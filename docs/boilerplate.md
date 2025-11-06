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
*[UI]: User Interface
*[GPL]: General Public License

De forma geral, as aplicações da plataforma **Embrapa I/O** são _forks_ de repositórios pré-existentes denominados _boilerplates_. Estes repositórios são aplicações funcionais, em determinada linguagem de programação ou _framework_, já estruturadas para funcionar corretamente nos _pipelines_ e processos de DevOps da plataforma. A ideia é fomentar a padronização e o reuso de código-fonte. Neste tutorial veremos como configurar corretamente um novo _boilerplate_ para distribuí-lo no catálogo da plataforma, de modo a possibilitar que outras equipes de desenvolvimento de ativos digitais possam fazer uso.

Para criar e disponibilizar seu _boilerplate_, você precisará seguir os seguintes passos:

1. [Crie uma "aplicação-base"](#base);
2. [Integre ao Sentry (para _error tracking_)](#bug);
3. [Integre ao Matomo (para _analytics_)](#analytics);
4. [Integre ao SonarQube (para _code quality_ e _secure analysis_)](#code);
5. [Crie os arquivos de _environment variables_](#env);
6. [Utilize as _keywords_ de customização](#keyword);
7. [Containerize seu _boilerplate_](#docker);
8. [Implemente os "serviços-padrões"](#cli): [_test_](#cli:test), [_backup_](#cli:backup), [_restore_](#cli:restore) e [_sanitize_](#cli:sanitize);
9. [Configure os metadados](#metadata);
10. [Configure outros orquestradores](#orchestrator);
11. [Documente e inclua a licença](#readme); e
12. [Distribua o _boilerplate_](#publish).

É possível [criar um repositório de aplicação]({{ site.baseurl }}/docs/app) sem utilizar um _boilerplate_. Esta função é útil para instanciar na plataforma sistemas que antecedem o próprio **Embrapa I/O**. Entretanto, será necessário criar manualmente um repositório no [GitLab](https://git.embrapa.io) e adaptar seu código fonte de forma que ele tenha **toda a estrutura de pastas e arquivos requeridos para um _boilerplate_** (ou seja, seguir os mesmos passos aqui descritos). Em seguida, no momento de criar a aplicação pela _dashboard_, selecione a opção de um "**repositório pré-existente**" (conforme a imagem abaixo).

![Criando uma aplicação sem o boilerplate]({{ site.baseurl }}/assets/img/boilerplate/01.png)

## 1. Crie uma "aplicação-base" {#base}

O primeiro passo para iniciar a construção de seu _boilerplate_ é criar uma aplicação funcional. Esta aplicação terá funcionalidades que são **requisitos comuns** de ativos digitais para a agricultura, de forma que o reúso deste código-base seja demandado. Por exemplo, poderíamos ter dois _boilerplates_ de PWA utilizando os _frameworks_ [VueJS](https://vuejs.org) e [Vuetify](https://vuetifyjs.com): um com sistema de _login_ de usuários e outro sem. No catálogo de _boilerplates_ o usuário poderia escolher qual utilizar tomando esta característica como base.

> **Atenção!** O _boilerplate_ deve ser uma aplicação com padrões rigorosos de qualidade de código, bem como utilizando as **versões mais recentes**, LTS, da linguagem e arcabouço de programação. Por exemplo, se estiver sendo criado em [PHP](https://php.net), espera-se que esteja plenamente aderente aos [PHP Standards Recommendations](https://www.php-fig.org/psr/).

Assim, é fortemente recomendado que a criação de um _boilerplate_ tenha como ponto de partida o _Get Started_ do próprio arcabouço de programação. A imensa maioria dos _frameworks_ modernos possuem ferramentas CLI do tipo _standard tooling_, que permitem a criação de estruturas padronizadas de projetos de software. Adicionalmente, priorize o uso de linguagens, arcabouços e pacotes que tenham licença _open source_ permissivas, de forma a não "contaminar" o [licenciamento da aplicação final]({{ site.baseurl }}/docs/licensing). Por fim, tenha em mente que softwares são descontinuados. Portanto, para garantir uma vida longa e próspera ao seu _boilerplate_ (e às aplicações derivadas dele), dê preferência a tecnologias consolidadas, com vastas comunidades e que tenham se provado no tempo. Tome como exemplos: [Go Gin Gonic](https://gin-gonic.com/docs/quickstart/), [Java Spring Boot](https://spring.io/guides/gs/spring-boot/), [PHP Laravel](https://laravel.com/docs/4.2/quick), [PHP Symfony](https://symfony.com/doc/current/getting_started/index.html), [Python Django](https://docs.djangoproject.com/en/4.0/intro/tutorial01/), [ReactJS](https://reactjs.org/docs/add-react-to-a-website.html), [React Native](https://reactnative.dev/docs/0.60/enviroment-setup) e [VueJS/Vuetify](https://vuetifyjs.com/en/getting-started/installation/).

Todos os _boilerplates_ da plataforma ficam disponíveis **publicamente** no mesmo [grupo de repositórios no GitLab](https://git.embrapa.io/io/metadata/boilerplate). Você pode iniciar a criação de seu _boilerplate_ em um [repositório de aplicação dentro de um projeto seu na plataforma]({{ site.baseurl }}/docs/introduction#project) e, posteriormente, efetuar um _fork_ para este grupo, ou [solicitar a criação de um novo repositório dentro do grupo](mailto:io@embrapa.br). Para todos os efeitos, a construção do _boilerplate_ seguirá as diretrizes de uma aplicação convencional da plataforma, tal como o [controle de _issues_ e _milestones_]({{ site.baseurl }}/docs/kanban).

Após criar a aplicação-base, você deverá customizá-la. Antes de começar a alterá-la, entretanto, verifique se existem ferramentas do tipo **_linter_** e **_formatter_** devidamente configuradas em sua IDE para a linguagem de programação que está utilizando. Falamos mais sobre isso na [seção de boas práticas de desenvolvimento]({{ site.baseurl }}/docs/practices). É importante também configurar o [EditorConfig](https://editorconfig.org). Como sugestão, crie um arquivo `.editorconfig` na raiz com o seguinte conteúdo:

```ini
[*]
charset = utf-8
end_of_line = lf
indent_size = 2
indent_style = space
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

Inicie a customização da aplicação-base incluindo aspectos que são comumente utilizados nos ativos digitais da Embrapa. Por exemplo, uma identidade visual aderente aos padrões estabelecidos pela área de comunicação, a logo da Empresa conforme o manual de uso, estrutura de menus, cabeçalho e rodapé, e telas que são normalmente padronizadas (p.e., a tela de "Sobre"). Adicionalmente, inclua funcionalidades mais complexas que caracterizem seu _boilerplate_, tal como requisitos não-funcionais (p.e., registro e _login_ de usuários) ou mesmo funcionais (p.e., cadastro e gestão de fazendas). O domínio de negócio dos ativos digitais da plataforma **Embrapa I/O** é abrangente, porém bem definida: "**o agronegócio**". Portanto, <u>existem requisitos funcionais que serão de uso comum</u>.

Caso esteja desenvolvendo o _boilerplate_ para uma **API Web**, comprometa-se em torná-lo aderente ao [AgroAPI](https://www.agroapi.cnptia.embrapa.br), de forma que as aplicações criadas a partir dele possam compor o catálogo da Embrapa quando forem publicadas. Simuladores, algoritmos de aprendizado de máquina, visão computacional e **artefatos de software especializados** de forma geral, <u>devem ser encapsulados em componentes específicos</u>. Neste caso, recomenda-se que tenham seu próprio repositório de código e sejam integrados nas aplicações na forma de **pacotes privados** (gerenciados por _dependency managers_, tal como o [composer](https://getcomposer.org/), o [npm](https://www.npmjs.com/), o [gradle](https://gradle.org) ou o [maven](https://maven.apache.org/)). Assim, um _boilerplate_ para uma aplicação [TensorFlow.js](https://www.tensorflow.org/js), por exemplo, seria na verdade um pacote NPM. No [capítulo sobre integração]({{ site.baseurl }}/docs/integration) são detalhados outros formatos de aplicação, tal como [_remotes_ para compor _micro-frontends_](https://ruairidh.dev/introduction-to-micro-frontends/).

## 2. Integre ao _error tracking_ {#bug}

Conforme [já detalhado anteriormente]({{ site.baseurl }}/docs/bug), a plataforma **Embrapa I/O** é integrada à ferramenta [Sentry](https://sentry.io), de _error tracking_. Assim, no momento em que um projeto ou uma aplicação é criada pela [_dashboard_ da plataforma](https://dashboard.embrapa.io), o [autômato _Genesis_]({{ site.baseurl }}/docs/architecture#genesis) cria a entidade correlata na ferramenta Sentry e atribui a equipe. Pela _dashboard_ será então possível à equipe de desenvolvimento do ativo obter o DSN de _error tracking_.

![Acesso ao DSN pelo card da aplicação]({{ site.baseurl }}/assets/img/bug/02.png)

Para que funcione corretamente, será necessário preparar o _boilerplate_ para o Sentry. Este possui SDKs específicos para [diversas linguagens e arcabouços de programação](https://docs.sentry.io/platforms/). Por exemplo, para utilizar em um PWA em VueJS o seguinte trecho de código foi adicionado ao _bootstrap_ da aplicação:

```js
import * as Sentry from '@sentry/vue'
import { BrowserTracing } from '@sentry/tracing'

Sentry.init({
  Vue,
  dsn: process.env.VUE_APP_SENTRY_DSN,
  release: process.env.VUE_APP_VERSION.split('-')[0],
  environment: process.env.VUE_APP_STAGE,
  integrations: [
    new BrowserTracing({
      routingInstrumentation: Sentry.vueRouterInstrumentation(router),
      tracingOrigins: ['localhost', window.location.hostname, /^\//]
    })
  ],
  tracesSampleRate: 1.0
})
```

Dentre as variáveis de ambiente acima, o **DSN**, a **versão da _build_** (no atributo `release`) e o **estágio** (no atributo `environment`) [são injetados em tempo de _deploy_ pela plataforma](#env). A _keyword_ `%GENESIS_PROJECT_UNIX%` é [alterada pelo autômato _Genesis_ no momento do provisionamento da aplicação a partir do _boilerplate_](#keyword).

## 3. Integre ao _analytics_ {#analytics}

Similar ao _error tracking_ e conforme também [já detalhado anteriormente]({{ site.baseurl }}/docs/analytics), a plataforma **Embrapa I/O** é integrada à ferramenta [Matomo](https://matomo.org), utilizada para rastrear e analisar ações de usuários nas aplicações. Assim, no momento em que um projeto ou uma aplicação é criada pela [_dashboard_ da plataforma](https://dashboard.embrapa.io), o [autômato _Genesis_]({{ site.baseurl }}/docs/architecture#genesis) cria a entidade correlata na ferramenta Matomo e atribui a equipe. Pela _dashboard_ será então possível à equipe de desenvolvimento do ativo obter o identificador único de rastreamento ("Matomo Site ID").

![Sumário dos relatórios analíticos]({{ site.baseurl }}/assets/img/analytics/01.png)

Para que funcione corretamente, será necessário preparar o _boilerplate_ para o Matomo [incluindo um código de rastreamento](https://developer.matomo.org/guides/tracking-introduction). Por exemplo, para utilizar em um PWA em VueJS o seguinte trecho de código foi adicionado ao _router_ da aplicação (`/src/router/index.js`):

```js
import VueMatomo from 'vue-matomo'

Vue.use(VueMatomo, {
  host: 'https://hit.embrapa.io',
  siteId: process.env.VUE_APP_MATOMO_ID,
  router: router,
  preInitActions: [
    ['setCustomDimension', 1, process.env.VUE_APP_STAGE],
    ['setCustomDimension', 2, process.env.VUE_APP_VERSION]
  ]
})
```

Dentre as variáveis de ambiente acima, o **siteId**, o **estágio** e a **versão da _build_** são [injetados em tempo de _deploy_ pela plataforma](#env).

Caso esteja configurando o Matomo em um _boilerplate_ para aplicações do tipo _server-side_, é possível passar o `token_auth` no código de rastreamento para gerar relatórios analíticos mais detalhados. O **Embrapa I/O** injeta a variável de ambiente `MATOMO_TOKEN` com a chave para a API. Esta chave tem **permissão de escrita** no site e, por conta disso, é um dado sensível para a segurança das aplicações. Assim, valor real do `token_auth` é injetado apenas nos serviços de _deploy_ e _restart_ das aplicações. Nos demais serviços (tal como de `validate` ou `backup`) o valor injetado na variável `MATOMO_TOKEN` é uma chave aleatória, sem real permissão de acesso à API do Matomo.

> **Atenção!** Por questão de segurança, **jamais utilize a variável `MATOMO_TOKEN` em aplicações de _frontend_ ou exponha seu valor na interface do usuário!**

Um exemplo de uso do `token_auth` do Matomo injetado pelo **Embrapa I/O** pode ser visto no código PHP abaixo:

```php
require __DIR__ . '/vendor/autoload.php';

if (defined ('MATOMO_ID') && defined ('MATOMO_URL') && defined ('MATOMO_STAGE') && defined ('MATOMO_VERSION')) {
	$matomo = new MatomoTracker((int) MATOMO_ID, MATOMO_URL);

	if (defined ('MATOMO_TOKEN') && trim (MATOMO_TOKEN) != '') $matomo->setTokenAuth (MATOMO_TOKEN);

	$matomo->setCustomDimension(1, MATOMO_STAGE);
	$matomo->setCustomDimension(2, MATOMO_VERSION);

	$matomo->doTrackPageView($pageTitle);
}
```

Neste código está sendo utilizado o pacote [Matomo PHP Tracker](https://github.com/matomo-org/matomo-php-tracker), instalado via [PHP Composer](https://getcomposer.org/), que permite realizar [requisições específicas à API de rastreamento do Matomo](https://developer.matomo.org/api-reference/PHP-Matomo-Tracker).

## 4. Integre à ferramenta de _code quality_ e _secure analysis_ {#code}

O [SonarQube](https://www.sonarsource.com/products/sonarqube/) é uma popular ferramenta de **análise estática** usada no processo de revisão automática de código. Possui suporte a [29 linguagens de programação](https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/languages/overview/) e capacidade de detectar _bugs_, código duplicado, cobertura de testes de software (como testes unitários), alta complexidade ciclomática, entre outros problemas no código-fonte.

A ferramenta está [integrada à plataforma Embrapa I/O](https://code.embrapa.io) e pode, portanto, efetuar a análise do código-fonte de qualquer aplicação da plataforma (desde que a linguagem de programação seja suportada). Para permitir que esta análise seja realizada, é necessário inserir na raiz do _boilerplate_ o arquivo `.gitlab-ci.yml` com o seguinte conteúdo:

```yaml
image:
    name: sonarsource/sonar-scanner-cli:11
    entrypoint: [""]

variables:
  SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"
  GIT_DEPTH: "0"

stages:
  - build-sonar

build-sonar:
  stage: build-sonar

  cache:
    policy: pull-push
    key: "sonar-cache-$CI_COMMIT_REF_SLUG"
    paths:
      - "${SONAR_USER_HOME}/cache"
      - sonar-scanner/

  script:
    - >
      sonar-scanner
      -Dsonar.host.url="${SONAR_HOST_URL}"
      -Dsonar.projectKey="${CI_PROJECT_NAMESPACE}_${CI_PROJECT_NAME}"
      -Dsonar.qualitygate.wait=true
  allow_failure: true
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
    - if: $CI_COMMIT_BRANCH == 'main'
```

## 5. Crie os arquivos de _environment variables_ {#env}

Na plataforma as aplicações são parametrizadas por meio de **variáveis de ambiente**, que são injetadas diretamente durante os processos automatizados (_validate_, _deploy_, _backup_, _restart_, etc). Os principais arquivos utilizados são:

- `.env.io`: é injetado diretamente na chamada de linha de comando e, portanto, as variáveis neste arquivo terão precedência sobre todas as demais;
- `.env.sh`: substitui o arquivo acima quando são chamados serviços do tipo CLI (`test`, `sanitize`, `backup` ou `restore`); e
- `.env`: é carregado pelo Docker Compose ([veja abaixo](#docker)) a partir da raiz da aplicação.

Estes arquivos, portanto, são gerados pela plataforma e **não devem constar no _boilerplate_**. Ao invés disso, devem estar listados no arquivo `.gitignore` de forma a <u>não serem versionados pelo GIT</u>. Assim, para disponibilização junto ao _boilerplate_, é recomendado criar os arquivos acima, porém com o sufixo `.example` (estes sim versionados pelo GIT). Desta forma, os desenvolvedores que utilizarem o _boilerplate_ iniciarão a customização da aplicação copiando e renomeando estes arquivos para remover o sufixo.

As variáveis que compõem o arquivo `.env.io.example` são:

```bash
COMPOSE_PROJECT_NAME=%GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%
COMPOSE_PROFILES=development
IO_SERVER=localhost
IO_PROJECT=%GENESIS_PROJECT_UNIX%
IO_APP=%GENESIS_APP_UNIX%
IO_STAGE=development
IO_VERSION=%GENESIS_VERSION%
IO_DEPLOYER=first.surname@embrapa.br
SENTRY_DSN=GET_IN_DASHBOARD
MATOMO_ID=%GENESIS_MATOMO_ID%
MATOMO_TOKEN=
```

Acima as variáveis estão sendo setadas com valores propícios ao ambiente de desenvolvimento. Para distribuição do seu _boilerplate_, sugere-se utilizar algo semelhante. Repare na presença de _keywords_ (entre os caracteres `%`), que [serão explicadas em seguida](#keyword). Ao copiar e renomear o arquivo (retirando o sufixo `.example`) o desenvolvedor da aplicação precisará ajustar estes valores, tal como [inserir o DSN correto no Sentry]({{ site.baseurl }}/docs/bug).

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

## 6. Utilize as _keywords_ de customização {#keyword}

De forma a permitir ao [autômato _Genesis_]({{ site.baseurl }}/docs/architecture#genesis) realizar a customização de alguns aspectos da aplicação, são disponibilizadas algumas palavras-chave de uso reservado (_keywords_) que são substituídas no momento do provisionamento a partir do _boilerplate_. São elas:

- `%GENESIS_PROJECT_UNIX%`: Nome _unix_ do projeto;
- `%GENESIS_PROJECT_NAME%`: Nome legível do projeto;
- `%GENESIS_APP_UNIX%`: Nome _unix_ da aplicação;
- `%GENESIS_ACTUAL_YEAR%`: Ano atual, com 4 dígitos;
- `%GENESIS_VERSION%`: Um número de versão fictício, no padrão "`0.YY.MM-dev.1`"; e
- `%GENESIS_MATOMO_ID%`: Identificador único gerado e utilizado pelo [Matomo](#analytics).

Você pode optar por utilizar ou não estas _keywords_ no seu _boilerplate_. O autômato irá substituí-las em todos os arquivos não-ocultos (com exceção dos arquivos `.env.example`, `.env.io.example` e `.env.sh.example`, onde também serão substituídas).

## 7. Containerize seu _boilerplate_ {#docker}

Normalmente, no próprio site da linguagem ou arcabouço de desenvolvimento utilizado há documentação sobre como conteinerizar o software desenvolvido utilizando o [Docker](https://www.docker.com). Veja como exemplo o tutorial "[_Dockerize Vue.js App_](https://v2.vuejs.org/v2/cookbook/dockerize-vuejs-app.html)" na documentação oficial do VueJS.

Algumas vezes, em ambiente de desenvolvimento, pode ser preferível não utilizar containers, porém para tornar a aplicação derivada do _boilerplate_ apta ao _deploy_ na plataforma, será necessário conteinerizar. Claro, <u>isto não se aplica a aplicações que naturalmente não serão distribuídas na Web</u>, tal como código nativo para Google Android (em Kotlin ou Java), código nativo para Apple iOS (em Swift ou Objective-C) ou artefatos de software especializados encapsulados em pacotes para gerenciadores de dependência, [como citado anteriormente](#base).

A plataforma **Embrapa I/O** é agnóstica quanto ao orquestrador de containers em nuvem, [podendo trabalhar com diversas soluções]({{ site.baseurl }}/docs/cluster). Mas padroniza o ambiente local de desenvolvimento com o uso de [Docker Compose](https://docs.docker.com/compose/), sendo este também um dos _drivers_ de orquestração em nuvem. Assim, para fins desta documentação, <u>utilizaremos o Docker Compose para exemplificar o processo de conteinerização</u>.

Conforme comentado previamente no [capítulo de introdução]({{ site.baseurl }}/docs/introduction#boilerplate), existem alguns serviços que precisam ser disponibilizados no _stack_ de containers da aplicação: _backup_, _restore_, _sanitize_ e _test_. Para entender melhor o papel de cada um, observe o arquivo `docker-compose.yaml` de um _boilerplate_ para instanciar o [WordPress](https://br.wordpress.org/):

```yaml
services:
  db:
    image: mariadb:latest
    restart: unless-stopped
    volumes:
      - data_db:/var/lib/mysql
    networks:
      - stack
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWD}
      MYSQL_DATABASE: ${IO_PROJECT}_${IO_APP}
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${DB_PASSWD}
    healthcheck:
      test: mysql ${IO_PROJECT}_${IO_APP} --user=wordpress --password='${DB_PASSWD}' --silent --execute "SELECT 1;"
      interval: 20s
      timeout: 10s
      start_period: 20s
      retries: 5

  wordpress:
    image: 127.0.0.1:5000/${IO_PROJECT}_${IO_APP}_${IO_STAGE}_wordpress
    build: .
    depends_on:
      - db
    volumes:
      - data_wp:/var/www/html
    networks:
      - stack
    ports:
      - ${PORT}:80
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: ${DB_PASSWD}
      WORDPRESS_DB_NAME: ${IO_PROJECT}_${IO_APP}
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_DEBUG', ${WP_DEBUG});
        define('WP_ALLOW_MULTISITE', ${WP_ALLOW_MULTISITE});
        define('WP_SENTRY_PHP_DSN', '${SENTRY_DSN}');
        define('WP_SENTRY_ERROR_TYPES', E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_USER_DEPRECATED);
        define('WP_SENTRY_VERSION', @array_shift(explode('-', '${IO_VERSION}')));
        define('WP_SENTRY_ENV', '${IO_STAGE}' );
        define('WP_MATOMO_URL', 'https://hit.embrapa.io');
        define('WP_MATOMO_ID', ${MATOMO_ID});
        define('WP_MATOMO_TOKEN', '${MATOMO_TOKEN}');
        define('WP_MATOMO_STAGE', '${IO_STAGE}');
        define('WP_MATOMO_VERSION', '${IO_VERSION}');
    healthcheck:
      test: curl --fail -s http://localhost:80/ || exit 1
      interval: 20s
      timeout: 10s
      start_period: 30s
      retries: 5

  backup:
    image: mariadb:latest
    restart: "no"
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWD}
      MYSQL_DATABASE: ${IO_PROJECT}_${IO_APP}
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${DB_PASSWD}
    depends_on:
      - db
    links:
      - db
    volumes:
      - data_backup:/backup
      - data_wp:/var/www/html
    networks:
      - stack
    command: >
      sh -c  "set -ex &&
        export BACKUP_DIR=${IO_PROJECT}_${IO_APP}_${IO_STAGE}_${IO_VERSION}_$$(date +'%Y-%m-%d_%H-%M-%S') &&
        cd /backup && mkdir $$BACKUP_DIR &&
        mysqldump --host db -uroot -p${DB_ROOT_PASSWD} ${IO_PROJECT}_${IO_APP} > $$BACKUP_DIR/db.sql &&
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
      MYSQL_DATABASE: ${IO_PROJECT}_${IO_APP}
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${DB_PASSWD}
    depends_on:
      - db
    links:
      - db
    volumes:
      - data_backup:/backup
      - data_wp:/var/www/html
    networks:
      - stack
    command: >
      sh -c  "set -ex &&
        export FILE_TO_RESTORE=${BACKUP_FILE_TO_RESTORE:-no_file_to_restore} &&
        test -f /backup/$$FILE_TO_RESTORE &&
        RESTORE_DIR=$$(mktemp) &&
        tar -xf /backup/$$FILE_TO_RESTORE -C $$RESTORE_DIR --strip-components=1 &&
        mysql --host db -uroot -p${DB_ROOT_PASSWD} ${IO_PROJECT}_${IO_APP} < $$RESTORE_DIR/db.sql &&
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
    networks:
      - stack
    command: >
      sh -c  "mysqlcheck --host db -uroot -p${DB_ROOT_PASSWD} -o --auto-repair --flush ${IO_PROJECT}_${IO_APP}"
    profiles:
      - cli

networks:
  stack:
    external: true
    name: ${IO_PROJECT}_${IO_APP}_${IO_STAGE}

volumes:
  data_wp:
    name: ${DATA_WP}
    external: true

  data_db:
    name: ${DATA_DB}
    external: true

  data_backup:
    name: ${BACKUP}
    external: true
```

Observe que as variáveis de ambiente utilizadas acima são as mesmas injetadas pelos arquivos `.env` e `.env.io`, [nos exemplos discutidos anteriormente](#env). Os serviços que serão chamados por linha de comando (`test`, `sanitize`, `backup` e `restore`) possuem o `profile: [ 'cli' ]`, indicando que serão carregados apenas quando o arquivo `.env.sh` for utilizado (onde é passado, especificamente, `COMPOSE_PROFILES=cli`). Um exemplo de chamada destes serviços seria portanto:

```bash
env $(cat .env.sh) docker-compose run --rm --no-deps backup
```

Quando for realizado o _deploy_ do _stack_ de containers, todos os demais serviços "não-CLI" serão carregados. Mais especificamente, o [autômato _Deployer_]({{ site.baseurl }}/docs/architecture#deployer) irá injetar as variáveis do arquivo `.env.io` alterando conforme o _environment_. Assim, caso se trate de uma _build_ em estágio _alpha_ o `COMPOSE_PROFILES` terá o valor `alpha`. Isto possibilita que o usuário carregue determinados serviços apenas em determinados ambientes. Por exemplo, pode ser interessante ao desenvolvedor carregar a ferramenta [phpMyAdmin](https://www.phpmyadmin.net) para auditar seu BD quando a aplicação estiver em estágio _alpha_ ou _beta_, mas não (por questão de segurança) quando estiver em estágio _release_.

É fortemente recomendado que todos os serviços "não-CLI" tenham o atributo de `healthcheck` devidamente configurado. Este atributo permite que [as aplicações sejam monitoradas]({{ site.baseurl }}/docs/health), agregando informação à [dashboard da plataforma](https://dashboard.embrapa.io). O atributo `restart` destes serviços deve estar setado para `unless-stopped`, de forma a garantir maior resiliência da aplicação.

É muito importante que os **volumes** e a **network** sejam configurados corretamente. Para uso com os _drivers_ do **Docker Compose** ou **Docker Swarm**, o autômato _Deployer_ da plataforma executa uma série de validações. Dentre elas, somente são aceitos _volumes_ e _networks_ configurados com o atributo `external` igual à `true`. Assim, para instanciar a aplicação em ambiente de desenvolvimento, os desenvolvedores precisarão fazer algo do tipo:

```bash
docker network create agroproj_agroapp_development
docker volume create agroproj_agroapp_db
docker volume create --driver local --opt type=none --opt device=$(pwd)/data/wp --opt o=bind agroproj_agroapp_wp
docker volume create --driver local --opt type=none --opt device=$(pwd)/data/backup --opt o=bind agroproj_agroapp_backup
```

Em ambientes de _deploy_ (_alpha_, _beta_ e _release_) o volume será criado automaticamente utilizando o _driver_ de _storer_ configurado no _cluster_. Por exemplo, para um [_cluster_ com orquestrador **Docker Compose** utilizando como _storer_ o **NFSv4**]({{ site.baseurl }}/docs/cluster), teríamos algo do tipo:

```bash
docker volume create --driver local --opt type=nfs --opt o=addr=storage.sede.embrapa.br,rw --opt device=:/mnt/nfs/cluster.sede.embrapa.br/agroproj_agroapp_alpha_wp agroproj_agroapp_alpha_wp
```

Por segurança, todos os _volumes_ e a _network_ alocados no _stack_ de containers são checados antes do _deploy_. Assim, **não é possível uma aplicação referenciar e acessar o _volume_ e/ou _network_ de outra aplicação**. Uma vez que os _volumes_ e a _network_ estejam criados, o desenvolvedor da aplicação poderá instanciá-la com o seguinte comando:

```bash
env $(cat .env.io) docker-compose up --force-recreate --build --remove-orphans -d --wait
```

Em ambientes de _deploy_ que utilizem o _driver_ do Docker Compose o comando será semelhante, porém existem algumas garantias para assegurar que não sejam, por exemplo, chamados serviços do tipo CLI.

Adicionalmente, repare no exemplo acima o serviço `wordpress`. Este serviço é buildado em tempo de _deploy_, ou seja, existe um arquivo `Dockerfile` para possibilitar sua _build_. Entretanto foi configurada uma imagem com o valor `127.0.0.1:5000/${IO_PROJECT}_${IO_APP}_${IO_STAGE}_wordpress`. Este recurso é utilizado para possibilitar o _deploy_ em outros orquestradores, tal como o **Docker Swarm**. Neste caso, além de realizar a _build_, o **Docker Compose** irá registrar a imagem gerada no [servidor de registro local do _cluster_](https://docs.docker.com/registry/), possibilitando o _deploy_ no _swarm_ na sequência.

## 8. Implemente os "serviços-padrões" {#cli}

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

A plataforma **Embrapa I/O** fornece, por meio da _dashboard_, uma [funcionalidade para geração de _backups_ por demanda]({{ site.baseurl }}/docs/backup) para os mantenedores dos projetos de ativos digitais. Para que funcione corretamente, é necessário que exista o serviço _backup_ na _stack_ de containers da aplicação. Além disso, deve-se configurar um volume utilizando a palavra reservada `backup`. [Veremos a seguir](#metadata) como deixar pré-estabelecido no _boilerplate_ este volume.

De forma geral, o serviço deverá gerar os _dumps_ de todos os BDs, copiar os arquivos de _upload_ e tudo mais que for necessário para possibilitar a restauração do estado atual da aplicação, compactar em um arquivo no formato `%GENESIS_PROJECT_UNIX%_%GENESIS_APP_UNIX%_${STAGE}_${VERSION}_$$(date +'%Y-%m-%d_%H-%M-%S').tar.gz` e salvar no volume `backup`.

Na [seção anterior](#docker) é possível observar este e os demais serviços CLI devidamente configurados no `docker-compose.yaml` para um _boilerplate_ do [WordPress](https://br.wordpress.org). Repare que naquele exemplo é realizado o _dump_ do [MariaDB](https://mariadb.org) e é copiada integralmente a pasta `/var/www/html`, com todos os arquivos do WordPress. Quando da execução do processo de _backup_, o arquivo `.tar.gz` resultante é copiado para o volume `backup` que é então montado pelo [autômato _Doctor_]({{ site.baseurl }}/docs/architecture#doctor), que atribui uma URL (protegida por login e senha de acesso) e informa os mantenedores do projeto via e-mail.

Repare que este serviço é essencial para manter a autonomia dos mantenedores dos projetos de ativos digitais, reforçando as diretrizes de DevOps adotadas pela plataforma **Embrapa I/O**.

#### c) _restore_ {#cli:restore}

O serviço de _restore_ objetiva, principalmente, auxiliar os mantenedores do projeto tornando rápida e fácil a recuperação do _backup_ da aplicação. Mais especificamente, este serviço irá receber um arquivo do tipo `.tar.gz` por meio da variável de ambiente `BACKUP_FILE_TO_RESTORE`, passada por linha de comando, descompactar e restaurar todos os dados nos containers que formam a aplicação:

```bash
env $(cat .env.sh) BACKUP_FILE_TO_RESTORE=agroproj_agroapp_alpha_1.22.7-alpha.34_2022-06-23_09-30-04.tar.gz docker-compose run --rm --no-deps restore
```

#### d) _sanitize_ {#cli:sanitize}

A plataforma **Embrapa I/O** implementa um [processo de higienização/otimização das aplicações]({{ site.baseurl }}/docs/health). Este processo pode ser relevante para aplicações que tenham tarefas de _garbage collection_, análise/reparação/otimização de esquemas em seus BDs, limpeza de cache, etc. Nada impede, obviamente, a equipe de desenvolvimento da aplicação desenvolver seus próprios _schedular jobs_ para executar as mesmas tarefas na forma de containers no _stack_ da aplicação. Entretanto, este serviço visa simplificar este trabalho.

No `docker-compose.yaml` do [exemplo da seção anterior](#docker) é utilizada a ferramenta de linha de comando `mysqlcheck` para efetuar a [manutenção das tabelas](https://mariadb.com/kb/en/mysqlcheck/) do banco de dados [MariaDB](https://mariadb.org) utilizado no [WordPress](https://br.wordpress.org). Outras ferramentas e comandos similares que podem ser utilizadas neste serviço são o [_vacuum_ do PostgreSQL](https://www.postgresql.org/docs/current/sql-vacuum.html), o [_shrink_ do SQL Server](https://docs.microsoft.com/en-us/sql/relational-databases/databases/shrink-a-database), o [_compact_ do MongoDB](https://www.mongodb.com/docs/manual/reference/command/compact/), etc.

## 9. Configure os metadados {#metadata}

Todo _boilerplate_ e, consequentemente, toda aplicação na plataforma **Embrapa I/O** possui um diretório na raiz denominado `.embrapa`. Neste diretório ficam armazenados todos os metadados necessários à parametrização dos processos de DevOps da plataforma. Assim, com exceção do orquestrador [Docker Compose](https://docs.docker.com/compose/), cujo arquivo de configuração fica na raiz da aplicação pois também é utilizado em ambiente de desenvolvimento, as configurações que parametrizam as ferramentas de orquestração de containers ([Docker Swarm](https://docs.docker.com/engine/swarm/), [Kubernetes](https://kubernetes.io/pt-br/), [LXC](https://linuxcontainers.org), etc) e PaaS ([RedHat OpenShift](https://www.redhat.com/pt-br/technologies/cloud-computing/openshift), [AWS](https://www.datamation.com/cloud-computing/amazon-web-services.html), [Microsoft Azure](https://www.datamation.com/cloud-computing/microsoft-azure.html), [Google Cloud](https://www.datamation.com/cloud-computing/google-cloud-platform.html), [Heroku](https://www.heroku.com), etc) devem estar, sempre que possível, neste diretório.

Além disso, neste diretório fica o arquivo `settings.json`, que possui informações necessárias utilizadas pelos [diversos componentes do **Embrapa I/O**]({{ site.baseurl }}/docs/architecture). Para cada _boilerplate_ criado, será necessário configurar corretamente este arquivo. Vamos tomar como exemplo o _boilerplate_ para WordPress:

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
  "orchestrators": [ "DockerCompose", "DockerSwarm" ]
}
```

O atributo `boilerplate` deve conter o nome único do _boilerplate_ em toda a plataforma e deve seguir o padrão _unix_ de nomes de entidades (`/^[a-z0-9-]{3,}$/`).

> **Atenção!** Caso esteja apenas adequando uma aplicação legada para ficar aderente à plataforma, insira o valor "_" (underscore) no atributo `boilerplate`.

O atributo `platform` corresponde ao SDK do [Sentry](https://sentry.io) que deverá ser utilizado neste _boilerplate_. As _keywords_ para as [plataformas aceitas pelo Sentry](https://docs.sentry.io/platforms/) são: ```android```, ```apple```, ```dart```, ```dotnet```, ```electron```, ```elixir```, ```flutter```, ```go```, ```java```, ```javascript```, ```kotlin```, ```native```, ```node```, ```php```, ```python```, ```react-native```, ```ruby```, ```rust```, ```unity``` e ```unreal```. Defina corretamente a palavra-chave no atributo para assegurar a melhor experiência dos desenvolvedores no [monitoramento de erros da aplicação]({{ site.baseurl }}/docs/bug).

Os atributos `label`, `description`, `references` e `maintainers` (auto-explicativos) e são renderizados pela [_dashboard_ da plataforma](https://dashboard.embrapa.io) no momento da escolha do _boilerplate_ na [criação de aplicações]({{ site.baseurl }}/docs/app).

![Renderização das infos do boilerplate]({{ site.baseurl }}/assets/img/boilerplate/02.png)

No atributo `variables` são inseridas as _environment variables_ que parametrizam a aplicação, ou seja, as mesmas contidas no arquivo `.env`. A plataforma **Embrapa I/O** carrega estas variáveis, com seus respectivos valores padrão, no momento da [configuração da _build_]({{ site.baseurl }}/docs/build). Serão carregadas primeiro as variáveis do atributo `default` e, em seguida, sobrescrevendo estas, as variáveis dos atributos homônimos ao estágio da _build_ que está sendo configurada (`alpha`, `beta` ou `release`). No exemplo acima, está sendo habilitado por padrão o _debug_ (variável `WP_DEBUG`) para as _builds_ em estágio de testes internos (_alpha_) e externos (_beta_), e desabilitado para as _builds_ em produção (_release_).

Outro exemplo de uso é para setar o _environment_ interno aos arcabouços de programação. Por exemplo, uma aplicação [ASP.NET](https://docs.microsoft.com/pt-br/aspnet/core/) aceita os seguintes valores para a variável `ASPNETCORE_ENVIRONMENT`: `Development`, `Staging`, `Staging_2` e `Production` ([conforme a documentação](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/environments)). Assim, poderia ser configurado no arquivo `.env.example` do _boilerplate_ a variável `ASPNETCORE_ENVIRONMENT=Development`, de forma que os desenvolvedores, ao renomearem o arquivo para iniciar a customização da aplicação, já usariam o valor correto para o _environment_ de desenvolvimento. Nas configurações de metadados do _boilerplate_ no arquivo `settings.json`, esta variável poderia ser setada no subgrupo `alpha` como `Staging`, em `beta` como `Staging_2` e em `release` como `Production`. A mesma estratégia pode pode ser utilizada para a variável `NODE_ENV`, [comumente utilizada em projetos em JavaScript](https://www.geeksforgeeks.org/what-is-node_env-in-node-js/), e demais correlatas em outras linguagens e arcabouços de programação.

> **Atenção!** Durante a [configuração da _build_]({{ site.baseurl }}/docs/build) os valores padrão para as variáveis definidos aqui, bem como aqueles gerados randomicamente, poderão ser alterados pelo usuário.

As variáveis definidas podem ser de cinco tipos:

- **TEXT**: Uma sequência de caracteres livre, porém **sem espaços** (`/^[^\s]*$/`). Caso não seja passado um valor padrão (atributo `value`), será deixado em branco.
- **PASSWORD**: Utilizado para armazenar **senhas**. Uma sequência de caracteres livre, porém **sem espaços** (`/^[^\s]*$/`). Caso não seja passado um valor padrão (atributo `value`), será atribuída uma _string_ randômica (`/^[a-zA-Z0-9]{16}$/`).
- **SECRET**: Utilizado para armazenar **chaves privadas**. Uma sequência de caracteres livre, porém **sem espaços** (`/^[^\s]*$/`). Caso não seja passado um valor padrão (atributo `value`), será atribuída uma _string_ randômica (`/^[a-zA-Z0-9]{256}$/`).
- **PORT**: Utilizado para armazenar as **portas expostas publicamente** da aplicação. O valor desta variável será setado na [configuração da _build_]({{ site.baseurl }}/docs/build) considerando as portas vagas do _cluster_ escolhido para _deploy_.
- **VOLUME**: Utilizado para referenciar os **volumes** da aplicação. Os valores inseridos aqui serão utilizados na [configuração da _build_]({{ site.baseurl }}/docs/build), no passo de definição de volumes, para preencher automaticamente a lista dos volumes da aplicação.
- **EMPTY**: Força o uso de uma _string_ vazia como valor da variável. Útil para desabilitar variáveis em determinados ambientes de _deploy_.

![Volumes pré-configurados a partir das variáveis de ambiente]({{ site.baseurl }}/assets/img/boilerplate/03.png)

Repare que no "**3º Passo - Volumes**", mostrado na imagem acima, a listagem de volumes foi pré-carregada de acordo com a variáveis deste tipo declaradas nos metadados do _boilerplate_ utilizado na aplicação. Da mesma forma, todas as variáveis serão pre-carregadas no "**4º Passo - Variáveis**" com os valores definidos no `settings.json` ou gerados automaticamente. Na imagem abaixo é mostrado um exemplo da lista de variáveis pré-carregada (desconsidere as variáveis do tipo **SERVER**, que são aquelas presentes no arquivo `.env.io` e injetadas em tempo de _deploy_).

![Lista de variáveis pré-carregadas com base nos metadados]({{ site.baseurl }}/assets/img/boilerplate/04.png)

Por fim, o atributo `orchestrators` lista os **orquestradores para os quais o _boilerplate_ está homologado**. Cada orquestrador irá exigir parâmetros específicos para permitir o _deploy_ das aplicações. Por exemplo, para que o _boilerplate_ esteja aderente ao [Kubernetes](https://kubernetes.io/pt-br/), espera-se que exista um diretório "`.embrapa/k8s`" contendo os arquivos de configuração necessários. A equipe mantenedora do _boilerplate_ deve, na medida do possível, configurá-lo e homologá-lo na maior quantidade possível de orquestradores aceitos pela plataforma **Embrapa I/O**.

## 10. Configure outros orquestradores {#orchestrator}

Conforme é detalhado no [capítulo sobre a configuração de _clusters_]({{ site.baseurl }}/docs/cluster), o **Embrapa I/O** trabalha, por padrão, com o orquestrador **Docker Compose** no ambiente de desenvolvimento, mas outros orquestradores podem ser utilizados nos ambientes remotos de _deploy_. Estas configurações de _deployment_ para cada _driver_ de orquestração deverão estar disponibilizadas no diretório de metadados `.embrapa`.

#### a) Docker Swarm

As configurações para _deploy_ da aplicação em _clusters_ com **Docker Swarm** deverão ser disponibilizadas na pasta `.embrapa/swarm`. Um arquivo principal de _deploy_, denominado `deployment.yaml` deverá estar na raiz desta pasta. Este arquivo deverá ser uma cópia dos `docker-compose.yaml` no diretório raiz da aplicação, porém somente com os serviços do _profile_ de _deploy_.

Todos os serviços deverão ter uma imagem vinculada. Esta imagem deverá ser exatamente a mesma na declaração do serviço nos arquivos `docker-compose.yaml` e `.embrapa/swarm/deployment.yaml`. Em serviços que são 'buildados' em tempo de _deploy_, as imagens geradas deverão ser registradas no [servidor local do Docker Registry](https://docs.docker.com/registry/). Por exemplo, considere o arquivo `docker-compose.yaml` mostrado no [passo de conteinerização do _boilerplate_](#docker). Os arquivo `deployment.yaml` correlato seria:

```yaml
services:
  db:
    image: mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWD}
      MYSQL_DATABASE: ${IO_PROJECT}_${IO_APP}
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${DB_PASSWD}
    volumes:
      - data_db:/var/lib/mysql
    networks:
      - stack
    healthcheck:
      test: mysql ${IO_PROJECT}_${IO_APP} --user=wordpress --password='${DB_PASSWD}' --silent --execute "SELECT 1;"
      interval: 1m30s
      timeout: 10s
      start_period: 30s
      retries: 4
    deploy:
      restart_policy:
        condition: on-failure

  wordpress:
    image: 127.0.0.1:5000/${IO_PROJECT}_${IO_APP}_${IO_STAGE}_wordpress
    depends_on:
      - db
    volumes:
      - data_wp:/var/www/html
    ports:
      - ${PORT}:80
    networks:
      - stack
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: ${DB_PASSWD}
      WORDPRESS_DB_NAME: ${IO_PROJECT}_${IO_APP}
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_DEBUG', ${WP_DEBUG});
        define('WP_ALLOW_MULTISITE', ${WP_ALLOW_MULTISITE});
        define('WP_SENTRY_PHP_DSN', '${SENTRY_DSN}');
        define('WP_SENTRY_ERROR_TYPES', E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_USER_DEPRECATED);
        define('WP_SENTRY_VERSION', @array_shift(explode('-', '${IO_VERSION}')));
        define('WP_SENTRY_ENV', '${IO_STAGE}' );
        define('WP_MATOMO_URL', 'https://hit.embrapa.io');
        define('WP_MATOMO_ID', ${MATOMO_ID});
        define('WP_MATOMO_TOKEN', '${MATOMO_TOKEN}');
        define('WP_MATOMO_STAGE', '${IO_STAGE}');
        define('WP_MATOMO_VERSION', '${IO_VERSION}');
    healthcheck:
      test: curl --fail -s http://localhost:80/ || exit 1
      interval: 1m30s
      timeout: 10s
      start_period: 30s
      retries: 4
    deploy:
      restart_policy:
        condition: on-failure

networks:
  stack:
    external: true
    name: ${IO_PROJECT}_${IO_APP}_${IO_STAGE}

volumes:
  data_wp:
    name: ${DATA_WP}
    external: true

  data_backup:
    name: ${BACKUP}
    external: true

  data_db:
    name: ${DATA_DB}
    external: true
```

No serviço `wordpress` é declarada a imagem `127.0.0.1:5000/${IO_PROJECT}_${IO_APP}_${IO_STAGE}_wordpress`. Assim, o `docker-compose.yaml` será utilizado para realizar o _build_ da aplicação e registrar as imagens que serão depois utilizadas no _swarm_.

O atributo `deploy` no arquivo `deployment.yaml` é específico do **Docker Swarm**. A plataforma **Embrapa I/O** restringe o que pode ser configurado neste atributo. Neste momento, é necessário que o valor de `restart-policy` seja `condition: on-failure`. O `mode`, caso seja setado, deve ter o valor `global` (mas é recomendado <u>não configurá-lo</u>). Os atributos `resources` e `replicas` não devem existir.

Os serviços do tipo **CLI** (`backup`, `restore`, `sanitize` e `test`), por sua vez, deverão estar separados em arquivos **YAML** próprios na pasta `.embrapa/swarm/cli`. Por exemplo, para um arquivo `backup.yaml` nesta pasta, teríamos:

```yaml
services:
  backup:
    image: mariadb:latest
    volumes:
      - data_backup:/backup
      - data_wp:/var/www/html
    command: >
      sh -c  "set -ex &&
        export BACKUP_DIR=${IO_PROJECT}_${IO_APP}_${IO_STAGE}_${IO_VERSION}_$$(date +'%Y-%m-%d_%H-%M-%S') &&
        cd /backup && ls -l && mkdir $$BACKUP_DIR &&
        mysqldump --host db -uroot -p${DB_ROOT_PASSWD} ${IO_PROJECT}_${IO_APP} > $$BACKUP_DIR/db.sql &&
        cp -R /var/www/html $$BACKUP_DIR/ &&
        tar -czf $$BACKUP_DIR.tar.gz $$BACKUP_DIR &&
        ls -la /var/www/html &&
        rm -rf /backup/$$BACKUP_DIR"
    networks:
      - stack
    deploy:
      restart_policy:
        condition: none

networks:
  stack:
    external: true
    name: ${IO_PROJECT}_${IO_APP}_${IO_STAGE}

volumes:
  data_wp:
    name: ${DATA_WP}
    external: true

  data_backup:
    name: ${BACKUP}
    external: true
```

Ao contrário do `deployment.yaml`, na declaração dos serviços **CLI** o atributo `restart_policy` deve ter `condition: none`, uma vez que estes são _one-shot containers_.

## 11. Documente e inclua a licença {#readme}

É **extremamente importante** que, na raiz do repositório do _boilerplate_, tenha os arquivos `README.md` e `LICENSE`. O `README.md` conterá a documentação do _boilerplate_ voltada para os **usuários desenvolvedores**. Ou seja, os usuários que irão derivar seu código-fonte para criar as aplicações finais. Existem [modelos e _templates_](https://github.com/othneildrew/Best-README-Template) de uso livre que podem auxiliar nesta documentação. Neste arquivo estarão presentes informações sobre o _boilerplate_, tal como:

- _prints_ das telas, caso ele possua uma UI;
- as funcionalidades pré-implementadas, que são normalmente requisitos não-funcionais para as aplicações derivadas;
- as tecnologias utilizadas, tal como a linguagem de programação (e sua versão), _frameworks_, bibliotecas, pacotes, etc;
- uma seção de _Getting Started_, onde são listados os pré-requisitos e como realizar a instalação;
- exemplos de uso do _boilerplate_ e de customizações possíveis;
- um _roadmap_ com a lista do que já está implementado e de um eventual _backlog_;
- o passo-a-passo de como os usuários podem participar da equipe de mantenedores do _boilerplate_;
- informações de contato dos membros mantenedores; e
- uma seção de referências para documentação externa dos principais componentes e material de apoio.

Já no arquivo `LICENSE` estará presente a licença de uso e derivação do _boilerplate_ em si. É fundamental que esta licença seja de código-aberto e extremamente permissiva, de forma a não "contaminar" a aplicação derivada. Por exemplo, é indesejável o uso de uma licença do tipo GNU GPL v3, uma vez que ela obriga todo código-fonte derivado a ter a mesma licença do original (e, desta forma, ser também _open source_). Como muitas aplicações aspiram a produtos com apelo mercadológico, o uso do _boilerplate_ seria impossibilitado. Falamos mais sobre este assunto no [capítulo de licenciamento]({{ site.baseurl }}/docs/licensing).

Assim, como sugestão, recomendamos fortemente o uso da [licensa MIT](https://mit-license.org) em todo _boilerplate_ desenvolvido.

## 12. Distribua o _boilerplate_ {#publish}

Para distribuir o _boilerplate_ para uso pela comunidade de desenvolvedores, será necessário disponibilizá-lo no grupo de repositórios `/io/boilerplate` do [GitLab da plataforma](https://git.embrapa.io), onde estará **visível publicamente para todos os usuários**.

> **Atenção!** Após efetuar o _fork_ da aplicação, criando o _boilerplate_, é necessário **alterar a visibilidade no _boilerplate_ para 'Public'** (Settings &raquo; General &raquo; Visibility, project features, permissions &raquo; Project visibility).

Além disso, ele deverá constar e estar ativo no [catálogo de _boilerplates_](http://localhost:8029/io/boilerplate/metadata/-/blob/main/boilerplates.json). Para ser inserido na listagem, os mantenedores precisarão passar para a [equipe de suporte do **Embrapa I/O**](mailto:io@embrapa.br) o **nome _unix_** do _boilerplate_, um **nome legível** (rótulo), uma **breve descrição** (de uma linha) e um **ícone** que melhor represente as tecnologias utilizadas. Atualmente, os ícones permitidos são:

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

**Parabéns!** 🥳 Tendo seguido estes passos você disponibilizou um novo _boilerplate_ que poderá ser utilizado pela comunidade **Embrapa I/O** no desenvolvimento de ativos digitais para a agropecuária.

> **Obrigado pela sua contribuição!** <span style="font-style: normal;">🤗</span>
