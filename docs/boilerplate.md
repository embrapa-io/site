---
layout: page
title: Boilerplate
subtitle: Criando e mantendo um boilerplate
---

*[PWA]: Progressive Web App
*[LTS]: Long-term support
*[CLI]: Command-line interface
*[API]: Application Programming Interface
*[DSN]: Data Source Name
*[SDKs]: Software Development Kits
*[IDE]: Integrated Development Environment
*[BD]: Banco de Dados
*[BDs]: Bancos de Dados
*[PaaS]: Platform as a Service

De forma geral, as aplicações da plataforma **embrapa.io** são _forks_ de repositórios pré-existentes denominados _boilerplates_. Estes respositórios são aplicações funcionais, em determinada linguagem de programação ou _framework_, já estruturadas para funcionar corretamente nos _pipelines_ e processos de DevOps da plataforma. A ideia é fomentar a padronização e o reuso de código-fonte. Neste tutorial veremos como configurar corretamente um novo _boilerplate_ para distribuí-lo no catálogo da plataforma, de modo a possibilitar que outras equipes de desenvolvimento de ativos digitais possam fazer uso.

Para criar e disponibilizar seu _boilerplate_, você precisará seguir os seguintes passos:

1. [Crie uma "aplicação-base"](#base);
2. [Integre ao _error tracking_](#bug);
3. [Crie os arquivos de _environment variables_](#env);
4. [Utilize as _keywords_ de customização](#keyword);
5. [Conteinerize seu _boilerplate_](#docker);
6. [Implemente os "serviços-padrões"](#cli): [_test_](#cli:test), [_backup_](#cli:backup), [_restore_](#cli:restore) e [_sanitize_](#cli:sanitize);
7. [Configure os metadados](#metadata); e
8. [Distribua o _boilerplate_](#publish).

É possível [criar um repositório de aplicação]({{ site.baseurl }}/docs/app) sem utilizar um _boilerplate_. Esta função é útil para instanciar na plataforma sistemas que antecedem o próprio **embrapa.io**. Entretanto, será necessário criar manualmente um repositório no [GitLab](https://git.embrapa.io) e adaptar seu código fonte de forma que ele tenha **toda a estrutura de pastas e arquivos requeridos para um _boilerplate_** (ou seja, seguir os mesmos passos aqui descritos). Em seguida, no momento de criar a aplicação pela _dashboard_, selecione a opção de um "**repositório pré-existente**" (conforme a imagem abaixo).

![Criando uma aplicação sem o boilerplate]({{ site.baseurl }}/assets/img/boilerplate/01.png)

## 1. Crie uma "aplicação-base" {#base}

O primeiro passo para iniciar a construção de seu _boilerplate_ é criar uma aplicação funcional. Esta aplicação terá funcionalidades que são **requisitos comuns** de ativos digitais para a agricultura, de forma que o reúso deste código-base seja demandado. Por exemplo, poderíamos ter dois _boilerplates_ de PWA utilizando os _frameworks_ [VueJS](https://vuejs.org) e [Vuetify](https://vuetifyjs.com): um com sistema de _login_ de usuários e outro sem. No catálogo de _boilerplates_ o usuário poderia escolher qual utilizar tomando esta característica como base.

> **Atenção!** O _boilerplate_ deve ser uma aplicação com padrões rigorosos de qualidade de código, bem como utilizando as **versões mais recentes**, LTS, da linguagem e arcabouço de programação. Por exemplo, se estiver sendo criado em [PHP](https://php.net), espera-se que esteja plenamente aderente aos [PHP Standards Recommendations](https://www.php-fig.org/psr/).

Assim, é fortemente recomendado que a criação de um _boilerplate_ tenha como ponto de partida o _Get Started_ do próprio arcabouço de programação. A imensa maioria dos _frameworks_ modernos possuem ferramentas CLI do tipo _standard tooling_, que permitem a criação de estruturas padronizadas de projetos de software. Adicionalmente, priorize o uso de linguagens, arcabouços e pacotes que tenham licença _open source_ permissivas, de forma a não "contaminar" o [licenciamento da aplicação final]({{ site.baseurl }}/docs/licensing). Por fim, tenha em mente que softwares são descontinuados. Portanto, para garantir uma vida longa e próspera ao seu _boilerplate_ (e às aplicações derivadas dele), dê preferência a tecnologias consolidadas, com vastas comunidades e que tenham se provado no tempo. Tome como exemplos: [Go Gin Gonic](https://gin-gonic.com/docs/quickstart/), [Java Spring Boot](https://spring.io/guides/gs/spring-boot/), [PHP Laravel](https://laravel.com/docs/4.2/quick), [PHP Symfony](https://symfony.com/doc/current/getting_started/index.html), [Python Django](https://docs.djangoproject.com/en/4.0/intro/tutorial01/), [ReactJS](https://reactjs.org/docs/add-react-to-a-website.html), [React Native](https://reactnative.dev/docs/0.60/enviroment-setup) e [VueJS/Vuetify](https://vuetifyjs.com/en/getting-started/installation/).

Todos os _boilerplates_ da plataforma ficam disponíveis **publicamente** no mesmo [grupo de repositórios no GitLab](https://git.embrapa.io/io/metadata/boilerplate). Você pode iniciar a criação de seu _boilerplate_ em seu próprio repositório e, posteriormente, efetuar um _fork_ para este grupo, ou [solicitar a criação de um novo repositório dentro do grupo](mailto:io@embrapa.br). Para todos os efeitos, a construção do _boilerplate_ seguirá as diretrizes de uma aplicação convencional da plataforma, tal como o [controle de _issues_ e _milestones_]({{ site.baseurl }}/docs/kanban).

Após criar a aplicação-base, você deverá customizá-la. Antes de começar a alterá-la, entretanto, verifique se existem ferramentas do tipo **_linter_** e **_fomatter_** devidamente configuradas em sua IDE para a linguagem de programação que está utilizando. Falamos mais sobre isso na [seção de boas práticas de desenvolvimento]({{ site.baseurl }}/docs/practices).

Inicie a customização da aplicação-base incluindo aspectos que são comumente utilizados nos ativos digitais da Embrapa. Por exemplo, uma identidade visual aderente aos padrões estabelecidos pela área de comunicação, a logo da Empresa conforme o manual de uso, estrutura de menus, cabeçalho e rodapé, e telas que são normalmente padronizadas (p.e., a tela de "Sobre"). Adicionalmente, inclua funcionalidades mais complexas que caracterizem seu _boilerplate_, tal como requisitos não-funcionais (p.e., registro e _login_ de usuários) ou mesmo funcionais (p.e., cadastro e gestão de fazendas). O domínio de negócio dos ativos digitais da plataforma **embrapa.io** é abrangente, porém bem definida: "**o agronegócio**". Portanto, <u>existem requisitos funcionais que serão de uso comum</u>.

Caso esteja desenvolvendo o _boilerplate_ para uma **API Web**, comprometa-se em torná-lo aderente ao [AgroAPI](https://www.agroapi.cnptia.embrapa.br), de forma que as aplicações criadas a partir dele possam compor o catálogo da Embrapa quando forem publicadas. Simuladores, algoritmos de aprendizado de máquina, visão computacional e **artefatos de software especializados** de forma geral, <u>devem ser encapsulados em componentes específicos</u>. Neste caso, recomenda-se que tenham seu próprio repositório de código e sejam integrados nas aplicações na forma de **pacotes privados** (gerenciados por _dependency managers_, tal como o [composer](https://getcomposer.org/), o [npm](https://www.npmjs.com/), o [gradle](https://gradle.org) ou o [maven](https://maven.apache.org/)). Assim, um _boilerplate_ para uma aplicação [TensorFlow.js](https://www.tensorflow.org/js), por exemplo, seria na verdade um pacote NPM. No [capítulo sobre integração]({{ site.baseurl }}/docs/integration) são detalhados outros formatos de aplicação, tal como [_remotes_ para compor _micro-frontends_](https://ruairidh.dev/introduction-to-micro-frontends/).

## 2. Integre ao _error tracking_ {#bug}

Conforme [já detalhado anteriomente]({{ site.baseurl }}/docs/bug), a plataforma **embrapa.io** é integrada à ferramenta [Sentry](https://sentry.io), de _error tracking_. Assim, no momento em que um projeto ou uma aplicação é criada pela [_dashboard_ da plataforma](https://dashboard.embrapa.io), o [autômato _Genesis_]({{ site.baseurl }}/docs/architecture#genesis) cria a entidade correlata na ferramenta Sentry e atribui a equipe. Pela _dashboard_ será então possível à equipe de desenvolvimento do ativo obter o DSN de _error tracking_.

![Acesso ao DSN pelo card da aplicação]({{ site.baseurl }}/assets/img/bug/02.png)

Para que funcione corretamente, será necessário preparar o _boilerplate_ para o Sentry. Este possui SDKs específicos para [diversas linguagens e arcabouços de programação](https://docs.sentry.io/platforms/). Por exemplo, para utilizar em um PWA em VueJS o seguinte trecho de código foi adicionado ao _bootstrap_ da aplicação:

```js
import * as Sentry from '@sentry/vue'
import { BrowserTracing } from '@sentry/tracing'

Sentry.init({
  Vue,
  dsn: process.env.SENTRY_DSN,
  release: '%GENESIS_PROJECT_UNIX%@' + process.env.VERSION.split('-')[0],
  environment: process.env.STAGE,
  integrations: [
    new BrowserTracing({
      routingInstrumentation: Sentry.vueRouterInstrumentation(router),
      tracingOrigins: ['localhost',  window.location.host, /^\//]
    })
  ],
  tracesSampleRate: 1.0
})
```

Dentre as variáveis de ambiente acima, o **DSN**, a **versão da _build_** (no atributo `release`) e o **estágio de maturidade** (no atributo `environment`) [são injetados em tempo de _deploy_ pela plataforma](#env). A _keyword_ `%GENESIS_PROJECT_UNIX%` é [alterada pelo autômato _Genesis_ no momento do provisionamento da aplicação a partir do _boilerplate_](#keyword).

## 3. Crie os arquivos de _environment variables_ {#env}

Na plataforma as aplicações são parametrizadas por meio de **variáveis de ambiente**, que são injetadas diretamente durante os processos automatizados (_validate_, _deploy_, _backup_, _restart_, etc). Os principais arquivos utilizados são:

- `.env.ci`: é injetado diretamente na chamada de linha de comando e, portanto, as variáveis neste arquivo terão precedência sobre todas as demais;
- `.env.cli`: substitui o arquivo acima quando são chamados serviços do tipo CLI (`test`, `sanitize`, `backup` ou `restore`); e
- `.env`: é carregado pelo Docker Compose ([veja abaixo](#docker)) a partir da raiz da aplicação.

Estes arquivos, portanto, são gerados pela plataforma e **não devem constar no _boilerplate_**. Ao invés disso, devem estar listados no arquivo `.gitignore` de forma a <u>não serem versionados pelo GIT</u>. Assim, para disponibilização junto ao _boilerplate_, é recomendado criar os arquivos acima, porém com o sufixo `.example` (estes sim versionados pelo GIT). Desta forma, os desenvolvedores que utilizarem o _boilerplate_ iniciarão a customização da aplicação copiando e renomeando estes arquivos para remover o sufixo.

As variáveis que compõem o arquivo `.env.ci.example` são:

```bash
SERVER=localhost
STAGE=development
COMPOSE_PROJECT_NAME=%GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%
COMPOSE_PROFILES=development
ENVIRONMENT=development
VERSION=%GENESIS_VERSION%
DEPLOYER=first.surname@embrapa.br
SENTRY_DSN=GET_IN_DASHBOARD
```

Acima as variáveis estão sendo setadas com valores propícios ao ambiente de desenvolvimento. Para distribuição do seu _boilerplate_, sugere-se utilizar algo semelhante. Repare na presença de _keywords_ (entre os caracteres '**%**'), que serão explicadas em seguida. Ao copiar e renomear o arquivo (retirando o sufixo `.example`) o desenvolvedor da aplicação precisará ajustar estes valores, tal como [inserir o DSN correto no Sentry]({{ site.baseurl }}/docs/bug).

As variáveis do arquivo `.enc.cli.example` serão idênticas às acima, com a exceção da variável `COMPOSE_PROFILES`, que deverá ser setada com o valor `cli`.

As variáveis do arquivo `.env.example` deverão ser as mesmas que são pré-carregadas para a [configuração da _build_]({{ site.baseurl }}/docs/build). Isto será explicado mais adiante, no [passo de configuração dos metadados](#metadata). A equipe de criação do _boilerplate_ irá definir quais variáveis serão estas. Para fins de exemplificação, considere as seguintes variáveis do _boilerplate_ do [WordPress](https://br.wordpress.org/):

```bash
PORT=8081
DB_ROOT_PASSWD=secret
DB_PASSWD=secret
DATA_WP=%GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%_wp
BACKUP=%GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%_backup
WP_DEBUG=true
WP_ALLOW_MULTISITE=false
```

## 4. Utilize as _keywords_ de customização {#keyword}

De forma a permitir ao [autômato _Genesis_]({{ site.baseurl }}/docs/architecture#genesis) realizar a customização de alguns aspectos da aplicação, são disponibilizadas algumas palavras-chave de uso reservado (_keywords_) que são substiuídas no momento do provisionamento a partir do _boilerplate_. São elas:

- `%GENESIS_PROJECT_UNIX%`: Nome _unix_ do projeto;
- `%GENESIS_PROJECT_NAME%`: Nome legível do projeto;
- `%GENESIS_APP_UNIX%`: Nome _unix_ da aplicação;
- `%GENESIS_ACTUAL_YEAR%`: Ano atual, com 4 dígitos; e
- `%GENESIS_VERSION%`: Um número de versão fictício, no padrão "`0.YY.MM-dev.1`".

Você pode optar por utilizar ou não estas _keywords_ no seu _boilerplate_. O autômato irá substituí-las em todos os arquivos não-ocultos (com exceção dos arquivos `.env.example`, `.env.ci.example` e `.env.cli.example`, onde também serão substituídas).

## 5. Conteinerize seu _boilerplate_ {#docker}

Normalmente, no próprio site da linguagem ou arcabouço de desenvolvimento utilizado há documentação sobre como conteinerizar o software desenvolvido utilizando o [Docker](https://www.docker.com). Veja como exemplo o tutorial "[_Dockerize Vue.js App_](https://v2.vuejs.org/v2/cookbook/dockerize-vuejs-app.html)" na documentação oficial do VueJS.

Algumas vezes, em ambiente de desenvolvimento, pode ser preferível não utilizar containers, porém para tornar a aplicação derivada do _boilerplate_ apta ao _deploy_ na plataforma, será necessário conteinerizar. Claro, <u>isto não se aplica a aplicações que naturalmente não serão distribuídas na Web</u>, tal como código nativo para Google Android (em Kotlin ou Java), código nativo para Apple iOS (em Swift ou Objective-C) ou artefatos de software especializados encapsulados em pacotes para gerenciadores de dependência, [como citado anteriormente](#base).

A plataforma **embrapa.io** é agnóstica quanto ao orquestrador de containers em nuvem, [podendo trabalhar com diversas soluções]({{ site.baseurl }}/docs/cluster). Mas padroniza o ambiente local de desenvolvimento com o uso de [Docker Compose](https://docs.docker.com/compose/), sendo este também um dos _drivers_ de orquestração em nuvem. Assim, para fins desta documentação, <u>utilizaremos o Docker Compose para exemplificar o processo de contenerização</u>.

Conforme comentado previamente no [capítulo de introdução]({{ site.baseurl }}/docs/introduction#boilerplate), existem alguns serviços que precisam ser disponibilizados no _stack_ de containers da aplicação: _backup_, _restore_, _sanitize_ e _test_. Para entender melhor o papel de cada um, observe o arquivo `docker-compose.yaml` de um _boilerplate_ para instanciar o [WordPress](https://br.wordpress.org/):

```yaml
version: '3.9'

services:
  db:
    image: mariadb:latest
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWD}
      MYSQL_DATABASE: %GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${DB_PASSWD}
    healthcheck:
      test: mysql %GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX% --user=wordpress --password='${DB_PASSWD}' --silent --execute "SELECT 1;"
      interval: 1m30s
      timeout: 10s
      start_period: 30s
      retries: 4

  wordpress:
    build: .
    depends_on:
      - db
    volumes:
      - data_wp:/var/www/html
    ports:
      - ${PORT}:80
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: ${DB_PASSWD}
      WORDPRESS_DB_NAME: %GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_DEBUG', ${WP_DEBUG});
        define('WP_ALLOW_MULTISITE', ${WP_ALLOW_MULTISITE});
        define('WP_SENTRY_PHP_DSN', '${SENTRY_DSN}');
        define('WP_SENTRY_ERROR_TYPES', E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_USER_DEPRECATED);
        define('WP_SENTRY_VERSION', @array_shift(explode('-', '${VERSION}')));
        define('WP_SENTRY_ENV', '${STAGE}' );
    healthcheck:
      test: curl --fail -s http://localhost:80/ || exit 1
      interval: 1m30s
      timeout: 10s
      start_period: 30s
      retries: 4

  backup:
    image: mariadb:latest
    restart: "no"
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWD}
      MYSQL_DATABASE: %GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${DB_PASSWD}
    depends_on:
      - db
    links:
      - db
    volumes:
      - data_backup:/backup
      - data_wp:/var/www/html
    command: >
      sh -c  "set -ex &&
        export BACKUP_DIR=${COMPOSE_PROJECT_NAME}_${VERSION}_$$(date +'%Y-%m-%d_%H-%M-%S') &&
        cd /backup && mkdir $$BACKUP_DIR &&
        mysqldump --host db -uroot -p${DB_ROOT_PASSWD} %GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX% > $$BACKUP_DIR/db.sql &&
        cp -R /var/www/html $$BACKUP_DIR/ &&
        tar -czf $$BACKUP_DIR.tar.gz $$BACKUP_DIR &&
        rm -rf /backup/$$BACKUP_DIR"
    profiles:
      - cli

  restore:
    image: mariadb:latest
    restart: "no"
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWD}
      MYSQL_DATABASE: %GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${DB_PASSWD}
    depends_on:
      - db
    links:
      - db
    volumes:
      - data_backup:/backup
      - data_wp:/var/www/html
    command: >
      sh -c  "set -ex &&
        export FILE_TO_RESTORE=${BACKUP_FILE_TO_RESTORE:-no_file_to_restore} &&
        test -f /backup/$$FILE_TO_RESTORE &&
        RESTORE_DIR=$$(mktemp) &&
        tar -xf /backup/$$FILE_TO_RESTORE -C $$RESTORE_DIR --strip-components=1 &&
        mysql %GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX% < $$RESTORE_DIR/db.sql &&
        cp -Rf $$RESTORE_DIR/html/. /var/www/html &&
        find /var/www/html -type d -exec chmod 755 {} \; &&
        find /var/www/html -type f -exec chmod 644 {} \; &&
        rm -rf $$RESTORE_DIR"
    profiles:
      - cli

  sanitize:
    image: mariadb:latest
    restart: "no"
    depends_on:
      - db
    links:
      - db
    command: >
      sh -c  "mysqlcheck --host db -uroot -p${DB_ROOT_PASSWD} -o --auto-repair --flush %GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%"
    profiles:
      - cli

volumes:
  data_wp:
    name: ${DATA_WP}
    external: true

  data_backup:
    name: ${BACKUP}
    external: true
```

Observe que as variáveis de ambiente utilizadas acima são as mesmas injetadas pelos arquivos `.env` e `.env.ci`, [nos exemplos discutidos anteriormente](#env). Os serviços que serão chamados por linha de comando (`test`, `sanitize`, `backup` e `restore`) possuem o `profile: [ 'cli' ]`, indicando que serão carregados apenas quando o arquivo `.env.cli` for utilizado (onde é passado, especificamente, `COMPOSE_PROFILES=cli`). Um exemplo de chamada destes serviços seria portanto:

```bash
env $(cat .env.cli) docker-compose run --rm --no-deps backup
```

Quando for realizado o _deploy_ do _stack_ de containers, todos os demais serviços "não-CLI" serão carregados. Mais especificamente, o [autômato _Deployer_]({{ site.baseurl }}/docs/architecture#deployer) irá injetar as variáveis do arquivo `.env.ci` alterando conforme o _environment_. Assim, caso se trate de uma _build_ em estágio _alpha_ o `COMPOSE_PROFILES` terá o valor `alpha`. Isto possibilita que o usuário carregue determinados serviços apenas em determinados ambientes. Por exemplo, pode ser interessante ao desenvolvedor carregar a ferramenta [phpMyAdmin](https://www.phpmyadmin.net) para auditar seu BD quando a aplicação estiver em estágio _alpha_ ou _beta_, mas não (por questão de segurança) quando estiver em estágio _release_.

É fortemente recomendado que todos os serviços "não-CLI" tenham o atributo de `healthcheck` devidamente configurado. Este atributo permite que [as aplicações sejam monitoradas]({{ site.baseurl }}/docs/health), agregando informação à [dashboard da plataforma](https://dashboard.embrapa.io). O atributo `restart` destes serviços deve estar setado para `unless-stopped`, de forma a garantir maior resiliência da aplicação.

É muito importante que os **volumes** sejam configurados corretamente. Para uso com o _driver_ do Docker Compose, o autômato _Deployer_ da plataforma executa uma série de validações. Dentre elas, somente são aceitos volumes configurados com o atributo `external` igual à `true`. Assim, para instanciar a aplicação em amebiente de desenvolvimento, os desenvolvedores precisarão, por exemplo, fazer algo do tipo:

```bash
docker volume create --driver local --opt type=none --opt device=$(pwd)/data/wp --opt o=bind agroproj_agroapp_wp
```

Em ambientes de _deploy_ (_alpha_, _beta_ e _release_) o volume será criado automaticamente utilizando o _driver_ de _storer_ configurado no _cluster_. Por exemplo, para um [_cluster_ com orquestrador **Docker Compose** utilizando como _storer_ o **NFSv4**]({{ site.baseurl }}/docs/cluster), teríamos algo do tipo:

```bash
docker volume create --driver local --opt type=nfs --opt o=addr=storage.sede.embrapa.br,rw --opt device=:/mnt/nfs/cluster.sede.embrapa.br/agroproj_agroapp_alpha_wp agroproj_agroapp_alpha_wp
```

Por segurança, todos os volumes alocados no _stack_ de containers são checados antes do _deploy_. Assim, **não é possível uma aplicação referenciar e acessar o volume de outra aplicação**. Uma vez que os volumes estejam criados, o desenvolvedor da aplicação poderá instanciá-la com o seguinte comando:

```bash
env $(cat .env.ci) docker-compose up --force-recreate --build --remove-orphans -d --wait
```

Em ambientes de _deploy_ que utilizem o _driver_ do Docker Compose o comando será semelhante, porém existem algumas garantias para assegurar que não sejam, por exemplo, chamados serviços do tipo CLI.

## 6. Implemente os "serviços-padrões" {#cli}

Conforme já comentado, existem alguns serviços do tipo CLI que são requeridos pela plataforma em todas as aplicações instanciadas. Assim, os _boilerplates_ devem prover uma versão inicial destes serviços no _stack_ de containers, que poderá ser aprimorada pelo desenvolvedor da aplicação posteriormente. Detalharemos mais cada um deles a seguir.

Um ponto que deve-se ter em mente é que <u>nem sempre fará sentido a aplicação possuir alguns destes serviços</u>. Por exemplo, uma aplicação do tipo PWA é executada inteiramente do lado do cliente, não tendo qualquer persistência de dados (ou estado) na nuvem. Assim, não faz sentido disponibilizar serviços de _backup_ e _restore_. Nestes casos, visando não gerar problemas com a automação interna e externa à plataforma, recomenda-se o uso da imagem `tianon/true` nestes serviços, tal como segue:

```yaml
backup:
  image: tianon/true
  restart: "no"
  profiles:
    - cli

restore:
  image: tianon/true
  restart: "no"
  profiles:
    - cli
```

#### a) _test_ {#cli:test}

Este serviço executa entre os processos de _build_ e _deploy_ do [autômato de _Deployer_]({{ site.baseurl }}/docs/architecture#deployer), aplicando os **testes unitários** (previamente implementados) na aplicação. Assim, antes de preparar o serviço, é necessário integrar uma biblioteca ou pacote para testes unitários e estabelecer um conjunto mínimo de testes que fará parte do _boilerplate_ e poderá, mais tarde, ser aprimorado pelo desenvolvedor da aplicação.

> **Atenção!** Na versão de **PoC** da plataforma este serviço ainda <u>não está sendo utilizado</u>.

#### b) _backup_ {#cli:backup}

A plataforma **embrapa.io** fornece, por meio da _dashboard_, uma [funcionalidade para geração de _backups_ por demanda]({{ site.baseurl }}/docs/backup) para os mantenedores dos projetos de ativos digitais. Para que funcione corretamente, é necessário que exista o serviço _backup_ na _stack_ de containers da aplicação. Além disso, deve-se configurar um volume utilizando a palavra reservada `backup`. [Veremos a seguir](#metadata) como deixar pré-estabelecido no _boilerplate_ este volume.

De forma geral, o serviço deverá gerar os _dumps_ de todos os BDs, copiar os arquivos de _upload_ e tudo mais que for necessário para possibilitar a restauração do estado atual da aplicação, compactar em um arquivo no formato `%GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%_${STAGE}_${VERSION}_$$(date +'%Y-%m-%d_%H-%M-%S').tar.gz` e salvar no volume `backup`.

Na [seção anterior](#docker) é possível observar este e os demais serviços CLI devidamente configurados no `docker-compose.yaml` para um _boilerplate_ do [WordPress](https://br.wordpress.org). Repare que naquele exemplo é realizado o _dump_ do [MariaDB](https://mariadb.org) e é copiada integralmente a pasta `/var/www/html`, com todos os arquivos do WordPress. Quando da execução do processo de _backup_, o arquivo `.tar.gz` resultante é copiado para o volume `backup` que é então montado pelo [autômato _Doctor_]({{ site.baseurl }}/docs/architecture#doctor), que atribui uma URL (protegida por login e senha de acesso) e informa os mantenedores do projeto via e-mail.

Repare que este serviço é essencial para manter a autonomia dos mantenedores dos projetos de ativos digitais, reforçando as diretrizes de DevOps adotadas pela plataforma **embrapa.io**.

#### c) _restore_ {#cli:restore}

O serviço de _restore_ objetiva, principalmente, auxiliar os mantenedores do projeto tornando rápida e fácil a recuperação do _backup_ da aplicação. Mais especificamente, este serviço irá receber um arquivo do tipo `.tar.gz` por meio da variável de ambiente `BACKUP_FILE_TO_RESTORE`, passada por linha de comando, descompactar e restaurar todos os dados nos containers que formam a aplicação:

```bash
env $(cat .env.cli) BACKUP_FILE_TO_RESTORE=agroproj_agroapp_alpha_1.22.7-alpha.34_2022-06-23_09-30-04.tar.gz docker-compose run --rm --no-deps restore
```

#### d) _sanitize_ {#cli:sanitize}

A plataforma **embrapa.io** implementa um [processo de higienização/otimização das aplicações]({{ site.baseurl }}/docs/health). Este processo pode ser relevante para aplicações que tenham tarefas de _garbage collection_, análise/reparação/otimização de esquemas em seus BDs, limpeza de cache, etc. Nada impede, obviamente, a equipe de desenvolvimento da aplicação desenvolver seus próprios _schedular jobs_ para executar as mesmas tarefas na forma de containers no _stack_ da aplicação. Entretanto, este serviço visa simplificar este trabalho.

No `docker-compose.yaml` do [exemplo da seção anterior](#docker) é utilizada a ferramenta de linha de comando `mysqlcheck` para efetuar a [manutenção das tabelas](https://mariadb.com/kb/en/mysqlcheck/) do banco de dados [MariaDB](https://mariadb.org) utilizado no [WordPress](https://br.wordpress.org). Outras ferramentas e comandos similares que podem ser utilizadas neste serviço são o [_vacuum_ do PostgreSQL](https://www.postgresql.org/docs/current/sql-vacuum.html), o [_shrink_ do SQL Server](https://docs.microsoft.com/en-us/sql/relational-databases/databases/shrink-a-database), o [_compact_ do MongoDB](https://www.mongodb.com/docs/manual/reference/command/compact/), etc.

## 7. Configure os metadados {#metadata}

Todo _boilerplate_ e, consequentemente, toda aplicação na plataforma **embrapa.io** possui um diretório na raiz denominado `.embrapa`. Neste diretório ficam armazenados todos os metadados necessários à parametrização dos processos de DevOps da plataforma. Assim, com exceção do orquestrador [Docker Compose](https://docs.docker.com/compose/), cujo arquivo de configuração fica na raiz da aplicação pois também é utilizado em ambiente de desenvolvimento, recomenda-se fortemente que as configurações que parametrizam as ferramentas de orquestração de containers ([Docker Swarm](https://docs.docker.com/engine/swarm/), [Kubernetes](https://kubernetes.io/pt-br/), [LXC](https://linuxcontainers.org), etc) e PaaS ([RedHat OpenShift](https://www.redhat.com/pt-br/technologies/cloud-computing/openshift), [AWS](https://www.datamation.com/cloud-computing/amazon-web-services.html), [Microsoft Azure](https://www.datamation.com/cloud-computing/microsoft-azure.html), [Google Cloud](https://www.datamation.com/cloud-computing/google-cloud-platform.html), [Heroku](https://www.heroku.com), etc) fiquem, quando possível, neste diretório.

Além disso, neste diretório fica o arquivo `settings.json`, que possui informações necessárias utilizadas pelos [diversos componentes do **embrapa.io**]({{ site.baseurl }}/docs/architecture). Para cada _boilerplate_ criado, será necessário configurar corretamente este arquivo. Vamos tomar como exemplo o _boilerplate_ para WordPress:

```json
{
  "boilerplate": "wordpress",
  "platform": "php",
  "label": "Instância básica do WordPress",
  "description": "Sistema livre e aberto de gestão de conteúdo para internet, baseado em PHP com banco de dados MySQL, voltado principalmente para a criação de páginas eletrônicas (sites e portais) e blogs online.",
  "references": [
    { "label": "Site oficial do WordPress", "url": "https://wordpress.org/"}
  ],
  "maintainers": [
    { "name": "Camilo Carromeu", "email": "camilo.carromeu@embrapa.br", "phone": "+55 (67) 9 8111-8060" }
  ],
  "variables": {
    "default": [
      { "name": "PORT", "type": "PORT" },
      { "name": "DB_ROOT_PASSWD", "type": "PASSWORD" },
      { "name": "DB_PASSWD", "type": "PASSWORD" },
      { "name": "DATA_WP", "value": "wp", "type": "VOLUME" },
      { "name": "BACKUP", "value": "backup", "type": "VOLUME" },
      { "name": "WP_DEBUG", "value": "true", "type": "TEXT" },
      { "name": "WP_ALLOW_MULTISITE", "value": "false", "type": "TEXT" }
    ],
    "alpha": [],
    "beta": [],
    "release": [
      { "name": "WP_DEBUG", "value": "false", "type": "TEXT" }
    ]
  },
  "orchestrators": [ "DockerCompose" ]
}
```

O atributo `boilerplate` deve conter o nome único do _boilerplate_ em toda a plataforma e deve seguir o padrão _unix_ de nomes de entidades (`/^[a-z0-9-]{3,}$/`).

O atributo `platform` corresponde ao SDK do [Sentry](https://sentry.io) que deverá ser utilizado neste _boilerplate_. As _keywords_ para as [plataformas aceitas pelo Sentry](https://docs.sentry.io/platforms/) são: ```android```, ```apple```, ```dart```, ```dotnet```, ```electron```, ```elixir```, ```flutter```, ```go```, ```java```, ```javascript```, ```kotlin```, ```native```, ```node```, ```php```, ```python```, ```react-native```, ```ruby```, ```rust```, ```unity``` e ```unreal```. Defina corretamente a palavra-chave no atributo para assegurar a melhor experiência dos desenvolvedores no [monitoramento de erros da aplicação]({{ site.baseurl }}/docs/bug).

Os atributos `label`, `description`, `references` e `maintainers` (auto-explicativos) e são renderizados pela [_dashboard_ da plataforma](https://dashboard.embrapa.io) no momento da escolha do _boilerplate_ na [criação de aplicações]({{ site.baseurl }}/docs/app).

![Renderização das infos do boilerplate]({{ site.baseurl }}/assets/img/boilerplate/02.png)

No atributo `variables` são inseridas as _environment variables_ que parametrizam a aplicação, ou seja, as mesmas contidas no arquivo `.env`. A plataforma **embrapa.io** carrega estas variáveis, com seus respectivos valores padrão, no momento da [configuração da _build_]({{ site.baseurl }}/docs/build). Serão carregadas primeiro as variáveis do atributo `default` e, em seguida, sobreescrevendo estas, as variáveis dos atributos homônimos ao estágio de maturidade da _build_ que está sendo configurada (`alpha`, `beta` ou `release`). No exemplo acima, está sendo habilitado por padrão o _debug_ (variável `WP_DEBUG`) para as _builds_ em estágio de testes internos (_alpha_) e externos (_beta_), e desabilitado para as _builds_ em produção (_release_).

> **Atenção!** Durante a [configuração da _build_]({{ site.baseurl }}/docs/build) os valores padrão para as variáveis definidos aqui, bem como aqueles gerados randômicamente, poderão ser alterados pelo usuário.

As variáveis definidas podem ser de cinco tipos:

- **TEXT**: Uma sequência de caracteres livre, porém **sem espaços** (`/^[^\s]*$/`). Caso não seja passado um valor padrão (atributo `value`), será deixado em branco.
- **PASSWORD**: Utilizado para armazenar **senhas**. Uma sequência de caracteres livre, porém **sem espaços** (`/^[^\s]*$/`). Caso não seja passado um valor padrão (atributo `value`), será atribuída uma _string_ randômica (`/^[a-zA-Z0-9]{16}$/`).
- **SECRET**: Utilizado para armazenar **chaves privadas**. Uma sequência de caracteres livre, porém **sem espaços** (`/^[^\s]*$/`). Caso não seja passado um valor padrão (atributo `value`), será atribuída uma _string_ randômica (`/^[a-zA-Z0-9]{256}$/`).
- **PORT**: Utilizado para armazenar as **portas expostas publicamente** da aplicação. O valor desta variável será setado na [configuração da _build_]({{ site.baseurl }}/docs/build) considerando as portas vagas do _cluster_ escolhido para _deploy_.
- **VOLUME**: Utilizado para referenciar os **volumes** da aplicação. Os valores inseridos aqui seerão utilizados na [configuração da _build_]({{ site.baseurl }}/docs/build), no passo de definição de volumes, para preencher automaticamente a lista dos volumes da aplicação.

![Volumes pré-configurados a partir das variáveis de ambiente]({{ site.baseurl }}/assets/img/boilerplate/03.png)

Repare que no "**3º Passo - Volumes**", mostrado na imagem acima, a listagem de volumes foi pré-carregada de acordo com a variáveis deste tipo declaradas nos metadados do _boilerplate_ utilizado na aplicação. Da mesma forma, todas as variáveis serão pre-carregadas no "**4º Passo - Variáveis**" com os valores definidos no `settings.json` ou gerados automaticamente. Na imagem abaixo é mostrado um exemplo da lista de variáveis pré-carregada (desconsidere as variáveis do tipo **SERVER**, que são aquelas presentes no arquivo `.env.ci` e injetadas em tempo de _deploy_).

![Lista de variáveis pré-carregadas com base nos metadados]({{ site.baseurl }}/assets/img/boilerplate/04.png)

Por fim, o atributo `orchestrators` lista os **orquestradores para os quais o _boilerplate_ está homologado**. Cada orquestrador irá exigir parâmetros específicos para permitir o _deploy_ das aplicações. Por exemplo, para que o _boilerplate_ esteja aderente ao [Kubernetes](https://kubernetes.io/pt-br/), espera-se que exista um diretório "`.embrapa/k8s`" contendo os arquivos de configuração necessários. A equipe mantenedora do _boilerplate_ deve, na medida do possível, configurá-lo e homologá-lo na maior quantidade possível de orquestradores aceitos pela plataforma **embrapa.io**.

## 8. Distribua o _boilerplate_ {#publish}

Para distribuir o _boilerplate_ para uso pela comunidade de desenvolvedores, será necessário disponibilizá-lo no grupo de repositórios `/io/boilerplate` do [GitLab da plataforma](https://git.embrapa.io). Além disso, ele deverá constar e estar ativo na [listagem de _boilerplates_](http://localhost:8029/io/boilerplate/metadata/-/blob/main/boilerplates.json). Para ser inserido na listagem, os mantenedores precisarão passar para a [equipe de suporte do **embrapa.io**](mailto:io@embrapa.br) o nome _unix_ do _boilerplate_, um nome legível (rótulo), uma breve descrição (de uma linha) e um ícone que melhor represente as tecnologias utilizadas. Atualmente, os ícones permitidos são:

<li class="cell"><i class="fa-brands fa-android"></i><div class="subtile">fa-brands<br />fa-android</div></li>
<li class="cell"><i class="fa-brands fa-angular"></i><div class="subtile">fa-brands<br />fa-angular</div></li>
<li class="cell"><i class="fa-brands fa-apple"></i><div class="subtile">fa-brands<br />fa-apple</div></li>
<li class="cell"><i class="fa-solid fa-code-branch"></i><div class="subtile">fa-solid<br />fa-code-branch</div></li>
<li class="cell"><i class="fa-brands fa-golang"></i><div class="subtile">fa-brands<br />fa-golang</div></li>
<li class="cell"><i class="fa-brands fa-java"></i><div class="subtile">fa-brands<br />fa-java</div></li>
<li class="cell"><i class="fa-brands fa-js"></i><div class="subtile">fa-brands<br />fa-js</div></li>
<li class="cell"><i class="fa-brands fa-microsoft"></i><div class="subtile">fa-brands<br />fa-microsoft</div></li>
<li class="cell"><i class="fa-brands fa-node-js"></i><div class="subtile">fa-brands<br />fa-node-js</div></li>
<li class="cell"><i class="fa-brands fa-php"></i><div class="subtile">fa-brands<br />fa-php</div></li>
<li class="cell"><i class="fa-solid fa-puzzle-piece"></i><div class="subtile">fa-solid<br />fa-puzzle-piece</div></li>
<li class="cell"><i class="fa-brands fa-python"></i><div class="subtile">fa-brands<br />fa-python</div></li>
<li class="cell"><i class="fa-brands fa-react"></i><div class="subtile">fa-brands<br />fa-react</div></li>
<li class="cell"><i class="fa-brands fa-vuejs"></i><div class="subtile">fa-brands<br />fa-vuejs</div></li>
<li class="cell"><i class="fa-brands fa-wordpress"></i><div class="subtile">fa-brands<br />fa-wordpress</div></li>
