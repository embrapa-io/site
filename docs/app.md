---
layout: page
title: Aplicação
subtitle: Adicionando uma aplicação ao projeto
---

<iframe width="730" height="410" src="https://www.youtube.com/embed/ZAkhZT7K5h8" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

Conforme [explicitado no capítulo de introdução]({{ site.baseurl }}/docs/introduction#project), um **projeto de ativo digital** na plataforma pode ser composto por diversos softwares desacoplados. Assim, cada um destes softwares-componentes será uma **aplicação** independente no projeto, com seu código-fonte armazenado e versionado em um repositório específico no [GitLab](https://git.embrapa.io) e tendo um ciclo de vida próprio.

Existem duas formas de se criar uma aplicação em um projeto no **Embrapa I/O**:

### 1. A partir de _boilerplate_

Para criar uma nova aplicação a partir de um [_boilerplate_]({{ site.baseurl }}/docs/introduction#boilerplate), um **arquiteto da solução** do projeto deverá clicar no botão "**Nova App**", no rodapé do _card_ do projeto. Isso iniciará um _wizard_ que guiará o usuário por alguns passos. Inicialmente é apresentado ao usuário um _disclaimer_, o qual ele deverá estar ciente.

![Disclaimer de criação de app]({{ site.baseurl }}/assets/img/app/01.png)

No segundo passo, o usuário deverá selecionar o _boilerplate_ que será utilizado para gerar o código-fonte inicial da aplicação. Conforme foi [explicado no capítulo de introdução]({{ site.baseurl }}/docs/introduction#boilerplate), o _boilerplate_ é necessário para estruturar a aplicação no padrão requerido pelo **Embrapa I/O**. Na maioria das vezes o _boilerplate_ será apenas uma espécie de ```Hello Word```, ou seja, o menor conjunto de código-fonte possível para instanciar uma aplicação em determinada linguagem de programação ou _framework_ de desenvolvimento, porém estruturado com os requisitos para torná-lo aderente aos _pipelines_ de DevOps do Embrapa I/O.

É possível criar uma aplicação sem utilizar um _boilerplate_ como base. Para isso deverá ser utilizada a opção "**repositório pré-existente**" no campo de seleção. Neste caso, o repositório da aplicação deverá ser criado de antemão e possuir a mesma estrutura requerida por um _boilerplate_, [conforme explicado no tutorial de criação de _boilerplates_]({{ site.baseurl }}/docs/boilerplate).

Ao selecionar o _boilerplate_ serão apresentadas informações sobre ele, tal como links de referência e a sua equipe mantenedora. Qualquer usuário da plataforma pode [propor um novo _boilerplate_]({{ site.baseurl }}/docs/boilerplate), colaborando com a comunidade **Embrapa I/O**.

Neste passo o usuário deverá também selecionar um **nome _unix_** para a aplicação (somente letras minúsculas, números e hífen). A combinação com o nome _unix_ do projeto (_namespace_) deverá ser única em toda a plataforma. Por exemplo, na imagem abaixo está sendo definido como ```pwa``` o nome _unix_ da aplicação, sendo que o nome final com o _namespace_ será ```pasto-certo/pwa```. Caso esteja criando uma aplicação sem o _boilerplate_, o nome _unix_ deverá ser o mesmo do repositório criado previamente.

![Selecionando o boilerplate]({{ site.baseurl }}/assets/img/app/02.png)

Ao clicar no botão "**Criar App**" a plataforma irá colocar a requisição em uma fila para o autômato _Genesis_, de provisionamento de entidades. O autômato fará um _fork_ do repositório do _boilerplate_ para o projeto, customizando alguns detalhes neste processo.

![Aguardando a criação da app]({{ site.baseurl }}/assets/img/app/03.png)

No _card_ do **projeto** na _dashboard_ fica disponível a lista de todas as **aplicações** naquele projeto. Para cada aplicação nesta lista, é possível [configurar a _build_]({{ site.baseurl }}/docs/build), ou seja, os **estágios de maturidade** que podem ser disponibilizados publicamente: _alpha_ (testes internos), _beta_ (testes externos) e _release_ (produção).

![App com estágios de maturidade]({{ site.baseurl }}/assets/img/app/04.png)

Por fim, o repositório da aplicação estará disponível no grupo do projeto no [GitLab](https://git.embrapa.io). A equipe de desenvolvedores poderá agora [iniciar o planejamento do desenvolvimento]({{ site.baseurl }}/docs/kanban) e realizar o _clone_ do código-fonte para o ambiente local de desenvolvimento, codificar a aplicação conforme os requisitos, seguindo [boas práticas de desenvolvimento]({{ site.baseurl }}/docs/practices), e fazer o _commit_ e _push_ de volta ao repositório. Adicionalmente, a equipe pode contar com uma [ferramenta para monitoramento de erros (_error tracking_)]({{ site.baseurl }}/docs/bug).

### 2. A partir de um repositório GIT

Quando a aplicação é criada a partir de um _boilerplate_ existe o grande benefício desta já nascer inerentemente conteinerizada, integrada às ferramentas de monitoramento ([Matomo](https://hit.embrapa.io), [Sentry](https://bug.embrapa.io), [SonarQube](https://code.embrapa.io), etc) e aderente aos _pipelines_ de _deploy_ de aplicações da plataforma. Entretanto, exitem situações em que a criação da aplicação a partir de um _boilerplate_ não será adequada. Os casos mais comuns são:

- quando não há no catálogo de _boilerplates_ algum que atenda às especificações tecnológicas definidas para a aplicação; e
- quando se trata de uma aplicação existente que está sendo migrada para a plataforma **Embrapa I/O**.

Nestes casos, a equipe de desenvolvimento precisará adequar o código-fonte da aplicação para que esta seja reconhecida pela plataforma, devidamente monitorada e aderente aos processos de DevOps.

> **Atenção!** Caso as especificações técnicas do ativo que será desenvolvido não estejam contempladas em nenhum _boilerplate_ do catálogo, é fortemente recomendado avaliar se, ainda assim, não existe algum _boilerplate_ que possa ser "ajustado" para contemplá-las. Muitas vezes pode ser mais fácil e rápido efetuar estes ajustes do que partir do "zero", tendo que efetuar todos os passos (que serão vistos logo mais) de adequação para tornar o código-fonte aderente à plataforma **Embrapa I/O**.

Para iniciar, será preciso primeiramente criar o repositório GIT. Para isso, um **arquiteto de solução** do projeto deverá [acessar o GitLab da plataforma](https://git.embrapa.io), navegar até o grupo de repositórios do projeto e criar manualmente um novo repositório:

![Criando um repositório GIT avulso]({{ site.baseurl }}/assets/img/app/05.png)

> **Atenção!** O nome do repositório GIT deverá respeitar a sintaxe do nome de aplicações, ou seja, termo mínimo 3 caracteres e ser composto apenas por caracteres alfanuméricos minúsculos sem acentos e hífen.

Na próxima tela, você terá a escolha de criar um repositório em branco ou importar um repositório existente. Esta última opção pode ser utilizada quando se trata de uma aplicação que esteja sendo migrada e que já está sendo versionada pelo GIT (estando, p.e., no [GitHub](https://github.com) ou outra plataforma similar). Se estiver criando um repositório vazio para, posteriormente, por meio de um _scaffold_ inicializar o código fonte em determinada linguagem e/ou arcabouço de desenvolvimento, recomenda-se criar um "_blank project_" e inicializá-lo com o `README`.

![Configurando o novo repositório GIT]({{ site.baseurl }}/assets/img/app/06.png)

É necessário que o **Embrapa I/O** reconheça este repositório como uma [aplicação]({{ site.baseurl }}/docs/introduction#app) para que esta seja criada também nas ferramentas satélites ([Matomo](https://hit.embrapa.io), [Sentry](https://bug.embrapa.io) e [SonarQube](https://code.embrapa.io)), provendo assim os identificadores necessários para configurar a integração do código-fonte com estas ferramentas. Assim, é necessário configurar manualmente os metadados da aplicação. Para isso, crie um diretório na raiz denominado `.embrapa` e, dentro dele, um arquivo `settings.json` com o seguinte conteúdo:

```json
{
  "boilerplate": "_",
  "platform": "javascript",
  "label": "",
  "description": "",
  "references": [],
  "maintainers": [],
  "variables": {
    "default": [],
    "alpha": [],
    "beta": [],
    "release": []
  },
  "orchestrators": [ "DockerCompose" ]
}
```

Depois será necessário rever este arquivo mas, para um primeiro momento, utilize este conteúdo acima alterando apenas o valor do atributo `platform` para a linguagem predominante na aplicação que será desenvolvida, dentre as seguintes opções: `android`, `apple`, `dart`, `dotnet`, `electron`, `elixir`, `flutter`, `go`, `java`, `javascript`, `kotlin`, `native`, `node`, `php`, `python`, `react-native`, `ruby`, `rust`, `unity` e `unreal`.

> **Atenção!** Repare que o valor do atributo _boilerplate_ é um _underscore_ (carácter `_`). **Não altere este valor!**

Uma vez que este arquivo de metadados tenha sido criado no repositório, este pode agora pode ser vinculado a uma aplicação homônima por meio da [_dashboard_](https://dashboard.embrapa.io). Para isso, no _card_ do projeto clique em "**Nova App**", aceite os termos do _disclaimer_ e, no passo seguinte, selecione no campo "**Escolha um modelo (_boilerplate_)...**" a opção "**Repositório pré-existente**". Em seguida, insira o **nome Unix do repositório no GitLab** no campo indicado (deve ser <u>exatamente o mesmo nome</u>) e clique em "**Criar App**".

![Criando uma app a partir de um repositório GIT pré-existente]({{ site.baseurl }}/assets/img/app/07.png)

Agora, será necessário codificar a nova aplicação ou adaptar o código-fonte existente realizando alguns procedimentos (mas não todos) que são tratados no [artigo sobre desenvolvimento e disponibilização de _boilerplates_]({{ site.baseurl }}/docs/boilerplate). Mais especificamente, será necessário:

1. Aplicar as [diretrizes de boas práticas]({{ site.baseurl }}/docs/boilerplate#base) para criação de aplicações;
2. Integrar sua aplicação ao [Sentry (_error tracking_)]({{ site.baseurl }}/docs/boilerplate#bug), ao [Matomo (_analytics_)]({{ site.baseurl }}/docs/boilerplate#analytics) e ao [SonarQube]({{ site.baseurl }}/docs/boilerplate#code);
3. Criar os [arquivos de _environment variables_]({{ site.baseurl }}/docs/boilerplate#env);
4. [Conteinerizar sua aplicação]({{ site.baseurl }}/docs/boilerplate#docker);
5. Implementar os [serviços-padrões]({{ site.baseurl }}/docs/boilerplate#cli) de [_test_]({{ site.baseurl }}/docs/boilerplate#cli:test), [_backup_]({{ site.baseurl }}/docs/boilerplate#cli:backup), [_restore_]({{ site.baseurl }}/docs/boilerplate#cli:restore) e [_sanitize_]({{ site.baseurl }}/docs/boilerplate#cli:sanitize); e
6. Configurar adequadamente os [metadados]({{ site.baseurl }}/docs/boilerplate#metadata) e os [orquestradores]({{ site.baseurl }}/docs/boilerplate#orchestrator).

> **Atenção!** Repare que no último passo o arquivo `.embrapa/settings.json` será revisitado. Isto é necessário para complementá-lo com os valores padrão das variáveis de ambiente e a configuração de orquestradores, quando aplicável.

Pronto! Feito isso o **Embrapa I/O** irá criar, após algum tempo, a aplicação nas ferramentas satélites e expor no _card_ as informações necessárias de configurações. Estando tudo certo será possível aplicar todos os _pipelines_ e processos de DevOps, assim como em qualquer aplicação criada a partir de um _boilerplate_.
