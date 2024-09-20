---
layout: page
title: Terminologia
subtitle: Conceitos básicos da plataforma
---

<iframe width="730" height="410" src="https://www.youtube.com/embed/yEaiqeUxyu8" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

A plataforma **Embrapa I/O** permite que sejam estruturados **projetos de software de ativos digitais para a agropecuária**, guiando os desenvolvedores em padrões e métodos bem definidos. Antes de utilizá-la, é necessário compreender alguns conceitos inerentes à plataforma.

Primeiramente, assume-se que cada ativo digital será formado por diversos softwares desacoplados, além de outros artefatos de apoio. Este conceito reflete o padrão atual de desenvolvimento de software, onde uma solução tem um _backend_ integrado ao banco de dados, um _frontend_ na Web, um aplicativo _mobile_, dentre outros (ou pode ainda ainda ser baseada em [_microservices_](https://microservices.io) ou [_micro-frontends_](https://micro-frontends.org)), com diversos módulos, _plugins_, _packages_ e componentes que seguem ciclos de vida independentes.

Para consolidar estes conceitos, a seguir são apresentadas as principais entidades que você encontrará na plataforma e sua terminologia.

## Ativo Digital {#digital-asset}

A [Embrapa tem por missão](https://www.embrapa.br/missao-visao-e-valores) viabilizar soluções de pesquisa, desenvolvimento e inovação para a sustentabilidade da agricultura, em benefício da sociedade brasileira. Como uma empresa de inovação voltada para o agronegócio brasileiro, atualmente desenvolve tecnologias de 14 tipos diferentes: prática agropecuária; cultivar; reprodutor, matriz ou linhagem animal; processo para produção, fabricação ou extração; produto agropecuário ou industrial; máquina, implemento ou equipamento; metodologia técnico-científica; metodologia com fins organizacionais e gerenciais; software institucional; procedimento informatizado; ativo cartográfico; tecnologias interdependentes; sistema agropecuário, agroalimentar e florestal; e, com especial ênfase, **ativo digital agropecuário**.

Neste contexto, um **ativo digital** é um conjunto de softwares com código-fonte original (e outros artefatos relacionados) que são desenvolvidos para serem utilizados no agronegócio e agricultura familiar. Mais especificamente, em cinco ecossistemas digitais: **agricultura; pecuária; florestas e silvicultura; aquicultura e pesca; e, indústria de processamento**. Para diferenciar "ativos digitais" de outras tecnologias também digitais formalmente conceituadas dentro da Empresa (tal como "processo informatizado" e "banco de dados"), é utilizada como base a [definição do INPI](https://www.gov.br/inpi/pt-br/servicos/programas-de-computador/arquivos/manual/manual-e-software-2022.pdf) para "**programa de computador**", que por sua vez é baseada na [a Lei nº 9.609, de 19 de fevereiro de 1998](https://www.planalto.gov.br/ccivil_03/leis/L9609.htm).

Em resumo, portanto, para ser considerada um "**ativo digital**", a **tecnologia digital desenvolvida deve possuir código-fonte próprio, com originalidade, e passível de [depósito e registro junto ao INPI](https://www.gov.br/inpi/pt-br/servicos/perguntas-frequentes/programas-de-computador)**.

Desta forma, aplicativos móveis, aplicações web, softwares embarcados, utilitários de linha de comando, softwares desktop, APIs e outros tipos de soluções computacionais para o agronegócio, que possuam código-fonte original, são exemplos de **ativos digitais**.

 Contrariamente, o uso exclusivo de linguagens de marcação e códigos-fonte autogerados, bem como soluções que não possuam código-fonte original, tal como aquelas construídas por meio de plataformas _No-Code_ ou _Codeless_ que não tenham código-fonte disponível para registro ou que tenham mas necessitem destas ferramentas proprietárias para serem executados ([a exemplo do Google AppSheet](https://sites.google.com/embrapa.br/embaixadores/aplicativos/desenvolvimento/appsheet?authuser=1)), **não são consideradas formalmente um ativo digital**.

## Projeto {#project}

Um **projeto** de ativo digital no **Embrapa I/O** corresponde a um grupo de repositórios no [GitLab](https://git.embrapa.io) (similar a uma _organization_ do [GitHub](https://github.com)). É, portanto, composto por diversos repositórios que, por sua vez, podem ser de 3 (três) tipos distintos:

- **repositório de código-fonte de aplicação**: que contém o código-fonte de um dos softwares que compõe o ativo digital, sendo gerado automaticamente pela plataforma a partir do código-fonte de um _boilerplate_ escolhido pelo usuário;
- **repositório de suporte**: que são gerados automaticamente pela plataforma, seguindo padrões bem definidos, para prover o site técnico de divulgação pública do projeto, a documentação _online_ da API, o empacotamente para disponibilização em lojas virtuais, o diretório privado de documentação, os artefatos de identidade visual e/ou binários de compilações; e
- **repositório de arquivos de apoio**: que nada mais são do que repositórios criados pelos mantenedores do projeto para armazenar e versionar outros arquivos que não se enquadrem nos tipos anteriores.

Para criar um **projeto**, [acesse a _dashboard_]({{ site.baseurl }}/docs/dashboard) e [siga os passos na própria interface]({{ site.baseurl }}/docs/project).

## Aplicação {#app}

Dentre os tipos de repositórios listados, o do código-fonte de **aplicação** (ou **app**) é o mais importante, pois permitirá que os desenvolvedores codifiquem cada módulo desacoplado do ativo em si e, posteriormente, façam a entrega deste módulo (_deploy_). Na plataforma **Embrapa I/O**, uma aplicação é sempre criada a partir de um código-fonte modelo, que atua como um _template_ de código ou **_boilerplate_**. Isto é fundamental para estruturar o códifo-fonte inicial da sua aplicação com padrões e diretrizes requeridos pela plataforma.

Para entender melhor este processo, [siga os passos de criação de uma aplicação]({{ site.baseurl }}/docs/app).

## Boilerplate {#boilerplate}

Uma **aplicação** pode ser criada na plataforma utilizando qualquer linguagem de programação, entretanto é necessário que ela seja baseada sempre em um _boilerplate_. Estes templates de código irão fornecer a estrutura inicial de diretórios e arquivos da aplicação, bem como a sua conteinerização prévia respeitando os requisitos determinados pela plataforma.

Por exemplo, toda aplicação no **Embrapa I/O** precisa ter um diretório oculto na raiz denominado ```.embrapa```. Neste diretório estão metadados que são utilizados pela plataforma durante a configuração dos _builds_ e nas fases de CI/DI dos processos de DevOps.

Na conteinerização também existem padrões a serem seguidos. Por exemplo, a plataforma espera ter disponível nas aplicações alguns serviços que são utilizados no _deploy_ e monitoramento das _builds_ instanciadas, tal como:

- **_backup_**: que [executa o backup das instâncias]({{ site.baseurl }}/docs/backup) e disponibiliza para os mantenedores do projeto;
- **_restore_**: que possibilita restaurar um _backup_ específico;
- **_sanitize_**: que executa um processo de higienização e/ou otimização na instância; e
- **_test_**: que executa testes unitários na instância.

Veja mais sobre [como criar e manter _boilerplates_]({{ site.baseurl }}/docs/boilerplate) e seja assim um colaborador da plataforma.

## Planejamento e Acompanhamento {#kanban}

O [GitLab](https://git.embrapa.io) integrado à plataforma **Embrapa I/O** possui uma ferramenta embutida de gerencimento ágil de projetos (do inglês, _tracking and agile project management_). Esta ferramenta permite o planejamento das etapas de desenvolvimento por meio de marcos (_milestones_) e do registro de tarefas (_issues_) associadas. Para entender melhor como fazer o planejamento e acompanhamento do projeto, [veja como utilizar a _Kanban board_ integrada]({{ site.baseurl }}/docs/kanban).

## Rodadas Evolutivas {#round}

Durante o ciclo-de-vida da **aplicação**, seu código-fonte passará por diversas evoluções. Quando estas intervenções compreendem esforços que alteram significativamente o software, atribuindo-lhe novas funcionalidades, interfaces, refatorações e/ou integrações, dizemos que trata-se de uma nova **rodada evolutiva** e, portanto, uma nova **macro-versão** da aplicação. Toda vez que uma nova **rodada evolutiva** tem início, uma [equipe (_squad_)]({{ site.baseurl }}/docs/squads) será provisionada com especialistas e profissionais que viabilizem os requisitos funcionais de suas novas _features_.

Na plataforma **Embrapa I/O** uma **app** pode ser criada visando a entrega de uma **prova de conceito** (do inglês, _Proof of Concept - PoC_), um **protótipo** ou um **produto viável mínimo** (do inglês, _Minimum Viable Product - MVP_), ou seja, uma versão inicial da aplicação em [Escala TRL/MRL]({{ site.baseurl }}/docs/mvp) 5, 6 ou 7, respectivamente. Nesta empreitada, o _squad_ de desenvolvimento irá implementar a macro-versão "0" (zero) desta aplicação. Em uma nova rodada evolutiva, visando a evolução da aplicação para um produto pleno e em produção (TRLs 8 e 9), teríamos a macro-versão "1.0". Havendo novas funcionalidades a serem implementadas, poderia-se provisionar novamente uma equipe e desenvolver a macro-versão "2.0", e assim sucessivamente.

Assim, a cada nova rodada evolutiva, a macro-versão da aplicação é incrementada, prefixando o [nome de versão](#version) do software desenvolvido. Leia o [artigo completo sobre **rodadas evolutivas** para uma melhor compreensão]({{ site.baseurl }}/docs/round).

## Estágios {#stage}

O desenvolvimento de novas funcionalidades e manutenções corretivas e evolutivas de uma aplicação no **Embrapa I/O** evolui por 4 (quatro) estágios:

- **_development_**: Estágio de **desenvolvimento**, que roda apenas na estação de trabalho dos desenvolvedores;
- **_alpha_**: Estágio de **testes internos**, apto ao _deploy_ na plataforma;
- **_beta_**: Estágio de **testes externos**, apto ao _deploy_ na plataforma; e
- **_release_**: Estágio de **produção**, apto ao _deploy_ na plataforma.

Quando uma nova **app** é criada em um **projeto** a partir de um _boilerplate_, na prática o **Embrapa I/O** faz um _fork_ do repositório do [GitLab](https://git.embrapa.io) do _boilerplate_ para dentro do projeto. Neste momento, o _boilerplate_ é customizado com algumas informações do projeto e são criadas automaticamente 4 (quatro) _branches_: _main_, _alpha_, _beta_ e _release_.

A metodologia de controle de versões adotada pelo **Embrapa I/O** segue a diretriz de "_Trunk Based Development_", onde há uma _branch_ principal, neste caso denominada "_main_", onde todas as _revisions_ devem ser concentradas. Assim, qualquer ramificação deve ter sua origem no tronco (_main_) e retornar a ele. Quando uma nova versão precisa ser entregue (_deploy_), é feito um _merge_ do tronco (_main_) para uma _branch_ do estágio (_alpha_, _beta_ ou _release_). A _branch_ do estágio é então tagueada para a versão específica. Veremos mais sobre isso no [passo de _deploy_ de _builds_]({{ site.baseurl }}/docs/deploy).

## Build {#build}

A _build_ é uma instância de determinada aplicação em um estágio específico. Seu nome é formado pelo padrão:

> project / app @ stage

Quando uma [nova app é criada]({{ site.baseurl }}/docs/app), pode-se habilitar até 3 (três) _builds_ para ela, cada uma relacionada a um estágio: _alpha_, _beta_ e _release_. Para isso, será necessário [configurar cada _build_ separadamente]({{ site.baseurl }}/docs/build). Para que uma _build_ seja instanciada na plataforma **Embrapa I/O** e, desta forma, disponibilizada publicamente, ela precisará primeiramente ter sua configuração validada. A configuração de uma _build_ envolve o _cluster_ em que ela será instanciada, os _volumes_ para armazenamento de dados, a definição das variáveis de ambiente da instância e a associação de URLs externas (_aliases_).

## Versão {#version}

Para a entrega (_deploy_) de _builds_ é necessário, além de efetuar o _merge_ da _branch_ "_main_" na _branch_ de estágio (_alpha_, _beta_ ou _release_), criar uma _tag_ nesta última _branch_ de forma a informar à plataforma **Embrapa I/O** que existe uma nova versão da _build_ a ser instanciada no servidor remoto. Para nomear esta _tag_, a plataforma institui um padrão bem definido de nome de versão:

> macro version . milestone year . milestone month - stage . patch

Desta forma, a versão de uma determinada _build_ poderia ser, por exemplo, "**2.23.4-beta.7**". Neste exemplo, a _build_ em questão está na [macro-versão](#round) "**2**", correspondente ao _milestone_ "**23.4**" (ou seja, com entrega planejada para **abril de 2023**), no estágio de "**testes externos**" (_beta_) e no "**7º**" _patch_.

Ao versionar a _build_ de produção (_release_) há uma exceção: **é omitido o qualificador de estágio**. Assim, um nome de versão válido para uma _build_ em produção seria "**2.23.4-3**" (versão final para produção, planejada para **abril de 2023**, da aplicação em sua **2ª macro-versão**).

Este padrão de nomes de versão é aderente ao padrão [SemVer 2.0.0](https://semver.org/). É importante frisar que a plataforma **Embrapa I/O** valida se as _tags_ estão sendo criadas com nomes válidos e nas _branches_ corretas, somente efetuando o _deploy_ se tudo estiver conforme o padrão.

Veja como criar a _tag_ na _branch_ utilizando o cliente GIT e, desta forma, [efetuar o _deploy_ da _build_]({{ site.baseurl }}/docs/deploy).

## Instância {#instance}

Uma vez que tenha sido realizado o _deploy_ de uma _build_ em determinado servidor remoto (_cluster_), teremos uma instância sendo executada e disponível para acesso pelos usuários. Os usuários poderão então acessar a instância por meio da URL do servidor e das portas alocadas (links permanentes) ou por meio de _aliases_ configurados previamente. Os mantenedores do projeto poderão [monitorar a instância]({{ site.baseurl }}/docs/health) e "disparar" determinados processos de gestão (tal como reiniciar os _containers_, agendar o higienizador/otimizador, suspender a instância e [fazer backup dos dados da instância]({{ site.baseurl }}/docs/backup)).

## Cluster {#cluster}

Uma instância de uma _build_ pode ser instanciada em servidores (ou _clusters_) remotos internos e externos à Embrapa e com diferentes **orquestradores** de _containers_. Para isto, a plataforma **Embrapa I/O** adota uma estratégia de _deploy_ baseada em _drivers_. Assim, é possível ter um _driver_ para [Kubernetes](https://kubernetes.io) (que fará o _deploy_ em um _host_ com este orquestrador), outro para _deploy_ na [Microsoft Azure](https://azure.microsoft.com) (que fará o _deploy_ interagindo com a API desta plataforma), outro para [RedHat OpenShift](https://www.redhat.com/pt-br/technologies/cloud-computing/openshift), etc.

Da mesma forma, é necessário gerenciar os servidores do tipo _storage_ onde serão montados os volumes para armazenamento de dados das aplicações. Neste caso também é adotado uma estratégia baseada em _drivers_, onde pode-se por exemplo ter para o orquestrador Kubernetes um _driver_ para NFS v3 e outro para o NFS v4. Ou ainda, ter um _driver_ para o orquestrador [Amazon AWS](https://aws.amazon.com) integrado a um _driver_ para _storage_ que monta os volumes no [Amazon EBS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEBS.html).

É possível [configurar e disponibilizar novos _clusters_ e _storages_]({{ site.baseurl }}/docs/cluster) para comporem a plataforma **Embrapa I/O**, ampliando assim sua capacidade de entrega de soluções.
