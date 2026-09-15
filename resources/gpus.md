---
layout: page
title: GPU Servers
subtitle: Catálogo de servidores de inferência (LLMs) disponíveis às aplicações
---

Um **GPU Server** é um servidor de inferência de modelos de linguagem (LLMs) e de _embeddings_ mantido pela Embrapa e acessível, pela rede interna, a partir de determinados [_clusters_]({{ site.baseurl }}/resources/clusters) da plataforma. As aplicações instanciadas nesses _clusters_ consomem os modelos por APIs padronizadas: a API compatível com OpenAI (`/v1`) para chat, visão e _tool calling_, e a API nativa do [Ollama](https://ollama.com) (`/api`) para _embeddings_.

A lista abaixo é montada no momento do acesso a partir do catálogo oficial da plataforma. Para cada servidor são exibidos a arquitetura da GPU, a memória, os _runtimes_, os modelos publicados e os _clusters_ a partir dos quais ele está disponível. Endereços completos, chaves e limites de uso são exibidos na [_dashboard_](https://dashboard.embrapa.io) ao [configurar a _build_]({{ site.baseurl }}/docs/build#cluster) em um _cluster_ que enxerga o servidor.

{% include catalog.html type="gpus" %}

> **Atenção!** Os GPU Servers não são acessíveis pela Internet: só respondem a requisições originadas nos _clusters_ indicados em cada item. Uma aplicação instanciada em outro _cluster_ (ou fora da plataforma, via [Releaser]({{ site.baseurl }}/docs/releaser)) não os alcança.
