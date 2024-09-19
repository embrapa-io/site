---
layout: page
title: Orientações
subtitle: O que saber antes de começar?
---

Antes de iniciar o projeto de desenvolvimento de um novo **ativo digital agropecuário**, é importante atentar-se a algumas orientações e diretrizes. Respeitá-las poderá mitigar a necessidade de ajustes e refatorações quando da qualificação, transferência e lançamento do produto de software. São elas:

1. [Evite a fragmentação de ativos digitais](#fragmentation);
2. [Formalize o projeto de desenvolvimento no SEG](#seg);
3. [Busque parceiros para o desenvolvimento e sustentação](#partner);
4. [Respeite o Guia de Identidade Visual e Uso da Marca](#identity);
5. [Tenha muita atenção no tratamento de dados pessoais](#lgpd);
6. [Não se esqueça da documentação técnica](#docs);
7. [Evite _marketplaces_ de terceiros](#marketplaces);
8. [Defina o nível de maturidade a ser alcançado](#trl);
9. [Atribua licenças de código aos componentes do ativo](#license); e
10. [Registre o ativo digital no INPI](#inpi).

### 1. Avalie se faz sentido realmente um novo ativo digital {#fragmentation}

Sendo a Embrapa uma instituição de pesquisa, é nosso papel desenvolver soluções inovadoras para problemas da agropecuária brasileira. Entretanto, uma vez que estas soluções nascem a partir de ideias de grupos de pesquisa autônomos, somos de certa forma incentivados a criar soluções independentes, com foco em resolver o problema em questão. Ocorre que, muitas vezes, tais soluções poderiam agregar valor a outros produtos da Empresa, já lançados para o público ou mesmo que ainda estejam em desenvolvimento. Diversas soluções digitais da Embrapa, até mesmo por seu domínio comum no agronegócio, tendem a ser complementares.

Sempre que optamos por desenvolver novos produtos ao invés de complementar produtos existentes, estamos ampliando a "**fragmentação**" de soluções tecnológicas da Empresa. Isso pode afetar negativamente a imagem da Embrapa para seu público final, uma vez que para resolver problemas correlatos para uma mesma cadeia de produção agropecuária, o produtor rural ou técnico agropecuário terá agora que utilizar diversos softwares desacoplados que não compartilham informações entre si, sendo forçado a lidar com um ambiente muitas vezes desnecessariamente mais complexo.

Assim, sempre que as equipes de desenvolvimento de ativos digitais forem acionadas para iniciar a produção de uma nova solução, é fundamental que sejam buscadas tecnologias correlatas no catálogo dos ecossistemas digitais agropecuários em que a problemática está inserida. Nesta prospecção e análise crítica, deve-se questionar se não existem soluções neste catálogo que poderiam ser complementadas com novas funcionalidades para atender à demanda. Desta forma, agrega-se valor ao produto existente ao mesmo tempo em que é aproveitado o engajamento do público cativo desta solução original.

Em termos práticos, sugere-se que seja criada, por meio de uma nova [rodada evolutiva]({{ site.baseurl }}/docs/introduction#round), uma nova [macro-versão]({{ site.baseurl }}/docs/introduction#version) do ativo digital existente. Como exemplo prático, temos o estudo de caso do software **PlanePasto**, uma solução que foi inicialmente idealizada e implementada pela [Universidade Federal de São João del-Rei (UFSJ)](https://ufsj.edu.br). Em 2023, o grupo de pesquisa em melhoramento de cultivares de pastagens tropicais da Embrapa foi procurada por professores da UFSJ para o desenvolvimento conjunto de uma nova versão desta tecnologia, visando agregar resultados de pesquisa científica da Empresa. Ao invés de uma solução autônoma, foi iniciada uma nova rodada evolutiva do aplicativo [Pasto Certo](https://www.pastocerto.com), então na [versão 3.0](https://www.infoteca.cnptia.embrapa.br/infoteca/handle/doc/1133853), que resultou no desenvolvimento do [Pasto Certo 4.0](https://www.infoteca.cnptia.embrapa.br/handle/doc/1166788) com uma nova funcionalidade, denominada "**Dimensionar Piquetes**".

![Funcionalidade 'Dimensionar Piquetes' do Pasto Certo 4.0]({{ site.baseurl }}/assets/img/guidelines/20240917154158.png)

> **Atenção!** Para lidar com questões de propriedade intelectual que possam ser impactadas pelas decisões acima, considere estratégias como o uso de "_micro-frontends_", que é descrita na [seção sobre integração de ativos digitais]({{ site.baseurl }}/docs/integration).

A mitigação da fragmentação traz também diversos outros benefícios, tal como a otimização das equipes de desenvolvimento, a facilitação da sustentação e a maior entrega de valor pelo produto que, por sua vez, poderá facilitar sua transferência para parceiros da iniciativa privada.

### 2. Formalize o projeto de desenvolvimento no SEG {#seg}

O [Sistema Embrapa de Gestão (SEG)](https://www.embrapa.br/documents/32008859/39100403/Sum%C3%A1rio+Executivo+002+-+SEG/86964fe8-f97d-55ff-57ad-ae1898c9ac3c?version=1.0) é o instrumento que estabelece as bases para a gestão do macroprocesso de inovação da Embrapa. Na prática, ele é "materializado" por meio dos softwares [Ideare](https://sistemas.sede.embrapa.br/ideare), [Integro](https://sistemas.sede.embrapa.br/integro) e [Gestec](https://sistemas.sede.embrapa.br/gestec), de acesso restrito aos empregados da Empresa e aos parceiros de outras instituições que participam de projetos da Embrapa.

Ativos digitais agropecuários muitas vezes são desenvolvidos nas Unidades Descentralizadas da Embrapa de forma _ad hoc_, ou seja, sem o formalismo dispendido a outros tipos de tecnologias da Empresa. Com isso, tem-se um catálogo de softwares vasto, fragmentado e, muitas vezes, com produtos de baixa qualidade, que não tiveram o planejamento adequado e o provisionamento a priori de recursos financeiros e humanos para seu desenvolvimento.

Assim, antes de iniciar o projeto, articule e defina uma [equipe de desenvolvimento]({{ site.baseurl }}/docs/squads) e, juntamente com estes pares, faça a previsão de recursos financeiros, monte o cronograma de desenvolvimento e detalhe as atividades do processo. **Esta formalização deve ser feita, preferencialmente, como um novo projeto no Ideare ou, pelo menos, como uma nova atividade incluída em um projeto.**

É importante que as equipes de TI de desenvolvimento de software (arquitetos de solução, engenheiros de software, analistas de requisitos e programadores) aproveitem este momento para negociar com o demandante e a chefia, visando garantir recursos essenciais para o desenvolvimento do ativo digital (tal como, alocação de horas, _workstations_ de desenvolvimento, componentes de hardware, estagiários/bolsistas, fábricas de software, materiais de consumo, etc).

### 3. Busca antecipada de parceiros co-titulares {#partner}

É desafiador conseguir articular e provisionar os recursos humanos e financeiros para o desenvolvimento de um ativo digital. Sua natureza complexa demanda o envolvimento de especialistas em uma equipe técnica multidisciplinar altamente qualificada. Entretanto, mais desafiador ainda é sua **sustentação** ao longo de todo seu clico de vida.

A sustentação de um software envolve atividades como manutenções corretivas e evolutivas, monitoramento, segurança, suporte ao usuário, _backup_ e recuperação, avaliação de desempenho e qualidade, dentre muitas outras. Estas atividades precisam ser realizadas durante toda a vida do ativo digital, desde de sua publicação inicial até o término de seu uso.

Sabemos que as equipes de desenvolvimento de software da Embrapa são escassas e, por conta disso, é fundamental adotarmos estratégias que permitam à Empresa otimizar estes valiosos recursos humanos de forma que possam estar disponíveis para responder rapidamente a novas demandas digitais da agropecuária brasileira.

Assim, sugere-se que, de forma geral, os ativos desenvolvidos tenham **foco na transferência tecnológica**, buscando parceiros da iniciativa privada que possam auxiliar na sustentação e ampliação da entrega de valor para os usuários finais. Para tal, recomenda-se começar a busca ativa destes parceiros antes mesmo do início de sua concepção, de forma que tais entes externos possam contribuir antecipadamente com _inputs_ intelectuais e com o ônus do desenvolvimento, tornando-se co-titulares na propriedade intelectual do ativo.

> **Atenção!** Para que um ativo digital seja qualificado em estágio de maturidade TRL/MRL 8 ou 9 é obrigatório que haja um contrato com alguma empresa da iniciativa privada que garanta sua sustentação ou que ele esteja inserido em um programa governamental que garanta o provisionamento perene da equipe de desenvolvimento.

É importante que estes parceiros, quando entes da iniciativa privada, tenham interesse na comercialização posterior do ativo ou em utilizá-lo para agregar valor ao seu negócio de alguma forma, havendo um incentivo em monetizar seu uso e, consequentemente, garantir a sustentação ao longo de todo o seu ciclo de vida. Para viabilizar a formalização destas parcerias, a Embrapa conta com diversos instrumentos, tais como: Acordo de Cooperação Técnica, Projeto Tipo III, Acordo de Exploração Comercial, Projeto Tipo II, dentre outros.

### 4. Guia de Identidade Visual e Uso da Marca Embrapa {#identity}

Desde o início do desenvolvimento do ativo digital, deve-se prezar pelo bom uso da [**Marca Embrapa**](https://ainfo.cnptia.embrapa.br/digital/bitstream/item/203625/1/Manual-de-identidade-visual2.pdf) e pelas diretrizes de identidade visual das interfaces com o usuário. Para orientar neste aspecto, leia o [**Guia de Identidade Visual para Aplicativos Mobile**]({{ site.baseurl }}/assets/pdf/Guia_de_Identidade_Visual_para_Aplicativos_Mobile.pdf), onde estão definidas as diretrizes de uso da Marca nos ativos, paletas de cores, áreas de sangria, formato dos ícones, etc.

> **Atenção!** O respeito às diretrizes de uso da Marca e do Guia de Identidade Visual é objeto de avaliação durante o processo de qualificação do ativo digital e poderá invalidá-lo ou exigir a refatoração de sua UX/UI.

Em caso de dúvidas, é possível recorrer ao "[**Guardião da Marca Embrapa**](https://www.embrapa.br/group/intranet/mme/lista-de-guardioes)", que é o empregado na Unidade Descentralizada encarregado de revisar a aplicação do uso da Marca Embrapa e assinatura do Governo Federal ou Instituições Patrocinadoras, Apoiadoras, Parceiras e Coeditora, conforme normas vigentes do [**Manual da Marca Embrapa**](https://www.embrapa.br/group/intranet/manual-da-marca-embrapa-mme).

### 5. Coleta e tratamento de dados pessoais {#lgpd}

Desde sua promulgação em 2018, a [Lei Geral de Proteção de Dados (LGPD)](http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) alterou drasticamente a forma como lidamos com dados pessoais coletados em ativos digitais. Uma série de cuidados são exigidos, que tendem a criar um grande ônus de tratamento deste dados. Assim, deve-se avaliar minuciosamente, antes e ao longo do desenvolvimento do ativo digital, **se é realmente necessário realizar a coleta de dados pessoais dos usuários**.

Caso este seja de fato um requisito do software, [leia a documentação sobre este tema]({{ site.baseurl }}/docs/lgpd) e antecipe as atividades essenciais para sua viabilização (tal como a homologação pela Assessoria Jurídica dos "**Termos de Uso**" e "**Aviso de Privacidade**").

De outra forma, caso não haja coleta e tratamento de dados pessoais, disponibilize na interface do ativo (se aplicável) o [aviso de privacidade para aplicativo móvel sem coleta de dados pessoais](https://www.embrapa.br/acessoainformacao/aviso-de-privacidade-para-aplicativo-movel-sem-coleta-de-dados-pessoais).

### 6. Documentação técnica dos ativos digitais {#docs}

A plataforma **Embrapa I/O** implementa diversos mecanismos de apoio à redação e disponibilização de documentação pública e privada para os ativos digitais:

- [Site de informações públicas do projeto]({{ site.baseurl }}/docs/project#web) (baseado no [GitHub Pages](https://pages.github.com));
- [Documentação pública da API]({{ site.baseurl }}/docs/project#api) (baseada no [Swagger](https://swagger.io)); e
- [Repositório de documentação técnica]({{ site.baseurl }}/docs/project#doc) (não pública).

A documentação é uma parte essencial do processo de desenvolvimento de software, pois ajuda a garantir a qualidade, a manutenção, a evolução e a sustentação dos produtos. Portanto, é essencial que as equipes de desenvolvimento não ignorem esta etapa do processo de produção dos ativos digitais agropecuários.

![Big picture da plataforma +Precoce]({{ site.baseurl }}/assets/img/guidelines/design.png)

Vale salientar que, durante o processo de qualificação do ativo digital, será demanda a arquitetura da solução (_big picture_), com a visão geral dos componentes do software, tecnologias utilizadas, como se relacionam, a licença atribuída a cada um e suas interfaces com outros ativos (caso exista). Na figura acima é mostrada, como exemplo, a _big picture_ da arquitetura do ativo digital [+Precoce](https://www.embrapa.br/busca-de-publicacoes/-/publicacao/1112017/projeto-mais-precoce-embrapa-aumentar-a-producao-e-qualidade-dos-bezerros). Outro exemplo é a própria [página de arquitetura da plataforma **Embrapa I/O**]({{ site.baseurl }}/docs/architecture).

### 7. Distribuição em _marketplaces_ {#marketplaces}

Equipes que possuem aplicativos publicados na [Google Play](https://play.google.com/console/) têm recebido alertas sobre o "**requisitos de nível desejado da API**". Este aviso está relacionado a uma mudança na política deste _marketplace_, que agora exige que "[o nível da API do Android tenha no máximo um ano de diferença em relação à versão mais recente](https://support.google.com/googleplay/android-developer/answer/11917020?hl=pt-BR)".

Na prática a Google Play está exigindo que todos os apps disponibilizados tenham pelo menos uma nova _build_ por ano, na qual as bibliotecas básicas do [Android](https://android.com) sejam atualizadas (ainda que não haja outras manutenções corretivas/evolutivas). Isso força os desenvolvedores a, no mínimo, revisitar e atualizar pacotes depreciados, aprimorando a segurança e qualidade do catálogo da Google Play como um todo. A consequência para a não-atualização anual é que estes apps deixem de ser listados para novos usuários (continuando disponíveis para quem já tem ele instalado por tempo indeterminado).

Consequentemente, o efeito prático é um ônus ainda maior para sustentação do ativo (que corrobora com o [assunto tratado anteriormente](#partner)). Assim como a Google Play, outros _marketplaces_ como a [Apple App Store](https://www.apple.com/br/app-store/) possuem políticas semelhantes. Por conta disso, a recomendação é que novos aplicativos, que não tenham parcerias para sua sustentação (ou seja, sejam _Beta Release_ - TRL 7), sejam desenvolvidos no formato de **aplicações web responsivas** — preferencialmente [PWAs (do inglês, _Progressive Web Applications_)](https://web.dev/learn/pwa/progressive-web-apps?hl=pt-br) ou [SPAs (do inglês, _Single-Page Applications_)](https://www.iugu.com/blog/single-page-applications).

> **Atenção!** Caso a disponibilização em _marketplace_ seja realmente o melhor caminho, considere nomear o pacote no padrão `br.embrapa.nome_do_app`. Em muitos casos, tal como na Google Play, este nome não poderá ser alterado posteriormente. Como este nome é utilizado na composição da URL do produto de software no catálogo do _marketplace_, esta decisão tem grande impacto em ferramentas de busca (veja sobre [_Search Engine Optimization - SEO_](https://developers.google.com/search/docs/fundamentals/seo-starter-guide?hl=pt-br) para mais detalhes).

### 8. Nível de maturidade TRL/MRL a ser atingido {#trl}

É necessário que a equipe de desenvolvimento defina o nível de maturidade na [Escala TRL/MRL](https://cloud.cnpgc.embrapa.br/nap/files/2018/08/EscalaTRL-MRL-17Abr2018.pdf) a ser atingido. Para isso, é fundamental estar pacificado o [conceito de rodadas evolutivas no desenvolvimento de ativos digitais]({{ site.baseurl }}/docs/round).

Ao contrário de outros tipos de tecnologias, é possível o lançamento de ativos digitais em **TRL 7**, ou seja, em versão "**Beta**". Consequentemente, também é possível divulgar softwares em TRL 7 no [catálogo de tecnologias do portal da Embrapa](https://www.embrapa.br/tecnologias).

Conforme [comentado anteriormente](#partner), o atingimento de níveis mais altos de maturidade tecnológica (TRL 8 e 9) dependem da formalização de parcerias que garantam a sustentação do software e potencializem a sua adoção, preservando a imagem da marca Embrapa. Leia as [orientações específicas sobre a Escala TRL/MRL e distribuição de MVPs]({{ site.baseurl }}/docs/mvp) para maiores detalhes.

![Identidade visual de aplicativo em Beta Release]({{ site.baseurl }}/assets/img/guidelines/01.png)

Ativos digitais em _Beta Release_ (TRL 7), devido à instabilidade inerente, devem ter uma preocupação adicional com os seguintes aspectos:

- Sejam identificados como "_Beta_" em sua interface, informando ao usuário final dos riscos e limitações. Um exemplo de ajuste na identidade visual pode ser visto na figura acima. Ao clicar na faixa de "BETA" (canto superior direito), uma janela de diálogo com um _disclaimer_ é apresentada ao usuário. Nesta janela, além do aviso sobre a maturidade do ativo, existe uma chamada para eventuais parceiros e um canal de comunicação. Esta orientação se aplica a qualquer software que tenha uma interface de usuário (aplicativos móveis, aplicações web e softwares desktop).

- Também recomendamos fortemente que softwares em TRL 7 que coletem dados de usuário tenham funcionalidades que permitam o _backup_ destes dados pelo próprio usuário (preferencialmente em um formato legível, tal como planilhas Excel), bem como sua restauração posterior. Lembramos que, [pela LGPD]({{ site.baseurl }}/docs/lgpd), o usuário pode a qualquer momento apagar seus dados pessoais do sistema. Além disso, dado que se trata de uma versão _Beta_, é salutar que o usuário tenha a possibilidade de salvaguardar seus dados de qualquer instabilidade do software.

- Por fim, [conforme já comentado](#marketplaces), reforçamos a recomendação de que ativos neste nível de maturidade sejam disponibilizados publicamente **sem o uso de _marketplaces_ de terceiros**.

### 9. Atribuição de licenças de código {#license}

A equipe de desenvolvimento, em acordo com a área de negócios e a chefia, deverá estabelecer e atribuir licenças de código para os diversos componentes que formam o ativo digital agropecuário desenvolvido. Para maiores detalhes, leia a [documentação específica sobre licenças de distribuição e derivação dos ativos digitais]({{ site.baseurl }}/docs/licensing).

### 10. Registro do ativo digital no INPI {#inpi}

Por fim, será necessário realizar o registro (ou depósito) do código-fonte dos componentes de software que compõem o ativo digital agropecuário. Para maiores detalhes, leia o [artigo sobre registro de software junto ao INPI]({{ site.baseurl }}/docs/register).
