---
layout: page
title: Boilerplates
subtitle: Catálogo de boilerplates disponíveis na plataforma
---

Um [_boilerplate_]({{ site.baseurl }}/docs/introduction#boilerplate) é o ponto de partida de uma [aplicação]({{ site.baseurl }}/docs/app#boilerplate): a menor estrutura de código capaz de instanciar um software em determinada tecnologia, já conteinerizada, integrada às ferramentas de monitoramento e aderente aos _pipelines_ de DevOps do **Embrapa I/O**. Qualquer usuário da plataforma pode [propor um novo _boilerplate_]({{ site.baseurl }}/docs/boilerplate) ou [melhorias em um existente]({{ site.baseurl }}/docs/merge).

A lista abaixo é montada no momento do acesso a partir do catálogo oficial da plataforma, o mesmo que a [_dashboard_](https://dashboard.embrapa.io) exibe ao criar uma aplicação. Filtre por nome, descrição ou tipo e expanda um item para ver o repositório, as referências e os mantenedores.

**Como usar um _boilerplate_:** na [_dashboard_](https://dashboard.embrapa.io), no _card_ do projeto, clique em **Nova App** e selecione-o no _wizard_ ([veja o passo a passo]({{ site.baseurl }}/docs/app#boilerplate)). O contato com os mantenedores também é feito pela _dashboard_.

{% include catalog.html type="boilerplates" %}

> **Atenção!** Por padrão as imagens dos serviços que compõem a _stack_ de um _boilerplate_ usam a tag `latest`. Antes de publicar uma aplicação, [avalie fixar as versões das imagens]({{ site.baseurl }}/docs/app#boilerplate).
