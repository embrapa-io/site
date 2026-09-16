---
layout: page
title: WebMCP
subtitle: Ferramentas desta documentação para agentes de IA no navegador
---

O [WebMCP](https://github.com/webmachinelearning/webmcp) (_Web Model Context Protocol_) é uma proposta de padrão _web_, incubada no W3C pelo Google e pela Microsoft, que permite a uma página registrar **ferramentas** (_tools_) que agentes de IA rodando no navegador podem chamar diretamente, em vez de ler a tela ou clicar por conta própria. É a versão "dentro do navegador" do [Model Context Protocol]({{ site.baseurl }}/docs/mcp): as ferramentas ficam no JavaScript da própria página e executam com a sessão do usuário.

Este site registra, em todas as páginas, um conjunto de ferramentas **somente leitura** sobre a documentação e os catálogos públicos da plataforma:

| Ferramenta | O que faz |
|---|---|
| `search_docs` | Busca por palavras-chave nos capítulos da documentação e devolve os mais relevantes, com trecho. |
| `get_doc` | Devolve o texto completo de um capítulo, pelo _slug_ da URL (`releaser`, `delivery`, `deploy`…). |
| `list_docs` | Lista todos os capítulos com título, subtítulo e URL. |
| `get_current_page` | Devolve o texto da página aberta no momento. |
| `list_boilerplates` | Lista os [_boilerplates_]({{ site.baseurl }}/resources/boilerplates), com filtro textual opcional. |
| `list_clusters` | Lista os [_clusters_]({{ site.baseurl }}/resources/clusters) por estágio, com recursos disponíveis (sem dados de rede). |
| `list_gpu_servers` | Lista os [GPU Servers]({{ site.baseurl }}/resources/gpus) acessíveis pelos _clusters_. |
| `open_page` | Navega para outra página deste site. |

> **Atenção!** O WebMCP ainda é experimental. A especificação é um rascunho de grupo comunitário do W3C, a API mudou de `navigator.modelContext` para `document.modelContext` em julho de 2026 e o Chrome a oferece por _origin trial_ (versões 149 a 156). As ferramentas deste site são um aprimoramento progressivo: em navegadores sem suporte, nada muda.

## Como usar {#how}

As ferramentas só existem enquanto uma página deste site está aberta no navegador do agente. Quem as consome:

- **ChatGPT (aplicativo de desktop)**: o navegador embutido do ChatGPT reconhece as ferramentas ("_site tools_") com os modelos GPT-5.6 Sol ou Terra. Basta abrir esta documentação no navegador do ChatGPT e pedir, por exemplo, "procure na documentação como configurar o Releaser". A opção **Enable site tools** fica em Settings › Browser › Permissions.
- **Gemini no Chrome**: anunciado pelo Google como o primeiro agente a consumir WebMCP; depende da disponibilidade do recurso na sua conta e região.
- **Chrome com a extensão _Model Context Tool Inspector_** (oficial, da equipe do Chrome): mostra as ferramentas registradas na aba **WebMCP** do painel _Application_ do DevTools, permite chamá-las manualmente e simular um agente.
- **Claude, Cursor e outros clientes MCP de desktop**: por meio de uma extensão-ponte (_bridge_) que expõe as ferramentas da aba aberta como um servidor MCP local. Veja as [instruções de teste](#test).
- **Brave (Leo)** e **Edge**: suporte experimental, atrás de _flags_.

## Testando localmente {#test}

No Chrome ou no Brave sem _origin trial_, ative a _flag_ `chrome://flags/#enable-webmcp-testing` (`brave://flags/#enable-webmcp-testing`), reinicie o navegador e abra qualquer página do site. No console do DevTools, `window.__embrapaIoWebMCP.tools` lista as ferramentas registradas e `window.__embrapaIoWebMCP.api` informa qual nome da API foi usado.

Para chamar uma ferramenta pelo console:

```js
const t = window.__embrapaIoWebMCP.tools.find(x => x.name === 'search_docs');
await t.execute({ query: 'deploy em produção', limit: 3 });
```

## Para o site em produção {#production}

Em `www.embrapa.io`, enquanto durar o _origin trial_ do Chrome, o suporte nativo exige um _token_ registrado para a origem em [developer.chrome.com/origintrials](https://developer.chrome.com/origintrials/#/register_trial/4163014905550602241), informado em `webmcp.origin_trial_token` no `_config.yml`. Sem o _token_, as ferramentas continuam disponíveis para navegadores com a _flag_ ativada, para o ChatGPT de desktop e para as extensões-ponte.
