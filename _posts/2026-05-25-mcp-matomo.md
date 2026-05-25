---
layout: post
title: MCP para consulta dos analytics de acesso das aplicações (Matomo)
subtitle: Disponibilizado novo MCP autenticado que permite consultar os relatórios analíticos de acesso das aplicações — tráfego, origens de visitas, páginas mais acessadas, campanhas e comportamento dos usuários — diretamente via linguagem natural em assistentes de IA.
tags: [ ia, mcp, matomo, analytics ]
---

Mais um **MCP Server** foi disponibilizado na plataforma, ampliando o alcance dos assistentes de IA do **Embrapa I/O**: agora também é possível consultar os **_analytics_ de acesso** das aplicações diretamente pelo [Claude](https://claude.ai), [Gemini](https://gemini.google.com), [GitHub Copilot](https://github.com/features/copilot) ou qualquer outro cliente compatível — sem precisar navegar pelos relatórios do Matomo.

## MCP do Matomo — analytics de acesso das aplicações

Diferentemente dos demais MCPs da plataforma (desenvolvidos internamente), este utiliza o **plugin oficial [MCP Server do Matomo](https://plugins.matomo.org/McpServer)**, que é mantido oficialmente pela própria Matomo, conectado à instância de _analytics_ do **Embrapa I/O** em [hit.embrapa.io](https://hit.embrapa.io).

O servidor é **orientado a leitura** e dá acesso, em linguagem natural, aos relatórios de _analytics_ das aplicações:

- **Tráfego e visitas** — visitas, visitantes únicos, _page views_ e tendências ao longo do tempo.
- **Origens** — de onde vêm os acessos (busca, referência, campanhas, acesso direto).
- **Conteúdo** — páginas mais acessadas, entradas e saídas.
- **Audiência** — dispositivos, navegadores, localização geográfica e idioma.
- **Campanhas e metas** — desempenho de campanhas e taxas de conversão das metas configuradas.

**URL de conexão:** `https://mcp.hit.embrapa.io`

A autenticação utiliza o **login do próprio Matomo** (via OAuth 2.0 com PKCE). O acesso é limitado aos mesmos sites e relatórios que o usuário já enxerga no Matomo.

## Funcionalidades

O servidor expõe _tools_ orientadas a leitura em torno dos domínios de _analytics_ do Matomo:

- **Sites** — listagem das aplicações acessíveis ao usuário, com seus identificadores.
- **Relatórios** — descoberta de relatórios e metadados, e obtenção dos dados processados (visitas, páginas, origens, dispositivos, localização, etc.).
- **Metas** — metas de conversão configuradas e seus resultados.
- **Segmentos e dimensões** — filtros e dimensões (inclusive customizadas) disponíveis para análise.

Exemplos de uso:

```
Quais foram as fontes de tráfego com mais visitas no site da minha aplicação
no último mês?
```

```
Gere um resumo executivo do desempenho de acessos da minha aplicação nas
últimas 4 semanas: visitas, visitantes únicos, páginas mais vistas e origens.
```

```
Liste os 10 países que mais geraram visitas à minha aplicação nos últimos 90 dias.
```

## Configuração

O **MCP do Matomo** é compatível com os mesmos clientes de IA já suportados pelos demais MCPs da plataforma: **Claude Desktop**, **Claude Web**, **Claude Code**, **ChatGPT**, **Gemini CLI**, **Perplexity**, **VS Code + Copilot**, **Cursor**, **Antigravity**, **OpenCode**, **JetBrains**, entre outros.

A configuração segue o padrão dos demais — basta adicionar a URL `https://mcp.hit.embrapa.io` no cliente de IA preferido. Instruções detalhadas para cada IDE estão na [documentação]({{ site.baseurl }}/docs/mcp/#config).

> **Dica!** Os cinco MCPs (Dashboard, Logs, Kanban, SEG e Matomo) podem ser utilizados simultaneamente. Com todos conectados, é possível consultar a configuração de uma _build_, verificar os logs, criar uma _issue_ no Kanban, buscar projetos do SEG e ainda analisar os acessos das aplicações no Matomo — tudo em uma única conversa.

## Saiba mais

A documentação completa, incluindo referência técnica das _tools_, mais exemplos de _prompts_ e a documentação oficial do Matomo, está disponível em:

- [**MCP do Matomo →**]({{ site.baseurl }}/docs/mcp/hit/)
- [**MCP do Dashboard →**]({{ site.baseurl }}/docs/mcp/io/)
- [**MCP de Logs (Grafana Loki) →**]({{ site.baseurl }}/docs/mcp/log/)
- [**MCP do Kanban (GitLab) →**]({{ site.baseurl }}/docs/mcp/git/)
- [**MCP do SEG →**]({{ site.baseurl }}/docs/mcp/seg/)
