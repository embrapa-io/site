---
layout: page
title: Releaser
subtitle: Deploy de builds em clusters externos
---

A plataforma **Embrapa I/O** oferece um ecossistema de DevOps completo para desenvolvimento e entrega de aplicações. Por meio de uma rede de _clusters_ é possível fazer o _deploy_ automatizado de ativos em diferentes estágios de maturidade. Entretanto, algumas vezes é necessário que a entrega destes ativos se dê em ambientes externos à plataforma. Por exemplo, em projetos desenvolvidos em parceria com entes externos (tal como empresas privadas) pode ser acordado a disponibilização da solução em produção em uma nuvem do próprio parceiro ou terceirizada. Nestes casos, pode ser indesejado por parte deste parceiro, integrar esta nuvem à rede de _clusters_ do **Embrapa I/O**.

Além disso, todos os _clusters_ do catálogo da plataforma são de **uso compartilhado**. Isto significa que os recursos de hardware dos servidores (disco, memória, unidades de processamento, etc) não podem ser provisionados por aplicação, sendo gerenciados exclusivamente pelos orquestradores. Para disponibilização de soluções em produção, principalmente aquelas de alta demanda, esta especificidade será um risco.

Por fim, atualmente a plataforma **Embrapa I/O** encontra-se em _Beta Release_, ou seja, ainda em fase de desenvolvimento. Apesar de utilizar ferramentas maduras em sua construção (tal como, o [GitLab](https://gitlab.com), o [Sentry](https://sentry.io) e o [Matomo](https://matomo.org)), **a disponibilização de aplicações em produção (_release_) por meio da plataforma é fortemente desencorajada**. Existem elementos críticos, tal como o roteamento de URLs (realizado pelo autômato _router_), que precisam ser amadurecidos. Assim, orienta-se que, neste momento, sejam realizados apenas o _deploy_ de aplicações em estágio de **testes internos** (_alpha_) e **testes externos** (_beta_) utilizando a rede de _clusters_ da plataforma.

Devido a estes pontos, foi criada uma ferramenta, denominada **Releaser**, visando simplificar o processo de _deploy_ e atualização contínua de _builds_ de aplicações em servidores externos à plataforma. Esta ferramenta funciona de duas formas:

- como um **utilitário de linha de comando**, permitindo que o usuário faça a gestão das _builds_ manualmente (_deploy_, _rollback_, _stop_, _restart_, _sanitize_, _backup_, etc); e

- como um **serviço executando em segundo plano (_daemon_)**, mantendo as _builds_ atualizadas para a sua versão mais recente e executando periodicamente os processos de _backup_ e _sanitize_.

É importante ressaltar que a ferramenta **Releaser** implementa alguns dos _pipelines_ de DevOps do **Embrapa I/O**, <u>mas não todos</u>. A responsabilidade pela configuração de rotas, das URLs (CNAMEs), balanceamento de carga e certificados SSL (criação e atualização periódica), por exemplo, ficarão a cargo de um administrador da rede, que deverá realizar estas tarefas manualmente.

## Instalação

A ferramenta está [disponível publicamente como uma imagem no **Docker Hub**](https://hub.docker.com/r/embrapa/releaser). Para utilizá-la, primeiramente **crie um diretório** onde serão colocados os **arquivos de configuração**:

```bash
mkdir -p ~/releaser && cd ~/releaser
```

Neste diretório serão configuradas as chaves de acesso à plataforma **Embrapa I/O** e todas as informações necessárias para o _deploy_ das _builds_. Assim, em caso de restauração do ambiente, estes arquivos serão essenciais.

> **Atenção!** É fortemente recomendado o _backup_ deste diretório sempre que houver alterações nestas configurações.

Atualmente a ferramenta **Releaser** funciona com dois orquestradores de containers: [Docker Compose](https://docs.docker.com/compose/) e [Docker Swarm](https://docs.docker.com/engine/swarm/).

### Docker Compose

Para utilizar a ferramenta em um servidor com **Docker Compose**, basta instanciá-la como um container:

```bash
mkdir -p ~/releaser && cd ~/releaser

docker run --name releaser \
  -v $(pwd):/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped -d \
  embrapa/releaser
```

### Docker Swarm

Para utilizar em um servidor com **Docker Swarm**, primeiramente você deve ter um [Docker Registry](https://docs.docker.com/registry/) rodando localmente:

```bash
docker service create \
  --name registry \
  --publish published=5000,target=5000 \
  registry:2
```

Em seguida, instancie a ferramenta **Releaser** como um serviço em um nó do tipo _manager_:

```bash
mkdir -p ~/releaser && cd ~/releaser

docker service create --name releaser \
  --constraint=node.hostname==$(hostname) \
  --mount=type=bind,src=$(pwd),dst=/data \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  embrapa/releaser
```

## Configuração

Para auxiliar na configuração inicial, execute o seguinte comando...

...no **Docker Compose**:

```bash
docker exec -it releaser io
```

...no **Docker Swarm**:

```bash
docker exec -it $(docker ps -q -f name=releaser) io
```

Caso o diretório de configuração (`~/releaser`, neste exemplo) esteja vazio, você será orientado no preenchimento das variáveis de ambiente necessárias ao funcionamento da ferramenta. Ao final de uma série de perguntas, será criado um arquivo `.env` com um conteúdo semelhante ao abaixo:

```bash
SERVER=cloud.cnpgc.embrapa.br
ORCHESTRATOR=DockerCompose
GITLAB_TOKEN=z2dK8wqkMDc7O1FucoYW
SMTP_HOST=smtp.cnpgc.embrapa.br
SMTP_PORT=587
SMTP_SECURE=yes
SMTP_FROM=no-reply@embrapa.br
SMTP_USER=cixin.liu@embrapa.br
SMTP_PASS=secret
LOG_MAIL=cnpgc.suporte@embrapa.br
```

Tenha em mente que valor de `SERVER` será injetado no momento do _deploy_ das _builds_ como a variável de ambiente `IO_SERVER`.

O `GITLAB_TOKEN` deve ser obtido por meio da interface do [GitLab do Embrapa I/O](https://git.embrapa.io). Para isso, acesse seu _profile_ e vá na opção [Personal Access Tokens](https://git.embrapa.io/-/profile/personal_access_tokens). Gere um novo _token_ selecionando o _scope_ `read_api`.

![Access Token no GitLab]({{ site.baseurl }}/assets/img/releaser/20230717155813.png)

> **Atenção!** O usuário que irá gerar o **Access Token** deverá ter acesso a todos os projetos que terão apps instanciadas pela ferramenta **Releaser** neste servidor.

As variáveis com o prefixo `SMTP` são necessárias para configuração do envio de e-mails. A ferramenta **Releaser**, quando rodando no modo _daemon_, envia um e-mail de _log_ sempre que ocorre a atualização de uma aplicação para uma nova versão (ou em caso de erro). Conforme será visto abaixo, pode-se configurar para cada _build_ o time que irá receber estes e-mails. Além disso, deve-se configurar um e-mail padrão de _log_ (variável `LOG_MAIL`) que também recebe todos os e-mails enviados.

Além disso, será gerado um par de chaves SSH, caso não exista. Estas chaves são necessárias para a sincronização do código-fonte das aplicações. Você deve acessar novamente seu _profile_ no GitLab da plataforma e ir na opção [SSH Keys](https://git.embrapa.io/-/profile/keys). Cadastre então o conteúdo da chave pública gerada (arquivo `ssh.pub`).

![SSH Key no GitLab]({{ site.baseurl }}/assets/img/releaser/20230717164051.png)

Por fim, você deverá configurar as [_builds_ das aplicações]({{ site.baseurl }}/docs/introduction#build) que serão gerenciadas pela ferramenta **Releaser**. Para cada _build_ deverá haver uma entrada no arquivo `builds.json`. Por exemplo:

```json
[
  {
    "project": "pasto-certo",
    "app": "pwa",
    "stage": "release",
    "team": [
      "ludwig.mises@embrapa.br",
      "murray.rothbard@embrapa.br"
    ],
    "sentry": {
      "dsn": "https://8eaf295c850d9c188f280cbd27ab0fe7ab7ca644@bug.embrapa.io/123"
    },
    "matomo": {
      "id": 321,
      "token": "73a2ada00882dcee68193f3c5cc02eb03310602f"
    },
    "auto": {
      "deploy": true,
      "backup": false,
      "sanitize": false
    },
    "env": {
      "PORT": "49152",
      "VUE_APP_API": "https://test.cnpgc.embrapa.br/pasto-certo/api",
      "VUE_APP_TOKEN": "sPOve29ZnLmtNAiLRLjh5EzKrS2Unnno",
      "VUE_APP_ANALYTICS": "UA-123456789-0"
    }
  },
  {
    "project": "andro-certo",
    "app": "api",
    "stage": "beta",
    "team": [
      "bernard.cornwell@embrapa.br"
    ],
    "sentry": {
      "dsn": "https://d5020b7beccd6ef6b14b904b92ee3cae1584be6f@bug.embrapa.io/456"
    },
    "matomo": {
      "id": 654,
      "token": "0aa0277979f61d68ae5d602452f6ba246ed2982e"
    },
    "auto": {
      "deploy": true,
      "backup": true,
      "sanitize": true
    },
    "env": {
      "PORT": "49153",
      "ENVIRONMENT": "test",
      "SECRET": "dOpSqbFtj4Yzqa7lAR0jt3mRDgw09JsA",
      "SMTP_HOST": "smtp.cnpgc.embrapa.br",
      "SMTP_PORT": "587",
      "SMTP_SECURE": "yes",
      "EXPRESS_PORT": "49154",
      "MONGO_NON_ROOT_USERNAME": "user",
      "MONGO_ROOT_PASSWORD": "secret",
      "MONGO_NON_ROOT_PASSWORD": "secret",
      "MONGO_DATA": "andro-certo_api_alpha_db",
      "BACKUP": "andro-certo_api_alpha_backup"
    }
  }
]
```

No exemplo acima foram configuradas duas _builds_: `pasto-certo/pwa@release` e `andro-certo/api@beta`. O atributo `team` lista os e-mails que irão receber os _logs_ do processo de _deploy_ correlatos a cada _build_. O atributo _auto_ permite ativar os serviços que serão executados de forma periódica, sendo eles:

- ***deploy***: Executa a cada **15 minutos** a busca por novas versões, ou seja, _tags_ na _branch_ do estágio da _build_. Caso encontre, executa o processo de _deploy_ da nova _tag_ e envia um e-mail de _log_ (informando o sucesso ou eventuais erros no procedimento);

- ***backup***: Executa **diariamente** o serviço de _backup_ da _stack_ de _containers_ da _build_. É fundamental que o [serviço de _backup_]({{ site.baseurl }}/docs/backup) esteja corretamente configurado na aplicação. Os arquivos de backup serão salvos no volume externo de _backup_; e

- ***sanitize***: Executa **mensalmente** o serviço de sanitização, caso esteja corretamenta configurado na _stack_ de _containers_ da _build_. Mais informações sobre os processos de higienização/otimização dos _containers_ podem ser encontradas [no tutorial de criação de _boilerplates_]({{ site.baseurl }}/docs/boilerplate).

O **DSN do Sentry**, [conforme já explicado]({{ site.baseurl }}/docs/bug), pode ser obtido a partir da [_dashboard_ do Embrapa I/O](https://dashboard.embrapa.io). Da mesma forma, o **ID do Matomo** também pode ser obtido por meio da _dashboard_, [conforme já visto anteriormente]({{ site.baseurl }}/docs/analytics). O **_token_ do Matomo**, por sua vez, é gerado pelo Embrapa I/O automaticamente quando se utiliza os _pipelines_ de _deploy_ padrão da plataforma. Para gerá-lo manualmente, você precisará [acessar o Matomo](https://hit.embrapa.io) e autenticar-se com seu login e senha. Em seguida, acesse a "Aministração" (na _toolbar_) e vá em "Pessoal &raquo; Segurança". Na seção "**Tokens de autenticação**" adicione um novo _token_, inserindo o valor da _hash_ gerada no atributo correlato nas aplicações do `builds.json`.

![Tokens de autenticação no Matomo]({{ site.baseurl }}/assets/img/releaser/20230717162755.png)

> **Atenção!** O usuário que irá gerar o ***token*** do Matomo deverá ter acesso aos projetos em que esta _hash_ for informada. Você pode gerar um único _token_ para atender a todos os projetos no Releaser dos quais participa como membro da equipe.

No atributo `env` devem ser listadas as variáveis de ambiente que serão injetadas no momento do _deploy_. Mais especificamente, será gerado um arquivo `.env` na raiz do diretório clonado da aplicação, de forma idêntica à utilizada para instanciar a aplicação em ambiente local de desenvolvimento.

Pronto! Caso tenha seguido corretamente os passos acima, a ferramenta estará pronta para ser executada.

## Utilização

Para utilizar a ferramenta, execute a seguinte instrução...

...no **Docker Compose**:

```bash
docker exec -it releaser io COMMAND
```

...no **Docker Swarm**:

```bash
docker exec -it $(docker ps -q -f name=releaser) io COMMAND
```

Os comandos disponíveis são:

- ***validate***: Executa o processo de validação da _build_ (_dry run_). Aceita como parâmetro uma lista de _builds_ separadas por vírgula (por exemplo, `proj1/app1@alpha,proj1/app2@alpha,proj2/app1@beta`) ou `--all` (para executar em todas as _builds_ configuradas);
- ***deploy***: Valida, prepara (criando, p.e., a rede) e faz o _deploy_ da _build_ para a última versão. Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`. Também aceita o parâmetro `--force`, que irá forçar o _re-deploy_ mesmo que não exista uma nova _tag_;
- ***stop***: Derruba a _stack_ de _containers_ da _build_. Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`;
- ***restart***: Inicia ou re-inicia a _stack_ de _containers_ da _build_. Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`;
- ***rollback***: Executa o rollback da _build_ para uma versão anterior, inserida pelo usuário. Deve-se informar como parâmetro a _build_ e a _tag_ (por exemplo, `my-project/my-app@beta 3.25.9-beta.17`);
- ***backup***: Gera um _backup_ da _build_. Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`;
- ***sanitize***: Executa o processo de higienização/otimização da _build_. Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`;
- ***info***: Exibe a versão de cada _build_ instanciada e outros comandos úteis do orquestrador que podem ser utilizados; e
- ***mail***: Testa as configurações de SMTP por meio do envio de um e-mail de teste. Deve-se informar como parâmetro uma lista de endereços separada por vírgula que receberão a mensagem (por exemplo, `jose.silva@embrapa.br,maria.santos@embrapa.br`).

Por exemplo, para **validar** todas as _builds_ configuradas em um servidor com **Docker Compose**, faríamos:

```bash
docker exec -it releaser io validate --all
```

Para fazer o ***rollback*** da _build_ `pasto-certo/pwa@release` para a versão `4.23.7-15` em um _cluster_ com **Docker Swarm**, faríamos:

```bash
docker exec -it $(docker ps -q -f name=releaser) io rollback \
  pasto-certo/pwa@release \
  4.23.7-15
```

## Atualização

Para atualizar a ferramenta **Releaser** para a última versão, acesse o diretório de configuração (`~/releaser`, no exemplo acima) e execute...

...no **Docker Compose**:

```bash
docker stop releaser && docker rm releaser

docker pull embrapa/releaser

cd ~/releaser

docker run --name releaser \
  -v $(pwd):/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped -d \
  embrapa/releaser

docker exec -it releaser io
```

...no **Docker Swarm**:

```bash
docker service rm releaser

docker pull embrapa/releaser

cd ~/releaser

docker service create --name releaser \
  --constraint=node.hostname==$(hostname) \
  --mount=type=bind,src=$(pwd),dst=/data \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  embrapa/releaser

docker exec -it $(docker ps -q -f name=releaser) io
```

## Solução de Problemas

A ferramenta **Releaser** é de código-aberto e está [disponível publicamente no GitHub](https://github.com/embrapa-io/releaser). Ela utiliza a distribuição [Alpine Linux](https://www.alpinelinux.org) como sistema operacional.

Para acessar o sistema de arquivos do _container_ da ferramenta, execute...

...no **Docker Compose**:

```bash
docker exec -it releaser bash
```

...no **Docker Swarm**:

```bash
docker exec -it $(docker ps -q -f name=releaser) bash
```

## Dicas

A seguir são listadas algumas dicas complementares para uso da ferramenta **Releaser**.

### Backup

Por padrão, os _boilerplates_ de aplicações da plataforma **Embrapa I/O** [implementam um serviço de _backup_]({{ site.baseurl }}/docs/boilerplate#cli:backup). Caso a aplicação instanciada pelo **Releaser** tenha este serviço na _stack_ de _containers_, pode-se habilitá-lo para ser executado diariamente (veja acima).

A dica é utilizar um único volume de _backup_ para todas as aplicações instanciadas no servidor. Com isso ficará mais fácil implementar um _script_ que copie todos os novos arquivos gerados para, p.e., um _storage_ remoto.

No exemplo abaixo criamos um volume denominado `backup` que será utilizado por todas as _builds_ instanciadas:

```bash
docker volume create \
  --driver local \
  --opt type=none \
  --opt device=/root/backup \
  --opt o=bind \
  backup
```

Basta agora informar este volume no momento de configurar as _environment variables_ no arquivo `builds.json`.

### Domínios (_virtual proxies_) e certificados SSL/TLS {#proxy}

Conforme mencionado acima, o **Releaser** implementa diversos _pipelines_ de _DevOps_ do **Embrapa I/O**, porém alguns processos importantes não estão contemplados. Por exemplo, uma vez que a aplicação tenha sido implantada pela ferramenta **Releaser** em seu servidor, ela estará acessível apenas pelas portas expostas pelo Docker. Faz-se necessário configurar os domínios e seus respectivos certificados SSL/TLS para publicar a aplicação de forma amigável.

Recomendamos duas formas de fazer isso, que estão detalhadas a seguir. Em ambos os casos, o primeiro passo para as configurações é a criação de registros do tipo `CNAME` no servidor DNS do domínio escolhido apontando para o host que estará fazendo o papel de _virtual proxy_.

Por exemplo, vamos supor que esteja sendo disponibilizada a _build_ `pasto-certo/pwa@beta` na VM `apps001.cnpgc.embrapa.br`, com um IP da intranet do _data center_. Neste exemplo a aplicação implantada neste _host_ foi exposta na porta **49152**. Vamos supor também que existe na mesma rede uma VM para fazer o papel do _virtual proxy_, cujo nome de _host_ é `proxy.cnpgc.embrapa.br` e que tem IP público. Queremos que esta aplicação fique acessível por meio do subdomínio `https://beta.pastocerto.com`. O primeiro passo será cadastrar no servidor DNS que gerencia o domínio `pastocerto.com` uma entrada do tipo `CNAME` de `beta.pastocerto.com` apontando para `proxy.cnpgc.embrapa.br`. Para cada serviço exposto, recomenda-se a criação de um subdomínio específico (por exemplo, `pgadmin.pastocerto.com`, `api.pastocerto.com`, `mcp.pastocerto.com`, etc).

Neste exemplo, há duas formas de configurar o `proxy.cnpgc.embrapa.br`:

#### Gestão automatizada pelo Nginx Proxy Manager (recomendado) {#npm}

O [Nginx Proxy Manager](https://nginxproxymanager.com) é uma interface web simples que facilita a configuração e o gerenciamento automatizado de proxies reversos, certificados SSL e redirecionamentos usando o servidor Nginx.

O **Embrapa I/O** já possui em seu catálogo de _boilerplates_ esta ferramenta, que pode ser adicionada como uma aplicação ao seu projeto. Desta forma, bastará instanciá-la na mesma VM das aplicações utilizando o **Releaser** (ou seja, como uma nova entrada no `builds.json`).

![Boilerplate do Nginx Proxy Manager]({{ site.baseurl }}/assets/img/releaser/20251031160841.png){: width="60%" .img-center }

Recomenda-se que sejam mantidas as portas padrão para esta aplicação, ou seja: `HTTP_PORT=80`, `HTTPS_PORT=443` e `ADMIN_PORT=81`. Assim, deve-se expor publicamente apenas as portas **80** e **443**, enquanto que a **81** (interface web de gestão) deve permanecer acessível apenas pela VPN (por medida de segurança).

Para o exemplo apresentado, o _virtual proxy_ que mapeia o subdomínio `https://beta.pastocerto.com` para `http://apps001.cnpgc.embrapa.br:49152` seria configurado da seguinte forma:

![Configuração do Proxy Host no NPM]({{ site.baseurl }}/assets/img/releaser/20251031163743.png)

> **Atenção!** Caso o **Nginx Proxy Manager** precise mapear os serviços rodando no Docker na mesma VM em que está instalado, referencie no campo "**Forward Hostname / IP**" o IP `172.17.0.1` (ou seja, o IP do _host_ a partir do _container_).

Repare que esta abordagem tem a grande vantagem de poder ser colocada em uma VM dedicada, com IP público, enquanto as aplicações web propriamente ditas podem ser instanciadas em _clusters_ na intranet do _data center_, poupando o uso de outros IPs públicos.

#### Gestão manual pelo Nginx {#nginx}

A dica aqui é o uso do servidor web [Nginx](https://nginx.org) associado com certificados gerados pelo [Let's Encrypt](https://letsencrypt.org), fazendo tudo de forma manual. Pode ser útil caso tenha poucos serviços para expor em uma ou duas aplicações apenas.

No servidor `proxy.cnpgc.embrapa.br` deverá estar instalado o servidor web Nginx (diretamente pelo gerenciador de pacotes do sistema operacional). Deverá também estar disponível o utilitário de linha de comando `certbot`, [conforme instruções de instalação para o sistema operacional do servidor](https://certbot.eff.org). Atendidos estes requisitos, podemos fazer:

```bash
certbot certonly --nginx --domains beta.pastocerto.com
```

Este comando irá gerar as chaves TLS necessárias. Em seguida, podemos configurar o subdomínio no Nginx adicionando um arquivo de configuração denominado `pasto-certo_pwa_beta.conf` (normalmente em `/etc/nginx/sites-available/`) com o seguinte conteúdo:

```conf
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  ssl_certificate /etc/letsencrypt/live/beta.pastocerto.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/beta.pastocerto.com/privkey.pem;
  ssl_protocols TLSv1.2 TLSv1.3;

  server_name beta.pastocerto.com;

  location / {
    resolver 127.0.0.1 [::1];
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
    proxy_ssl_session_reuse off;
    proxy_pass http://apps001.cnpgc.embrapa.br:49152;
  }
}
```

> **Atenção!** Caso o **Nginx** precise mapear os serviços rodando no Docker ma mesma VM em que está instalado, referencie no `proxy_pass` o IP `127.0.0.1` (ou seja, o IP do _localhost_).

Por fim, habilite esta configuração, teste-a e reinicie o servidor Nginx:

```bash
ln -s \
  /etc/nginx/sites-available/pasto-certo_pwa_beta.conf \
  /etc/nginx/sites-enabled/

nginx -t

/etc/init.d/nginx reload && /etc/init.d/nginx restart
```

### Instalação do Portainer {#portainer}

É recomendado que seja [instalado o Portainer](https://docs.portainer.io/start/install) em servidores que tenham o **Releaser** para auxiliar a equipe mantenedora em sua gestão:

- para [Docker Compose](https://docs.portainer.io/start/install/server/docker/linux);
- [Docker Swarm](https://docs.portainer.io/start/install/server/swarm/linux); ou
- [Kubernetes](https://docs.portainer.io/start/install/server/kubernetes/baremetal).

Por padrão, recomenda-se que este seja disponibilizado publicamente no HTTPS (porta 443) da URL (_hostname_) do servidor, com o HTTP (porta 80) redirecionando para o HTTPS.

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

Caso não tenha realizado a configuração de "domínios (_virtual proxies_) e certificados SSL/TLS" (apresentada na seção anterior), [instale o Nginx](https://www.linuxcapable.com/how-to-install-nginx-on-debian-linux/) e, para a configuração acima do Portainer, especifique um novo site como segue (troque `portainer.cnpxx.embrapa.br` pelo nome correto do seu _host_):

```
server {
  listen 80;
  listen [::]:80;

  server_name portainer.cnpxx.embrapa.br;

  return 301 https://portainer.cnpxx.embrapa.br;
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  ssl_certificate /etc/embrapa/wildcard/portainer.cnpxx.embrapa.br/fullchain.pem;
  ssl_certificate_key /etc/embrapa/wildcard/portainer.cnpxx.embrapa.br/privkey.pem;
  ssl_trusted_certificate /etc/embrapa/wildcard/portainer.cnpxx.embrapa.br/fullchain.pem;
  ssl_protocols TLSv1.2 TLSv1.3;

  server_name portainer.cnpxx.embrapa.br;

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

### Depuração de Serviços e Atualização das Imagens de Containers {#info}

Para forçar a atualização de imagens de containers de uma determinada aplicação, faça o seguinte:

```bash
docker exec -it releaser io info
```

O comando acima irá mostrar o _path_ para os diretórios dos repositórios clonados de todas as apps configuradas (das _tags_ em que o _deploy_ foi realizado). Para uma determinada app, você verá algo como:

```bash
To publica/camunda@release (version 0.25.9-2):
cd apps/publica/camunda/0.25.9-2
```

Dê o comando acima para acessar o diretório com a versão de _deploy_. Agora, pode-se utilizar múltiplos comandos para depurar a aplicação em execução, tal como:

```bash
env $(cat .env.io) docker compose ps
```

Que irá mostrar os serviços rodando, seu _status_ (p.e., "_healthy_") e outras informações relevantes.

Também é possível visualizar os _logs_:

```bash
env $(cat .env.io) docker compose logs -f app
```

Para forçar a atualização das imagens, faça:

```bash
env $(cat .env.io) docker compose pull --ignore-pull-failures --ignore-buildable
```

Este comando irá atualizar somente aquelas imagens que não foram 'buildadas' localmente. Para garantir que as novas versões de imagens sejam utilizadas, force um novo _deploy_. Para o exemplo acima o comando seria:

```bash
docker exec -it releaser io deploy publica/camunda@release --force
```

### Salvaguarda de Segredos e Senhas {#vault}

O arquivo de configuração do **Releaser** (`builds.json`) concentra diversos _passwords_, _hashes_, _secrets_ e valores de variáveis de ambiente que, se perdidos, podem gerar grande dor de cabeça. Assim, é aconselhado utilizar um serviço em nuvem do tipo _password_ ou _secrets management_ para gerência da configuração (controle de versões) destas configurações do **Releaser**, garantindo que estas informações não serão perdidas mesmo que o servidor (_bare metal_) seja irremediavelmente comprometido.

Por exemplo, para guardar seu arquivo com segurança, sem burocracia e de forma gratuita no [Bitwarden](https://bitwarden.com), crie uma conta no serviço e, na VM ou _cluster_ com o **Releaser**, faça:

```bash
# Instale via Snap (considerando que esteja no Ubuntu):
snap install bw

# Verifique a versão:
bw --version

# Faça login:
bw login
```

Ems seguida, crie um arquivo `/root/vault.sh` com o seguinte conteúdo:

```bash
#!/bin/sh

export BW_SESSION="$(bw unlock --raw)"

NOTES=$(cat /root/releaser/builds.json)

jq -n \
  --arg name "Releaser Backup $(hostname) $(date +%F)" \
  --arg notes "$NOTES" \
  '{type:2, secureNote:{type:0}, name:$name, notes:$notes}' \
  | bw encode | bw create item
```

Por fim, atribua permissões de execução: `chmod +x /root/vault.sh`.

Sempre que seu arquivo `builds.json` tiver novas configurações, é recomendado executar este script. Ele irá enviar para sua conta do **Bitwarden** a nova versão de forma protegida:

![Bitwarden]({{ site.baseurl }}/assets/img/releaser/20251217145652.png)
