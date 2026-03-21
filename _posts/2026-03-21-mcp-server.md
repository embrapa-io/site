---
layout: post
title: MCP Server
subtitle: Lançamento do servidor MCP (Model Context Protocol) do Embrapa I/O.
tags: [ ia, mcp, devops ]
---

Foi lançado o **MCP Server** do **Embrapa I/O**, um _middleware_ inteligente que conecta **clientes de IA** diretamente à plataforma via [Model Context Protocol (MCP)](https://modelcontextprotocol.io). Com ele, assistentes como [Claude](https://claude.ai), [Gemini](https://gemini.google.com), [GitHub Copilot](https://github.com/features/copilot), [Cursor](https://cursor.com) e outros podem interagir com a plataforma — criando projetos, configurando _builds_, monitorando _deploys_ e muito mais — tudo via linguagem natural.

## Como conectar

Basta adicionar a URL "**https://mcp.embrapa.io**" no seu cliente de IA preferido.

A autenticação é feita via **OAuth 2.1 com PKCE**. Ao conectar, o fluxo de _login_ abrirá automaticamente no _browser_ para autenticação por e-mail (OTP) — o mesmo mecanismo já utilizado na plataforma.

O servidor é compatível com os principais clientes de IA do mercado: **Claude Desktop**, **Claude Code**, **Gemini CLI**, **VS Code + Copilot**, **Cursor**, **Antigravity**, **OpenCode**, **JetBrains** (IntelliJ, WebStorm, PyCharm), **Windsurf** e **Zed**. Instruções detalhadas de configuração para cada IDE estão disponíveis na [documentação do MCP Server]({{ site.baseurl }}/docs/mcp/#config).

## O que é possível fazer

O servidor expõe **37 _tools_** e **8 _prompts_ guiados** organizados em 10 domínios:

- **Gestão de Projetos** — Criar projetos com provisionamento automático de GitLab, Sentry, Matomo e SonarQube; classificar ecossistemas; gerenciar repositórios de suporte; e arquivar projetos.
- **Aplicações e _Builds_** — Criar apps a partir de _boilerplates_ do catálogo, configurar _builds_ (_cluster_, variáveis, volumes, URLs e _aliases_), com validação automática de aderência entre _codebase_ e configuração.
- **Operações de _Build_** — Reiniciar instâncias, fazer _backup_, ativar sanitização periódica, e consultar saúde dos _containers_.
- **Gestão de Equipe** — Definir Arquitetos da Solução (_Maintainer_) e Membros da Equipe (_Developer_) em cada projeto.
- **Integrações e Qualidade** — Métricas do SonarQube, rastreamento de erros via Sentry, _analytics_ do Matomo e vulnerabilidades (CVEs) detectadas pelo Trivy.
- **Catálogos** — Explorar _boilerplates_, _clusters_ e orquestradores disponíveis.
- **Monitoramento Consolidado** — Visão agregada de saúde das aplicações e _builds_.
- **_Deploy_ Externo** — Geração automática do `builds.json` para o [Releaser]({{ site.baseurl }}/docs/releaser/).

Todas as _tools_ que alteram dados na plataforma possuem **política de confirmação obrigatória**: a IA apresenta um resumo completo dos dados e aguarda confirmação explícita do usuário antes de executar qualquer ação.

## Prompts guiados

Os 8 _prompts_ guiados facilitam operações comuns:

1. **Visão geral dos projetos** — Resumo organizado de todos os seus projetos
2. **Criar projeto** — Passo-a-passo guiado para criação
3. **Configurar novo app** — Da escolha do _boilerplate_ ao primeiro _deploy_
4. **Realizar _deploy_** — Criação de _git tag_ no formato correto do estágio
5. **Status de _deploy_** — Relatório consolidado de uma _build_
6. **Diagnosticar problemas** — Investigação sistemática de falhas
7. **Gestão de equipe** — Adicionar, remover ou alterar papéis
8. **Relatório de saúde** — Consolidação de qualidade, _bugs_, _analytics_ e _status_

## Saiba mais

A documentação completa, incluindo a referência técnica de todas as 37 _tools_ e instruções de configuração para cada IDE, está disponível em:

[**Documentação do MCP Server →**]({{ site.baseurl }}/docs/mcp/)
