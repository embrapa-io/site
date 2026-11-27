#!/bin/bash
#
# Instalador do Releaser do Embrapa I/O. Prepara uma VM Ubuntu Server 26.04 ou Debian 13 (amd64) para receber as builds
# de produção de um projeto pelo Releaser (embrapa.io/docs/releaser), com logs e métricas no Grafana da plataforma.
# Variação do cluster.sh (embrapa.io/cluster.sh) para servidores fora da rede de clusters: não conversa com a Dashboard,
# não cria o usuário io, não instala painel nem proxy. As portas 80 e 443 ficam para as aplicações.
#
# Uso (como root, na VM):
#
#   curl -fsSL https://embrapa.io/releaser.sh -o /root/releaser.sh
#   sh /root/releaser.sh setup             # verificação prévia, perguntas no terminal e instalação
#   sh /root/releaser.sh status            # confere a instalação, sem mudar nada
#   sh /root/releaser.sh repair            # reaplica os ajustes idempotentes (sysctl, daemon.json, Alloy, CRON…) e confere
#
# O setup é idempotente: se falhar, corrija o que ele apontou e rode de novo. As respostas ficam em /root/releaser.env
# (só o root lê), e um setup seguinte não pergunta de novo o que já está lá.
#
# Ao terminar, o contêiner 'releaser' está no ar e o comando 'io' está instalado no servidor. A configuração do Releaser
# (token do GitLab, SMTP, pasta de backups) é feita pelo próprio 'io', no primeiro uso: Run now: io
#
# Variáveis (ambiente ou /root/releaser.env; o setup pergunta as que faltarem):
#
#   HOST=apps.cnpxx.embrapa.br          nome do servidor (vira o hostname e o rótulo 'host' nos logs e nas métricas)
#   LOKI_USER e LOKI_PASS               credenciais do Grafana do Embrapa I/O (peça por e-mail a io@embrapa.br)
#   DOCKER_POOL=172.30.0.0/16           faixa de onde o Docker tira as redes das builds (uma /24 por rede)
#   RELEASER_DIR=/root/releaser         diretório de configuração do Releaser (montado em /data; mantenha em disco local)
#   BACKUP_DIR=/root/backup             pasta dos backups de todas as builds (o 'io' pergunta por ela; aqui só é criada)
#   RELEASER_VERSION=1.26.11-11         versão do Releaser a instalar (padrão: a mais nova publicada no Docker Hub)
#   IO_TEST=1                           laboratório: aceita VM pequena e credenciais do Loki vazias (sem envio ao Grafana)
#
# Log completo: /var/log/embrapa.io-releaser-setup.log
#
# Fonte: github.com/embrapa-io/site (releaser.sh), publicado em embrapa.io/releaser.sh.

# Chamado por `sh releaser.sh`: continua no bash.
if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi

set -uo pipefail

VERSION=1.26.11-1

ENV_FILE=/root/releaser.env
# shellcheck disable=SC1090
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

HOST=${HOST:-}
LOKI_USER=${LOKI_USER:-}
LOKI_PASS=${LOKI_PASS:-}
DOCKER_POOL=${DOCKER_POOL:-172.30.0.0/16}
RELEASER_DIR=${RELEASER_DIR:-/root/releaser}
BACKUP_DIR=${BACKUP_DIR:-/root/backup}
RELEASER_VERSION=${RELEASER_VERSION:-}
IO_TEST=${IO_TEST:-0}

LOKI_URL=https://loki.embrapa.io/loki/api/v1/push
PROMETHEUS_URL=https://prometheus.embrapa.io/api/v1/write

LOG=/var/log/embrapa.io-releaser-setup.log
STATE=/etc/embrapa-io-releaser
IMAGE=embrapa/releaser
CONTAINER=releaser
PORT_RANGE=49152-65535

# Requisitos mínimos de um servidor de release pequeno (o Releaser em si pesa pouco; o que pesa são as builds).
MIN_CPU=2
MIN_RAM_GB=4
MIN_FREE_GB=40

# Sistemas aceitos: Ubuntu Server 26.04 LTS (recomendado) e Debian 13, ambos amd64. DISTRO decide os repositórios.
DISTRO=$( . /etc/os-release 2> /dev/null; echo "${ID:-}" )
case "$DISTRO" in
  debian) OS_REPO=http://deb.debian.org/debian/ ;;
  *) DISTRO=ubuntu; OS_REPO=http://archive.ubuntu.com/ubuntu/ ;;
esac

# Saída que a VM precisa ter (qualquer resposta HTTP serve: o teste é de rede, não de autorização).
OUTBOUND=(
  "Repositório do sistema|$OS_REPO"
  "Repositório do Docker|https://download.docker.com/linux/$DISTRO/"
  "Docker Hub|https://registry-1.docker.io/v2/"
  "Docker Hub (API de tags)|https://hub.docker.com/v2/repositories/$IMAGE/tags/"
  "GitLab do Embrapa I/O|https://git.embrapa.io/users/sign_in"
  "Core do Embrapa I/O (catálogos)|https://core.embrapa.io/metadata/boilerplates.json"
  "Loki do Embrapa I/O|https://loki.embrapa.io/ready"
  "Prometheus do Embrapa I/O|https://prometheus.embrapa.io/"
  "Repositório do Grafana (Alloy)|https://apt.grafana.com/"
  "Banco de CVEs do Trivy (ghcr.io)|https://ghcr.io/v2/"
)

