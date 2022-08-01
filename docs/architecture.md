---
layout: page
title: Arquitetura
subtitle: Módulos que compõem a plataforma
---

O **embrapa.io** é uma [plataforma de software de código-aberto]({{ site.baseurl }}/license), [disponível publicamente](https://github.com/embrapa-io), composta por diversos componentes desacoplados:

![Arquitetura do embrapa.io]({{ site.baseurl }}/assets/img/arch.png)

## _Dashboard_ {#dashboard}

Trata-se de uma _single-page application_ (ou aplicação Web responsiva) desenvolvida em JavaScript utilizando o _framework_ [VueJS](https://vuejs.org/) com [Vuetify](https://vuetifyjs.com/en/), permite aos desenvolvedores de ativos digitais terem acesso a todos os projetos dos quais são membros da equipe e suas aplicações.

## _Core_ {#core}

Aplicação de _backend_ que implementa a API de interface com a _Dashboard_. Esta aplicação, implementada em [NodeJS](https://nodejs.dev/) com [Express](https://expressjs.com/) e [Mongoose](https://mongoosejs.com/), persiste os dados em um banco [MongoDB](https://www.mongodb.com/) e no mensageiro (_broker_) implementado em [Redis](https://redis.io/).

## Autômato _Genesis_ {#genesis}

Este autômato, implementado em [PHP](https://www.php.net/), é responsável pela criação de grupos e repositórios no [GitLab](https://about.gitlab.com/), organizações e projetos no [Sentry](https://sentry.io/) e propriedades no [Google Analytics](https://analytics.google.com/).

## Autômato _Deployer_ {#deployer}

Este autômato, implementado em [PHP](https://www.php.net/), é responsável pelo _deploy_ das aplicações nos _clusters_ remotos.

## Autômato _Doctor_ {#doctor}

Este autômato, implementado em [PHP](https://www.php.net/), é responsável pelo monitoramento e gestão das instâncias nos _clusters_ remotos. Também permite executar o _backup_ por demanda dos dados destas instâncias.

## Autômato _Router_ {#router}

Este autômato, implementado em [PHP](https://www.php.net/), é responsável pelo roteamento de _load balancer_ no acesso às instâncias.

## GitLab {#gitlab}

Ferramenta responsável pelo armazenamento de gerência de configuração do código-fonte de todas as aplicações. Além disso, nela é realizado o planejamento e acompanhamento dos projetos por meio de _miletones_ e _issues_.

## Sentry {#sentry}

Ferramenta responsável pelo rastreamento de erros (do inglês, _error tracking_) nas aplicações desenvolvidas.

## Google Analytics {#analytics}

Serviço responsável pelo monitoramento e análise estatística de uso das aplicações.
