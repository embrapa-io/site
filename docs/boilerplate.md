---
layout: page
title: Boilerplate
subtitle: Criando e mantendo um boilerplate
---

De forma geral, as aplicações da plataforma **embrapa.io** são _forks_ de repositórios pré-existentes denominados _boilerplates_. Estes respositórios são aplicações em determinada linguagem de programação ou _framework_ já estruturadas para funcionar corretamente nos _pipelines_ e processos de DevOps da plataforma. A ideia é fomentar a padronização e o reuso de código-fonte. Neste tutorial veremos como configurar corretamente um novo _boilerplate_ para distribuí-lo no catálogo da plataforma, de modo a possibilitar que outras equipes de desenvolvimento de ativos digitais possam fazer uso.

É possível [criar um repositório de aplicação]({{ site.baseurl }}/docs/app) sem utilizar um _boilerplate_. Esta função é útil para instanciar na plataforma sistemas que antecedem o próprio **embrapa.io**. Entretanto, será necessário criar manualmente um repositório no [GitLab](https://git.embrapa.io) e adaptar seu código fonte de forma que ele tenha **toda a estrutura de pastas e arquivos requeridos para um _boilerplate_**. Em seguida, no momento de criar a aplicação pela _dashboard_, selecione a opção de um "repositório pré-existente" (conforme a imagem abaixo).

![Criando uma aplicação sem o boilerplate]({{ site.baseurl }}/assets/img/boilerplate/01.png)

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
