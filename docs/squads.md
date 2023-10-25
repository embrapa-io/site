---
layout: page
title: Squads
subtitle: Como cada time de desenvolvimento de ativos é formado?
---

O desenvolvimento de ativos digitais para a agropecuária é sempre desafiador, em maior ou menor grau, geralmente demandando uma **equipe multidisciplinar**. A seguir são listados os papéis que deverão ser assumidos pelos membros dos times, de forma a <u>atribuir responsabilidades</u>. **Observe que um membro da equipe pode assumir um ou mais destes papéis.**

### _Architect_: Arquiteto da Solução {#architect}

Este papel deverá ser assumido por um **empregado da Embrapa** da área de computação. Preferencialmente, por um membro da **Supervisão de Desenvolvimento de Ativos Digitais**.

Ele será responsável por definir, com o apoio dos [_Specialists_](#specialist), a arquitetura tecnológica do ativo digital, propondo quais módulos deverão compor a solução, como eles irão interagir, quais tecnologias e linguagens de programação serão utilizadas e antever a integração do ativo com soluções previamente desenvolvidas. Este profissional deverá conhecer bem a plataforma **Embrapa I/O** e ser proficiente na criação de entidades (tais como [projetos]({{ site.baseurl }}/docs/project) e [aplicações]({{ site.baseurl }}/docs/app) a partir de _boilerplates_), na [configuração]({{ site.baseurl }}/docs/build) e [_deploy_ de _builds_]({{ site.baseurl }}/docs/deploy) e na [gestão de instâncias]({{ site.baseurl }}/docs/health).

> **Atenção!** Somente o _Architect_ pode efetuar o [_deploy_ das aplicações em produção (_release_)]({{ site.baseurl }}/docs/deploy).

Uma vez que se inicie o desenvolvimento, o profissional deverá registrar o ativo junto ao [CatSoft](https://sistemas.sede.embrapa.br/catsoft/) e, no momento adequado, cuidar da distribuição do ativo em _marketplaces_ externos, criando e configurando o _store listing_ nas lojas virtuais de aplicativos.

Deverá também articular, em conjunto com o [_Manager_](#manager), para garantir que todos os demais papéis necessários sejam atribuídos antes do início do projeto. Ao longo de sua execução, deverá garantir que sejam definidas as [licenças de software]({{ site.baseurl }}/docs/licensing) para cada aplicação que compõe o ativo digital, consultorando o [_Manager_](#manager) de forma que seja tomada a melhor decisão. Ao final do projeto, deverá subsidiar a [classificação do ativo na Escala TRL/MRL]({{ site.baseurl }}/docs/mvp) e o encaminhamento para o registro junto ao [INPI](https://www.gov.br/inpi/pt-br).

Também deverá realizar o planejamento-macro do projeto, definindo e registrando os marcos (ou _milestones_). Cada _milestone_ deverá ser nomeado conforme o [padrão de atribuição de nomes de versões da plataforma]({{ site.baseurl }}/docs/introduction#version). Para realizar esta atividade, utilizará a [ferramenta de gestão de projetos]({{ site.baseurl }}/docs/kanban) integrada ao [GitLab](https://git.embrapa.br) da plataforma **Embrapa I/O**, baseada na [metodologia de desenvolvimento ágil **Kanban**](https://thomazribas.com/agile/kanban). Neste contexto, o _Architect_ assume o "chapéu" do _Service Request Manager_ sendo responsável, nas <u>reuniões semanais</u> da equipe (_Replenishment Meeting_), por definir quais requisitos registrados no _backlog_ serão relacionados a cada _milestone_ e, desta forma, atribuídos para desenvolvimento.

### _Engineer_: Engenheiro de Software {#engineer}

Este profissional será responsável por refinar o planejamento do projeto e monitorar o desenvolvimento das aplicações que compõem a solução, registrando os requisitos levantados no formato de _issues_ detalhadamente e atribuindo estas _issues_ aos demais membros do _squad_. Assim, no contexto da metodologia de desenvolvimento ágil **Kanban**, o _Engineer_ assume o "chapéu" de _Service Delivery Manager_ sendo responsável, nas <u>conversas diárias</u> com os [_Programmers_](#programmer) (_Kanban Meeting_), por atualizar o _status_ de cada _issue_ atribuída.

Também será o responsável pela documentação geral do projeto, assegurando que os respositórios de suporte para [documentação pública]({{ site.baseurl }}/docs/project#web), [privada]({{ site.baseurl }}/docs/project#doc) e da [API]({{ site.baseurl }}/docs/project#api) (caso se aplique) estejam atualizados e completos.

### _Analyst_: Analista de Requisitos {#analyst}

Responsável pelo lavantamento de requisitos, criação de _mockups_ e validação junto aos [_Managers_](#manager). Em projetos de escopo menor, recomenda-se que este papel seja assumido pelo [_Engineer_](#engineer) da equipe.

### _Manager_: Gestor do Domínio de Negócio {#manager}

Normalmente os pesquisadores ou analistas da área de PD&I da Embrapa que demandaram a solução (e/ou lideram o projeto/atividade de pesquisa associado). É um profissional da agropecuária, tal como um zootecnista, agrônomo, biólogo ou veterinário. No contexto da metodologia, faz o papel de _product owner_ da solução, responsável por maximizar o valor do produto final.

> **Atenção!** É fortemente recomendado que todo ativo digital em desenvolvimento tenha pelo menos dois membros com este papel (um titular e um suplente).

É o responsável por providenciar os requisitos da solução e os dados experimentais necessários para seu desenvolvimento (tal como dados rotulados a serem utilizados pelos [_Specialist_](#specialist) para o treinamento de algoritmos de aprendizado de máquina). Também será responsável pelos testes da solução junto ao público-alvo (articulando, p.e., junto a associações de produtores), bem como aprovar as versões das _builds_ antes de promovê-las a novos estágios de maturidade.

Adicionalmente, atuará como o secretário executivo do projeto de desenvolvimento do ativo digital: (_a_) gerenciando a agenda de reuniões do projeto; (_b_) demandando recursos externos, tal como a logo e identidade visual para a área de comunicação; (_c_) articulando com o [_Sponsor_](#sponsor) e a área de negócios da Embrapa e dos parceiros a transferência do ativo para o mercado; e, (_d_) encabeçando a redação de contratos com agentes externos, formulários e relatórios para outras instâncias, tal como os comitês de propriedade intelectual, ética ou de uso de animais.

### _Sponsor_: Analista do Negócio {#sponsor}

Desempenha o papel de patrocinador em um projeto (ou _business owner_), procurando orientar o desenvolvimento de forma a atender melhor o interesse da empresa. É responsável por agendar as _strategy review meeting_ (quinzenais) que, no âmbito do projeto, buscam a transferência mercadológica do ativo, discutindo modelos de negócios, parcerias, licenças e registro de software, etc. Assumem este "chapéu" profissionais da área de negócios da Embrapa e dos parceiros envolvidos.

### _Specialist_: Especialista em TI {#specialist}

São profissionais da área de computação especialistas em uma subárea específica. Por exemplo, projetos que demandem a criação de algoritmos de aprendizado de máquina, sistemas de informação geográfica, algoritmos embarcados, etc. A necessidade de um _Specialist_ deve ser identificada antes do início do projeto e deverão ser realizadas as articulações necessárias para envolver este profissional, que pode ser interno ou externo à Embrapa.

Por exemplo, a equipe de um projeto de ativo digital para a pecuária que vislumbra o uso de câmeras à campo para o reconhecimento e alerta de predadores poderia contar com um pesquisador especializado em visão computacional da [Embrapa Agricultura Digital](https://www.embrapa.br/agricultura-digital) e um pesquisador em engenharia da computação, responsável pelo desenvolvimento das placas de circuito impresso, da [UFMS](https://www.ufms.br/).

### _Programmer_: Programador {#programmer}

Responsável pela codificação das _issues_, testes unitários e manutenções corretivas e evolutivas.

Deverá atualizar diariamente a situação das _issues_ atribuídas a si na [ferramenta de gestão de projetos]({{ site.baseurl }}/docs/kanban). Além disso, participar das <u>conversas diárias</u> com o [_Engineer_](#engineer) (_Kanban Meeting_), de forma a mantê-lo a par do desenvolvimento de cada tarefa.

É o responsável por efetuar o [_deploy_ das aplicações]({{ site.baseurl }}/docs/deploy) em ambientes de [testes internos (_alpha_) e externos (_beta_)]({{ site.baseurl }}/docs/introduction#stage).
