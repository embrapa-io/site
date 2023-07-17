---
layout: page
title: Releaser
subtitle: Deploy de builds em clusters externos
---

A plataforma **Embrapa I/O** oferece um ecossistema de DevOps completo para desenvolvimento e entrega de aplicações. Por meio de uma rede de _clusters_ é possível fazer o _deploy_ automatizado de ativos em diferentes estágios de maturidade. Entretanto, algumas vezes é necessário que a entrega destes ativos se dê em ambientes externos à plataforma. Por exemplo, em projetos desenvolvidos em parceria com entes externos (tal como empresas privadas) pode ser acordado a disponibilização da solução em produção em uma nuvem do próprio parceiro ou terceirizada. Nestes casos, pode ser indesejado por parte deste parceiro, integrar esta nuvem à rede de _clusters_ do **Embrapa I/O**.

Além disso, atualmente a plataforma **Embrapa I/O** encontra-se em _Beta Release_, ou seja, ainda em fase de desenvolvimento. Apesar de utilizar ferramentas maduras em sua construção (tal como, o [GitLab](https://gitlab.com), o [Sentry](https://sentry.io) e o [Matomo](https://matomo.org)), **a disponibilização de aplicações em produção (_release_) por meio da plataforma é fortemente desencorajada**. Existem elementos críticos, tal como o roteamento de URLs (realizado pelo autômato _router_), que precisam ser amadurecidos. Assim, orienta-se que, neste momento, sejam realizados apenas o _deploy_ de aplicações em estágio de **testes internos** (_alpha_) e **testes externos** (_beta_) utilizando a rede de _clusters_ da plataforma.

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
docker service create --name registry --publish published=5000,target=5000 registry:2
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

O **DSN do Sentry**, [conforme já explicado]({{ site.baseurl }}/docs/bug), pode ser obtido a partir da [_dashboard_ do Embrapa I/O](https://dashboard.embrapa.io). Da mesma forma, o **ID do Matomo** também pode ser obtido por meio da _dashboard_, [conforme já visto]({{ site.baseurl }}/docs/analytics). O **_token_ do Matomo**, por sua vez, é gerado pelo Embrapa I/O automaticamente quando se utiliza os _pipelines_ de _deploy_ padrão da plataforma. Para gerá-lo manualmente, você precisará [acessar o Matomo](https://hit.embrapa.io) e autenticar-se com seu login e senha. Em seguida, acesse a "Aministração" (na _toolbar_) e vá em "Pessoal &raquo; Segurança". Na seção "**Tokens de autenticação**" adicione um novo _token_, inserindo o valor da _hash_ gerada no atributo correlato nas aplicações do `builds.json`.

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

- ***validate***: Executa o processo de validação da _build_ (_dry run_);
- ***deploy***: Valida, prepara (criando, p.e., a rede) e faz o _deploy_ da _build_ para a última versão;
- ***stop***: Derruba a _stack_ de _containers_ da _build_;
- ***restart***: Inicia ou re-inicia a _stack_ de _containers_ da _build_;
- ***rollback***: Executa o rollback da _build_ para uma versão anterior, inserida pelo usuário;
- ***backup***: Gera um _backup_ da _build_;
- ***sanitize***: Executa o processo de higienização/otimização da _build_; e
- ***info***: Exibe a versão de cada _build_ instanciada e outros comandos úteis do orquestrador que podem ser utilizados.

Por exemplo, para **validar** todas as _builds_ configuradas em um servidor com **Docker Compose**, faríamos:

```bash
docker exec -it releaser io validate --all
```

Para fazer o ***rollback*** da _build_ `pasto-certo/pwa@release` para a versão `4.23.7-15` em um _cluster_ com **Docker Swarm**, faríamos:

```bash
docker exec -it $(docker ps -q -f name=releaser) io rollback pasto-certo/pwa@release 4.23.7-15
```

## Atualização

Para atualizar a ferramenta **Releaser** para a última versão, acesse o diretório de configuração (`~/releaser`, no exemplo acima) e execute...

...no **Docker Compose**:

```bash
docker stop releaser && docker rm releaser

docker pull embrapa/releaser

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
