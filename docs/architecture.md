---
layout: page
title: Arquitetura
subtitle: Módulos que compõem a plataforma
---

O **Embrapa I/O** é uma [plataforma de software de código-aberto]({{ site.baseurl }}/license), [disponível publicamente](https://github.com/embrapa-io), composta por diversos componentes desacoplados:

![Arquitetura do Embrapa I/O]({{ site.baseurl }}/assets/img/arch.png)

Os círculos numerados representam as interfaces disponíveis para os desenvolvedores, sendo elas:

1. [https://dashboard.embrapa.io](https://dashboard.embrapa.io) - Painel de Controle / _Dashboard_
2. [https://git.embrapa.io](https://git.embrapa.io) - GitLab
3. [https://bug.embrapa.io](https://bug.embrapa.io) - Sentry
4. [https://hit.embrapa.io](https://hit.embrapa.io) - Matomo
5. [https://log.embrapa.io](https://log.embrapa.io) - Grafana Loki
6. [https://code.embrapa.io](https://code.embrapa.io) - SonarQube
7. [https://iot.embrapa.io](https://iot.embrapa.io) - ThingsBoard
8. [https://backup.embrapa.io](https://backup.embrapa.io) - Backup
9. [https://hub.docker.com/r/embrapa/releaser](https://hub.docker.com/r/embrapa/releaser) - Releaser

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

## Integrações

A plataforma **Embrapa I/O** é integrada com várias ferramentas que apoiam as diversas etapas do processos de desenvolvimento de software. É utilizada apenas a variante _open source_ de cada ferramenta, mantida por suas respectivas comunidades.

### a. GitLab {#gitlab}

O [GitLab](https://gitlab.com) é a ferramenta responsável pelo [armazenamento de gerência de configuração do código-fonte]({{ site.baseurl }}/docs/project#git) de todas as aplicações. Além disso, nela é realizado o [planejamento e acompanhamento dos projetos]({{ site.baseurl }}/docs/kanban) por meio de _milestones_ e _issues_.

### b. Sentry {#sentry}

O [Sentry](https://sentry.io) é a ferramenta responsável pelo [rastreamento de erros (do inglês, _error tracking_)]({{ site.baseurl }}/docs/bug) nas aplicações desenvolvidas.

### c. Matomo {#analytics}

O [Matomo](https://matomo.org) é a ferramenta responsável pelo [monitoramento de acessos e análise estatística]({{ site.baseurl }}/docs/analytics) de uso das aplicações.

### d. Grafana Loki {#grafana}

O [Grafana Loki](https://grafana.com/docs/loki) é a ferramenta responsável por [coletar e indexar os logs (do inglês, _logging_)]({{ site.baseurl }}/docs/health) de todas as aplicações que estejam hospedadas na [rede de _clusters_]({{ site.baseurl }}/docs/build#cluster) da plataforma.

### e. SonarQube {#sonarqube}

O [SonarQube](https://www.sonarsource.com/products/sonarqube/) é a ferramenta responsável por realizar a análise estática do código das aplicações e gerar relatórios de qualidade apontando problemas de manutenibilidade, confiabilidade e segurança.

### f. ThingsBoard {#thingsboard}

O [ThingsBoard](https://thingsboard.io) é um _middleware_ para internet das coisas (do inglês, _Internet of Things - IoT_) e é a ferramenta responsável por integrar dispositivos de borda à plataforma **Embrapa I/O** provendo um repositório para armazenamento de dados dos sensores e a criação de regras de automação para os atuadores.

## Releaser {#releaser}

Ferramenta "avulsa" à plataforma, que permite a entrega (_deploy_) de aplicações em ambientes externos, tal como servidores em _data centers_ de parceiros ou em nuvens privadas. A ferramenta está [disponível publicamente para uso pelos desenvolvedores]({{ site.baseurl }}/docs/releaser).
