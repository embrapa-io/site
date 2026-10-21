#!/bin/sh
#
# Web Terminal do Embrapa I/O: instala e mantém o contêiner 'terminal' neste cluster.
#
# Instalação (como root, uma vez por cluster):
#
#   curl -fsSL https://embrapa.io/terminal.sh -o /root/terminal.sh && sh /root/terminal.sh install
#
#   sh /root/terminal.sh install   grava o cron diário (/etc/cron.d/embrapa-terminal) e já aplica
#   sh /root/terminal.sh           aplica: é o que o cron roda todo dia
#   sh /root/terminal.sh status    mostra o que faria, sem mudar nada
#
# O catálogo da plataforma (core.embrapa.io/metadata/clusters.json) é a fonte da verdade:
# o cluster é o host do catálogo que tem certificado em /etc/letsencrypt/live/, e a porta
# e a ativação vêm de 'resources.terminal'. Terminal desativado no catálogo = contêiner
# removido. A imagem só é trocada quando muda; se a nova não responder no /health, volta
# a anterior.
#
# Ajustes locais opcionais em /root/terminal.env:
#
#   CLUSTER=cluster.exemplo.embrapa.br     quando o certificado tem outro nome ou há mais de um
#   IMAGE=embrapa/terminal:1.26.10-2       fixa uma versão (o padrão segue a 'latest')
#   LETSENCRYPT=/etc/letsencrypt           outro diretório do Let's Encrypt
#
# Fonte: github.com/embrapa-io/terminal (terminal.sh), publicado em embrapa.io/terminal.sh.

set -u

IMAGE=embrapa/terminal:latest
NAME=terminal
CATALOG=https://core.embrapa.io/metadata/clusters.json
LETSENCRYPT=/etc/letsencrypt
SELF=/root/terminal.sh
CRON=/etc/cron.d/embrapa-terminal
LOG=/var/log/embrapa-terminal.log

[ -f /root/terminal.env ] && . /root/terminal.env

LIVE=$LETSENCRYPT/live

say () { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }

die () { say "ERROR > $*"; exit 1; }

[ "$(id -u)" = 0 ] || die "Run as root."

command -v docker > /dev/null || die "Docker not found."

command -v curl > /dev/null || die "curl not found."

MODE=${1:-apply}

# Uma execução por vez (o cron e uma chamada manual podem coincidir).
if command -v flock > /dev/null; then
  exec 9> /var/lock/embrapa-terminal.lock

  flock -n 9 || { say "INFO > Another execution is running: nothing to do."; exit 0; }
fi

case "$MODE" in
  install|apply|status) ;;
  *) die "Unknown command '$MODE'. Use: install, status or nothing (apply)." ;;
esac

