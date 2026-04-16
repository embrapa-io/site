---
layout: page
title: Spec-Driven Development
subtitle: Uso do BMAD Method com programação assistida por IA
---

<iframe width="730" height="410" src="https://www.youtube.com/embed/qa4MejqCo38" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## O que é _Spec-Driven Development_

_Spec-Driven Development_ (SDD) é uma abordagem de desenvolvimento de software onde **especificações detalhadas** — documentos de requisitos, arquitetura, _design_ de UX e épicos/histórias — são produzidas de forma estruturada **antes** de qualquer linha de código ser escrita. Diferente de metodologias tradicionais, no SDD essas especificações são criadas em colaboração com agentes de IA especializados, garantindo completude, consistência e profundidade técnica.

Na prática, o SDD inverte a dinâmica da _vibe coding_ (onde o desenvolvedor pede ao agente que crie código livremente): em vez de gerar código diretamente a partir de _prompts_ vagos, o desenvolvedor usa agentes especializados para construir uma **base sólida de especificações** que, só então, é consumida por agentes de codificação para implementação precisa e consistente.

O resultado é código de maior qualidade, com menos retrabalho e decisões de _design_ tomadas de forma consciente — não improvisadas pelo agente no momento da geração.

## BMAD Method {#bmad}

O [**BMAD Method**](https://github.com/bmad-code-org/BMAD-METHOD) (_Build More Architect Dreams_) é um _framework_ de desenvolvimento ágil orientado por IA, 100% gratuito e _open source_, que implementa o conceito de _Spec-Driven Development_ de forma prática e estruturada. É a **recomendação oficial** para uso com a plataforma **Embrapa I/O**.

### Por que o BMAD Method?

Ferramentas tradicionais de IA fazem o trabalho de pensar por você, produzindo resultados medianos. Os agentes do BMAD atuam como **colaboradores especialistas** que guiam um processo estruturado para extrair o melhor do pensamento humano em parceria com a IA:

- **Inteligência adaptativa** — Ajusta automaticamente a profundidade do planejamento com base na complexidade do projeto;
- **_Workflows_ estruturados** — Fundamentados em boas práticas ágeis: análise, planejamento, arquitetura e implementação;
- **Agentes especializados** — 12+ especialistas de domínio: PM, Arquiteto, _Developer_, UX, _Scrum Master_ e outros;
- **_Party Mode_** — Múltiplos agentes em uma mesma sessão, colaborando e debatendo;
- **Ciclo de vida completo** — Do _brainstorming_ ao _deployment_.

### Instalação

**Pré-requisito**: [Node.js](https://nodejs.org) v20+

O _framework_ é instalado no contexto da aplicação. Portanto, primeiro clone e acesse a sua app:

```bash
cd ~/projects

mkdir my-project && cd my-project

git clone git@git.embrapa.io:my-project/my-app.git

cd my-app
```

Em seguida:

```bash
npx bmad-method install
```

> **Importante!** Neste momento, siga os próximos passos e já instale a agente de conformidade **Alice** (veja detalhes na [próxima seção](#alice)).

No passo `Select official modules to install`, selecione "**BMad Method Agile-AI Driven-Development**".

Em seguida, no passo: `Would you like to install from a custom source (Git URL or local path)?`, selecione "**Yes**".

Por fim, em `Git URL or local path:` coloque a URL do repositório do agente: "**https://github.com/embrapa-io/alice**". Quando aparecer, selecione o módulo "**Embrapa I/O DevOps Compliance Module**".

Continue a instalação auto-guiada até finalizar. A _skill_ da agente será instalada junto com os demais agentes BMAD.

Abra seu agente de terminal ou IDE (Claude Code, Cursor, VS Code, Gemini CLI, etc) neste diretório.

> **Dica!** Não sabe o que fazer? Pergunte `bmad-help` — ele indica exatamente qual é o próximo passo e o que é opcional. Você pode fazer perguntas como `/bmad-help acabei de definir a arquitetura, o que faço agora?`.

### Módulos

O BMAD Method é extensível por meio de módulos oficiais:

| Módulo | Propósito |
|--------|-----------|
| **BMad Method (BMM)** | _Framework_ principal com 34+ _workflows_ |
| **BMad Builder (BMB)** | Criação de agentes e _workflows_ personalizados |
| **Test Architect (TEA)** | Estratégia de testes baseada em risco |
| **Game Dev Studio (BMGD)** | _Workflows_ para desenvolvimento de jogos (Unity, Unreal, Godot) |
| **Creative Intelligence Suite (CIS)** | Inovação, _brainstorming_ e _design thinking_ |

Saiba mais na [documentação oficial do BMAD Method](https://docs.bmad-method.org).

## Alice — Agente de Conformidade {#alice}

A **Alice** é um módulo do BMAD Method específico para o **Embrapa I/O**. Trata-se de uma agente especialista em conformidade com a plataforma: ela analisa _codebases_, identifica desvios, gera relatórios detalhados com _action items_ e implementa os ajustes necessários para que a aplicação esteja 100% aderente aos padrões da plataforma.

> **Dica!** Se seguiu os passos da seção anterior, a agente **Alice** já está disponível. Para invocar: `/alice`.

A Alice opera sobre as **4 Verdades Fundamentais** da plataforma:

| # | Verdade | Descrição |
|---|---------|-----------|
| 1 | **Sem `version`** | Campo `version` deve estar ausente do `docker-compose.yaml` |
| 2 | **_Network_ externa** | _Network_ `stack` deve ser `external: true` com nome `${IO_PROJECT}_${IO_APP}_${IO_STAGE}` |
| 3 | **Volumes externos** | Todos os volumes devem ser `external: true` |
| 4 | **Sem `container_name`** | Nenhum serviço pode ter o atributo `container_name` |

### _Workflows_ da Alice

A Alice possui 3 _workflows_ que devem ser executados em sequência:

```
[VC] Verify Compliance → [IA] Implement Adjustments → [CR] Code Review
         ↓                         ↓                         ↓
  Gera relatório          Implementa ajustes         Valida implementação
  com action items        do relatório               (NOVA SESSÃO!)
```

**[VC] Verificar Conformidade** — Analisa completamente o _codebase_ em 6 etapas (detecção de _stack_, validação do Docker Compose, variáveis de ambiente, `settings.json`, integrações Sentry/Matomo e geração do relatório). Produz o arquivo `embrapa-io-compliance.md` com _action items_ detalhados e exemplos de código adaptados à _stack_ do projeto.

**[IA] Implementar Ajustes** — Executa os _action items_ do relatório, cria os arquivos `.env`, `.env.io`, `bootstrap.sh`, `.embrapa/settings.json` e `LICENSE`. Configura integrações com Sentry e Matomo.

**[CR] _Code Review_** — Verifica se todas as implementações estão corretas e emite veredicto: **APPROVED** ou **REJECTED**. Deve ser executado em uma **nova sessão** para garantir verificação imparcial.

### Escopo da Alice

A Alice **pode modificar**:

- `docker-compose.yaml`, `Dockerfile`
- `.env.example`, `.env.io.example`, `.env`, `.env.io`
- `.embrapa/settings.json`
- `LICENSE`, `bootstrap.sh`, `README.md`
- Integrações Sentry e Matomo (configuração mínima)

A Alice **não modifica**:

- Código funcional da aplicação (exceto integrações Sentry/Matomo)
- _Endpoints_, rotas ou lógica de negócio
- Testes, CI/CD ou refatoração de código
- Docker Swarm (fora do escopo)

### Menu da Alice

| Opção | Descrição |
|-------|-----------|
| **[VC]** | Verificar Conformidade — analisa o _codebase_ e gera relatório |
| **[IA]** | Implementar Ajustes — executa os _action items_ do relatório |
| **[CR]** | _Code Review_ — verifica se a implementação está conforme |
| **[CH]** | Conversar com a Alice sobre qualquer assunto relacionado ao Embrapa I/O |
| **[MH]** | Reexibir o menu |
| **[DA]** | Dispensar a agente |

## Instalação e Uso {#install}

### 1. Instalar o BMAD Method

No diretório do seu projeto:

```bash
npx bmad-method install
```

Siga as instruções do instalador. Selecione a ferramenta de IA que utiliza (Claude Code, Cursor, etc.).

### 2. Instalar o módulo da Alice

Clone o repositório do módulo dentro da pasta `_bmad/`:

```bash
git clone https://github.com/embrapa-io/bmad.git _bmad/embrapa-io
```

### 3. Invocar a Alice

Na sua IDE de IA, utilize o _skill_ correspondente:

**Claude Code:**

```
/bmad-agent-embrapa-io-alice
```

**Outras IDEs** (Cursor, Windsurf, etc.): invoque o agente conforme a documentação do BMAD para a ferramenta.

### 4. Seguir o fluxo

1. A Alice se apresentará com um menu interativo;
2. Selecione **[VC]** para verificar a conformidade do _codebase_;
3. Revise o relatório gerado em `docs/embrapa-io-compliance.md`;
4. Selecione **[IA]** para implementar os ajustes;
5. **Abra uma nova sessão** e selecione **[CR]** para o _code review_ final.

### Configuração

O arquivo `_bmad/embrapa-io/config.yaml` permite personalizar:

```yaml
user_name: Seu Nome
communication_language: Brazilian Portuguese
document_output_language: Brazilian Portuguese
output_folder: "{project-root}/docs"
```

### Base de Conhecimento

O diretório `_bmad/embrapa-io/knowledge/` contém 8 arquivos de referência que a Alice utiliza durante as análises:

| Arquivo | Descrição |
|---------|-----------|
| `embrapa-io-fundamentals.md` | 4 Verdades Fundamentais da plataforma |
| `embrapa-io-validation.md` | 40 regras de validação organizadas por categoria |
| `embrapa-io-stacks.md` | Configurações específicas por _stack_ tecnológica |
| `embrapa-io-integrations.md` | Integrações Sentry, Matomo e _healthchecks_ |
| `embrapa-io-coding-standards.md` | Padrões de codificação: grafia PT-BR, variáveis sem _fallback_, LICENSE |
| `embrapa-io-workflows.md` | Padrões de adaptação por tipo de projeto |
| `embrapa-io-deployment.md` | Processos de _deployment_ e ambientes |
| `embrapa-io-integration-guide.md` | Guia detalhado de integrações |
