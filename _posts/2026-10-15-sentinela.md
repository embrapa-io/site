---
layout: post
title: "Sentinela: agente de IA para busca de insights nos projetos"
subtitle: Relatórios diários ou semanais, gerados por IA, com o que mudou nas apps do seu projeto destacando o que merece atenção.
tags: [ ia, devops, logs, documentacao ]
---

A plataforma **Embrapa I/O** monitora cada aplicação por meio de várias ferramentas integradas: _logs_ no [**Grafana Loki**](https://log.embrapa.io), erros no [**Sentry**](https://bug.embrapa.io), vulnerabilidades das imagens no [**Trivy**](https://trivy.dev), qualidade do código no [**SonarQube**](https://code.embrapa.io), atividade do repositório no [**GitLab**](https://git.embrapa.io) e acessos no [**Matomo**](https://hit.embrapa.io). Cada uma mostra os seus números no _dashboard_, e são muitos números. Quem tem tempo de abrir seis ferramentas por semana, para cada app, e cruzar o que elas dizem?

A partir de hoje esse trabalho é da **Sentinela**, o agente de _insights_ por projeto da plataforma. Ela já aparece no _dashboard_ de todos os projetos e é ativada pelo arquiteto, projeto a projeto, em menos de um minuto.

> **Atualização (28/10/2026):** veja a Sentinela em ação, da ativação ao relatório completo, na nova vídeo-aula:

<iframe width="730" height="410" src="https://www.youtube.com/embed/YjcE0gCOI4g" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## O que ela faz {#what}

A cada dia ou semana, conforme a configuração, a Sentinela lê o que as ferramentas registraram sobre as apps do projeto no período, pede a um modelo de inteligência artificial uma leitura qualitativa e envia à equipe, por e-mail, um relatório em três partes:

- **Indicadores e panorama**: quantas novidades surgiram e com que severidade, quantos achados de relatórios anteriores continuam em aberto, e gráficos de visitas e de vulnerabilidades por app.
- **_Insights_ e achados por app**: o que o modelo concluiu sobre cada app, em poucas linhas, seguido dos achados que sustentam a conclusão. Há achados de segurança, ataque, dependências, _bug_, estabilidade, integração, desempenho, qualidade, distribuição e uso.
- **Resumo do período por app**: as notas do SonarQube, o estado do _deploy_, a atividade no repositório, os _logs_, os erros, as CVEs e o uso, lado a lado, para consulta rápida.

![Indicadores do relatório semanal]({{ site.baseurl }}/assets/img/sentinel/09.png)

Cada achado chega com a severidade, a evidência (o trecho de _log_, o erro, a CVE), uma ação sugerida e o _link_ para abrir na ferramenta de origem. Nada de "verifique a segurança da aplicação": a Sentinela diz qual imagem tem a CVE, qual serviço reiniciou por falta de memória e qual _endpoint_ ficou lento depois de qual _tag_.

![Insights e achados de uma app no relatório]({{ site.baseurl }}/assets/img/sentinel/11.png)

A ideia não é substituir o _dashboard_, que continua mostrando os números de cada ferramenta. A Sentinela cruza esses números e conta o que eles significam: uma varredura de _scanners_ que está recebendo resposta `200` em `/.env`, um erro que se repete no Sentry desde o último _deploy_, um estágio parado há semanas, uma vulnerabilidade com correção publicada que ninguém aplicou.

Uma cópia de cada relatório fica no histórico do projeto, no _dashboard_, e outra, em Markdown, no repositório `io-doc`, para que o conhecimento acumulado não se perca na caixa de entrada.

## Onde roda o modelo {#provider}

A escolha do modelo é do arquiteto do projeto, e há dois caminhos:

- **GPU Server da Embrapa**: modelo aberto rodando na infraestrutura de TI da Empresa. Nenhum dado sai da rede corporativa, não há chave nem custo. É a opção recomendada e serve a qualquer projeto.
- **Provedor externo**: Google, Anthropic, OpenAI ou qualquer API compatível com a da OpenAI, com a chave do próprio arquiteto ou do projeto (se tiver um _budget_, p.e., no Google Vertex AI) - no caso de projetos com dados públicos ou não sensíveis, ou com provedor sob contrato corporativo.

Em qualquer dos dois, antes de enviar o que quer que seja, a plataforma remove segredos (senhas, chaves, _tokens_) e pseudonimiza identificadores pessoais (endereços IP e e-mails). O modelo nunca executa nada: só lê e relata. E a Sentinela **não avalia pessoas**: nenhum achado nomeia autor de _commit_ nem mede produtividade individual. O relatório fala das apps, não de quem as desenvolve.

## Como ativar {#enable}

No card do projeto, o novo botão, com o ícone de brilhos ao lado do da equipe, abre o diálogo da Sentinela.

![Card do projeto com o botão da Sentinela]({{ site.baseurl }}/assets/img/sentinel/01.png){: width="430" }

A ativação tem três passos:

1. **Termo de Responsabilidade**: o que será enviado ao modelo, o que a plataforma remove antes e quem responde pela escolha do provedor.
2. **Provedor**: GPU Server da Embrapa ou provedor externo, com o modelo a usar.
3. **Ajustes**: frequência (semanal ou diária), destinatários (toda a equipe ou só os arquitetos) e a cópia em Markdown no `io-doc`.

Só os arquitetos do projeto, com e-mail `@embrapa.br`, podem ativar, reconfigurar ou desativar. Depois de salvar, o botão **Executar agora** gera o primeiro relatório em alguns minutos, sem esperar o próximo ciclo.

Cada achado do relatório traz dois _links_, **útil** e **ruído**. O voto em ruído faz a Sentinela parar de relatar aquele achado nos próximos relatórios. É assim que a equipe ensina a Sentinela o que importa no seu projeto, e o relatório vai ficando mais curto e mais certeiro a cada semana.

## Saiba mais {#docs}

O capítulo [Sentinela]({{ site.baseurl }}/docs/sentinel) da documentação descreve o passo a passo da ativação, as fontes consultadas, a anatomia do relatório, as regras de privacidade e as perguntas frequentes.

Como todo texto gerado por IA, o relatório pode conter erros e exige revisão humana: a Sentinela aponta, a equipe decide. Dúvidas, sugestões e relatos de achados equivocados são bem-vindos nos canais de sempre da plataforma.
