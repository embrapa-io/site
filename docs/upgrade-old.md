---
layout: page
title: Upgrade
subtitle: Como manter suas apps atualizadas em relação ao boilerplate?
---

*[UI]: User Interface

Uma das maiores capacidades do **embrapa.io** é o de fomentar o **desenvolvimento colaborativo de ativos digitais**. Para isso, a plataforma faz uso intensivo dos recursos do [GIT](https://git-scm.com/), possibilitando que manutenções corretivas e evolutivas no código-fonte de diferentes aplicações em projetos distintos possam ser compartilhadas. Este recurso está fortemente embasado no [conceito de _boilerplates_]({{ site.baseurl }}/docs/boilerplate) inerente à plataforma, que faz com que toda aplicação criada seja na realidade um [_fork_ de um repositório-base](https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html). Desta forma, uma vez estabelecido um vínculo entre o repositório-base (_upstream_) e o derivado (_fork_), torna-se possível que alterações sejam mescladas (do inglês, _merged_) do primeiro para o segundo e vice-versa.

É possível, portanto, que erros encontrados ou melhorias identificadas que remetam ao _boilerplate_ [sejam corrigidos e retroalimentem o repositório-base]({{ site.baseurl }}/docs/merge), de forma que novos projetos derivados do mesmo _boilerplate_ se beneficiem destas alterações. Da mesma forma, repositórios derivados já existentes podem ser atualizados a partir das novas revisões do repositório-base, de forma a receber manutenções corretivas e evolutivas que tenham sido realizadas após sua criação a partir do _boilerplate_.

Os repositórios de _boilerplates_ são projetos públicos no [GitLab da plataforma **embrapa.io**](https://git.embrapa.io) e podem ser acessados por qualquer usuário da plataforma:

![Boilerplates como um grupo público no GitLab]({{ site.baseurl }}/assets/img/upgrade/01.png)

Além disso, todo repositório de aplicação tem a indicação (link) de qual repositório-base foi realizado o _fork_, possibilitando o acesso direto a ele:

![Link para o repositório upstream]({{ site.baseurl }}/assets/img/upgrade/02.png)

Uma vez que tenham sido identificadas alterações relevantes no repositório-base, pode-se trazer estas alterações para as aplicações em seu projeto que tenham sido derivadas deste _boilerplate_. Há diversas formas de fazer isso, mas apresentaremos aqui um passo-a-passo que possibilita fazê-lo de forma segura, porém mais cadenciada. Primeiramente, crie um novo _fork_ do _boilerplate_ em seu projeto (grupo do GitLab), clicando no botão indicado:

![Botão para iniciar a criação do fork]({{ site.baseurl }}/assets/img/upgrade/03.png)

No formulário de _fork_, escolha o projeto que contém as aplicações que serão atualizadas (em destaque na imagem abaixo) e, opcionalmente, altere o nome do repositório resultante de forma a identificá-lo apropriadamente. No exemplo abaixo foi adicionado o sufixo `-upgrade` ao nome do _boilerplate_. Por fim, clique no botão "Fork project":

![Formulário de fork do boilerplate]({{ site.baseurl }}/assets/img/upgrade/04.png)

O novo repositório será criado no grupo de repositórios do projeto (neste exemplo, denominado `mais-precoce`). Para realizar o _upgrade_ das aplicações, será necessário criar uma _branch_ de atualização em cada aplicação a ser modificada. Por exemplo, no estudo de caso que estamos utilizando, o projeto `mais-precoce` possui diversas aplicações derivadas do _boilerplate_ `vuejs-pwa`, sendo elas: `pwa`, `manager`, `plugin-flow`, `plugin-gantt`, `plugin-optimize` e `plugin-sensitivity`. Para atualizar cada uma destas aplicações, o procedimento será o mesmo. Acesse o repositório da aplicação e vá no histórico de _commits_:

![Histórico de commits do repositório 'plugin-flow']({{ site.baseurl }}/assets/img/upgrade/05.png)

Procure pelo commit realizado pelo usuário "embrapa.io Genesis Automaton", denominado "Configuração inicial automática do repositório". Você deverá copiar o ID do _commit_ (SHA) imediatamente anterior a esta entrada, conforme mostrado na imagem abaixo:

![Copiando o commit ID da última alteração realizada antes do fork do boilerplate]({{ site.baseurl }}/assets/img/upgrade/06.png)

Retorne à raiz do repositório e clique no botão para criar uma nova _branch_:

![Criar uma nova branch]({{ site.baseurl }}/assets/img/upgrade/07.png)

Dê um nome para a _branch_ (p.e., `upgrade`) e cole o ID copiado do _commit_ no campo "Create from". Por fim, clique em "Create branch":

![Criando a branch de upgrade]({{ site.baseurl }}/assets/img/upgrade/08.png)

Retorne agora para o repositório de _upgrade_ do _boilerplate_ resultante do _fork_ que fizemos inicialmente (neste exemplo, `vuejs-pwa-upgrade`) e crie um novo _merge request_.

> **Atenção!** É fundamental atentar-se para as _branches_ que serão a origem (_source_) e destino (_target_) do _merge request_. Você deverá fazer um _merge_
 da _branch_ principal do _fork_ do _boilerplate_ para a recém-criada _branch_ de _upgrade_.

Uma vez selecionas as _branches_ corretas, clique em "Compare branches and continue":

![Criando um merge request para atualizar a branch de upgrade]({{ site.baseurl }}/assets/img/upgrade/09.png)

Uma vez criado o _merge request_, aplique-o! Como a _branch_ `upgrade` foi criada diretamente de um _commit_ do _boilerplate_ original, o _merge_ poderá ser aplicado de imediato (sem conflitos).

Agora, crie um novo _merge request_ da _branch_ `upgrade` (que agora contém todas as alterações mais recentes do _boilerplate_) para a _branch_ `main`, ou seja, a _branch_ principal (_trunk_) do mesmo repositório. Neste momento, mantenha a opção "Delete source branch when merge request is accepted" selecionada, de forma que ao final do processo a _branch_ `upgrade`, não sendo mais necessária, seja automaticamente apagada.

![Fazendo o merge da branch upgrade para a main]({{ site.baseurl }}/assets/img/upgrade/10.png)

Você precisará agora aplicar o _merge_. Provavelmente haverá, no entanto, conflitos a serem tratados. No exemplo deste artigo, estamos utilizando a UI do GitLab para executar todos os passos, mas você tem a escolha de fazer este _merge_ localmente, utilizando assim o cliente GIT de sua preferência. No GitLab iremos resolver os conlitos um-a-um e realizar o _commit_ das alterações para a _branch_ `upgrade`:

![Resolvendo os conflitos do merge]({{ site.baseurl }}/assets/img/upgrade/11.png)

Por fim, aplique o _merge_ mantendo a opção para apagar a _branch_ `upgrade` selecionada:

![Aplicando o merge da branch upgrade para a main]({{ site.baseurl }}/assets/img/upgrade/12.png)

Pronto! A _branch_ `main` da sua aplicação está agora atualizada com todas manutenções corretivas e evolutivas realizadas no _boilerplate_ original. Você pode agora repetir os passos acima para as demais aplicações do projeto que tenham sido derivadas do mesmo _boilerplate_.

No futuro, para atualizar novamente as aplicações, você poderá utilizar o mesmo _fork_ do _boilerplate_ (neste caso, o repositório `mais-precoce/vuejs-pwa-upgrade`). Será necessário, no entanto, atualizá-lo com os _commits_ do repositório original do _boilerplate_. Para isso, execute os seguintes comandos em seu ambiente local, adaptando-os conforme a necessidade:

```bash
# Faça o clone do repositório derivado do boilerplate (fork):
git clone https://git.embrapa.io/mais-precoce/vuejs-pwa-upgrade.git
cd vuejs-pwa-upgrade

# Adicione o repositório do boilerplate como um segundo 'remote'
# ao repositório clonado (chamando-o de 'upstream'):
git remote add upstream https://git.embrapa.io/io/boilerplate/vuejs-pwa.git

# Obtenha as alterações do 'upstream' e realize o pull para a
# branch principal 'main':
git checkout main
git fetch upstream
git pull upstream main

# Por fim, faça o push das alterações para o 'origin', de forma a
# atualizar o seu fork:
git push origin main
```
