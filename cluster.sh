#!/bin/bash
#
# Instalador dos clusters do Embrapa I/O. Prepara uma VM Ubuntu Server 26.04 ou Debian 13 (amd64) para receber as builds da
# plataforma, conversando com o assistente de cluster da Dashboard, que gera o token e acompanha cada etapa.
#
# Uso (como root, na VM):
#
#   curl -fsSL https://embrapa.io/cluster.sh -o /root/cluster.sh
#   sha256sum /root/cluster.sh            # confira com o valor mostrado na Dashboard
#   sh /root/cluster.sh setup <token>     # verificação prévia, espera a confirmação na Dashboard e instala
#   sh /root/cluster.sh status            # confere a instalação, sem mudar nada
#   sh /root/cluster.sh repair            # reaplica os ajustes idempotentes (sysctl, sudo, sudoers, CRON…) e confere
#
# O setup é idempotente: se falhar ou o token expirar, gere outro na Dashboard e rode de novo.
#
# Variáveis opcionais (ambiente ou /root/cluster.env):
#
#   IO_API=https://core.embrapa.io      API da plataforma
#   PANEL=arcane|none                   painel local (padrão: o escolhido no assistente, senão arcane)
#   DOCKERHUB_USER e DOCKERHUB_TOKEN    login no Docker Hub sem pergunta (token só leitura do NTI)
#   IO_TEST=1                           laboratório: aceita pouco espaço em disco, certificado autoassinado, sem Web Terminal
#
# Log completo: /var/log/embrapa.io-cluster-setup.log
#
# Fonte: github.com/embrapa-io/cluster (cluster.sh), publicado em embrapa.io/cluster.sh.

# Chamado por `sh cluster.sh`: continua no bash.
if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi

set -uo pipefail

VERSION=1.26.11-9

[ -f /root/cluster.env ] && . /root/cluster.env

IO_API=${IO_API:-https://core.embrapa.io}
IO_TEST=${IO_TEST:-0}
PANEL=${PANEL:-}

LOG=/var/log/embrapa.io-cluster-setup.log
STATE=/etc/embrapa-io
DATA=/var/io
CORE_IP_DEFAULT=200.202.148.38
PORT_RANGE=49152-65535

# Requisitos mínimos (faixa «pequeno» do assistente).
MIN_CPU=4
MIN_RAM_GB=15
MIN_DATA_GB=190

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
  "Loki do Embrapa I/O|https://loki.embrapa.io/ready"
  "Prometheus do Embrapa I/O|https://prometheus.embrapa.io/"
  "Core do Embrapa I/O|https://core.embrapa.io/status"
  "Site do Embrapa I/O|https://embrapa.io/"
  "Repositório do Grafana (Alloy)|https://apt.grafana.com/"
)

# Etapas da instalação, na ordem da Dashboard (contrato: backend/docs/cluster-api.md, etapa `install`).
SUBSTEPS=(system docker user loki alloy dockerhub certificate terminal panel cron cleanup)

declare -A LABEL=(
  [system]="Sistema (pacotes, hostname, sysctl, sudo clássico)"
  [docker]="Docker (repositório oficial)"
  [user]="Usuário io (grupo docker, /var/io, sudoers, chave da plataforma)"
  [loki]="Loki (plugin e daemon.json)"
  [alloy]="Grafana Alloy (métricas e journal)"
  [dockerhub]="Login no Docker Hub do NTI"
  [certificate]="Certificado do host (Let's Encrypt)"
  [terminal]="Web Terminal"
  [panel]="Painel local"
  [cron]="CRON e ajustes (limpeza, unattended-upgrades)"
  [cleanup]="Limpeza (token invalidado)"
)

# Chave pública da plataforma (a mesma do site/docs/cluster.md); a API pode mandar outra no /secrets.
PLATFORM_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCykAvX7CZmqw1bgOCOmRtgpfr55cjqO0v1+DImp4pKrITdFxZu0OqsJgHjio/yp4w5+KvWmFJa5woYbZry9inFciwKo3+rpGjBHJfNfDq70/q3VdSSInFrSMtWgBk0x5QZQ78ENkNkO9DRIdnnffN9bY1uibR6ZX0pCSSyTGgx3NlAakW47tYIzVcrrUGKGG8vZwSkl7GhEEXtNETp02WQpkUvYrNqgRrmw2lvv41QfRETIuNN7PDhJrDO4tYHtix5D+Pvd05IacgTVQxpi6vnMVdgrwbZ1RPw9TLLkoy3kZs45hLG9oipiYOiD6rxiIYC0f1iUaKz9PKZdfnF8Ya5XJFoL6NcBTPDGh01dkEBonOWt3lgpC/2SBM/SeClt8M2lI6KtqAkjPEKWhnirDP0lXzY2CYamnu2rD6p4z4OWAYG6ngQcCIK45vQvsSz8mfitWnJe89WCCaEVj+L1QO/hjnKJ+eKf5ze35HagFRhpIAB34FmGHO3N8yFCLqvHFNLw6dKl5IXU2cvJF1jwhL3coOx9oeFZLPk45Zze2e/Itjd9x84gWtmo60MvXVBsYGYlcZLzSgAbNGldMuxAFWs0ZvghNx+KZjg6fZ2hAlPHIg1MiAlztyLbbjV2Mjc6ke6sjBDvPkPZQde6G/T8Mp56cCtAb/77/dw78zruX5qyQ== embrapa.io"

# --------------------------------------------------------------------------------------------------------------------
# Utilitários
# --------------------------------------------------------------------------------------------------------------------

exec 3>&1

say () { echo "$*" >&3; echo "$(date '+%F %T') $*" >> "$LOG"; }
ok () { say "  ✅  $*"; }
bad () { say "  ❌  $*"; }
die () { say ""; say "❌  $*"; exit 1; }

