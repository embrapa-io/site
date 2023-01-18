---
layout: page
title: Upgrade
subtitle: Como manter suas apps atualizadas em relação ao boilerplate?
---

*[UI]: User Interface

Uma das maiores capacidades do **embrapa.io** é o de fomentar o **desenvolvimento colaborativo de ativos digitais**. Para isso, a plataforma faz uso intensivo dos recursos do [GIT](https://git-scm.com/), possibilitando que manutenções corretivas e evolutivas no código-fonte de diferentes aplicações em projetos distintos possam ser compartilhadas. Este recurso está fortemente embasado no [conceito de _boilerplates_]({{ site.baseurl }}/docs/boilerplate) inerente à plataforma, que faz com que toda aplicação criada seja na realidade um [_fork_ de um repositório-base](https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html). Desta forma, uma vez estabelecido um vínculo entre o repositório-base (_upstream_) e o derivado (_fork_), torna-se possível que alterações sejam mescladas (do inglês, _merged_) do primeiro para o segundo e vice-versa.

É possível, portanto, que erros encontrados ou melhorias identificadas que remetam ao _boilerplate_ [sejam corrigidos e retroalimentem o repositório-base]({{ site.baseurl }}/docs/merge), de forma que novos projetos derivados do mesmo _boilerplate_ se beneficiem destas alterações. Da mesma forma, repositórios derivados já existentes podem ser atualizados a partir das novas revisões do repositório-base, recebendo manutenções corretivas e evolutivas que tenham sido realizadas após sua criação a partir do _boilerplate_.

Os repositórios de _boilerplates_ são projetos públicos no [GitLab da plataforma **embrapa.io**](https://git.embrapa.io) e podem ser acessados por qualquer usuário da plataforma:

![Boilerplates como um grupo público no GitLab]({{ site.baseurl }}/assets/img/upgrade/01.png)

Além disso, todo repositório de aplicação tem a indicação (link) de qual repositório-base foi realizado o _fork_, possibilitando o acesso direto a ele:

![Link para o repositório upstream]({{ site.baseurl }}/assets/img/upgrade/02.png)

Uma vez que tenham sido identificadas alterações relevantes no repositório-base, pode-se trazer estas alterações para as aplicações em seu projeto que tenham sido derivadas deste _boilerplate_. Há diversas formas de fazer isso, mas apresentaremos aqui um passo-a-passo que possibilita fazê-lo de forma simples, utilizando o próprio clone do repositório da aplicação e um cliente GIT em seu ambiente de desenvolvimento local. Para este exemplo, está sendo utilizando o cliente [GitKraken](https://www.gitkraken.com/).

Utilizando seu cliente GIT, abra o repositório da sua aplicação. Primeiramente, vamos adicionar o repositório do _boilerplate_ original como um novo _remote_, chamando-o de `upstream`:

![Adicionando o boilerplate como remote]({{ site.baseurl }}/assets/img/upgrade/52.png)

Desta forma, seu repositório estará agora com dois _remotes_: o `origin` e o `upstream`. Em seguida, sincronize a _branch_ `main` do _boilerplate_ (_remote_ `upstream` recém adicionado) criando uma _branch_ local denominada `boilerplate`. Faça agora o _merge_ da _branch_ `boilerplate` para a _branch_ `main` (ou seja, na prática será um _merge_ da _branch_ `main` do _remote_ `upstream` para a _branch_ `main` do _remote_ `origin`), resolvendo os conflitos um-a-um.

![Commitando o merge]({{ site.baseurl }}/assets/img/upgrade/53.png)

Feito isso, a _branch_ `boilerplate` pode ser apagada e o _remote_ `upstream` removido. Para manter sua aplicação atualizada com as manutenções corretivas e evolutivas do _boilerplate_, basta repetir os passos acima sempre que necessário.
