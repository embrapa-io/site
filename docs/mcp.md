---
layout: page
title: MCP Servers
subtitle: Conectores Model Context Protocol para LLMs
---

O [Model Context Protocol (MCP)](https://modelcontextprotocol.io) é um padrão aberto, [criado pela Anthropic](https://www.anthropic.com/news/model-context-protocol) e mantido como [especificação pública](https://spec.modelcontextprotocol.io), que define como aplicações de IA se conectam a fontes de dados e ferramentas externas. Funciona como uma interface universal — similar ao que o USB fez para periféricos — permitindo que _Large Language Models_ (LLMs) interajam diretamente com APIs, bancos de dados e serviços, mantendo o contexto da conversa. A especificação é [_open-source_](https://github.com/modelcontextprotocol) e conta com SDKs oficiais em [TypeScript](https://github.com/modelcontextprotocol/typescript-sdk) e [Python](https://github.com/modelcontextprotocol/python-sdk), além de uma lista crescente de [servidores e clientes compatíveis](https://github.com/modelcontextprotocol/servers).

No contexto do desenvolvimento de software, MCPs eliminam a necessidade de alternar entre o assistente de IA e interfaces web de gerenciamento: o desenvolvedor descreve em linguagem natural o que precisa (criar um projeto, mover uma _issue_, consultar métricas de qualidade) e o LLM executa a operação diretamente na plataforma. Isso reduz fricção, acelera fluxos repetitivos e permite que tarefas de gestão de projeto, _deploy_ e monitoramento sejam integradas ao mesmo ambiente onde o código é escrito — IDE, terminal ou _chat_.

O **Embrapa I/O** disponibiliza os seguintes MCP Servers que permitem interagir por meio de linguagem natural com diferentes ferramentas e funcionalidades da plataforma:

- [MCP do Dashboard](#mcp): provê acesso a todas as funcionalidades reunidas no [Painel de Controle](https://dashboard.embrapa.io) da plataforma.
- [MCP do Kanban do GitLab](#git): provê _tools_ para interagir (criar/editar/apagar/correlacionar) os _milestones_ e as _issues_ dos projetos, registrados no Kanban do [GitLab](https://git.embrapa.io) da plataforma.

# MCP do Dashboard {#mcp}

O **MCP Server** do **Embrapa I/O** é um _middleware_ inteligente entre **clientes de IA** e a API da plataforma que implementa o [Model Context Protocol (MCP)](https://modelcontextprotocol.io), permitindo que assistentes de IA como Claude, Gemini, Copilot e Cursor interajam diretamente — criando projetos, configurando _builds_, monitorando _deploys_ e muito mais — tudo via linguagem natural.

## Conectar

A URL de conexão do MCP Server é:

<div style="margin: 0 auto; text-align: center;">
  <a class="btn btn-info btn-lg" href="https://mcp.embrapa.io" target="_blank"
    onclick="event.preventDefault(); navigator.clipboard.writeText(this.href).then(() => { const o = this.textContent; this.textContent = '✔ Link copiado!'; setTimeout(() => this.textContent = o, 2000); });">
    mcp.embrapa.io
  </a>
</div>

A autenticação é feita via **OAuth 2.1 com PKCE**. Ao conectar, o fluxo de login abrirá automaticamente no _browser_ para autenticação por e-mail (OTP).

## Funcionalidades

O servidor expõe **37 _tools_** e **8 _prompts_ guiados** organizados nos seguintes domínios:

**Perfil do Usuário** — Consulta e atualização do perfil na plataforma, incluindo nome de exibição utilizado em todas as interfaces e listagens de equipe.

**Gestão de Projetos** — Criação de projetos (ativos digitais) com provisionamento automático de GitLab, Sentry, Matomo e SonarQube. Classificação por ecossistemas produtivos (agricultura, pecuária, florestal, aquicultura, indústria) ou corporativo. Gerenciamento de repositórios de suporte (documentação pública, Swagger, identidade visual, binários para lojas, TWA). Arquivamento de projetos com confirmação por PIN via e-mail.

**Aplicações e _Builds_** — Criação de aplicações a partir de _boilerplates_ pré-configurados do catálogo, com _fork_ automático no GitLab e 4 _branches_ (`main`, `alpha`, `beta`, `release`). Configuração completa de _builds_ (_cluster_, variáveis de ambiente, volumes, URLs públicas e _aliases_/subdomínios), com validação automática de aderência entre _codebase_ e configuração. Histórico de alterações de variáveis para auditoria. Remoção de _builds_ com confirmação por PIN.

**Operações de _Build_** — Reiniciar instâncias, remover _deploy_ sem apagar configuração, solicitar _backup_ de dados persistentes, e ativar/desativar sanitização periódica (limpeza e otimização mensal). Revalidação de _builds_ que falharam na validação anterior. Consulta de saúde dos _containers_ (_status_, _uptime_, alertas).

**Gestão de Equipe** — Definição da equipe completa de um projeto com dois papéis: Arquiteto da Solução (_Maintainer_ — gerencia configuração, _deploy_ em produção e _backup_) e Membro da Equipe (_Developer_ — codifica e faz _deploy_ em `alpha`/`beta`).

**Portas de Rede** — Alocação e liberação de portas nos _clusters_ da plataforma, necessárias para expor _builds_ via URLs e subdomínios.

**Integrações e Qualidade** — Acesso às métricas de qualidade de código via SonarQube (manutenibilidade, confiabilidade, segurança e _Quality Gate_), rastreamento de erros via Sentry (exceções em _runtime_ categorizadas por severidade e versão) e _analytics_ de acesso via Matomo (sessões, páginas visitadas e comportamento dos usuários).

**Catálogos da Plataforma** — Listagem de _boilerplates_ disponíveis (Node.js, Laravel, Vue.js, WordPress, entre outros) com detalhes de _stack_, documentação e licença. Listagem de _clusters_ disponíveis para _deploy_ (capacidade, _aliases_ e configurações SMTP) e orquestradores suportados.

**Monitoramento Consolidado** — Visão agregada por aplicação combinando Matomo, Sentry e SonarQube em uma única consulta. Saúde de _builds_ específicas (`project/app@stage`) em _clusters_ compartilhados: _status_ do _deploy_, _uptime_, histórico de versões deployadas e vulnerabilidades de segurança (CVEs) detectadas pelo Trivy nos _containers_ — complementar à análise estática do SonarQube, cobrindo dependências de _runtime_, imagens base e bibliotecas do SO.

**_Deploy_ Externo (Releaser)** — Geração do arquivo `builds.json` para _deploy_ e atualização contínua em servidores fora da rede de _clusters_ da plataforma. Coleta automática de equipe, variáveis de ambiente, Sentry DSN e Matomo ID a partir da API ou de arquivos locais do _codebase_, com geração de _secrets_ e _passwords_ randômicos.

**_Prompts_ Guiados** — 8 fluxos interativos para operações comuns: visão geral dos projetos, criação de projeto passo-a-passo, criação de aplicação, _deploy_ via _git tag_, diagnóstico de problemas de _build_, gestão de equipe, _status_ de _deploy_ e relatório de saúde do projeto.

## Exemplos de _Prompts_

Abaixo, exemplos do que pode ser solicitado em linguagem natural a um assistente de IA conectado a este MCP:

```
Mostre uma visão geral de todos os meus projetos no Embrapa I/O, com status das builds.
```

```
Crie um novo projeto chamado "AgroVision" no ecossistema pecuária.
```

```
Adicione uma aplicação ao projeto agrovision usando o boilerplate de Node.js.
```

```
Configure a build alpha do agrovision/api no cluster compartilhado com a variável
de ambiente DATABASE_URL apontando para o MongoDB de homologação.
```

```
Faça o deploy da aplicação agrovision/api em alpha — crie a tag a partir da main.
```

```
A build alpha do agrovision/api está falhando. Faça um diagnóstico completo:
verifique saúde do container, configuração, variáveis e logs do Sentry.
```

```
Gere um relatório de saúde do projeto agrovision: qualidade de código,
bugs rastreados, analytics de acesso e status de cada build.
```

```
Adicione o usuário joao.silva@embrapa.br como Developer no projeto agrovision.
```

```
Liste os boilerplates disponíveis que suportam Vue.js.
```

```
Gere o builds.json para deploy externo do agrovision/pwa em um servidor próprio.
```

## Configuração em IDEs e CLIs {#config}

### Claude Desktop

A forma mais prática. Ao adicionar pelo Claude Desktop, o servidor fica disponível automaticamente no Claude Code.

1. Abra o **Claude Desktop**;
2. Vá em **Configurações → Conectores → Adicionar conector personalizado**; e
3. Informe a URL: `https://mcp.embrapa.io`.

Ao conectar, uma janela de _login_ abrirá para autenticação via e-mail (OTP).

> **Dica!** Se adicionado pelo Claude Desktop, ao digitar `/mcp` no Claude Code o servidor aparecerá como **"claude.ai Embrapa I/O"** e poderá ser utilizado normalmente.

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

## Referência Técnica {#tools}

### _Tools_ (37)

#### Perfil do Usuário

| _Tool_ | Descrição |
|--------|-----------|
| `get_my_profile` | Retorna perfil do usuário autenticado (nome, e-mail, papel e vínculos externos). |
| `update_my_name` | Atualiza o nome de exibição do usuário em todas as interfaces da plataforma. Requer confirmação explícita. |

#### Projetos e Ecossistemas

| _Tool_ | Descrição |
|--------|-----------|
| `list_my_projects` | Lista todos os projetos do usuário com apps, equipe (nomes, e-mails e papéis), ecossistemas e _status_ das _builds_. O campo `archive` é sempre `false` (projetos arquivados não aparecem). |
| `create_project` | Cria um novo projeto com provisionamento automático (GitLab, Sentry, Matomo, SonarQube). O identificador unix (_slug_) é **irreversível**. Salvaguarda: limitado a 1 criação por sessão + _cooldown_ de 5 minutos por usuário. Requer vínculo Embrapa. |
| `update_ecosystems` | Atualiza a classificação de ecossistemas de um projeto. O ecossistema `corporate` é mutuamente exclusivo. Requer _Maintainer_. |
| `request_project_archive` | Inicia o arquivamento de um projeto. Envia PIN de confirmação por e-mail. Operação significativa: desativa _builds_, repos e remove equipe. Requer _Maintainer_. |
| `confirm_project_archive` | Confirma o arquivamento com o PIN recebido. Ação irreversível. |

#### Aplicações e Configuração de _Builds_

| _Tool_ | Descrição |
|--------|-----------|
| `create_app` | Cria uma aplicação a partir de um _boilerplate_ do catálogo. Faz _fork_ no GitLab com 4 _branches_ (`main`, `alpha`, `beta`, `release`). O nome unix do app (máx. 10 caracteres) é **irreversível**. Requer _Maintainer_. |
| `get_build_config` | Obtém a configuração de uma _build_ (`project/app@stage`): _cluster_, variáveis, volumes, URLs e _aliases_. Requer _Maintainer_. |
| `save_build_config` | Salva a configuração completa de uma _build_. Após salvar, a plataforma dispara validação automática (não chamar `revalidate_build`). Antes de salvar, recomenda-se verificar se a _branch_ do estágio está atualizada com a `main`. Requer _Maintainer_. |
| `get_variable_history` | Histórico de alterações das variáveis de ambiente de uma _build_ (cada alteração incrementa a versão). Requer vínculo Embrapa. |
| `request_build_removal` | Solicita remoção completa de uma _build_ (configuração + instância). Envia PIN por e-mail. Diferente de `undeploy_build` (que preserva a configuração). Requer _Maintainer_. |
| `confirm_build_removal` | Confirma remoção permanente com o PIN recebido. |

#### Operações de _Build_

| _Tool_ | Descrição |
|--------|-----------|
| `revalidate_build` | Reenvia uma _build_ para revalidação. Funciona **apenas** para _builds_ com _status_ `INVALID` ou `INACTIVATED`. Não usar logo após `save_build_config` (validação já é automática). |
| `restart_build` | Reinicia a instância de uma _build_ no _cluster_ (com opção de _upgrade_ de imagem). Requer _Maintainer_. |
| `undeploy_build` | Remove a instância sem apagar a configuração. A _build_ pode ser redeployada depois. Requer _Maintainer_. |
| `request_backup` | Dispara _backup_ dos dados persistentes de uma _build_. Requer _Maintainer_. |
| `get_build_health` | Obtém o _status_ de saúde dos _containers_ (monitorados pelo autômato Doctor a cada minuto): _running_, _stopped_, _unhealthy_, _uptime_ e alertas. Requer _Maintainer_. |
| `get_sanitize_status` | Consulta se a sanitização periódica está ativa, data da última execução e próxima agendada. Requer _Maintainer_. |
| `start_sanitize` | Ativa sanitização periódica (mensal) — executa o serviço `sanitize` do _stack_ para limpeza e otimização. Requer _Maintainer_. |
| `stop_sanitize` | Desativa a sanitização periódica. Requer _Maintainer_. |

#### Equipe

| _Tool_ | Descrição |
|--------|-----------|
| `update_team` | Define a equipe completa de um projeto, **substituindo** todos os membros atuais. Papéis: `Maintainer` (Arquiteto da Solução — requer `@embrapa`) e `Developer` (Membro da Equipe). Deve conter ao menos um _Maintainer_. Requer _Maintainer_. |

#### Portas de Rede

| _Tool_ | Descrição |
|--------|-----------|
| `allocate_port` | Reserva uma porta no _cluster_ para uma _build_. Obrigatório antes de configurar URLs e _aliases_ em `save_build_config`. Requer _Maintainer_. |
| `release_ports` | Libera todas as portas alocadas para uma _build_, devolvendo-as ao _pool_ do _cluster_. Liberar portas de uma _build_ em execução pode torná-la inacessível. Requer _Maintainer_. |

#### Integrações e Qualidade

| _Tool_ | Descrição |
|--------|-----------|
| `get_code_quality` | Métricas do SonarQube para todas as apps de um projeto: manutenibilidade, confiabilidade, segurança, vulnerabilidades e _Quality Gate_. |
| `get_bug_tracking` | Dados do Sentry para todas as apps de um projeto: erros e exceções categorizados por severidade, frequência e versão. Inclui DSN de cada app. |
| `get_analytics` | Dados do Matomo para todas as apps de um projeto: acessos, sessões, páginas visitadas e comportamento dos usuários. Inclui ID e _token_ Matomo. |

#### Repositórios de Suporte

| _Tool_ | Descrição |
|--------|-----------|
| `get_support_repos` | Lista os repositórios de suporte ativos nos projetos do usuário: `web` (docs.embrapa.io), `api` (api.embrapa.io), `doc`, `art`, `bin` e `twa`. |
| `update_support_repos` | Ativa ou desativa repositórios de suporte. Ao ativar, o autômato Genesis cria o repo no GitLab e configura _deploy_ automático quando aplicável. Requer _Maintainer_. |

#### Catálogos da Plataforma

| _Tool_ | Descrição |
|--------|-----------|
| `list_boilerplates` | Lista todos os _boilerplates_ (modelos de aplicação) do catálogo. Cada item tem: `unix` (para uso em `create_app`), `label` e `description`. |
| `get_boilerplate_info` | Detalhes de um _boilerplate_: _stack_, linguagem/_framework_, referências, mantenedores e configurações do `.embrapa/settings.json`. |
| `get_boilerplate_repos` | README e LICENSE de um _boilerplate_ do catálogo. |
| `list_clusters` | Lista os _clusters_ (servidores remotos) disponíveis: domínio, capacidade, _aliases_ (subdomínios), faixa de portas e configurações SMTP. |
| `list_orchestrators` | Lista os orquestradores suportados (Docker Compose e Docker Swarm). |

#### Monitoramento Consolidado

| _Tool_ | Descrição |
|--------|-----------|
| `app_info` | Visão agregada de uma aplicação combinando três fontes: Matomo (_analytics_), Sentry (_bugs_) e SonarQube (qualidade de código). |
| `build_info` | Saúde de uma _build_ específica: _status_ do _deploy_, _cluster_, URLs, _aliases_, histórico de versões, _uptime_ e **CVEs/vulnerabilidades** detectadas pelo Trivy nos _containers_ (complementar ao SonarQube — cobre dependências de _runtime_, imagens base e bibliotecas do SO). |

#### _Deploy_ Externo (Releaser)

| _Tool_ | Descrição |
|--------|-----------|
| `generate_releaser_config` | Gera o arquivo `builds.json` para _deploy_ via [Releaser](/docs/releaser) em servidores externos. Coleta equipe, variáveis, Sentry DSN e Matomo ID da API ou de arquivos locais (`.env.io`/`.env`). Gera _secrets_ e _passwords_ randômicos para campos sensíveis. |

### _Prompts_ Guiados (8)

Os _prompts_ são fluxos interativos pré-definidos que guiam o usuário através de operações comuns.

| _Prompt_ | Descrição |
|----------|-----------|
| `overview_my_projects` | Gera uma visão geral organizada de todos os projetos do usuário, agrupados por _status_, com indicação de apps e pontos de atenção. |
| `create_new_project` | Guia passo-a-passo para criação de projeto: nome, _slug_, ecossistemas, verificação de disponibilidade e provisionamento. |
| `setup_new_app` | Guia para adicionar um app a um projeto existente: escolha de _boilerplate_, criação, configuração de _build_ (_cluster_, portas, variáveis, volumes) e primeiro _deploy_. |
| `deploy_app` | Guia o processo completo de _deploy_ via _git tag_: verifica _status_ da _build_, identifica a última _tag_, cria a nova _tag_ no formato correto do estágio (`alpha`, `beta`, `release`) e monitora o _deploy_. |
| `deploy_status` | Verifica o _status_ de uma _build_ específica e apresenta relatório consolidado: _status_ atual, _cluster_, URLs, _aliases_, alertas e próximo passo recomendado. |
| `troubleshoot_build` | Diagnóstico sistemático de problemas: verifica saúde, configuração, histórico de variáveis e sanitização. Identifica a causa provável e sugere correções. |
| `team_management` | Gestão interativa da equipe: adicionar, remover ou alterar papel de membros, com verificação de papel do usuário e confirmação antes de cada operação. |
| `project_health_report` | Relatório consolidado de saúde: qualidade de código (SonarQube), _bugs_ (Sentry), _analytics_ (Matomo), _status_ de cada _build_ e recomendações priorizadas. |

# MCP do Kanban do GitLab {#git}

O **MCP Server do Kanban** conecta assistentes de IA diretamente ao [GitLab](https://git.embrapa.io) da plataforma, permitindo gerenciar _issues_, _milestones_, _labels_ e relações entre tarefas via linguagem natural. O servidor opera sobre a API do GitLab e expõe as operações como _tools_ MCP, transformando o assistente de IA em um gerente de projeto integrado ao Kanban.

## Conectar

A URL de conexão do MCP Server é:

<div style="margin: 0 auto; text-align: center;">
  <a class="btn btn-info btn-lg" href="https://mcp.git.embrapa.io" target="_blank"
    onclick="event.preventDefault(); navigator.clipboard.writeText(this.href).then(() => { const o = this.textContent; this.textContent = '✔ Link copiado!'; setTimeout(() => this.textContent = o, 2000); });">
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

A configuração segue o mesmo padrão descrito na seção [Configuração em IDEs e CLIs](#config) do MCP do Dashboard. Basta substituir a URL por `https://mcp.git.embrapa.io`. Exemplos:

**Claude Desktop ou Web** — Configurações → Conectores → Adicionar conector personalizado → informar `https://mcp.git.embrapa.io`.

**Claude Code:**

> **Dica!** Ao configurar o conector no Claude Desktop/Web ele ficará disponível automaticamente no Claude Code.

```bash
claude mcp add --scope user --transport http git-kanban https://mcp.git.embrapa.io
```

**Gemini CLI:**

```bash
gemini mcp add -s user -t http git-kanban https://mcp.git.embrapa.io
```

**VS Code (GitHub Copilot)** — adicionar em `~/.vscode/mcp.json`:

```json
{
  "servers": {
    "git-kanban": {
      "type": "http",
      "url": "https://mcp.git.embrapa.io"
    }
  }
}
```

**Google Antigravity** - adicionar em `~/.gemini/antigravity/mcp_config.json`

```json
"git-kanban": {
  "serverUrl": "https://mcp.git.embrapa.io"
}
```

A partir destas configurações de referência, pode-se extrapolar para outros clientes com suporte à MCP com poucos ajustes.

> **Dica!** Ambos os MCPs podem ser utilizados simultaneamente. Com os dois conectados, é possível, por exemplo, consultar o _status_ de uma _build_ no Dashboard e criar uma _issue_ no Kanban em uma única conversa.

## Referência Técnica {#git-tools}

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