# JSON sem dependências além do python3 (need_python garante que exista).
json_get () { python3 -c 'import json,sys
d=json.load(sys.stdin)
for k in sys.argv[1].split("."):
    d = d.get(k) if isinstance(d, dict) else None
print("" if d is None else (" ".join(d) if isinstance(d, list) else (json.dumps(d) if isinstance(d, dict) else d)))' "$1"; }

# Lista de evidências: linhas "ok|rótulo|detalhe" em $EVIDENCE → JSON.
evidence_json () { python3 -c 'import json,sys
out=[]
for line in open(sys.argv[1], encoding="utf-8"):
    line=line.rstrip("\n")
    if not line: continue
    ok,label,detail=(line.split("|",2)+["",""])[:3]
    out.append({"label":label,"ok":ok=="1","detail":detail})
print(json.dumps(out, ensure_ascii=False))' "$1"; }

api () { # api METHOD caminho [corpo-json]
  local method=$1 path=$2 body=${3:-}

  if [ -n "$body" ]; then
    curl -fsS --max-time 30 -X "$method" -H 'Content-Type: application/json' --data-binary "$body" "$IO_API$path"
  else
    curl -fsS --max-time 30 -X "$method" "$IO_API$path"
  fi
}

# Envia o andamento à Dashboard. Falha de rede não interrompe a instalação (fica no log).
progress () { # progress etapa subetapa status [arquivo de evidências] [resumo]
  [ -z "${TOKEN:-}" ] && return 0

  local body
  body=$(STEP="$1" SUB="$2" STATUS="$3" EV="${4:-}" SUMMARY="${5:-}" LOGTAIL="$( [ "$3" = failed ] && tail -n 40 "$LOG" || true )" python3 -c 'import json,os
b={"step":os.environ["STEP"],"status":os.environ["STATUS"]}
if os.environ["SUB"]: b["substep"]=os.environ["SUB"]
if os.environ["SUMMARY"]: b["summary"]=os.environ["SUMMARY"]
if os.environ["LOGTAIL"]: b["log"]=os.environ["LOGTAIL"]
ev=os.environ["EV"]
if ev:
    out=[]
    for line in open(ev, encoding="utf-8"):
        line=line.rstrip("\n")
        if line:
            ok,label,detail=(line.split("|",2)+["",""])[:3]
            out.append({"label":label,"ok":ok=="1","detail":detail})
    b["evidence"]=out
print(json.dumps(b, ensure_ascii=False))')

  api POST "/cluster/setup/$TOKEN/progress" "$body" > /dev/null 2>> "$LOG" || echo "$(date '+%F %T') aviso: andamento não enviado ($1/$2 $3)" >> "$LOG"
}

need_root () { [ "$(id -u)" = 0 ] || die "Rode como root (sudo -i)."; }

os_ok () { . /etc/os-release; { [ "${ID:-}" = ubuntu ] && [ "${VERSION_ID:-}" = 26.04 ]; } || { [ "${ID:-}" = debian ] && [ "${VERSION_ID:-}" = 13 ]; }; }

docker_snap () { snap list docker > /dev/null 2>&1; }

docker_apt () { dpkg -s docker-ce > /dev/null 2>&1; }

os_amd64 () { os_ok && [ "$(uname -m)" = x86_64 ]; }

# O clássico se apresenta como "Sudo version"; o sudo-rs, como "sudo-rs".
sudo_classic () { sudo -V 2> /dev/null | head -1 | grep -q '^Sudo version'; }

# Primeiros dois octetos de uma sub-rede "172.28.0.0" → "172.28."
prefix16 () { echo "$1" | cut -d. -f1-2; }

# --------------------------------------------------------------------------------------------------------------------
# Verificação prévia (não muda nada na VM, além do servidor HTTP temporário da checagem da porta 80)
# --------------------------------------------------------------------------------------------------------------------

check_file () { # caminho servido em http://<host>/.well-known/embrapa-io/check para o core conferir a porta 80
  echo "${TOKEN:0:12}"
}

HTTP_PID=

start_check_server () {
  local root=/var/www/html
  mkdir -p "$root/.well-known/embrapa-io"
  check_file > "$root/.well-known/embrapa-io/check"

  # A porta 80 livre: um servidor temporário só para a checagem. Ocupada pelo nginx (reexecução): ele já serve o arquivo.
  if ! ss -Hltn 'sport = :80' | grep -q .; then
    (cd "$root" && exec python3 -m http.server 80 --bind 0.0.0.0) >> "$LOG" 2>&1 &
    HTTP_PID=$!
  fi
}

# Porta alta (faixa das apps) aberta só durante a verificação, para o core conferir o firewall: aceita e fecha.
PROBE_PORT=65535
PROBE_PID=

start_probe_listener () {
  ss -Hltn "sport = :$PROBE_PORT" | grep -q . && return 0
  python3 -c 'import socket,sys
s=socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1); s.bind(("0.0.0.0", int(sys.argv[1]))); s.listen(8)
while True:
    c,_=s.accept(); c.close()' "$PROBE_PORT" >> "$LOG" 2>&1 &
  PROBE_PID=$!
}

stop_check_server () {
  [ -n "$HTTP_PID" ] && kill "$HTTP_PID" 2> /dev/null
  [ -n "$PROBE_PID" ] && kill "$PROBE_PID" 2> /dev/null
  HTTP_PID=
  PROBE_PID=
  rm -f /var/www/html/.well-known/embrapa-io/check
}

preflight () { # grava as evidências em $1; devolve 1 se algum item obrigatório falhar
  local ev=$1 failed=0

  add () { echo "$1|$2|$3" >> "$ev"; [ "$1" = 1 ] && ok "$2: $3" || { bad "$2: $3"; failed=1; }; }
  warn () { echo "1|$1|$2" >> "$ev"; say "  ⚠️  $1: $2"; }

  : > "$ev"

  . /etc/os-release
  if os_ok; then add 1 "Sistema" "$PRETTY_NAME"; else add 0 "Sistema" "$PRETTY_NAME (é preciso o Ubuntu Server 26.04 LTS ou o Debian 13)"; fi

  local arch; arch=$(uname -m)
  if [ "$arch" = x86_64 ]; then add 1 "Arquitetura" "amd64"; else add 0 "Arquitetura" "$arch (é preciso amd64)"; fi

  local cpu ram; cpu=$(nproc); ram=$(awk '/MemTotal/ {printf "%d", $2/1024/1024 + 0.5}' /proc/meminfo)
  if [ "$cpu" -ge "$MIN_CPU" ]; then add 1 "Processador" "$cpu vCPU"; else add 0 "Processador" "$cpu vCPU (mínimo $MIN_CPU)"; fi
  if [ "$ram" -ge "$MIN_RAM_GB" ]; then add 1 "Memória" "${ram} GB"; else add 0 "Memória" "${ram} GB (mínimo 16 GB)"; fi

  # Disco de dados: de preferência um disco próprio montado em /var/io (boa prática, não exigência). Sem ele, /var/io
  # fica no disco do sistema, que precisa ter o mínimo livre; o item passa com aviso. No laboratório, aceita qualquer.
  local src size free
  if src=$(findmnt -n -o SOURCE --target "$DATA" 2> /dev/null) && [ "$(findmnt -n -o TARGET --target "$DATA")" = "$DATA" ]; then
    size=$(df -BG --output=size "$DATA" | tail -1 | tr -dc 0-9)
    if [ "$size" -ge "$MIN_DATA_GB" ]; then add 1 "Disco de dados" "$DATA em $src, ${size} GB"; else add 0 "Disco de dados" "$DATA com ${size} GB (mínimo 200 GB)"; fi
  else
    free=$(df -BG --output=avail "$(dirname "$DATA")" | tail -1 | tr -dc 0-9)
    if [ "$free" -ge "$MIN_DATA_GB" ] || [ "$IO_TEST" = 1 ]; then
      warn "Disco de dados" "$DATA no disco do sistema, ${free} GB livres (recomendado: disco próprio montado em $DATA)"
    else
      add 0 "Disco de dados" "$DATA no disco do sistema com ${free} GB livres (mínimo 200 GB; ou monte um disco próprio em $DATA)"
    fi
  fi

  # Docker: snap é recusado; pelo apt é aproveitado.
  if docker_snap; then
    add 0 "Docker" "instalado pelo snap: remova (snap remove --purge docker) e rode de novo; o cluster usa o repositório oficial"
  elif docker_apt; then
    add 1 "Docker" "já instalado pelo repositório oficial ($(dpkg-query -W -f '${Version}' docker-ce)); será ajustado"
  elif command -v docker > /dev/null; then
    add 0 "Docker" "instalado fora do repositório oficial ($(command -v docker)): remova e rode de novo"
  else
    add 1 "Docker" "não instalado; será instalado do repositório oficial"
  fi

  # Portas 80 e 443: livres, ou com o nginx desta instalação (reexecução).
  local port who pid
  for port in 80 443; do
    who=$(ss -Hltnp "sport = :$port" 2> /dev/null | grep -o 'users:(("[^"]*"' | head -1 | cut -d'"' -f2)
    pid=$(ss -Hltnp "sport = :$port" 2> /dev/null | grep -o 'pid=[0-9]*' | head -1 | cut -d= -f2)
    if [ -z "$who" ]; then add 1 "Porta $port" "livre"
    elif [ -n "$HTTP_PID" ] && [ "$pid" = "$HTTP_PID" ]; then add 1 "Porta $port" "livre (servidor temporário da checagem do core)"
    elif [ "$who" = nginx ]; then add 1 "Porta $port" "em uso pelo nginx desta instalação"
    else add 0 "Porta $port" "em uso por $who: o painel e o certificado precisam dela"; fi
  done

  # Sub-redes dos estágios: nenhuma rota nem rede Docker na mesma faixa /16.
  local stage net p clash
  for stage in $STAGES; do
    net=$(echo "$SUBNETS" | json_get "$stage")
    [ -z "$net" ] && continue
    p=$(prefix16 "$net")
    clash=$(ip -4 route | awk '{print $1}' | grep "^$p\." | head -1)
    if [ -z "$clash" ] && command -v docker > /dev/null; then
      clash=$(docker network ls -q | xargs -r docker network inspect --format '{{range .IPAM.Config}}{{.Subnet}} {{end}}' 2> /dev/null | tr ' ' '\n' | grep "^$p\." | head -1)
    fi
    if [ -z "$clash" ]; then add 1 "Sub-rede $stage" "$net/16 livre"; else add 0 "Sub-rede $stage" "$net/16 conflita com $clash"; fi
  done

  # Relógio sincronizado (certificados e tokens dependem dele).
  if [ "$(timedatectl show -p NTPSynchronized --value 2> /dev/null)" = yes ]; then add 1 "Relógio" "sincronizado"
  else add 0 "Relógio" "não sincronizado: libere o NTP da Unidade (systemd-timesyncd)"; fi

  # Saída para a internet.
  local item name url code
  for item in "${OUTBOUND[@]}"; do
    name=${item%%|*}; url=${item#*|}
    code=$(curl -s -o /dev/null --max-time 10 -w '%{http_code}' "$url" 2>> "$LOG")
    if [ "$code" != 000 ]; then add 1 "Saída: $name" "$url (HTTP $code)"; else add 0 "Saída: $name" "$url sem resposta: libere a saída no firewall"; fi
  done

  return $failed
}

# --------------------------------------------------------------------------------------------------------------------
# Etapas da instalação. Cada uma roda num subshell com set -e e a saída no log; precisa ser idempotente.
# --------------------------------------------------------------------------------------------------------------------

apt_q () { DEBIAN_FRONTEND=noninteractive apt-get -y -q -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold "$@"; }

apply_sysctl () {
  cat > /etc/sysctl.d/99-embrapa-io.conf << EOF
# Embrapa I/O (cluster.sh). A reserva de portas é obrigatória: a faixa das builds coincide com as portas efêmeras.
fs.file-max=2000000
kernel.pid_max=128000
kernel.threads-max=128000
vm.max_map_count=524288
net.ipv4.ip_local_reserved_ports=$PORT_RANGE
EOF
  sysctl --system > /dev/null
}

apply_sudo () {
  # Ubuntu 26.04: o sudo-rs (padrão) recusa curingas nos argumentos e ignora a regra de chown/chmod do usuário io; volta
  # para o sudo clássico. O Debian 13 já usa o clássico (e a instalação mínima pode nem trazer o sudo).
  command -v sudo > /dev/null || apt_q install sudo
  if [ -e /usr/bin/sudo.ws ]; then update-alternatives --set sudo /usr/bin/sudo.ws; fi
  sudo_classic
}

apply_sudoers () {
  local f=/etc/sudoers.d/io tmp
  tmp=$(mktemp)
  echo "io ALL=(ALL) NOPASSWD: /bin/chown * $DATA/*, /bin/chmod * $DATA/*, /usr/bin/chown * $DATA/*, /usr/bin/chmod * $DATA/*" > "$tmp"
  visudo -cf "$tmp" > /dev/null
  install -m 440 "$tmp" "$f"
  rm -f "$tmp"
}

apply_data_dir () {
  mkdir -p "$DATA"
  chown io:io "$DATA"
  chmod 700 "$DATA"
}

apply_cron () {
  cat > /etc/cron.d/embrapa-io-cleanup << 'EOF'
# Embrapa I/O (cluster.sh): cache de build e imagens sem uso há mais de 24 h.
30 4 * * * root docker builder prune -af --filter until=24h > /dev/null 2>&1; docker image prune -af --filter until=24h > /dev/null 2>&1
EOF
  cat > /etc/logrotate.d/embrapa-io << 'EOF'
/var/log/embrapa.io*.log /var/log/embrapa-*.log {
  weekly
  rotate 8
  compress
  missingok
  notifempty
}
EOF
  # Só atualizações de segurança, sem reinício automático; o Docker fica para o NTI, numa janela (reinicia as builds).
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
  apt_q install ca-certificates curl gnupg python3 cron logrotate unattended-upgrades nginx certbot

  hostnamectl set-hostname "$HOST"
  if grep -q '^127\.0\.1\.1' /etc/hosts; then
    sed -i "s/^127\.0\.1\.1.*/127.0.1.1 $HOST ${HOST%%.*}/" /etc/hosts
  else
    echo "127.0.1.1 $HOST ${HOST%%.*}" >> /etc/hosts
  fi

  apply_sysctl
  apply_sudo

  # O nginx desta instalação: por enquanto só HTTP (desafio do certificado e checagem do core).
  rm -f /etc/nginx/sites-enabled/default
  write_nginx_http
  systemctl enable --now nginx
  nginx -t && systemctl reload nginx
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

step_user () {
  id io > /dev/null 2>&1 || adduser --disabled-password --gecos "Embrapa I/O" io
  usermod -aG docker io
  apply_data_dir
  apply_sudoers

  install -d -m 700 -o io -g io /home/io/.ssh
  echo "from=\"$CORE_IP\" $SSH_KEY" > /home/io/.ssh/authorized_keys
  chown io:io /home/io/.ssh/authorized_keys
  chmod 600 /home/io/.ssh/authorized_keys
}

step_loki () {
  docker plugin inspect loki > /dev/null 2>&1 || docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions

  local f=/etc/docker/daemon.json tmp
  tmp=$(mktemp)
  LOKI_URL="$LOKI_URL" LOKI_USER="$LOKI_USER" LOKI_PASS="$LOKI_PASS" python3 - "$f" > "$tmp" << 'PY'
import json, os, sys, urllib.parse
path = sys.argv[1]
try:
    cfg = json.load(open(path))
except Exception:
    cfg = {}
u = urllib.parse.urlsplit(os.environ["LOKI_URL"])
auth = urllib.parse.quote(os.environ["LOKI_USER"], safe="") + ":" + urllib.parse.quote(os.environ["LOKI_PASS"], safe="")
cfg.update({
    "debug": False,
    "live-restore": True,
    "log-driver": "loki",
    "log-opts": {
        "loki-url": f"{u.scheme}://{auth}@{u.netloc}{u.path}",
        "loki-external-labels": "container_name={{.Name}},job=docker",
        "loki-batch-size": "1048576", "loki-batch-wait": "1s", "loki-retries": "5",
        "loki-min-backoff": "500ms", "loki-max-backoff": "5s", "loki-timeout": "10s",
        "mode": "non-blocking", "max-buffer-size": "4m",
        "keep-file": "false", "max-size": "10m", "max-file": "3",
    },
})
print(json.dumps(cfg, indent=2))
PY
  dockerd --validate --config-file "$tmp"

  if ! cmp -s "$tmp" "$f"; then
    install -m 600 "$tmp" "$f"
    systemctl restart docker
  fi
  rm -f "$tmp"

  docker info --format '{{.LoggingDriver}}' | grep -qx loki
}

step_alloy () {
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

step_dockerhub () {
  if dockerhub_logged; then echo "Docker Hub: io já tem credencial"; return 0; fi

  local user=${DOCKERHUB_USER:-} token=${DOCKERHUB_TOKEN:-}

  if [ -z "$user" ] || [ -z "$token" ]; then
    if [ "$IO_TEST" = 1 ]; then echo "Docker Hub: pulado no laboratório"; return 0; fi
    [ -r /dev/tty ] || { echo "Sem terminal para pedir o token do Docker Hub (use DOCKERHUB_USER e DOCKERHUB_TOKEN)"; return 1; }
    # Os pedidos vão direto ao terminal: a saída da subetapa (inclusive o stderr do read -p) vai para o log.
    say ""
    say "  Login no Docker Hub (conta do NTI)"
    say "  Crie um token de acesso (read-only) em «Personal Access Tokens» em https://app.docker.com (o token fica só nesta VM)"
    printf '    Usuário: ' > /dev/tty
    read -r user < /dev/tty
    printf '    Token: ' > /dev/tty
    read -r -s token < /dev/tty
    printf '\n' > /dev/tty
    say ""
  fi

  printf '%s' "$token" | sudo -u io -H docker login -u "$user" --password-stdin
  dockerhub_logged
}

step_certificate () {
  local live=/etc/letsencrypt/live/$HOST

  if [ "$IO_TEST" = 1 ]; then
    # Laboratório: sem DNS público, um autoassinado no mesmo lugar (o painel e o nginx não percebem a diferença).
    if [ ! -s "$live/fullchain.pem" ]; then
      mkdir -p "$live"
      openssl req -x509 -newkey rsa:2048 -nodes -days 30 -subj "/CN=$HOST" -addext "subjectAltName=DNS:$HOST" \
        -keyout "$live/privkey.pem" -out "$live/fullchain.pem"
    fi
    return 0
  fi

  certbot certonly --webroot -w /var/www/html -d "$HOST" --non-interactive --agree-tos --keep-until-expiring \
    --register-unsafely-without-email --deploy-hook "systemctl reload nginx"
  test -s "$live/fullchain.pem"
}

step_terminal () {
  if [ "$IO_TEST" = 1 ]; then echo "Web Terminal: pulado no laboratório (precisa do cluster no catálogo)"; return 0; fi

  curl -fsSL https://embrapa.io/terminal.sh -o /root/terminal.sh
  # Grava o CRON diário. O contêiner só sobe quando o cluster estiver no catálogo (depois da aprovação): até lá, o
  # terminal.sh não acha o host e não faz nada, sem que isso seja falha da instalação.
  sh /root/terminal.sh install || echo "Web Terminal: ativo após a aprovação no catálogo"
  test -f /etc/cron.d/embrapa-terminal
}

step_panel () {
  case "$PANEL" in
    none) rm -f /etc/nginx/sites-enabled/embrapa-io-panel; write_nginx_http; nginx -t && systemctl reload nginx; return 0 ;;
    arcane) install_arcane ;;
    *) echo "Painel desconhecido: $PANEL"; return 1 ;;
  esac

  write_nginx_https
  nginx -t
  systemctl reload nginx
}

step_cron () {
  apply_cron
  systemctl enable --now cron unattended-upgrades
}

step_cleanup () {
  rm -rf /var/www/html/.well-known/embrapa-io
  return 0
}

# --------------------------------------------------------------------------------------------------------------------
# Arquivos gerados
# --------------------------------------------------------------------------------------------------------------------

write_nginx_http () {
  cat > /etc/nginx/sites-available/embrapa-io << EOF
# Embrapa I/O (cluster.sh): desafio do Let's Encrypt e checagem do core; o resto vai para o HTTPS.
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name $HOST;

  location /.well-known/ { root /var/www/html; }

  location / { return 301 https://\$host\$request_uri; }
}
EOF
  ln -sf /etc/nginx/sites-available/embrapa-io /etc/nginx/sites-enabled/embrapa-io
}

write_nginx_https () {
  local live=/etc/letsencrypt/live/$HOST
  cat > /etc/nginx/sites-available/embrapa-io-panel << EOF
# Embrapa I/O (cluster.sh): painel local ($PANEL) em https://$HOST.
map \$http_upgrade \$connection_upgrade { default upgrade; '' close; }

server {
  listen 443 ssl default_server;
  listen [::]:443 ssl default_server;
  http2 on;
  server_name $HOST;

  ssl_certificate $live/fullchain.pem;
  ssl_certificate_key $live/privkey.pem;
  ssl_protocols TLSv1.2 TLSv1.3;

  client_max_body_size 512m;

  location / {
    proxy_pass http://127.0.0.1:$PANEL_PORT;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
    proxy_read_timeout 3600s;
  }
}
EOF
  ln -sf /etc/nginx/sites-available/embrapa-io-panel /etc/nginx/sites-enabled/embrapa-io-panel
}

write_alloy_config () {
  cat << EOF
// Grafana Alloy — cluster do Embrapa I/O ($HOST), gerado pelo cluster.sh. Não edite: rode o setup de novo.

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
      username = "$PROMETHEUS_USER"
      password = "$PROMETHEUS_PASS"
    }
  }
}
EOF
}

