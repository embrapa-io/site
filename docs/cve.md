---
layout: page
title: CVEs Críticos
subtitle: Alertas de vulnerabilidades que estão sendo exploradas na internet e não exigem login.
---

<iframe width="730" height="410" src="https://www.youtube.com/embed/2AJF_TLKJRY" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

A plataforma **Embrapa I/O** varre toda hora as imagens em execução nos _clusters_ em busca de vulnerabilidades conhecidas (CVEs) com o **Trivy**, e o resultado aparece no diálogo de [monitoramento da _build_]({{ site.baseurl }}/docs/health). Só que a maioria das CVEs `HIGH` e `CRITICAL` que o Trivy encontra nunca foi explorada por ninguém, e um aviso a cada uma delas só ensina a equipe a ignorar avisos.

O **alerta de vulnerabilidades em exploração ativa** faz o oposto: cruza o que o Trivy encontrou com catálogos públicos de falhas **que já estão sendo exploradas** e só se manifesta quando há algo que exige ação. Se chegou um alerta, ele merece atenção.

> **Atenção!** O alerta vale para todos os estágios, inclusive `alpha` e `beta`. Eles têm o mesmo tratamento de `release`, porque também são porta de entrada para a infraestrutura e podem guardar dados sigilosos.

## De onde vem a informação {#sources}

