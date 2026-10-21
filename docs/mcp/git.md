---
layout: page
title: MCP do GitLab
subtitle: Três formas de gerir issues, milestones e labels do Kanban por agentes de IA
share-title: "MCP do GitLab | Embrapa I/O"
share-description: "Como gerir o Kanban do GitLab (git.embrapa.io) com agentes de IA: o MCP oficial do GitLab (recomendado), a CLI glab para agentes de terminal e o MCP do Embrapa I/O, que será descontinuado."
permalink: /docs/mcp/git/
---

{% include mcp-copy-url.html %}

O Kanban de cada projeto do **Embrapa I/O** vive no grupo do projeto no [GitLab](https://git.embrapa.io) da plataforma: as colunas são os _labels_ (`To Do`, `Doing`, `Alpha`, `Beta`…) e as entregas são os _milestones_ do grupo. Há três formas de um agente de IA trabalhar nesse Kanban:

| | Para quê | Onde funciona |
|---|---|---|
| [**MCP oficial do GitLab**](#official) | **Recomendado.** O dia a dia do Kanban: listar colunas, criar e mover _issues_, comentar | Qualquer cliente MCP: Claude Desktop e Web, ChatGPT, VS Code, Cursor, Claude Code |
| [**CLI `glab`**](#glab) | O que o MCP oficial ainda não faz: criar _milestones_ de grupo, _labels_ e _boards_ | Só agentes de terminal, como o Claude Code e o Codex |
| [**MCP do Embrapa I/O**](#legacy) (`mcp.git.embrapa.io`) | Perdeu a serventia diante dos dois anteriores | **Será descontinuado** |

## MCP oficial do GitLab (recomendado) {#official}

Desde a versão 19.5 do GitLab, o **MCP Server oficial** é um recurso estável, mantido pela própria GitLab e disponível em todas as edições, inclusive a _Community Edition_ da plataforma. Ele roda dentro do GitLab, é atualizado junto com ele e é o caminho recomendado pela GitLab para conectar assistentes de IA. É o ideal para agentes usados no _desktop_ e na _web_.

A URL de conexão é:

<div style="margin: 0 auto; text-align: center;">
  <a class="btn btn-info btn-lg" href="https://git.embrapa.io/api/v4/mcp" target="_blank"
    onclick="return copyMcpUrl(this);">
    git.embrapa.io/api/v4/mcp
  </a>
</div>

A autenticação é feita pelo **OAuth** do GitLab: na primeira conexão, o _login_ abre no _browser_ e o assistente passa a agir **com as suas permissões**, nem mais nem menos.

No **Claude Code**:

```bash
claude mcp add -s user --transport http GitLab https://git.embrapa.io/api/v4/mcp
```

Depois, digite `/mcp` na conversa, escolha **GitLab** e autentique. Nos demais clientes, siga o padrão de [Configuração em IDEs e CLIs]({{ site.baseurl }}/docs/mcp/#config) com a URL acima, ou as instruções da [documentação do GitLab](https://docs.gitlab.com/user/model_context_protocol/mcp_server/).

### O que faz no Kanban

- **Listar as _issues_ do grupo inteiro** (`list_work_items`), com filtros por _label_ (a coluna), _milestone_, responsável, autor, estado e datas. Diferentemente do MCP do Embrapa I/O, que opera projeto a projeto, ele enxerga o Kanban do grupo de uma vez.
- **Criar e atualizar _issues_** (`save_work_item`): título, descrição, _labels_, _milestone_, responsáveis, prazo e estado. Mover um _card_ de coluna é adicionar um _label_ e remover outro. _Labels_ e _milestones_ são procurados no projeto e nos grupos acima dele, e um nome inexistente gera erro em vez de ser ignorado.
- **Ler uma _issue_ com comentários e discussões** (`get_work_item`) e **comentar** (`save_note`).
- **Navegar pelos grupos** (`list_groups`) e **buscar** em todo o GitLab (`search`).
- Além do Kanban: _merge requests_, revisão de código, _pipelines_, _jobs_ e _commits_. Veja a [lista completa de _tools_](https://docs.gitlab.com/user/model_context_protocol/mcp_server_tools/).

O que ele **ainda não faz**: criar, editar ou listar _milestones_ e _labels_, nem gerir _boards_. Ele só usa os que já existem. Para isso, use o [`glab`](#glab) ou a interface do GitLab.

> **Dica!** Para expor só as _tools_ do Kanban e deixar o contexto do assistente mais leve, envie o cabeçalho `X-Gitlab-Enabled-Mcp-Server-Toolsets` com os grupos desejados. No Claude Code: `claude mcp add -s user --transport http GitLab https://git.embrapa.io/api/v4/mcp --header "X-Gitlab-Enabled-Mcp-Server-Toolsets: core,work_items"`.

## CLI `glab` (agentes de terminal) {#glab}

O [`glab`](https://gitlab.com/gitlab-org/cli) é a linha de comando oficial do GitLab. Ele cobre o que o MCP oficial ainda não faz, principalmente **criar _milestones_ de grupo** e **_boards_**, e serve a quem usa agentes que executam comandos no terminal, como o **Claude Code** e o **Codex**. Assistentes que rodam só no _browser_ ou no _desktop_, sem terminal, não conseguem usá-lo.

Instale (por exemplo, `brew install glab` ou o pacote da sua distribuição) e autentique na instância da plataforma:

```bash
glab auth login --hostname git.embrapa.io
```

> **Atenção!** Fora de um clone de repositório do `git.embrapa.io`, o `glab` usa o `gitlab.com` por padrão. Defina `export GITLAB_HOST=git.embrapa.io` ou, nas chamadas à API, use `glab api … --hostname git.embrapa.io`.

Comandos úteis no Kanban (`<grupo>` é o nome Unix do projeto na plataforma):

```bash
glab issue list -g <grupo> -l Doing                     # uma coluna do Kanban do grupo
glab issue list -g <grupo> -m 1.26.11 -O json           # issues de um milestone, em JSON
glab issue update 42 -l Alpha -u Doing                  # move a issue #42 de Doing para Alpha
glab issue note 42 -m "Validado na reunião de hoje."    # comenta
glab milestone create --group <grupo> --title 1.26.11 \
  --start-date 2026-11-02T00:00:00Z --due-date 2026-11-06T00:00:00Z
glab milestone list --group <grupo>
glab label list -g <grupo>                              # labels do grupo (criação: só em projeto)
glab issue board view                                   # board interativo no terminal
```

Peça ao agente em linguagem natural ("crie os _milestones_ das próximas quatro semanas no grupo `controlpec`") e ele monta os comandos.

## MCP do Embrapa I/O (será descontinuado) {#legacy}

O `mcp.git.embrapa.io` foi criado em março de 2026, quando o GitLab ainda não tinha um MCP estável. Com o MCP oficial, que opera no grupo inteiro e é mantido pela GitLab, e o `glab` para o que falta, ele **perdeu a serventia e será descontinuado**. Quem o utiliza deve migrar para o [MCP oficial](#official).

Enquanto estiver no ar, a URL de conexão é `https://mcp.git.embrapa.io`, também com **OAuth** do GitLab:

```bash
claude mcp add --scope user --transport http git-kanban https://mcp.git.embrapa.io
```

Ele expõe 36 _tools_, **sempre por projeto** (não por grupo): _issues_ (criação, consulta, atualização, exclusão), vínculos entre _issues_ (`relates_to`, `blocks`, `is_blocked_by`), notas e discussões, _labels_ e _milestones_ de projeto (inclusive a promoção de _milestone_ para o grupo e os eventos de _burndown_), projetos, membros e _namespaces_.

## Exemplos de _Prompts_

Com o MCP oficial conectado (ou o `glab`, num agente de terminal):

```
Quais são as minhas issues abertas no GitLab?
```

```
Liste as issues do grupo controlpec na coluna "Doing", com responsável e milestone.
```

```
Crie uma issue no projeto controlpec/api com título "Implementar endpoint de relatórios",
label "To Do", milestone 1.26.11 e atribua ao usuário matheus.amorim.
```

```
Mova todas as issues do grupo controlpec que estão em "To Do" para "Doing".
```

```
Adicione um comentário na issue #3 do controlpec/pwa informando que
o layout foi validado pelo Sânzio na reunião de hoje.
```

Só com o `glab`, num agente de terminal:

```
Crie no grupo controlpec os milestones das próximas quatro semanas,
um por semana (segunda a sexta), com os títulos no formato das versões.
```
