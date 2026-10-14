---
layout: page
title: MCP do Sentry
subtitle: Rastreamento de erros e issues do bug.embrapa.io via linguagem natural
share-title: "MCP do Sentry | Embrapa I/O"
share-description: "MCP Server do Embrapa I/O para investigar erros, issues e releases das aplicações no Sentry (bug.embrapa.io) em linguagem natural."
permalink: /docs/mcp/bug/
---

O rastreamento de erros da plataforma utiliza o **MCP oficial do Sentry** — o [`getsentry/sentry-mcp`](https://github.com/getsentry/sentry-mcp), mantido pela própria [Sentry](https://sentry.io). Ele conecta assistentes de IA (Claude, Gemini, Copilot, Cursor, etc.) à instância de _bug tracking_ do **Embrapa I/O** ([bug.embrapa.io](https://bug.embrapa.io)), permitindo investigar exceções, analisar _issues_, consultar projetos e DSNs — tudo via linguagem natural.

Diferente dos demais MCPs da plataforma (servidores HTTP próprios, com _login_ OAuth e URL de conexão), este é o servidor oficial da Sentry e roda por **transporte `stdio`**: o processo executa **localmente** na máquina do desenvolvedor (via Node/`npx`) e se conecta à instância _self-hosted_ apontando para `bug.embrapa.io`. Uma versão hospedada com URL própria (`mcp.bug.embrapa.io`, _streamable HTTP_) está planejada; até lá, siga a configuração `stdio` descrita abaixo.

## Conectar

Não há URL de conexão (o transporte é `stdio`). O servidor é o pacote npm **`@sentry/mcp-server`**, executado localmente. Pré-requisitos:

- **Node.js** instalado (versão LTS — 20 ou superior), que fornece o `npx`;
- um **Auth Token** do Sentry criado em `bug.embrapa.io` (veja abaixo).

Comando base (referência — os clientes abaixo encapsulam isto):

```bash
npx -y @sentry/mcp-server@latest --access-token=SEU_TOKEN --host=bug.embrapa.io --disable-skills=seer
```

- `--host=bug.embrapa.io` — aponta para a instância _self-hosted_ (sem isto, o pacote tenta o Sentry _cloud_);
- `--disable-skills=seer` — o **Seer** (análise por IA da Sentry) não existe no _self-hosted_ e **não há como ativá-lo** na instância. Desde a versão 0.42 o pacote já o descarta sozinho quando o `--host` não é `sentry.io`; a _flag_ (ou a variável `MCP_DISABLE_SKILLS=seer`) continua recomendada por ser explícita e valer em qualquer versão;
- o token pode ser passado pela variável de ambiente `SENTRY_ACCESS_TOKEN` em vez de `--access-token` (recomendado nos arquivos de configuração).

### Criar o Auth Token

1. Acesse [bug.embrapa.io](https://bug.embrapa.io) e faça _login_;
2. Vá em **User Settings → Auth Tokens** (`https://bug.embrapa.io/settings/account/api/auth-tokens/`);
3. Clique em **Create New Token** e selecione os _scopes_:
   ```
   org:read   project:read   project:write   team:read   team:write   event:write
   ```
4. Copie o token gerado (começa com `sntryu_…`) — ele **não** é exibido novamente.

> **Atenção!** O token herda as permissões da **sua conta**: você só enxerga as organizações e projetos aos quais já tem acesso no `bug.embrapa.io`.

## Funcionalidades

O servidor oficial expõe _tools_ para os principais fluxos de _debugging_:

**Organizações, Times e Projetos** — Listagem das organizações, times e projetos acessíveis ao usuário; criação de projetos/times e consulta de configurações.

**Issues e Eventos** — Detalhamento de uma _issue_ (mensagem de erro, _stack trace_, frequência, versões afetadas), consulta de eventos individuais e atualização de _status_ (resolver, ignorar).

**Busca** — _Tools_ de busca (`search_issues`, `search_issue_events`, `search_events`) que aceitam a [sintaxe de consulta do Sentry](https://docs.sentry.io/concepts/search/) (`is:unresolved environment:production release:app@1.2.3`) e, opcionalmente, linguagem natural traduzida por um modelo de IA.

**Releases e DSNs** — Consulta de _releases_ e das _client keys_ (DSNs) de cada projeto.

**Documentação** — Consulta da documentação oficial do Sentry (SDKs, integração) diretamente pelo assistente.

> **Nota!** O servidor pode usar um **provedor de LLM próprio** (variáveis `EMBEDDED_AGENT_PROVIDER` e `OPENAI_API_KEY`/`ANTHROPIC_API_KEY`) apenas para **traduzir linguagem natural** para a sintaxe do Sentry. **Não é necessário:** sem provedor, o `search_issues` e o `search_issue_events` funcionam normalmente desde que o assistente escreva a consulta na sintaxe do Sentry (é o que os clientes de IA fazem sozinhos a partir do seu pedido). Se optar por configurar um provedor, lembre que cada busca envia a pergunta e nomes de campos/_tags_ para esse serviço externo.

> **Atenção!** Na versão atual do pacote (0.42), a _tool_ **`search_events` falha nesta instância** com erro interno de validação (`invalid_type` em `dataset`/`environment`/`query`), mesmo com a consulta na sintaxe do Sentry — não é falta de provedor de LLM nem problema do token. Para contagens e eventos, use **`search_issues`** (devolve o `count` de cada _issue_) e **`search_issue_events`**; não insista variando parâmetros. O **Seer** não existe no _self-hosted_ e nenhuma configuração o ativa — por isso mantemos `--disable-skills=seer`.

> **Nota!** A instância da plataforma opera em modo **somente erros** (`errors-only`): recursos de **_traces_/_performance_, _profiling_, _session replay_, _crons_, _user feedback_ e _metrics_ não são coletados**. Também **não há _release health_** (sessões, taxa _crash-free_, adoção por _release_). Assim, as _tools_ ligadas a _traces_, _replays_, _logs_ e _metrics_ (notadamente `get_trace_details` e os _datasets_ correspondentes do `search_events`) **retornam vazio por desenho** — não é falha do SDK da aplicação nem do servidor. Isso **não afeta** as _tools_ de **erros, _issues_, projetos, _releases_ e DSNs**, que são o foco e funcionam normalmente.

## Exemplos de _Prompts_

Abaixo, exemplos do que pode ser solicitado em linguagem natural a um assistente de IA conectado a este MCP:

```
Liste meus projetos no Sentry e quantas issues abertas cada um tem.
```

```
Mostre os detalhes da issue mais recente do projeto pasto-certo/api:
stack trace, frequência e versões afetadas.
```

```
Quais erros novos apareceram no projeto arena nas últimas 24 horas?
```

```
Resolva a issue 12345 do projeto controlpec/api.
```

```
Qual é o DSN do projeto fertiliza/backend?
```

```
Faça um diagnóstico do projeto mecaniza: principais erros, frequência
e em quais versões eles ocorrem.
```

## Configuração no Claude Code

Como o transporte é `stdio`, a configuração informa o **comando** a executar (não uma URL). O **Claude Code** é o cliente de referência na plataforma — comece por ele.

Adicione o servidor com um único comando (`--scope user` o deixa disponível em qualquer projeto):

```bash
claude mcp add sentry --scope user \
  --env SENTRY_ACCESS_TOKEN=SEU_TOKEN \
  -- npx -y @sentry/mcp-server@latest --host=bug.embrapa.io --disable-skills=seer
```

Confirme a conexão com `claude mcp list` (o `sentry` deve aparecer como _connected_) ou digitando `/mcp` dentro do Claude Code.

> **Dica!** A superfície de _tools_ do pacote muda entre versões. Para um ambiente estável, troque `@latest` por uma versão fixa (ex.: `@sentry/mcp-server@0.42.0`) e atualize deliberadamente.

> **Dica!** Prefira passar o token pela variável `SENTRY_ACCESS_TOKEN` (`--env`), como acima, em vez de `--access-token` no comando — assim ele não fica exposto na linha de execução do processo.

## Outros clientes

De forma acessória, os demais clientes usam o **mesmo servidor `stdio`**. O bloco JSON **canônico** (formato `mcpServers`) é:

```json
{
  "mcpServers": {
    "sentry": {
      "command": "npx",
      "args": ["-y", "@sentry/mcp-server@latest", "--host=bug.embrapa.io", "--disable-skills=seer"],
      "env": { "SENTRY_ACCESS_TOKEN": "SEU_TOKEN" }
    }
  }
}
```

**Cursor, Windsurf, Antigravity e Claude Desktop** usam exatamente esse bloco — cole-o no arquivo correspondente:

| Cliente | Arquivo de configuração |
|---------|--------------------------|
| Claude Desktop | `claude_desktop_config.json` (via **Customize → Developer → Edit Config**) |
| Cursor | `~/.cursor/mcp.json` |
| Windsurf | `~/.codeium/windsurf/mcp_config.json` |
| Google Antigravity | `~/.gemini/antigravity/mcp_config.json` |

**OpenAI Codex CLI** e **Gemini CLI** — mesma lógica do Claude Code:

```bash
# OpenAI Codex CLI
codex mcp add sentry --env SENTRY_ACCESS_TOKEN=SEU_TOKEN \
  -- npx -y @sentry/mcp-server@latest --host=bug.embrapa.io --disable-skills=seer

# Gemini CLI
gemini mcp add sentry -e SENTRY_ACCESS_TOKEN=SEU_TOKEN \
  -- npx -y @sentry/mcp-server@latest --host=bug.embrapa.io --disable-skills=seer
```

**VS Code (GitHub Copilot)** — em `.vscode/mcp.json` (por projeto) ou nas _User Settings_, usa a chave `servers` com `type: stdio`:

```json
{
  "servers": {
    "sentry": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@sentry/mcp-server@latest", "--host=bug.embrapa.io", "--disable-skills=seer"],
      "env": { "SENTRY_ACCESS_TOKEN": "SEU_TOKEN" }
    }
  }
}
```

**GitHub Copilot CLI** — lê servidores MCP no mesmo formato `mcpServers` (bloco canônico); adicione o servidor `sentry` ao arquivo de configuração de MCP do Copilot CLI (consulte a documentação do cliente para o caminho exato na sua versão).

> **Nota!** A partir destes exemplos é possível extrapolar para outros clientes com suporte a MCP `stdio` com poucos ajustes.

## Referência Técnica

A superfície de _tools_ do servidor oficial **evolui entre versões**. No momento, cobre os seguintes domínios:

| Domínio | Descrição |
|---------|-----------|
| Conta | Identificação do usuário dono do token (`whoami`). |
| Organizações e Times | Listagem e criação de organizações e times acessíveis. |
| Projetos | Listagem, criação e atualização de projetos; consulta de DSNs (_client keys_). |
| _Issues_ e Eventos | Detalhamento de _issues_ (_stack trace_, frequência, versões), consulta de eventos e atualização de _status_. |
| Busca | `search_issues` / `search_issue_events` — aceitam a sintaxe do Sentry e funcionam **sem** provedor de LLM (o provedor só traduz linguagem natural). `search_events` **falha nesta instância** na versão 0.42 (ver nota acima). |
| _Releases_ | Consulta de _releases_ dos projetos. |
| Documentação | Consulta da documentação oficial do Sentry. |
| _Traces_ / _Performance_ _(sem dados)_ | `get_trace_details` e a busca de _transactions_ no `search_events` — **não coletados** nesta instância (modo `errors-only`); retornam vazio. |
| Seer _(indisponível)_ | Análise por IA da Sentry — **não** existe no _self-hosted_ e não há como ativá-lo; o pacote já o descarta para _hosts_ fora do `sentry.io`, e mantemos `--disable-skills=seer` por clareza. |

> **Nota!** Para a referência completa e sempre atualizada das _tools_, parâmetros e _flags_, consulte a documentação oficial (_links_ abaixo).

## Documentação oficial (Sentry MCP)

- [Repositório `getsentry/sentry-mcp`](https://github.com/getsentry/sentry-mcp)
- [Serviço e documentação do MCP](https://mcp.sentry.dev/)
- [Pacote `@sentry/mcp-server` (npm)](https://www.npmjs.com/package/@sentry/mcp-server)
