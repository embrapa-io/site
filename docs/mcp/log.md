---
layout: page
title: MCP de Logs (Grafana Loki)
subtitle: Consulta dos logs centralizados das aplicações via linguagem natural
permalink: /docs/mcp/log/
---

{% include mcp-copy-url.html %}

O **MCP Server de Logs** conecta assistentes de IA à stack centralizada de observabilidade do Embrapa I/O, permitindo consultar logs de todas as aplicações da plataforma via linguagem natural. O servidor opera sobre o [Grafana Loki](https://grafana.com/oss/loki/) e implementa **controle de acesso por projeto** — cada usuário só visualiza logs das aplicações às quais tem acesso na plataforma.

## Conectar

A URL de conexão do MCP Server é:

<div style="margin: 0 auto; text-align: center;">
  <a class="btn btn-info btn-lg" href="https://mcp.log.embrapa.io" target="_blank"
    onclick="return copyMcpUrl(this);">
    mcp.log.embrapa.io
  </a>
</div>

A autenticação é feita via **OAuth 2.1 com PKCE**. Ao conectar, o fluxo de login abrirá automaticamente no _browser_ para autenticação por e-mail (OTP) — o mesmo mecanismo utilizado pelo MCP do Dashboard.

## Funcionalidades

O servidor expõe **6 _tools_** focadas em consulta e análise de logs:

**Navegação de Projetos** — Lista os projetos do usuário que possuem logs disponíveis no Loki, com detalhamento de aplicações e _stages_ de _deploy_. O controle de acesso é baseado nos projetos vinculados ao usuário na plataforma — a mesma permissão do Dashboard.

**Consulta de Logs** — Busca flexível de logs com filtros por projeto, aplicação, _stage_, nível de log (_ERROR_, _WARN_, _INFO_), texto livre e período temporal. Suporta _tail_ em tempo real (últimas N linhas) e busca direcionada por erros, exceções e _stack traces_.

**Estatísticas** — Volume total de logs e taxa de erros por projeto, com distribuição por _stage_. Útil para identificar aplicações problemáticas ou verificar a saúde geral de um projeto.

## Exemplos de _Prompts_

Abaixo, exemplos do que pode ser solicitado em linguagem natural a um assistente de IA conectado a este MCP:

```
Quais projetos meus têm logs disponíveis?
```

```
Mostre os últimos 50 logs do pasto-certo/api em release.
```

```
Busque erros no projeto arena nas últimas 24 horas.
```

```
Tem algum ECONNREFUSED nos logs do fertiliza/backend em alpha?
```

```
Qual a taxa de erros do projeto publica nas últimas 24 horas?
```

```
Liste os logs do embrapa-io/grafana com nível ERROR na última hora.
```

```
Faça um diagnóstico do projeto mecaniza: verifique erros recentes em todas
as aplicações e me diga se tem algo preocupante.
```

## Configuração em IDEs e CLIs

A configuração segue o padrão unificado descrito em [Configuração em IDEs e CLIs]({{ site.baseurl }}/docs/mcp/#config). Basta usar a URL `https://mcp.log.embrapa.io`. Exemplo no **Claude Code**:

```bash
claude mcp add --scope user --transport http loki https://mcp.log.embrapa.io
```

> **Dica!** Ao configurar o conector no Claude Desktop/Web ele ficará disponível automaticamente no Claude Code.

## Referência Técnica

### _Tools_ (6)

#### Navegação

| _Tool_ | Descrição |
|--------|-----------|
| `list_projects` | Lista os projetos do usuário que possuem logs no Loki, incluindo aplicações e _stages_ com dados disponíveis. O escopo é resolvido via API do backend com o JWT do usuário — mesma permissão do Dashboard. |
| `list_builds` | Lista as aplicações e _stages_ de _deploy_ de um projeto específico que possuem logs disponíveis no Loki. |

#### Consulta de Logs

| _Tool_ | Descrição |
|--------|-----------|
| `query_logs` | Consulta logs de um projeto no Grafana Loki. Filtros: aplicação, _stage_ (`alpha`, `beta`, `release`), nível de log (`ERROR`, `WARN`), texto livre e período (`1h`, `24h`, `7d`). Retorna _timestamp_, linha de log e _labels_ (serviço, _container_, _host_). |
| `tail_logs` | Exibe as últimas N linhas de log de um projeto (equivalente a `tail`). Útil para verificar rapidamente o que está acontecendo em tempo real. |
| `search_errors` | Busca por erros, exceções, _stack traces_ e falhas de conexão nos logs de um projeto. Suporta padrão adicional para filtrar erros específicos (ex: `ECONNREFUSED`, `timeout`, `500`, `OutOfMemory`). |

#### Estatísticas

| _Tool_ | Descrição |
|--------|-----------|
| `log_stats` | Mostra estatísticas de volume e taxa de erros dos logs de um projeto: total de linhas, distribuição por _stage_ e percentual de erros. Útil para visão rápida da saúde de um projeto. |