# --------------------------------------------------------------------------------------------------------------------
# Painéis
# --------------------------------------------------------------------------------------------------------------------

PANEL_DIR=/opt/embrapa-io/panel
PANEL_PORT=3552
PANEL_FILE=/root/embrapa-io-panel.txt

# A etapa roda num subshell: a senha nova vai para o arquivo (só root) antes de valer, e o resumo final a mostra.
save_panel_password () { # usuário senha
  ( umask 077; printf 'Painel %s em https://%s\nUsuário: %s\nSenha: %s\n' "$PANEL" "$HOST" "$1" "$2" > "$PANEL_FILE" )
  touch "$STATE/panel-password-new"
}

# 32 caracteres com maiúscula, minúscula, número e símbolo (a política do Arcane exige os quatro).
panel_secret () { python3 -c 'import secrets as s, string as t
a=t.ascii_letters+t.digits+"-_.@#%+"
while True:
    p="".join(s.choice(a) for _ in range(32))
    if any(c.islower() for c in p) and any(c.isupper() for c in p) and any(c.isdigit() for c in p) and any(c in "-_.@#%+" for c in p): print(p); break'; }

install_arcane () {
  PANEL_PORT=3552
  mkdir -p "$PANEL_DIR"

  [ -s "$PANEL_DIR/.env" ] || printf 'ENCRYPTION_KEY=%s\n' "$(openssl rand -hex 32)" > "$PANEL_DIR/.env"
  chmod 600 "$PANEL_DIR/.env"

  cat > "$PANEL_DIR/compose.yaml" << EOF
# Embrapa I/O (cluster.sh): painel local Arcane, atrás do nginx em https://$HOST.
name: embrapa-io-panel
services:
  arcane:
    image: ghcr.io/getarcaneapp/manager:latest
    container_name: arcane
    ports:
      - 127.0.0.1:$PANEL_PORT:3552
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - arcane-data:/app/data
    environment:
      - APP_URL=https://$HOST
      - ENCRYPTION_KEY=\${ENCRYPTION_KEY}
    logging:
      driver: json-file
    healthcheck:
      test: ['CMD', './arcane', 'health', '--timeout', '2s']
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 15s
    restart: unless-stopped
volumes:
  arcane-data:
EOF
  docker compose --project-directory "$PANEL_DIR" up -d --wait
  apply_panel_cron

  # Senha inicial: a padrão (arcane / arcane-admin) é trocada aqui, antes de o painel ficar na internet.
  [ -s "$STATE/panel-initialized" ] && return 0
  arcane_set_password
}

# Atualização noturna do painel (04:47, depois do Web Terminal às 04:17): baixa a imagem e só recria o contêiner se
# ela mudou. Se a nova não ficar saudável em 2 min, volta para a anterior. O painel fica na internet e controla o
# Docker do host: não pode ficar meses sem as correções de segurança.
apply_panel_cron () {
  [ -f "$PANEL_DIR/compose.yaml" ] || return 0

  cat > "$PANEL_DIR/update.sh" << 'EOF'
#!/bin/bash
# Embrapa I/O (cluster.sh): atualização do painel local. Roda pelo /etc/cron.d/embrapa-io-panel; pode ser chamado à mão.
set -uo pipefail
DIR=/opt/embrapa-io/panel
LOG=/var/log/embrapa-io-panel.log
exec 9> /run/embrapa-io-panel.lock
flock -n 9 || exit 0
exec >> "$LOG" 2>&1
say () { echo "$(date -Is) $*"; }
dc () { docker compose --project-directory "$DIR" "$@"; }

image=$(dc config --images | head -1)
old=$(docker image inspect -f '{{.Id}}' "$image" 2> /dev/null || true)

dc pull -q || { say "ERROR > Impossible to pull $image: keeping the current version."; exit 1; }
new=$(docker image inspect -f '{{.Id}}' "$image")

if [ "$new" = "$old" ]; then say "INFO > $image is up to date."; exit 0; fi

say "INFO > New image for $image (${old:7:12} -> ${new:7:12}): recreating."
if dc up -d --wait --wait-timeout 120; then say "INFO > Panel updated and healthy."; exit 0; fi

say "ERROR > New image is not healthy: rolling back to ${old:7:12}."
[ -n "$old" ] && docker tag "$old" "$image" && dc up -d --force-recreate --wait --wait-timeout 120 \
  && { say "INFO > Rollback done."; exit 1; }
say "ERROR > Rollback failed: check 'docker compose --project-directory $DIR ps'."
exit 1
EOF
  chmod 700 "$PANEL_DIR/update.sh"

  cat > /etc/cron.d/embrapa-io-panel << EOF
# Embrapa I/O (cluster.sh): atualização noturna do painel local (log em /var/log/embrapa-io-panel.log).
47 4 * * * root $PANEL_DIR/update.sh
EOF
  chmod 644 /etc/cron.d/embrapa-io-panel
}

# O painel é público: a senha padrão (arcane / arcane-admin) é trocada aqui, antes de o nginx publicá-lo, por uma de 32
# caracteres, e o usuário passa a ser quem está configurando (login pelo e-mail; o Arcane não aceita @ no nome de
# usuário, que fica com a parte antes do @).
arcane_set_password () {
  local base=http://127.0.0.1:$PANEL_PORT/api cookies password id
  cookies=$(mktemp)
  password=$(panel_secret)
  save_panel_password "${ADMIN_EMAIL:-arcane}" "$password"

  curl -fsS -c "$cookies" -H 'Content-Type: application/json' -d '{"username":"arcane","password":"arcane-admin"}' "$base/auth/login" > /dev/null \
    || { rm -f "$cookies" "$PANEL_FILE" "$STATE/panel-password-new"; return 1; }

  ARCANE_NEW="$password" python3 -c 'import json,os; print(json.dumps({"currentPassword":"arcane-admin","newPassword":os.environ["ARCANE_NEW"]}))' \
    | curl -fsS -b "$cookies" -H 'Content-Type: application/json' --data-binary @- "$base/auth/password" > /dev/null \
    || { rm -f "$cookies" "$PANEL_FILE" "$STATE/panel-password-new"; return 1; }

  if [ -n "$ADMIN_EMAIL" ]; then
    id=$(curl -fsS -b "$cookies" "$base/auth/me" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("data", d)["id"])')
    ADMIN_EMAIL="$ADMIN_EMAIL" ADMIN_NAME="$ADMIN_NAME" python3 -c 'import json,os; e=os.environ["ADMIN_EMAIL"]; print(json.dumps({"username":e.split("@")[0],"email":e,"displayName":os.environ["ADMIN_NAME"] or e.split("@")[0]}))' \
      | curl -fsS -b "$cookies" -X PUT -H 'Content-Type: application/json' --data-binary @- "$base/users/$id" > /dev/null \
      || { echo "Arcane: não foi possível trocar o usuário; o login continua 'arcane'"; save_panel_password arcane "$password"; }
  fi

  rm -f "$cookies"
  date -Is > "$STATE/panel-initialized"
}

# --------------------------------------------------------------------------------------------------------------------
# Conferência (status) e reparo
# --------------------------------------------------------------------------------------------------------------------

dockerhub_logged () {
  local f=/home/io/.docker/config.json
  [ -s "$f" ] && python3 -c 'import json,sys; a=json.load(open(sys.argv[1])); sys.exit(0 if ("https://index.docker.io/v1/" in a.get("auths",{}) or a.get("credsStore")) else 1)' "$f"
}

STATUS_FAIL=0

check () { # check rótulo comando…
  local label=$1; shift
  if ( "$@" ) >> "$LOG" 2>&1; then ok "$label"; else bad "$label"; STATUS_FAIL=1; fi
}

cmd_status () {
  need_root
  local host; host=$(hostname)

  say "Embrapa I/O — conferência do cluster $host (cluster.sh $VERSION)"
  say ""
  check "Hostname com domínio ($host)" bash -c "[[ '$host' == *.* ]]"
  check "Ubuntu 26.04 ou Debian 13, amd64" os_amd64
  check "Reserva de portas $PORT_RANGE" bash -c "sysctl -n net.ipv4.ip_local_reserved_ports | grep -q '$PORT_RANGE'"
  check "Sudo clássico (não o sudo-rs)" sudo_classic
  check "Docker do repositório oficial (sem snap)" bash -c "dpkg -s docker-ce > /dev/null && ! snap list docker > /dev/null 2>&1"
  check "Docker Compose" docker compose version
  check "Usuário io no grupo docker" bash -c "id -nG io | tr ' ' '\n' | grep -qx docker"
  check "$DATA do io, modo 700" bash -c "[ \"\$(stat -c '%U %a' $DATA)\" = 'io 700' ]"
  check "Sudoers do io válido" visudo -cf /etc/sudoers.d/io
  check "sudo chown do io em $DATA" bash -c "mkdir -p $DATA/.cluster-check && chown root:root $DATA/.cluster-check && sudo -u io sudo -n /bin/chown io:io $DATA/.cluster-check && rmdir $DATA/.cluster-check"
  check "Chave da plataforma restrita ao core" bash -c "grep -q '^from=\"' /home/io/.ssh/authorized_keys && grep -q ' embrapa.io\$' /home/io/.ssh/authorized_keys"
  check "Driver de log loki" bash -c "docker info --format '{{.LoggingDriver}}' | grep -qx loki"
  check "Alloy ativo" systemctl is-active --quiet alloy
  check "Alloy mandando ao Embrapa I/O" grep -q 'embrapa.io' /etc/alloy/config.alloy
  check "Docker Hub: credencial do io" dockerhub_logged
  check "Certificado do host" bash -c "openssl x509 -checkend 604800 -noout -in /etc/letsencrypt/live/$host/fullchain.pem"
  check "nginx ativo" systemctl is-active --quiet nginx
  check "Painel respondendo" bash -c "curl -fsk --resolve $host:443:127.0.0.1 -o /dev/null https://$host/"
  check "Web Terminal (CRON)" test -f /etc/cron.d/embrapa-terminal
  check "CRON de limpeza" test -f /etc/cron.d/embrapa-io-cleanup
  [ -f "$PANEL_DIR/compose.yaml" ] && check "Painel: atualização noturna (CRON)" test -x "$PANEL_DIR/update.sh" -a -f /etc/cron.d/embrapa-io-panel
  check "unattended-upgrades (só segurança, Docker retido)" grep -q docker-ce /etc/apt/apt.conf.d/52embrapa-io-unattended
  say ""
  if [ "$STATUS_FAIL" = 0 ]; then say "Tudo certo."; else say "Há itens com problema (detalhes em $LOG). O 'repair' corrige os ajustes de sistema."; fi
  return $STATUS_FAIL
}

cmd_repair () {
  need_root
  say "Embrapa I/O — reaplicando os ajustes idempotentes"
  {
    apply_sysctl
    apply_sudo
    id io > /dev/null 2>&1 && { usermod -aG docker io; apply_data_dir; apply_sudoers; }
    id alloy > /dev/null 2>&1 && usermod -aG systemd-journal alloy
    apply_cron
    apply_panel_cron
  } >> "$LOG" 2>&1 || die "Falha ao reaplicar (detalhes em $LOG)."
  say ""
  cmd_status
}

# --------------------------------------------------------------------------------------------------------------------
# Setup
# --------------------------------------------------------------------------------------------------------------------

run_substep () {
  local key=$1 rc

  say "  … ${LABEL[$key]}"
  progress install "$key" running

  ( set -e; "step_$key" ) >> "$LOG" 2>&1
  rc=$?

  if [ $rc -ne 0 ]; then
    bad "${LABEL[$key]}"
    progress install "$key" failed "" "Falhou em: ${LABEL[$key]}"
    die "A instalação parou em «${LABEL[$key]}». Detalhes em $LOG. Corrija e rode o setup de novo (token novo na Dashboard, se expirou)."
  fi

  ok "${LABEL[$key]}"
  progress install "$key" "done"
}

load_request () {
  local info
  info=$(api GET "/cluster/setup/$TOKEN" 2>> "$LOG") || die "Token inválido ou expirado. Gere outro no assistente da Dashboard."

  HOST=$(echo "$info" | json_get host)
  STAGES=$(echo "$info" | json_get stages)
  SUBNETS=$(echo "$info" | json_get subnets)
  REQUEST_STATUS=$(echo "$info" | json_get status)
  TOKEN_EXPIRES=$(echo "$info" | json_get expires)
  CORE_IP=$(echo "$info" | json_get core_ip); CORE_IP=${CORE_IP:-$CORE_IP_DEFAULT}
  [ -z "$PANEL" ] && PANEL=$(echo "$info" | json_get panel)
  # Quem está configurando vira o administrador do painel (login pelo e-mail).
  ADMIN_EMAIL=$(echo "$info" | json_get admin.email)
  ADMIN_NAME=$(echo "$info" | json_get admin.name)
  [[ "$ADMIN_EMAIL" =~ ^[a-z0-9._-]+@([a-z0-9-]+\.)+[a-z]+$ ]] || ADMIN_EMAIL=
  PANEL=${PANEL:-arcane}

  [[ "$HOST" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$ ]] || die "Host inválido no pedido: '$HOST'."
}

wait_confirmation () {
  local deadline=$(( $(date +%s) + 1800 )) info status

  say ""
  say "⏳  Aguardando a confirmação na Dashboard (até 30 minutos)…"
  while [ "$(date +%s)" -lt "$deadline" ]; do
    info=$(api GET "/cluster/setup/$TOKEN" 2>> "$LOG") || die "Token inválido ou expirado. Gere outro no assistente da Dashboard."
    status=$(echo "$info" | json_get status)
    case "$status" in
      INSTALLING) say "  ✅  Confirmado."; return 0 ;;
      FAILED|DRAFT) die "O pedido foi cancelado ou falhou na Dashboard ($status)." ;;
    esac
    sleep 5
  done
  die "A confirmação não chegou em 30 minutos. Rode o setup de novo quando for confirmar."
}