# --------------------------------------------------------------------------------------------------------------------
# Utilitários
# --------------------------------------------------------------------------------------------------------------------

exec 3>&1

say () { echo "$*" >&3; echo "$(date '+%F %T') $*" >> "$LOG"; }
ok () { say "  ✅  $*"; }
bad () { say "  ❌  $*"; }
warn () { say "  ⚠️  $*"; }
die () { say ""; say "❌  $*"; exit 1; }

need_root () { [ "$(id -u)" = 0 ] || die "Rode como root (sudo -i)."; }

# O script usa python3 para JSON (daemon.json, API do Docker Hub). A instalação mínima do Debian pode não trazê-lo.
need_python () {
  command -v python3 > /dev/null && return 0
  say "Instalando o python3, que o releaser.sh usa (a instalação mínima do Debian não traz)..."
  { apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3; } >> "$LOG" 2>&1 || die "Não foi possível instalar o python3 (veja $LOG)."
}

# Código HTTP de um destino, em até três tentativas: espelhos atrás de um nome e firewalls das Unidades falham de vez
# em quando, e uma tentativa só já recusou servidor bom. 000 = sem resposta.
outbound_code () {
  local code=000 try
  for try in 1 2 3; do
    code=$(curl -s -o /dev/null --connect-timeout 5 --max-time 10 -w '%{http_code}' "$1" 2>> "$LOG")
    [ "$code" != 000 ] && break
    [ "$try" = 3 ] || sleep 2
  done
  echo "$code"
}

# Conexão TCP (o clone do código sai pela porta 22 do GitLab; sem ela, o Releaser clona por HTTPS com GITLAB_SSH).
tcp_open () { timeout 5 bash -c "exec 3<> /dev/tcp/$1/$2" 2> /dev/null; }

# Em subshell: o /etc/os-release define VERSION, que aqui é a versão do script.
os_ok () { ( . /etc/os-release; { [ "${ID:-}" = ubuntu ] && [ "${VERSION_ID:-}" = 26.04 ]; } || { [ "${ID:-}" = debian ] && [ "${VERSION_ID:-}" = 13 ]; } ); }
os_pretty () { ( . /etc/os-release; echo "${PRETTY_NAME:-${ID:-?} ${VERSION_ID:-}}" ); }
os_amd64 () { os_ok && [ "$(uname -m)" = x86_64 ]; }

docker_snap () { snap list docker > /dev/null 2>&1; }
docker_apt () { dpkg -s docker-ce > /dev/null 2>&1; }

valid_host () { [[ "$1" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$ ]]; }
valid_pool () { [[ "$1" =~ ^(10\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])|192\.168)\.[0-9]{1,3}\.[0-9]{1,3}/(1[2-9]|2[0-3])$ ]]; }

apt_q () { DEBIAN_FRONTEND=noninteractive apt-get -y -q -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold "$@"; }

# ---- Perguntas no terminal (só o que não veio por variável). As respostas não vão para o log.
can_ask () { [ -t 0 ] && [ -r /dev/tty ]; }

ask () { # ask rótulo [-s]
  local answer=''
  printf '    %s' "$1" > /dev/tty
  if [ "${2:-}" = -s ]; then read -r -s answer < /dev/tty; printf '\n' > /dev/tty; else read -r answer < /dev/tty; fi
  printf '%s' "$answer"
}

# Grava as respostas para o status, o repair e um setup seguinte (a senha do Loki também fica no daemon.json).
save_env () {
  ( umask 077; cat > "$ENV_FILE" << EOF
# Embrapa I/O (releaser.sh $VERSION): respostas do setup em $(date +%F). Só o root lê. Para mudar, edite e rode o setup.
HOST=$HOST
LOKI_USER=$LOKI_USER
LOKI_PASS='$LOKI_PASS'
DOCKER_POOL=$DOCKER_POOL
RELEASER_DIR=$RELEASER_DIR
BACKUP_DIR=$BACKUP_DIR
EOF
  )
}

# --------------------------------------------------------------------------------------------------------------------
# Verificação prévia (não muda nada na VM)
# --------------------------------------------------------------------------------------------------------------------

