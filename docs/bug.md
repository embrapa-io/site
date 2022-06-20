---
layout: page
title: Error Tracking
subtitle: Monitorando e rastreando erros nas aplicações
---

Como parte da plataforma **embrapa.io**, há uma [ferramenta de _error tracking_ integrada](https://bug.embrapa.io), denominada [Sentry](https://sentry.io), que é automaticamente configurada no momento da criação de [projetos]({{ site.baseurl }}/docs/project) e [aplicações]({{ site.baseurl }}/docs/app).

Por padrão, os _boilerplates_ da plataforma são [pré-configurados]({{ site.baseurl }}/docs/boilerplate) para já enviarem os erros para a ferramenta. Para isto, [o Sentry utiliza um _Data Source Name (DSN)_](https://docs.sentry.io/product/sentry-basics/dsn-explainer/) único para cada aplicação. Este atributo é injetado pela plataforma **embrapa.io** em tempo de _deploy_ das aplicações. Assim, da mesma forma que as demais _environment variables_ injetadas, em ambiente de desenvolvimento este atrubuto deverá ser configurado no arquivo ```.env.ci```. É possível obter o valor do DSN da aplicação pela própria [_dashboard_ da plataforma](https://dashboard.embrapa.io).

![Acesso ao DSN pelo card da aplicação]({{ site.baseurl }}/assets/img/bug/01.png)

> **Atenção!** Ao lado do ícone do _error tracking_ no _card_ da aplicação é mostrado o número total de erros emitidos por _issues_ "não resolvidas".

Após clicar no ícone do _error tracking_ no _card_ da aplicação, poderá ser copiado o DSN, [consultada a documentação específica para a plataforma utilizada](https://docs.sentry.io/platforms/) (linguagem ou arcabouço de programação) e [acessado o ambiente de _error tracking_](https://bug.embrapa.io) na própria ferramenta Sentry.

![Dialog com menu de contexto do error tracking]({{ site.baseurl }}/assets/img/bug/02.png)

Uma vez configurado o DSN, o Sentry irá capturar todos os erros da sua aplicação. Estes erros serão mostrados no ambiente de _error tracking_ com diversas informações detalhadas de _debug_. Os erros podem ser então atribuídos a membros do projeto para resolução.

![Detalhes de um erro no ambiente de error tracking]({{ site.baseurl }}/assets/img/bug/03.png)

Adicionalmente, caso tenham sido corretamente configurados os atributos ```environment``` e ```release```, conforme detalhado no [tutorial de configuração de _boilerplates_]({{ site.baseurl }}/docs/boilerplate), os erros serão agrupados por ambiente de execução (_development_, _alpha_, _beta_ e _release_) e _milestone_, respectivamente.

![Agrupamento por releases no ambiente de error tracking]({{ site.baseurl }}/assets/img/bug/04.png)

Uma vez que esteja familiarizado com a ferramenta de _error tracking_, você já pode [configurar as _builds_ de _deploy_ da aplicação]({{ site.baseurl }}/docs/build).