load_secrets () {
  local s
  s=$(api GET "/cluster/setup/$TOKEN/secrets" 2>> "$LOG") || die "Não foi possível obter as credenciais da plataforma."

  LOKI_URL=$(echo "$s" | json_get loki.url)
  LOKI_USER=$(echo "$s" | json_get loki.username)
  LOKI_PASS=$(echo "$s" | json_get loki.password)
  PROMETHEUS_URL=$(echo "$s" | json_get prometheus.url)
  PROMETHEUS_USER=$(echo "$s" | json_get prometheus.username)
  PROMETHEUS_PASS=$(echo "$s" | json_get prometheus.password)
  SSH_KEY=$(echo "$s" | json_get ssh_key); SSH_KEY=${SSH_KEY:-$PLATFORM_KEY}

  [ -n "$LOKI_URL" ] && [ -n "$LOKI_USER" ] && [ -n "$LOKI_PASS" ] && [ -n "$PROMETHEUS_URL" ] || die "Credenciais incompletas na resposta da plataforma."
}

# O core confere DNS (registro do host e curinga), SSH (22), HTTP (80, pelo servidor temporário) e uma porta alta.
# É o primeiro passo: sem isso, nada do que vem depois funciona (deploy, router, certificado).
probe_from_core () {
  local out
  out=$(api POST "/cluster/setup/$TOKEN/probe" '{}' 2>> "$LOG") || { bad "Não foi possível pedir a verificação ao core ($IO_API)"; return 1; }
  echo "$out" | python3 -c 'import json,sys
d=json.load(sys.stdin)
for part in ("dns","network"):
    for e in d.get(part,{}).get("evidence",[]):
        print(("  ✅  " if e.get("ok") else "  ❌  ")+e.get("label","")+": "+e.get("detail",""))
for part in ("dns","network"):
    fix=d.get(part,{}).get("fix")
    if fix: print("     → "+fix)
sys.exit(0 if d.get("ok") else 1)' | tee -a "$LOG"
  return "${PIPESTATUS[1]}"
}