preflight () { # devolve 1 se algum item obrigatório falhar
  local failed=0
  add () { if [ "$1" = 1 ]; then ok "$2: $3"; else bad "$2: $3"; failed=1; fi; }

  if os_ok; then add 1 "Sistema" "$(os_pretty)"; else add 0 "Sistema" "$(os_pretty) (é preciso o Ubuntu Server 26.04 LTS ou o Debian 13)"; fi

  local arch; arch=$(uname -m)
  if [ "$arch" = x86_64 ]; then add 1 "Arquitetura" "amd64"; else add 0 "Arquitetura" "$arch (é preciso amd64)"; fi

  local cpu ram; cpu=$(nproc); ram=$(awk '/MemTotal/ {printf "%d", $2/1024/1024 + 0.5}' /proc/meminfo)
  if [ "$cpu" -ge "$MIN_CPU" ] || [ "$IO_TEST" = 1 ]; then add 1 "Processador" "$cpu vCPU"; else add 0 "Processador" "$cpu vCPU (mínimo $MIN_CPU)"; fi
  if [ "$ram" -ge "$MIN_RAM_GB" ] || [ "$IO_TEST" = 1 ]; then add 1 "Memória" "${ram} GB"; else add 0 "Memória" "${ram} GB (mínimo $MIN_RAM_GB GB)"; fi

  # Disco: o diretório do Releaser (clones das builds) e os volumes do Docker (/var/lib/docker) ficam no disco local.
  local free fstype
  free=$(df -BG --output=avail "$(dirname "$RELEASER_DIR")" | tail -1 | tr -dc 0-9)
  if [ "$free" -ge "$MIN_FREE_GB" ] || [ "$IO_TEST" = 1 ]; then add 1 "Disco" "${free} GB livres em $(dirname "$RELEASER_DIR")"
  else add 0 "Disco" "${free} GB livres em $(dirname "$RELEASER_DIR") (mínimo $MIN_FREE_GB GB)"; fi
  fstype=$(findmnt -n -o FSTYPE --target "$(dirname "$RELEASER_DIR")" 2> /dev/null)
  case "$fstype" in
    nfs*|cifs|smb*|fuse.sshfs|glusterfs|ceph) add 0 "Diretório do Releaser" "$RELEASER_DIR em $fstype: precisa ser disco local (uma oscilação do servidor de arquivos interrompe o deploy)" ;;
    *) add 1 "Diretório do Releaser" "$RELEASER_DIR em disco local${fstype:+ ($fstype)}" ;;
  esac

  # Docker: snap é recusado; pelo apt é aproveitado.
  if docker_snap; then
    add 0 "Docker" "instalado pelo snap: remova (snap remove --purge docker) e rode de novo; o Releaser usa o repositório oficial"
  elif docker_apt; then
    add 1 "Docker" "já instalado pelo repositório oficial ($(dpkg-query -W -f '${Version}' docker-ce)); será ajustado"
    if [ "$(docker info --format '{{.Swarm.LocalNodeState}}' 2> /dev/null)" = active ]; then
      add 0 "Orquestrador" "Docker Swarm ativo: o releaser.sh prepara servidores em Docker Compose (o Swarm segue o roteiro manual da documentação)"
    fi
  elif command -v docker > /dev/null; then
    add 0 "Docker" "instalado fora do repositório oficial ($(command -v docker)): remova e rode de novo"
  else
    add 1 "Docker" "não instalado; será instalado do repositório oficial"
  fi

  # Faixa das redes Docker: nenhuma rota do sistema (VPN, rede da Unidade) na mesma faixa /16. As redes que o próprio
  # Docker já criou (docker0, br-*) não contam: é dele que a faixa é.
  local p clash; p=${DOCKER_POOL%%/*}; p=${p%.*}; p=${p%.*}
  clash=$(ip -4 route | grep -vE 'dev (docker0|br-[0-9a-f]+)' | awk '{print $1}' | grep "^$p\." | head -1)
  if [ -z "$clash" ]; then add 1 "Redes Docker" "$DOCKER_POOL livre (uma /24 por rede)"
  else add 0 "Redes Docker" "$DOCKER_POOL conflita com a rota $clash: escolha outra faixa (DOCKER_POOL)"; fi

  # Relógio sincronizado (TLS, tokens e os horários dos backups dependem dele).
  if [ "$(timedatectl show -p NTPSynchronized --value 2> /dev/null)" = yes ]; then add 1 "Relógio" "sincronizado"
  elif command -v chronyc > /dev/null 2>&1; then
    # Ubuntu 26.04: o chrony usa NTS por padrão, que precisa de saída TCP 4460 além da UDP 123.
    add 0 "Relógio" "não sincronizado (chrony; veja chronyc -N sources): o NTS do Ubuntu precisa de saída TCP 4460 além da UDP 123; libere a 4460 ou aponte o chrony para um NTP sem NTS (como a.ntp.br) em /etc/chrony/sources.d/"
  else add 0 "Relógio" "não sincronizado: libere o NTP da Unidade (systemd-timesyncd)"; fi

  # Saída para a internet.
  local item name url code
  for item in "${OUTBOUND[@]}"; do
    name=${item%%|*}; url=${item#*|}
    code=$(outbound_code "$url")
    if [ "$code" != 000 ]; then add 1 "Saída: $name" "$url (HTTP $code)"
    elif [[ "$name" == *Trivy* ]]; then warn "Saída: $name" "$url sem resposta: sem ela, desligue o relato de CVEs nas builds (\"stats\": { \"cve\": false })"
    elif [[ "$name" == *Loki* || "$name" == *Prometheus* ]] && [ "$IO_TEST" = 1 ]; then warn "Saída: $name" "$url sem resposta (laboratório)"
    else add 0 "Saída: $name" "$url sem resposta: libere a saída no firewall"; fi
  done
  if tcp_open git.embrapa.io 22; then ok "Saída: GitLab por SSH: porta 22 aberta (clone das aplicações)"
  else warn "Saída: GitLab por SSH: porta 22 fechada; o Releaser clona por HTTPS com GITLAB_SSH no .env (embrapa.io/docs/releaser/#https)"; fi

  return $failed
}

# --------------------------------------------------------------------------------------------------------------------
# Etapas da instalação. Cada uma roda num subshell com set -e e a saída no log; precisa ser idempotente.
# --------------------------------------------------------------------------------------------------------------------

SUBSTEPS=(system docker loki alloy releaser cli cron)

declare -A LABEL=(
  [system]="Sistema (pacotes, hostname, sysctl)"
  [docker]="Docker (repositório oficial)"
  [loki]="Loki (plugin e daemon.json com a faixa das redes)"
  [alloy]="Grafana Alloy (métricas e journal)"
  [releaser]="Releaser (contêiner $CONTAINER)"
  [cli]="Comando io no servidor"
  [cron]="CRON e ajustes (limpeza, logrotate, unattended-upgrades)"
)

apply_sysctl () {
  cat > /etc/sysctl.d/99-embrapa-io.conf << EOF
# Embrapa I/O (releaser.sh). A reserva de portas evita que uma conexão de saída ocupe a porta publicada de uma build.
fs.file-max=2000000
kernel.pid_max=128000
kernel.threads-max=128000
vm.max_map_count=524288
net.ipv4.ip_local_reserved_ports=$PORT_RANGE
EOF
  sysctl --system > /dev/null
}

apply_hostname () {
  hostnamectl set-hostname "$HOST"
  if grep -q '^127\.0\.1\.1' /etc/hosts; then
    sed -i "s/^127\.0\.1\.1.*/127.0.1.1 $HOST ${HOST%%.*}/" /etc/hosts
  else
    echo "127.0.1.1 $HOST ${HOST%%.*}" >> /etc/hosts
  fi
}

