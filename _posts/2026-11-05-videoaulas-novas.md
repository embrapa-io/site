---
layout: post
title: "20 videoaulas novas no canal do Embrapa I/O"
subtitle: Em oito dias, o canal ganhou vinte vídeos curtos, em 4K e num formato novo, que mostram na prática cada recurso da plataforma, do primeiro deploy aos agentes de inteligência artificial.
tags: [ videos ]
---

Desde 29 de outubro, o [canal do **Embrapa I/O** no YouTube](https://www.youtube.com/@embrapa-io) recebeu vinte videoaulas novas. Cada uma ensina, passo a passo, um recurso da plataforma: o que ele resolve, onde fica e como usar, com os botões e os comandos reais em destaque. A maioria tem entre três e oito minutos.

<iframe width="730" height="410" src="https://www.youtube.com/embed/YouJi3eZB6E" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## Um formato novo {#format}

As videoaulas agora são produzidas por um gerador próprio, a partir de um roteiro revisado:

- **Telas reais.** O Dashboard, o GitLab, o SonarQube, o Matomo, o Sentry, o terminal e os assistentes de IA aparecem como são, em projetos de laboratório ou com dados fictícios. Nenhuma tela é desenhada à mão.
- **Voz clonada.** A narração é gerada por inteligência artificial a partir da voz do autor. Cada vídeo traz esse aviso na descrição e está marcado no YouTube como conteúdo alterado ou sintético.
- **Legendas e dublagem.** As legendas em português saem do próprio roteiro, e a dublagem automática do YouTube oferece os vídeos também em inglês e em espanhol.
- **Esperas aceleradas.** Quando um agente de IA ou um _deploy_ leva minutos, o trecho aparece acelerado, com o selo «Acelerado», sem cortar o que acontece.

Os vídeos também estão embutidos nos capítulos correspondentes da [documentação]({{ site.baseurl }}/docs/preface), e as _playlists_ estão no menu **Videoaulas**, no alto desta página.

## Visão geral {#overview}

- [Hospedagem: onde cada estágio da sua aplicação deve rodar](https://youtu.be/wF-dTS0O6YQ): os estágios `alpha`, `beta` e `release` e os _clusters_ de cada um.

[_Playlist_ Visão geral](https://www.youtube.com/playlist?list=PLBTsCa6Rsuz3jh0S2P8aTBlvhk7Mr3gbS)

## Quickstart {#quickstart}

- [Quickstart: do zero ao primeiro deploy](https://youtu.be/YouJi3eZB6E): o acesso ao Dashboard, o projeto, a _app_ e o primeiro _deploy_.
- [Qualidade do Código: o SonarQube em cada aplicação](https://youtu.be/S_MfwAUnIQE): a análise feita a cada _commit_ e como ler o resultado.
- [Boilerplate: trazendo as melhorias do modelo para a sua app](https://youtu.be/zpfSsxY4GBE): como a sua aplicação recebe as correções do _boilerplate_ de onde nasceu.

[_Playlist_ Quickstart](https://www.youtube.com/playlist?list=PLBTsCa6Rsuz2x75zbYwAB1mEYLXbUA1RP)

## Avançado {#advanced}

- [Backup S3: cópia dos backups em nuvem e restauração](https://youtu.be/V7hKe-axlsw): a cópia diária dos _backups_ para um _bucket_ e o _restore_ pelo _Health Check_.
- [Silo e Caddy: um S3 na sua Unidade para os backups](https://youtu.be/AldXJnvqwTc): como montar o S3 da Unidade com dois _boilerplates_.
- [Cluster: um servidor da sua Unidade no catálogo](https://youtu.be/yVHHmz7xYf4): como oferecer um servidor da Unidade para os projetos da plataforma.
- [CVEs Críticos: o que fazer quando chega um alerta de vulnerabilidade](https://youtu.be/2AJF_TLKJRY): o alerta, a análise e a correção.
- [Sentinela: a agente de IA que vigia os projetos](https://youtu.be/paY1iwZVzM4): os relatórios da [Sentinela]({{ site.baseurl }}/docs/sentinel) e como votar nos achados.

[_Playlist_ Avançado](https://www.youtube.com/playlist?list=PLSMuLTEGhNrU)

## Releaser {#releaser}

- [Releaser (vídeo 1): instalar e fazer o primeiro deploy no seu servidor](https://youtu.be/HIPg-lgIgcs)
- [Releaser (vídeo 2): o dia a dia do seu servidor](https://youtu.be/ut1Q9zNUAkw)

[_Playlist_ Releaser](https://www.youtube.com/playlist?list=PLLte_dO8_BwA)

## Boilerplates {#boilerplates}

A série **Do código existente ao boilerplate** leva um sistema desenvolvido fora da plataforma para dentro dela e o transforma num modelo para outras equipes, com a ajuda da [Alice]({{ site.baseurl }}/docs/alice):

- [Vídeo 1: sua app no Embrapa I/O com a Alice](https://youtu.be/w7Qwwf2RFx0): o repositório, a criação da _app_, a conformidade com a plataforma, o SonarQube, o _deploy_ e o _backup_.
- [Vídeo 2: sua app vira modelo com a Alice](https://youtu.be/y1jHk8kJer4): o [_boilerplate_]({{ site.baseurl }}/docs/boilerplate) no catálogo e, como prova, uma aplicação nova criada a partir dele.

[_Playlist_ Boilerplates](https://www.youtube.com/playlist?list=PLcYLxJ-IPTvo)

## Inteligência artificial {#ai}

A série **IA no Embrapa I/O** mostra os assistentes de IA conectados à plataforma pelos [MCP Servers]({{ site.baseurl }}/docs/mcp):

- [Vídeo 1: seu assistente de IA conectado ao Dashboard](https://youtu.be/CS-fjG0qXq0)
- [Vídeo 2: diagnóstico e correção de um bug com o Claude Code](https://youtu.be/LcMJIsnyzOw)
- [Vídeo 3: relatórios de uso dos aplicativos com IA (Matomo)](https://youtu.be/ECtpMIUF6ik)

A série **Agente da Pecuária com n8n** constrói, do zero, um agente que responde perguntas sobre pecuária com o conhecimento da Embrapa (o SAC da Embrapa Gado de Corte, os livros da coleção 500 Perguntas, 500 Respostas e o catálogo do Pasto Certo), sempre citando a fonte. Usa só ferramentas livres e os modelos de IA dos GPU Servers da plataforma:

- [Vídeo 1: o plano, as fontes e a app no ar](https://youtu.be/TspfQAGBCrk)
- [Vídeo 2: a base de conhecimento com RAG e Qdrant](https://youtu.be/K3-AAjCHrEI)
- [Vídeo 3: o agente com RAG, CAG e o Pasto Certo](https://youtu.be/bt63NRuh8sE)
- [Vídeo 4: o agente no ar, na web e no Telegram](https://youtu.be/GeLt1_jh8gI)

[_Playlist_ IA](https://www.youtube.com/playlist?list=PLBTsCa6Rsuz1vsofd7jNhVIMatKfArMpj) · [_Playlist_ Agente da Pecuária com n8n](https://www.youtube.com/playlist?list=PLRFN_Ap6U0vE)

## Acompanhe {#follow}

Inscreva-se no [canal](https://www.youtube.com/@embrapa-io) para receber os próximos vídeos. Dúvidas e sugestões de temas são bem-vindas na [comunidade do Discord](https://discord.embrapa.io).
