---
layout: page
title: Build
subtitle: Preparando um estágio da aplicação para deploy
---

Conforme [detalhado anteriormente]({{ site.baseurl }}/docs/kanban), a plataforma **embrapa.io** adota uma metodologia de desenvolvimento baseada na entrega de melhorias contínuas e graduais. Desta forma, uma vez que o [processo de codificação das aplicações]({{ site.baseurl }}/docs/app) de inicie, já é possível configurar os ambientes de estágio de maturidade para entrega da aplicação para **testadores internos** (_alpha testers_), **testadores externos** (_beta testers_) e para os **usuários finais** em produção (_release users_).

Quando uma **aplicação** é disponibilizada em um determinado **ambiente de estágio de maturidade**, denominamos esta combinação como uma ***build*** da aplicação. Seu nome será dado pela junção do nome _unix_ do projeto (_namespace_), o nome _unix_ da aplicação e o estágio de maturidade (_alpha_, _beta_ ou _release_):

> project / app @ stage

Falamos mais sobre os [estágios de maturidade e a definição de _build_ no capítulo de introdução]({{ site.baseurl }}/docs/introduction).

Uma vez que a **aplicação** tenha sido criada, já será possível configurar as _builds_ para cada **estágio de maturidade**. Para isso, será necessário a um **mantenedor do projeto** informar, por meio de um _wizard_, dados essenciais para o _deploy_ da _build_. Inicialmente, o usuário precisará clicar no ícone em forma de "engrenagem" ao lado do estágio de maturidade (_alpha_, _beta_ ou _release_) que deseja configurar para gerar a _build_.

![Iniciar a configuração de uma build]({{ site.baseurl }}/assets/img/build/01.png)

#### Passo 1: _Disclaimer_

O _wizard_ de configuração da _build_ tem 6 (seis) passos nos quais o usuário deverá preencher informações requeridas. O primeiro é o _disclaimer_, o qual o mantenedor do projeto deverá estar ciente.

![Disclaimer de configuração da build]({{ site.baseurl }}/assets/img/build/02.png)

Repare que no **canto superior direito** do _dialog_ do _wizard_ é indicado o nome da _build_ que está sendo configurada.

#### Passo 2: _Cluster_

No segundo passo o usuário deverá informa o _cluster_ onde será realizado o _deploy_ desta _build_ da aplicação.

> Atenção! Uma vez que tenha sido realizado o _deploy_ no _cluster_ escolhido, ele **não poderá mais ser alterado**.

Os _clusters_ de _deploy_ de _builds_ podem estar em qualquer local (em Unidades da Embrapa, instituições parceiras ou serviços de _cloud_ terceirizados) e podem utilizar diversas tecnologias de orquestração de _containers_ homologadas para a plataforma. Falamos mais sobre _clusters_ no [capítulo de introdução]({{ site.baseurl }}/docs/introduction) e no tutorial sobre [como configurar e disponibilizar um _cluster_]({{ site.baseurl }}/docs/cluster).

![Escolha do cluster de deploy da build]({{ site.baseurl }}/assets/img/build/03.png)

#### Passo 3: _Volumes_

Um _volume_ é uma **área de armazenamento independente** utilizada pelas aplicações para persistir dados criados em tempo de execução. Um exemplo comum são arquivos de _upload_ enviados para uma aplicação web. Nos _clusters_ estas áreas serão criadas em servidores do tipo _storage_, específicos para armazenar grandes quantidades de dados.

Ao acessar pela primeira vez este passo na configuração da _build_, a plataforma carrega _volumes_ que foram pré-configurados no [_boilerplate_ utilizado para instanciar a aplicação]({{ site.baseurl }}/docs/app). A [equipe mantenedora do _boilerplate_]({{ site.baseurl }}/docs/boilerplate) é responsável por "propor" uma configuração inicial que garanta a conteinerização da aplicação derivada. Neste passo, o usuário mantenedor do projeto pode alterar esta proposta inicial apagando _volumes_ que não queira utilizar e criando outros. É necessário, no entanto, se atentar ao _volume_ denominado ```backup```, pois este é um _volume_ coringa utilizado no [processo de _backup_ de _builds_]({{ site.baseurl }}/docs/backup).

![Configuração dos volumes da build]({{ site.baseurl }}/assets/img/build/04.png)

#### Passo 4: _Environment Variables_

Neste passo o usuário irá configurar as **variáveis de ambiente** da _build_. Da mesma forma que ocorre em _volumes_, aqui serão pré-carregadas "variáveis iniciais", proposta pela [equipe mantenedora do _boilerplate_]({{ site.baseurl }}/docs/boilerplate). O usuário poderá então remover, alterar e criar novas variáveis.

![Lista de variáveis de ambiente da build]({{ site.baseurl }}/assets/img/build/05.png)