apply_dirs () {
  install -d -m 700 "$RELEASER_DIR"
  install -d -m 700 "$BACKUP_DIR"
}

apply_cron () {
  cat > /etc/cron.d/embrapa-io-cleanup << 'EOF'
# Embrapa I/O (releaser.sh): cache de build e imagens sem uso há mais de 24 h (as imagens das builds no ar não contam).
30 4 * * * root docker builder prune -af --filter until=24h > /dev/null 2>&1; docker image prune -af --filter until=24h > /dev/null 2>&1
EOF
  # O cron ignora arquivo com escrita para o grupo ou outros («INSECURE MODE»).
  chmod 644 /etc/cron.d/embrapa-io-cleanup
  cat > /etc/logrotate.d/embrapa-io << 'EOF'
/var/log/embrapa.io*.log /var/log/embrapa-*.log {
  weekly
  rotate 8
  compress
  missingok
  notifempty
}
EOF
  # Só atualizações de segurança, sem reinício automático; o Docker fica para quem administra, numa janela.
  cat > /etc/apt/apt.conf.d/52embrapa-io-unattended << 'EOF'
Unattended-Upgrade::Origins-Pattern { "origin=Ubuntu,archive=${distro_codename}-security"; "origin=Debian,codename=${distro_codename}-security,label=Debian-Security"; };
Unattended-Upgrade::Package-Blacklist { "docker-ce"; "docker-ce-cli"; "docker-ce-rootless-extras"; "containerd.io"; "docker-buildx-plugin"; "docker-compose-plugin"; };
Unattended-Upgrade::Automatic-Reboot "false";
EOF
  cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
}

step_system () {
  apt_q update
  apt_q upgrade
  apt_q dist-upgrade
  apt_q install ca-certificates curl gnupg python3 cron logrotate unattended-upgrades

  [ "$(hostname)" = "$HOST" ] || apply_hostname
  apply_sysctl
  apply_dirs
}

step_docker () {
  docker_snap && { echo "Docker pelo snap: recusado"; return 1; }

  if ! docker_apt; then
    . /etc/os-release
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/$DISTRO/gpg" -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DISTRO $VERSION_CODENAME stable" > /etc/apt/sources.list.d/docker.list
    apt_q update
    apt_q install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi

  systemctl enable --now docker
  docker version > /dev/null
  docker compose version
}

