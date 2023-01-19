---
layout: page
title: Arquitetura
subtitle: Módulos que compõem a plataforma
---

O **embrapa.io** é uma [plataforma de software de código-aberto]({{ site.baseurl }}/license), [disponível publicamente](https://github.com/embrapa-io), composta por diversos componentes desacoplados:

![Arquitetura do embrapa.io]({{ site.baseurl }}/assets/img/arch.png)

Os círculos numerados na imagem representam as interfaces disponíveis para os desenvolvedores, sendo elas:

1. [https://dashboard.embrapa.io](https://dashboard.embrapa.io)
2. [https://git.embrapa.io](https://git.embrapa.io)
3. [https://bug.embrapa.io](https://bug.embrapa.io)
4. [https://hit.embrapa.io](https://hit.embrapa.io)
5. [https://backup.embrapa.io](https://backup.embrapa.io)

Cada componente da _big picture_ acima é descrito a seguir:

## _Dashboard_ {#dashboard}

Trata-se de uma _single-page application_ (ou aplicação Web responsiva) desenvolvida em JavaScript utilizando o _framework_ [VueJS](https://vuejs.org/) com [Vuetify](https://vuetifyjs.com/en/), permite aos desenvolvedores de ativos digitais terem acesso a todos os projetos dos quais são membros da equipe e suas aplicações. Está, portanto, [disponível como uma interface de acesso ao desenvolvedores]({{ site.baseurl }}/docs/dashboard).

## _Core_ {#core}

Aplicação de _backend_ que implementa a API de interface com a _Dashboard_. Esta aplicação, implementada em [NodeJS](https://nodejs.dev/) com [Express](https://expressjs.com/) e [Mongoose](https://mongoosejs.com/), persiste os dados em um banco [MongoDB](https://www.mongodb.com/) e no mensageiro (_broker_) implementado em [Redis](https://redis.io/).

## Autômato _Genesis_ {#genesis}

Este autômato, implementado em [PHP](https://www.php.net), é responsável pela criação de grupos e repositórios no [GitLab](https://about.gitlab.com), organizações e projetos no [Sentry](https://sentry.io) e grupos e sites no [Matomo](https://matomo.org).

## Autômato _Deployer_ {#deployer}

Este autômato, implementado em [PHP](https://www.php.net/), é responsável pelo _deploy_ das aplicações nos _clusters_ remotos.

## Autômato _Doctor_ {#doctor}

Este autômato, implementado em [PHP](https://www.php.net/), é responsável pelo monitoramento e gestão das instâncias nos _clusters_ remotos. Também permite executar o _backup_ por demanda dos dados destas instâncias, [disponibilizando uma interface de acesso a estes arquivos]({{ site.baseurl }}/docs/backup).

## Autômato _Router_ {#router}

Este autômato, implementado em [PHP](https://www.php.net/), é responsável pelo roteamento, certificados SSL e balanceamento de carga no acesso às instâncias.

## GitLab {#gitlab}

Ferramenta responsável pelo armazenamento de gerência de configuração do código-fonte de todas as aplicações. Além disso, nela é realizado o planejamento e acompanhamento dos projetos por meio de _miletones_ e _issues_. Fica, portanto, [disponível para acesso pelos desenvolvedores]({{ site.baseurl }}/docs/project#git).

## Sentry {#sentry}

Ferramenta responsável pelo rastreamento de erros (do inglês, _error tracking_) nas aplicações desenvolvidas, [disponível para acesso pelos desenvolvedores]({{ site.baseurl }}/docs/bug).

## Matomo {#analytics}

Ferramenta responsável pelo monitoramento e análise estatística de uso das aplicações, [disponível para acesso pelos desenvolvedores]({{ site.baseurl }}/docs/analytics).
