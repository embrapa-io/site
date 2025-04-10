---
layout: page
title: Cluster
subtitle: Configurando e disponibilizando um cluster
---

Conforme explicado no [capítulo de arquitetura]({{ site.baseurl }}/docs/architecture), o **Embrapa I/O** é uma plataforma do tipo _Cloud Agnostic Architecture_. Ou seja, se propõe a atuar com <u>diferentes tecnologias de conteinerização e clusterização em nuvem</u>, às quais são aqui chamadas de "**orquestradores**".

Assim, é possível que uma aplicação, devidamente conteinerizada, seja instanciada em estágio _alpha_ (para testes internos) em um orquestrador [Docker Swarm](https://docs.docker.com/engine/swarm/) rodando em um cluster de servidores localizado fisicamente na [Embrapa Gado de Corte](https://www.embrapa.br/gado-de-corte). A mesma aplicação poderia ser instanciada em estágio _beta_ (para testes externos) em um orquestrador [Kubernetes](https://kubernetes.io/pt-br/) rodando em um cluster de servidores localizado fisicamente na [Embrapa Agricultura Digital](https://www.embrapa.br/agricultura-digital). Por fim, esta mesma aplicação poderia estar instanciada em estágio _release_ (produção) em um orquestrador [Cloud Foundry](https://www.cloudfoundry.org) rodando na [IBM Cloud](https://www.ibm.com/cloud).

Para possibilitar a "orquestração" dos ativos digitais nesta rede descentralizada de _clusters_, a plataforma implementa **_drivers_** de serviços. Estes _drivers_ podem ser de dois tipos:

- **orquestrador**: que efetua tarefas de validação dos _stacks_ de _containers_, _deploy_/_undeploy_, _health check_, _backup_, sanitização, etc; e

- **storer**: que instancia _volumes_ no próprio _cluster_ ou em servidores externos do tipo _storage_.

O provisionamento de novos _clusters_, _storages_ e o desenvolvimento de _drivers_, estão alinhados com a estratégia de desenvolvimento colaborativo e manutenção compartilhada da plataforma. Assim, [da mesma forma que ocorre com os _boilerplates_]({{ site.baseurl }}/docs/boilerplate), _clusters_ são mantidos por equipes descentralizadas, que podem ser internas ou externas à Embrapa.

![Detalhes do cluster escolhido para deploy da aplicação]({{ site.baseurl }}/assets/img/cluster/20250311144415.png)

Desta forma, unidades descentralizadas, instituições e empresas parceiras da Embrapa podem compor a rede de _clusters_ do **Embrapa I/O**, integrando servidores reais ou VMs de seus próprios CPDs. Com isso, a gestão das aplicações nestes servidores físicos ou máquinas virtuais passa a ser realizada pelos processos de DevOps da plataforma.

> **Atenção!** Os processos automatizados de _backup_ nos _clusters_ são de atribuição da equipe de mantenedores, sendo que o **Embrapa I/O** aborda apenas o _backup_ sob demanda, [já detalhado anteriormente]({{ site.baseurl }}/docs/backup). Da mesma forma, recursos essenciais adicionais, tal como envio de e-mail (SMTP) devem ser disponibilizados na rede interna em que o servidor está instalado e devidamente informado na documentação do _cluster_.

# Passo-a-Passo de Configuração

A seguir são listados os passos básicos para disponibilização do _cluster_.

1. [Instalação do orquestrador](#install) (com [Docker Compose](#docker) ou [Docker Swarm](#swarm));
2. [Integração (via SSH) do _cluster_ ao Embrapa I/O](#ssh);
3. [Liberação das demais portas no _firewall_](#ports);
4. [Configuração do _plugin_ para _logging_](#loki);
5. [Ativação do _Web Terminal_ (opcional)](#terminal);
6. [Instalação de um _Distribution Registry_ (opcional)](#registry); e
7. [Configuração do Portainer (opcional)](#portainer).

## 1. Instalação do orquestrador {#install}

Neste primeiro passo será abordado o provisionamento básico do(s) servidor(es) - físico(s) ou virtual(is) - do _cluster_, tal como a instalação do sistema operacional sugerido, o orquestrador e _storer_ associado.

### Docker Compose {#docker}

Para instalação do orquestrador em [Docker Compose](https://docs.docker.com/compose/) é necessário disponibilizar um único servidor dedicado (_bare metal_) ou máquina virtual. É recomendado o uso da distribuição [Linux Ubuntu Server 24.04 LTS](https://ubuntu.com/download/server). <u>É necessário que seja utilizada a arquitetura <b>amd64</b></u>. No momento da instalação do SO, haverá a possibilidade de instalar pacotes adicionais. Neste momento, selecione o **SSH Server**.

Uma vez que o _shell_ esteja disponível, atualize completamente a distribuição (`apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt autoclean`) e proceda com o [passo-a-passo oficial para instalação do Docker](https://docs.docker.com/engine/install/ubuntu/).

> **Atenção!** Após concluir da instalação, é fortemente recomendado efetuar o [login no Docker](https://docs.docker.com/engine/reference/commandline/login/) utilizando uma conta institucional. O uso do Docker não-autenticado pode resultar em erros durante o processo de _deploy_ (p.e., `Temporary failure in name resolution`).

Agora será necessário configurar um _storer_ associado ao _cluster_, que é o servidor físico onde serão armazenados os _volumes_ utilizados pelos containers para persistir dados:

- `DockerLocal`: Caso não haja uma outra VM ou um outro servidor do tipo _storage_ disponível, que seria o equipamento mais apropriado, é possível configurar um _storer_ local. Na prática será um diretório no próprio _cluster_ onde todos os _volumes_ serão criados fisicamente. Para isto, basta criar um diretório em qualquer local no servidor e atribuir permissões de escrita.

- `DockerNFSv4`: Havendo uma outra VM ou outro servidor físico de _storage_ disponível, os mantenedores poderão [instalar e/ou habilitar o NFS (versão 4)](https://phoenixnap.com/kb/ubuntu-nfs-server) nele. É importante que no arquivo `/etc/exports` sejam parametrizados, pelo menos, as seguintes opções no diretório a ser montado: `rw`, `no_root_squash`, `sync`, `no_subtree_check` e `insecure`.

É fortemente recomendado ajustar alguns parâmetros do Linux (`sysctl`). Normalmente estes parâmetros são ajustados editando o arquivo `/etc/sysctl.d/99-sysctl.conf` (ou diretamente o `/etc/sysctl.conf` em distribuições mais antigas). Considere os seguintes parâmetros e correspondentes valores mínimos:

```bash
fs.file-max=98000
kernel.pid_max=64000
kernel.threads-max=64000
vm.max_map_count=262144
```

### Docker Swarm {#swarm}

Para instalação do orquestrador em [Docker Swarm](https://docs.docker.com/engine/swarm/) é necessário disponibilizar três ou mais servidores dedicados (_bare metal_) ou máquinas virtuais. Em cada uma delas deverá ser instalado, preferencialmente, a distribuição [Linux Ubuntu Server 24.04 LTS](https://ubuntu.com/download/server). <u>É necessário que seja utilizada a arquitetura <b>amd64</b></u>. No momento da instalação do SO, haverá a possibilidade de instalar pacotes adicionais. Neste momento, selecione o **SSH Server**.

Uma vez que o _shell_ esteja disponível, atualize completamente a distribuição (`apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt autoclean`) em cada um dos nós e proceda com o [passo-a-passo oficial para instalação do Docker](https://docs.docker.com/engine/install/ubuntu/).

> **Atenção!** Após concluir da instalação, é fortemente recomendado efetuar o [login no Docker](https://docs.docker.com/engine/reference/commandline/login/) utilizando uma conta institucional (pelo menos nos nós do tipo _manager_). O uso do Docker não-autenticado pode resultar em erros durante o processo de _deploy_ (p.e., `Temporary failure in name resolution`).

Para instalar o **Docker Swarm**, [siga os passos da documentação oficial](https://docs.docker.com/engine/swarm/swarm-tutorial/). Você deverá definir a quantidade de servidores que atuará como _manager nodes_ e como _worker nodes_. Considere a [orientação da documentação oficial](https://docs.docker.com/engine/swarm/admin_guide/#distribute-manager-nodes) para otimizar a tolerância à falhas, onde o número de _managers_ deverá ser sempre ímpar. Assim, caso tenha 4 servidores/VMs em seu _cluster_, considere criar 3 _manager nodes_ e 1 _worker node_. Por fim, [adicione todos os nós ao _swarm_](https://docs.docker.com/engine/swarm/swarm-tutorial/add-nodes/).

Todo _cluster_ **Docker Swarm** deverá possuir um [servidor para registro de imagens (Docker Registry)](https://docs.docker.com/registry/) rodando localmente na porta padrão. Ele será utilizado para registrar as imagens criadas no _build_ em tempo de _deploy_ das aplicações. Para criá-lo no _swarm_, faça:

```bash
docker service create --name registry --publish published=5000,target=5000 registry:3
```

Configure agora um _storer_ associado ao _cluster_, que é o servidor físico onde serão armazenados os _volumes_ utilizados pelos containers para persistir dados:

- `SwarmNFSv4`: Será necessário ter um servidor de _storage_ dedicado ao _cluster_ em **Docker Swarm**. Nele, os mantenedores deverão [instalar e/ou habilitar o NFS (versão 4)](https://phoenixnap.com/kb/ubuntu-nfs-server). É importante que no arquivo `/etc/exports` sejam parametrizados, pelo menos, as seguintes opções no diretório a ser montado: `rw`, `no_root_squash`, `sync`, `no_subtree_check` e `insecure`. Todos os nós do _cluster_ devem ser capazes de montar o _storage_ NFS.

## 2. Integração (via SSH) do _cluster_ à plataforma {#ssh}

Para realizar a integração do novo _cluster_ com a plataforma **Embrapa I/O**, os mantenedores deverão configurar nas máquinas (todos os nós do _cluster_ e o _storage_, caso exista), reais ou virtuais, um usuário e a chave única de acesso SSH.

> **Atenção!** Nos comandos abaixo o `sudo` foi omitido, mas talvez você precise adicioná-lo no início das sentenças para executá-los de forma apropriada.

### a. Criação do usuário exclusivo:

Você deverá criar um usuário que será utilizado exclusivamente para executar os _pipelines_ de DevOps do **Embrapa I/O** neste _cluster_. O usuário pode ter qualquer _username_, porém, para exemplificar, utilizaremos o login "**io**":

```bash
adduser --disabled-login --gecos "" --shell /bin/bash io
```

Nos _clusters_, ou seja, as máquinas em que o Docker estiver executando (tal como todos os nós de um orquestrador [Docker Swarm](#swarm)), adicione este usuário ao grupo apropriado:

```bash
usermod -aG docker io
```

Com isso o usuário terá as permissões necessárias para executar os comandos do Docker.

### b. Adição do usuário ao _sudoers_:

Caso seu _cluster_ esteja utilizando um _storage_ desacoplado, execute os comandos abaixo apenas neste _storage_. Caso o armazenamento de volumes seja local, ou seja, no próprio _cluster_, execute os comando abaixo nele.

As instruções criam os diretórios em que os volumes serão armazenados e concede ao usuário de DevOps a permissão de alterar o proprietário e permissões de suas subpastas. Para exemplificar, foi considerado que o diretório de armazenamento de volumes será o `/mnt/nfs` e que o usuário de DevOps tem o login "**io**":

```bash
mkdir /mnt/nfs && chown io:io /mnt/nfs && chmod 700 /mnt/nfs

echo "io ALL=(ALL) NOPASSWD: /bin/chown * /mnt/nfs/*, /bin/chmod * /mnt/nfs/*" > /etc/sudoers.d/io
```

### c. Configuração da chave SSH:

Adicione agora a seguinte chave pública SSH no arquivo `.ssh/authorized_keys` do usuário:

```bash
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCykAvX7CZmqw1bgOCOmRtgpfr55cjqO0v1+DImp4pKrITdFxZu0OqsJgHjio/yp4w5+KvWmFJa5woYbZry9inFciwKo3+rpGjBHJfNfDq70/q3VdSSInFrSMtWgBk0x5QZQ78ENkNkO9DRIdnnffN9bY1uibR6ZX0pCSSyTGgx3NlAakW47tYIzVcrrUGKGG8vZwSkl7GhEEXtNETp02WQpkUvYrNqgRrmw2lvv41QfRETIuNN7PDhJrDO4tYHtix5D+Pvd05IacgTVQxpi6vnMVdgrwbZ1RPw9TLLkoy3kZs45hLG9oipiYOiD6rxiIYC0f1iUaKz9PKZdfnF8Ya5XJFoL6NcBTPDGh01dkEBonOWt3lgpC/2SBM/SeClt8M2lI6KtqAkjPEKWhnirDP0lXzY2CYamnu2rD6p4z4OWAYG6ngQcCIK45vQvsSz8mfitWnJe89WCCaEVj+L1QO/hjnKJ+eKf5ze35HagFRhpIAB34FmGHO3N8yFCLqvHFNLw6dKl5IXU2cvJF1jwhL3coOx9oeFZLPk45Zze2e/Itjd9x84gWtmo60MvXVBsYGYlcZLzSgAbNGldMuxAFWs0ZvghNx+KZjg6fZ2hAlPHIg1MiAlztyLbbjV2Mjc6ke6sjBDvPkPZQde6G/T8Mp56cCtAb/77/dw78zruX5qyQ== embrapa.io
```

Por exemplo, considerando que foi criado um usuário com login "**io**" e que a chave acima está na variável `$PUBLIC_KEY`, faça (em todos os nós do _cluster_ e no _storage_, caso exista):

```bash
mkdir -p /home/io/.ssh && chmod 700 /home/io/.ssh
echo "$PUBLIC_KEY" > /home/io/.ssh/authorized_keys
chmod 600 /home/io/.ssh/authorized_keys && chown -R io:io /home/io/.ssh
```

Além de autorizar a chave, assegure que o _firewall_ permita o acesso do _host_ `core.embrapa.io` (IP `200.202.148.38`) em cada uma das máquinas (inclusive o _storage_, caso exista) via SSH na **porta 22**.

> **Atenção!** Neste momento não é possível ainda alterar a porta do SSH. Esta configuração simples tem implicações profundas no Docker CLI e na forma como ele está integrado à plataforma **Embrapa I/O**.

Repare que, com esta configuração, os autômatos do **Embrapa I/O** conseguirão acessar os servidores do _cluster_. Isso é necessário para que a plataforma consiga provisionar no servidor todos os artefatos para _deploy_ das aplicações (tal como diretórios, _networks_ e _volumes_, além de realizar a _build_ e instanciação das imagens e containers).

## 3. Liberação das demais portas no _firewall_ {#ports}

O **Embrapa I/O** expõe as aplicações instanciadas em portas na **faixa de 49152 a 65535**. Portanto, toda esta faixa de portas deverá ser exposta para acesso público nos servidores de aplicação que compõem o _cluster_ (p.e., todos os nós _managers_ e _workers_ no [Docker Swarm](https://docs.docker.com/engine/swarm/)).

> **Atenção!** Existe um limite de **30 projetos** para cada cada _cluster_ do **Embrapa I/O**. Este limite está relacionado ao limite padrão do Docker, onde um único _host_ não deve possuir mais do que 30 _networks_. É possível contornar esta limitação, mas visando manter uma complexidade comedida da gestão das VMs, sugere-se mantê-lo. É importante frisar que o número de aplicações em cada projeto e de containers em cada aplicação não é limitado pela plataforma e, portanto, ficará a cargo das limitações de _hardware_, sistema operacional e outros recursos escassos, tal como a quantidade máxima de portas expostas em cada _cluster_ (no caso, 16.383).

## 4. Configuração do _plugin_ para _logging_ {#loki}

O **Embrapa I/O** utiliza o [Grafana Loki](https://grafana.com/docs/loki/latest/) para permitir a coleta e análise de _log_ de todos os containers instanciados. Assim, é necessário [instalar o _plugin_ do Loki](https://grafana.com/docs/loki/latest/send-data/docker-driver/) para que toda a saída dos containers (no _stdout_) seja enviada para o [Grafana](https://log.embrapa.io).

Para instalar o _plugin_, execute:

```bash
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
```

Verifique a instalação utilizando o comando `docker plugin ls`.

Uma vez que o plugin esteja instalado no Docker, edite o arquivo `/etc/docker/daemon.json` (ou `/var/snap/docker/current/config/daemon.json`, se tiver sido instalado pelo [Snap](https://snapcraft.io)) inserindo o seguinte conteúdo:

```json
{
  "debug" : true,
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "https://<username>:<password>@loki.embrapa.io/loki/api/v1/push",
    "loki-batch-size": "400",
    "loki-retries": "5",
    "loki-max-backoff": "1s",
    "loki-timeout": "2s",
    "keep-file": "true"
  }
}
```

> **Atenção!** Os valores de `username` e `password` para a linha acima devem ser obtidos junto à **Supervisão de Desenvolvimento de Ativos Digitais (DEGI/GCI/GTI/SDAD)**.

Por fim, faça: `systemctl restart [service]`, onde `[service]` pode ser `docker` ou `snap.docker.dockerd` (se tiver sido instalado via [Snap](https://snapcraft.io)). Caso tenha dúvida sobre o nome exato do serviço, execute `systemctl list-units --type=service | grep docker`. É possível verificar se há algum erro utilizando o comando `journalctl -u [service] | grep loki`. Se configurado com sucesso, deverá ser visto na saída deste último comando algo como "_Using default logging driver loki_".

## 5. Ativação do _Web Terminal_ (opcional) {#terminal}

O recurso de **Web Terminal** permite que [membros do projeto com o papel de **Arquitetos da Solução**]({{ site.baseurl }}/docs/squads/#architect) acessem diretamente o _shell_ dos containers das aplicações (via `ash`, `bash`, `dash` ou `sh`). Este recurso é útil para depurar, realizar manutenções eventuais e fazer intervenções pontuais no container em execução.

![Web Terminal]({{ site.baseurl }}/assets/img/posts/Terminal.gif)

A ativação do **Web Terminal** é um recurso opcional, que a equipe de mantenedores do _cluster_ pode ativar ou não (assim como, p.e., a disponibilização de um SMTP para envio de e-mails). Para ativação do recurso no _cluster_ é necessário ter um [utilitário instalado que foi desenvolvido especificamente para esta finalidade](https://hub.docker.com/r/embrapa/terminal).

Para instalá-lo, sugere-se a criação de um _script_ denominado `/root/terminal.sh` com o seguinte conteúdo...

...no **Docker Compose**:

```bash
#!/bin/sh

type docker > /dev/null 2>&1 || { echo >&2 "Command 'docker' has not been found! Aborting."; exit 1; }

set -x

set +e

docker stop terminal

docker rm terminal

set -e

docker pull embrapa/terminal

docker run --name terminal \
  -v /var/embrapa/ssl/wildcard/cnpxx.crt:/ssl/server.crt:ro \
  -v /var/embrapa/ssl/wildcard/cnpxx.key:/ssl/server.key:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -p 65500:5000 \
  --restart unless-stopped -d \
  embrapa/terminal
```

...no **Docker Swarm**:

```bash
#!/bin/sh

type docker > /dev/null 2>&1 || { echo >&2 "Command 'docker' has not been found! Aborting."; exit 1; }

set -x

set +e

docker service rm terminal

set -e

docker pull embrapa/terminal

docker service create --name terminal \
  --mode=global \
  --mount=type=bind,src=/var/embrapa/ssl/wildcard/cnpxx.crt,dst=/ssl/server.crt,readonly \
  --mount=type=bind,src=/var/embrapa/ssl/wildcard/cnpxx.key,dst=/ssl/server.key,readonly \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock,readonly \
  --publish published=65500,target=5000 \
  embrapa/terminal
```

Repare que os caminhos para os certificados SSL (`cnpxx.crt` e `cnpxx.key`) devem ser alterados para corresponder aos corretos.

Em seguida, atribua permissões (`chmod +x /root/terminal.sh`) e execute. Ao finalizar, para verificar se está tudo certo, dê o comando...

...no **Docker Compose**:

```bash
docker logs -f terminal
```

...no **Docker Swarm**:

```bash
docker logs -f $(docker ps -q -f name=terminal)
```

Você deverá ver a mensagem "**WebSocket Server running!**".

## 6. Instalação de um _Distribution Registry_ (opcional) {#registry}

Como [vimos acima](#swarm), a instalação de um [_Distribution Registry_](https://distribution.github.io/distribution/) local é obrigatória caso esteja utilizando como orquestrador o **Docker Swarm**. Caso contrário, ela é opcional. Porém, mesmo nestes casos, pode ser útil ter um _registry_ local para armazenar as imagens dos seus _builds_ e, desta forma, prover mais agilidade e segurança nos processos de _deploy_.

Para instalar, basta executar o comando:

```bash
docker run -d -p 5000:5000 --name registry registry:3
```

> **Atenção!** Este registro deverá ser utilizado apenas localmente e, portanto, **a porta 5000 não deverá ser exposta publicamente no _firewall_**.

## 7. Configuração do Portainer (opcional) {#portainer}

Adicionalmente, é fortemente recomendado que seja [instalado o Portainer](https://docs.portainer.io/start/install) para auxiliar a equipe mantenedora de _clusters_ em [Docker Compose](https://docs.portainer.io/start/install/server/docker/linux), [Docker Swarm](https://docs.portainer.io/start/install/server/swarm/linux) ou [Kubernetes](https://docs.portainer.io/start/install/server/kubernetes/baremetal) em sua gestão. Por padrão, recomenda-se que este seja disponibilizado publicamente no HTTPS (porta 443) da URL do _cluster_, com o HTTP (porta 80) redirecionando para o HTTPS. Desta forma, será necessário abrir também em seu _firewall_ o acesso às portas 80 e 443 do novo _cluster_ (além das portas altas comentadas acima).

Para simplificar a instalação e recorrente atualização do Portainer (quando necessário), crie um _script_ denominado `/root/portainer.sh` com as seguintes instruções:

```bash
#!/bin/sh

type docker > /dev/null 2>&1 || { echo >&2 "Command 'docker' has not found! Aborting."; exit 1; }

set -x

set +e

docker stop portainer

docker rm portainer

docker volume create portainer_data

set -e

docker pull portainer/portainer-ce:latest

docker run -d -p 8000:8000 -p 9443:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
```

Além disso, [instale o Nginx](https://www.linuxcapable.com/how-to-install-nginx-on-debian-linux/) e, para a configuração acima do Portainer, especifique um novo site como segue (troque `io.cnpxx.embrapa.br` pelo nome correto do seu _cluster_):

```
server {
  listen 80;
  listen [::]:80;

  server_name io.cnpxx.embrapa.br;

  return 301 https://io.cnpxx.embrapa.br;
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  ssl_certificate /etc/embrapa/wildcard/io.cnpxx.embrapa.br/fullchain.pem;
  ssl_certificate_key /etc/embrapa/wildcard/io.cnpxx.embrapa.br/privkey.pem;
  ssl_trusted_certificate /etc/embrapa/wildcard/io.cnpxx.embrapa.br/fullchain.pem;
  ssl_protocols TLSv1.2 TLSv1.3;

  server_name io.cnpxx.embrapa.br;

  location / {
    resolver 127.0.0.1 [::1];
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Access-Control-Allow-Origin '*';
    proxy_set_header Access-Control-Allow-Methods 'GET, POST, OPTIONS, PUT, DELETE, HEAD';
    proxy_cache_bypass $http_upgrade;
    proxy_ssl_session_reuse off;
    proxy_pass http://localhost:9443;
  }
}
```

## 8. Backup e limpeza do cache (opcional) {#backup}

Para _backup_ periódico do _cluster_, além dos processos e protocolos existentes no _data center_ em que está alocado, recomenda-se configurar um _schedular job_ diário utilizando a ferramenta [docker-backup](https://github.com/muesli/docker-backup). Uma vez instalada e devidamente adicionada ao _path_ do sistema operacional, crie um arquivo `.sh` com o seguinte conteúdo:

```bash
#!/bin/sh

HOSTNAME=$(hostname)

echo "Starting embrapa.io backup process to $HOSTNAME..."

type docker > /dev/null 2>&1 || { echo >&2 "Command 'docker' has not found! Aborting."; exit 1; }

type docker-backup > /dev/null 2>&1 || { echo >&2 "Command 'docker-backup' has not found! See: https://github.com/muesli/docker-backup. Aborting."; exit 1; }

set -e

BKP_PATH="/var/opt/embrapa.io/backup"

mkdir -p $BKP_PATH

[ ! -d $BKP_PATH ] && echo "$BKP_PATH does not exist." && exit 1

BKP_FOLDER="io_cluster_$(date +%Y-%m-%d_%H-%M-%S)"

echo "Deleting old backups (older than 7 days)..."

find $BKP_PATH -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;

echo "Creating backup folder: '$BKP_FOLDER'..."

mkdir -p $BKP_PATH/$BKP_FOLDER/$HOSTNAME

set +e

echo "Starting Docker backup process with 'docker-backup' to all containers..."

cd $BKP_PATH/$BKP_FOLDER/$HOSTNAME

docker-backup backup --all --stopped --tar --verbose

set -e

echo "Compressing backup folder..."

cd /tmp

tar -czvf $BKP_PATH/$BKP_FOLDER.tar.gz -C $BKP_PATH $BKP_FOLDER

rm -rf $BKP_PATH/$BKP_FOLDER

echo "All done! Backup file at: $BKP_PATH/$BKP_FOLDER.tar.gz"

echo "Clean up unused images..."

docker builder prune -af --filter "until=24h"

docker image prune -af --filter "until=24h"
```

Adicione este arquivo no CRON para ser executado diariamente. Por exemplo, se foi criado um arquivo `/root/embrapa.io/backup/cluster.sh`, crie um _script_ `/etc/cron.daily/io` com o seguinte conteúdo:

```bash
#!/bin/sh

find /var/log -type f -name "embrapa.io*" -mtime +14 -exec rm {} \;

DATE="$(date +%Y-%m-%d)"

/root/embrapa.io/backup/cluster.sh >> /var/log/embrapa.io-cluster-$DATE.log 2>&1
```

Em seguida, faça:

```bash
chmod +x /root/embrapa.io/backup/cluster.sh
chmod +x /etc/cron.daily/io

/etc/init.d/cron reload
```

É importante notar as linhas finais do _script_ de _backup_, onde aparecem os comandos:

```bash
echo "Clean up unused images..."

docker builder prune -af --filter "until=24h"

docker image prune -af --filter "until=24h"
```

O processo de _build_ do Docker gera uma imensa quantidade de imagens e outros arquivos de _cache_. Isto tende a ocupar rapidamente todo o espaço em disco. Estes comandos garantem que este _cache_ não tenha mais do que 24 horas.

> **Atenção!** Ainda que opte por não configurar o processo de _backup_ sugerido acima, considere criar um _schedular job_ para executar as linhas de limpeza do _cache_ diariamente.

# Disponibilizando no Catálogo

Uma vez configurado o _cluster_, basta montar as configurações em formato JSON e [enviar para a equipe de gestão da plataforma](mailto:io@embrapa.br). O exemplo abaixo demonstra como deverão ser as configurações:

```json
{
  "release": [
    {
      "host": "io.facom.ufms.br",
      "ssh":{
        "user": "devops"
      },
      "local": "Faculdade de Computação da UFMS",
      "location": "Campo Grande - MS",
      "orchestrator": "DockerCompose",
      "storage": {
        "type": "DockerNFSv4",
        "host": "storage.facom.ufms.br",
        "path": "/mnt/nfs"
      },
      "aliases": [
        "releases.facom.ufms.br",
        "agro.facom.ufms.br",
        "farm.facom.ufms.br",
        "live.facom.ufms.br",
      ],
      "disabled": false,
      "maintainers": [
        { "name": "Hercule Poirot", "email": "hercule.poirot@ufms.br", "phone": "+55 (67) 9 8888-7777" },
        { "name": "Maria Capitolina Santiago", "email": "capitu.santiago@ufms.br", "phone": "+55 (67) 9 6666-5555" }
      ],
      "resources": {
        "smtp": {
          "active": true,
          "host": "smtp.facom.ufms.br",
          "port": 25,
          "tls": false
        },
        "terminal": {
          "active": true,
          "port": 65500
        },
        "external": {
          "active": true
        },
        "registry": {
          "active": false
        },
        "backup": {
          "active": true
        },
        "snapshot": {
          "active": true
        }
      }
    },
    {
      "host": "cluster.cnpgc.embrapa.br",
      "ssh":{
        "user": "io"
      },
      "nodes": {
        "manager": [
          "manager1.cnpgc.embrapa.br",
          "manager2.cnpgc.embrapa.br"
        ],
        "worker": [
          "worker1.cnpgc.embrapa.br"
        ]
      },
      "local": "Embrapa Gado de Corte",
      "location": "Campo Grande - MS",
      "orchestrator": "DockerSwarm",
      "storage": {
        "type": "SwarmNFSv4",
        "host": "storage.cnpgc.embrapa.br",
        "path": "/swarm"
      },
      "aliases": [
        "app.cnpgc.embrapa.br",
        "manager.cnpgc.embrapa.br",
        "api.cnpgc.embrapa.br",
        "portal.cnpgc.embrapa.br"
      ],
      "disabled": false,
      "maintainers": [
        { "name": "Dorothy Gale", "email": "dorothy.gale@embrapa.br", "phone": "+55 (67) 3368-1122" },
        { "name": "Bras Cubas", "email": "bras.cubas@embrapa.br", "phone": "+55 (67) 3368-3344" },
        { "name": "Tyler Durden", "email": "tyler.durden@embrapa.br", "phone": "+55 (67) 3368-5566" }
      ],
      "resources": {
        "smtp": {
          "active": true,
          "host": "smtp.cnpgc.embrapa.br",
          "port": 587,
          "tls": true
        },
        "terminal": {
          "active": false,
          "port": 65500
        },
        "external": {
          "active": false
        },
        "registry": {
          "active": true
        },
        "backup": {
          "active": true
        },
        "snapshot": {
          "active": true
        }
      }
    }
  ],
  "beta": [
    {
      "host": "io.facom.ufms.br",
      "ssh":{
        "user": "devops"
      },
      "local": "Faculdade de Computação da UFMS",
      "location": "Campo Grande - MS",
      "orchestrator": "DockerCompose",
      "storage": {
        "type": "DockerNFSv4",
        "host": "storage.facom.ufms.br",
        "path": "/mnt/nfs"
      },
      "aliases": [
        "test.facom.ufms.br",
        "beta.facom.ufms.br"
      ],
      "disabled": false,
      "maintainers": [
        { "name": "Hercule Poirot", "email": "hercule.poirot@ufms.br", "phone": "+55 (67) 9 8888-7777" },
        { "name": "Maria Capitolina Santiago", "email": "capitu.santiago@ufms.br", "phone": "+55 (67) 9 6666-5555" }
      ],
      "resources": {
        "smtp": {
          "active": true,
          "host": "smtp.facom.ufms.br",
          "port": 25,
          "tls": false
        },
        "terminal": {
          "active": true,
          "port": 65500
        },
        "external": {
          "active": true
        },
        "registry": {
          "active": false
        },
        "backup": {
          "active": false
        },
        "snapshot": {
          "active": true
        }
      }
    }
  ],
  "alpha": [
    {
      "host": "io.facom.ufms.br",
      "ssh":{
        "user": "devops"
      },
      "local": "Faculdade de Computação da UFMS",
      "location": "Campo Grande - MS",
      "orchestrator": "DockerCompose",
      "storage": {
        "type": "DockerLocal",
        "path": "/mnt/volumes"
      },
      "aliases": [
        "sandbox.facom.ufms.br",
        "alpha.facom.ufms.br"
      ],
      "disabled": false,
      "maintainers": [
        { "name": "Hercule Poirot", "email": "hercule.poirot@ufms.br", "phone": "+55 (67) 9 8888-7777" },
        { "name": "Elizabeth Bennet", "email": "elizabeth.bennet@ufms.br", "phone": "+55 (67) 9 4444-3333" },
        { "name": "Fitzwilliam Darcy", "email": "fitzwilliam.darcy@ufms.br", "phone": "+55 (67) 9 2222-1111" }
      ],
      "resources": {
        "smtp": {
          "active": true,
          "host": "smtp.facom.ufms.br",
          "port": 25,
          "tls": false
        },
        "terminal": {
          "active": true,
          "port": 65500
        },
        "external": {
          "active": true
        },
        "registry": {
          "active": false
        },
        "backup": {
          "active": false
        },
        "snapshot": {
          "active": true
        }
      }
    }
  ]
```

Repare que o _cluster_ deve ser configurado especificamente para cada estágio da aplicação. Assim, ele pode estar disponível para os estágios _alpha_, _beta_ e/ou _release_, ou seja, não necessariamente para todos. O `host` deverá apontar para o IP real do servidor ou VM. O atributo `ssh.user` permite especificar o [usuário exclusivo para acionar os processos de _deploy_ no _cluster_](#ssh). Os atributos `local` e `location` indicam a Unidade da Embrapa, instituição ou empresa e a sua localização geográfica.

O `orchestrator` indica o _driver_ de orquestração que está sendo utilizado. No exemplo acima, o _cluster_ `io.facom.ufms.br` está configurado com o orquestrador **Docker Compose** e, portanto, é composto por um único servidor. Já o _cluster_ `cluster.cnpgc.embrapa.br` está configurado com o orquestrador **Docker Swarm** e é, portanto, composto por diversos nós. Neste caso, no atributo `host` deverá ser referenciado um _manager node_ principal, que no nosso exemplo é o `cluster`. No atributo `node` estão declarados explicitamente os demais nós, sendo `manager1` e `manager2` como _manager nodes_ e `worker1` como um _worker node_, totalizando assim os 4 (quatro) nós que formam o _cluster_.

O atributo `storage` contém o _driver_ de _storer_ e atributos relacionados. Por exemplo, para o estágio _alpha_ foi configurado um _storer_ utilizando o _driver_ `DockerLocal` e, desta forma, os _volumes_ serão criados no diretório `/mnt/volumes` indicado no atributo `path`. Já em estágio _beta_ e _release_ está sendo utilizado o _driver_ para **NFSv4** e, desta forma, os _volumes_ serão criados fisicamente no diretório remoto `/mnt/nfs` do _storage_ `storage.facom.ufms.br`.

Os `aliases` são subdomínios configurados pela Unidade da Embrapa, instituição ou empresa parceira que [possibilitam alocar as aplicações em domínios mais condizentes semanticamente com a sua finalidade]({{ site.baseurl }}/docs/build#urls). Estes aliases **devem ser configurados no DNS** da seguinte forma:

1. Para cada _alias_, crie um registro do tipo `CNAME` apontando para `router.embrapa.io`; e
2. Para cada _alias_, crie um _wildcard subdomain_ (registro do tipo `A`) apontando para o **IP** do `router.embrapa.io` (ou seja, `200.202.148.38`).

Assim, para um _alias_ `app.cnpgc.embrapa.br`, teríamos:

```
Name                      Type     Value
----------------------    -----    -----------------
app.cnpgc.embrapa.br      CNAME    router.embrapa.io
*.app.cnpgc.embrapa.br    A        200.202.148.38
```

Vale ressaltar que as aplicações instanciadas estarão sempre expostas por meio das portas atribuídas a elas em cada _cluster_. Em _clusters_ com múltiplos nós (_nodes_), as réplicas em cada nó poderão ser acessadas de forma distinta pelo endereço real do nó e porta específica. O _load balancer_ será automaticamente ativado quando um [_alias_, URL externa ou _subpath_ for configurado]({{ site.baseurl }}/docs/build#urls). Para isso, é utilizado o método [_least connected_ do Nginx](https://nginx.org/en/docs/http/load_balancing.html), onde a próxima solicitação é atribuída ao servidor com o menor número de conexões ativas.

O atributo `resources` irá informar ao usuário, no momento da escolha do _cluster_ para _deploy_ da aplicação durante a [configuração da _build_]({{ site.baseurl }}/docs/build#cluster), quais os recursos que estão disponíveis:

- **SMTP:** Se há um servidor de SMTP para envio de e-mails associado a este _cluster_. Se existir, as informações para conexão serão exibidas ao usuário.

- **IP Público:** Se o _cluster_ possui um IP Público. Caso possua, é possível o acesso direto às portas provisionadas para os serviços e, com isso, disponibilizar nele serviços não-HTTP, tal como _brokers_ IoT (MQTT, CoAP, AMQP, XMPP, etc). Caso não possua, todas as aplicações neste _cluster_ estarão acessíveis apenas pelo provisionamento HTTPS que o **Embrapa I/O** faz (roteando o tráfego pelo balanceador de carga via _virtual proxy_).

- **Web Terminal:** Se o _cluster_ suporta a funcionalidade de [Web Terminal](#terminal).

- **Registro:** Se o _cluster_ possui [registro local para as imagens dos containers](#registry).

- **Backup:** Se existe neste _cluster_ [processo automatizado e individualizado de _backup_ das aplicações](#backup).

- **Snapshot:** Se é realizado o backup do tipo _snapshot_ na(s) VM(s) do _cluster_ em questão.

> **Atenção!** Repare que o recursos de _backup_ difere do recurso de _snapshot_. No primeiro, caso esteja disponível, será possível a recuperação de aplicações específicas, de forma individualizada. No segundo, o _restore_ da VM é realizada em caso de um problema crítico, que afete o _cluster_ como um todo.

Caso o atributo `disabled` esteja setado como `true`, o _cluster_ não aceitará novos _deploys_ naquele _cluster_ para aquele estágio específico (ou seja, ele pode estar `disabled` para o estágio _release_, mas não para _alpha_ e _beta_), porém as _builds_ já instanciadas continuarão sendo geridas normalmente (inclusive recebendo _deploys_ de novas _tags_). Por fim, é possível estabelecer grupos diferentes de mantenedores para o _cluster_ em cada estágio.
