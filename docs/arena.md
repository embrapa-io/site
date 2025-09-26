---
layout: page
title: Rinha de Bot
subtitle: Testes cegos para avaliação de agentes de IA
---

<!-- <iframe width="730" height="410" src="https://www.youtube.com/embed/wnN1tiGVcu4" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe> -->

A ferramenta **Rinha de Bot** do **Embrapa I/O** está disponível em:

<div style="margin: 0 auto; text-align: center;">
    <a class="btn btn-info btn-lg" href="https://hub.arena.embrapa.io" target="_blank">hub.arena.embrapa.io</a>
</div>

Trata-se de uma aplicação web para execução de testes cegos em agentes de IA (comumente chamados de _chatbots_). Por meio dela, é possível criar "**torneios**" entre dois agentes, que estarão conectados via _Webhook_ ou por uma API _OpenAI-Compatible_.

Para criar um torneio, [acesse o console da ferramenta](https://hub.arena.embrapa.io) e vá em "**Criar Torneio**". Preencha o "**Título do Torneio**" e a "**Mensagem de Boas-Vindas**", que são dados que estarão sempre visíveis aos avaliadores.

Em seguida, é preciso definir pelo menos um "**Domínio de Conhecimento**", que são as áreas em que o agente foi treinado e portanto em que será testado. Por exemplo, no caso se trate de um agente de IA para a pecuária, domínios possíveis seriam: Gado de Corte, ILPF, IPF e ILP. Caso se trate de um agente para atender a processos gerenciais/institucionais, domínios possíveis seriam: RH, Orçamento, Patrimônio e Financeiro.

![Criar Torneio - Informações Básicas]({{ site.baseurl }}/assets/img/arena/20250926095628.png)

Após inserir as informações básicas do torneio, o usuário deverá configurar os agentes A e B. No primeiro campo, "**Nome/Label do Agente**", deverá ser definido um identificador que permita posteriormente reconhecer qual o agente de teste e qual o de controle.

Para cada agente, o usuário deverá então escolher o "**Tipo de Integração**", que poderá ser de duas formas:

### Via _Webhook_

Esta é a melhor forma de integrar agentes que tenham sido desenvolvidos no [N8N](https://n8n.io). Basta integrar ao fluxo do seu agente um nó do tipo _webhook_, conforme a imagem abaixo:

![Integração com fluxo no N8N.]({{ site.baseurl }}/assets/img/arena/20250926161421.png)

Considere aos itens referenciados acima:

1. Na configuração do agente, você deverá inserir no campo "**URL do Webhook**" a URL gerada pelo N8N;
2. O "**HTTP Method**" no nó Webhook do N8N deverá ser `POST`;
3. Para os testes, será enviado ao N8N um JSON no formato abaixo. Repare que o prompt a ser passado para a LLM no N8N está em `$json.body.prompt` e existe um atributo `$json.body.session` que pode ser utilizado junto aos nós de memória.
4. Por fim, deverá ser utilizado um nó "**Respond to Webhook**" para capturar a saída, com a **opção de responder no formato texto**.

```json
{
    "prompt": "<SYSTEM>\nVocê é um especialista em pecuária de corte.\n</SYSTEM>\n\n<USER>\nQual a melhor cultivar para criação de bezerros no Pantanal?\n</USER>",
    "timestamp": "2025-09-25T21:39:27.222Z",
    "source": "arena.embrapa.io",
    "session": "68d5b68f0590ec7e08f10024"
}
```

No JSON acima, o atributo prompt está separado em duas _tags_: `<SYSTEM></SYSTEM>` e `<USER></USER>`. Isto ocorre quando é configurado para o agente um "**System Prompt**", conforme imagem abaixo:

![Agente A configurado com integração via Webhook.]({{ site.baseurl }}/assets/img/arena/20250926164622.png)

Por fim, é possível configurar um _token_ de autenticação, que será passado pelo _header_ (`Authorization: Bearer [token]`).

### Via API _OpenAI Compatible_

Esta opção é ideal para conectar provedores em nuvem de terceiros ou _LLM Runtimes_ como o [Ollama](https://ollama.com).
