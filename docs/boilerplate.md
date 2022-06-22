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
*[SDK]: Software Development Kit
*[IDE]: Integrated Development Environment
*[BD]: Banco de Dados

De forma geral, as aplicações da plataforma **embrapa.io** são _forks_ de repositórios pré-existentes denominados _boilerplates_. Estes respositórios são aplicações funcionais, em determinada linguagem de programação ou _framework_, já estruturadas para funcionar corretamente nos _pipelines_ e processos de DevOps da plataforma. A ideia é fomentar a padronização e o reuso de código-fonte. Neste tutorial veremos como configurar corretamente um novo _boilerplate_ para distribuí-lo no catálogo da plataforma, de modo a possibilitar que outras equipes de desenvolvimento de ativos digitais possam fazer uso.

Para criar e disponibilizar seu _boilerplate_, você precisará seguir os seguintes passos:

1. [Crie uma "aplicação-base"](#base);
2. [Integre ao _error tracking_](#bug);
3. [Crie os arquivos de _environment variables_](#env);
4. [Utilize as _keywords_ de customização](#keyword);
5. [Conteinerize seu _boilerplate_](#docker);
6. [Configure os metadados](#metadata); e
7. [Distribua o _boilerplate_](#publish).

É possível [criar um repositório de aplicação]({{ site.baseurl }}/docs/app) sem utilizar um _boilerplate_. Esta função é útil para instanciar na plataforma sistemas que antecedem o próprio **embrapa.io**. Entretanto, será necessário criar manualmente um repositório no [GitLab](https://git.embrapa.io) e adaptar seu código fonte de forma que ele tenha **toda a estrutura de pastas e arquivos requeridos para um _boilerplate_** (ou seja, seguir os mesmos passos aqui descritos). Em seguida, no momento de criar a aplicação pela _dashboard_, selecione a opção de um "**repositório pré-existente**" (conforme a imagem abaixo).

![Criando uma aplicação sem o boilerplate]({{ site.baseurl }}/assets/img/boilerplate/01.png)

## 1. Crie uma "aplicação-base" {#base}

O primeiro passo para iniciar a construção de seu _boilerplate_ é criar uma aplicação funcional. Esta aplicação terá funcionalidades que são **requisitos comuns** de ativos digitais para a agricultura, de forma que o reúso deste código-base seja demandado. Por exemplo, poderíamos ter dois _boilerplates_ de PWA utilizando os _frameworks_ [VueJS](https://vuejs.org) e [Vuetify](https://vuetifyjs.com): um com sistema de _login_ de usuários e outro sem. No catálogo de _boilerplates_ o usuário poderia escolher qual utilizar tomando esta característica como base.

> **Atenção!** O _boilerplate_ deve ser uma aplicação com padrões rigorosos de qualidade de código, bem como utilizando as **versões mais recentes**, LTS, da linguagem e arcabouço de programação. Por exemplo, se estiver sendo criado em [PHP](https://php.net), espera-se que esteja plenamente aderente aos [PHP Standards Recommendations](https://www.php-fig.org/psr/).

Assim, é fortemente recomendado que a criação de um _boilerplate_ tenha como ponto de partida o _Get Started_ do próprio arcabouço de programação. A imensa maioria dos _frameworks_ modernos possuem ferramentas CLI do tipo _standard tooling_, que permitem a criação de estruturas padronizadas de projetos de software. Adicionalmente, priorize o uso de linguagens, arcabouços e pacotes que tenham licença _open source_ permissivas, de forma a não "contaminar" o [licenciamento da aplicação final]({{ site.baseurl }}/docs/licensing). Por fim, tenha em mente que softwares são descontinuados. Portanto, para garantir uma vida longa e próspera ao seu _boilerplate_ (e às aplicações derivadas dele), dê preferência a tecnologias consolidadas, com vastas comunidades e que tenham se provado no tempo. Tome como exemplos: [Go Gin Gonic](https://gin-gonic.com/docs/quickstart/), [Java Spring Boot](https://spring.io/guides/gs/spring-boot/), [PHP Laravel](https://laravel.com/docs/4.2/quick), [PHP Symfony](https://symfony.com/doc/current/getting_started/index.html), [Python Django](https://docs.djangoproject.com/en/4.0/intro/tutorial01/), [ReactJS](https://reactjs.org/docs/add-react-to-a-website.html), [React Native](https://reactnative.dev/docs/0.60/enviroment-setup) e [VueJS/Vuetify](https://vuetifyjs.com/en/getting-started/installation/).

Todos os _boilerplates_ da plataforma ficam disponíveis **publicamente** no mesmo [grupo de repositórios no GitLab](https://git.embrapa.io/io/metadata/boilerplate). Você pode iniciar a criação de seu _boilerplate_ em seu próprio repositório e, posteriormente, efetuar um _fork_ para este grupo, ou [solicitar a criação de um novo repositório dentro do grupo](mailto:io@embrapa.br). Para todos os efeitos, a construção do _boilerplate_ seguirá as diretrizes de uma aplicação convencional da plataforma, tal como o [controle de _issues_ e _milestones_]({{ site.baseurl }}/docs/kanban).

Após criar a aplicação-base, você deverá customizá-la. Antes de começar a alterá-la, entretanto, verifique se existem ferramentas do tipo **_linter_** e **_fomatter_** devidamente configuradas em sua IDE para a linguagem de programação que está utilizando. Falamos mais sobre isso na [seção de boas práticas de desenvolvimento]({{ site.baseurl }}/docs/practices).

Inicie a customização da aplicação-base incluindo aspectos que são comumente utilizados nos ativos digitais da Embrapa. Por exemplo, uma identidade visual aderente aos padrões estabelecidos pela área de comunicação, a logo da Empresa conforme o manual de uso, estrutura de menus, cabeçalho e rodapé, e telas que são normalmente padronizadas (p.e., a tela de "Sobre"). Adicionalmente, inclua funcionalidades mais complexas que caracterizem seu _boilerplate_, tal como requisitos não-funcionais (p.e., registro e _login_ de usuários) ou mesmo funcionais (p.e., cadastro e gestão de fazendas). O domínio de negócio dos ativos digitais da plataforma **embrapa.io** é abrangente, porém bem definida: "**o agronegócio**". Portanto, <u>existem requisitos funcionais que serão de uso comum</u>.

Caso esteja desenvolvendo o _boilerplate_ para uma **API Web**, comprometa-se em torná-lo aderente ao [AgroAPI](https://www.agroapi.cnptia.embrapa.br), de forma que as aplicações criadas a partir dele possam compor o catálogo da Embrapa quando forem publicadas. Simuladores, algoritmos de aprendizado de máquina, visão computacional e **artefatos de software especializados** de forma geral, <u>devem ser encapsulados em componentes específicos</u>. Neste caso, recomenda-se que tenham seu próprio repositório de código e sejam integrados nas aplicações na forma de **pacotes privados** (gerenciados por _dependency managers_, tal como o [composer](https://getcomposer.org/), o [npm](https://www.npmjs.com/), o [gradle](https://gradle.org) ou o [maven](https://maven.apache.org/)). Assim, um _boilerplate_ para uma aplicação [TensorFlow.js](https://www.tensorflow.org/js), por exemplo, seria na verdade um pacote NPM.

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

Acima as variáveis estão sendo setadas com valores propícios ao ambiente de desenvolvimento. Repare na presença de _keywords_ (entre os caracteres '**%**'), que serão explicadas em seguida. Ao copiar e renomear o arquivo (retirando o sufixo `.example`) o desenvolvedor precisará ajustar estes valores, tal como [inserir o DSN correto no Sentry]({{ site.baseurl }}/docs/bug).

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

```
env $(cat .env.cli) docker-compose run --rm --no-deps backup
```

Quando for realizado o _deploy_ do _stack_ de containers, todos os demais serviços "não-CLI" serão carregados. Mais especificamente, o [autômato _Deployer_]({{ site.baseurl }}/docs/architecture#deployer) irá injetar as variáveis do arquivo `.env.ci` alterando conforme o _environment_. Assim, caso se trate de uma _build_ em estágio _alpha_ o `COMPOSE_PROFILES` terá o valor `alpha`. Isto possibilita que o usuário carregue determinados serviços apenas em determinados ambientes. Por exemplo, pode ser interessante ao desenvolvedor carregar a ferramenta [phpMyAdmin](https://www.phpmyadmin.net) para auditar seu BD quando a aplicação estiver em estágio _alpha_ ou _beta_, mas não (por questão de segurança) quando estiver em estágio _release_.

É fortemente recomendado que todos os serviços "não-CLI" tenham o atributo de `healthcheck` devidamente configurado. Este atributo permite que [as aplicações sejam monitoradas]({{ site.baseurl }}/docs/health), agregando informação à [dashboard da plataforma](https://dashboard.embrapa.io). O atributo `restart` destes serviços deve estar setado para `unless-stopped`, de forma a garantir maior resiliência da aplicação.

É muito importante que os **volumes** sejam configurados corretamente. Para uso com o _driver_ do Docker Compose, o autômato _Deployer_ da plataforma executa uma série de validações. Dentre elas, somente são aceitos volumes configurados com o atributo `external` igual à `true`.

## 6. Configure os metadados {#metadata}

Todo _boilerplate_ e, consequentemente, toda aplicação na plataforma **embrapa.io** possui um diretório na raiz denominado `.embrapa`.

As _keywords_ para as [plataformas aceitas pelo Sentry](https://docs.sentry.io/platforms/) são: ```android```, ```apple```, ```dart```, ```dotnet```, ```electron```, ```elixir```, ```flutter```, ```go```, ```java```, ```javascript```, ```kotlin```, ```native```, ```node```, ```php```, ```python```, ```react-native```, ```ruby```, ```rust```, ```unity``` e ```unreal```. Defina corretamente a palavra-chave no atributo ```platform``` do _boilerplate_ para assegurar a melhor experiência dos desenvolvedores na interface do [Sentry](https://bug.embrapa.io).

No atributo ```icon``` os valores permitidos são:

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

## 7. Distribua o _boilerplate_ {#publish}

...
