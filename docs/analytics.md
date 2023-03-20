---
layout: page
title: Relatórios Analíticos
subtitle: Monitorando o uso das aplicações
---

Como parte da plataforma **embrapa.io**, há também uma ferramenta de relatórios analíticos integrada, denominada [Matomo](https://matomo.org), que é automaticamente configurada no momento da criação de [projetos]({{ site.baseurl }}/docs/project) e [aplicações]({{ site.baseurl }}/docs/app). Trata-se, portanto, de uma ferramenta de análise utilizada para rastrear e analisar ações de usuários nas aplicações. Ela está disponível para acesso em:

<div style="margin: 0 auto; text-align: center;">
    <a class="btn btn-info btn-lg" href="https://hit.embrapa.io" target="_blank">hit.embrapa.io</a>
</div>

Por padrão, os _boilerplates_ da plataforma são [pré-configurados]({{ site.baseurl }}/docs/boilerplate) para já enviarem os registros de acesso e ações de usuários para a ferramenta. Para isto, o Matomo utiliza um _Site ID_ único para cada aplicação. Este atributo é injetado pela plataforma **embrapa.io** em tempo de _deploy_ das aplicações. Assim, da mesma forma que as demais _environment variables_ injetadas, em ambiente de desenvolvimento este atributo deverá ser configurado no arquivo ```.env.ci```. No entanto, no momento da customização do _boilerplate_ para gerar a aplicação, o autômato já insere o valor adequado no arquivo `.env.ci.example`, não sendo necessário nenhuma intervenção do desenvolvedor.

É possível acompanhar os relatórios analíticos gerados automaticamente pela [_dashboard_ do **embrapa.io**](https://dashboad.embrapa.io) por meio do botão "Painel", no _card_ dos projetos:

![Sumário dos relatórios analíticos]({{ site.baseurl }}/assets/img/analytics/01.png)

Este _dialog_ apresenta um sumário com as informações mais relevantes, mas os relatórios completos estarão disponíveis na própria ferramenta do Matomo, acessível pelo botão "Relatório Completo":

![Relatórios completos no Matomo]({{ site.baseurl }}/assets/img/analytics/02.png)

Os relatórios permitem aferir a "qualidade percebida" da aplicação e a recepção do público. Estão presentes informações como o tempo de renderização, o engajamento dos usuários e sua fidelidade, com base no uso recorrente.