A fonte é o [CIRCL Vulnerability-Lookup](https://vulnerability.circl.lu), serviço aberto do CERT de Luxemburgo, que reúne vários **catálogos de vulnerabilidades exploradas** (_KEV_, de _Known Exploited Vulnerabilities_), cada um com o seu mantenedor:

| Catálogo | O que é |
|---|---|
| **CISA** | Catálogo oficial do governo dos EUA, com exploração confirmada |
| **Shadowserver** | Observações de _honeypots_ |
| **ENISA** | Rede de CSIRTs da União Europeia |
| **CIRCL** | Catálogo do próprio CIRCL |
| **Previdian** | Catálogo de terceiros, mais amplo |

Os catálogos são baixados a cada 6 horas. Se o CIRCL estiver fora do ar, a plataforma recorre ao catálogo da CISA.

**Não existe lista mantida pela Embrapa.** Uma lista curada à mão cobriria o dia zero com textos prontos, mas dependeria de alguém lembrar de incluir cada falha, e ferramenta de segurança que depende de uma pessoa deixa de funcionar quando essa pessoa não está. Por isso a decisão é confiar em catálogos públicos e medir quanto confiar em cada um (veja a próxima seção).

## Índice de confiabilidade e níveis {#index}

Os catálogos não são igualmente confiáveis, e a CISA, por exemplo, costuma demorar a incluir falhas recentes. Por isso a plataforma calcula, para cada CVE, um **índice de confiabilidade** de 0 a 100%, de forma determinística (sem inteligência artificial). O índice leva em conta:

- **A qualidade de cada catálogo**, pela nota que o próprio CIRCL publica a partir de critérios como comprovar, situar, antecipar e manter a informação;
- **O que o catálogo afirma**, de uma simples varredura em massa até comprometimento confirmado, e quão segura ele diz estar disso;
- **Quantas fontes independentes sustentam a mesma CVE.** Catálogos que apenas copiam outro não contam duas vezes.

O índice vira um **nível de urgência**:

| Índice | Nível | Leitura | Prazo sugerido |
|---|---|---|---|
| menos de 25% | Em observação | Sem e-mail e fora da caixa de exploração ativa; a CVE segue na lista comum de vulnerabilidades da _build_ | — |
| 25% a menos de 50% | **Alta** | Programe a correção. | Até 7 dias |
| 50% a menos de 75% | **Crítica** | Corrija hoje. | Até 24 horas |
| 75% ou mais | **Emergencial** | Corrija agora. Tirar o estágio do ar é uma opção legítima até a correção. | Imediato |

### Exemplo: PHP2Shell {#example}

Em 22/10/2026, a falha PHP2Shell (CVE-2026-109618 e CVE-2026-109619, no PHP) já constava como explorada no catálogo Previdian, que registrava exploração bem-sucedida, mas ainda não estava no da CISA. Apoiada por **uma única fonte**, de nota baixa, o índice foi de cerca de **34%**: nível **Alta**. O alerta saiu, pedindo para programar a correção.

Quando a CISA incluiu a mesma CVE, passou a haver duas fontes independentes e o índice subiu para cerca de **60%**: nível **Crítica**. A equipe recebeu na hora um novo alerta, agora dizendo "Corrija hoje".

O alerta mostra sempre o nível, o índice e a leitura das fontes, por exemplo: "**Alta (34%)**: 1 fonte independente (Previdian) relata exploração bem-sucedida".

## Quando o alerta é enviado {#criteria}

Um alerta só é gerado quando todas as condições abaixo são verdadeiras ao mesmo tempo:

1. O nível é **Alta** ou superior (índice de 25% ou mais);
2. A falha pode ser explorada **pela rede** (`AV:N` no vetor CVSS) e **sem nenhum privilégio** (`PR:N`), isto é, por qualquer pessoa na internet, sem login;
3. A exploração **não depende de ação de um usuário** (`UI:N`), como abrir uma página ou um arquivo. Por isso falhas de navegador embutido (Chromium do Puppeteer ou do Playwright, por exemplo) não entram;
4. A falha tem **impacto alto no sigilo ou na integridade** dos dados (`C:H` ou `I:H` no CVSS 3.1; `VC:H` ou `VI:H` no 4.0). Falhas que apenas derrubam o serviço não entram.

Pacotes de _kernel_ (`linux`, `kernel`) encontrados na imagem também ficam de fora: o contêiner usa o _kernel_ do servidor, e não o que vem na imagem.

Falhas que exigem acesso local ou uma conta autenticada não entram, por mais graves que sejam. Elas continuam na lista comum de vulnerabilidades da _build_.

A mensagem é montada em português a partir de dados estruturados (vetor CVSS, tipo de falha, sinal do catálogo e versões do Trivy), sem tradução automática. A descrição original, em inglês, vai no fim de cada item, com o link para o registro da CVE.

## Quem recebe {#recipients}

**Todos os membros da equipe do projeto que têm conta no Embrapa I/O** (arquitetos, desenvolvedores e demais membros), e não só os mantenedores, porque quem reconhece a urgência muitas vezes é o técnico de TI que é apenas membro da equipe. A conta é criada no primeiro acesso ao _dashboard_, com o aceite dos termos: quem está na equipe mas nunca acessou **não recebe**. Cada pessoa recebe **um único e-mail por ciclo**, agrupado por CVE e ordenado pelo nível mais alto. Dentro de cada CVE, cada _build_ aparece no formato `projeto/app@estágio • serviços`, com o servidor onde roda, a data da última varredura e a ação indicada. O rodapé traz o link para esta página.

![E-mail de alerta: cabeçalho, metadados e a CVE com nível, fontes, risco e registro]({{ site.baseurl }}/assets/img/cve/04.png)

![E-mail de alerta: builds afetadas, cada uma com a ação proposta e o link para o dashboard]({{ site.baseurl }}/assets/img/cve/05.png)

As imagens desta página usam **dados fictícios**, de um ambiente de teste.

Como qualquer pessoa da equipe pode corrigir a falha, **não há descadastro**: para deixar de receber, é preciso sair da equipe do projeto.

Uma cópia resumida, agrupada por projeto, vai também para o _space_ de alertas críticos dos administradores da plataforma, que acompanham o que as equipes recebem.

## Repetição, mudança de nível e encerramento {#cycle}

| Situação | E-mail |
|---|---|
| A _build_ passa a ser afetada, ou a CVE entra em um catálogo, com nível Alta ou superior | **Alerta imediato** |
| O nível **sobe** (por exemplo, de Alta para Crítica porque outro catálogo incluiu a CVE) | **Alerta imediato**, na hora |
| O nível se mantém e a _build_ continua afetada | **Lembrete**: Emergencial a cada 12 horas, Crítica a cada 24 horas e Alta a cada 7 dias |
| O nível **desce** (por exemplo, um catálogo retirou a entrada) | Nenhum; só muda o ritmo dos lembretes |
| A CVE some em **todas** as _builds_ afetadas do projeto | **Encerrado**, um e-mail por CVE e projeto |

Sobre o "Encerrado":

- Só é enviado se a situação chegou a **Crítica** ou **Emergencial**. Em casos de nível Alta, não há e-mail próprio: o encerramento aparece como uma linha no e-mail de alerta do projeto que sair no mesmo ciclo, se houver, e na linha "Corrigidas desde o último relatório" da [Sentinela]({{ site.baseurl }}/docs/sentinel), quando o projeto a tem;
- Só vale quando a varredura da _build_ é **recente** e a CVE não aparece mais. Uma _build_ que não foi varrida (parada, sem contato ou com varredura que falhou) **nunca** é tratada como resolvida;
- O e-mail informa o **motivo** do encerramento (veja a próxima seção);
- Tudo o que vence na mesma hora (novos alertas, mudanças de nível, lembretes e encerramentos) vai junto no mesmo e-mail.

### Quando o alerta sai sozinho {#auto-close}

O alerta só vale para _build_ **no ar**. Se a _build_ deixa de estar no ar, os itens dela saem da caixa de exploração ativa e o episódio é encerrado, sem que a falha tenha sido corrigida. Uma _build_ é considerada no ar quando:

- **_Build_ da plataforma:** o _status_ do _deploy_ não é `INACTIVATED`, `UNDEPLOYING` nem `REMOVING`;
- **Plataforma e Releaser:** a saúde mais recente tem ao menos um serviço em execução (`running`);
- **Releaser:** o último contato do servidor foi há no máximo **7 dias**.

Cada encerramento registra o motivo, que aparece no e-mail "Encerrado":

| Motivo | Significado | E-mail |
|---|---|---|
| **Corrigida** (`fixed`) | A CVE não aparece mais na varredura recente da _build_ | **Encerrado**, se chegou a Crítica ou Emergencial |
| **Desativada** (`deactivated`) | A _build_ foi desativada ou parada, e nenhum serviço está em execução | **Encerrado**, se chegou a Crítica ou Emergencial, dizendo que a _build_ saiu do ar |
| **Sem contato** (`unreachable`) | O servidor do Releaser está há mais de 7 dias sem contato | Nenhum; só uma linha no _space_ de alertas dos administradores |

> **Atenção!** Sair do ar não é o mesmo que estar corrigida. Se a _build_ voltar a rodar com a falha, o alerta recomeça como um episódio novo.

## O que fazer {#actions}

Cada item do alerta traz a ação indicada para aquela _build_, escolhida por regras fixas, na ordem a seguir. O que importa é **onde a _build_ roda**.

### _Build_ em _cluster_ compartilhado {#cluster}

| Situação | Ação |
|---|---|
| **Não há** versão corrigida e a _build_ não é atualizada há mais de 6 meses | **Tire do ar**, com _backup_ antes. Uma _build_ esquecida no ar é exatamente a porta de entrada que se quer fechar. Se há versão corrigida, vale atualizar, mesmo em _build_ antiga: aplicações de prateleira (n8n, WordPress) costumam receber só o _restart_ com atualização das imagens, e nunca um _deploy_ |
| **Não há** versão corrigida e o nível é Alta | Restrinja o acesso ou tire do ar os estágios que não são de produção (`alpha` e `beta`) |
| **Não há** versão corrigida e o nível é Crítica ou Emergencial | Recomenda-se **tirar o estágio do ar** até haver correção: faça um **Backup** e depois **Desativar**. Manter no ar é uma decisão consciente da equipe |
| Há versão corrigida e a falha está em uma **dependência da aplicação** (`npm`, `composer`, `pip`, `gem`, binário Go, `jar`…) | **Atualize a dependência no código** (do pacote e versão instalada para a corrigida, no arquivo de _lock_ indicado no item) e **gere uma nova _tag_**. **Reiniciar não corrige**, porque a dependência vem do código da aplicação, e não da imagem |
| Há versão corrigida, mas a versão está **fixada** no `Dockerfile` ou no `docker-compose.yml` (versão exata ou _digest_) | Suba a versão fixada para a corrigida no repositório e gere uma nova _tag_ |
| Há versão corrigida e a imagem é `latest` ou está **sem _tag_** (ou o serviço é `build:` sobre uma base `latest`) | **Fixe antes de atualizar.** Reiniciar com atualização pode saltar de versão maior e, em banco de dados, até tornar o volume ilegível. No `docker-compose.yml` ou no `Dockerfile`, fixe a **versão maior** em uso (por exemplo, `postgres:16`, e não `postgres:latest`), gere uma nova _tag_ e só então atualize as imagens |
| Há versão corrigida e a imagem é _floating_ parcial (`8.3-apache`, sem a versão exata), ou o serviço é `build:` sobre uma base assim | No _dashboard_, abra a _build_, clique em **Reiniciar** e marque **Atualizar imagens** |

Se um alerta Emergencial continuar sem correção, ele volta a cada 12 horas dizendo: "Ainda vulnerável. Se não for possível corrigir agora, tire o estágio do ar."

### _Build_ implantada pelo Releaser {#releaser}

O _dashboard_ não alcança os servidores que usam o [Releaser]({{ site.baseurl }}/docs/releaser), por desenho. As regras da tabela acima para _build_ antiga, sem versão corrigida, dependência da aplicação, versão fixada e `latest` ou sem _tag_ valem também aqui, inclusive a de **atualizar a dependência no código e gerar uma nova _tag_**, porque o _restart_ não a corrige. Na última, em vez do **Reiniciar** do _dashboard_, o alerta traz o comando equivalente, a executar no servidor indicado:

```bash
io restart <projeto>/<app>@<estágio> --upgrade
```

A opção `--upgrade` renova as imagens, reconstrói os serviços `build:` e reinicia a _stack_. Quando a imagem é `latest` ou está sem _tag_, o alerta pede primeiro para fixar a versão maior no `docker-compose.yaml` e gerar uma nova _tag_; depois do _deploy_ pelo Releaser, vem o mesmo `io restart --upgrade`.

Para distinguir versão fixada, `latest` e imagem sem _tag_, a plataforma precisa saber a imagem de cada serviço, que o Releaser informa a partir da versão `1.26.10-18`. Com um Releaser anterior, toda vulnerabilidade de imagem cai no `io restart --upgrade`: [atualize o Releaser]({{ site.baseurl }}/docs/releaser#update) para receber a orientação completa.

Quando a ação é tirar do ar, o alerta traz também o comando:

```bash
io stop <projeto>/<app>@<estágio>
```

O comando `io restart --upgrade` existe a partir do Releaser `1.26.10-10`. Se o Releaser daquele servidor for de uma versão anterior, o alerta traz o caminho manual (`docker pull` e `io deploy --force`) e a sugestão de [atualizar o Releaser]({{ site.baseurl }}/docs/releaser#update). Se o servidor está há mais de 24 horas sem contato, o alerta sai mesmo assim, avisando a data do último dado de vulnerabilidades. Passados 7 dias sem contato, o alerta é encerrado (veja [Quando o alerta sai sozinho](#auto-close)).

### Pedir ajuda à Sentinela {#sentinel}

Quando o projeto tem a [Sentinela]({{ site.baseurl }}/docs/sentinel) configurada e ativa, o e-mail traz o botão **Pedir à Sentinela uma checagem no código**, que abre no _dashboard_ o diálogo da Sentinela do projeto, de onde se pede a execução. Nada é executado só por abrir o link.

### A plataforma nunca derruba nada sozinha {#never}

Toda ação é **proposta** pela plataforma e **executada pela equipe**. Nenhuma _build_ é parada, reiniciada ou atualizada automaticamente por causa de um alerta. Isso vale inclusive para o nível Emergencial: tirar do ar é uma recomendação, nunca uma ação automática.

## Correção com apoio de agentes de IA (MCP) {#mcp}

O [MCP do _dashboard_]({{ site.baseurl }}/docs/mcp/io) tem a ferramenta `list_critical_cves` e o _prompt_ guiado `fix_critical_cves`, que reúnem em uma só consulta as _builds_ com alerta ativo dos seus projetos: nível, índice, pacote, versão instalada e corrigida, tipo do pacote (sistema ou dependência da aplicação), arquivo de _lock_ afetado, classificação da imagem, ação indicada, repositório e a versão implantada. Com isso, um agente de IA (Claude, Gemini, Copilot, Cursor…) pode ler o código na **versão que está no ar** e propor a correção _build_ a _build_.

Um exemplo de pergunta:

```
Verifique os alertas de CVEs críticos em meus projetos e me oriente em cada um como agir.
```

Para cada alerta, o agente:

1. Lista as _builds_ afetadas, da mais urgente para a menos;
2. Lê o repositório da _build_ na versão implantada, para saber onde a dependência ou a imagem é declarada;
3. Propõe a correção conforme a [tabela de ações](#actions): atualizar a dependência e gerar _tag_, fixar a versão maior antes de atualizar, subir a versão fixada ou reiniciar com atualização das imagens;
4. Aponta, quando for o caso, que a opção mais prudente é tirar o estágio do ar até haver correção.

> **Atenção!** O agente **nunca altera nada sem a sua confirmação**: nem o código, nem a _tag_, nem a _build_. Ele propõe, mostra o que mudaria e espera o seu "pode fazer". Como em todo alerta, a decisão e a execução são da equipe.

## Onde mais as vulnerabilidades aparecem {#where}

O alerta, o _dashboard_ e a Sentinela leem **o mesmo conjunto** de vulnerabilidades em exploração ativa, então os três sempre concordam:

- **Dashboard:** uma caixa **Vulnerabilidades em exploração ativa** no topo do diálogo de vulnerabilidades da _build_, com nível, índice, pacote, versão instalada e corrigida, a ação indicada e o link para esta página. Essas CVEs saem da lista comum logo abaixo, para não aparecerem duas vezes. O ícone `crisis_alert` pulsa na linha do serviço, no _card_ da aplicação e como _badge_ no _card_ do projeto, em laranja para o nível Alta e em vermelho para Crítica e Emergencial. Os projetos com alerta ativo ficam no topo da lista, numa faixa própria, **Precisam de atenção imediata**, qualquer que seja o filtro;

  ![Lista de projetos com a faixa "Precisam de atenção imediata" no topo]({{ site.baseurl }}/assets/img/cve/01.png)

  ![Health Check da build, com o ícone na linha do serviço e o resumo no rodapé]({{ site.baseurl }}/assets/img/cve/02.png)

  ![Diálogo de vulnerabilidades com a caixa "Vulnerabilidades em exploração ativa" no topo]({{ site.baseurl }}/assets/img/cve/03.png)

- **Sentinela:** os relatórios diário e semanal trazem, antes de qualquer outro achado, uma seção própria com o mesmo título, com nível, índice, há quanto tempo o primeiro alerta foi enviado, quantos lembretes já saíram e a ação indicada. A seção é montada a partir dos dados, não pelo modelo de IA, que não pode reescrevê-la nem rebaixar a severidade. Essas CVEs saem da seção comum de vulnerabilidades, e as corrigidas na semana aparecem numa linha à parte;
- **MCP:** as ferramentas `build_info` e `get_build_health` do [MCP do _dashboard_]({{ site.baseurl }}/docs/mcp/io) trazem o campo `exploited`, e `list_critical_cves` lista todas as _builds_ com alerta ativo (veja [Correção com apoio de agentes de IA](#mcp)).

## Perguntas frequentes {#faq}

**Recebi um alerta, mas minha aplicação não usa o trecho vulnerável.** O Trivy sabe que o pacote está na imagem, mas não se o seu código usa o caminho da falha. Mesmo assim, atualizar custa pouco e o alerta é sobre exposição pela internet: corrija. Se tiver dúvida, peça uma checagem à Sentinela.

**O Trivy acusou a versão errada.** Acontece, por exemplo, quando um `ENV PHP_VERSION` no `Dockerfile` ficou desatualizado em relação ao que a imagem realmente instala. Corrija a variável.

**A CVE deixou de aparecer sem que eu fizesse nada.** Um catálogo pode ter retirado a entrada, o que reduz o nível. Se a CVE some do _dashboard_ mas a _build_ não foi varrida recentemente, ela **não** é considerada resolvida.

**Quem recebe os alertas?** Todos os membros da equipe do projeto que têm conta no **Embrapa I/O** (a conta é criada no primeiro acesso à plataforma). Como a falha pode ser corrigida por qualquer pessoa da equipe, não há opção de descadastro: para deixar de receber, é preciso sair da equipe do projeto.
