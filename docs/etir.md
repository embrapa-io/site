---
layout: page
title: Relatório semanal à ETIR
subtitle: O que a equipe de resposta a incidentes da Embrapa recebe toda segunda-feira sobre as CVEs em exploração ativa nas builds.
---

Toda segunda-feira, às 7h (horário de Campo Grande), a plataforma **Embrapa I/O** envia à **ETIR** um relatório consolidado das vulnerabilidades mais graves que seguem em aberto nas _builds_ que ela hospeda ou monitora. Esta página explica o que é a ETIR, por que ela recebe o relatório, o que entra nele e o que ele significa para as equipes dos projetos.

## O que é a ETIR {#what}

A **ETIR** (Equipe de Tratamento e Resposta a Incidentes em Redes Computacionais) é a equipe da Embrapa responsável por receber, analisar e responder a incidentes de segurança da informação na rede da empresa. Ela é o ponto de contato da Embrapa com o **CTIR Gov**, o centro do Governo Federal que coordena as equipes de resposta dos órgãos públicos: é a ETIR quem decide se um incidente precisa ser comunicado a ele.

Para a ETIR, saber com antecedência quais sistemas estão expostos a falhas que já estão sendo exploradas na internet faz diferença: ela pode priorizar o monitoramento, reconhecer mais rápido um ataque em andamento e, se for o caso, procurar os responsáveis.

## De onde vêm os dados {#context}

O relatório não é uma análise à parte: ele resume o **alerta de vulnerabilidades em exploração ativa** que as equipes já recebem, descrito em detalhes no capítulo [CVEs Críticos]({{ site.baseurl }}/docs/cve). Em resumo:

