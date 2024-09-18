---
layout: page
title: Orientações
subtitle: O que saber antes de começar?
---

Antes de iniciar o projeto de desenvolvimento de um novo ativo digital agropecuário, é importante atentar-se a algumas orientações e diretrizes. Respeitá-las poderá mitigar a necessidade de ajustes e refatorações quando da qualificação e publicação do produto de software.

1. [Evite a fragmentação de ativos digitais](#fragmentation);
2. [Busque parceiros para o desenvolvimento e sustentação](#partner);
3. [Respeite o Guia de Identidade Visual e Uso da Marca](#identity);
4. [Tenha muita atenção no tratamento de dados pessoais](#lgpd);
5. [Não se esqueça da documentação técnica](#docs);
6. [Evite _marketplaces_ de terceiros](#marketplaces);
7. [Defina o nível de maturidade a ser alcançado](#trl);
8. [Registre o ativo digital no INPI](#inpi);

### 1. Avalie se faz sentido realmente um novo ativo digital {#fragmentation}

Sendo a Embrapa uma instituição de pesquisa, é nosso papel desenvolver soluções inovadoras para problemas da agropecuária brasileira. Entretanto, uma vez que estas soluções nascem a partir de ideias de grupos de pesquisa autônomos, somos de certa forma incentivados a criar soluções independentes com foco em resolver o problema em questão. Ocorre que, muitas vezes, tais soluções poderiam agregar valor a produtos da Empresa que já estão lançados para o público (ou mesmo que ainda estejam em desenvolvimento). Diversas soluções digitais da Embrapa, até mesmo por seu domínio comum no agro, tendem a ser complementares.

Sempre que optamos por desenvolver novos produtos ao invés de complementar produtos existentes, estamos ampliando a "**fragmentação**" de soluções tecnológicas da Empresa. Isso pode afetar negativamente a imagem da Embrapa para seu público final, uma vez que para resolver problemas correlatos para uma mesma cadeia de produção agropecuária, o produtor rural ou técnico agropecuário terá agora que utilizar diversos softwares desacoplados que não compartilham informações entre si.

Assim, sempre que as equipes de desenvolvimento de ativos digitais forem acionadas para iniciar a produção de uma nova solução, é fundamental que sejam buscadas soluções semelhantes no catálogo dos ecossistemas digitais agropecuários em que a problemática está inserida. Nesta prospecção deve-se questionar se não existem soluções neste catálogo que poderiam ser complementadas com novas funcionalidades para resolver a problemática. Desta forma, agrega-se valor ao produto existente ao mesmo tempo em que é aproveitado o público cativo desta solução original.

Em termos práticos, sugere-se que seja criada, por meio de uma nova [rodada evolutiva]({{ site.baseurl }}/docs/introduction#round), uma nova [macro-versão]({{ site.baseurl }}/docs/introduction#version) do ativo digital existente. Como exemplo prático, temos o estudo de caso da solução **PlanePasto**, uma solução que foi inicialmente idealizada e implementada pela [Universidade Federal de São João del-Rei (UFSJ)](https://ufsj.edu.br). Em 2023, o grupo de pesquisa em melhoramento de cultivares de pastagens tropicais da Embrapa foi procurada por professores da UFSJ para o desenvolvimento conjunto de uma nova versão desta solução que pudesse agregar resultados de pesquisa científica da Empresa. Ao invés de uma solução autônoma, foi iniciada uma nova rodada evolutiva do aplicativo Pasto Certo, então na [versão 3.0](https://www.infoteca.cnptia.embrapa.br/infoteca/handle/doc/1133853), que resultou no desenvolvimento do [Pasto Certo 4.0](https://www.infoteca.cnptia.embrapa.br/handle/doc/1166788) com uma nova funcionalidade, denominada "**Dimensionar Piquetes**".

![Funcionalidade 'Dimensionar Piquetes' do Pasto Certo 4.0]({{ site.baseurl }}/assets/img/guidelines/20240917154158.png)

> **Atenção!** Para lidar com questões de propriedade intelectual que possam ser impactadas pelas decisões acima, considere utilizar estratégias tal como o uso de "_micro-frontends_", que é descrita na [seção sobre integração de ativos digitais]({{ site.baseurl }}/docs/integration).

A mitigação da fragmentação traz também diversos outros benefícios, tal como a otimização das equipes de desenvolvimento, a facilitação da sustentação e a maior entrega de valor pelo produto que, por sua vez, poderá facilitar sua transferência para parceiros da iniciativa privada.

### 2. Busca antecipada de parceiros co-titulares {#partner}

É desafiador conseguir articular e provisionar os recursos humanos e financeiros para o desenvolvimento de um ativo digital. Sua natureza complexa demanda o envolvimento de especialistas em uma equipe técnica multidisciplinar altamente qualificada. Entretanto, mais desafiador ainda é sua **sustentação** ao longo de todo seu clico de vida.

A sustentação de um software envolve atividades como manutenções corretivas e evolutivas, monitoramento, segurança, suporte ao usuário, _backup_ e recuperação, avaliação de desempenho e qualidade, dentre muitas outras. Estas atividades precisam ser realizadas durante toda a vida do ativo digital, desde de sua publicação inicial até o término de seu uso.

Sabemos que as equipes técnicas da Embrapa são limitadas e, por conta disso, é fundamental adotarmos estratégias que permitam à Empresa otimizar estas equipes de forma que possam estar disponíveis para responder rapidamente a novas demandas da agropecuária brasileira.

Assim, sugere-se que, de forma geral, os ativos desenvolvidos tenham **foco na transferência tecnológica**, buscando parceiros que possam auxiliar na sustentação e ampliação da entrega de valor para os usuários finais. Para tal, recomenda-se a busca ativa e antecipada de parceiros antes mesmo do início de sua concepção, de forma que tais entes externos possam contribuir com _inputs_ intelectuais e com o ônus do desenvolvimento, tornando-se co-titulares na propriedade intelectual do ativo.

> **Atenção!** Para que um ativo digital seja qualificado em estágio de maturidade TRL/MRL 8 ou 9 é obrigatório que haja um contrato com alguma empresa da iniciativa privada que garanta sua sustentação ou que ele esteja inserido em um programa social governamental que garanta o provisionamento perene da equipe de desenvolvimento.

É importante que estes parceiros, quando entes da iniciativa privada, tenham interessa na comercialização posterior do ativo ou em utilizá-lo para agregar valor ao seu negócio de alguma forma, havendo um incentivo em monetizar seu uso e, consequentemente, garantir a sustentação ao longo de todo o seu ciclo de vida.

### 3. Guia de Identidade Visual e Uso da Marca Embrapa {#identity}

Desde o início do desenvolvimento do ativo digital, deve-se prezar pelo bom uso da [**Marca Embrapa**](https://ainfo.cnptia.embrapa.br/digital/bitstream/item/203625/1/Manual-de-identidade-visual2.pdf) e pelas diretrizes de identidade visual das interfaces com os usuários. Para orientar neste aspecto, leia o [**Guia de Identidade Visual para Aplicativos Mobile**]({{ site.baseurl }}/assets/pdf/Guia_de_Identidade_Visual_para_Aplicativos_Mobile.pdf), onde estão definidas as diretrizes de uso da Marca nos ativos, paletas de cores, áreas de sangria, formato dos ícones, etc.

> **Atenção!** O respeito às diretrizes de uso da Marca e do Guia de Identidade Visual é objeto de avaliação durante o processo de qualificação do ativo digital e poderá invalidá-lo ou exigir refatoração de sua UX/UI.

Em caso de dúvidas, é possível recorrer ao "[**Guardião da Marca Embrapa**](https://www.embrapa.br/group/intranet/mme/lista-de-guardioes)", que é o empregado na Unidade Descentralizada encarregado de revisar a aplicação do uso da Marca Embrapa e assinatura do Governo Federal ou Instituições Patrocinadoras, Apoiadoras, Parceiras e Coeditora, conforme normas vigentes do [**Manual da Marca Embrapa**](https://www.embrapa.br/group/intranet/manual-da-marca-embrapa-mme).

### 4. Coleta e tratamento de dados pessoais {#lgpd}

Desde sua promulgação em 2018, a [Lei Geral de Proteção de Dados (LGPD)](http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) alterou drasticamente a forma como lidamos com dados pessoais coletados em ativos digitais. Uma série de cuidados são exigidos, que tendem a criar um grande ônus de tratamento deste dados. Assim, deve-se avaliar minuciosamente antes e ao longo do desenvolvimento do ativo digital **se é realmente necessário realizar a coleta de dados pessoais dos usuários**.

Caso este seja de fato um requisito do software, [leia a documentação sobre este tema]({{ site.baseurl }}/docs/lgpd) e antecipe as atividades essenciais para sua viabilização (tal como a homologação pela Assessoria Jurídica dos "Termos de Uso" e "Aviso de Privacidade").

### 5. Documentação técnica dos ativos digitais {#docs}

### 6. Distribuição em _marketplaces_ {#marketplaces}

### 7. Nível de maturidade TRL/MRL a ser atingido {#trl}

### 8. Registro do ativo digital no INPI {#inpi}
