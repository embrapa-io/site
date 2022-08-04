---
layout: page
title: Squads
subtitle: Como cada time de desenvolvimento de ativos é formado?
---

O desenvolvimento de ativos digitais para a agropecuária é sempre desafiador, em maior ou menor grau, geralmente demandando uma equipe multidisciplinar. A seguir são listados os papéis que deverão ser assumidos pelos membros dos times, de forma a atribuir responsabilidades. Observe que um membro da equipe pode assumir um ou mais destes papéis.

#### Arquiteto da Solução

Este papel deverá ser assumido por um **empregado da Embrapa** da área de computação. Preferencialmente, por um membro da **Supervisão de Desenvolvimento de Ativos Digitais**.

Ele será responsável por definir, com o apoio dos **especialistas**, a arquitetura tecnológica do ativo digital, propondo quais módulos deverão compor a solução, como eles irão interagir, quais tecnologias e linguagens de programação serão utilizadas e antever a integração do ativo com soluções previamente desenvolvidas. Este profissional deverá conhecer bem a plataforma **embrapa.io** e ser proficiente na criação de entidades (tais como [projetos]({{ site.baseurl }}/docs/project) e [aplicações]({{ site.baseurl }}/docs/app) a partir de _boilerplates_), na [configuração]({{ site.baseurl }}/docs/build) e [_deploy_ de _builds_]({{ site.baseurl }}/docs/deploy) e na [gestão de instâncias]({{ site.baseurl }}/docs/health).

Uma vez que se inicie o desenvolvimento, o profissional deverá registrar o ativo junto ao [CatSoft](https://sistemas.sede.embrapa.br/catsoft/) e, no momento adequado, cuidar da distribuição do ativo em _marketplaces_ externos, criando e configurando o _store listing_ nas lojas virtuais de aplicativos.

Este profissional deverá articular, em conjunto com o **gestor de domínio de negócio**, para garantir que todos os demais papéis necessários sejam atribuídos antes do início do projeto. Ao longo de sua execução, deverá garantir que sejam definidas as [licenças de software]({{ site.baseurl }}/docs/licensing) para cada aplicação que compõe o ativo digital, consultorando o **gestor de domínio de negócio** de forma que seja tomada a melhor decisão. Ao final do projeto, deverá subsidiar a [classificação do ativo na Escala TRL/MRL]({{ site.baseurl }}/docs/mvp) e o encaminhamento para o registro junto ao [INPI](https://www.gov.br/inpi/pt-br).

#### Engenheiro de Software

Este profissional será responsável por planejar e monitorar o desenvolvimento das aplicações que compõem a solução, definindo os _milestones_, registrando os requisitos levantados no formato de _issues_, priorizando estas _issues_ juntamente com os **gestores do domínio de negócios** (de forma a inserí-las em _milestones_ ou no _backlog_) e atribuindo-as aos demais membros da equipe.

Para viabilizar estas atividades, utilizará a [ferramenta de gestão de projetos]({{ site.baseurl }}/docs/kanban) integrada ao [GitLab](https://git.embrapa.br) da plataforma **embrapa.io**, baseada na [metodologia de desenvolvimento ágil **Kanban**](https://statushero.com/blog/comparing-scrum-kanban-lean/).

#### Analista de Requisitos

Responsável pelo lavantamento de requisitos, criação de _mockups_ e validação junto aos **gestores do domínio de negócios**. Em projetos de escopo menor, recomenda-se que este papel seja assumido pelo **engenheiro de software** da equipe.

#### Gestor do Domínio de Negócio

Normalmente os pesquisadores ou analistas da Embrapa que demandaram a solução (e/ou lideram o projeto/atividade de pesquisa associado). É um profissional da agropecuária, tal como um zootecnista, agrônomo, biólogo ou veterinário. É fortemente recomendado que todo ativo digital em desenvolvimento tenha pelo menos dois membros com este papel (um titular e um suplente).

É o responsável por providenciar os requisitos da solução e os dados experimentais necessários para seus desenvolvimento (tal como dados rotulados a serem utilizados pelos **especialistas** para o treinamento de algoritmos de aprendizado de máquina). Também será responsável pelos testes da solução junto ao público-alvo (articulando, p.e., junto a associações de produtores), bem como aprovar as versões das _builds_ antes de promovê-las a novos estágios de maturidade.

Adicionalmente, atuará como o secretário executivo do projeto de desenvolvimento do ativo digital: (_a_) gerenciando a agenda de reuniões do projeto; (_b_) demandando recursos externos, tal como a logo e identidade visual para a área de comunicação; (_c_) articulando com a área de negócios da Embrapa e dos parceiros a eventual transferência do ativo; e, (_d_) encabeçando a redação de contratos com agentes externos, formulários e relatórios para outras instâncias, tal como os comitês de propriedade intelectual ou de uso de animais.

#### Especialista

São profissionais da área de computação especialistas em uma subárea específica. Por exemplo, projetos que demandem a criação de algoritmos de aprendizado de máquina, sistemas de informação geográfica, algoritmos embarcados, etc. A necessidade de um especialista deve ser identificada antes do início do projeto e deverão ser realizadas as articulações necessárias para envolver este profissional, que pode ser interno ou externo à Embrapa.

Por exemplo, a equipe de um projeto de ativo digital para a pecuária que vislumbra o uso de câmeras à campo para o reconhecimento e alerta de predadores poderia contar com um pesquisador especializado em visão computacional da [Embrapa Agricultura Digital](https://www.embrapa.br/agricultura-digital) e um pesquisador em engenharia da computação, responsável pelo desenvolvimento das placas de circuito impresso, da [UFMS](https://www.ufms.br/).

#### Programador

Responsável pela codificação das _issues_, testes unitários e manutenções corretivas e evolutivas.
