---
layout: page
title: Sentinela
subtitle: Relatórios automáticos de insights sobre segurança, estabilidade, desempenho, qualidade e uso por projeto
---

A **Sentinela** é o agente de _insights_ da plataforma **Embrapa I/O**. A cada dia ou semana ela lê o que as ferramentas integradas já registram sobre as aplicações de um [projeto]({{ site.baseurl }}/docs/project), pede a um modelo de inteligência artificial uma leitura qualitativa e envia à equipe, por e-mail, um relatório com o que mudou, o que merece atenção e o que continua em aberto. Uma cópia de cada relatório fica no histórico do projeto, no [_dashboard_ da plataforma]({{ site.baseurl }}/docs/dashboard), e outra, em Markdown, no repositório `io-doc` do projeto.

A ideia não é substituir o _dashboard_, que já mostra os números de cada ferramenta. A Sentinela cruza esses números e conta o que eles significam: uma varredura de _scanners_ que está recebendo resposta `200` em `/.env`, um erro que se repete no Sentry desde o último _deploy_, um estágio que está parado há semanas, uma vulnerabilidade com correção publicada que ninguém aplicou.

![Botão da Sentinela no card do projeto]({{ site.baseurl }}/assets/img/sentinel/01.png){: width="430" }

## Como funciona {#how}

Cada execução passa por quatro etapas, sempre nessa ordem:

