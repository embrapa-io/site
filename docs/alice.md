---
layout: page
title: Alice
subtitle: A agente de IA da plataforma, em plugins do Claude Code para cada tarefa.
---

A **Alice** é a agente de IA do **Embrapa I/O**. Ela conhece as regras da plataforma e trabalha dentro do seu código,
no seu assistente de IA, sempre pedindo a sua aprovação antes de mudar qualquer coisa fora da sua máquina. A agente é
uma só, mas cada tarefa vem num _plugin_ próprio, que você instala conforme o que faz no dia a dia:

| _Plugin_ | Comando | Para quem | O que faz |
| --- | --- | --- | --- |
| `compliance@embrapa-io` | `/compliance:alice` | toda equipe | verifica e adapta qualquer código às regras da plataforma, revisa a implementação e testa o _backup_ e o _restore_ ([detalhes](#compliance)) |
| `sentinel@embrapa-io` | `/sentinel:alice` | arquitetos de um projeto | trata os relatórios da [Sentinela]({{ site.baseurl }}/docs/sentinel): confere os achados, organiza o Kanban e guia as correções ([detalhes](#sentinel)) |
| `cve@embrapa-io` | `/cve:alice` | arquitetos de um projeto | trata os alertas de [CVEs críticos]({{ site.baseurl }}/docs/cve) das _builds_ ([detalhes](#cve)) |
| `boilerplate@embrapa-io` | `/boilerplate:alice` | quem mantém _boilerplates_ | transforma uma aplicação aderente num [_boilerplate_]({{ site.baseurl }}/docs/boilerplate) do catálogo ([detalhes](#boilerplate)) |

O código de todos os _plugins_ está em [github.com/embrapa-io/alice](https://github.com/embrapa-io/alice).

## Instalação {#install}

Os _plugins_ são para o [**Claude Code**](https://claude.com/claude-code). O repositório da Alice é um _marketplace_
de _plugins_, chamado `embrapa-io`: primeiro você adiciona o _marketplace_, uma vez só, e depois instala os _plugins_
que quiser. No terminal:

```bash
claude plugin marketplace add embrapa-io/alice

claude plugin install compliance@embrapa-io       # conformidade (toda equipe)
claude plugin install sentinel@embrapa-io         # relatórios da Sentinela
claude plugin install cve@embrapa-io              # alertas de CVE crítico
claude plugin install boilerplate@embrapa-io      # app → boilerplate do catálogo
```

Ou, de dentro de uma conversa no Claude Code:

```
/plugin marketplace add embrapa-io/alice
/plugin install compliance@embrapa-io
```

Depois de instalar, reinicie o Claude Code (ou abra uma conversa nova) para os comandos aparecerem.

### Atualização {#update}

A Alice muda com a plataforma. Para receber as versões novas:

```bash
claude plugin marketplace update embrapa-io
claude plugin update compliance@embrapa-io        # repita para cada plugin instalado
```

### Remoção e troca de nome {#uninstall}

```bash
claude plugin uninstall <plugin>@embrapa-io
```

> **Atenção!** Em 03/11/2026, o _plugin_ `critical-cves` passou a se chamar **`cve`**. Quem instalou o nome antigo:
> `claude plugin uninstall critical-cves@embrapa-io` e `claude plugin install cve@embrapa-io`. O comando agora é
> `/cve:alice`.

### Outros assistentes de IA {#other-assistants}

No Gemini CLI, OpenCode, GitHub Copilot, Codex e outros, a Alice de conformidade (`compliance`) é instalada como
módulo do **BMAD Method**, conforme o capítulo [Spec-Driven Development]({{ site.baseurl }}/docs/bmad#alice). Os
outros _plugins_ (`sentinel`, `cve` e `boilerplate`), por enquanto, existem só para o Claude Code.

## Como usar {#usage}

Abra o Claude Code na pasta certa (a da aplicação, a do projeto ou a do _boilerplate_, conforme o _plugin_) e chame o
comando. Digitar só `/alice` lista as Alices instaladas. A Alice se apresenta, mostra um menu e espera a sua escolha:

- qualquer código do menu vale **a qualquer momento** da conversa, e `MH` mostra o menu de novo;
- também dá para pedir direto, em português, junto com o comando, como em `/sentinel:alice trate o relatório desta semana`;
- `DA` dispensa a agente.

Regras que todos os _plugins_ seguem:

- nada sai da sua máquina sem o seu «pode» explícito: _push_, _tag_, _merge request_, _issue_, reinício de _build_,
  voto no Dashboard, mudança no Sentry ou no SonarQube;
- mudanças em lote passam antes por uma tabela de aprovação;
- dados de usuários e segredos não vão para _issues_, _commits_ nem relatórios.

Vários _plugins_ consultam a plataforma pelos [MCP Servers]({{ site.baseurl }}/docs/mcp). Conecte ao Claude Code os que
cada um pede (abaixo) antes de usar.

### Conformidade: `compliance` {#compliance}

Na pasta da aplicação, `/compliance:alice` (ou `/alice`):

| Código | O que faz |
| --- | --- |
| VC | Verificar a conformidade: analisa o código e gera o relatório do que falta |
| IA | Implementar os ajustes do relatório |
| CR | _Code review_: confere se a implementação ficou 100% conforme (de preferência numa conversa nova) |
| BR | Testar o _backup_ e o _restore_: faz o _backup_, apaga os volumes, restaura e compara (só no ambiente de desenvolvimento) |

É o caminho para [trazer uma aplicação existente para a plataforma]({{ site.baseurl }}/docs/app#alice) e para manter
qualquer aplicação aderente depois de mudanças grandes.

### Relatórios da Sentinela: `sentinel` {#sentinel}

Na pasta do projeto (a que reúne os clones das apps) ou no clone de uma app, `/sentinel:alice`. Ela busca os
[relatórios da Sentinela]({{ site.baseurl }}/docs/sentinel#report), confere cada achado contra o código, registra o que
procede como _issues_ no Kanban do grupo no GitLab (com _milestones_, responsáveis e prazos pela capacidade da equipe),
guia a correção _issue_ por _issue_ e devolve à Sentinela o que o relatório errou, pelos votos
[útil ou ruído]({{ site.baseurl }}/docs/sentinel#feedback).

| Código | O que faz |
| --- | --- |
| TR | Tratar o relatório inteiro: revisar, organizar o Kanban, registrar votos e lições |
| RS | Revisar o relatório: buscar e conferir cada achado contra o código |
| KB | Organizar o Kanban: plano com _milestones_, responsáveis e prazos |
| SC | Sincronizar as colunas do Kanban com as _tags_ `alpha`, `beta` e `release` |
| CI | Corrigir a próxima _issue_ (_worktree_, teste, MR) |
| SQ | Pôr o Sentry e o SonarQube coerentes com o código |
| BP | Levar ao _boilerplate_ a correção que nasceu nele |
| VT | Registrar útil ou ruído no Dashboard |
| IS | Redigir uma _issue_ para a Sentinela sobre o que o relatório errou |

Pede o [MCP do Dashboard]({{ site.baseurl }}/docs/mcp/io/) e o [MCP do GitLab]({{ site.baseurl }}/docs/mcp/git/);
recomenda a CLI `glab` autenticada em `git.embrapa.io` (para _milestones_ de grupo e o _board_); usa, se houver, os MCPs
do [Sentry]({{ site.baseurl }}/docs/mcp/bug/) e do [SonarQube]({{ site.baseurl }}/docs/mcp/code/).

### CVEs críticos: `cve` {#cve}

Na pasta da app (ou numa pasta com os clones das apps do projeto), `/cve:alice`. Ela lista as _builds_ com
[alerta de CVE crítico]({{ site.baseurl }}/docs/cve), confere cada CVE no código da versão implantada e executa, _build_
a _build_ e sempre com confirmação, a [ação indicada pelo alerta]({{ site.baseurl }}/docs/cve#actions).

| Código | O que faz |
| --- | --- |
| FC | Fluxo completo: do panorama ao fechamento, _build_ a _build_ |
| LC | Listar as _builds_ com CVE crítico |
| VC | Verificar um CVE no código da versão implantada |
| VI | Verificar se a imagem nova do fornecedor já corrige |
| AT | Atualizar a dependência ou a imagem (_commit_ e _tag_ de _deploy_) |
| RU | Reiniciar com atualização de imagens |
| RL | Preparar os comandos para o servidor do [Releaser]({{ site.baseurl }}/docs/releaser) |
| BD | Sem correção: restringir o acesso, ou fazer _backup_ e desativar o estágio |
| CF | Conferir se o alerta fechou e fazer o relato final |

Antes de reiniciar, a Alice confere se a imagem nova do fornecedor já traz a versão corrigida; antes de desativar uma
_build_ com dados, faz o _backup_ e espera a confirmação; nunca dá salto de versão maior em banco de dados sem plano de
migração. Pede o [MCP do Dashboard]({{ site.baseurl }}/docs/mcp/io/), o papel de arquiteto no projeto e Docker na
máquina.

### _Boilerplates_: `boilerplate` {#boilerplate}

Na pasta da aplicação já aderente, num clone do repositório `io/boilerplate/<nome>`, `/boilerplate:alice`:

| Código | O que faz |
| --- | --- |
| GB | Gerar o _boilerplate_ (fluxo completo) |
| VS | Auditar versões e propor _upgrades_ |
| GL | Gravar ou revisar o `.gitlab-io.yml` |
| SQ | SonarQube antes do catálogo |
| CT | Publicar no catálogo (`metadata/boilerplates.json`) |

O _plugin_ `boilerplate` não substitui o `compliance`: se a aplicação ainda não estiver aderente, rode antes a
conformidade. O passo a passo completo está em [_Boilerplate_]({{ site.baseurl }}/docs/boilerplate#skill).

## Perguntas frequentes {#faq}

**Preciso instalar todos os _plugins_?**
Não. Quem só desenvolve aplicações precisa do `compliance`. Arquitetos de projeto ganham com `sentinel` e `cve`. O
`boilerplate` é para quem mantém modelos do catálogo.

**A Alice manda meu código para algum lugar?**
Ela roda no seu assistente de IA, com a conta e o contrato que você usa nele. Os _plugins_ só trazem as instruções e os
scripts da plataforma; o que o assistente faz com o código segue as regras dele. Vale a mesma regra de sempre: dado
sigiloso ou pessoal só em ferramenta e conta autorizadas para isso.

**O comando não aparece depois de instalar.**
Reinicie o Claude Code ou abra uma conversa nova. Confira com `claude plugin list` se o _plugin_ está instalado e
habilitado.

**Onde reporto um problema ou sugiro uma melhoria?**
Nas _issues_ de [github.com/embrapa-io/alice](https://github.com/embrapa-io/alice/issues).