if [ "$MODE" = install ]; then
  [ "$(readlink -f "$0")" = "$SELF" ] || cp "$0" "$SELF"

  chmod 700 "$SELF"

  [ -d "$(dirname "$CRON")" ] || die "$(dirname "$CRON") not found: is cron installed?"

  # Diário, de madrugada no horário do host. 'root' é o usuário (formato do /etc/cron.d).
  {
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin'
    echo "17 4 * * * root $SELF >> $LOG 2>&1"
  } > "$CRON" || die "Impossible to write $CRON."

  chmod 644 "$CRON"

  say "INFO > Daily cron installed in $CRON (04:17, log in $LOG)."

  # Legado: a documentação antiga mandava criar um /root/terminal.sh que recriava o
  # contêiner a cada chamada, e muitos clusters o chamam pelo /etc/cron.daily/io (junto
  # com o backup) ou pelo crontab. Só a linha do terminal sai; o backup fica no /root
  # (dentro do /etc/cron.daily ele seria executado).
  stamp=$(date +%Y%m%d-%H%M%S)

  for file in /etc/cron.daily/* /etc/crontab; do
    [ -f "$file" ] && grep -q '/root/terminal\.sh' "$file" || continue

    cp "$file" "/root/$(basename "$file").bak-$stamp"

    sed -i '\#/root/terminal\.sh#d' "$file"

    say "INFO > Legacy call to /root/terminal.sh removed from $file (backup in /root/$(basename "$file").bak-$stamp)."
  done

  if crontab -l 2> /dev/null | grep -q '/root/terminal\.sh'; then
    crontab -l > "/root/crontab.bak-$stamp"

    grep -v '/root/terminal\.sh' "/root/crontab.bak-$stamp" | crontab -

    say "INFO > Legacy call to /root/terminal.sh removed from the root crontab (backup in /root/crontab.bak-$stamp)."
  fi

  MODE=apply
fi

# --- Imagem ---

if [ "$MODE" = apply ]; then
  docker pull -q "$IMAGE" > /dev/null 2>&1 || say "WARNING > Impossible to pull $IMAGE: using the local image."
fi

docker image inspect "$IMAGE" > /dev/null 2>&1 || die "Image $IMAGE not available."

# jq e curl da própria imagem: o host só precisa de Docker e curl.
jq () { docker run --rm -i --entrypoint jq "$IMAGE" "$@"; }

# --- Cluster, porta e ativação (catálogo) ---

catalog=$(curl -fsS --max-time 20 "$CATALOG") || die "Impossible to read $CATALOG."

if [ -z "${CLUSTER:-}" ]; then
  for host in $(printf '%s' "$catalog" | jq -r '[.[] | arrays | .[] | .host] | unique | .[]'); do
    [ -f "$LIVE/$host/fullchain.pem" ] && CLUSTER="${CLUSTER:+$CLUSTER }$host"
  done
fi

case "${CLUSTER:-}" in
  '') die "No cluster of the catalog has a certificate in $LIVE: set CLUSTER in /root/terminal.env." ;;
  *' '*) die "More than one cluster matches ($CLUSTER): set CLUSTER in /root/terminal.env." ;;
esac

# Ativo se estiver ativo em algum estágio: o próprio terminal recusa os demais.
info=$(printf '%s' "$catalog" | jq -r --arg h "$CLUSTER" '
  [.[] | arrays | .[] | select(.host == $h)]
  | [ (map(.resources.terminal.active == true) | any),
      (map(.resources.terminal.port // empty) | first // 65500),
      (.[0].orchestrator // "DockerCompose") ]
  | @tsv')

[ -n "$info" ] || die "Cluster $CLUSTER not found in the catalog."

active=$(printf '%s' "$info" | cut -f1)
port=$(printf '%s' "$info" | cut -f2)
orchestrator=$(printf '%s' "$info" | cut -f3)

exists=$(docker inspect -f '{{.Id}}' "$NAME" 2> /dev/null || true)

if [ "$active" != true ]; then
  if [ -z "$exists" ]; then
    say "INFO > Web Terminal disabled in the catalog for $CLUSTER: nothing to do."
  elif [ "$MODE" = status ]; then
    say "INFO > Web Terminal disabled in the catalog for $CLUSTER: the container would be removed."
  else
    docker rm -f "$NAME" > /dev/null
    say "INFO > Web Terminal disabled in the catalog for $CLUSTER: container removed."
  fi

  exit 0
fi

[ "$orchestrator" = DockerCompose ] || die "Orchestrator $orchestrator is not supported by this script yet."

cert=$LIVE/$CLUSTER/fullchain.pem
key=$LIVE/$CLUSTER/privkey.pem

{ [ -f "$cert" ] && [ -f "$key" ]; } || die "Certificate not found in $LIVE/$CLUSTER."

# --- Estado atual ---

healthy () {
  docker run --rm --network host --entrypoint curl "$IMAGE" -fsk --max-time 5 "https://127.0.0.1:$port/health" > /dev/null 2>&1
}

want=$(docker image inspect -f '{{.Id}}' "$IMAGE")
have=$(docker inspect -f '{{.Image}}' "$NAME" 2> /dev/null || true)
running=$(docker inspect -f '{{.State.Running}}' "$NAME" 2> /dev/null || true)
config=$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}{{range $p, $b := .HostConfig.PortBindings}}{{$p}}={{(index $b 0).HostPort}}{{println}}{{end}}' "$NAME" 2> /dev/null || true)

reason=''

if [ -z "$exists" ]; then
  reason='not installed'
elif [ "$have" != "$want" ]; then
  reason='new image'
elif ! printf '%s' "$config" | grep -qx "SSL_CERT=$cert" || ! printf '%s' "$config" | grep -qx "5000/tcp=$port"; then
  reason='configuration changed (certificate or port)'
elif [ "$running" != true ]; then
  reason='not running'
elif ! healthy; then
  reason='not healthy'
fi

if [ -z "$reason" ]; then
  say "SUCCESS > Web Terminal up to date and healthy on https://$CLUSTER:$port."

  exit 0
fi

if [ "$MODE" = status ]; then
  say "INFO > Web Terminal for $CLUSTER on port $port would be (re)created: $reason."

  exit 0
fi

# --- (Re)criação, com volta à imagem anterior ---

start () {
  docker run -d --name "$NAME" --restart unless-stopped \
    -v "$LETSENCRYPT:$LETSENCRYPT:ro" \
    -e SSL_CERT="$cert" \
    -e SSL_KEY="$key" \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -p "$port:5000" \
    "$1" > /dev/null
}

wait_healthy () {
  i=0

  while [ $i -lt 12 ]; do
    sleep 5

    healthy && return 0

    i=$((i + 1))
  done

  return 1
}

say "INFO > (Re)creating the Web Terminal for $CLUSTER on port $port: $reason."

docker rm -f "$NAME" > /dev/null 2>&1

if start "$IMAGE" && wait_healthy; then
  say "SUCCESS > Web Terminal healthy on https://$CLUSTER:$port."

  exit 0
fi

say "ERROR > The new Web Terminal did not answer on /health in 60 s."

if [ -n "$have" ] && [ "$have" != "$want" ]; then
  docker rm -f "$NAME" > /dev/null 2>&1

  if start "$have" && wait_healthy; then
    say "WARNING > Rolled back to the previous image ($have)."
  else
    say "ERROR > The previous image did not answer either: check 'docker logs $NAME'."
  fi
fi

exit 1
