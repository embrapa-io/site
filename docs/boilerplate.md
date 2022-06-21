---
layout: page
title: Boilerplate
subtitle: Criando e mantendo um boilerplate
---

*[PWA]: Progressive Web App
*[LTS]: Long-term support
*[CLI]: Command-line interface
*[API]: Application Programming Interface

De forma geral, as aplicações da plataforma **embrapa.io** são _forks_ de repositórios pré-existentes denominados _boilerplates_. Estes respositórios são aplicações funcionais, em determinada linguagem de programação ou _framework_, já estruturadas para funcionar corretamente nos _pipelines_ e processos de DevOps da plataforma. A ideia é fomentar a padronização e o reuso de código-fonte. Neste tutorial veremos como configurar corretamente um novo _boilerplate_ para distribuí-lo no catálogo da plataforma, de modo a possibilitar que outras equipes de desenvolvimento de ativos digitais possam fazer uso.

Para criar e disponibilizar seu _boilerplate_, você precisará seguir os seguintes passos:

1. [Crie uma "aplicação-base"](#base);
2. [Integre ao _error tracking_](#bug);
3. [Conteinerize seu _boilerplate_](#docker);
4. [Utilize as _keywords_ de customização](#keyword);
5. [Configure os metadados](#metadata); e
6. [Distribua](#publish).

É possível [criar um repositório de aplicação]({{ site.baseurl }}/docs/app) sem utilizar um _boilerplate_. Esta função é útil para instanciar na plataforma sistemas que antecedem o próprio **embrapa.io**. Entretanto, será necessário criar manualmente um repositório no [GitLab](https://git.embrapa.io) e adaptar seu código fonte de forma que ele tenha **toda a estrutura de pastas e arquivos requeridos para um _boilerplate_** (ou seja, seguir os mesmos passos acima). Em seguida, no momento de criar a aplicação pela _dashboard_, selecione a opção de um "repositório pré-existente" (conforme a imagem abaixo).

![Criando uma aplicação sem o boilerplate]({{ site.baseurl }}/assets/img/boilerplate/01.png)

## 1. Crie uma "aplicação-base" {#base}

O primeiro passo para iniciar a construção de seu _boilerplate_ é criar uma aplicação funcional. Esta aplicação terá funcionalidades que são **requisitos comuns** de ativos digitais para a agricultura, de forma que o reúso deste código-base seja demandado. Por exemplo, poderíamos ter dois _boilerplates_ de PWA utilizando os _frameworks_ [VueJS](https://vuejs.org) e [Vuetify](https://vuetifyjs.com): um com sistema de _login_ de usuários e outro sem. No catálogo de _boilerplates_ o usuário poderia escolher qual utilizar tomando esta característica como base.

> **Atenção!** O _boilerplate_ deve ser uma aplicação com padrões rigorosos de qualidade de código, bem como utilizando as **versões mais recentes**, LTS, da linguagem e arcabouço de programação. Por exemplo, se estiver sendo criado em [PHP](https://php.net), espera-se que esteja plenamente aderente aos [PHP Standards Recommendations](https://www.php-fig.org/psr/).

Assim, é fortemente recomendado que a criação de um _boilerplate_ tenha como ponto de partida o _Get Started_ do próprio arcabouço de programação. A imensa maioria dos _frameworks_ modernos possuem ferramentas CLI do tipo _standard tooling_, que permitem a criação de estruturas padronizadas de projetos de software. Adicionalmente, priorize o uso de linguagens, arcabouços e pacotes que tenham licença _open source_ permissivas, de forma a não "contaminar" o [licenciamento da aplicação final]({{ site.baseurl }}/docs/licensing). Por fim, tenha em mente que softwares são descontinuados. Portanto, para garantir uma vida longa e próspera ao seu _boilerplate_ (e às aplicações derivadas dele), dê preferência a tecnologias consolidadas, com vastas comunidades e que tenham se provado no tempo. Tome como exemplos: [Go Gin Gonic](https://gin-gonic.com/docs/quickstart/), [Java Spring Boot](https://spring.io/guides/gs/spring-boot/), [PHP Laravel](https://laravel.com/docs/4.2/quick), [PHP Symfony](https://symfony.com/doc/current/getting_started/index.html), [Python Django](https://docs.djangoproject.com/en/4.0/intro/tutorial01/), [ReactJS](https://reactjs.org/docs/add-react-to-a-website.html), [React Native](https://reactnative.dev/docs/0.60/enviroment-setup) e [VueJS/Vuetify](https://vuetifyjs.com/en/getting-started/installation/).

Todos os _boilerplates_ da plataforma ficam disponíveis **publicamente** no mesmo [grupo de repositórios no GitLab](https://git.embrapa.io/io/metadata/boilerplate). Você pode iniciar a criação de seu _boilerplate_ em seu próprio repositório e, posteriormente, efetuar um _fork_ para este grupo, ou [solicitar a criação de um novo repositório dentro do grupo](mailto:io@embrapa.br). Para todos os efeitos, a construção do _boilerplate_ seguirá as diretrizes de uma aplicação convencional da plataforma, tal como o [controle de _issues_ e _milestones_]({{ site.baseurl }}/docs/kanban).

Após criar a aplicação-base, você deverá customizá-la. Inicie incluindo aspectos que são comumente utilizados nos ativos digitais da Embrapa. Por exemplo, uma identidade visual aderente aos padrões estabelecidos pela área de comunicação, a logo da Empresa conforme o manual de uso, estrutura de menus, cabeçalho e rodapé, e telas que são normalmente padronizadas (p.e., a tela de "Sobre"). Adicionalmente, inclua funcionalidades mais complexas que caracterizem seu _boilerplate_, tal como requisitos não-funcionais (p.e., registro e login de usuários) ou mesmo funcionais (p.e., cadastro e gestão de fazendas). O domínio de negócio dos ativos digitais da plataforma **embrapa.io** é abrangente, porém bem definida: "**o agronegócio**". Portanto, <u>existem requisitos funcionais que serão de uso comum</u>.

Caso esteja desenvolvendo o _boilerplate_ para uma **API Web**, comprometa-se em torná-lo aderente ao [AgroAPI](https://www.agroapi.cnptia.embrapa.br), de forma que as aplicações criadas a partir dele possam compor o catálogo da Embrapa quando forem publicadas. Simuladores, algoritmos de aprendizado de máquina, visão computacional e **artefatos de software especializados** de forma geral, <u>devem ser encapsulados em componentes específicos</u>. Neste caso, recomenda-se que tenham seu próprio repositório de código e sejam integrados nas aplicações na forma de **pacotes privados** (gerenciados por _dependency managers_, tal como o [composer](https://getcomposer.org/), o [npm](https://www.npmjs.com/), o [gradle](https://gradle.org) ou o [maven](https://maven.apache.org/)). Assim, um _boilerplate_ para uma aplicação [TensorFlow.js](https://www.tensorflow.org/js), por exemplo, seria na verdade um pacote NPM.

## 2. Integre ao _error tracking_ {#bug}

...
## 3. Conteinerize seu _boilerplate_ {#docker}

Conteinerize seu _boilerplate_. Normalmente, no próprio site da linguagem ou arcabouço de desenvolvimento utilizado há documentação sobre como conteinerizar utilizando o [Docker](https://www.docker.com). Veja como exemplo o tutorial "[_Dockerize Vue.js App_](https://v2.vuejs.org/v2/cookbook/dockerize-vuejs-app.html)" na documentação oficial do VueJS. Algumas vezes, em ambiente de desenvolvimento, pode ser preferível não utilizar containers, porém para tornar a aplicação derivada do _boilerplate_ apta ao _deploy_ na plataforma, será necessário conteinerizar. Claro, <u>isto não se aplica a aplicações que naturalmente não serão distribuídas na Web</u>, tal como código nativo para Google Android (em Kotlin ou Java), código nativo para Apple iOS (em Swift ou Objective-C) ou mesmo pacotes (de artefatos de software especializados) para gerenciadores de dependência, como citado anteriormente.

## 4. Utilize as _keywords_ de customização {#keyword}

...
## 5. Configure os metadados {#metadata}

...

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

## 6. Distribua {#publish}

...
