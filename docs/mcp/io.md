---
layout: page
title: MCP do Dashboard
subtitle: Acesso a todas as funcionalidades do Painel de Controle da plataforma
share-title: "MCP do Dashboard | Embrapa I/O"
share-description: "MCP Server do Embrapa I/O que dá acesso ao Painel de Controle em linguagem natural: projetos, apps, builds, deploys, equipe, qualidade de código e relatórios da Sentinela, com login OAuth."
permalink: /docs/mcp/io/
---

{% include mcp-copy-url.html %}

O **MCP Server** do **Embrapa I/O** é um _middleware_ inteligente entre **clientes de IA** e a API da plataforma que implementa o [Model Context Protocol (MCP)](https://modelcontextprotocol.io), permitindo que assistentes de IA como Claude, Gemini, Copilot e Cursor interajam diretamente — criando projetos, configurando _builds_, monitorando _deploys_ e muito mais — tudo via linguagem natural.

## Conectar

A URL de conexão do MCP Server é:

<div style="margin: 0 auto; text-align: center;">
  <a class="btn btn-info btn-lg" href="https://mcp.embrapa.io" target="_blank"
    onclick="return copyMcpUrl(this);">
    mcp.embrapa.io
  </a>
</div>

A autenticação é feita via **OAuth 2.1 com PKCE**. Ao conectar, o fluxo de login abrirá automaticamente no _browser_ para autenticação por e-mail (OTP).

## Funcionalidades

O servidor expõe **48 _tools_** e **9 _prompts_ guiados** organizados nos seguintes domínios:

**Perfil do Usuário** — Consulta e atualização do perfil na plataforma, incluindo nome de exibição utilizado em todas as interfaces e listagens de equipe.

**Gestão de Projetos** — Criação de projetos (ativos digitais) com provisionamento automático de GitLab, Sentry, Matomo e SonarQube. Classificação por ecossistemas produtivos (agricultura, pecuária, florestal, aquicultura, indústria) ou corporativo. Gerenciamento de repositórios de suporte (documentação pública, Swagger, identidade visual, binários para lojas, TWA). Arquivamento de projetos com confirmação por PIN via e-mail.

**Aplicações e _Builds_** — Criação de aplicações a partir de _boilerplates_ pré-configurados do catálogo, com _fork_ automático no GitLab e 4 _branches_ (`main`, `alpha`, `beta`, `release`). Configuração completa de _builds_ (_cluster_, variáveis de ambiente, volumes, URLs públicas e _aliases_/subdomínios), com validação automática de aderência entre _codebase_ e configuração. Histórico de alterações de variáveis para auditoria. As variáveis secretas (`SECRET`, `PASSWORD` e as de texto com nome de segredo, como `*_TOKEN`) nunca chegam ao assistente: saem mascaradas e, ao salvar, as vazias são geradas no servidor (ou mantêm o valor atual). Remoção de _builds_ e de aplicações criadas por engano, com confirmação por PIN.

**Operações de _Build_** — Reiniciar instâncias, remover _deploy_ sem apagar configuração, solicitar _backup_ de dados persistentes, e ativar/desativar sanitização periódica (limpeza e otimização mensal). Revalidação de _builds_ que falharam na validação anterior, interrupção de validação presa e retorno ao rascunho de _build_ inválida nunca implantada. Publicação de versão pela plataforma: _merge_ da `main` no ramo do estágio e criação da próxima _tag_, sem _git_ local. Consulta de saúde dos _containers_ (_status_, _uptime_, alertas).

**Gestão de Equipe** — Definição da equipe completa de um projeto com dois papéis: Arquiteto da Solução (_Maintainer_ — gerencia configuração, _deploy_ em produção e _backup_) e Membro da Equipe (_Developer_ — codifica e faz _deploy_ em `alpha`/`beta`).

**Portas de Rede** — Alocação e liberação de portas nos _clusters_ da plataforma, necessárias para expor _builds_ via URLs e subdomínios.

**Integrações e Qualidade** — Acesso às métricas de qualidade de código via SonarQube (manutenibilidade, confiabilidade, segurança e _Quality Gate_), rastreamento de erros via Sentry (exceções em _runtime_ categorizadas por severidade e versão) e _analytics_ de acesso via Matomo (sessões, páginas visitadas e comportamento dos usuários).

**Catálogos da Plataforma** — Listagem de _boilerplates_ disponíveis (Node.js, Laravel, Vue.js, WordPress, entre outros) com detalhes de _stack_, documentação e licença. Listagem de _clusters_ disponíveis para _deploy_ (capacidade, _aliases_ e configurações SMTP) e orquestradores suportados.

**Monitoramento Consolidado** — Visão agregada por aplicação combinando Matomo, Sentry e SonarQube em uma única consulta. Saúde de _builds_ específicas (`project/app@stage`) em _clusters_ compartilhados: _status_ do _deploy_, _uptime_, histórico de versões deployadas e vulnerabilidades de segurança (CVEs) detectadas pelo Trivy nos _containers_ — complementar à análise estática do SonarQube, cobrindo dependências de _runtime_, imagens base e bibliotecas do SO. Lista também as _builds_ com [alerta de CVE crítica]({{ site.baseurl }}/docs/cve) ativo, com o repositório e a versão implantada, para que o agente leia o código e oriente a correção.

**_Deploy_ Externo (Releaser)** — Geração do arquivo `builds.json` para _deploy_ e atualização contínua em servidores fora da rede de _clusters_ da plataforma. Coleta automática de equipe, variáveis de ambiente, Sentry DSN e Matomo ID a partir da API ou de arquivos locais do _codebase_, com geração de _secrets_ e _passwords_ randômicos.

**Sentinela** — Leitura dos relatórios da [Sentinela]({{ site.baseurl }}/docs/sentinel) guardados na plataforma, inclusive as prévias e os de projetos sem `io-doc`, já estruturados (achados com identificador, severidade, evidência e ação; itens em aberto; _insights_). Busca nos achados de todos os relatórios dos projetos do usuário, para saber se um problema já apareceu e como foi votado, ou comparar padrões entre projetos. Registro em lote do voto útil/ruído, com veredito e motivo.

**_Prompts_ Guiados** — 9 fluxos interativos para operações comuns: visão geral dos projetos, criação de projeto passo-a-passo, criação de aplicação, _deploy_ via _git tag_, diagnóstico de problemas de _build_, gestão de equipe, _status_ de _deploy_, relatório de saúde do projeto e correção de [CVEs críticos]({{ site.baseurl }}/docs/cve).

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

```
Leia o último relatório da Sentinela do agrovision e confira cada achado no código.
Algum deles já tinha aparecido em relatórios anteriores?
```

```
Verifique os alertas de CVEs críticos em meus projetos e me oriente em cada um como agir.
```

## Configuração em IDEs e CLIs

A configuração segue o padrão unificado descrito em [Configuração em IDEs e CLIs]({{ site.baseurl }}/docs/mcp/#config). Basta usar a URL `https://mcp.embrapa.io`. Exemplo no **Claude Code**:

```bash
claude mcp add --scope user --transport http io https://mcp.embrapa.io
```

> **Dica!** Se adicionado pelo Claude Desktop, ao digitar `/mcp` no Claude Code o servidor aparecerá como **"claude.ai Embrapa I/O"** e poderá ser utilizado normalmente.

## Referência Técnica

### _Tools_ (48)

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
| `get_build_config` | Obtém a configuração de uma _build_ (`project/app@stage`): _cluster_, variáveis, volumes, URLs e _aliases_. O valor das variáveis secretas sai mascarado (`__IO_SECRET_KEPT__`). Requer _Maintainer_. |
| `save_build_config` | Salva a configuração completa de uma _build_. Após salvar, a plataforma dispara validação automática (não chamar `revalidate_build`). Antes de salvar, recomenda-se verificar se a _branch_ do estágio está atualizada com a `main`. O marcador das variáveis secretas volta ao valor real; `SECRET` e `PASSWORD` vazios mantêm o valor da _build_ ou são gerados no servidor (`PASSWORD` com 32 e `SECRET` com 256 caracteres), e a resposta diz só «gerado» ou «mantido». Requer _Maintainer_. |
| `get_variable_history` | Histórico de alterações das variáveis de ambiente de uma _build_ (cada alteração incrementa a versão). Requer vínculo Embrapa. |
| `request_build_removal` | Solicita remoção completa de uma _build_ já implantada (configuração + instância). Envia PIN por e-mail. Diferente de `undeploy_build` (que preserva a configuração). _Build_ nunca implantada não tem o que remover: use `reset_build` ou a remoção do app. Requer _Maintainer_. |
| `confirm_build_removal` | Confirma remoção permanente com o PIN recebido. |
| `request_app_removal` | Solicita a remoção de uma aplicação do projeto (por exemplo, criada por engano). Só é aceita se nenhuma _build_ do app foi implantada. Envia PIN por e-mail. Requer _Maintainer_. |
| `confirm_app_removal` | Confirma a remoção do app com o PIN: o repositório é arquivado no GitLab, as portas são liberadas e o app sai do projeto. |

#### Operações de _Build_

| _Tool_ | Descrição |
|--------|-----------|
| `revalidate_build` | Reenvia uma _build_ para revalidação. Funciona **apenas** para _builds_ com _status_ `INVALID` ou `INACTIVATED`. Não usar logo após `save_build_config` (validação já é automática). |
| `invalidate_build` | Interrompe a validação de uma _build_ presa em `VALIDATING`, passando-a a `INVALID`. |
| `reset_build` | Devolve ao rascunho (`DRAFT`) uma _build_ `INVALID` nunca implantada: apaga _cluster_, URLs, _aliases_ e domínios e mantém as variáveis. |
| `publish_version` | Publica uma versão: _merge_ da `main` no ramo do estágio (por _merge request_, sem _push_ forçado) e criação da próxima _tag_ do estágio pela plataforma. A _build_ precisa estar `VALID`. Em `release`, só o _Maintainer_. |
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
| `list_critical_cves` | Lista as _builds_ dos seus projetos com [alerta de CVE crítica]({{ site.baseurl }}/docs/cve) ativo (vulnerabilidade em exploração ativa), da mais urgente para a menos: nível e índice, pacote (sistema ou dependência da aplicação, com o arquivo de _lock_), versões instalada e corrigida, classificação da imagem, ação indicada, repositório no GitLab, versão implantada, servidor e link do _dashboard_. Sem alertas, devolve uma lista vazia. Somente leitura. |

#### _Deploy_ Externo (Releaser)

| _Tool_ | Descrição |
|--------|-----------|
| `generate_releaser_config` | Gera o arquivo `builds.json` para _deploy_ via [Releaser]({{ site.baseurl }}/docs/releaser) em servidores externos. Coleta equipe, variáveis, Sentry DSN e Matomo ID da API ou de arquivos locais (`.env.io`/`.env`). Gera _secrets_ e _passwords_ randômicos para campos sensíveis. |

#### Sentinela {#sentinel}

| _Tool_ | Descrição |
|--------|-----------|
| `list_sentinel_reports` | Lista os relatórios da Sentinela de um projeto, do mais recente para o mais antigo: carimbo (`stamp`), período, frequência, apps, achados novos e em aberto, severidades, custo e se é prévia. Requer ser membro do projeto. |
| `get_sentinel_report` | Lê um relatório: achados (com `fingerprint`, severidade, categoria, fonte, evidência, ação e link), itens em aberto, observações sem ação ("Para ciência"), _insights_ e avisos da coleta; ou o texto em Markdown. Nunca devolve o HTML. Requer ser membro do projeto. |
| `search_sentinel_findings` | Busca nos achados de todos os relatórios (inclusive prévias) dos projetos do usuário; gestores da plataforma buscam em todos. Um item por achado, com a primeira e a última vez em que saiu, em quantos relatórios e os votos. Filtros por texto, projeto, data, severidade, categoria e app. |
| `list_sentinel_votes` | Votos e vereditos já registrados nos achados de um projeto. O e-mail de quem votou só aparece para o Arquiteto da Solução. Requer ser membro do projeto. |
| `vote_sentinel_findings` | Registra em lote (até 50) o veredito da triagem de cada achado: `ok`, `wrong_action` e `partial` votam útil; `noise` vota ruído e **silencia o achado nos relatórios seguintes**; `stale` e `unverified` registram a triagem sem votar. Votar de novo substitui o voto anterior. Requer confirmação explícita e ser membro do projeto. |

### _Prompts_ Guiados (9)

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
| `fix_critical_cves` | Guia a correção dos alertas de CVE crítica: chama `list_critical_cves`, lê o repositório de cada _build_ na versão implantada e propõe a correção conforme a ação indicada (atualizar a dependência e gerar _tag_, fixar a versão maior antes de atualizar, subir a versão fixada ou reiniciar com atualização). **Nunca altera nada sem confirmação.** |