# O script usa python3 para JSON desde a verificação prévia. A instalação mínima do Ubuntu sempre o traz; a do Debian
# pode não trazer: é a única coisa instalada antes da confirmação.
need_python () {
  command -v python3 > /dev/null && return 0
  say "Instalando o python3, que o cluster.sh usa (a instalação mínima do Debian não traz)..."
  { apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3; } >> "$LOG" 2>&1 || die "Não foi possível instalar o python3 (veja $LOG)."
}

cmd_setup () {
  need_root
  need_python
  TOKEN=${1:-}
  [[ "$TOKEN" =~ ^[A-Za-z0-9_-]{16,128}$ ]] || die "Uso: sh cluster.sh setup <token> (o token vem do assistente da Dashboard)."

  mkdir -p "$STATE"; chmod 700 "$STATE"
  touch "$LOG"; chmod 600 "$LOG"

  say "Embrapa I/O — instalação de cluster (cluster.sh $VERSION)"
  load_request
  say "Cluster: $HOST · estágios: $STAGES · painel: $PANEL$( [ "$IO_TEST" = 1 ] && echo ' · LABORATÓRIO (IO_TEST=1)')"

  trap stop_check_server EXIT
  start_check_server
  start_probe_listener
  sleep 1

  say ""
  say "🌐  Pré-requisitos conferidos a partir do core (DNS, SSH, HTTP e portas altas):"
  probe_from_core || die "O core não alcança esta VM como precisa. Corrija os itens acima e rode o setup de novo (o token vale até $(date -d "$TOKEN_EXPIRES" '+%H:%M' 2> /dev/null || echo 'o horário mostrado na Dashboard'))."

  say ""
  say "🔎  Verificação prévia (nada é alterado):"
  local ev; ev=$(mktemp)
  progress preflight "" running
  if ! preflight "$ev"; then
    progress preflight "" failed "$ev" "Há itens a corrigir antes da instalação."
    die "Corrija os itens marcados com ❌ e rode o setup de novo."
  fi
  progress preflight "" "done" "$ev"
  rm -f "$ev"

  if [ "$REQUEST_STATUS" != INSTALLING ]; then wait_confirmation; fi

  # A checagem da porta 80 pelo core acabou; o nginx da instalação assume a porta.
  stop_check_server

  load_secrets

  say ""
  say "🛠  Instalação:"
  progress install "" running
  local key
  for key in "${SUBSTEPS[@]}"; do run_substep "$key"; done
  progress install "" "done"

  say ""
  say "🚀  Instalação concluída. A plataforma agora valida o cluster a partir do core; acompanhe na Dashboard."
  say "   Painel: https://$HOST"
  if [ -f "$STATE/panel-password-new" ] && [ -s "$PANEL_FILE" ]; then
    local who secret
    who=$(sed -n 2p "$PANEL_FILE"); secret=$(sed -n 3p "$PANEL_FILE")
    say "   $who · $secret"
    say "   (anote agora; uma cópia ficou em $PANEL_FILE, só para o root)"
    rm -f "$STATE/panel-password-new"
  fi
  say "   Conferência local, a qualquer momento: sh /root/cluster.sh status"
}

case "${1:-help}" in
  setup) shift; cmd_setup "$@" ;;
  status) touch "$LOG" 2> /dev/null; cmd_status ;;
  repair) touch "$LOG" 2> /dev/null; cmd_repair ;;
  version) echo "$VERSION" ;;
  *) sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
