---
layout: page
title: Macroprocesso
subtitle: Visão geral do processo de desenvolvimento de ativos tecnológicos para a agricultura digital
---

<iframe width="730" height="410" src="https://www.youtube.com/embed/DFc2iZy4Ox4" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

O termo **Agricultura Digital** se refere a uma forma ubíqua de oferecer informação, produtos e serviços para todos os elos da cadeia agropecuária, fazendo uso intensivo do aparato tecnológico e mudança cultural da era da transformação digital. Trata-se de uma evolução da Agricultura de Precisão, baseada em tecnologias, para um modelo fortemente baseado no negócio. Um dos princípios básicos deste conceito é a experiência do usuário como o cerne da transformação digital.

A Embrapa tem atuado para estar em consonância com estas tendências e aplicá-las, com protagonismo, no sistema produtivo agropecuário brasileiro. Os desafios inerentes ao conceito da Agricultura Digital, entretanto, vão muito além do desenvolvimento de novas soluções de TI aplicadas. Trata-se também de adequar processos de negócio para possibilitar desenvolver tais soluções em parceria com a iniciativa privada e transferi-las com a agilidade do mercado de vanguarda tecnológica.

Assim, foi estabelecida uma **Estratégia de Aceleração Digital** na Embrapa que visa estabelecer um macroprocesso de desenvolvimento de ativos digitais para viabilizar novos negócios da transformação digital do agro, visando contribuir diretamente com a missão da Empresa. Neste macroprocesso os ativos digitais nascem por meio de um esforço multidisciplinar envolvendo cientistas especialistas em produtos agropecuários e pesquisadores da computação científica; atingem sua puberdade ao serem empacotados em soluções digitais que podem ser utilizados pelo público alvo; e, alcançam sua maturidade plena ao comporem um negócio digital.

Demandas por novos ativos digitais já são atualmente controladas pelo [Sistema Embrapa de Gestão (SEG)](https://www.embrapa.br/fundamentos-estrutura-e-funcionamento-do-sistema-embrapa-de-gestao-seg), sendo orquestradas pela área de PD&I. Assim, desde o levantamento de necessidade e sua concepção até sua maturidade plena, um ativo digital passa por etapas evolutivas que o farão progredir em fases de maturidade até alcançar seu público final. Veja mais sobre isso no [artigo dedicado ao conceito de **rodadas evolutivas**]({{ site.baseurl }}/docs/round).

Além disso, visando mitigar a fragmentação dos ativos, no contexto deste macroprocesso de desenvolvimento, os ativos digitais são orquestrados em ecossistemas temáticos para atender às inúmeras cadeias de produção da agricultura brasileira. O modelo proposto, conforme mostrado na figura abaixo, possui portanto duas dimensões: um eixo vertical, baseado na [Escala de Maturidade TRL/MRL](https://www.embrapa.br/escala-dos-niveis-de-maturidade-tecnologica-trl-mrl), e outro eixo horizontal, de orquestração dos ativos em ecossistemas temáticos digitais, sendo eles: **agricultura** (e fruticultura), **pecuária** (produção animal), **aquicultura** (e pesca), **florestas** (e silvicultura) e **indústria de processamento**.

![Macroprocesso de Desenvolvimento de Ativos Digitais]({{ site.baseurl }}/assets/img/round/02.png)

Em cada uma das fases do eixo vertical, haverá mudança no foco de desenvolvimento. A **Fase I** é centrado na computação científica e, portanto, no uso de tecnologias habilitadoras para o desenvolvimento de novos modelos, algoritmos e circuitos inovadores com o uso massivo de dados agropecuários.

Na **Fase II** ocorre a manufatura digital do ativo visando encapsulá-lo em um produto viável palatável ao público final. Trata-se portanto de um trabalho de Engenharia de Software, que será conduzido por um arquiteto de soluções digitais. O ativo empacotado poderá ser entregue por meio dos _marketplaces_ da Embrapa, tal como o [AgroAPI](https://www.agroapi.cnptia.embrapa.br/), ou privados (em _Beta Release_), visando compor a vitrine de tecnologias da Empresa. 

Por fim, na **Fase III** ocorre a transferência mercadológica, onde almeja-se alcançar a maturidade plena do ativo com a finalização de um plano de negócio, identidade visual e UI/UX bem definida, plano de marketing, transferência de tecnologia e apuração de royalties.

Foi com o intuito de materializar os conceitos preconizados no macroprocesso e permitir que equipes de desenvolvimento de software das comunidades internas e externas à Embrapa pudessem desenvolver ativos para a agricultura digital de forma ágil, eficiente e aderente aos princípios deste macroprocesso, que foi desenvolvida a plataforma de DevOps denominada **Embrapa I/O**.

A plataforma permite que sejam estruturados projetos de software de ativos digitais para a agropecuária, guiando os desenvolvedores em padrões e métodos bem definidos. Trata-se de uma ferramenta que unifica os repositórios de código-fonte destes ativos e automatiza diversas atividades inerentes ao processo de desenvolvimento de software, tal como teste, integração e entrega contínuas, monitoramento de erros, geração de relatórios analíticos de uso e busca ativa por vulnerabilidades (CVEs).

Conforme pode ser visto na [arquitetura do Embrapa I/O]({{ site.baseurl }}/docs/architecture), a plataforma integra uma série de ferramentas visando possibilitar a automação de tarefas que, de outra forma, iriam onerar a equipe de desenvolvimento.
