---
layout: page
title: Aplicação
subtitle: Adicionando uma aplicação ao projeto
---

Conforme [explicitado no capítulo de introdução]({{ site.baseurl }}/docs/introduction), um **projeto de ativo digital** na plataforma pode ser composto por diversos softwares desacoplados. Assim, cada um destes softwares-componentes será uma **aplicação** independente no projeto, com seu código-fonte armazenado e versionado em um repositório específico no [GitLab](https://git.embrapa.io) e tendo um ciclo-de-vida próprio.

Para criar uma nova aplicação, um **usuário mantenedor** deverá clicar no botão "**Nova App**", no rodapé do _card_ do projeto. Isso inciará um _wizard_ que guiará o usuário por alguns passos. Inicialmente é apresentado ao usuário um _disclaimer_, o qual ele deverá estar ciente.

![Disclaimer de criação de app]({{ site.baseurl }}/assets/img/app/01.png)

No segundo passo, o usuário deverá selecionar o _boilerplate_ que será utilizado para gerar o código-fonte inicial da aplicação. Conforme foi [explicado no capítulo de introdução]({{ site.baseurl }}/docs/introduction), o _boilerplate_ é necessário para estruturar a aplicação no padrão requerido pelo **embrapa.io**. Na maioria das vezes o _boilerplate_ será apenas uma espécie de ```Hello Word```, ou seja, o menor conjunto de código-fonte possível para instanciar uma aplicação em determinada linguagem de programação ou _framework_ de desenvolvimento.

Ao selecionar o _boilerplate_ serão apresentadas informações sobre ele, tal como links de referência e a sua equipe mantenedora. Qualquer usuário da plataforma pode [propor um novo _boilerplate_]({{ site.baseurl }}/docs/boilerplate), colaborando com a comunidade **embrapa.io**.

Neste passo o usuário deverá também selecionar um **nome _unix_** para a aplicação (somente minúsculas, sem acentos, espaços ou caracteres especiais). A combinação com o nome _unix_ do projeto (_namespace_) deverá ser única em toda a plataforma. Por exemplo, na imagem abaixo está sendo definido ```pwa``` o nome _unix_ da aplicação, sendo que o nome final com o _namespace_ será ```pasto-certo/pwa```.

![Selecionando o boilerplate]({{ site.baseurl }}/assets/img/app/02.png)

Ao clicar no botão "**Criar App**" a plataforma irá colocar a requisição em uma fila para o autômato _Genesis_, de provisionamento de entidades. O autômato fará um _fork_ do repositório do _boilerplate_ para o projeto, customizando alguns detalhes neste processo.

![Aguardando a criação da app]({{ site.baseurl }}/assets/img/app/03.png)

No _card_ do **projeto** na _dashboard_ fica disponível a lista de todas as **aplicações** naquele projeto. Para cada aplicação nesta lista, é possível [configurar a _build_]({{ site.baseurl }}/docs/build), ou seja, os **estágios de maturidade** que podem ser disponibilizados publicamente: _alpha_ (testes internos), _beta_ (testes externos) e _release_ (produção).

![App com estágios de maturidade]({{ site.baseurl }}/assets/img/app/04.png)

Por fim, o repositório da aplicação estará disponível no grupo do projeto no [GitLab](https://git.embrapa.io). A equipe de desenvolvedores poderá agora [iniciar o planejamento do desenvolvimento]({{ site.baseurl }}/docs/kanban) e realizar o _clone_ do código-fonte para o ambiente local de desenvolvimento, codificar a aplicação conforme os requisitos e fazer o _commit_ e _pull_ de volta ao repositório.