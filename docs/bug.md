---
layout: page
title: Error Tracking
subtitle: Monitorando e rastreando erros nas aplicações
---

Como parte da plataforma **embrapa.io**, há uma ferramenta de _error tracking_ integrada, denominada [Sentry](https://sentry.io), que é automaticamente configurada no momento da criação de [projetos]({{ site.baseurl }}/docs/project) e [aplicações]({{ site.baseurl }}/docs/app). Ela está disponível para acesso em:

<div style="margin: 0 auto; text-align: center;">
    <a class="btn btn-info btn-lg" href="https://bug.embrapa.io" target="_blank">bug.embrapa.io</a>
</div>

Por padrão, os _boilerplates_ da plataforma são [pré-configurados]({{ site.baseurl }}/docs/boilerplate) para já enviarem os erros para a ferramenta. Para isto, [o Sentry utiliza um _Data Source Name (DSN)_](https://docs.sentry.io/product/sentry-basics/dsn-explainer/) único para cada aplicação. Este atributo é injetado pela plataforma **embrapa.io** em tempo de _deploy_ das aplicações. Assim, da mesma forma que as demais _environment variables_ injetadas, em ambiente de desenvolvimento este atributo deverá ser configurado no arquivo ```.env.ci```. É possível obter o valor do DSN da aplicação pela própria [_dashboard_ da plataforma](https://dashboard.embrapa.io).

![Acesso ao DSN pelo card da aplicação]({{ site.baseurl }}/assets/img/bug/01.png)

> **Atenção!** Ao lado do ícone do _error tracking_ no _card_ da aplicação é mostrado o número total de erros emitidos por _issues_ "não resolvidas".

Após clicar no ícone do _error tracking_ no _card_ da aplicação, poderá ser copiado o DSN, [consultada a documentação específica para a plataforma utilizada](https://docs.sentry.io/platforms/) (linguagem ou arcabouço de programação) e [acessado o ambiente de _error tracking_](https://bug.embrapa.io) na própria ferramenta Sentry.

![Dialog com menu de contexto do error tracking]({{ site.baseurl }}/assets/img/bug/02.png)

Uma vez configurado o DSN, o Sentry irá capturar todos os erros da sua aplicação. Estes erros serão mostrados no ambiente de _error tracking_ com diversas informações detalhadas de _debug_. Os erros podem ser então atribuídos a membros do projeto para resolução.

![Detalhes de um erro no ambiente de error tracking]({{ site.baseurl }}/assets/img/bug/03.png)

Adicionalmente, caso tenham sido corretamente configurados os atributos ```environment``` e ```release```, conforme detalhado no [tutorial de configuração de _boilerplates_]({{ site.baseurl }}/docs/boilerplate), os erros serão agrupados por ambiente de execução (_development_, _alpha_, _beta_ e _release_) e _milestone_, respectivamente.

![Agrupamento por releases no ambiente de error tracking]({{ site.baseurl }}/assets/img/bug/04.png)

É possível melhorar a integração com o [GitLab](https://git.embrapa.io) de forma a possibilitar a criação de _issues_ no [Kanban do projeto]({{ site.baseurl }}/docs/kanban) diretamente pela interface de _error tracking_. Entretanto, neste momento, <u>este processo ainda é manual</u>. Para fazer a integração, acesse o [Sentry](https://bug.embrapa.io) e selecione um projeto (a _Organization_ no Sentry) do qual é **mantenedor**. Vá em "**Settings » Integrations » GitLab**" e clique no botão "**Add Installation**".

![Configurando a integração com o GitLab: Add Installation]({{ site.baseurl }}/assets/img/bug/05.png)

Leia as instruções na página que aparece. Você será direcionado a criar um nova _Application_ no seu [perfil do GitLab](https://git.embrapa.io/-/profile/applications). Ao prosseguir, você deverá inserir no Sentry os dados de integração, semelhante à imagem abaixo. Repare que no campo "**GitLab Group Path**" deverá ser inserido o nome _unix_ do projeto.

![Configurando a integração com o GitLab: Connect Sentry]({{ site.baseurl }}/assets/img/bug/06.png)

Caso as informações estejam corretas, você poderá informar ao Sentry quais repositórios estão associados à _Organization_.

![Configurando a integração com o GitLab: Add Repositories]({{ site.baseurl }}/assets/img/bug/07.png)

Agora, nas _issues_ do _error tracking_, aparecerá uma opção para _linkar_ a _issue_ do GitLab.

![Configurando a integração com o GitLab: Link GitLab Issue]({{ site.baseurl }}/assets/img/bug/08.png)

Esta função permite vincular o _bug_ a uma _issue_ pré-existente no GitLab ou criar uma nova _issue_ automaticamente. Escolha corretamente à qual aplicação a _issue_ deverá ser vinculada.

![Configurando a integração com o GitLab: Configure GitLab Issue]({{ site.baseurl }}/assets/img/bug/09.png)

Por fim, você pode acessar o [GitLab](https://git.embrapa.io) e complementar as informações da _issue_, tal como vincular um responsável, o estágio no _Kanban Board_, o _milestone_, um prazo de término, etc.

![Configurando a integração com o GitLab: Edit GitLab Issue]({{ site.baseurl }}/assets/img/bug/10.png)

Uma vez que esteja familiarizado com a ferramenta de _error tracking_, você já pode [configurar as _builds_ de _deploy_ da aplicação]({{ site.baseurl }}/docs/build).
