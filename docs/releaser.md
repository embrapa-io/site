---
layout: page
title: Releaser
subtitle: Deploy de builds em clusters externos
---

A plataforma **Embrapa I/O** oferece um ecossistema de DevOps completo para desenvolvimento e entrega de aplicações. Por meio de uma rede de _clusters_ é possível fazer o _deploy_ automatizado de ativos em diferentes estágios de maturidade. Entretanto, algumas vezes é necessário que a entrega destes ativos se dê em ambientes externos à plataforma. Por exemplo, em projetos desenvolvidos em parceria com entes externos (tal como empresas privadas) pode ser acordado a disponibilização da solução em produção em uma nuvem do próprio parceiro ou terceirizada. Nestes casos, pode ser indesejado por parte deste parceiro, integrar esta nuvem à rede de _clusters_ do **Embrapa I/O**.

Além disso, todos os _clusters_ do catálogo da plataforma são de **uso compartilhado**. Isto significa que os recursos de hardware dos servidores (disco, memória, unidades de processamento, etc) não podem ser provisionados por aplicação, sendo gerenciados exclusivamente pelos orquestradores. Para disponibilização de soluções em produção, principalmente aquelas de alta demanda, esta especificidade será um risco.

Por fim, atualmente a plataforma **Embrapa I/O** encontra-se em _Beta Release_, ou seja, ainda em fase de desenvolvimento. Apesar de utilizar ferramentas maduras em sua construção (tal como, o [GitLab](https://gitlab.com), o [Sentry](https://sentry.io) e o [Matomo](https://matomo.org)), **a disponibilização de aplicações em produção (_release_) por meio da plataforma é fortemente desencorajada**. Existem elementos críticos, tal como o roteamento de URLs (realizado pelo autômato _router_), que precisam ser amadurecidos. Assim, orienta-se que, neste momento, sejam realizados apenas o _deploy_ de aplicações em estágio de **testes internos** (_alpha_) e **testes externos** (_beta_) utilizando a rede de _clusters_ da plataforma.

A orientação completa sobre onde cada estágio deve ser instanciado, conforme o nível de serviço da infraestrutura, está no capítulo sobre [hospedagem de aplicações]({{ site.baseurl }}/docs/delivery).

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
  --restart always -d --sig-proxy=false \
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

## Configuração do _plugin_ para _logging_ {#loki}

O **Embrapa I/O** utiliza o [Grafana Loki](https://grafana.com/docs/loki/latest/) para permitir a coleta e análise de _log_ de todos os containers instanciados. Esta funcionalidade funciona tanto para as _builds_ instanciadas vias _clusters_ compartilhados quanto via **Releaser**. Para ativá-la, é necessário [instalar o _plugin_ do Loki](https://grafana.com/docs/loki/latest/send-data/docker-driver/) de forma que toda a saída dos containers (no _stdout_) seja enviada para o [Grafana](https://log.embrapa.io).

Para instalar o _plugin_, execute:

```bash
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
```

Verifique a instalação utilizando o comando `docker plugin ls`.

Uma vez que o plugin esteja instalado no Docker, edite o arquivo `/etc/docker/daemon.json` inserindo o seguinte conteúdo:

{% raw %}
```json
{
  "debug": false,
  "live-restore": true,
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "https://<username>:<password>@loki.embrapa.io/loki/api/v1/push",
    "loki-external-labels": "container_name={{.Name}},job=docker",
    "loki-batch-size": "1048576",
    "loki-batch-wait": "1s",
    "loki-retries": "5",
    "loki-min-backoff": "500ms",
    "loki-max-backoff": "5s",
    "loki-timeout": "10s",
    "mode": "non-blocking",
    "max-buffer-size": "4m",
    "keep-file": "false",
    "max-size": "10m",
    "max-file": "3"
  }
}
```
{% endraw %}

O parâmetro `mode` com valor `non-blocking` desacopla os containers do envio de _logs_: quando o _buffer_ (de tamanho `max-buffer-size`) enche — por exemplo, se o Loki estiver lento ou indisponível —, as mensagens excedentes são **descartadas** ao invés de bloquear o container. Isso evita que eventuais problemas no _logging_ afetem a execução das aplicações.

> **Atenção!** Os valores de `username` e `password` para a linha acima devem ser solicitados à equipe da plataforma por [e-mail](mailto:io@embrapa.br) ou pela [sala Arquitetos de Soluções no Google Chat](https://chat.google.com/room/AAAA853zctw?cls=11).

O _driver_ já adiciona automaticamente o rótulo `host` (preenchido com o _hostname_ do servidor) a todos os _logs_, portanto não é necessário informá-lo manualmente. Garanta apenas que o _hostname_ do sistema operacional reflita o nome desejado — se necessário, ajuste-o com `hostnamectl set-hostname production.cnpgc.embrapa.br`. O rótulo `container_name={% raw %}{{.Name}}{% endraw %}` é mantido explicitamente porque, ao informar um valor para `loki-external-labels`, seu padrão seria sobrescrito.

Antes de reiniciar o serviço, valide a sintaxe do arquivo de configuração:

```bash
dockerd --validate --config-file /etc/docker/daemon.json
```

Por fim, faça: `systemctl restart docker`. É possível verificar se há algum erro utilizando o comando `journalctl -u docker | grep loki`. Se configurado com sucesso, deverá ser visto na saída deste último comando algo como "_Using default logging driver loki_".

## Configuração Inicial do Releaser {#setup}

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
BACKUP_DIR=/root/backup
```

Além destas, o `.env` aceita variáveis opcionais, que não são perguntadas pelo assistente. Por exemplo, a partir da versão `1.26.10-12`, a rotação dos _backups_ no volume (`RETENTION`, veja [Rotação de _backups_](#cleaner)) e a [cópia em nuvem](#cloud) para um _bucket_ S3 (`S3_*`):

```bash
# Rotação dos backups no volume (cleaner): D/S/M/A, padrão 7/4/3/1
RETENTION=7/4/3/1

# Cópia em nuvem (io cloud): bucket S3 compatível
S3_ENDPOINT=https://0123456789abcdef0123456789abcdef.r2.cloudflarestorage.com
S3_BUCKET=releaser-backups
S3_ACCESS_KEY=0f1e2d3c4b5a69788796a5b4c3d2e1f0
S3_SECRET_KEY=exemplo-de-segredo-nao-use-este-valor-0123456789abcdef
S3_REGION=auto
S3_RETENTION=30/8/12/3

# Imagem do container auxiliar que acessa os volumes de backup, se o Releaser
# não conseguir descobrir a própria (ex.: container com --hostname trocado)
# IO_RELEASER_IMAGE=embrapa/releaser:1.26.10-12
```

Tenha em mente que valor de `SERVER` será injetado no momento do _deploy_ das _builds_ como a variável de ambiente `IO_SERVER`.

A variável `BACKUP_DIR` (a partir da versão `1.26.10-13`) é a pasta do servidor onde ficam os _backups_ de **todas** as _builds_ (padrão `/root/backup`). O assistente pergunta por ela, e é fácil listar, copiar e restaurar os arquivos dali: os de cada _build_ começam com `projeto_app_estágio_`. Mantenha-a **fora** do diretório do Releaser e, se o servidor tiver um, num disco de dados. Para uma instalação existente, a pasta pode ser alterada em `io cloud --setup` (ou editando o `.env`). O [`io install`](#install) usa esse valor para orientar a criação do volume de _backup_ de cada _build_.

O `GITLAB_TOKEN` deve ser obtido por meio da interface do [GitLab do Embrapa I/O](https://git.embrapa.io). Para isso, acesse seu _profile_ e vá na opção [Personal Access Tokens](https://git.embrapa.io/-/profile/personal_access_tokens). Gere um novo _token_ selecionando o _scope_ `read_api`.

> **Atenção!** O _token_ é usado para localizar os repositórios das aplicações e suas _tags_. Os catálogos da plataforma (_boilerplates_, _clusters_ e orquestradores) **não** dependem dele: a partir da versão `1.26.9-7` o Releaser os obtém diretamente do _backend_ do Embrapa I/O (`https://core.embrapa.io/metadata/...`), sem autenticação, com o GitLab apenas como contingência. Se a sua instalação usa um _backend_ próprio, informe a URL na variável opcional `IO_API_URL` do `.env`. Versões anteriores à `1.26.9-7` liam esses catálogos do repositório `io/boilerplate/metadata` no GitLab e falham com `Repository 'io/boilerplate/metadata' not found!` quando o _token_ não o enxerga — atualize a imagem ([veja como](#update)).

![Access Token no GitLab]({{ site.baseurl }}/assets/img/releaser/20230717155813.png)

> **Atenção!** O usuário que irá gerar o **Access Token** deverá ter acesso a todos os projetos que terão apps instanciadas pela ferramenta **Releaser** neste servidor.

As variáveis com o prefixo `SMTP` são necessárias para configuração do envio de e-mails. A ferramenta **Releaser**, quando rodando no modo _daemon_, envia um e-mail de _log_ sempre que ocorre a atualização de uma aplicação para uma nova versão (ou em caso de erro). Conforme será visto abaixo, pode-se configurar para cada _build_ o time que irá receber estes e-mails. Além disso, deve-se configurar um e-mail padrão de _log_ (variável `LOG_MAIL`) que também recebe todos os e-mails enviados.

O envio foi pensado para funcionar com o SMTP que houver no ambiente (relay do Google Workspace, SMTP da unidade, Gmail com senha de app etc.). A partir da versão `1.26.9-8`:

- `SMTP_SECURE=yes` exige certificado válido do servidor; com `no`, aceita certificado autoassinado e TLS legado (servidores internos antigos). O TLS em si é negociado automaticamente: implícito na porta 465 e `STARTTLS` nas demais, quando o servidor oferece;
- `SMTP_HOST` aceita uma lista separada por vírgulas (por exemplo, `smtp-relay.gmail.com,smtp.cnpgc.embrapa.br`), tentada em ordem. Se a conexão não sai pela porta de `SMTP_PORT` (porta bloqueada no _firewall_ é o caso mais comum), o Releaser tenta as outras portas de submissão: 587 e 465 e, só quando não há usuário e senha, também a 25;
- `LOG_MAIL` também aceita uma lista separada por vírgulas. Endereços inválidos no `LOG_MAIL` ou no `team` das _builds_ são ignorados, sem impedir o envio aos demais;
- O servidor se apresenta no `EHLO` pelo nome em `SERVER`. Se `SERVER` não for um nome completo (por exemplo, `localhost` ou um IP), usa o domínio de `SMTP_FROM`. Para definir outro nome, use a variável opcional `SMTP_HELO`. O `smtp-relay.gmail.com` recusa o `EHLO` com IP (`421 4.7.0 Try again later, closing connection. (EHLO)`), que era o padrão nas versões anteriores;
- Cada tentativa espera no máximo 15 segundos, valor que pode ser alterado na variável opcional `SMTP_TIMEOUT`;
- Quando nenhuma tentativa funciona, o e-mail não se perde: fica numa fila no diretório `.mail` do diretório de configuração e é reenviado nas execuções seguintes do _daemon_, com uma nota indicando o horário em que foi gerado. A fila guarda no máximo 100 mensagens por até 7 dias. Na mesma execução, depois da primeira falha, os e-mails seguintes vão direto para a fila, sem novas tentativas.

Para verificar a configuração, use o comando `mail` (veja abaixo). Ele mostra o remetente, os destinatários, o nome usado no `EHLO`, a resolução de DNS de cada servidor e cada tentativa de conexão, e termina com `SUCCESS` ou `ERROR`. Quando o envio funciona, ele também esvazia a fila.

Além disso, será gerado um par de chaves SSH, caso não exista. Estas chaves são necessárias para a sincronização do código-fonte das aplicações. Você deve acessar novamente seu _profile_ no GitLab da plataforma e ir na opção [SSH Keys](https://git.embrapa.io/-/profile/keys). Cadastre então o conteúdo da chave pública gerada (arquivo `ssh.pub`).

> **Atenção!** No campo "**Usage type**", escolha **Authentication**. O **Releaser** usa a chave apenas para clonar e atualizar o código-fonte das aplicações, nunca para assinar _commits_. Restrita à autenticação, uma eventual cópia da chave não serve para assinar _commits_ em seu nome. No título, identifique o servidor (por exemplo, `Releaser apps001.cnpgc.embrapa.br`), para saber depois qual chave revogar. A data de expiração é opcional; se definir uma, anote-a: quando a chave vencer, o **Releaser** deixa de clonar as novas versões e os _deploys_ automáticos param, com erro de clone no e-mail de _log_.

> **Atenção!** Por padrão, o código-fonte é clonado por SSH, na **porta 22** do `git.embrapa.io`. Se a rede do servidor bloquear essa porta na saída, use a variável opcional `GITLAB_SSH` para clonar por HTTPS, na porta 443. Veja como em [Porta 22 bloqueada](#https).

![SSH Key no GitLab]({{ site.baseurl }}/assets/img/releaser/20230717164051.png)

Por fim, você deverá configurar as [_builds_ das aplicações]({{ site.baseurl }}/docs/introduction#build) que serão gerenciadas pela ferramenta **Releaser**. Cada _build_ é **um arquivo JSON** no diretório `builds/` do volume compartilhado com o _container_, com o nome `<projeto>_<app>_<estágio>.json`. A partir da versão 1.26.10-12, o assistente da primeira execução não pede mais as _builds_: ao terminar, ele indica o comando [`io install`](#install), que monta o arquivo completo de forma guiada, buscando na plataforma a equipe, o DSN do **Sentry**, o ID do **Matomo** e as variáveis. Qualquer comando executado logo depois de subir o _container_ (por exemplo, `io install` ou `io cli`) passa antes pelo assistente, se ele ainda não tiver sido feito, e segue em seguida. Por exemplo, o arquivo `builds/pasto-certo_pwa_release.json`:

```json
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
    "sanitize": false,
    "cleaner": false,
    "cloud": false
  },
  "stats": {
    "version": true,
    "cve": true,
    "health": true
  },
  "env": {
    "PORT": "49152",
    "VUE_APP_API": "https://test.cnpgc.embrapa.br/pasto-certo/api",
    "VUE_APP_TOKEN": "sPOve29ZnLmtNAiLRLjh5EzKrS2Unnno",
    "VUE_APP_ANALYTICS": "UA-123456789-0"
  }
}
```

Outras _builds_ do mesmo servidor ficam em outros arquivos (`builds/andro-certo_api_beta.json` etc.). O nome do arquivo precisa bater com `project`, `app` e `stage` do conteúdo, senão o Releaser recusa; e a mesma _build_ em dois arquivos é erro, não há precedência silenciosa.

> **Atenção!** Para **desativar** uma _build_ sem perder a configuração, basta renomear o arquivo para outra extensão (por exemplo, `pasto-certo_pwa_release.json.bkp`): só arquivos `.json` contam. O Releaser deixa de gerir a _build_ e de reportá-la à plataforma, mas os _containers_ continuam como estão; para derrubá-los, use `io stop` antes de renomear. O `io info` lista as _builds_ desativadas.

Instalações antigas, com todas as _builds_ num único `builds.json`, **continuam funcionando**. O comando `io split` migra o arquivo para `builds/*.json` e guarda o original como `builds.json.bkp`; o `io install` oferece essa migração quando encontra o formato antigo.

O atributo `team` lista os e-mails que irão receber os _logs_ do processo de _deploy_ correlatos a cada _build_. O atributo _auto_ permite ativar os serviços que serão executados de forma periódica, sendo eles:

- ***deploy***: Executa a cada **15 minutos** a busca por novas versões, ou seja, _tags_ na _branch_ do estágio da _build_. Caso encontre, executa o processo de _deploy_ da nova _tag_ e envia um e-mail de _log_ (informando o sucesso ou eventuais erros no procedimento);

- ***backup***: Executa **diariamente** o serviço de _backup_ da _stack_ de _containers_ da _build_. É fundamental que o [serviço de _backup_]({{ site.baseurl }}/docs/backup) esteja corretamente configurado na aplicação. Os arquivos de backup serão salvos no volume externo de _backup_;

- ***sanitize***: Executa **mensalmente** o serviço de sanitização, caso esteja corretamenta configurado na _stack_ de _containers_ da _build_. Mais informações sobre os processos de higienização/otimização dos _containers_ podem ser encontradas [no tutorial de criação de _boilerplates_]({{ site.baseurl }}/docs/boilerplate).;

- ***cleaner***: Executa **diariamente** (logo após o _backup_) a **rotação dos arquivos de _backup_** da _build_, mantendo por padrão os últimos **7 diários, 4 semanais, 3 mensais e 1 anual** (a partir da versão `1.26.10-12`; antes, sem o anual) e apagando o restante. Aceita `false` (padrão, quando ausente), `true` ou `"undated"` — este último inclui na rotação, pela data de modificação, arquivos **sem data no nome** (caso de aplicações que não seguem o [padrão de nome do arquivo de _backup_]({{ site.baseurl }}/docs/boilerplate#cli:backup)). Detalhes na seção [Rotação de _backups_](#cleaner); e

- ***cloud*** (a partir da versão `1.26.10-12`): Executa **diariamente** (logo após o _cleaner_) a **cópia dos arquivos de _backup_** da _build_ para um _bucket_ S3 configurado no `.env`, com rotação própria no _bucket_. Aceita `false` (padrão, quando ausente), `true` ou `"undated"` (que inclui na rotação do _bucket_ os arquivos sem data no nome, como no _cleaner_). Detalhes na seção [Cópia em nuvem (S3)](#cloud).

O atributo `stats` define o que a _build_ **reporta à plataforma** (ver [a seção correspondente](#report)): a versão implantada (`version`), as vulnerabilidades das imagens em execução (`cve`) e a saúde dos serviços (`health`). Os três valem `true` por padrão, inclusive quando o atributo está ausente; `"stats": false` desliga os três. O caso típico de desligar é o `cve` num servidor pequeno ou sem acesso ao `ghcr.io`, de onde o Trivy baixa o banco de vulnerabilidades.

O **DSN do Sentry**, [conforme já explicado]({{ site.baseurl }}/docs/bug), pode ser obtido a partir da [_dashboard_ do Embrapa I/O](https://dashboard.embrapa.io). Da mesma forma, o **ID do Matomo** também pode ser obtido por meio da _dashboard_, [conforme já visto anteriormente]({{ site.baseurl }}/docs/analytics). O **_token_ do Matomo**, por sua vez, é gerado pelo **Embrapa I/O** automaticamente quando se utiliza os _pipelines_ de _deploy_ padrão da plataforma. Para gerá-lo manualmente, você precisará [acessar o Matomo](https://hit.embrapa.io) e autenticar-se com seu login e senha. Em seguida, acesse a "Aministração" (na _toolbar_) e vá em "Pessoal &raquo; Segurança". Na seção "**Tokens de autenticação**" adicione um novo _token_, inserindo o valor da _hash_ gerada no atributo correlato nas aplicações do `builds.json`.

![Tokens de autenticação no Matomo]({{ site.baseurl }}/assets/img/releaser/20230717162755.png)

> **Atenção!** O usuário que irá gerar o ***token*** do Matomo deverá ter acesso aos projetos em que esta _hash_ for informada. Você pode gerar um único _token_ para atender a todos os projetos no Releaser dos quais participa como membro da equipe.

No atributo `env` devem ser listadas as variáveis de ambiente que serão injetadas no momento do _deploy_. Mais especificamente, será gerado um arquivo `.env` na raiz do diretório clonado da aplicação, de forma idêntica à utilizada para instanciar a aplicação em ambiente local de desenvolvimento.

Os arquivos de `builds/` são relidos a cada execução: ao alterar o `env` de uma _build_ já implantada, basta rodar `io deploy proj/app@stage --force` para que o clone seja refeito, o `.env` regenerado e os _containers_ recriados com os novos valores, sem precisar de uma nova _tag_. Os arquivos gerados pelo Releaser (`.env`, `.env.io` e `.env.sh`) são a **única** fonte de variáveis para o `docker compose`: as variáveis do próprio Releaser (`SMTP_HOST`, `SMTP_PORT`, `SERVER` etc., do arquivo `.env` do diretório de configuração) nunca chegam aos _containers_ das aplicações, mesmo que a aplicação declare variáveis com o mesmo nome.

Pronto! Caso tenha seguido corretamente os passos acima, a ferramenta estará pronta para ser executada.

## Utilização {#usage}

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
- ***deploy***: Valida, prepara (criando, p.e., a rede) e faz o _deploy_ da _build_ para a última versão. Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`. Também aceita o parâmetro `--force`, que irá forçar o _re-deploy_ mesmo que não exista uma nova _tag_ (relendo o `builds.json` e regenerando o `.env` — é a forma de aplicar mudanças de variáveis de ambiente);
- ***stop***: Derruba a _stack_ de _containers_ da _build_. Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`. Com `--down` (a partir da versão `1.26.10-5`), remove os _containers_ em vez de apenas pará-los (`docker compose down`), **mantendo os volumes**: útil para recriar a _stack_ do zero, por exemplo ao trocar a porta ou a rede (`io stop proj/app@release --down` e, em seguida, `io deploy proj/app@release --force`);
- ***restart***: Inicia ou re-inicia a _stack_ de _containers_ da _build_. Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`. Com `--upgrade` (ou `--update`, a partir da versão `1.26.10-10`), **renova as imagens** antes de reiniciar, do mesmo jeito que a opção "Atualizar imagens" do _restart_ na _dashboard_ faz nos _clusters_ da plataforma: baixa a versão mais recente das imagens sem versão fixada (`docker compose pull`), reconstrói os serviços com `build:` sobre a imagem-base renovada (`docker compose build --pull`) e recria os _containers_. Em seguida, varre as imagens com o Trivy e reporta as CVEs à plataforma, para que o [alerta de CVEs críticos]({{ site.baseurl }}/docs/cve) reconheça a correção no mesmo ciclo. É a forma de aplicar correções de segurança em aplicações de prateleira (n8n, WordPress etc.), que raramente recebem uma _tag_ nova: `io restart proj/app@release --upgrade`;
- ***rollback***: Executa o rollback da _build_ para uma versão anterior, inserida pelo usuário. Deve-se informar como parâmetro a _build_ e a _tag_ (por exemplo, `my-project/my-app@beta 3.25.9-beta.17`);
- ***backup***: Gera um _backup_ da _build_ executando o serviço `backup` do `docker-compose.yaml`. Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`. _Builds_ sem esse serviço (caso das aplicações de _frontend_) são ignoradas com um aviso, não com erro;
- ***sanitize***: Executa o processo de higienização/otimização da _build_ (serviço `sanitize`). Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`. _Builds_ sem esse serviço são ignoradas com um aviso;
- ***cleaner***: Rotaciona os arquivos do volume de _backup_ da _build_ (mantém, por padrão, os últimos 7 diários, 4 semanais, 3 mensais e 1 anual; ajustável pela variável `RETENTION` do `.env`). Aceita como parâmetro uma lista de _builds_ separadas por vírgula ou `--all`, e o parâmetro `--dry-run`, que apenas mostra o que seria mantido e apagado. Ao final, exibe um resumo por _build_ com a quantidade de arquivos e o espaço ocupado antes e depois da rotação. _Builds_ sem volume de _backup_ são ignoradas com um aviso;
- ***cloud*** (a partir da versão `1.26.10-12`): Copia os arquivos do volume de _backup_ da _build_ para um _bucket_ S3 e os rotaciona lá. Aceita uma lista de _builds_ separadas por vírgula ou `--all`, e os parâmetros `--dry-run` (apenas mostra o que seria enviado e apagado) e `--list` (lista o conteúdo do _bucket_ para a _build_). O _daemon_ executa **diariamente**, após o _cleaner_, para as _builds_ com `auto.cloud` ligado. Detalhes na seção [Cópia em nuvem (S3)](#cloud);
- ***health***: Inspeciona os _containers_ de cada _build_ neste servidor (estado, _healthcheck_, tamanho, data de criação) e reporta a saúde dos serviços à plataforma. Aceita uma lista de _builds_ ou `--all`. O _daemon_ executa a cada **minuto**, em silêncio;
- ***cve***: Varre as imagens em execução de cada _build_ com o [Trivy](https://trivy.dev) (só vulnerabilidades `HIGH` e `CRITICAL`) e reporta o resultado à plataforma. Aceita uma lista de _builds_ ou `--all`. O _daemon_ executa a cada **hora**, num minuto sorteado por servidor. Cada imagem distinta é varrida uma vez por rodada; se alguma varredura falhar, a _build_ fica de fora do relato e a plataforma mantém o resultado anterior;
- ***install***: [Configuração guiada](#install) de uma _build_ nova: escolhe projeto, _app_ e estágio por menus, busca na plataforma a equipe, o DSN do Sentry, o site e o _token_ do Matomo e as variáveis do `.embrapa/settings.json`, gera os valores por tipo e grava o arquivo em `builds/`. Aceita a _build_ como parâmetro (`proj/app@stage`) e `--yes` (sem perguntas, com os valores padrão);
- ***split***: Migra o `builds.json` antigo para um arquivo por _build_ em `builds/`, guardando o original como `builds.json.bkp`;
- ***info***: Exibe, por _build_, o arquivo de configuração, o resultado do último relato de cada sinal à plataforma (versão, saúde e CVEs), a versão instanciada e outros comandos úteis do orquestrador; lista também as _builds_ desativadas. A partir da versão `1.26.10-12`, mostra ainda o resultado da última [cópia em nuvem](#cloud) de cada _build_: `ok` (com data e hora, arquivos e _bytes_ enviados e apagados e o tamanho no _bucket_), `FAILED` (com o motivo e a data do último sucesso), `never run`, `disabled (auto.cloud = false)` ou `bucket not configured`. Por exemplo: `Cloud copy (S3): ok at 2026-10-23T03:10:42-03:00 (1 uploaded, 143,2 MB; 1 deleted; 15 file(s), 2,1 GB in the bucket)`;
- ***cli*** (a partir da versão `1.26.10-12`): Instala (ou atualiza) o comando `io` no servidor, em `/usr/local/bin/io`. Aceita `--print` (só imprime o _script_), `--uninstall` (remove) e `--yes` (não pergunta). Veja [O comando `io` no servidor](#cli);
- ***upgrade*** (a partir da versão `1.26.10-14`): Atualiza o próprio Releaser para a versão mais nova publicada (ou `--to VERSÃO`), com volta automática à versão anterior se a nova falhar. Aceita `--dry-run` (só mostra) e `--yes` (não pergunta). Veja [Atualização](#update);
- ***mail***: Testa as configurações de SMTP por meio do envio de um e-mail de teste, detalhando cada tentativa (servidor, porta e motivo da falha). Deve-se informar como parâmetro uma lista de endereços separada por vírgula que receberão a mensagem (por exemplo, `jose.silva@embrapa.br,maria.santos@embrapa.br`). Se o envio funcionar, os e-mails que estavam na fila também são enviados; e
- ***check*** (a partir da versão `1.26.10-8`): Testa o acesso ao GitLab pelos dois caminhos de que o _deploy_ depende: a API, com o `GITLAB_TOKEN` (alcance, tempo de resposta, validade, escopos e se o _token_ venceu ou foi revogado), e o clone, pela chave SSH ou pela URL de `GITLAB_SSH` (veja [clone por HTTPS](#https)). Ao final, uma linha de resumo que começa com `Success!` (em verde), `Warning!` (em amarelo) ou `Error!` (em vermelho), seguida do resultado da API, do _token_ e do clone. A mesma linha aparece no fim do menu, quando se executa `io` sem comando. O _daemon_ executa o teste **uma vez por dia** e envia e-mail ao `LOG_MAIL` quando o _token_ venceu, foi revogado, não tem o _scope_ `read_api`, vence em 14 dias ou em 7 dias ou menos (neste caso, diariamente), ou quando o clone é recusado. Uma indisponibilidade momentânea do GitLab não gera e-mail. A partir da versão `1.26.10-12`, quando alguma variável `S3_*` está no `.env`, o teste inclui também a listagem do _bucket_ da [cópia em nuvem](#cloud) (com _timeout_ de 5 segundos) e a resume na mesma linha. O _daemon_ envia e-mail ao `LOG_MAIL` quando o acesso ao _bucket_ falha (no máximo um por dia). Configuração incompleta, _bucket_ inexistente, chave recusada ou provedor inacessível aparecem como `ERROR`. O teste do _bucket_ não entra na linha de resumo do menu do `io` (sem comando), que continua testando só o GitLab. Por exemplo:

```
INFO > S3 bucket 'releaser-backups' at https://0123456789abcdef0123456789abcdef.r2.cloudflarestorage.com (S3_ENDPOINT)...
SUCCESS > S3: ok (bucket releaser-backups, 184 ms)

Success! API ok (95 ms) | Token ok, expires on 2027-03-01, in 129 days | SSH: ok as @releaser (310 ms) | S3 ok (bucket releaser-backups, 184 ms)
```

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

## Configuração guiada de uma _build_ {#install}

O comando `io install` monta o arquivo de uma _build_ nova sem que você precise copiar nada à mão:

```bash
docker exec -it releaser io install
```

1. Lista os **projetos** da plataforma a que o dono do `GITLAB_TOKEN` tem acesso (pelo menos _Developer_), depois as **_apps_** do projeto escolhido e, por fim, o **estágio**. Também aceita a _build_ direto como parâmetro: `io install pasto-certo/pwa@release`.
2. Pergunta à plataforma o que só ela sabe sobre essa _build_: a **equipe** (que vira o `team`), o **DSN do Sentry**, o **site e o _token_ do Matomo** (criados na hora, se ainda não existirem) e as **variáveis** do `.embrapa/settings.json` da _tag_ mais recente do estágio. Se o estágio já for implantado pela própria plataforma num _cluster_, o comando para: um estágio é da plataforma **ou** do Releaser, nunca dos dois.
3. Gera os valores por tipo de variável: `PASSWORD` e `SECRET` aleatórios (ou digitados, se você preferir), `PORT` com a **próxima porta livre** a partir da base informada (conferindo as portas em uso no servidor e as já reservadas em outros arquivos de `builds/`), `VOLUME` com o sufixo padrão e `TEXT` com o valor padrão do _boilerplate_, sempre com a chance de alterar.
4. Grava `builds/<projeto>_<app>_<estágio>.json` com `auto` e `stats` nos valores padrão e mostra o comando do primeiro _deploy_.

Com `--yes` não há perguntas: valem os padrões (senhas aleatórias, próxima porta a partir de `49152`, valores do _boilerplate_). Os **volumes externos** citados pela aplicação ainda precisam ser criados por você antes do primeiro _deploy_ (`docker volume create <projeto>_<app>_<estágio>_<nome>`); o comando mostra **só os que ainda não existem** no servidor. Para o volume de _backup_ (`<projeto>_<app>_<estágio>_backup`, padrão dos _boilerplates_), a partir da versão `1.26.10-13` ele orienta a criá-lo ligado à pasta `BACKUP_DIR` (veja a [configuração inicial](#setup)):

```bash
mkdir -p /root/backup
docker volume create --driver local --opt type=none --opt o=bind \
  --opt device=/root/backup projeto_app_estagio_backup
```

A pasta é **compartilhada por todas as _builds_** do servidor: o `cleaner` e o `cloud` só tocam nos arquivos com o prefixo de cada _build_. Se a aplicação não tem o serviço `backup`, o volume não é necessário. O `io install` não altera _builds_ já configuradas: edite o arquivo diretamente ou remova-o antes.

## O comando `io` no servidor {#cli}

Todo uso do Releaser passa pelo `io` dentro do _container_: `docker exec -it releaser io backup --all`. A partir da versão `1.26.10-12`, o próprio Releaser instala no servidor um comando `io` que faz esse `docker exec` por você:

```bash
docker exec -it releaser io cli
```

Ele mostra o destino (`/usr/local/bin/io`), pede confirmação (`--yes` pula) e grava o _script_. A partir daí, direto no terminal do servidor, no `cron` ou em _scripts_:

```bash
io                       # o menu
io backup --all && io cloud --all
io cloud meu-projeto/api@release --list
```

- O comando é um _script_ `sh` pequeno que roda `docker exec [-it | -i] releaser io "$@"`: usa `-it` só quando a entrada e a saída são um terminal (senão `-i`, para funcionar em `cron`, _pipes_ e `&&`), repassa os argumentos sem reinterpretá-los e devolve o código de saída do `io` do _container_.
- Procura o _container_ pelo nome `releaser` (ou pelo que estiver em `RELEASER_CONTAINER`). Se não houver, procura pelo rótulo do serviço do Swarm ou pela imagem `embrapa/releaser`, e falha com mensagem clara se achar nenhum ou mais de um. Também falha com mensagem clara se o Docker não responder ou se o usuário não tiver permissão (fora do grupo `docker`): use `sudo io ...` ou acrescente o usuário ao grupo.
- Um `/usr/local/bin/io` que **não** tenha sido gerado pelo Releaser nunca é sobrescrito nem removido. `io cli --uninstall` remove o comando, só se for do Releaser.
- **Atualização automática:** quando a imagem do Releaser é atualizada, a primeira chamada pelo `io` do servidor regrava o _script_ sem perguntar e avisa numa linha. Chamadas diretas (`docker exec releaser io ...`), o `cron` interno e o _daemon_ não tentam atualizar nada.
- Se a gravação falhar (Docker instalado via _snap_, com AppArmor; Docker _rootless_; `/usr/local/bin` somente leitura), o Releaser não insiste: imprime a alternativa manual, que também serve para instalar o comando pela primeira vez:

```bash
docker exec releaser io cli --print | sudo tee /usr/local/bin/io > /dev/null && sudo chmod +x /usr/local/bin/io
```

Nada no diretório `/data` do Releaser muda com o `io cli`.

> **Atenção!** Hoje os comandos do Releaser terminam com código 0 mesmo quando uma _build_ falha (`ERROR >`) ou a execução é interrompida (`CRITICAL >`). Por isso, `io backup --all && io cloud --all` segue para o `cloud` mesmo depois de uma falha no `backup`. Essa mudança está proposta para uma versão futura, porque altera o comportamento de todos os comandos.

## O que o Releaser reporta à plataforma {#report}

Desde a versão `1.26.10-2`, o Releaser informa ao **Embrapa I/O** o que sabe sobre cada _build_ que implanta, e a _dashboard_ passa a mostrar esses estágios como mostra os dos _clusters_ da plataforma. **Basta atualizar a imagem** ([veja como](#update)): não há nada para configurar. No _card_ do projeto, a **versão** de um estágio implantado pelo Releaser aparece em **laranja, com o ícone de servidor**, enquanto os estágios dos _clusters_ da plataforma seguem em ciano, com o foguete. Passe o mouse sobre o chip para ver em qual servidor a _build_ está e quando foi o último contato:

![Card com os estágios release e beta vindos do Releaser e o alpha na plataforma]({{ site.baseurl }}/assets/img/releaser/20261015091339.png){: width="60%" .img-center }

O **coração** de cada estágio passa a considerar tanto a **saúde dos serviços** (_healthcheck_ e estado dos _containers_) quanto as **CVEs** das imagens: vermelho com serviço parado ou CVE crítica, laranja com serviço iniciando ou CVE alta. O _Health Check_ mostra os serviços, a origem (servidor e versão do Releaser), a hora do último contato e as vulnerabilidades encontradas:

![Health Check de uma build implantada pelo Releaser]({{ site.baseurl }}/assets/img/releaser/20261015091353.png){: width="80%" .img-center }

![CVEs de uma build implantada pelo Releaser]({{ site.baseurl }}/assets/img/releaser/20261015091420.png){: width="80%" .img-center }

Esses dados também alimentam a [Sentinela]({{ site.baseurl }}/docs/sentinel), que passa a incluir as _builds_ do Releaser nos relatórios do projeto. São três sinais, cada um no seu ritmo:

| Sinal | Quando | O que vai |
|---|---|---|
| Versão | Ao fim de cada _deploy_ bem-sucedido (e junto com a saúde) | A _tag_ implantada |
| Saúde | A cada minuto (_daemon_), ou `io health` | Estado, _healthcheck_, tamanho e idade de cada serviço |
| CVEs | A cada hora (_daemon_), ou `io cve` | Vulnerabilidades `HIGH` e `CRITICAL` de cada imagem em execução, pelo Trivy |

A autenticação usa o **mesmo `GITLAB_TOKEN`** do `.env` do Releaser: a plataforma valida o _token_ no GitLab e exige que o seu dono seja pelo menos _Developer_ do repositório da _app_. Se o _token_ expirar ou perder o acesso, o relato é recusado (o `io info` mostra o motivo) e, depois de 15 minutos sem contato, a _dashboard_ marca o estágio como "sem contato com o Releaser", em cinza. O valor de `SERVER` é o que aparece na _dashboard_ como o servidor da _build_: use o nome real da máquina, pois é ele que diz à equipe **onde** atuar quando algo falha.

> **Atenção!** Um estágio é implantado pela plataforma **ou** por um Releaser, nunca pelos dois. Se o estágio tiver um _cluster_ configurado na _dashboard_, o relato do Releaser é recusado (código `409`, visível no `io info`) e a plataforma continua mandando. É o caso de _builds_ antigas que ficaram no Releaser depois de migradas para a plataforma: remova-as do servidor (ou renomeie o arquivo para `.bkp`) e derrube os _containers_ com `io stop`. O caso inverso também acontece: um estágio que alguém tentou configurar num _cluster_ da plataforma, falhou na validação e ficou **inválido**, mesmo rodando num Releaser. Enquanto a configuração existir, o relato é recusado. Abra o status da _build_ na _dashboard_ e use **Limpar Configuração**: o estágio volta ao rascunho, sem derrubar nada, e o próximo relato do Releaser é aceito.

O que cada _build_ reporta é controlado pelo atributo [`stats`](#setup) do seu arquivo. O Trivy roda como _container_ no próprio servidor (imagem `aquasec/trivy`, banco de vulnerabilidades no volume `releaser_trivy`) e precisa de acesso ao `ghcr.io` para baixar o banco; servidores sem essa saída devem desligar o `cve`. As ações do _Health Check_ que dependem do _deployer_ da plataforma (_backup_, reiniciar, desativar e remover a _build_, terminal) ficam desabilitadas na _dashboard_ para as _builds_ do Releaser: elas continuam sendo feitas pelos comandos `io`. Quando uma CVE em exploração ativa atinge uma _build_ do Releaser, o e-mail do [alerta de CVEs críticos]({{ site.baseurl }}/docs/cve) traz o comando a executar no servidor (`io restart proj/app@stage --upgrade`) ou, em versões anteriores à `1.26.10-10`, o caminho manual e a orientação para [atualizar o Releaser](#update).

## Monitoramento do Releaser

Toda instância do **Releaser** reporta ao Sentry da plataforma (sentry.io, projeto `releaser`): erros internos da própria ferramenta como _issues_ e a saída de cada execução como _logs_ (com `operation`, `build`, `project`, `app` e `stage`). O `environment` é o valor de `SERVER` do `.env` e o `release` é a versão da imagem. Nada precisa ser configurado. Erros de _deploy_ ou _backup_ de uma _build_ **não** viram _issue_ do Releaser: eles são enviados por e-mail à equipe da _build_, e cada aplicação tem o próprio DSN do Sentry. O _health check_ de cada minuto só envia _logs_ de aviso ou erro.

## Atualização {#update}

A partir da versão **1.26.10-14**, o próprio Releaser avisa quando há versão nova e se atualiza com um comando:

```bash
docker exec -it releaser io upgrade
```

Ou só `io upgrade`, com o comando `io` instalado no servidor ([`io cli`](#cli)). É o mesmo sentido do `--upgrade` do `io restart`: puxar uma imagem mais nova. Lá, das _builds_; aqui, do próprio Releaser. Nada mais é necessário: as _builds_ configuradas, o `.env` e as chaves ficam no diretório e continuam valendo, e os recursos novos (como o [relato à plataforma](#report)) entram em funcionamento sozinhos.

O que acontece:

1. O Releaser consulta as versões publicadas de `embrapa/releaser` no Docker Hub, mostra de qual para qual versão vai e pede confirmação (`--yes` pula).
2. **Não atualiza no meio de uma operação**: se um _deploy_, _backup_, cópia em nuvem ou outro comando estiver rodando, recusa e diz qual. Tente de novo quando terminar.
3. Baixa a imagem nova pela **_tag_ exata** (`docker pull embrapa/releaser:1.26.10-14`), nunca pela `latest`.
4. Um _container_ auxiliar, da imagem nova, faz a troca: guarda a configuração do _container_ atual (`docker inspect`, em `/data/.update/previous.json`), para o atual, cria o novo com **a mesma configuração** (nome, diretório `/data`, _socket_ do Docker, variáveis definidas no `docker run`, política de _restart_, rede e rótulos), espera ele ficar de pé, configura a chave SSH do GitLab e roda um `io check` silencioso.
5. **Volta atrás sozinho**: se o _container_ novo não subir, ficar reiniciando ou o `io check` não rodar até o fim, o auxiliar remove o novo e religa o anterior, com a configuração de antes. GitLab ou _bucket_ fora do ar no momento **não** contam como falha da atualização.
6. O _container_ anterior só é removido depois que o novo passou em tudo. A imagem anterior continua no servidor (`docker image prune` a remove quando quiser).

A sessão do `docker exec` termina quando o _container_ antigo para, o que é esperado: a troca continua no auxiliar. Depois de alguns segundos, rode de novo:

```bash
docker exec -it releaser io info
```

O resultado aparece no início (`Last upgrade: 1.26.10-13 -> 1.26.10-14: ok at ...`) e, uma vez, na próxima abertura do menu. Se a atualização voltou atrás, o Releaser também manda um e-mail ao `LOG_MAIL` com o registro completo, que fica em `/data/.update/upgrade.log`.

Opções:

| Opção | O que faz |
|---|---|
| `--to VERSÃO` | Atualiza para uma versão específica (ex.: `--to 1.26.10-14`), inclusive para voltar a uma anterior |
| `--dry-run` | Só mostra o que seria feito e a configuração que o _container_ novo vai manter; não baixa, não para, não cria nada |
| `--yes` | Não pede confirmação |

Durante a troca (no máximo alguns minutos), os _jobs_ automáticos do Releaser não começam: o _deploy_ seguinte roda normalmente no _container_ novo.

### Aviso de versão nova

- **Menu** (`io` sem comando): uma linha em amarelo, `Update available: 1.26.10-14 (current 1.26.10-13): run 'io upgrade'`, e o comando `upgrade` destacado.
- **`io check`**: a versão aparece na linha de resumo (`Releaser update available: ...`).
- **`io info`**: um bloco `=== Releaser ===` no início, com a versão em uso, a mais nova publicada e o resultado da última atualização.
- **E-mail**: o _check_ diário do _daemon_ avisa o `LOG_MAIL` **uma vez por versão nova**, nunca todo dia.

A consulta ao Docker Hub é guardada por 24 horas e tem tempo limite de 3 segundos: o menu não fica lento nem depende da rede, e falha de rede não gera erro.

### Docker Swarm {#update-swarm}

No Swarm, o `io upgrade` faz `docker service update --image embrapa/releaser:<versão> --update-failure-action rollback` no serviço do Releaser: a especificação do serviço (montagens, _constraint_, variáveis) fica como está, só a imagem muda, e o próprio Swarm volta à versão anterior se a tarefa nova não subir. Depois, o `io check` roda na tarefa nova e, se falhar, o Releaser pede o _rollback_ do serviço. O comando precisa rodar num nó _manager_; num _worker_, o Releaser recusa e mostra o comando para rodar no _manager_.

### Atualização manual {#update-manual}

Use o procedimento manual quando o `io upgrade` não for possível: _container_ do Releaser parado ou com problema (não há onde rodar o `docker exec`), Releaser sem o _socket_ do Docker montado, _container_ criado por Docker Compose ou versões anteriores à **1.26.10-14**, que não têm o comando. Acesse o diretório de configuração (`~/releaser`, no exemplo acima, o que está montado em `/data`) e execute os comandos abaixo. Repita no `docker run` as demais opções usadas na instalação (outras variáveis `-e`, rede, rótulos).

Execute...

...no **Docker Compose**:

```bash
docker stop releaser && docker rm releaser

docker pull embrapa/releaser

cd ~/releaser

docker run --name releaser \
  -v $(pwd):/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart always -d --sig-proxy=false \
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

> **Atenção!** Servidores que usam o `~/releaser-update.sh`: faça uma última atualização com o _script_ (ou com os comandos acima) até a versão **1.26.10-14** ou mais nova. Daí em diante, use `io upgrade`: o _script_ deixa de ser necessário e pode ficar guardado como alternativa manual. O `io upgrade` funciona mesmo que o _container_ tenha sido criado com a imagem `embrapa/releaser` sem _tag_ (a `latest`); a partir dele, o _container_ passa a usar a _tag_ exata da versão.

### Se a troca for interrompida

O auxiliar não depende do terminal de quem chamou. Se ele mesmo for interrompido no meio (servidor reiniciado, Docker parado), o _container_ anterior **não é apagado**: fica parado com o nome `releaser-previous`, e a configuração dele está em `/data/.update/previous.json`. Para voltar:

```bash
docker rm -f releaser                      # o novo, se existir
docker rename releaser-previous releaser
docker update --restart unless-stopped releaser
docker start releaser
```

Com o comando `io` instalado no servidor ([`io cli`](#cli)), nada muda: a primeira chamada depois da atualização regrava o _script_ para a versão nova e avisa numa linha.

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

### Falha no clone: `Bad owner or permissions on /root/.ssh/config`

Em alguns servidores o _container_ é criado com a _umask_ `0000` (configuração do _runtime_ de _containers_ do _host_, não da imagem). Nas versões anteriores à `1.26.9-9`, isso fazia o arquivo `/root/.ssh/config` nascer com permissão `666`, que o OpenSSH recusa, e todo _deploy_ falhava ao clonar o repositório (`Impossible to clone repository at tag ...`). Para conferir a _umask_ do _container_:

```bash
docker exec releaser sh -c umask
```

A partir da versão `1.26.9-9` o **Releaser** corrige as permissões a cada execução ([atualize a imagem](#update)). Para corrigir imediatamente em uma versão anterior:

```bash
docker exec releaser sh -c 'chmod 600 /root/.ssh/config'
```

### Porta 22 bloqueada: clone por HTTPS {#https}

O **Releaser** consulta as _tags_ pela API do GitLab, na porta 443, mas clona o código-fonte por SSH, na porta 22. Em redes que bloqueiam a porta 22 na saída (comum em nuvens de parceiros e em algumas unidades), a API funciona e o _deploy_ falha no clone, com `Impossible to clone repository at tag ...` ou `... at branch ...`.

Para confirmar, execute no servidor:

```bash
timeout 5 bash -c '</dev/tcp/git.embrapa.io/443' && echo "443 aberta" || echo "443 bloqueada"
timeout 5 bash -c '</dev/tcp/git.embrapa.io/22' && echo "22 aberta" || echo "22 bloqueada"
```

E teste o SSH com a chave do próprio **Releaser**:

```bash
docker exec $(docker ps -q -f name=releaser) ssh -o ConnectTimeout=10 -T git@git.embrapa.io
```

Com a porta 22 liberada e o `ssh.pub` cadastrado no seu _profile_ do GitLab, a resposta começa com `Welcome to GitLab`. Um _timeout_ indica bloqueio de rede; `Permission denied (publickey)` indica que a chave não está cadastrada.

Há duas saídas:

1. **Liberar a porta** (definitivo): peça à equipe de rede responsável pelo servidor a liberação de saída TCP na porta **22** para o `git.embrapa.io`, anexando o resultado dos testes acima.

2. **Clonar por HTTPS** (imediato, sem mexer na rede): a variável opcional `GITLAB_SSH` define o endereço usado no clone, cujo padrão é `ssh://git@git.embrapa.io`. Apontada para HTTPS com um _token_, o clone passa a sair pela porta 443:

   - Gere um _token_ em [Personal Access Tokens](https://git.embrapa.io/-/user_settings/personal_access_tokens) com os _scopes_ `read_api` **e** `read_repository` (o `read_api` sozinho não permite clonar), sem data de expiração. O usuário precisa ter acesso a todos os repositórios das _builds_ do servidor, como no caso do `GITLAB_TOKEN`.
   - No `.env` do diretório de configuração (`~/releaser/.env`, no exemplo), use esse _token_ no `GITLAB_TOKEN` e acrescente:

     ```bash
     GITLAB_SSH=https://oauth2:<token>@git.embrapa.io
     ```

   - Valide com uma das _builds_ (o `validate` faz o clone da _branch_ do estágio):

     ```bash
     docker exec -it $(docker ps -q -f name=releaser) io validate projeto/app@stage
     ```

O `.env` é relido a cada execução, tanto pelo comando `io` quanto pelos serviços periódicos do _daemon_: não é preciso recriar o _container_. Nas mensagens de erro do clone o Git omite o _token_ da URL, mas ele fica em texto claro no `.env`, como o `GITLAB_TOKEN`. Por isso, guarde esse arquivo com o mesmo cuidado do `builds.json` (veja [Salvaguarda de Segredos e Senhas](#vault)).

## Dicas

A seguir são listadas algumas dicas complementares para uso da ferramenta **Releaser**.

### Backup

Por padrão, os _boilerplates_ de aplicações da plataforma **Embrapa I/O** [implementam um serviço de _backup_]({{ site.baseurl }}/docs/boilerplate#cli:backup). Caso a aplicação instanciada pelo **Releaser** tenha este serviço na _stack_ de _containers_, pode-se habilitá-lo para ser executado diariamente (veja acima).

A dica é utilizar um único volume de _backup_ para todas as aplicações instanciadas no servidor. Com isso ficará mais fácil implementar um _script_ que copie todos os novos arquivos gerados para, p.e., um _storage_ remoto. A partir da versão `1.26.10-12`, o próprio **Releaser** faz isso para qualquer _bucket_ compatível com o S3 (veja [Cópia em nuvem (S3)](#cloud)).

A partir da versão `1.26.10-13`, essa pasta é a `BACKUP_DIR` do `.env` (padrão `/root/backup`, alterável em `io cloud --setup`), e o [`io install`](#install) mostra o comando que cria o volume `_backup` de cada _build_ ligado a ela. Veja a [configuração inicial](#setup).

No exemplo abaixo criamos um volume denominado `backup` que será utilizado por todas as _builds_ instanciadas:

```bash
docker volume create \
  --driver local \
  --opt type=none \
  --opt device=/root/backup \
  --opt o=bind \
  backup
```

Basta agora informar este volume no momento de configurar as _environment variables_ no arquivo da _build_ (em `builds/`).

#### Rotação de _backups_ {#cleaner}

O serviço de _backup_ dos _boilerplates_ gera um arquivo por execução e **não apaga os anteriores**. Com o _backup_ diário ligado, o volume cresce indefinidamente. O comando `cleaner` resolve isso aplicando, ao volume de _backup_ de cada _build_, uma política de retenção do tipo _avô-pai-filho_ **por contagem de períodos com _backup_**. Por padrão, mantém:

- **7 diários** — o último _backup_ de cada um dos 7 dias mais recentes que possuem _backup_;
- **4 semanais** — entre os arquivos restantes, o último de cada uma das 4 semanas mais recentes (na prática, os 4 domingos anteriores);
- **3 mensais** — entre os arquivos restantes, o **primeiro** _backup_ de cada um dos 3 meses mais recentes; e
- **1 anual** (a partir da versão `1.26.10-12`) — entre os arquivos restantes, o **primeiro** _backup_ de cada um dos anos mais recentes que têm _backup_ (com 1, o primeiro do ano corrente; com 2, também o primeiro do ano anterior). Assim como o mensal, não muda ao longo do ano. Quem já usava o `cleaner` passa a guardar **um arquivo a mais** (o primeiro do ano), salvo quando ele já está entre os mensais.

A quantidade de cada geração pode ser trocada pela variável opcional `RETENTION` do `.env`, no formato `D/S/M/A`: quatro inteiros maiores ou iguais a zero, separados por barra, com quantos dias, semanas, meses e anos guardar. Por exemplo:

| `RETENTION` | Guarda |
|---|---|
| (ausente ou vazia) | `7/4/3/1`: 7 diários, 4 semanais, 3 mensais e 1 anual (padrão) |
| `14/8/12/3` | 14 diários, 8 semanais, 12 mensais e 3 anuais |
| `7/4/3/0` | a política anterior à versão `1.26.10-12`, sem anual |
| `0/0/0/5` | só o primeiro _backup_ de cada um dos 5 anos mais recentes |

Valor malformado (menos de quatro números, número não inteiro ou negativo) **interrompe a rotação com um erro, sem apagar nada**. No _daemon_, se alguma _build_ tem a rotação ligada, o erro vai por e-mail.

Como a contagem considera apenas períodos que têm arquivo, a **ausência de _backups_ novos nunca provoca exclusão**: se hoje não houve _backup_, o de 7 dias atrás continua entre os 7 dias mais recentes e é preservado. Entre uma rotação e a próxima pode haver um ou dois arquivos a mais que os 15 da política padrão. A data de cada arquivo é lida do próprio nome (`AAAA-MM-DD_HH-MM-SS`, como sufixo ou prefixo); arquivos **sem data no nome** (por exemplo, um _dump_ colocado manualmente no volume) não entram na política: são preservados e nunca apagados.

Só entram na rotação os arquivos cujo nome começa com o prefixo da própria _build_ (`{projeto}_{app}_{stage}_`). Isso importa quando várias _builds_ compartilham o mesmo diretório de _backup_ no servidor (como sugerido em [Backup](#backup)): cada _build_ só enxerga (e só apaga) os seus próprios arquivos, e a política de 7/4/3/1 vale por _build_ — arquivos de outras _builds_, com nome fora do padrão ou sem prefixo (por exemplo, `backup_2026-08-01.tar.gz` de versões antigas dos _boilerplates_) nunca são tocados.

Em regime permanente, o volume de _backup_ da _build_ `cnpgc/edge@release` fica assim:

```
cnpgc_edge_release_1.26.9-3_2026-09-07_02-00-00.tar.gz   ← diários (7)
cnpgc_edge_release_1.26.9-3_2026-09-06_02-00-00.tar.gz
...
cnpgc_edge_release_1.26.9-3_2026-09-01_02-00-00.tar.gz
cnpgc_edge_release_1.26.9-3_2026-08-30_02-00-00.tar.gz   ← semanais (4 domingos)
cnpgc_edge_release_1.26.9-3_2026-08-23_02-00-00.tar.gz
cnpgc_edge_release_1.26.9-3_2026-08-16_02-00-00.tar.gz
cnpgc_edge_release_1.26.9-3_2026-08-09_02-00-00.tar.gz
cnpgc_edge_release_1.26.9-2_2026-08-01_02-00-00.tar.gz   ← mensais (3, primeiro backup do mês)
cnpgc_edge_release_1.26.5-1_2026-07-01_02-00-00.tar.gz
cnpgc_edge_release_1.26.5-1_2026-06-01_02-00-00.tar.gz
cnpgc_edge_release_1.26.1-3_2026-01-01_02-00-00.tar.gz   ← anual (1, primeiro backup do ano)
```

Quando o primeiro _backup_ do ano é também o primeiro do mês, o mesmo arquivo cumpre as duas funções e não ocupa lugar extra.

Para ver o que seria feito sem apagar nada:

```bash
docker exec -it releaser io cleaner cnpgc/edge@release --dry-run
```

A saída termina com um resumo por _build_, útil para acompanhar o espaço recuperado:

```
INFO > Summary:

cnpgc/edge@release
23 → 15 file(s)
1,8 GB → 1,2 GB
freed 600,0 MB
```

Para deixar a rotação automática (diária, logo após o _backup_), ligue `"cleaner": true` no atributo `auto` da _build_.

> **Aplicações fora dos _boilerplates_:** se o serviço `backup` de uma aplicação gerar arquivos sem data reconhecível no nome, o `cleaner` os preserva e avisa a cada execução. Ajuste o serviço para o [padrão obrigatório]({{ site.baseurl }}/docs/boilerplate#cli:backup) `{projeto}_{app}_{stage}_{versão}_AAAA-MM-DD_HH-MM-SS.tar.gz` ou, como paliativo, use `"cleaner": "undated"` na _build_ para que esses arquivos entrem na rotação pela data de modificação. O comando acessa o volume diretamente pelo Docker (`{projeto}_{app}_{stage}_backup`, ou o volume `backup` declarado no `docker-compose.yaml`), portanto funciona igual nos orquestradores Docker Compose e Docker Swarm e não depende do serviço `backup` da aplicação.

Para isso, o `cleaner` (e a [cópia em nuvem](#cloud)) usa um _container_ auxiliar efêmero, criado a partir da **própria imagem do Releaser em execução** (a partir da versão `1.26.10-12`; antes, baixava a imagem `alpine:3`). Se o Releaser não conseguir descobrir a própria imagem (por exemplo, num _container_ criado com `--hostname` trocado), informe-a na variável opcional `IO_RELEASER_IMAGE` do `.env`.

#### Cópia em nuvem (S3) {#cloud}

A partir da versão `1.26.10-12`, o **Releaser** pode copiar, todo dia, os arquivos de _backup_ de cada _build_ para um _bucket_ S3 compatível (AWS S3, Cloudflare R2, Backblaze B2, MinIO ou qualquer serviço com a API do S3), guardando uma cópia fora do servidor. O _bucket_ é configurado **uma única vez** no `.env` do **Releaser** e a cópia é ligada **por _build_**, no atributo `auto.cloud`.

```bash
docker exec -it releaser io cloud [BUILD-1,BUILD-2,...,BUILD-N | --all] [--dry-run | --list]
```

Por exemplo:

```bash
# o que seria enviado e apagado, sem tocar no bucket
docker exec -it releaser io cloud --all --dry-run

# copia (e rotaciona no bucket) uma build
docker exec -it releaser io cloud meu-projeto/api@release

# lista o que há no bucket para a build
docker exec -it releaser io cloud meu-projeto/api@release --list
```

Em modo _daemon_, o comando roda uma vez por dia, **depois** do `backup` e do `cleaner`, para as _builds_ com `auto.cloud` ligado.

##### Configuração do _bucket_

As variáveis abaixo são lidas do `.env` do diretório de configuração:

| Variável | Obrigatória | Descrição |
|---|---|---|
| `S3_ENDPOINT` | sim | URL da API S3 do provedor (ex.: `https://<conta>.r2.cloudflarestorage.com`, `https://s3.us-east-005.backblazeb2.com`, `https://s3.sa-east-1.amazonaws.com`, `http://minio.exemplo.br:9000`). |
| `S3_BUCKET` | sim | Nome do _bucket_ (só o nome, sem `s3://` nem barras). **O _bucket_ precisa existir**: o **Releaser** não o cria. |
| `S3_ACCESS_KEY` | sim | Chave de acesso (_access key ID_). |
| `S3_SECRET_KEY` | sim | Segredo da chave (_secret access key_). |
| `S3_REGION` | não | Região. Padrão `auto`, que funciona no Cloudflare R2. Na AWS e no Backblaze B2, use a região real do _bucket_ (ex.: `sa-east-1`, `us-east-005`); no MinIO, em geral, `us-east-1`. |
| `S3_RETENTION` | não | Rotação no _bucket_, no formato `D/S/M/A` (veja [Rotação de _backups_](#cleaner)). Se ausente ou vazia, vale o `RETENTION`; se este também faltar, `7/4/3/1`. |

> **Atenção!** A chave precisa de permissão para **listar, ler, gravar e apagar objetos** no _bucket_. Prefira uma chave restrita a esse _bucket_.

Depois de configurar, teste com o comando `io check`, que também verifica o acesso ao _bucket_ (veja o comando `check` em [Utilização](#usage)).

##### Ligando a cópia por _build_

No arquivo da _build_ (`builds/<projeto>_<app>_<estágio>.json`), o atributo `auto.cloud` controla a cópia:

```json
"auto": {
  "deploy": true,
  "backup": true,
  "sanitize": true,
  "cleaner": true,
  "cloud": true
}
```

| Valor de `auto.cloud` | Comportamento no _daemon_ |
|---|---|
| `false` ou ausente (**padrão**) | Não copia. |
| `true` | Copia diariamente e rotaciona o _bucket_ com `S3_RETENTION`. |
| `"undated"` | Idem, e arquivos **sem data no nome** entram na rotação do _bucket_ pela data de modificação (como no _cleaner_). |

Em execução manual (`io cloud ...`), o comando roda para as _builds_ indicadas mesmo com `auto.cloud` desligado.

##### Organização no _bucket_

Os arquivos ficam organizados por _build_:

```
<bucket>/<projeto>/<app>/<estágio>/<arquivo>
```

Por exemplo, `meus-backups/meu-projeto/api/release/meu-projeto_api_release_1.26.9-1_2026-10-23_02-00-00.tar.gz`. Assim, um mesmo _bucket_ pode servir a vários servidores e a várias _builds_.

Como no _cleaner_, **só são considerados os arquivos cujo nome começa com `<projeto>_<app>_<estágio>_`**, tanto no volume quanto no _bucket_. Arquivos de outras _builds_ ou com outro nome nunca são enviados nem apagados.

##### Como funciona

A cada execução, para cada _build_, o **Releaser**:

1. lista os arquivos da _build_ no volume de _backup_;
2. lista os arquivos da _build_ no _bucket_;
3. envia **só o que falta** no _bucket_ (nunca sobrescreve um arquivo que já está lá); e
4. aplica a rotação (`S3_RETENTION`) **ao que está no _bucket_** e apaga o excedente.

Arquivos que faltam no _bucket_ mas que a rotação dele já descartaria (por exemplo, quando o volume guarda mais _backups_ que o _bucket_) não são enviados: seriam enviados e apagados de novo a cada dia. Arquivos sem data no nome são enviados e nunca apagados do _bucket_ (salvo com `"undated"`).

Ao final, um resumo por _build_ informa os arquivos e _bytes_ enviados, mantidos e apagados, e o tamanho do _bucket_ antes e depois. O resultado da última cópia aparece no `io info`. Falha de rede ou de permissão numa _build_ é registrada como erro **daquela _build_** (as outras seguem) e, nesse caso, nada é apagado do _bucket_.

> **Atenção!** A cópia em nuvem **não** é um espelho do volume: nada é apagado do _bucket_ porque saiu do volume (por exemplo, pela rotação local do _cleaner_). O _bucket_ tem a própria rotação, `S3_RETENTION`, que pode guardar mais (ou menos) que o volume. Ela também **não gera** _backups_ (copia os arquivos que o serviço `backup` da aplicação gravou no volume), **não cria** o _bucket_ nem configura regras de ciclo de vida, versionamento ou criptografia no provedor, e **não restaura**: para restaurar, baixe o arquivo do _bucket_ (pelo painel do provedor ou por um cliente S3, como `rclone` ou `aws s3 cp`) e use o procedimento de restauração da aplicação.

##### Exemplo: Cloudflare R2

1. No painel da Cloudflare, em **R2**, crie o _bucket_ (por exemplo, `releaser-backups`).
2. Em **R2 &raquo; Manage API tokens**, crie um _token_ com permissão **Object Read & Write**, restrito ao _bucket_. Anote o _Access Key ID_, o _Secret Access Key_ e o _endpoint_ S3 (`https://<ID da conta>.r2.cloudflarestorage.com`).
3. No `.env` do **Releaser**, acrescente:

```bash
S3_ENDPOINT=https://0123456789abcdef0123456789abcdef.r2.cloudflarestorage.com
S3_BUCKET=releaser-backups
S3_ACCESS_KEY=0f1e2d3c4b5a69788796a5b4c3d2e1f0
S3_SECRET_KEY=exemplo-de-segredo-nao-use-este-valor-0123456789abcdef
S3_RETENTION=30/8/12/3
```

O `S3_REGION` pode ficar de fora (o padrão, `auto`, é o que o R2 espera).

##### Exemplo: MinIO

Com o **MinIO** acessível pelo servidor (por exemplo, `http://minio.unidade.embrapa.br:9000`), crie o _bucket_ e uma chave com acesso a ele (pelo console do MinIO ou com o `mc`):

```bash
mc alias set local http://minio.unidade.embrapa.br:9000 ADMIN SENHA-DO-ADMIN
mc mb local/releaser-backups
mc admin user add local releaser exemplo-de-segredo-nao-use
mc admin policy attach local readwrite --user releaser
```

No `.env` do **Releaser**:

```bash
S3_ENDPOINT=http://minio.unidade.embrapa.br:9000
S3_BUCKET=releaser-backups
S3_ACCESS_KEY=releaser
S3_SECRET_KEY=exemplo-de-segredo-nao-use
S3_REGION=us-east-1
```

##### Exemplo de saída

```
=== meu-projeto/api@release ===

INFO > Checking if build 'meu-projeto/api@release' has been deployed...
INFO > Copying backups to the bucket (rotation there: keep last 7 daily, 4 weekly, 3 monthly and 1 yearly)...
INFO > Backup volume: 'meu-projeto_api_release_backup'
INFO > Bucket: 's3://releaser-backups/meu-projeto/api/release/' at 'https://0123456789abcdef0123456789abcdef.r2.cloudflarestorage.com'
INFO > Files of this build: 15 in the volume (2,1 GB), 15 in the bucket (2,1 GB).
INFO > Uploading 1 file(s) (143,2 MB):
  143,2 MB  meu-projeto_api_release_1.26.9-1_2026-10-23_02-00-00.tar.gz
  INFO  : meu-projeto_api_release_1.26.9-1_2026-10-23_02-00-00.tar.gz: Copied (new)
INFO > Keeping 15 of 16 backup file(s) in the bucket [D = daily, W = weekly, M = monthly, Y = yearly]:
  D   143,2 MB  meu-projeto_api_release_1.26.9-1_2026-10-23_02-00-00.tar.gz
  D   142,9 MB  meu-projeto_api_release_1.26.9-1_2026-10-22_02-00-00.tar.gz
  ...
  Y   120,4 MB  meu-projeto_api_release_1.26.1-3_2026-01-01_02-00-00.tar.gz
INFO > Deleting 1 file(s) from the bucket (141,7 MB):
  141,7 MB  meu-projeto_api_release_1.26.9-1_2026-10-16_02-00-00.tar.gz
SUCCESS > All done! Build 'meu-projeto/api@release': 1 file(s) uploaded, 15 kept and 1 deleted in the bucket.

INFO > Summary:

meu-projeto/api@release
uploaded 1 file(s), 143,2 MB
kept 15, deleted 1 file(s), 141,7 MB
bucket: 15 → 15 file(s), 2,1 GB → 2,1 GB
```

E o `io cloud meu-projeto/api@release --list` mostra a marca que a próxima rotação dará a cada arquivo (`-` = será apagado; `?` = sem data no nome, nunca apagado):

```
INFO > 16 file(s), 2,2 GB [D/W/M/Y = kept by the next rotation, - = deleted by it, ? = no date in the name, never deleted]:
  D   143,2 MB  2026-10-23 02:00  meu-projeto_api_release_1.26.9-1_2026-10-23_02-00-00.tar.gz
  ...
  -   141,7 MB  2026-10-16 02:00  meu-projeto_api_release_1.26.9-1_2026-10-16_02-00-00.tar.gz
  ?   12,0 MB   2026-03-02 15:10  meu-projeto_api_release_dump-antes-da-migracao.sql.gz
```

##### Segurança

- As credenciais ficam só no `.env` do **Releaser**. Ele as entrega ao `rclone` por variáveis de ambiente do processo: não há arquivo de configuração do `rclone`, e as chaves não aparecem na linha de comando (`ps`) nem na saída, nos e-mails ou nos _logs_.
- As variáveis do `.env` do **Releaser** não são repassadas aos _containers_ das aplicações.
- O volume de _backup_ é montado **somente leitura** para a cópia.

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

É recomendado que seja [instalado o Portainer](https://docs.portainer.io/start/install) em servidores que tenham o **Releaser** para auxiliar a equipe mantenedora em sua gestão. Por meio de sua interface web é possível, por exemplo, acompanhar os _logs_ e o consumo de recursos de cada _container_, acessar um terminal (_console_) dentro deles e parar ou reiniciar _stacks_ de forma simplificada. Veja a documentação oficial de instalação:

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

docker run -d --sig-proxy=false -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

set +e

for i in 1 2 3 4 5; do
  sleep 10

  [ -n "$(docker ps -q -f name=^portainer$ -f status=running)" ] && exit 0

  docker start portainer
done

echo >&2 "Portainer is not running! Check it with 'docker logs portainer'."

exit 1
```

O parâmetro `--sig-proxy=false` impede que o cliente `docker` repasse ao _container_ sinais que ele próprio receba (p.e., um `SIGTERM` enviado ao _script_ quando executado via `cron`), o que derrubaria o Portainer logo após sua criação. Como uma parada deste tipo é tratada pelo Docker como manual, o `--restart=always` não o traz de volta. Por isso, ao final, o _script_ verifica se o Portainer permanece em execução, tentando reiniciá-lo até 5 vezes, e retorna erro caso não consiga.

Repare também que é publicada a porta HTTPS do Portainer (9443), com certificado autoassinado. Assim, mesmo o tráfego entre o _virtual proxy_ e o Portainer é criptografado. No **Nginx Proxy Manager**, configure o _proxy host_ com o _scheme_ `https`, apontando para a porta **9443** do _host_ onde está o Portainer (ou para `172.17.0.1`, caso estejam na mesma VM).

> **Atenção!** Caso o _virtual proxy_ seja o Nginx instalado no próprio _host_ (conforme configuração a seguir), é recomendado publicar a porta apenas na interface local, substituindo `-p 9443:9443` por `-p 127.0.0.1:9443:9443` no _script_. Assim, o Portainer não fica exposto diretamente na rede.

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
    proxy_cache_bypass $http_upgrade;
    proxy_ssl_session_reuse off;
    proxy_pass https://127.0.0.1:9443;
  }
}
```

### Depuração de Serviços e Atualização das Imagens de Containers {#info}

A partir da versão `1.26.10-10`, a forma mais simples de atualizar as imagens de uma aplicação é o comando `restart` com `--upgrade`:

```bash
docker exec -it releaser io restart publica/camunda@release --upgrade
```

Em versões anteriores, ou para depurar a aplicação, faça o seguinte:

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

Os arquivos de configuração das _builds_ do **Releaser** (`builds/*.json`, ou o `builds.json` nas instalações antigas) concentram diversos _passwords_, _hashes_, _secrets_ e valores de variáveis de ambiente que, se perdidos, podem gerar grande dor de cabeça. Assim, é aconselhado utilizar um serviço em nuvem do tipo _password_ ou _secrets management_ para gerência da configuração (controle de versões) destas configurações do **Releaser**, garantindo que estas informações não serão perdidas mesmo que o servidor (_bare metal_) seja irremediavelmente comprometido.

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

NOTES=$(cat /root/releaser/.env /root/releaser/builds/*.json)

jq -n \
  --arg name "Releaser Backup $(hostname) $(date +%F)" \
  --arg notes "$NOTES" \
  '{type:2, secureNote:{type:0}, name:$name, notes:$notes}' \
  | bw encode | bw create item
```

Por fim, atribua permissões de execução: `chmod +x /root/vault.sh`.

Sempre que os arquivos de `builds/` (ou o `.env`) tiverem novas configurações, é recomendado executar este script. Ele irá enviar para sua conta do **Bitwarden** a nova versão de forma protegida:

![Bitwarden]({{ site.baseurl }}/assets/img/releaser/20251217145652.png)