# O daemon.json do padrão: o atual (argumento) com o driver de log, as opções do Embrapa I/O e a faixa das redes por
# cima. Sem credenciais do Loki (laboratório), o driver fica o json-file.
daemon_json () {
  LOKI_URL="$LOKI_URL" LOKI_USER="$LOKI_USER" LOKI_PASS="$LOKI_PASS" DOCKER_POOL="$DOCKER_POOL" python3 - "$1" << 'PY'
import json, os, sys, urllib.parse
path = sys.argv[1]
try:
    cfg = json.load(open(path))
except Exception:
    cfg = {}
cfg.update({"debug": False, "live-restore": True})
# As redes das builds (uma por stack, criada pelo Releaser sem sub-rede) e as demais redes do Docker saem desta faixa,
# em /24. Redes que já existem não mudam.
cfg["default-address-pools"] = [{"base": os.environ["DOCKER_POOL"], "size": 24}]
user, password = os.environ["LOKI_USER"], os.environ["LOKI_PASS"]
if user and password:
    u = urllib.parse.urlsplit(os.environ["LOKI_URL"])
    auth = urllib.parse.quote(user, safe="") + ":" + urllib.parse.quote(password, safe="")
    cfg["log-driver"] = "loki"
    cfg["log-opts"] = {
        "loki-url": f"{u.scheme}://{auth}@{u.netloc}{u.path}",
        "loki-external-labels": "container_name={{.Name}},job=docker",
        "loki-batch-size": "1048576", "loki-batch-wait": "1s", "loki-retries": "5",
        "loki-min-backoff": "500ms", "loki-max-backoff": "5s", "loki-timeout": "10s",
        "mode": "non-blocking", "max-buffer-size": "4m",
        "keep-file": "false", "max-size": "10m", "max-file": "3",
    }
else:
    cfg["log-driver"] = "json-file"
    cfg["log-opts"] = {"max-size": "10m", "max-file": "3"}
print(json.dumps(cfg, indent=2))
PY
}

step_loki () {
  if [ -n "$LOKI_USER" ] && [ -n "$LOKI_PASS" ]; then
    docker plugin inspect loki > /dev/null 2>&1 || docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
  fi

  local f=/etc/docker/daemon.json tmp
  tmp=$(mktemp)
  daemon_json "$f" > "$tmp"
  dockerd --validate --config-file "$tmp"

  if ! cmp -s "$tmp" "$f"; then
    install -m 600 "$tmp" "$f"
    # live-restore: os contêineres continuam no ar durante o reinício do daemon.
    systemctl restart docker
  fi
  rm -f "$tmp"

  if [ -n "$LOKI_USER" ] && [ -n "$LOKI_PASS" ]; then docker info --format '{{.LoggingDriver}}' | grep -qx loki; fi
  docker info --format '{{range .DefaultAddressPools}}{{.Base}}{{end}}' | grep -qx "$DOCKER_POOL"
}

write_alloy_config () {
  cat << EOF
// Grafana Alloy — servidor com o Releaser do Embrapa I/O ($HOST), gerado pelo releaser.sh. Não edite: rode o setup de novo.

discovery.relabel "journal_labels" {
  targets = []

  rule {
    source_labels = ["__journal__hostname"]
    target_label  = "host"
  }

  rule {
    source_labels = ["__journal__systemd_unit"]
    target_label  = "unit"
  }

  rule {
    source_labels = ["__journal_priority_keyword"]
    target_label  = "level"
  }
}

loki.source.journal "journal" {
  max_age       = "12h"
  forward_to    = [loki.write.default.receiver]
  relabel_rules = discovery.relabel.journal_labels.rules
  labels        = { job = "systemd-journal" }
}

local.file_match "varlog" {
  path_targets = [{
    __address__ = "localhost",
    __path__    = "/var/log/*.log",
    job         = "varlogs",
    host        = constants.hostname,
  }]
}

loki.source.file "varlog" {
  targets    = local.file_match.varlog.targets
  forward_to = [loki.write.default.receiver]
}

loki.write "default" {
  endpoint {
    url = "$LOKI_URL"

    basic_auth {
      username = "$LOKI_USER"
      password = "$LOKI_PASS"
    }
  }
}

prometheus.exporter.unix "default" { }

prometheus.relabel "add_ip" {
  forward_to = [prometheus.remote_write.default.receiver]

  rule {
    target_label = "ip"
    replacement  = sys.env("HOST_IP")
  }
}

prometheus.scrape "node" {
  targets         = prometheus.exporter.unix.default.targets
  forward_to      = [prometheus.relabel.add_ip.receiver]
  scrape_interval = "60s"
}

prometheus.remote_write "default" {
  endpoint {
    url = "$PROMETHEUS_URL"

    basic_auth {
      username = "$LOKI_USER"
      password = "$LOKI_PASS"
    }
  }
}
EOF
}

