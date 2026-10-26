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

1. **Coleta.** A plataforma reúne, para cada aplicação do projeto, um pacote fechado de dados do período: _logs_ do [Loki](https://log.embrapa.io), erros do [Sentry]({{ site.baseurl }}/docs/bug), vulnerabilidades das imagens em execução (Trivy) e das dependências dos aplicativos de loja (OSV), métricas e _hotspots_ do [SonarQube]({{ site.baseurl }}/docs/quality), _commits_, _merge requests_, _tags_ e _pipelines_ do [GitLab]({{ site.baseurl }}/docs/kanban), acessos do [Matomo]({{ site.baseurl }}/docs/analytics) e o estado dos estágios implantados.
2. **Privacidade.** Antes de qualquer envio, segredos (senhas, chaves, _tokens_) são removidos e identificadores pessoais (endereços IP e e-mails) são substituídos por pseudônimos reversíveis. O modelo nunca vê o valor real.
3. **Análise.** O modelo escolhido pela equipe recebe o pacote de cada aplicação e devolve, num formato fixo, os achados (com evidência e ação sugerida) e de um a três _insights_ por aplicação. Uma segunda passada, mais curta, consolida o que se repete em várias aplicações do mesmo _boilerplate_ num único item do projeto inteiro.
4. **Relatório.** A plataforma monta o e-mail, reidrata os pseudônimos para a equipe, grava o histórico no _card_ e a cópia em Markdown no `io-doc`.

| Fonte | O que entra no pacote |
| --- | --- |
| Loki | Volume de _logs_ e de erros, códigos HTTP, caminhos sensíveis acessados, origens mais frequentes, reinícios e amostras de linhas |
| Sentry | _Issues_ não resolvidas no período, novas (pelo primeiro evento da vida inteira da _issue_, não só do período) e regressões, com contagem de eventos no período e no total e de instalações afetadas; para as mais relevantes, de onde vêm (versão, ambiente, navegador, sistema) e as linhas do app mais próximas do erro |
| Trivy | CVEs altas e críticas nas imagens em execução, por serviço, e quais já têm correção publicada, com o **caminho da correção** de cada uma, decidido pela plataforma: reconstruir a imagem (base flutuante), subir a base fixada no `Dockerfile` (na aplicação ou no _boilerplate_, conforme o fork diverge ou não dele), atualizar a imagem do fornecedor (binário de terceiro, como `gosu` ou MinIO) ou subir a dependência direta que traz a vulnerável |
| Ficha do repositório | O que os arquivos de _build_ dizem, lidos na _tag_ mais recente e reduzidos a fatos, nunca ao conteúdo: no `Dockerfile`, a imagem base, o usuário, `COPY . .`, `npm ci` e `ARG` com nome de segredo; no `.dockerignore`, se exclui `.git` e `.env`; no `docker-compose`, portas publicadas, bancos e ferramentas de administração e senha escrita no `command`; na configuração do nginx, o _fallback_ da SPA; no `package-lock.json`, qual dependência direta traz cada pacote vulnerável; e o que veio do _boilerplate_ de origem |
| Dependências | Para aplicativos de loja e aplicações fora da plataforma: CVEs conhecidas (base [OSV](https://osv.dev)) nos pacotes dos _lockfiles_ (e, em .NET sem _lockfile_, nas versões do `.csproj`), separando o que chega ao usuário do que é só ferramenta de _build_, e o _framework_ fora de suporte. Veja [Dependências dos aplicativos](#deps) |
| SonarQube | _Quality gate_ (aprovado, reprovado ou sem análise), a análise que vale (data, ramo e _commit_), notas, cobertura, duplicação, as linguagens do repositório que ficaram fora da análise, as vulnerabilidades abertas de qualquer data, os arquivos que concentram os problemas e os _hotspots_ pendentes |
| GitLab | _Commits_ (sem autor), _merge requests_ mescladas, abertas e paradas (número, título e última atualização), _tags_ publicadas e _pipelines_ com falha |
| Matomo | Visitas por dia (até o último dia completo), ações, rejeição, tempo médio e páginas mais vistas (com o identificador de registro trocado por `:id`, para `/relatorio/:id` contar como uma página só); e o retrato do público: visitantes únicos, novos × recorrentes, dispositivos e sistemas, origem do tráfego e sites que mais encaminham, estados do Brasil (ou países), páginas de entrada, duração das visitas e picos de dia e hora. Sempre agregados: nunca um visitante individual |
| Estágios | Para cada estágio que existe (com versão no ar ou com _tag_ no GitLab): a versão implantada, a data e a idade dela, a última _tag_ do estágio, quem implanta (o _cluster_ da plataforma ou um [Releaser]({{ site.baseurl }}/docs/releaser#report), com o último contato), o _status_ da _build_ na plataforma, a saúde dos serviços e a data da última verificação. Veja [Estágios](#stages) |
| Google Play | Para aplicativos nativos publicados na loja: taxa de _crash_ e de ANR por versão, erros agrupados (tipo, local, usuários afetados), instalações, ficha da loja e o histórico de avaliações, sem o nome do autor, com rascunho de resposta para as que pedem uma. Veja [Aplicativos na Google Play](#play) |

### Estágios {#stages}

O relatório traz um inventário de estágios por aplicação, montado pela plataforma e não pelo modelo: as datas e as idades já vêm calculadas, e um estágio que existe nunca some do relatório só porque não respondeu. Um estágio entra quando tem versão no ar ou quando tem _tag_ no GitLab (`V.AA.M-alpha.P`, `V.AA.M-beta.P` ou `V.AA.M-P`).

O estado de um estágio só é confiável quando ele foi verificado. Ele aparece como **não verificado**, com o motivo escrito, quando:

- há _tag_ do estágio, mas nenhum _deploy_ registrado na plataforma (o estágio roda fora do _cluster_, num Releaser anterior à versão que reporta, ou não foi implantado);
- o Releaser que o implanta não reporta há mais de 24 horas;
- a _build_ está em rascunho na plataforma, mas a versão antiga continua registrada (contêineres de um _deploy_ antigo);
- a saúde nunca foi verificada, ou a última verificação tem mais de dois dias.

Um estágio em rascunho e sem _deploy_ é inativo por escolha da equipe: aparece no resumo, sem achado. Um contêiner de execução única que terminou bem (inicialização, migração) não conta como fora do ar, a menos que a _stack_ inteira esteja parada. Quando o `alpha` ou o `beta` estão numa versão anterior à da `release` (por exemplo, `alpha` na série 0 e `release` na série 1), o relatório avisa que a versão do estágio de teste não é o estado do produto.

Quatro situações viram **achado fixo**, sem depender de o modelo notar, com título estável para o item acompanhar o indicador **Em aberto** até ser resolvido:

| Achado | Severidade |
| --- | --- |
| Estágio sem verificação de saúde (agrupado no projeto inteiro quando o mesmo motivo se repete em várias aplicações) | alta na `release`, média no `beta`, baixa no `alpha` |
| Estágio com todos os serviços fora do ar | idem |
| Última _tag_ do estágio que não chegou ao ar | média |
| _Merge requests_ abertas sem atualização há mais de uma semana, com o número, o título, a _branch_ alvo, a data e o que fazer com cada uma (fechar, porque o conteúdo já está na _branch_ alvo; _rebase_, por conflito; ou mesclar) | média quando alguma é de segurança; baixa nas demais |
| _Merge requests_ mescladas depois da _tag_ mais recente, portanto fora de qualquer versão no ar (num item só quando a mesma correção foi mesclada em várias aplicações) | média quando há correção de segurança; baixa nas demais |
| Serviço que iniciou mais de 20 vezes no período | alta na `release`, média no `beta`, baixa no `alpha` |
| Contêineres antigos do estágio num servidor que não é o _cluster_ do _build_ ativo (eles nunca dizem o estado do estágio) | média se estão no ar; baixa se parados |
| Aplicação sem _commit_ no período e com todas as versões no ar de mais de 120 dias | média com CVE crítica corrigível; baixa nas demais |
| CVE crítica com correção numa imagem sem nenhum achado do Trivy para a aplicação | alta |
| Segredo passado como `ARG` de _build_ no `Dockerfile` | alta se gravado em `ENV` ou arquivo; média nas demais |
| `COPY . .` sem `.dockerignore` que exclua `.git` e `.env` | média |
| Banco de dados ou ferramenta de administração (pgAdmin, Adminer, MailHog…) com porta publicada no servidor, dizendo quando veio do _compose_ do _boilerplate_ | alta |
| Senha escrita no `command` de um serviço do _compose_ | média |
| Análise do SonarQube antiga, ou de uma _branch_ atrás da que vai ao ar, em várias aplicações (um item só, pedindo reanálise antes de agir) | baixa |

> **Atenção!** A Sentinela só lê e relata. Nenhuma ação é executada automaticamente nas aplicações: as correções são sugeridas à equipe, que decide o que fazer.

Aplicação que tem estágios na plataforma, mas nenhum `release`, ganha um aviso em **Para ciência**: se há produção, ela roda fora da plataforma, e os _logs_, erros, CVEs e saúde dela não estão no relatório. O modelo também é instruído a não chamar `alpha` ou `beta` de produção.

### Aplicação pausada de propósito {#paused}

Quando a equipe pausa uma aplicação (por exemplo, enquanto espera outro projeto), estágio parado, falta de _logs_ e zero visitas não são problema. Para a Sentinela saber disso, declare o estado no `.embrapa/settings.json` do repositório da aplicação, na _branch_ padrão:

```json
"lifecycle": {
  "state": "paused",
  "until": "2027-03",
  "reason": "aguarda a conclusão do projeto X"
}
```

O `state` aceita `paused` (pausada), `maintenance` (em manutenção) e `active`; `until` (ano e mês da retomada) e `reason` são opcionais. Com a aplicação pausada, os achados de estágio parado e de falta de uso viram ciência, e os de segurança continuam, porque as imagens que seguem no ar continuam vulneráveis: a ação sugerida passa a incluir desligar os estágios ou reconstruir as imagens durante a pausa. A 30 dias da retomada, o relatório lembra de reconstruir as imagens antes de voltar. Uma aplicação sem esse campo, sem _commit_ no período e com versões antigas no ar recebe o achado de aplicação sem atividade, que sugere declarar a pausa.

### Aplicativos na Google Play {#play}

Aplicativos nativos para Android não têm estágio implantado na plataforma, mas são apps legítimas do projeto, com Sentry, Matomo e SonarQube. Para eles a Sentinela também lê a **Google Play**, em três frentes:

- **Estabilidade e desempenho** (Android vitals): a taxa de _crash_ e de ANR (_Application Not Responding_) do período e as médias de 28 dias percebidas pelo usuário, que são os números que a Play compara com os limiares de mau comportamento (crash 1,09%, ANR 0,47%, 8% em qualquer modelo de aparelho) para decidir se reduz a visibilidade do app na loja; a quebra por versão, aparelho e versão do Android; o início lento (frio, morno, quente), _wakeups_ excessivos, _wakelocks_ presos e renderização lenta; e os erros agrupados pela loja, com o local e os usuários afetados. Os oito grupos mais frequentes trazem a pilha de um relato, com o aparelho e a versão do Android: quando nenhuma linha da pilha é do app ou de biblioteca embarcada nele, o crash nasceu no sistema, no WebView ou na camada do fabricante, e o relatório não sugere mudar o código do app. O achado mostra a mensagem e as primeiras linhas da pilha. Os estouros de limiar viram **achado fixo**, sem depender de o modelo notar: média de 28 dias acima do limiar (alta; crítica no dobro), pico no período com amostra suficiente, modelo de aparelho acima de 8% e versão nova que passou do limiar quando a anterior estava abaixo (média). O diagnóstico do modelo (o erro agrupado de mais usuários, o local e a correção) é juntado ao achado, e o título fica estável, para o item acompanhar o indicador **Em aberto** até a taxa voltar ao normal.
- **Loja**: instalações e desinstalações por dia, dispositivos ativos e o funil da ficha (visitantes, aquisições, conversão, por país, origem de tráfego e termo de busca), sempre com o período anterior de mesmo tamanho para comparação. Esses dados vêm da exportação em massa da Play Console, que chega com 3 a 7 dias de atraso: por isso o período de cada arquivo termina no último dia que a Google já publicou, e o relatório mostra essas datas. Um arquivo que parou de ser atualizado há mais de 21 dias (comum no _flavor_ de homologação) sai do resumo, com o aviso de até quando havia dado, em vez de mostrar um período antigo como se fosse o atual. Abaixo do limiar de privacidade da Google, países, origens e buscas vêm agrupados em "Other" e não aparecem.
- **Avaliações**: o histórico completo de cada pacote, desde a publicação, com estrelas, versão, aparelho e se a equipe já respondeu. Ele vem do CSV mensal da exportação em massa e da API da Play (que só devolve a última semana) e fica guardado num acervo da Sentinela. Sem a exportação liberada, o acervo se forma com a API a cada execução.
  - **Classificação uma vez só.** O modelo lê cada avaliação com texto uma única vez e registra o sentimento, o tema (falha, lentidão, acesso, dados, usabilidade, pedido de recurso, pergunta, elogio) e se ela pede resposta. A avaliação só volta ao modelo se for editada. Na primeira execução, o acervo é classificado em lotes de 40, as sem resposta primeiro.
  - **Rascunho de resposta.** Para cada avaliação que pede resposta, o modelo escreve um rascunho da resposta pública, no idioma da avaliação e com até 350 caracteres, para a equipe revisar e publicar na Play Console. A Sentinela nunca responde sozinha: a resposta é pública e notifica quem avaliou.
  - **Pendências no "em aberto".** Avaliação dos últimos 12 meses que pede resposta e está sem ela vira um item próprio do relatório, que entra no indicador **Em aberto** do card. O item fecha sozinho quando a resposta aparece na Play e reabre se a pessoa editar a avaliação depois da resposta. As de 1–2 estrelas entram mesmo antes de serem classificadas. As sem resposta com mais de 12 meses aparecem uma única vez, como **dívida histórica**, para não inflar o indicador para sempre.
  - **Sentimento e nota.** O modelo lê o sentimento do público (melhorando, estável ou piorando, com a justificativa) a partir da série mensal da nota: a média acumulada e a média de cada janela de 30 dias, nos últimos seis meses, com a proporção de avaliações negativas. Em apps com poucas avaliações, a nota de uma semana não se move; mês a mês, sim. A nota acumulada de cada mês é a oficial da Google; no mês em que a Google não publicou o arquivo, ela é estimada a partir do acervo, ajustada ao nível da oficial. Uma nota implausível na exportação é descartada, sem virar variação.
  - As avaliações chegam ao modelo sem o nome de quem escreveu e aparecem no relatório em paráfrase, identificadas por uma chave curta.

No Matomo, as visitas concentradas nos Estados Unidos no dia de um envio de versão à Play são o teste de pré-lançamento da Google (aparelhos do Firebase Test Lab que abrem e navegam o app sozinhos): o relatório as identifica assim, e não como público novo.

No relatório isso vira o bloco **Google Play · loja** no card da app (nota em estrelas com a variação, estabilidade contra os limiares, instalações e ficha, distribuição das avaliações), o gráfico **Instalações e nota na Google Play** no panorama (instalações por dia em oito semanas e a nota em seis meses) e a seção **Avaliações e sentimento na Google Play** (sentimento, avaliações sem resposta com o rascunho e dívida histórica), além dos achados e insights de costume (um crash que estourou o limiar numa versão, um ANR concentrado num aparelho, uma queda de conversão da ficha).

![Gráfico de instalações e nota na Google Play no panorama]({{ site.baseurl }}/assets/img/sentinel/16.png)

No gráfico, as barras verdes são as instalações e as vermelhas, as desinstalações de cada dia, nas oito semanas mais recentes da exportação; à direita, a linha é a nota oficial da Google, um ponto a cada 30 dias, e os círculos são a média das avaliações recebidas em cada mês (maiores quando há mais avaliações).

![Bloco Google Play no card da app]({{ site.baseurl }}/assets/img/sentinel/21.png)

No card da app, o bloco mostra a nota em estrelas e os dispositivos ativos, a estabilidade contra os limiares da Play (com o tamanho da amostra dos vitals), as instalações do período com a variação, o saldo, as datas da exportação e o funil da ficha, e a distribuição das avaliações do período.

![Seção de avaliações e sentimento na Google Play]({{ site.baseurl }}/assets/img/sentinel/18.png)

A seção de avaliações traz, por pacote, o sentimento do público (no selo, melhorando, estável ou piorando) e a leitura do modelo em uma ou duas frases; quando há avaliação que pede resposta, ela aparece abaixo em paráfrase, com o rascunho de resposta e o link para a Play Console. São três contagens, cada uma com o seu nome: as **não respondidas no período** (todas as avaliações da semana ainda sem resposta, inclusive elogios que não pedem uma), as que **pedem resposta** nos últimos 12 meses (o que entra no **Em aberto**) e a **dívida histórica** (mais de 12 meses).

Para a Sentinela enxergar o app, três coisas precisam estar no lugar:

1. **A conta de serviço da plataforma cadastrada como usuária da conta de desenvolvedor na Play Console.** A Sentinela usa uma única conta de serviço, `sentinela@embrapa-io.iam.gserviceaccount.com`, com duas permissões **somente leitura**, dadas nas **permissões da conta** (e não app por app, para que os apps novos já nasçam visíveis): **Ver informações do app e fazer o download de relatórios em massa** e **Ver informações de qualidade do app** (Android vitals). Elas bastam para ler também as avaliações; a permissão "Responder a avaliações" não é necessária e não deve ser dada, porque a Sentinela nunca responde nada. Na conta de desenvolvedor da **Embrapa** (`aplicativos@embrapa.br`) o cadastro já está feito. Apps publicados na conta de um **parceiro**, como o Pasto Certo na Unipasto, precisam que o administrador da conta do parceiro faça o mesmo cadastro, em "Usuários e permissões", convidando o e-mail da conta de serviço com essas duas permissões no nível da conta.

2. **Os pacotes do app declarados no `.embrapa/settings.json`** do repositório, na _branch_ padrão, no atributo `stores`, porque um app costuma publicar mais de um _flavor_ (produção e homologação, por exemplo). São lidos até quatro pacotes por aplicação:

```json
"stores": {
  "play": [ "br.embrapa.siexp", "br.embrapa.siexp.homolog" ]
}
```

3. **O bucket da exportação em massa.** Na Play Console, em _Download reports_, o botão _Copy Cloud Storage URI_ dá o identificador, que começa com `pubsite_prod_rev_`; o atributo aceita também o URI como copiado (`gs://pubsite_prod_rev_…/`) ou só o número. O da conta da Embrapa fica configurado uma vez na plataforma; um app publicado na conta de um parceiro declara o bucket do parceiro no mesmo atributo:

```json
"stores": {
  "play": [ "br.embrapa.pastocerto" ],
  "play_bucket": "pubsite_prod_rev_01234567890987654321"
}
```

Um pacote que a conta de serviço não enxerga aparece no relatório como aviso fixo de configuração na seção **Avisos da coleta**, não como achado; um erro passageiro da Google (resposta 5xx) também não vira achado: o dado daquela execução apenas falta; sem o bucket, o relatório sai sem instalações e funil da ficha, o histórico de avaliações começa a contar a partir da primeira execução, e o relatório diz isso. A Google só gera a exportação de app publicado em **produção**: app que ainda está só em teste interno, fechado ou aberto aparece com o aviso "sem dados na exportação" e as faixas em que há versão no ar, e as instalações ausentes não são tratadas como queda. Os vitals de app em teste também costumam vir vazios, porque a Play só calcula as taxas a partir de um número mínimo de usuários. Por enquanto só a Google Play é lida; a App Store fica para depois.

### Dependências dos aplicativos {#deps}

O Trivy enxerga só as imagens em execução nos _clusters_, e aplicativo de loja não roda em contêiner. Para eles, a Sentinela lê os **_lockfiles_** do repositório, na _branch_ padrão, e consulta cada pacote na [OSV](https://osv.dev), a base aberta de vulnerabilidades mantida pela Google. Entram os apps que declaram `stores` no `.embrapa/settings.json` e os que não têm estágio implantado; apps de servidor continuam com o Trivy. Só sai do repositório o nome e a versão de cada pacote público, nunca código.

| Tecnologia | _Lockfile_ lido | Observação |
| --- | --- | --- |
| Flutter | `pubspec.lock` | Pacotes do pub.dev; o relatório também mostra a versão mínima do Flutter declarada |
| Android nativo (Java, Kotlin) | `gradle.lockfile` | Exige o travamento de dependências do Gradle, descrito abaixo; só o que vai no APK de _release_ é verificado |
| React Native, Capacitor, Ionic, Cordova | `package-lock.json`, `yarn.lock` ou `pnpm-lock.yaml` | Dependências de desenvolvimento ficam de fora. No `package-lock.json`, cada vulnerabilidade é marcada pelo que chega ao usuário (app), pelo que é só ferramenta de _build_ (CLI, instaladores) e pela plataforma não publicada (iOS num app só da Play); a severidade do achado segue o que chega ao usuário |
| .NET (MAUI, Xamarin, ASP.NET Core) | `packages.lock.json` ou, sem ele, o `.csproj` | Com o `.csproj`, só as dependências diretas de versão exata são verificadas; `RestorePackagesWithLockFile` cobre as transitivas. O relatório também aponta o _framework_ fora de suporte (o alvo atual é o .NET 10) |
| iOS (CocoaPods) | `Podfile.lock` | **Não coberto**: a OSV não tem base para o CocoaPods. O relatório registra a lacuna |

Um projeto Android sem `gradle.lockfile` aparece com o aviso para ligá-lo. Basta incluir no `app/build.gradle`:

```groovy
dependencyLocking {
	lockAllConfigurations()
}
```

e gerar o arquivo com `./gradlew :app:dependencies --write-locks`. Daí em diante, o _build_ falha se uma dependência mudar sem o _lockfile_ acompanhar: ao incluir, remover ou atualizar dependência, regrave-o com o mesmo comando e faça o _commit_ junto. Bibliotecas em JAR solto (`app/libs/*.jar`) ficam fora do _lockfile_ e da verificação, e o relatório as lista: declará-las como dependência Maven resolve.

No relatório, as CVEs das dependências aparecem na célula **CVEs** do _card_ da app e no gráfico de vulnerabilidades do panorama. Diferente de um servidor, a correção só chega ao usuário com uma versão nova na loja: crítica ou alta com correção publicada vira achado de segurança com a atualização do pacote e a publicação.

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

**Provedor externo.** Google (Gemini), Anthropic (Claude), OpenAI (GPT), xAI (Grok), OpenRouter (vários modelos com uma chave só) ou qualquer API compatível com a da OpenAI (vLLM, SGLang, Ollama etc.), com a sua própria chave. Uma chave de formato conhecido só é enviada ao provedor dono dela: a plataforma recusa, antes de qualquer conexão, uma chave da Anthropic apontada para outro provedor, por exemplo. Informe a chave e clique em **Validar chave e listar modelos**: a plataforma confere a chave no provedor e carrega os modelos que ela enxerga, com os sugeridos no topo. A chave é gravada cifrada e nunca é exibida de novo.

![Passo 2: provedor externo]({{ site.baseurl }}/assets/img/sentinel/05.png)

Os GPU Servers servem um modelo por vez e podem ser trocados ou desligados, e um modelo de provedor externo pode ser descontinuado. Por isso, antes de cada execução, a Sentinela confere se o modelo configurado ainda é servido. Se não for, o relatório não é gerado, o motivo aparece no card em **Último problema** e os arquitetos de solução do projeto (e só eles) recebem um aviso por e-mail, uma vez por problema a cada 24 horas:

- **o servidor não respondeu:** pode ser passageiro; veja a situação dos servidores em [status.embrapa.io](https://status.embrapa.io) e, quando ele voltar, rode a Sentinela pelo card (**Executar agora**);
- **o servidor saiu de operação:** o GPU Server configurado não é mais oferecido pela plataforma; escolha outro provedor nas configurações da Sentinela;
- **o modelo não é mais servido:** o servidor está no ar, mas oferece outro modelo; o aviso lista os disponíveis, para a escolha nas configurações.

Trocar o modelo nas configurações não gera aviso: quem troca é a própria equipe.

> **Atenção!** Assinantes dos planos pagos de alguns provedores recebem créditos mensais de API que expiram sem acumular. Uma chave criada na organização vinculada ao plano consome esses créditos. Para um uso controlado, crie um espaço de trabalho (_workspace_) próprio para a Sentinela no painel do provedor, com limite de gasto, e gere a chave nele.

### 3. Ajustes {#settings}

Por fim, a frequência, os destinatários e a cópia no `io-doc`:

- **Semanal** (recomendado): um relatório por semana, sempre enviado, na madrugada de domingo para segunda (a partir das 2h de Brasília), para a equipe começar a semana com ele. **Diário**: a análise roda todos os dias no mesmo horário, mas o e-mail só sai quando há novidade; o resumo da semana continua vindo no semanal.
- **Destinatários**: toda a equipe ou só os arquitetos.
- **Cópia em `io-doc`**: grava cada relatório em Markdown em `06-Support/Sentinel/<ano>/`, no repositório de apoio do projeto. Quando a _branch_ `main` desse repositório só aceita _Maintainers_, a Sentinela grava na _branch_ `sentinela` e abre uma _merge request_. A opção só fica disponível quando o repositório de **Documentação técnica** (`doc`) está ativo nos repositórios de suporte do projeto; sem ele, ela aparece desligada, com o aviso para ativá-lo nas configurações do projeto. Um repositório de suporte desativado é arquivado e deixa de aceitar gravação: nesse caso a Sentinela pula a cópia e registra o motivo no _log_, sem falhar a execução.

![Passo 3: ajustes]({{ site.baseurl }}/assets/img/sentinel/06.png)

## Executando e acompanhando {#run}

Com a Sentinela ativa, a aba **Sobre** mostra o provedor e o modelo, a chave (só os quatro últimos caracteres e quem a cadastrou), a frequência, a última execução, o custo total acumulado e o termo aceito. Os arquitetos têm três ações: **Reconfigurar** (refaz os três passos, podendo manter a chave atual), **Desativar** (apaga a configuração e a chave; o histórico fica) e **Executar Agora**.

![Aba Sobre com a Sentinela ativa]({{ site.baseurl }}/assets/img/sentinel/07.png)

**Executar Agora** enfileira uma análise imediata com a janela inteira da frequência (os últimos 7 dias no semanal) e envia o e-mail mesmo sem novidade. Depois da ativação, o primeiro relatório agendado só sai na rodada seguinte (no semanal, a próxima segunda-feira); para tê-lo na hora, use este botão. Serve também para conferir o efeito de uma correção sem esperar a próxima rodada. Enquanto a análise roda, o botão fica desabilitado e o diálogo se atualiza sozinho; em alguns minutos o relatório chega por e-mail e aparece no histórico.

A seta ao lado do botão oferece a **prévia**: a mesma análise, que aparece só no histórico, marcada como "Prévia", sem e-mail e sem cópia no `io-doc`. Ela não muda nada para o próximo relatório: a janela do agendado, os itens em aberto e a lista de avaliações sem resposta ficam como estavam. Serve para conferir uma correção ou testar a configuração sem encher a caixa da equipe.

A aba **Histórico** lista todos os relatórios, com filtro por período: data, tipo, novidades, itens em aberto, quantidade de achados críticos e altos e o custo estimado. O botão da última coluna abre o relatório numa aba do navegador, pronto para leitura ou para imprimir em PDF.

![Aba Histórico]({{ site.baseurl }}/assets/img/sentinel/08.png)

> **Atenção!** Todo relatório cobre o período inteiro da frequência: o semanal, os últimos sete dias, mesmo que a equipe tenha rodado "Executar Agora" no meio da semana. O que já foi relatado e continua sem solução aparece em "Continua em aberto", e não como novidade.

## O relatório {#report}

O relatório é o mesmo por e-mail, no histórico e no `io-doc`, e se divide em seções numeradas, sempre na mesma ordem: indicadores, panorama, sumário, achados, loja (só quando há app na Google Play), pendências, ciência e atividade. As imagens desta seção vêm de um relatório semanal real, com alguns itens de segurança omitidos; só o gráfico de vulnerabilidades usa dados fictícios.

> **Atenção!** Vulnerabilidades que já estão sendo exploradas na internet e que a plataforma alertou por e-mail aparecem numa seção própria, **Vulnerabilidades em exploração ativa**, no topo do relatório, antes de qualquer outro achado. Essa seção é montada a partir dos dados, não pelo modelo de IA, e essas CVEs saem da lista comum de vulnerabilidades. Veja [como funciona o alerta]({{ site.baseurl }}/docs/cve).

Ele começa pelo retrato do período: o cabeçalho (período, data de geração, projeto e aplicações) e os **indicadores**, com as novidades, os itens em aberto e a contagem das novidades por severidade.

![Cabeçalho e indicadores do relatório]({{ site.baseurl }}/assets/img/sentinel/09.png)

Em seguida vem o **panorama**, com até seis gráficos, cada um com a ferramenta de origem no canto. O primeiro empilha as novidades por aplicação e severidade:

![Panorama: novidades por app e severidade]({{ site.baseurl }}/assets/img/sentinel/10.png)

As **visitas por dia** trazem uma linha por aplicação com site no Matomo, na mesma escala, até o último dia completo. As linhas tracejadas verticais marcam as _tags_ publicadas no período, para ver se uma versão nova mudou o uso:

![Panorama: visitas por dia]({{ site.baseurl }}/assets/img/sentinel/13.png)

**Quem acessa e de onde** soma as aplicações do projeto: visitantes únicos e dispositivos, a origem do tráfego (sites que encaminham, acesso direto, busca, assistentes de IA) e os estados do Brasil (ou países) com mais visitas, sempre em participação:

![Panorama: quem acessa e de onde]({{ site.baseurl }}/assets/img/sentinel/14.png)

As **páginas mais acessadas** somam todas as aplicações, com a aplicação de cada página no selo; o identificador de registro vira `:id`, para que as páginas de detalhe de cada registro não se espalhem pela lista:

![Panorama: páginas mais acessadas]({{ site.baseurl }}/assets/img/sentinel/15.png)

Quando há app na loja, entra o gráfico de **instalações e nota na Google Play** (descrito em [Aplicativos na Google Play](#play)); por fim, as **vulnerabilidades** altas e críticas nas imagens em execução, por estágio, e nas dependências dos apps de loja, com a proporção que já tem correção publicada (a imagem abaixo usa dados fictícios, no mesmo formato do relatório real):

![Panorama: vulnerabilidades nas imagens em execução e nas dependências (dados fictícios)]({{ site.baseurl }}/assets/img/sentinel/23.png)

Os gráficos de público existem para que o relatório sirva também a quem não é de TI na equipe. O panorama fecha com **a semana em números**: visitas, requisições e respostas `5xx`, _commits_ e _tags_, reinícios e linhas de erro, e a proporção de CVEs corrigíveis.

![A semana em números]({{ site.baseurl }}/assets/img/sentinel/17.png)

O **sumário** é uma tabela com as novidades de cada aplicação por severidade e os itens em aberto, da aplicação mais crítica para a menos.

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
| Adoção de novidades | Uma funcionalidade ou conteúdo lançado no período (tags, _merge requests_) e como o público o recebeu: acessos desde o lançamento, participação nas visitas, de onde veio o interesse |
| Tudo em ordem | Nada a fazer naquela aplicação |

Abaixo dos _insights_ ficam os **achados**, agrupados por categoria, cada um com a severidade, a evidência (números, trechos, datas), a ação sugerida, o link para a ferramenta de origem e os votos de retorno. Todo achado pede uma ação concreta que a equipe possa executar: uma observação sem ação (um _deploy_ estável, uma varredura respondida só com `404` ou com a página inicial da SPA) vai para a seção **Para ciência**, sem votos, seja qual for a severidade. O que é da própria plataforma (refazer a varredura de CVEs, ajustar a contagem de erros dos _logs_, instalar um _plugin_ no SonarQube) nunca vira tarefa da equipe.

![Insights e achados de uma aplicação]({{ site.baseurl }}/assets/img/sentinel/11.png)

Na seção **Para ciência** ficam as observações que não pedem ação, numa linha cada, com a aplicação e a evidência. No exemplo, uma varredura de _scanners_ em busca de `.env` e `.git/config` recebeu `200`, mas com o mesmo tamanho da página inicial: era a SPA respondendo, sem vazamento.

![Seção Para ciência]({{ site.baseurl }}/assets/img/sentinel/20.png)

Cada item de **Continua em aberto** vindo de uma fonte de eventos (_logs_, Sentry, Google Play) mostra a data da última ocorrência. O item que parou no meio do período (sem ocorrência nas últimas 48 horas) sai das pendências e vai para **Para ciência**, como "Parou em DD/MM", e volta como novidade se reaparecer. Uma novidade que repete um item já em aberto (o mesmo problema, com outras palavras ou somando outra aplicação) segue como o item em aberto, com o identificador dele, em vez de aparecer duas vezes.

Quando várias aplicações do mesmo _boilerplate_ repetem o mesmo problema (os mesmos _hotspots_ de `Dockerfile`, a mesma varredura, a mesma cobertura zerada), ele aparece uma vez só, na seção **projeto inteiro**, com a ação que resolve para todas. Cada achado tem um identificador curto (`ref`), que se mantém de um relatório para o outro enquanto o problema for o mesmo, ainda que descrito com outras palavras: o modelo recebe a lista do que já foi relatado e reconhece a repetição. A seção **Continua em aberto** traz o que já foi relatado antes e segue sem ação, com a severidade, a aplicação, a categoria, a fonte e a data em que o item apareceu pela primeira vez:

![Seção Continua em aberto]({{ site.baseurl }}/assets/img/sentinel/19.png)

O **Resumo do período** fecha com os números de cada aplicação: estágios, código, _logs_, erros, CVEs, qualidade (com as notas do SonarQube e a proporção de linguagens) e uso. Cada estágio aparece com um selo `[estágio | situação]` (azul com foguete quando a plataforma implanta, laranja com servidor quando é um Releaser; situação saudável, não verificado ou com serviços fora do ar), a versão no ar com a data e a última verificação.

![Resumo do período: estágios, código e logs de uma aplicação]({{ site.baseurl }}/assets/img/sentinel/12.png)

Quando uma fonte não trouxe nada para a aplicação, o cartão diz o motivo: aplicação sem projeto no SonarQube, sem site no Matomo, _logs_ indisponíveis naquela execução e assim por diante. Uma aplicação do projeto que ficou de fora do relatório inteiro (sem estágio implantado e sem dados em nenhuma fonte) aparece em **Para ciência**, com o motivo. Todas as datas e horas do relatório estão no horário de Brasília.

O rodapé de cada relatório informa o provedor, o modelo, os _tokens_ consumidos e o custo estimado, e lembra que o conteúdo foi gerado por IA e exige revisão humana.

![Rodapé do relatório]({{ site.baseurl }}/assets/img/sentinel/22.png)

## Retorno: útil ou ruído {#feedback}

Cada achado traz os links **útil** e **ruído**. O voto é individual e serve a dois fins: medir a qualidade da análise e silenciar o que não interessa. Um achado marcado como **ruído** não volta nos próximos relatórios daquele projeto, nem como novidade nem como pendência, mesmo que reapareça descrito de outro jeito. Marcar como **útil** reverte um voto de ruído anterior. Os links abrem o _dashboard_ e só gravam o voto com a pessoa logada nele, naquele navegador.

Quem tria os relatórios com um assistente de IA pode votar em lote pelo [MCP do Dashboard]({{ site.baseurl }}/docs/mcp/io/#sentinel), com um **veredito** e um motivo em uma linha. O veredito separa o achado certo do que acertou o problema e errou a ação, que o voto útil/ruído junta:

| Veredito | Quando | Voto |
| --- | --- | --- |
| `ok` | Procede e a ação serve | útil |
| `wrong_action` | O problema existe, mas a ação sugerida não serve como escrita | útil |
| `partial` | Parte procede, parte já estava resolvida ou não se aplica | útil |
| `noise` | Falso positivo, dado mal lido ou observação sem ação | ruído |
| `stale` | Era verdade antes, mas não no momento do relatório | nenhum (não silencia) |
| `unverified` | Não foi possível conferir | nenhum (não silencia) |

A triagem volta para a Sentinela. A cada voto, a plataforma guarda o veredito, o motivo e um resumo do achado (título, aplicação, fonte, evidência e ação). Na execução seguinte, o modelo recebe isso junto da lista do que já foi relatado:

- o **ruído** é reconhecido mesmo que o problema reapareça descrito com outras palavras, e não volta;
- nos achados marcados como `wrong_action` ou `partial`, o modelo lê o motivo e não repete a ação condenada nem a parte que não se aplica.

Por isso, vale escrever o motivo como orientação: em vez de "ação errada", "o erro vem do WebView do aparelho; a ação certa é registrar a versão mínima do Android na ficha". Votos em prévias também contam.

## Privacidade e responsabilidade {#privacy}

- **Nada é executado.** A Sentinela não altera aplicações, repositórios nem servidores.
- **Segredos nunca chegam ao provedor.** Senhas, chaves e _tokens_ são removidos do pacote antes do envio, inclusive os que aparecem em _logs_ e em linhas de comando.
- **Dados pessoais são pseudonimizados.** Endereços IP públicos e e-mails viram marcadores (`IP#C`, `EMAIL#A`) antes da análise e só são reidratados no relatório final, que a equipe lê. Endereços internos (redes privadas e loopback) ficam como estão, e uma verificação final mascara qualquer IP público ou e-mail que tenha sobrado antes do envio ao modelo.
- **Ninguém é avaliado.** Nenhum achado nomeia autor de _commit_ nem mede produtividade individual; o pacote de código vai sem autores.
- **É IA.** O relatório pode conter erros, exagerar ou minimizar um risco, e exige revisão humana antes de qualquer decisão.
- **A chave é de quem configura.** Cifrada, nunca exibida de novo e apagada se a pessoa deixar de ser arquiteta do projeto (os demais arquitetos são avisados por e-mail) ou quando o projeto é arquivado. Outro arquiteto pode sobrescrevê-la a qualquer momento.

## Perguntas frequentes {#faq}

**Uma aplicação não aparece no relatório.** Entram as aplicações com algum estágio implantado (no _cluster_ da plataforma ou reportado pelo [Releaser]({{ site.baseurl }}/docs/releaser#report)) ou com _tag_ de estágio no GitLab e também as aplicações ativas sem estágio na plataforma, como os aplicativos nativos para Android e iOS, desde que alguma fonte traga dado no período: Sentry, Matomo, SonarQube ou GitLab. Uma aplicação ativa sem estágio e sem dado em nenhuma fonte fica de fora, sem aviso. Aplicações sem achado e sem _insight_ não ganham seção de achados, mas aparecem no resumo do período.

**O relatório diário não chegou.** No diário, o e-mail só sai quando há novidade; o histórico registra a execução mesmo assim. O semanal é sempre enviado.

**A chave expirou ou foi revogada.** A próxima execução falha, o estado na aba Sobre muda para "Chave inválida" e o projeto deixa de ser analisado até um arquiteto reconfigurar.

**Os créditos acabaram.** A execução é adiada para o dia seguinte e o relatório traz o aviso; nada é perdido.

**Quanto custa?** No GPU Server da Embrapa, nada. Num provedor externo, o custo depende do modelo e do tamanho do projeto; o rodapé e o histórico mostram a estimativa de cada relatório e a aba Sobre, o acumulado. Um projeto de oito aplicações analisado semanalmente com um modelo de porte médio fica na casa de alguns centavos de dólar por relatório.

**Quero voltar atrás.** **Desativar** apaga a configuração e a chave e mantém o histórico. Arquivar o projeto apaga tudo.

**Onde fica a cópia em Markdown?** No repositório `io-doc` do projeto, em `06-Support/Sentinel/<ano>/<data>-weekly.md` ou `-daily.md`, com _front matter_ pensado para servir de insumo a agentes de IA e continuar legível para pessoas.
