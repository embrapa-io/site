---
layout: post
title: Novos MCPs para gestão do kanban e consulta de logs
subtitle: Disponibilizados novos MCPs autenticados para gestão de issues e milestones no kanban do GitLab e também para acesso e análise dos logs do Grafana Loki.
tags: [ ia, mcp, devops, logs, kanban ]
---

Dois novos **MCP Servers** foram disponibilizados na plataforma, expandindo as possibilidades de interação via linguagem natural com assistentes de IA:

## MCP de Logs — Grafana Loki

O **MCP Server de Logs** conecta assistentes de IA à stack centralizada de observabilidade do **Embrapa I/O**, permitindo consultar logs de todas as aplicações da plataforma diretamente pelo [Claude](https://claude.ai), [Gemini](https://gemini.google.com), [GitHub Copilot](https://github.com/features/copilot) ou qualquer outro cliente compatível.

**URL de conexão:** `https://mcp.log.embrapa.io`

O servidor expõe **6 _tools_** que permitem:

- **Navegar projetos** — Listar projetos e aplicações com logs disponíveis no Loki.
- **Consultar logs** — Buscar logs filtrados por projeto, aplicação, _stage_, nível de log ou texto livre, com suporte a _tail_ em tempo real.
- **Buscar erros** — Encontrar erros, exceções e _stack traces_ com padrões específicos (_ECONNREFUSED_, _timeout_, _OutOfMemory_).
- **Analisar estatísticas** — Volume total de logs e taxa de erros por projeto e _stage_.

O **controle de acesso** é baseado nos projetos vinculados ao usuário na plataforma — cada desenvolvedor só visualiza os logs das aplicações às quais tem permissão. A autenticação utiliza o mesmo fluxo OAuth 2.1 com OTP por e-mail dos demais MCPs.

Exemplo de uso:

```
Busque erros no projeto arena nas últimas 24 horas e me diga se tem algo preocupante.
```

## MCP do Kanban — GitLab

O **MCP Server do Kanban** conecta assistentes de IA ao [GitLab](https://git.embrapa.io) da plataforma, transformando o assistente em um gerente de projeto integrado ao Kanban.

**URL de conexão:** `https://mcp.git.embrapa.io`

O servidor expõe **36 _tools_** organizadas em 7 domínios:

- **_Issues_** — Ciclo completo: criar, consultar, atualizar, fechar e excluir _issues_ com filtros avançados.
- **Relações entre _issues_** — Vínculos de bloqueio e relacionamento entre tarefas, inclusive entre projetos diferentes.
- **Notas e discussões** — Comentários, _threads_ de discussão e marcação de resoluções.
- **_Labels_** — Criação e gestão de _labels_ com cores, descrições e prioridades.
- **_Milestones_** — Gerenciar _sprints_ e acompanhar progresso com _burndown_.
- **Projetos e membros** — Consultar detalhes de projetos e listar membros com níveis de acesso.
- **_Namespaces_ e iterações** — Navegar grupos e acompanhar iterações.

A autenticação é feita pelo **OAuth do próprio GitLab** — ao conectar, o fluxo de _login_ abre automaticamente no _browser_.

Exemplo de uso:

```
Crie uma issue no projeto controlpec/api com título "Implementar endpoint de relatórios",
label "To Do" e atribua ao usuário matheus.amorim.
```

## Configuração

Ambos os MCPs são compatíveis com os mesmos clientes de IA já suportados pelo MCP do Dashboard: **Claude Desktop**, **Claude Code**, **Gemini CLI**, **VS Code + Copilot**, **Cursor**, **Antigravity**, **OpenCode**, **JetBrains**, entre outros.

A configuração segue o mesmo padrão — basta adicionar a URL no cliente de IA preferido. Instruções detalhadas para cada IDE estão na [documentação]({{ site.baseurl }}/docs/mcp/#config).

> **Dica!** Os três MCPs (Dashboard, Logs e Kanban) podem ser utilizados simultaneamente. Com todos conectados, é possível consultar a configuração de uma _build_, verificar os logs e criar uma _issue_ — tudo em uma única conversa.

## Saiba mais

A documentação completa, incluindo referência técnica de todas as _tools_ e exemplos de _prompts_, está disponível em:

- [**MCP de Logs (Grafana Loki) →**]({{ site.baseurl }}/docs/mcp/#loki)
- [**MCP do Kanban (GitLab) →**]({{ site.baseurl }}/docs/mcp/#git)
- [**MCP do Dashboard →**]({{ site.baseurl }}/docs/mcp/#mcp)