1. **Coleta.** A plataforma reúne, para cada aplicação do projeto, um pacote fechado de dados do período: _logs_ do [Loki](https://log.embrapa.io), erros do [Sentry]({{ site.baseurl }}/docs/bug), vulnerabilidades das imagens em execução (Trivy), métricas e _hotspots_ do [SonarQube]({{ site.baseurl }}/docs/quality), _commits_, _merge requests_, _tags_ e _pipelines_ do [GitLab]({{ site.baseurl }}/docs/kanban), acessos do [Matomo]({{ site.baseurl }}/docs/analytics) e o estado dos estágios implantados.
2. **Privacidade.** Antes de qualquer envio, segredos (senhas, chaves, _tokens_) são removidos e identificadores pessoais (endereços IP e e-mails) são substituídos por pseudônimos reversíveis. O modelo nunca vê o valor real.
3. **Análise.** O modelo escolhido pela equipe recebe o pacote de cada aplicação e devolve, num formato fixo, os achados (com evidência e ação sugerida) e de um a três _insights_ por aplicação. Uma segunda passada, mais curta, consolida o que se repete em várias aplicações do mesmo _boilerplate_ num único item do projeto inteiro.
4. **Relatório.** A plataforma monta o e-mail, reidrata os pseudônimos para a equipe, grava o histórico no _card_ e a cópia em Markdown no `io-doc`.

| Fonte | O que entra no pacote |
| --- | --- |
| Loki | Volume de _logs_ e de erros, códigos HTTP, caminhos sensíveis acessados, origens mais frequentes, reinícios e amostras de linhas |
| Sentry | _Issues_ não resolvidas no período, novas e regressões, com contagem de eventos e de usuários afetados |
| Trivy | CVEs altas e críticas nas imagens em execução, por serviço, e quais já têm correção publicada |
| SonarQube | _Quality gate_, notas de manutenibilidade, confiabilidade, segurança e revisão de _hotspots_, cobertura, duplicação, linguagens e os _hotspots_ pendentes |
| GitLab | _Commits_ (sem autor), _merge requests_ mescladas, abertas e paradas, _tags_ publicadas e _pipelines_ com falha |
| Matomo | Visitas por dia (até o último dia completo), ações, rejeição, tempo médio e páginas mais vistas; e o retrato do público: visitantes únicos, novos × recorrentes, dispositivos e sistemas, origem do tráfego e sites que mais encaminham, estados do Brasil (ou países), páginas de entrada, duração das visitas e picos de dia e hora. Sempre agregados: nunca um visitante individual |
| Estágios | Versão implantada em cada estágio, saúde dos serviços e data da última verificação |

> **Atenção!** A Sentinela só lê e relata. Nenhuma ação é executada automaticamente nas aplicações: as correções são sugeridas à equipe, que decide o que fazer.

## Ativando {#enable}

A ativação cabe a um **arquiteto de solução** do projeto. É ele quem aceita o termo de responsabilidade, escolhe o provedor de IA e, se for o caso, cadastra a própria chave de API. Os demais membros da equipe recebem os relatórios e consultam o histórico, mas não configuram.

No _card_ do projeto, clique no botão da Sentinela (o ícone de brilho, ao lado do acesso ao Git). Quando o projeto ainda não tem a Sentinela ativa, o diálogo explica o que ela faz e oferece o botão **Ativar a Sentinela** aos arquitetos.

![Diálogo da Sentinela antes da ativação]({{ site.baseurl }}/assets/img/sentinel/02.png)

O assistente de ativação tem três passos.

### 1. Termo de responsabilidade {#term}

O primeiro passo resume o que será enviado ao modelo, o que a plataforma remove e pseudonimiza antes, e as regras de uso de IA generativa na Empresa. Dois pontos pedem atenção: um **provedor externo** com chave pessoal só pode receber dados **públicos ou não sensíveis**, e a chave de API fica **vinculada a quem aceita o termo**. Só é possível avançar depois de marcar a ciência.

![Passo 1: termo de responsabilidade]({{ site.baseurl }}/assets/img/sentinel/03.png)

### 2. Provedor {#provider}

Há duas opções.

**GPU Server da Embrapa.** Um modelo aberto rodando em servidores da própria Empresa (na GTI ou em outra Unidade). Nenhum dado sai da infraestrutura de TI corporativa, não é preciso chave e não há custo. Escolha o servidor e o modelo disponível nele. É a opção recomendada para começar, e a única possível para projetos com dados que não possam sair da Embrapa.

![Passo 2: GPU Server da Embrapa]({{ site.baseurl }}/assets/img/sentinel/04.png)

**Provedor externo.** Google (Gemini), Anthropic (Claude), OpenAI (GPT) ou qualquer API compatível com a da OpenAI (OpenRouter, vLLM, SGLang etc.), com a sua própria chave. Informe a chave e clique em **Validar chave e listar modelos**: a plataforma confere a chave no provedor e carrega os modelos que ela enxerga, com os sugeridos no topo. A chave é gravada cifrada e nunca é exibida de novo.

![Passo 2: provedor externo]({{ site.baseurl }}/assets/img/sentinel/05.png)

> **Atenção!** Assinantes dos planos pagos de alguns provedores recebem créditos mensais de API que expiram sem acumular. Uma chave criada na organização vinculada ao plano consome esses créditos. Para um uso controlado, crie um espaço de trabalho (_workspace_) próprio para a Sentinela no painel do provedor, com limite de gasto, e gere a chave nele.

### 3. Ajustes {#settings}

Por fim, a frequência, os destinatários e a cópia no `io-doc`:

- **Semanal** (recomendado): um relatório por semana, sempre enviado. **Diário**: a análise roda todos os dias, mas o e-mail só sai quando há novidade; o resumo da semana continua vindo no semanal.
- **Destinatários**: toda a equipe ou só os arquitetos.
- **Cópia em `io-doc`**: grava cada relatório em Markdown em `06-Support/Sentinel/<ano>/`, no repositório de apoio do projeto. Quando a _branch_ `main` desse repositório só aceita _Maintainers_, a Sentinela grava na _branch_ `sentinela` e abre uma _merge request_.

![Passo 3: ajustes]({{ site.baseurl }}/assets/img/sentinel/06.png)

## Executando e acompanhando {#run}

Com a Sentinela ativa, a aba **Sobre** mostra o provedor e o modelo, a chave (só os quatro últimos caracteres e quem a cadastrou), a frequência, a última execução, o custo total acumulado e o termo aceito. Os arquitetos têm três ações: **Reconfigurar** (refaz os três passos, podendo manter a chave atual), **Desativar** (apaga a configuração e a chave; o histórico fica) e **Executar Agora**.

![Aba Sobre com a Sentinela ativa]({{ site.baseurl }}/assets/img/sentinel/07.png)

**Executar Agora** enfileira uma análise imediata com a janela inteira da frequência (os últimos 7 dias no semanal) e envia o e-mail mesmo sem novidade. Serve para o primeiro relatório logo após a ativação e para conferir o efeito de uma correção sem esperar a próxima rodada. Enquanto a análise roda, o botão fica desabilitado e o diálogo se atualiza sozinho; em alguns minutos o relatório chega por e-mail e aparece no histórico.

A aba **Histórico** lista todos os relatórios, com filtro por período: data, tipo, novidades, itens em aberto, quantidade de achados críticos e altos e o custo estimado. O botão da última coluna abre o relatório numa aba do navegador, pronto para leitura ou para imprimir em PDF.

![Aba Histórico]({{ site.baseurl }}/assets/img/sentinel/08.png)

> **Atenção!** Os relatórios agendados cobrem o período desde a última execução. Se a equipe rodar "Executar Agora" na quinta-feira, o semanal de segunda vai cobrir só os dias seguintes a ela. O gráfico de visitas, por sua vez, mostra sempre os últimos sete dias.

## O relatório {#report}

O relatório é o mesmo por e-mail, no histórico e no `io-doc`. Ele começa pelo retrato do período: indicadores (novidades, itens em aberto e contagem por severidade) e o **panorama**, com cinco gráficos: novidades por aplicação e severidade; visitas por dia (uma linha por aplicação com site no Matomo, até o último dia completo); quem acessa e de onde, para o projeto inteiro (dispositivos, origem do tráfego e estados do Brasil ou países, em participação); páginas mais acessadas somando todas as aplicações; e vulnerabilidades altas e críticas nas imagens em execução, com a proporção que já tem correção. Os dois gráficos de público existem para que o relatório sirva também a quem não é de TI na equipe publicada.

![Cabeçalho e indicadores do relatório]({{ site.baseurl }}/assets/img/sentinel/09.png)

![Panorama: gráficos do período]({{ site.baseurl }}/assets/img/sentinel/10.png)

Em seguida vêm as aplicações, da mais crítica para a menos. Cada uma começa por até três caixas de **_insight_**: o que mais vale a atenção da equipe naquele momento, em uma ou duas linhas, com a cor e o ícone do tipo:

| Tipo | Significado |
| --- | --- |
| Segurança | Exposição, configuração insegura ou _hotspot_ que precisa de revisão |
| Varredura ou ataque | _Scanners_ e tentativas de exploração vistas nos _logs_ |
| Dependências e CVEs | Pacotes e imagens com vulnerabilidades que já têm correção |
| Erro recorrente | O mesmo erro se repetindo no Sentry ou nos _logs_ |
| Estabilidade | Reinícios, falta de memória, estágio parado |
| Integração | SMTP, banco ou API externa que deixou de responder |
| Desempenho | Lentidão e picos de resposta |
| Qualidade do código | _Quality gate_, cobertura, _bugs_ e dívida técnica |
| Distribuição e alcance | `robots.txt`, `sitemap.xml`, PWA, acessibilidade |
| Uso | Adoção e tendência de acessos |
| Tudo em ordem | Nada a fazer naquela aplicação |

Abaixo dos _insights_ ficam os **achados**, agrupados por categoria, cada um com a severidade, a evidência (números, trechos, datas), a ação sugerida, o link para a ferramenta de origem e os votos de retorno.

![Insights e achados de uma aplicação]({{ site.baseurl }}/assets/img/sentinel/11.png)

Quando várias aplicações do mesmo _boilerplate_ repetem o mesmo problema (os mesmos _hotspots_ de `Dockerfile`, a mesma varredura, a mesma cobertura zerada), ele aparece uma vez só, na seção **projeto inteiro**, com a ação que resolve para todas. A seção **Continua em aberto** traz o que já foi relatado antes e segue sem ação, e o **Resumo do período** fecha com os números de cada aplicação: estágios, código, _logs_, erros, CVEs, qualidade (com as notas do SonarQube e a proporção de linguagens) e uso.

![Resumo do período de uma aplicação]({{ site.baseurl }}/assets/img/sentinel/12.png)

O rodapé de cada relatório informa o provedor, o modelo, os _tokens_ consumidos e o custo estimado, e lembra que o conteúdo foi gerado por IA e exige revisão humana.

## Retorno: útil ou ruído {#feedback}

Cada achado traz os links **útil** e **ruído**. O voto é individual e serve a dois fins: medir a qualidade da análise e silenciar o que não interessa. Um achado marcado como **ruído** não volta nos próximos relatórios daquele projeto, nem como novidade nem como pendência. Marcar como **útil** reverte um voto de ruído anterior. Os links abrem o _dashboard_; o voto é registrado depois do _login_.

## Privacidade e responsabilidade {#privacy}

- **Nada é executado.** A Sentinela não altera aplicações, repositórios nem servidores.
- **Segredos nunca chegam ao provedor.** Senhas, chaves e _tokens_ são removidos do pacote antes do envio, inclusive os que aparecem em _logs_ e em linhas de comando.
- **Dados pessoais são pseudonimizados.** Endereços IP e e-mails viram marcadores (`IP#3`, `EMAIL#1`) antes da análise e só são reidratados no relatório final, que a equipe lê.
- **Ninguém é avaliado.** Nenhum achado nomeia autor de _commit_ nem mede produtividade individual; o pacote de código vai sem autores.
- **É IA.** O relatório pode conter erros, exagerar ou minimizar um risco, e exige revisão humana antes de qualquer decisão.
- **A chave é de quem configura.** Cifrada, nunca exibida de novo e apagada se a pessoa deixar de ser arquiteta do projeto (os demais arquitetos são avisados por e-mail) ou quando o projeto é arquivado. Outro arquiteto pode sobrescrevê-la a qualquer momento.

## Perguntas frequentes {#faq}

**Uma aplicação não aparece no relatório.** Só entram aplicações com algum estágio implantado. Aplicações sem achado e sem _insight_ não ganham seção de achados, mas aparecem no resumo do período.

**O relatório diário não chegou.** No diário, o e-mail só sai quando há novidade; o histórico registra a execução mesmo assim. O semanal é sempre enviado.

**A chave expirou ou foi revogada.** A próxima execução falha, o estado na aba Sobre muda para "Chave inválida" e o projeto deixa de ser analisado até um arquiteto reconfigurar.

**Os créditos acabaram.** A execução é adiada para o dia seguinte e o relatório traz o aviso; nada é perdido.

**Quanto custa?** No GPU Server da Embrapa, nada. Num provedor externo, o custo depende do modelo e do tamanho do projeto; o rodapé e o histórico mostram a estimativa de cada relatório e a aba Sobre, o acumulado. Um projeto de oito aplicações analisado semanalmente com um modelo de porte médio fica na casa de alguns centavos de dólar por relatório.

**Quero voltar atrás.** **Desativar** apaga a configuração e a chave e mantém o histórico. Arquivar o projeto apaga tudo.

**Onde fica a cópia em Markdown?** No repositório `io-doc` do projeto, em `06-Support/Sentinel/<ano>/<data>-semanal.md` ou `-diario.md`, com _front matter_ pensado para servir de insumo a agentes de IA e continuar legível para pessoas.
