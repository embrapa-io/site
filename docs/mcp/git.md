---
layout: page
title: MCP do Kanban do GitLab
subtitle: Gestão de issues, milestones e labels no Kanban via linguagem natural
permalink: /docs/mcp/git/
---

{% include mcp-copy-url.html %}

O **MCP Server do Kanban** conecta assistentes de IA diretamente ao [GitLab](https://git.embrapa.io) da plataforma, permitindo gerenciar _issues_, _milestones_, _labels_ e relações entre tarefas via linguagem natural. O servidor opera sobre a API do GitLab e expõe as operações como _tools_ MCP, transformando o assistente de IA em um gerente de projeto integrado ao Kanban.

## Conectar

A URL de conexão do MCP Server é:

<div style="margin: 0 auto; text-align: center;">
  <a class="btn btn-info btn-lg" href="https://mcp.git.embrapa.io" target="_blank"
    onclick="return copyMcpUrl(this);">
    mcp.git.embrapa.io
  </a>
</div>

A autenticação é feita pelo **OAuth** do próprio GitLab. Ao conectar, o fluxo de _login_ abrirá automaticamente no _browser_ para autenticação na instância do GitLab da plataforma.

## Funcionalidades

O servidor expõe **36 _tools_** organizadas nos seguintes domínios:

**Issues** — Ciclo completo de gestão de _issues_: criação com título, descrição, _labels_, _milestone_ e responsáveis; consulta individual ou listagem com filtros avançados (estado, _labels_, _milestone_, responsável, datas, tipo); atualização de qualquer campo (título, descrição, _labels_, estado, _milestone_, responsáveis, peso, confidencialidade, tipo); exclusão; e listagem das _issues_ atribuídas ao usuário autenticado.

**Relações entre _Issues_** — Criação de vínculos entre _issues_ de um mesmo projeto ou entre projetos diferentes, com três tipos de relação: `relates_to` (relacionada), `blocks` (bloqueia) e `is_blocked_by` (bloqueada por). Consulta e remoção de vínculos existentes.

**Notas e Discussões** — Adição de comentários em _issues_ e _merge requests_. Criação de notas em _threads_ de discussão existentes, edição de notas e marcação como resolvidas/não-resolvidas. Listagem de todas as discussões de uma _issue_.

**_Labels_** — Criação, consulta, atualização (nome, cor, descrição, prioridade) e exclusão de _labels_ em projetos. Suporte a _labels_ herdados de grupos ancestrais.

**_Milestones_** — Criação, consulta, edição (título, descrição, datas, estado) e exclusão de _milestones_. Promoção de _milestone_ de projeto para grupo. Consulta de _issues_ e _merge requests_ associados a um _milestone_. Eventos de _burndown_ para acompanhamento de progresso.

**Projetos e Membros** — Consulta de detalhes de projetos e listagem de projetos acessíveis (com filtros por visibilidade, linguagem, funcionalidades habilitadas). Listagem de projetos dentro de um grupo. Consulta de membros de um projeto (com suporte a herança de grupo).

**_Namespaces_ e Iterações** — Consulta e listagem de _namespaces_ (grupos e usuários), verificação de existência de _namespace_. Listagem de iterações de grupo com filtros por estado e período.

## Exemplos de _Prompts_

Abaixo, exemplos do que pode ser solicitado em linguagem natural a um assistente de IA conectado a este MCP:

```
Quais são as minhas issues abertas no GitLab?
```

```
Liste todas as issues do projeto controlpec/pwa com label "Doing".
```

```
Crie uma issue no projeto controlpec/api com título "Implementar endpoint de relatórios",
label "To Do" e atribua ao usuário matheus.amorim.
```

```
Mova todas as issues com label "To Do" do projeto controlpec/pwa para "Doing".
```

```
Crie um milestone "Sprint 2026-Q2" no projeto controlpec/pwa
com início em 2026-04-01 e término em 2026-06-30.
```

```
Mostre o progresso do milestone 1.26.12: quantas issues abertas vs. fechadas,
e quais merge requests estão associados.
```

```
Adicione um comentário na issue #3 do controlpec/pwa informando que
o layout foi validado pelo Sânzio na reunião de hoje.
```

```
Crie um vínculo de bloqueio: a issue #1 (plano de contas) bloqueia a issue #2
(filtro por texto) no projeto controlpec/pwa.
```

```
Feche todas as issues com label "Doing" atribuídas a simoes.leonardo
no projeto controlpec/pwa.
```

```
Liste os membros do projeto controlpec/pwa e seus níveis de acesso.
```

## Configuração em IDEs e CLIs

A configuração segue o padrão unificado descrito em [Configuração em IDEs e CLIs]({{ site.baseurl }}/docs/mcp/#config). Basta usar a URL `https://mcp.git.embrapa.io`. Exemplo no **Claude Code**:

```bash
claude mcp add --scope user --transport http git-kanban https://mcp.git.embrapa.io
```

> **Dica!** Ao configurar o conector no Claude Desktop/Web ele ficará disponível automaticamente no Claude Code.

## Referência Técnica

### _Tools_ (36)

#### _Issues_

| _Tool_ | Descrição |
|--------|-----------|
| `my_issues` | Lista _issues_ atribuídas ao usuário autenticado. Filtros: estado, _labels_, _milestone_, projeto, datas e busca textual. |
| `list_issues` | Lista _issues_ com filtros avançados: projeto, estado, _labels_, _milestone_, responsável, autor, tipo (`issue`, `incident`, `test_case`, `task`), datas e escopo (`created_by_me`, `assigned_to_me`, `all`). |
| `get_issue` | Detalhes de uma _issue_ específica: título, descrição, estado, _labels_, _milestone_, responsáveis, peso, datas e referências. |
| `create_issue` | Cria uma _issue_ com título, descrição, _labels_, _milestone_, responsáveis e tipo. |
| `update_issue` | Atualiza qualquer campo de uma _issue_: título, descrição, _labels_, estado (`close`/`reopen`), _milestone_, responsáveis, peso, confidencialidade, tipo e data de entrega. |
| `delete_issue` | Remove uma _issue_ permanentemente de um projeto. |

#### Relações entre _Issues_

| _Tool_ | Descrição |
|--------|-----------|
| `create_issue_link` | Cria vínculo entre duas _issues_ (mesmo projeto ou entre projetos). Tipos: `relates_to`, `blocks`, `is_blocked_by`. |
| `get_issue_link` | Consulta detalhes de um vínculo específico entre _issues_. |
| `list_issue_links` | Lista todos os vínculos de uma _issue_. |
| `delete_issue_link` | Remove um vínculo entre _issues_. |

#### Notas e Discussões

| _Tool_ | Descrição |
|--------|-----------|
| `create_note` | Adiciona um comentário a uma _issue_ ou _merge request_. |
| `create_issue_note` | Adiciona uma nota a um _thread_ de discussão existente em uma _issue_. |
| `update_issue_note` | Edita o conteúdo de uma nota existente. Permite marcar como resolvida ou não-resolvida. |
| `list_issue_discussions` | Lista todas as discussões (_threads_) de uma _issue_ com paginação. |

#### _Labels_

| _Tool_ | Descrição |
|--------|-----------|
| `list_labels` | Lista _labels_ de um projeto, com opção de incluir _labels_ de grupos ancestrais e contagem de _issues_/_merge requests_. |
| `get_label` | Detalhes de um _label_ específico (por ID ou nome). |
| `create_label` | Cria um _label_ com nome, cor (hex), descrição e prioridade. |
| `update_label` | Atualiza nome, cor, descrição ou prioridade de um _label_ existente. |
| `delete_label` | Remove um _label_ de um projeto. |

#### _Milestones_

| _Tool_ | Descrição |
|--------|-----------|
| `list_milestones` | Lista _milestones_ de um projeto com filtros: estado (`active`/`closed`), título, IIDs, datas e _milestones_ de grupos ancestrais. |
| `get_milestone` | Detalhes de um _milestone_ específico. |
| `create_milestone` | Cria um _milestone_ com título, descrição, data de início e data de entrega. |
| `edit_milestone` | Atualiza título, descrição, datas ou estado (`close`/`activate`) de um _milestone_. |
| `delete_milestone` | Remove um _milestone_ de um projeto. |
| `promote_milestone` | Promove um _milestone_ de nível de projeto para nível de grupo. |
| `get_milestone_issue` | Lista _issues_ associadas a um _milestone_. |
| `get_milestone_merge_requests` | Lista _merge requests_ associados a um _milestone_ com paginação. |
| `get_milestone_burndown_events` | Eventos de _burndown_ de um _milestone_ para acompanhamento de progresso. |

#### Projetos e Membros

| _Tool_ | Descrição |
|--------|-----------|
| `get_project` | Detalhes de um projeto: nome, visibilidade, URLs, _branches_, funcionalidades habilitadas e permissões. |
| `list_projects` | Lista projetos acessíveis com filtros: visibilidade, _membership_, linguagem, ordenação e funcionalidades. |
| `list_group_projects` | Lista projetos de um grupo com filtros adicionais: subgrupos, nível de acesso mínimo e estatísticas. |
| `list_project_members` | Lista membros de um projeto com nível de acesso, incluindo membros herdados do grupo. Filtros por nome, _username_ e IDs. |

#### _Namespaces_ e Iterações

| _Tool_ | Descrição |
|--------|-----------|
| `list_namespaces` | Lista _namespaces_ acessíveis (grupos e usuários) com filtros de busca e propriedade. |
| `get_namespace` | Detalhes de um _namespace_ por ID ou caminho completo. |
| `verify_namespace` | Verifica se um caminho de _namespace_ existe no GitLab. |
| `list_group_iterations` | Lista iterações de um grupo com filtros: estado (`opened`, `upcoming`, `current`, `closed`), busca por título e datas. |