step_alloy () {
  if [ -z "$LOKI_USER" ] || [ -z "$LOKI_PASS" ]; then echo "Alloy: pulado (sem credenciais do Grafana; laboratório)"; return 0; fi

  # Repositório do Grafana só se ainda não houver um (a TI da Unidade pode já ter, com outra chave).
  if ! grep -rqs "apt.grafana.com" /etc/apt/sources.list /etc/apt/sources.list.d/; then
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor --yes -o /etc/apt/keyrings/grafana.gpg
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list
    apt_q update
  fi
  dpkg -s alloy > /dev/null 2>&1 || apt_q install alloy

  local tmp; tmp=$(mktemp)
  write_alloy_config > "$tmp"
  alloy fmt "$tmp" > /dev/null
  install -m 640 -o root -g alloy "$tmp" /etc/alloy/config.alloy
  rm -f "$tmp"

  mkdir -p /etc/systemd/system/alloy.service.d
  cat > /etc/systemd/system/alloy.service.d/override.conf << 'EOF'
[Service]
ExecStartPre=+/bin/bash -c 'echo "HOST_IP=$(hostname -I | awk '"'"'{print $1}'"'"')" > /run/alloy-env'
EnvironmentFile=-/run/alloy-env
EOF
  usermod -aG systemd-journal alloy
  systemctl daemon-reload
  systemctl enable alloy
  systemctl restart alloy
  sleep 3
  systemctl is-active --quiet alloy
}

# Versão mais nova publicada no Docker Hub (formato MAJOR.AA.M-N, nunca a latest). Sem resposta, a latest é baixada
# e a versão vem de dentro da imagem (IO_RELEASER_VERSION): o contêiner nasce sempre com a tag exata, como o io upgrade.
latest_version () {
  curl -fsS --max-time 15 "https://hub.docker.com/v2/repositories/$IMAGE/tags/?page_size=100&ordering=last_updated" 2>> "$LOG" \
    | python3 -c 'import json, re, sys
tags = [t["name"] for t in json.load(sys.stdin).get("results", []) if re.fullmatch(r"\d+\.\d+\.\d+-\d+", t["name"])]
key = lambda v: [int(x) for x in re.split(r"[.-]", v)]
print(max(tags, key=key) if tags else "")' 2> /dev/null
}

image_version () { docker run --rm --entrypoint printenv "$1" IO_RELEASER_VERSION 2> /dev/null | tr -d '[:space:]'; }

container_image () { docker inspect --format '{{.Config.Image}}' "$CONTAINER" 2> /dev/null; }

step_releaser () {
  apply_dirs

  local version=$RELEASER_VERSION
  if [ -z "$version" ]; then version=$(latest_version); fi
  if [ -z "$version" ]; then
    docker pull "$IMAGE:latest"
    version=$(image_version "$IMAGE:latest")
    [ -n "$version" ] || { echo "Não foi possível descobrir a versão do Releaser"; return 1; }
  fi
  docker pull "$IMAGE:$version"
  echo "Releaser $version"

  # Contêiner que já existe fica como está (a troca de versão é do io upgrade); parado, é religado.
  if docker inspect "$CONTAINER" > /dev/null 2>&1; then
    local current; current=$(container_image)
    echo "Contêiner $CONTAINER já existe com a imagem $current"
    docker inspect --format '{{.State.Running}}' "$CONTAINER" | grep -qx true || docker start "$CONTAINER"
  else
    docker run --name "$CONTAINER" \
      -v "$RELEASER_DIR:/data" \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --restart always -d --sig-proxy=false \
      "$IMAGE:$version"
  fi

  local try
  for try in 1 2 3 4 5 6; do
    docker inspect --format '{{.State.Running}}' "$CONTAINER" | grep -qx true && break
    [ "$try" = 6 ] && { echo "O contêiner $CONTAINER não ficou no ar (docker logs $CONTAINER)"; return 1; }
    sleep 5
  done
  date -Is > "$STATE/installed"
  echo "releaser.sh $VERSION · $IMAGE:$version" >> "$STATE/installed"
}

# O comando io do servidor (docs/releaser/#cli). Desde o Releaser 1.26.11-7, o io cli não depende da configuração: o
# primeiro io de quem for configurar abre o assistente.
step_cli () {
  if docker exec "$CONTAINER" io cli --yes; then :
  else
    echo "io cli pelo contêiner auxiliar falhou; gravando pela alternativa manual"
    docker exec "$CONTAINER" io cli --print > /usr/local/bin/.io.tmp
    chmod +x /usr/local/bin/.io.tmp
    mv /usr/local/bin/.io.tmp /usr/local/bin/io
  fi
  test -x /usr/local/bin/io
  grep -q 'Embrapa I/O Releaser host wrapper' /usr/local/bin/io
}

step_cron () {
  apply_cron
  systemctl enable --now cron unattended-upgrades
}

run_substep () {
  local key=$1 rc

  say "  … ${LABEL[$key]}"
  ( set -e; "step_$key" ) >> "$LOG" 2>&1
  rc=$?

  if [ $rc -ne 0 ]; then
    bad "${LABEL[$key]}"
    die "A instalação parou em «${LABEL[$key]}». Detalhes em $LOG. Corrija e rode o setup de novo."
  fi
  ok "${LABEL[$key]}"
}

# --------------------------------------------------------------------------------------------------------------------
# Conferência (status) e reparo
# --------------------------------------------------------------------------------------------------------------------