1. A plataforma varre toda hora, com o **Trivy**, as imagens em execução nos _clusters_ e nos servidores do [Releaser]({{ site.baseurl }}/docs/releaser), em busca de vulnerabilidades conhecidas (CVEs);
2. Cada CVE encontrada é cruzada com catálogos públicos de **falhas que já estão sendo exploradas** (CISA, Shadowserver, ENISA, CIRCL e outros), reunidos pelo [CIRCL Vulnerability-Lookup](https://vulnerability.circl.lu);
3. Para cada CVE, a plataforma calcula um **índice de confiabilidade** de 0 a 100%, a partir da qualidade dos catálogos, do que eles afirmam e de quantas fontes independentes sustentam a mesma falha. O índice vira um nível de urgência: **Alta** (25% a menos de 50%), **Crítica** (50% a menos de 75%) e **Emergencial** (75% ou mais);
4. Só gera alerta a falha que pode ser explorada **pela internet, sem login e sem ação de um usuário**, com **impacto alto no sigilo ou na integridade** dos dados (no vetor CVSS: `AV:N`, `PR:N`, `UI:N` e `C:H` ou `I:H`);
5. Todos os membros da equipe do projeto recebem o alerta por e-mail, com a ação indicada para cada _build_, e lembretes até a correção.

O relatório à ETIR lê exatamente o mesmo conjunto de dados que o alerta, o _dashboard_ e a [Sentinela]({{ site.baseurl }}/docs/sentinel): os quatro sempre concordam.

## O que entra no relatório {#criteria}

Uma exposição entra no relatório quando:

- a CVE está no nível **Crítica** ou **Emergencial**, isto é, com índice de confiabilidade de **50% ou mais**. O nível **Alta não entra**: com uma única fonte de nota baixa, ele ainda pede só que a equipe programe a correção;
- a _build_ está **no ar** e a varredura mais recente ainda encontra a falha. Uma _build_ recém-implantada e ainda não varrida sai da lista até a próxima varredura: o relatório mostra só exposição confirmada;
- vale para todos os estágios (`alpha`, `beta` e `release`), porque todos são porta de entrada para a infraestrutura.

A **semana** do relatório são os 7 dias anteriores ao envio. As exposições em aberto são as do momento do envio; as encerradas são as da semana.

> **Atenção!** Semana sem nenhuma exposição também gera relatório, curto, dizendo que não há nada em aberto. A falta do e-mail nunca pode ser confundida com "nada a relatar".

## O que o relatório traz {#content}

### Resumo em números {#stats}

No topo, uma linha com: CVEs em aberto, _builds_ em aberto, exposições corrigidas, desativadas e inalcançáveis na semana, quantas estão em alerta há mais de 7 e há mais de 30 dias, e o tempo médio entre o primeiro alerta e a correção (das corrigidas na semana).

![Relatório à ETIR: cabeçalho, resumo em números e a primeira CVE em aberto]({{ site.baseurl }}/assets/img/etir/01.png)

### Exposições em aberto {#open}

**Uma seção por CVE**: cada falha aparece uma única vez, com todas as _builds_ afetadas abaixo dela. A ordem é Emergencial antes de Crítica; no mesmo nível, primeiro a que afeta mais _builds_ e, depois, a que está em alerta há mais tempo.

O cabeçalho de cada CVE traz:

| Campo | O que é |
|---|---|
| **CVE e título** | Identificador, com link para o registro no NVD, pacote e tipo de falha |
| **CVSS** | Nota de gravidade de 0 a 10, com a versão e o vetor resumido (`AV:N/PR:N/UI:N`), que é a prova técnica de "pela internet, sem login". Sem nota publicada ainda: **CVSS pendente** |
| **EPSS** | Probabilidade de a falha ser explorada nos próximos 30 dias, segundo o modelo público [EPSS](https://www.first.org/epss/) |
| **Bases** | Catálogos em que a exploração aparece, o índice de confiabilidade e o nível que resulta deles |
| **Correção** | A versão que corrige o pacote, ou o selo **sem correção** quando o fornecedor ainda não publicou uma |

E, para cada _build_ afetada:

- `project/app@stage` e os serviços (contêineres) com o pacote vulnerável;
- **onde roda:** _cluster_ da plataforma ou servidor do Releaser, com o local de hospedagem: o do cadastro do _cluster_ no [catálogo]({{ site.baseurl }}/resources/clusters) (por exemplo, "GTI, Brasília - DF") ou, no Releaser, o que a sigla do nome do servidor indica (por exemplo, "Nuvem da Embrapa"). É onde a _build_ roda, não a Unidade responsável pelo projeto, que a plataforma não registra: quem responde por ela são os arquitetos, logo abaixo;
- **URLs públicas** registradas na plataforma: subdomínios, subcaminhos, _aliases_ e domínios próprios. Quando não há URL registrada, o que é comum nos servidores do Releaser, o relatório diz "URL pública não registrada na plataforma (pode existir)" e informa o _host_ e o IP;
- **responsáveis:** os arquitetos do projeto com e-mail `@embrapa.br` ou `@colaborador.embrapa.br`. Projeto sem nenhum deles aparece marcado **sem responsável Embrapa**, o que já é um achado por si;
- **em alerta desde** a data do primeiro alerta à equipe, com os dias decorridos e o número de alertas e lembretes já enviados. Mais de 7 e mais de 30 dias ganham destaque.

![Relatório à ETIR: CVEs em aberto, resolvidas na semana e rodapé com o critério]({{ site.baseurl }}/assets/img/etir/02.png)

As imagens desta página usam **dados fictícios**, de um ambiente de teste.

### Resolvidas na semana {#resolved}

Abaixo das abertas, as exposições encerradas nos últimos 7 dias, também por CVE, separadas pelo motivo:

| Motivo | Significado |
|---|---|
| **Corrigida** | A varredura recente da _build_ não encontra mais a CVE. Aparece com o tempo entre o primeiro alerta e a correção |
| **Desativada** | A _build_ saiu do ar **sem correção** (desativada ou parada). Se voltar a rodar com a falha, a exposição volta ao relatório |
| **Inalcançável** | O servidor do Releaser está há mais de 7 dias sem contato: não se sabe se a falha foi corrigida |

### Rodapé {#footer}

O rodapé repete o critério de entrada e o aviso de sigilo, para quem lê o e-mail sem esta página à mão.

## Como ler alguns termos {#terms}

- **CVSS alto não é _zero-day_.** CVSS 9 ou mais indica gravidade. _Zero-day_ é a falha explorada **sem correção disponível**, que no relatório aparece com o selo "sem correção".
- **"Em alerta desde" não é "exposta desde".** A plataforma sabe quando avisou a equipe pela primeira vez, mas não quando a falha entrou no ar. A data pode ser posterior à exposição real, por exemplo quando a CVE entrou num catálogo depois de a _build_ já estar no ar.
- **Índice de confiabilidade não é gravidade.** O índice mede quanto se pode confiar que a falha está sendo explorada, e o CVSS mede o estrago possível. As duas coisas aparecem lado a lado de propósito.

## Quem recebe e sigilo {#recipients}

O relatório vai **por e-mail** para a ETIR (`etir@embrapa.br`), com cópia para a equipe do **Embrapa I/O** (`io@embrapa.br`), que acompanha as exposições junto com ela.

> **Atenção!** O relatório é uma lista de sistemas expostos a falhas em exploração, com URLs e endereços: nas mãos erradas, é um mapa para um atacante. Por isso ele **nunca** vai para um _space_ de chat nem para as equipes dos projetos, e não deve ser repassado a terceiros. As equipes recebem a parte que lhes cabe pelo [alerta]({{ site.baseurl }}/docs/cve#recipients), com a ação indicada para cada _build_.

## O que muda para as equipes {#teams}

Nada no fluxo de correção: o alerta continua chegando a todos os membros da equipe, com a ação indicada, e a correção segue com eles. A plataforma **nunca derruba nada sozinha**, e o relatório não pede providência de rotina à ETIR.

O que muda é a visibilidade: uma CVE **Crítica** ou **Emergencial** que fica em aberto por semanas aparece toda segunda-feira no relatório, com o tempo decorrido desde o primeiro alerta e os responsáveis. A ETIR pode procurar a equipe a qualquer momento, como já faz em qualquer incidente. A forma mais simples de não aparecer no relatório é corrigir a falha ou, enquanto não houver correção, tirar o estágio do ar, como indica o [capítulo de CVEs Críticos]({{ site.baseurl }}/docs/cve#actions).

Para manter os responsáveis corretos, confira se os arquitetos do projeto no _dashboard_ incluem ao menos uma pessoa com e-mail `@embrapa.br` ou `@colaborador.embrapa.br`.

## Perguntas frequentes {#faq}

**Minha build tem uma CVE de nível Alta. Ela vai para a ETIR?** Não. O relatório só traz os níveis Crítica e Emergencial. Se outro catálogo incluir a mesma CVE e o nível subir, a equipe recebe um novo alerta na hora, e a exposição passa a entrar no relatório da segunda-feira seguinte.

**Corrigi a falha ontem. Por que ela ainda está no relatório?** O relatório usa a varredura mais recente. Depois de um novo _deploy_, a _build_ sai das abertas até a próxima varredura e volta só se a falha ainda estiver lá. Corrigida, ela aparece em "Resolvidas na semana".

**Tirei o estágio do ar. Isso conta como corrigido?** Não: aparece como **desativada**, que é diferente de corrigida. Se a _build_ voltar a rodar com a falha, a exposição volta ao relatório.

**Por que o relatório não diz a Unidade do meu projeto?** Porque a plataforma não registra a Unidade responsável por um projeto. O relatório informa onde a _build_ roda (o _cluster_ ou o servidor) e identifica quem responde por ela pelos arquitetos do projeto. Por isso é importante manter no _dashboard_ ao menos um arquiteto com e-mail `@embrapa.br` ou `@colaborador.embrapa.br`.

**Posso receber uma cópia do relatório?** Não. As equipes recebem o alerta das suas _builds_, que traz tudo o que é preciso para corrigir; o relatório consolidado de todos os projetos fica restrito à ETIR e à equipe da plataforma.
