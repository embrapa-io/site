---
layout: page
title: MCP do SEG
subtitle: Consulta dos dados corporativos da Embrapa (SEG, CatSoft, empregados) via linguagem natural
permalink: /docs/mcp/seg/
---

{% include mcp-copy-url.html %}

O **MCP Server do SEG**, desenvolvido pela [Embrapa Gado de Corte](https://embrapa.br/gado-de-corte/), conecta assistentes de IA aos dados corporativos da Embrapa — especificamente do **[Sistema Embrapa de Gestão (SEG)](https://www.embrapa.br/fundamentos-estrutura-e-funcionamento-do-sistema-embrapa-de-gestao-seg)**, do **[catálogo de softwares (CatSoft)](https://catsoft.nuvem.ti.embrapa.br)**, do **portal [embrapa.br](https://embrapa.br)** (palavras-chave, ecossistemas e notícias) e da base de **empregados** da Empresa. Os dados são sincronizados incrementalmente a partir das [APIs corporativas](https://apidocportal.nuvem.ti.embrapa.br/) (e enriquecidos via _scraping_ do portal). Pesquisadores e gestores consultam projetos, planos de ação, atividades, perfis de pessoas, softwares e relações entre essas entidades diretamente pelo [Claude](https://claude.ai), [Gemini](https://gemini.google.com), [GitHub Copilot](https://github.com/features/copilot) ou qualquer cliente compatível.

Originalmente desenvolvido no escopo do **[INCT — Gado de Corte](https://www.embrapa.br/busca-de-noticias/-/noticia/100169755/cnpq-aprova-rede-de-pesquisa-inct-gado-de-corte-que-reune-embrapa-e-parceiros)** como entrega da atividade de infraestrutura moderna para armazenamento e processamento eficiente de dados agroambientais, sociais e econômicos, foi migrado para o ecossistema **Embrapa I/O** em maio de 2026 dada sua utilidade transversal para toda a Embrapa. A arquitetura é 100% _open-source_ (MIT/Apache 2.0/BSD-3): [PostgreSQL 18](https://www.postgresql.org/) como armazenamento, [PostGraphile V5](https://postgraphile.org/) como camada GraphQL _read-only_, [BullMQ](https://docs.bullmq.io/) sobre [Valkey](https://valkey.io/) para o _pipeline_ de sincronização e o [SDK oficial do MCP](https://github.com/modelcontextprotocol/typescript-sdk) como camada de protocolo.

## Conectar

A URL de conexão do MCP Server é:

<div style="margin: 0 auto; text-align: center;">
  <a class="btn btn-info btn-lg" href="https://seg.mcp.embrapa.io" target="_blank"
    onclick="return copyMcpUrl(this);">
    seg.mcp.embrapa.io
  </a>
</div>

A autenticação é feita via **OAuth 2.1 com PKCE** usando as **credenciais corporativas da Embrapa** (validação contra o `autenticacaoapi`). Ao conectar, o fluxo de _login_ abrirá automaticamente no _browser_.

## Volume de Dados

A base totaliza **~207 mil registros**:

| Domínio | Registros | Fonte |
|---------|-----------|-------|
| Atividades de pesquisa | ~123K | API SEG |
| Planos de ação | ~29K | API SEG |
| Empregados Embrapa (ativos e inativos) | ~21K | API Empregado |
| Junctions M2M | ~19K | APIs diversas + portal |
| Projetos de pesquisa | ~7,7K | API SEG |
| Pessoas físicas externas | ~5,2K | API SEG |
| Softwares (CatSoft) | ~1,2K | API CatSoft |
| Entidades parceiras | ~1,2K | API Pessoa Jurídica |
| Unidades / Arranjos / Portfólios | ~200 | API SEG |

A sincronização respeita as dependências de FK em **4 _waves_** sequenciais (unidades/arranjos/portfólios → empregados/entidades/pessoas → projetos/softwares → junctions M2M). Projetos são sincronizados de forma incremental a cada 12 horas; empregados e demais entidades em ciclos diários.

## Funcionalidades

O servidor expõe **8 _tools_** organizadas em duas estratégias complementares:

**_Tools_ compostas** — Operações de alta granularidade que resolvem o caso de uso completo em uma única chamada, eliminando o _pattern_ N+1 ao retornar dados aninhados (planos+atividades de um projeto, ou todos os 4 níveis de participação de um empregado).

**_Tools_ de busca _full-text_** — Pesquisa textual com _ranking_ por relevância via _tsvector_ nativo do PostgreSQL, com dicionários `portuguese` (com _stemming_) para títulos/descrições e `simple` para nomes e siglas. Suporta filtros por unidade, _status_ e período. _Fallback_ automático para `includesInsensitive` quando não há _matches_ via _full-text_.

**Salvaguardas (_Query Guard_)** — _Cap_ silencioso de limite por _tier_ (campos leves: 200; campos pesados: 10; _junction tables_: 1.000), `totalCount` real do banco em todas as consultas, _default_ `ativo=true` em coleções não-controle, tradução automática de `snake_case` → `camelCase` e detecção de UUIDs vs textos para escolher o operador correto. As salvaguardas protegem a janela de contexto da LLM e impedem consultas custosas acidentais.

**_Ranking_ M2M agregado** — Funções SQL pré-computadas para ordenar entidades por quantidade de relações (projetos com mais notícias, _softwares_ com mais responsáveis), resolvendo em ~10ms o que antes exigia múltiplas páginas + contagem manual.

## Exemplos de _Prompts_

Abaixo, exemplos do que pode ser solicitado em linguagem natural a um assistente de IA conectado a este MCP:

```
Quais projetos do CNPGC sobre pastagem estão em execução?
Mostre o responsável e a quantidade de planos e atividades de cada.
```

```
Detalhe o projeto de código 0406030010000: equipe, planos de ação, atividades
e palavras-chave associadas.
```

```
Quem é o líder do projeto Balde Cheio? Qual a unidade? Tem quantas notícias
relacionadas no portal embrapa.br?
```

```
Busque empregados do setor SPAT da CNPGC que sejam supervisores de TI.
```

```
Monte o perfil completo do empregado Camilo Carromeu: projetos que lidera,
planos como responsável, atividades e softwares.
```

```
Quais os 10 softwares do CatSoft com mais responsáveis cadastrados?
```

```
Liste os projetos com mais notícias publicadas no portal embrapa.br
nos últimos 5 anos.
```

```
Quantos empregados foram contratados após janeiro de 2025? Mostre por unidade.
```

```
Quais entidades parceiras participam de mais projetos em execução?
Top 10 por quantidade de projetos.
```

```
Faça um relatório consolidado da Rede de Inteligência Estratégica do INCT
Gado de Corte: projetos, equipe, planos vigentes e atividades em andamento.
```

## Configuração em IDEs e CLIs

A configuração segue o padrão unificado descrito em [Configuração em IDEs e CLIs]({{ site.baseurl }}/docs/mcp/#config). Basta usar a URL `https://seg.mcp.embrapa.io`. Exemplo no **Claude Code**:

```bash
claude mcp add --scope user --transport http seg https://seg.mcp.embrapa.io
```

> **Dica!** Ao configurar o conector no Claude Desktop/Web ele ficará disponível automaticamente no Claude Code.

## Referência Técnica

### _Tools_ (8)

#### _Bootstrap_

| _Tool_ | Descrição |
|--------|-----------|
| `system_prompt` | Retorna o esquema autoritativo do banco (24 tabelas, relações), regras de consulta, exemplos de filtros, _anti-patterns_ e _workflows_ recomendados. Deve ser a **primeira chamada** em qualquer sessão — atua como contrato para as demais _tools_. Aproximadamente 3K _tokens_. |

#### Consulta Genérica

| _Tool_ | Descrição |
|--------|-----------|
| `consultar` | _Escape hatch_ para consultas customizadas em qualquer coleção (projetos, empregados, softwares, unidades, _junctions_, etc.). Parâmetros: `collection`, `filter` (com suporte a `equalTo`, `includesInsensitive`, `isNull`, `greaterThan`, etc.), `fields`, `sort` e paginação. Aplica salvaguardas automáticas (_default_ `ativo=true`, _cap_ de limites por _tier_, detecção de UUID vs texto, _snake_case_ → _camelCase_). |

#### Projetos

| _Tool_ | Descrição |
|--------|-----------|
| `buscar_projetos` | Busca _full-text_ com _ranking_ por relevância em `título`, `código`, `sigla` e `resumo`. Filtros: `status` (substrings como `execu`, `conclu`, `encerr`), `unidade_sigla` (única ou múltipla), `incluir_contagens` (planos + atividades), `incluir_contagens_m2m` (notícias + arranjos + portfólios + palavras-chave + ecossistemas) e `incluir_resumo`. |
| `detalhar_projeto` | Detalhamento completo de UM projeto em uma única _query_ GraphQL: equipe (opcional), planos vinculados (opcional), atividades (opcional) e M2M achatados (`palavras_chave: ["a","b","c"]` em vez de _junction nesting_). Elimina o _pattern_ de 4+ chamadas paginadas. |

#### Empregados

| _Tool_ | Descrição |
|--------|-----------|
| `buscar_empregados` | Busca _full-text_ em ~21K empregados por `nome`, `email`, `cargo` e `setor`. Filtros adicionais: `unidade_sigla`, `setor` (ex: `NTI`, `SPAT`, `Chefia`), `data_contratacao_apos` (formato `YYYY-MM-DD`). Retorna `matricula`, `nome`, `email`, `cargo`, `setor`, `comissao`, `supervisor_cti` e `unidade`. |
| `perfil_empregado` | Perfil completo de UM empregado em uma única _query_ com os **4 níveis de participação**: projetos que lidera, planos de ação que coordena, atividades como responsável e softwares (CatSoft) em que figura como responsável. Aceita matrícula (VARCHAR) ou ID. |

#### Softwares (CatSoft)

| _Tool_ | Descrição |
|--------|-----------|
| `buscar_softwares` | Busca _full-text_ no catálogo CatSoft (~1,2K softwares) por `nome`, `sigla` e `descrição`. Filtros: `unidade_sigla`. Retorna `nome`, `sigla`, `url_sistema`, `unidade_gestora`, `unidade_tecnica`, `areas_informacao[]` e `responsaveis[]` (M2M achatados). |

#### _Ranking_ Agregado

| _Tool_ | Descrição |
|--------|-----------|
| `ranking_m2m` | _Ranking_ de entidades por quantidade de relações M2M, via funções SQL pré-computadas (GROUP BY + COUNT _server-side_). Pares válidos: `projetos` × (`noticias`, `arranjos`, `portfolios`, `palavras_chave`, `ecossistemas`) e `softwares` × (`areas_informacao`, `responsaveis`). Resolve em ~10ms o que antes exigia múltiplas páginas + contagem _client-side_. |

### Paginação

Todas as _tools_ retornam metadados de paginação:

```json
"_meta": {
  "total": 7744,
  "limit": 50,
  "offset": 0,
  "hasMore": true
}
```

Limites por _tier_: campos leves até 200, campos pesados (`resumo`, `descricao`, `minicurriculo`, `resumo_publico`) até 10, _junction tables_ até 1.000. O servidor aplica _cap_ silencioso quando o limite solicitado excede o máximo permitido.