STATUS_FAIL=0

check () { # check rótulo comando…
  local label=$1; shift
  if ( "$@" ) >> "$LOG" 2>&1; then ok "$label"; else bad "$label"; STATUS_FAIL=1; fi
}

# As credenciais do Grafana desta VM: as do daemon.json (o setup as pôs lá), senão as do releaser.env.
load_creds () {
  local out
  out=$(python3 - << 'PY' 2> /dev/null
import json, urllib.parse
c = json.load(open("/etc/docker/daemon.json"))
u = urllib.parse.urlsplit((c.get("log-opts") or {}).get("loki-url", ""))
print(urllib.parse.unquote(u.username or ""))
print(urllib.parse.unquote(u.password or ""))
PY
  ) || return 0
  [ -n "$(echo "$out" | sed -n 1p)" ] && { LOKI_USER=$(echo "$out" | sed -n 1p); LOKI_PASS=$(echo "$out" | sed -n 2p); }
  return 0
}

cmd_status () {
  need_root
  local host; host=$(hostname)
  load_creds

  say "Embrapa I/O — conferência do servidor $host (releaser.sh $VERSION)"
  say ""
  check "Hostname com domínio ($host)" bash -c "[[ '$host' == *.* ]]"
  check "Ubuntu 26.04 ou Debian 13, amd64" os_amd64
  check "Reserva de portas $PORT_RANGE" bash -c "sysctl -n net.ipv4.ip_local_reserved_ports | grep -q '$PORT_RANGE'"
  check "Docker do repositório oficial (sem snap)" bash -c "dpkg -s docker-ce > /dev/null && ! snap list docker > /dev/null 2>&1"
  check "Docker Compose" docker compose version
  check "Faixa das redes Docker ($DOCKER_POOL)" bash -c "docker info --format '{{range .DefaultAddressPools}}{{.Base}}{{end}}' | grep -qx '$DOCKER_POOL'"
  if [ -n "$LOKI_USER" ]; then
    check "Driver de log loki" bash -c "docker info --format '{{.LoggingDriver}}' | grep -qx loki"
    check "Alloy ativo" systemctl is-active --quiet alloy
    check "Alloy mandando ao Embrapa I/O" grep -q 'gerado pelo releaser.sh' /etc/alloy/config.alloy
  else
    warn "Logs e métricas: sem credenciais do Grafana (laboratório, ou setup ainda não feito)"
  fi
  check "Diretório do Releaser ($RELEASER_DIR, modo 700)" bash -c "[ \"\$(stat -c '%U %a' $RELEASER_DIR)\" = 'root 700' ]"
  check "Pasta de backups ($BACKUP_DIR)" test -d "$BACKUP_DIR"
  check "Contêiner $CONTAINER no ar" bash -c "docker inspect --format '{{.State.Running}}' $CONTAINER | grep -qx true"
  check "Contêiner com a tag exata da versão" bash -c "docker inspect --format '{{.Config.Image}}' $CONTAINER | grep -qE ':[0-9]+\.[0-9]+\.[0-9]+-[0-9]+\$'"
  check "Contêiner com $RELEASER_DIR em /data e o socket do Docker" bash -c "docker inspect --format '{{range .Mounts}}{{.Source}}:{{.Destination}} {{end}}' $CONTAINER | grep -q '$RELEASER_DIR:/data ' && docker inspect --format '{{range .Mounts}}{{.Source}}:{{.Destination}} {{end}}' $CONTAINER | grep -q '/var/run/docker.sock:/var/run/docker.sock'"
  check "Comando io no servidor" bash -c "test -x /usr/local/bin/io && grep -q 'Embrapa I/O Releaser host wrapper' /usr/local/bin/io"
  if [ -f "$RELEASER_DIR/.env" ]; then
    check "Releaser configurado (io check)" docker exec "$CONTAINER" io check
  else
    warn "Releaser ainda sem configuração: rode 'io' para o assistente (token do GitLab, SMTP, pasta de backups)"
  fi
  check "CRON de limpeza" bash -c 'test "$(stat -c %a /etc/cron.d/embrapa-io-cleanup 2> /dev/null)" = 644'
  check "unattended-upgrades (só segurança, Docker retido)" grep -q docker-ce /etc/apt/apt.conf.d/52embrapa-io-unattended
  say ""
  if [ "$STATUS_FAIL" = 0 ]; then say "Tudo certo."; else say "Há itens com problema (detalhes em $LOG). O 'repair' corrige os ajustes de sistema."; fi
  return $STATUS_FAIL
}

cmd_repair () {
  need_root
  need_python
  HOST=${HOST:-$(hostname)}
  load_creds
  say "Embrapa I/O — reaplicando os ajustes idempotentes"
  {
    apply_sysctl
    apply_dirs
    apply_cron
    if docker_apt; then
      step_loki
      [ -n "$LOKI_USER" ] && [ -n "$LOKI_PASS" ] && step_alloy
      if docker inspect "$CONTAINER" > /dev/null 2>&1; then
        docker inspect --format '{{.State.Running}}' "$CONTAINER" | grep -qx true || docker start "$CONTAINER"
        [ -x /usr/local/bin/io ] || step_cli
      fi
    fi
  } >> "$LOG" 2>&1 || die "Falha ao reaplicar (detalhes em $LOG)."
  say ""
  cmd_status
}

