---
layout: post
title: Boilerplate para Vibe Coding
subtitle: Disponibilizado novo boilerplate para Vibe Coding.
# cover-img: /assets/img/dashboard/02.png
# thumbnail-img: /assets/img/icon-back.png
# share-img: /assets/img/icon-back.png
tags: [ videos, boilerplates ]
---

Foi disponibilizado no catálogo do **Embrapa I/O** um novo _boilerplate_ para desenvolvimento de aplicações utilizando a popularmente chamada _vibe coding_. Ou seja, o uso de agentes de IA (tal como o [GitHub Copilot](https://github.com/features/copilot), [OpenAI Codex](https://openai.com/index/openai-codex/), [Gemini CLI](https://github.com/google-gemini/gemini-cli), [Claude Code](https://www.anthropic.com/claude-code), etc) para criação de um software funcional, aderente aos _pipelines_ de DevOps da plataforma e em qualquer linguagem de programação e/ou _framework_.

Este _boilerplate_ é particularmente útil para usuários que queiram iniciar um novo projeto, mas que não encontrem no catálogo a pilha tecnológica com a qual estão mais familiarizados. Neste caso o usuário pode partir deste _boilerplate_ e solicitar ao agente de sua preferência que crie a estrutura do projeto. O código inicial do repositório possui diretrizes e instruções intrínsecas que garantirão todos os elementos requeridos pelo **Embrapa I/O**, tal como os arquivos de parametrização (`.env` e `env.io`), serviços de suporte (_backup_, _restore_ e _sanitize_), _stack_ de containers com rede e volumes externos, integração com as ferramentas-satélite ([Matomo](https://hit.embrapa.io), [Sentry](https://bug.embrapa.io), [SonarQube](https://code.embrapa.io), etc), dentre muitas outras coisas.

![Boilerplate para vibe coding.]({{ site.baseurl }}/assets/img/posts/20250722145511.png)

No vídeo abaixo é mostrado o uso deste _boilerplate_ a partir de 3 agentes: Gemini CLI (modelo `gemini-2.5-pro`), OpenAI Codex (modelo `gpt-4o-mini`) e GitHub Copilot (modelo `Claude Sonnet`). Assim, partimos da criação da aplicação utilizando o _boilerplate_ (pela interface do **Embrapa I/O**) e, com o uso apenas de _prompt_ de comando para os agentes, é criada uma aplicação de _backend_ em PHP para uma API REST com autenticação via _One-Time Password_ (OTP) e JWT totalmente funcional. Ao final, fazemos o processo de validação e _deploy_ em um _cluster_ do catálogo da plataforma em estágio alpha.

<iframe width="730" height="410" src="https://www.youtube.com/embed/Vk2fG3B77m4" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
