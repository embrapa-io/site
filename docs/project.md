---
layout: page
title: Projetos
subtitle: Como criar um novo projeto de ativo digital?
---

Ao [acessar a _dashboard_]({{ site.baseurl }}/docs/dashboard) da plataforma, o usuário verá na barra superior um **botão para criar um novo projeto**.

> **Atenção!** Somente empregados da Embrapa podem criar novos projetos.

Ao clicar neste botão abrirá um _wizard_ para criação do projeto. O primeiro passo é um _disclaimer_, o qual o usuário deverá estar ciente.

![Tela de aviso da criação de projetos]({{ site.baseurl }}/assets/img/project/01.png)

No segundo passo o usuário poderá escolher um **nome legível para o projeto**, um **nome _unix_** (sem acentos, espaços ou caracteres especiais) e quais **repositórios de suporte** deverão ser gerados automaticamente.

![Configuração do projeto]({{ site.baseurl }}/assets/img/project/02.png)

## Repositórios de Suporte

Os repositórios de suporte podem ser de 6 (seis) tipos distintos:

#### I. Site de informações públicas do projeto

Todo projeto **embrapa.io** pode instanciar um **site público de documentação**. Esta funcionalidade é baseada no [GitHub Pages](https://pages.github.com) e funciona de forma muito similar. Na prática o desenvolvedor pode documentar as aplicações que compõem o projeto utilizando [linguagem Markdown](https://www.markdownguide.org) de forma bastante simplificada.

Quando esta opção é selecionada, o autômato de criação de entidades da plataforma irá criar um novo repositório (denominado ```_web```) no grupo do projeto no [GitLab](https://git.embrapa.io) com o código-fonte inicial desta página. Ao mesmo tempo, o autômato de _deploy_ da plataforma irá instanciar a página e disponibilizá-la publicamente no endereço ```https://project.embrapa.io/[nome unix do projeto]```. Toda alteração realizada neste repositório e versionada (_pull_) é automaticamente atualizada no site do projeto.

#### II. Documentação pública da API

O desenvolvedor poderá instanciar a documentação em [Swagger](https://swagger.io) da(s) API(s) disponível(is) no projeto. Ao selecionar esta opção, o autômato de criação de entidades irá criar um  ele poderá evoluir um novo repositório (denominado ```_api```) no grupo do projeto no [GitLab](https://git.embrapa.io) com o código-fonte inicial desta documentação. Ao mesmo tempo, o autômato de _deploy_ da plataforma irá instanciar a página de documentação da API e disponibilizá-la publicamente no endereço ```https://api.embrapa.io/[nome unix do projeto]```. Da mesma forma que o site público, cada alteração e versionamento (_pull_) neste repositório atualiza automaticamente esta documentação pública.


