---
layout: page
title: MCP Servers
subtitle: Conectores Model Context Protocol para LLMs
permalink: /docs/mcp/
---

O [Model Context Protocol (MCP)](https://modelcontextprotocol.io) é um padrão aberto, [criado pela Anthropic](https://www.anthropic.com/news/model-context-protocol) e mantido como [especificação pública](https://spec.modelcontextprotocol.io), que define como aplicações de IA se conectam a fontes de dados e ferramentas externas. Funciona como uma interface universal — similar ao que o USB fez para periféricos — permitindo que _Large Language Models_ (LLMs) interajam diretamente com APIs, bancos de dados e serviços, mantendo o contexto da conversa. A especificação é [_open-source_](https://github.com/modelcontextprotocol) e conta com SDKs oficiais em [TypeScript](https://github.com/modelcontextprotocol/typescript-sdk) e [Python](https://github.com/modelcontextprotocol/python-sdk), além de uma lista crescente de [servidores e clientes compatíveis](https://github.com/modelcontextprotocol/servers).

No contexto do desenvolvimento de software, MCPs eliminam a necessidade de alternar entre o assistente de IA e interfaces web de gerenciamento: o desenvolvedor descreve em linguagem natural o que precisa (criar um projeto, mover uma _issue_, consultar métricas de qualidade) e o LLM executa a operação diretamente na plataforma. Isso reduz fricção, acelera fluxos repetitivos e permite que tarefas de gestão de projeto, _deploy_ e monitoramento sejam integradas ao mesmo ambiente onde o código é escrito — IDE, terminal ou _chat_.

## MCP Servers disponíveis

O **Embrapa I/O** disponibiliza os seguintes MCP Servers que permitem interagir por meio de linguagem natural com diferentes ferramentas e funcionalidades da plataforma:

- [**MCP do Dashboard**]({{ site.baseurl }}/docs/mcp/io/) (`mcp.embrapa.io`) — provê acesso a todas as funcionalidades reunidas no [Painel de Controle](https://dashboard.embrapa.io) da plataforma (projetos, _builds_, _deploys_, equipe, qualidade, etc.).
- [**MCP de Logs (Grafana Loki)**]({{ site.baseurl }}/docs/mcp/log/) (`mcp.log.embrapa.io`) — provê _tools_ para consultar logs centralizados das aplicações, com controle de acesso por projeto, via [Grafana Loki](https://log.embrapa.io).
- [**MCP do Kanban do GitLab**]({{ site.baseurl }}/docs/mcp/git/) (`mcp.git.embrapa.io`) — provê _tools_ para interagir (criar/editar/apagar/correlacionar) os _milestones_ e as _issues_ dos projetos, registrados no Kanban do [GitLab](https://git.embrapa.io) da plataforma.
- [**MCP do SEG**]({{ site.baseurl }}/docs/mcp/seg/) (`seg.mcp.embrapa.io`) — provê _tools_ para consultar dados corporativos do **Sistema Embrapa de Gestão** (projetos, planos, atividades), do catálogo **CatSoft** (softwares), do **portal embrapa.br** (notícias, palavras-chave) e da base de **empregados** da Empresa.
- [**MCP do Matomo**]({{ site.baseurl }}/docs/mcp/hit/) (`mcp.hit.embrapa.io`) — provê _tools_ para consultar os _analytics_ de acesso das aplicações (tráfego, origens, páginas, campanhas) no [Matomo](https://hit.embrapa.io) da plataforma, via plugin oficial da Matomo.

> **Dica!** Os cinco MCPs podem ser utilizados **simultaneamente**. Com todos conectados, é possível consultar a configuração de uma _build_ no Dashboard, verificar os logs no Loki, criar uma _issue_ no Kanban, buscar projetos do SEG ou perfis de empregados e ainda analisar os acessos no Matomo — tudo em uma única conversa.

## Configuração em IDEs e CLIs {#config}

Todos os MCPs da plataforma seguem **o mesmo padrão de configuração** — muda apenas a **URL** de cada servidor (e, opcionalmente, o nome local que você dá ao conector). Nos exemplos abaixo, **substitua a URL pela do MCP desejado** (veja a lista acima); usamos `https://mcp.embrapa.io` como exemplo.

A maioria dos clientes suporta **OAuth nativo**: ao conectar, o fluxo de _login_ abre automaticamente no _browser_. Os clientes que não suportam OAuth requerem um _access token_ manual no _header_ `Authorization`.

### Claude Desktop

A forma mais prática. Ao adicionar pelo Claude Desktop, o servidor fica disponível automaticamente no Claude Code.

1. Abra o **Claude Desktop**;
2. Vá em **Configurações → Conectores → Adicionar conector personalizado**; e
3. Informe a URL (ex.: `https://mcp.embrapa.io`).

Ao conectar, uma janela de _login_ abrirá para autenticação.

> **Dica!** Se adicionado pelo Claude Desktop, ao digitar `/mcp` no Claude Code o servidor aparecerá disponível e poderá ser utilizado normalmente.

### Claude Code

Via linha de comando:

```bash
claude mcp add --scope user --transport http io https://mcp.embrapa.io
```

### Gemini CLI

```bash
gemini mcp add -s user -t http io https://mcp.embrapa.io
```

Caso necessário, a configuração manual pode ser feita em `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "io": {
      "httpUrl": "https://mcp.embrapa.io",
      "oauth": {
        "authorizationUrl": "https://mcp.embrapa.io/oauth/authorize",
        "tokenUrl": "https://mcp.embrapa.io/oauth/token",
        "registrationUrl": "https://mcp.embrapa.io/oauth/register",
        "scopes": ["mcp:full"]
      }
    }
  }
}
```

### VS Code (GitHub Copilot)

No VS Code com a extensão GitHub Copilot, adicione em `.vscode/mcp.json` (por projeto) ou nas _User Settings_:

```json
{
  "servers": {
    "io": {
      "type": "http",
      "url": "https://mcp.embrapa.io"
    }
  }
}
```

Ou via _Command Palette_: `MCP: Add Server` → HTTP → colar a URL. O VS Code com Copilot suporta OAuth 2.1 nativamente.

### Google Antigravity

Adicione em `~/.gemini/antigravity/mcp_config.json`:

```json
{
  "mcpServers": {
    "io": {
      "serverUrl": "https://mcp.embrapa.io/"
    }
  }
}
```

### Cursor

Adicione em `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "io": {
      "url": "https://mcp.embrapa.io"
    }
  }
}
```

### OpenAI Codex CLI

```bash
codex mcp add io --url https://mcp.embrapa.io
```

> **Atenção!** O Codex CLI possui um [bug conhecido](https://github.com/openai/codex/issues/9634) ([#10332](https://github.com/openai/codex/issues/10332)) com _refresh tokens_ OAuth — ele tenta reutilizar um _refresh token_ já consumido, causando erro "_your refresh token was already used_". Caso ocorra, use autenticação via _bearer token_:
>
> ```bash
> codex mcp add io --url https://mcp.embrapa.io --bearer-token-env-var EMBRAPA_MCP_TOKEN
> export EMBRAPA_MCP_TOKEN="<access_token>"
> ```
>
> O _access token_ pode ser obtido fazendo login por outro cliente (ex: Claude Desktop) ou via fluxo OAuth manual.

### OpenCode CLI

```bash
opencode mcp add io --url https://mcp.embrapa.io
```

### JetBrains (IntelliJ, WebStorm, PyCharm)

Acesse **Settings → Tools → AI Assistant → MCP Servers**, clique em **"+"** → **HTTP / SSE** e informe a URL `https://mcp.embrapa.io`.

### Windsurf

Adicione em `~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "io": {
      "serverUrl": "https://mcp.embrapa.io",
      "headers": {
        "Authorization": "Bearer <ACCESS_TOKEN>"
      }
    }
  }
}
```

> **Atenção!** Windsurf não suporta OAuth nativo para MCP. É necessário obter um _access token_ manualmente e configurá-lo no _header_.

### Zed

Adicione em `~/.config/zed/settings.json`:

```json
{
  "context_servers": {
    "io": {
      "settings": {
        "url": "https://mcp.embrapa.io",
        "headers": {
          "Authorization": "Bearer <ACCESS_TOKEN>"
        }
      }
    }
  }
}
```

> **Atenção!** Zed não suporta OAuth nativo. Requer _access token_ manual.

### Compatibilidade

| Cliente | OAuth Nativo | Configuração |
|---------|:---:|---|
| Claude Desktop | ✅ | UI → Conectores |
| Claude Code | ✅ | `claude mcp add` |
| Gemini CLI | ✅ | `gemini mcp add` |
| VS Code + Copilot | ✅ | `.vscode/mcp.json` |
| Antigravity | ✅ | Config de MCP Servers |
| Codex CLI | ⚠️ | `codex mcp add` ([bug com refresh token](https://github.com/openai/codex/issues/9634)) |
| Cursor | ✅ | `~/.cursor/mcp.json` |
| OpenCode | ✅ | `opencode mcp add` |
| JetBrains | ✅ | Settings → AI Assistant → MCP |
| Windsurf | ❌ | _Bearer token_ manual |
| Zed | ❌ | _Bearer token_ manual |

> **Nota!** A partir destas configurações de referência, pode-se extrapolar para outros clientes com suporte a MCP com poucos ajustes. O **MCP do Matomo** usa o login da própria conta Matomo (e aceita apenas contas até nível _Write_) — veja detalhes na [sua página]({{ site.baseurl }}/docs/mcp/hit/).
