---
layout: page
title: Rodadas Evolutivas
subtitle: Evolução do nível de maturidade de ativos digitais
---

*[API]: Application Programming Interface

O **Macroprocesso de Desenvolvimento de Ativos Digitais**, que foi abordado em [artigo específico]({{ site.baseurl }}/docs/macroprocess) corroborado por [videoaula](https://youtu.be/DFc2iZy4Ox4?si=yr7ca07IX3XSC5b_), apresenta o conceito de **Rodadas Evolutivas**. A seguir é detalhado este conceito e demonstrado seu uso prático.

## Fases de Maturidade

No âmbito da Agricultura Digital, ativos tecnológicos são concebidos a partir de pesquisas com **computação científica** em agropecuária de precisão, tendo seu encapsulamento na forma de **produtos digitais** e, por fim, sua transferência para o mercado visando compor um **negócio digital**. Na Embrapa, demandas por novos ativos digitais já são atualmente controladas pelo [Sistema Embrapa de Gestão (SEG)](https://www.embrapa.br/documents/32008859/39100403/Sum%C3%A1rio+Executivo+002+-+SEG/86964fe8-f97d-55ff-57ad-ae1898c9ac3c?version=1.0), sendo orquestradas pela área de PD&I. Assim, desde o levantamento de necessidade e sua concepção até sua maturidade plena, um ativo digital passa por etapas evolutivas que o farão progredir em estágios de maturidade até alcançar seu público final.

![Macroprocesso de desenvolvimento de ativos para Agricultura Digital.]({{ site.baseurl }}/assets/img/round/02.png)

Além disso, visando mitigar a fragmentação dos ativos, no contexto do macroprocesso de desenvolvimento, estes são orquestrados em ecossistemas temáticos para atender às inúmeras cadeias de produção da agricultura brasileira. O modelo proposto, conforme mostrado na figura acima, possui portanto duas dimensões: um eixo vertical, baseado na [Escala de Maturidade TRL/MRL](https://cloud.cnpgc.embrapa.br/nap/files/2018/08/EscalaTRL-MRL-17Abr2018.pdf), e outro eixo horizontal, de orquestração dos ativos em ecossistemas temáticos digitais, sendo eles: **agricultura (e fruticultura)**, **pecuária (produção animal)**, **aquicultura (e pesca)**, **florestas (e silvicultura)** e **indústria de processamento**.

Em cada uma das fases do eixo vertical, haverá mudança no foco de desenvolvimento. A **Fase I** é centrada na **computação científica** e, portanto, no uso de tecnologias habilitadoras para o desenvolvimento de novos modelos, algoritmos e circuitos inovadores com o uso massivo de dados agropecuários. Fazendo um paralelo com a terminologia para maturidade de software normalmente adotada pelo mercado, teríamos:

- **TRL 1 e 2**: Correspondente às **fases de diagnóstico, concepção e levantamento de requisitos** do processo de desenvolvimento de software; e
- **TRL 3 e 4**: Algoritmos especializados (tal como modelos de aprendizado de máquina), que podem ser executados em ambiente laboratorial (normalmente por linha de comando), ou seja, muito distantes ainda de se tornarem produtos para o usuário final.

Na **Fase II** ocorre a **manufatura digital** do ativo visando encapsulá-lo em um produto viável, palatável ao público final. Trata-se portanto de um trabalho de Engenharia de Software, que será conduzido por um arquiteto de soluções digitais. O ativo empacotado poderá ser entregue por meio dos _marketplaces_ da Embrapa, tal como o [AgroAPI](https://www.agroapi.cnptia.embrapa.br), ou privados (em _Beta Release_), visando compor a vitrine de tecnologias da Empresa. No paralelo com a terminologia adotada pelo mercado TI, teríamos:

- **TRL 5**: Prova de Conceito (do inglês, _Proof of Concept - PoC_);
- **TRL 6**: Protótipo Funcional; e
- **TRL 7**: Mínimo Produto Viável (do inglês, _Minimum Viable Product - MVP_).

Por fim, na **Fase III** ocorre a **transferência mercadológica**, onde almeja-se alcançar a maturidade plena do ativo com a finalização de um plano de negócio, identidade visual e UI/UX bem definida, plano de _marketing_, transferência de tecnologia e apuração de _royalties_. No paralelo com a terminologia adotada pelo mercado de TI, teríamos:

- **TRL 8**: _Release Candidate_; e
- **TRL 9**: _Stable_.

### Exemplo Prático 1

![Exemplo da plataforma de melhoramento de forrageiras tropicais.]({{ site.baseurl }}/assets/img/round/04.png)

No exemplo acima temos a execução de uma **rodada evolutiva** na prática. No caso em tela, foi planejado o desenvolvimento de uma API para aferição de indicadores de fenotipagem por meio de visão computacional. A solução está sendo desenvolvida para apoiar o programa de melhoramento de cultivares de forrageiras tropicais.

Assim, ao longo dos primeiros dois anos do projeto foram realizadas inúmeras coletas de dados a campo. Em cada coleta, drones sobrevoavam as parcelas obtendo dados de sensores em diferentes GSDs (do inglês, _Ground Sample Distance_). A partir das imagens obtidas pelos drones foram montados diversos ortomosaicos georreferenciados que, por sua vez, foram segmentados e rotulados com os dados observados em solo. A partir desta base de dados foi realizado um vasto trabalho em **computação científica**, conduzido por **especialistas computacionais** (em IA), visando treinar modelos de aprendizado de máquina que pudessem aferir de forma automatizada os indicadores de fenotipagem.

Uma vez obtidos os modelos, resultantes da Fase 1 da rodada evolutiva, partiu-se para a **manufatura digital**. O trabalho, agora conduzido por **arquitetos de solução**, visou empacotar estes modelos de aprendizado de máquina em APIs que pudessem, por meio de interfaces intuitivas, receber as imagens de drones, montar o ortomosaico, segmentá-lo separando as parcelas e classificar estas imagens resultantes, extraindo os indicadores de fenotipagem. Nesta fase a equipe de engenharia de software também implementou uma série de requisitos não-funcionais, tais como controles de autorização, acesso, auditoria, monitoramento, etc.

Por fim, o ativo entrou na última fase da rodada evolutiva, onde os **arquitetos de negócio** articulam e viabilizam sua **transferência** para o público final. Neste exemplo, dado que o resultado era uma API, a versão 1.0 (TRL 9) da solução é então disponibilizada no _marketplace_ do [AgroAPI](https://www.agroapi.cnptia.embrapa.br).

Este exemplo é bastante útil para explicitar onde a plataforma **Embrapa I/O** irá apoiar o desenvolvimento do ativo digital. Seu escopo é retratado na imagem abaixo pelo desenho em 'T' em destaque:

![Escopo da plataforma Embrapa I/O.]({{ site.baseurl }}/assets/img/round/05.png)

## Ciclo de Vida e Rodadas Evolutivas

Todo software possui um ciclo de vida que vai desde sua concepção até sua descontinuidade. Durante este período, o software é inicialmente desenvolvido e lançado, vindo a sofrer inúmeras manutenções corretivas e evolutivas, bem como refatorações, incremento de funcionalidades, fusões com outros softwares e, eventualmente, divisões em sistemas menores.

Assim, um ativo digital recém-desenvolvido, que tenha passado pelas três fases de maturidade citadas na seção anterior, estará em uma versão 1.0. Este ativo, para ser desenvolvido, exigiu o provisionamento de uma equipe multidisciplinar, provavelmente formada por pesquisadores e analistas da Embrapa e de parceiros (tal como outros institutos de pesquisa, universidades e empresas). A este esforço inicial, de articulação e provisionamento da equipe, uso de recursos financeiros e materiais e testes junto à comunidades interna e externa, damos o nome de "**rodada evolutiva**". Assim, manutenções evolutivas no software inicialmente desenvolvido para a adição de funcionalidades irão exigir novas rodadas evolutivas e, por conseguinte, a alocação de recursos financeiros, materiais e humanos para este novo esforço. Cada nova rodada evolutiva irá possibilitar a geração de uma nova macro-versão do ativo digital (2.0, 3.0, 4.0, etc).

Um exemplo de rodadas evolutivas utilizadas na prática é a evolução ao longo dos anos do aplicativo para dispositivos móveis [**Pasto Certo**](https://www.pastocerto.com). A [primeira versão deste aplicativo](https://www.infoteca.cnptia.embrapa.br/infoteca/handle/doc/1087190) foi desenvolvida em 2017 em uma parceria da Embrapa com a [Faculdade de Computação](https://www.facom.ufms.br) da [Universidade Federal de Mato Grosso do Sul - UFMS](https://ufms.br). Em 2019 foi desenvolvida a [segunda versão do aplicativo](https://www.infoteca.cnptia.embrapa.br/infoteca/handle/doc/1113229), com o apoio da [Associação para o Fomento à Pesquisa de Melhoramento de Forrageiras – Unipasto](https://www.unipasto.com.br). Em 2021, após nova rodada, foi lançado o [Pasto Certo 3.0](https://www.infoteca.cnptia.embrapa.br/infoteca/handle/doc/1133853). Por fim, em 2024, uma última rodada evolutiva (até o momento) resultou no [Pasto Certo 4.0](https://www.infoteca.cnptia.embrapa.br/infoteca/handle/doc/1166788).

Quando um ativo é transferido para um parceiro comercial, este deverá ficar responsável pelas novas versões do software, vindo a provisionar os recursos e esforços necessários às suas novas rodas evolutivas. Neste caso, a menos que previamente acordado, será necessário o estabelecimento de novos acordos de cooperação técnica para envolvimento de pessoal especializado da Embrapa. Em outras palavras, ativos nesta situação irão evoluir de forma autônoma.

Também pode ser necessário novas rodadas evolutivas para progredir o ativo na escala de maturidade. Por exemplo, considere um software que tenha sido desenvolvido sem parceira externa e lançado como um _Beta Release_ (MVP em TRL 7). Em determinado momento é firmada uma parceria com uma empresa para seu lançamento como um produto finalístico. Nesta ocasião pode ser estabelecida uma nova rodada evolutiva onde, com apoio do parceiro, o ativo será evoluído para sua versão 1.0 (TRL 9). Neste caso, a propriedade intelectual da nova versão é revista de forma a considerar a contribuição deste parceiro.

### Exemplo Prático 2

![Exemplo prático de ativo digital passando por diversas rodadas evolutivas.]({{ site.baseurl }}/assets/img/round/03.png)

No exemplo acima, vamos considerar um projeto SEG da Embrapa cujo um dos resultados é um novo aplicativo para dispositivos móveis que utilize a API do [ChatGPT](https://chatgpt.com) para interação em linguagem natural de produtores rurais e técnicos agropecuários com a base de conhecimento da coleção [500 Perguntas &bull; 500 Respostas](https://mais500p500r.sct.embrapa.br). Assim, temos que em 2023 é entregue uma prova de conceito (PoC), em TRL 5, que demonstra a viabilidade da solução.

Ao longo de 2024, por meio de um novo projeto SEG, a equipe de desenvolvedores amadurece a tecnologia obtendo um mínimo produto viável (MVP), em TRL 7, que é então lançado para o público como um produto "_Beta_" da Embrapa. Uma das vantagens do lançamento prévio de tecnologias é que estas atuam como "vitrines" na busca de parcerias. Características como a validação pelo público e a formação de uma base de usuários agregam valor à tecnologia, facilitando sua transferência.

Vamos supor então que em 2025 uma grande empresa do agronegócio e uma _startup_ em IA aplicada ao agro se consorciem à Embrapa para a evolução desta tecnologia. Como fruto desta parceria, é lançado em 2027 uma versão _Release Candidate_, em TRL 8, muito mais madura, com central de suporte e serviços personalizados para os produtores.

Por fim, em 2029, o consórcio lança a versão _Stable_, em TRL 9, com a tecnologia evoluída para um assistente virtual, ativado diretamente por voz, especializado do domínio da agropecuária.