As variáveis de ambiente podem ser de 6 (seis) tipos:

- **SERVER:** São variáveis injetadas pelo autômato de _deploy_ e não podem ser alteradas. Contém informações relevantes que podem ser utilizadas pela _build_ em tempo de execução, tal como o **estágio de maturidade**, o **número da versão** e o **usuário que executou o _deploy_**.
- **TEXT:** São variáveis de texto livre (_plain text_), cujo o conteúdo pode ser inserido pelo usuário. Não são aceitos, no entanto, nenhum tipo de caracter de espaço (o próprio espaço, tabulação, quebra de linha, etc).
- **SECRET:** São utilizadas para o registro de _private keys_, necessárias para sistemas de autenticação. Na configuração inicial da _build_ a plataforma gera uma sequência randômica alfanumérica de 256 caracteres, mas o usuário pode alterar este valor.
- **PASSWORD:** Utilizadas para armazenar senhas, tal como as senhas de _root_ e do _user_ do banco de dados da aplicação. Inicialmente a plataforma gera uma sequência randômica alfanumérica de 16 caracteres, mas o usuário pode alterar este valor.
- **PORT:** Utilizada para informar ao autômato de _deploy_ quais portas deverão ser expostas para a aplicação. Visando eliminar conflitos, a plataforma **embrapa.io** faz a gestão das portas atribuídas em cada _cluster_. Assim, ao selecionar uma variável deste tipo para a _build_ será atribuído um valor entre 49152 e 65535, que é a faixa de portas válidas utilizada pela plataforma.
- **VOLUME:** Aqui o usuário poderá vincular um _volume_ configurado no passo anterior a uma variável de ambiente.

![Configurando uma porta da aplicação como variável de ambiente]({{ site.baseurl }}/assets/img/build/06.png)

#### Passo 5: _URLs_

Quando é realizado o _deploy_ da _build_, o autômato de _deploy_ checa as portas válidas e as "expõe" publicamente no _cluster_. Assim, todas as variáveis do tipo ```PORT``` configuradas no passo anterior estarão acessíveis pelo domínio do _cluster_. Por exemplo, se o _cluster_ escolhido for ```cluster.cnpgc.embrapa.br``` e no passo anterior o usuário tiver configurado as portas ```55123``` para uma aplicação Web e ```55789``` para conexão com o banco de dados MySQL, a aplicação na _build_ estará disponível publicamente em ```https://cluster.cnpgc.embrapa.br:55123``` e os usuários poderão acessar diretamente o banco de dados MySQL da aplicação por meio do _host_ ```cluster.cnpgc.embrapa.br``` na porta ```55789```.

> **Atenção!** Apesar de possível, não é indicado expor portas de serviços internos ao _container_, pois isto pode trazer riscos à segurança da aplicação.

Neste passo é possível atribuir à aplicação URLs mais "amigáveis" e semanticamente aderentes à sua finalidade. Há duas formas de fazer isso:

- **URLs Auto-Geradas:** São subdomínio pré-conigurados no _cluster_ de _deploy_ da _build_, aos quais as portas expostas da aplicação podem ser mapeadas em _subpaths_. Por exemplo, no _cluster_ ```cluster.cnpgc.embrapa.br``` poderíamos ter o subdomínio ```api.cnpgc.embrapa.br``` configurado como um ```CNAME``` apontando para o _host_ real. Caso esteja fazendo a configuração de uma aplicação denominada, por exemplo, "**pasto-certo/backend**", que é a API do aplicativo Pasto Certo, o usuário poderia configurar uma URL ```https://api.cnpgc.embrapa.br/pasto-certo``` apontando para a o _host_ real na porta exposta. É importante ressaltar que os subdomínios são configurados em cada _cluster_ para cada estágio de maturidade, então um subdomínio disponível para as _builds_ em estágio de _release_ não estará disponível para os demais estágios (_alpha_ e _beta_). Os subdomínios são [configurados pela equipe mantenedora do _cluster_]({{ site.baseurl }}/docs/cluster).

- **URL Externa (_alias_):** Adicionalmente, é possível aos usuários configurarem seus próprios subdomínios em domínios de sua propriedade e apontá-los para as portas expostas da _build_. Para isso, basta ao usuário configurar um ```CNAME``` no DNS do domínio apontando para o host ```router.embrapa.io```. A plataforma irá então gerar os certificados SSL necessários e realizar as configurações necessárias para o roteamento do tráfego.

![Configurando as URLs da build]({{ site.baseurl }}/assets/img/build/07.png)

#### Passo 6: _Validate_

No último passo o usuário deverá submeter as configurações da _build_ para validação.

![Validando a build]({{ site.baseurl }}/assets/img/build/08.png)