# --------------------------------------------------------------------------------------------------------------------
# Setup
# --------------------------------------------------------------------------------------------------------------------

setup_ask () {
  local answer try current

  # Nome do servidor: o hostname, se já tiver domínio.
  if [ -z "$HOST" ]; then
    current=$(hostname); valid_host "$current" || current=''
    can_ask || die "Sem terminal para perguntar: informe HOST em $ENV_FILE ou no ambiente."
    say "🖥   Nome do servidor (com domínio; vira o hostname e o rótulo 'host' nos logs e nas métricas):"
    for try in 1 2 3; do
      answer=$(ask "Nome${current:+ [$current]}: " | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
      answer=${answer:-$current}
      valid_host "$answer" && { HOST=$answer; break; }
      say "    Nome inválido: '$answer' (ex.: apps.cnpgc.embrapa.br)."
      [ "$try" = 3 ] && die "Três nomes inválidos. Nada foi alterado; rode de novo."
    done
    say ""
  fi

  # Credenciais do Grafana: as mesmas do driver de log do Docker e do Alloy. Pedidas à equipe da plataforma.
  if { [ -z "$LOKI_USER" ] || [ -z "$LOKI_PASS" ]; } && [ "$IO_TEST" != 1 ]; then
    can_ask || die "Sem terminal para perguntar: informe LOKI_USER e LOKI_PASS em $ENV_FILE ou no ambiente."
    say "📈  Credenciais do Grafana do Embrapa I/O (logs no Loki e métricas no Prometheus):"
    say "    Peça por e-mail a io@embrapa.br ou na sala Arquitetos de Soluções do Google Chat. Ficam só nesta VM."
    LOKI_USER=$(ask "Usuário: " | tr -d '[:space:]')
    [ -n "$LOKI_USER" ] && LOKI_PASS=$(ask "Senha: " -s)
    [ -n "$LOKI_USER" ] && [ -n "$LOKI_PASS" ] || die "Sem as credenciais do Grafana, o servidor fica sem logs e métricas na plataforma. Para um laboratório, rode com IO_TEST=1."
    say ""
  fi

  valid_pool "$DOCKER_POOL" || die "DOCKER_POOL inválido: '$DOCKER_POOL' (faixa privada com máscara entre /12 e /23, ex.: 172.30.0.0/16)."
  [[ "$RELEASER_DIR" == /* ]] && [[ "$BACKUP_DIR" == /* ]] || die "RELEASER_DIR e BACKUP_DIR precisam ser caminhos absolutos."
}

cmd_setup () {
  need_root
  need_python

  mkdir -p "$STATE"; chmod 700 "$STATE"
  touch "$LOG"; chmod 600 "$LOG"

  say "Embrapa I/O — preparação de servidor para o Releaser (releaser.sh $VERSION)"
  [ "$IO_TEST" = 1 ] && echo "$(date '+%F %T') Laboratório (IO_TEST=1)" >> "$LOG"
  say ""
  setup_ask
  save_env
  say "Servidor: $HOST · Releaser em $RELEASER_DIR · backups em $BACKUP_DIR · redes Docker em $DOCKER_POOL${RELEASER_VERSION:+ · Releaser $RELEASER_VERSION}"

  say ""
  say "🔎  Verificação prévia (nada é alterado):"
  preflight || die "Corrija os itens marcados com ❌ e rode o setup de novo."

  say ""
  say "🛠  Instalação:"
  local key
  for key in "${SUBSTEPS[@]}"; do run_substep "$key"; done

  say ""
  say "🚀  Servidor preparado. O Releaser está no ar ($(container_image)) e o comando 'io' está instalado."
  say "   O que vem agora, pelo próprio io:"
  say "   • a configuração inicial (token read_api do GitLab, SMTP, pasta de backups $BACKUP_DIR) e a chave SSH para o GitLab;"
  say "   • cada build com 'io install <projeto>/<app>@<estágio>' (embrapa.io/docs/releaser/#install)."
  say "   Painel do Docker e proxy com certificados, se quiser, entram como apps do catálogo, com o monitoramento da"
  say "   plataforma: boilerplates Arcane ('io install … --allow-socket') e Nginx Proxy Manager (portas 80 e 443)."
  say "   Conferência local, a qualquer momento: sh /root/releaser.sh status"
  say ""
  say "Run now: io"
}

case "${1:-help}" in
  setup) shift; cmd_setup "$@" ;;
  status) touch "$LOG" 2> /dev/null; cmd_status ;;
  repair) touch "$LOG" 2> /dev/null; cmd_repair ;;
  version) echo "$VERSION" ;;
  *) sed -n '2,33p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
