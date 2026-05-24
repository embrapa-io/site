---
layout: page
title: MCP do Matomo
subtitle: Consulta de analytics de acesso das aplicações via linguagem natural
permalink: /docs/mcp/hit/
---

{% include mcp-copy-url.html %}

O **MCP do Matomo** conecta assistentes de IA aos dados de _analytics_ de acesso das aplicações da plataforma, hospedados no [Matomo](https://hit.embrapa.io) do **Embrapa I/O**. Diferentemente dos demais MCPs da plataforma (desenvolvidos internamente), este utiliza o **plugin oficial [MCP Server da Matomo](https://plugins.matomo.org/McpServer)**, mantido pela própria Matomo, permitindo perguntar em linguagem natural sobre tráfego, origens de visitas, páginas mais acessadas, campanhas e comportamento dos usuários — sem precisar navegar pelos relatórios.

O servidor atua como uma **camada de mediação**: aceita as requisições via MCP, encaminha à API de _Analytics_ do Matomo e retorna os dados de forma estruturada. Toda interpretação é feita pelo LLM — o Matomo não gera, analisa nem treina modelos com os dados. O acesso é **limitado aos mesmos sites e relatórios** que o usuário já enxerga no Matomo.

## Conectar

A URL de conexão do MCP Server é:

<div style="margin: 0 auto; text-align: center;">
  <a class="btn btn-info btn-lg" href="https://mcp.hit.embrapa.io" target="_blank"
    onclick="return copyMcpUrl(this);">
    mcp.hit.embrapa.io
  </a>
</div>

A autenticação é feita via **OAuth 2.0 com PKCE** (plugin `OAuth2` do Matomo). Ao conectar, o fluxo de _login_ abre automaticamente no _browser_ para autenticação com a **conta do Matomo** da plataforma (`hit.embrapa.io`), seguida da tela de autorização do cliente.

> **Atenção!** Por restrição do próprio MCP do Matomo, apenas contas com nível de acesso até **Escrita** (_View_ ou _Write_) podem conectar. **Superusuários não conseguem** utilizar o MCP — quem for superusuário precisa usar uma conta secundária de menor privilégio.

## Funcionalidades

O servidor é **orientado a leitura** (_read-oriented_) e expõe _tools_ em torno dos seguintes domínios de _analytics_:

**Sites** — Listagem dos sites (aplicações) que o usuário pode acessar no Matomo, com seus identificadores (`idSite`) para uso nas demais consultas.

**Relatórios** — Descoberta dos relatórios disponíveis e seus metadados, e obtenção dos **dados processados** de qualquer relatório (visitas, páginas, origens de tráfego, dispositivos, localização, etc.), com período e segmentação configuráveis.

**Metas (_Goals_)** — Consulta das metas de conversão configuradas e seus resultados.

**Segmentos (_Segments_)** — Consulta dos segmentos definidos para filtrar os dados de _analytics_.

**Dimensões (_Dimensions_)** — Consulta das dimensões customizadas disponíveis para análise.

> **Nota!** O acesso à **API crua** do Matomo (descoberta e execução genérica de métodos, incluindo operações de escrita) é um recurso **separado e desativado por padrão** — não está habilitado nesta instância. O escopo da conexão também é limitado a nível de leitura (_scope_ `matomo:read`).

## Exemplos de _Prompts_

Abaixo, exemplos do que pode ser solicitado em linguagem natural a um assistente de IA conectado a este MCP:

```
Quais foram as fontes de tráfego com mais visitas no site da minha aplicação
no último mês?
```

```
Quais páginas tiveram mais acessos ontem no site de ID 42?
```

```
Como está a tendência de acessos via dispositivos móveis neste mês
em relação ao anterior?
```

```
Liste os 10 países que mais geraram visitas à minha aplicação nos últimos 90 dias.
```

```
Qual campanha trouxe a maior taxa de conversão no último trimestre?
```

```
Gere um resumo executivo do desempenho de acessos da minha aplicação
nas últimas 4 semanas: visitas, visitantes únicos, páginas mais vistas
e principais origens.
```

## Configuração em IDEs e CLIs

A configuração segue o mesmo padrão unificado descrito em [Configuração em IDEs e CLIs]({{ site.baseurl }}/docs/mcp/#config). Basta usar a URL `https://mcp.hit.embrapa.io`. Exemplo no **Claude Code**:

```bash
claude mcp add --scope user --transport http matomo https://mcp.hit.embrapa.io
```

> **Dica!** Ao configurar o conector no Claude Desktop/Web, ele fica disponível automaticamente no Claude Code.

## Referência Técnica

A superfície de _tools_ do plugin oficial é **orientada a leitura** e pode evoluir entre versões. Os domínios cobertos no momento:

| Domínio | Descrição |
|---------|-----------|
| Sites | Listagem dos sites/aplicações acessíveis ao usuário (com `idSite`). |
| _Reports_ | Descoberta de relatórios e metadados, e obtenção dos dados processados (`matomo_report_processed`) — visitas, páginas, origens, dispositivos, localização, etc. |
| _Goals_ | Metas de conversão configuradas e seus resultados. |
| _Segments_ | Segmentos definidos para filtragem dos dados. |
| _Dimensions_ | Dimensões (inclusive customizadas) disponíveis para análise. |
| API crua _(desativada)_ | `matomo_api_list` / `matomo_api_get` e execução genérica de métodos — recurso opcional, **desabilitado por padrão** e não ativo nesta instância. |

> **Nota!** Para a referência completa e sempre atualizada das _tools_, parâmetros e comportamento, consulte a **documentação oficial da Matomo** (links abaixo).

## Documentação oficial (Matomo)

- [Plugin MCP Server — Matomo Marketplace](https://plugins.matomo.org/McpServer)
- [Como configurar o Matomo MCP Server (FAQ)](https://matomo.org/faq/how-to/how-to-configure-the-matomo-mcp-server/)
- [Integrar o MCP Server com o Claude (FAQ)](https://matomo.org/faq/how-to/integrate-the-mcp-server-with-claude-code/)
- [Configurar autenticação OAuth 2.0 para a API do Matomo](https://matomo.org/faq/how-to/set-up-oauth-2-0-authentication-for-the-matomo-api/)
