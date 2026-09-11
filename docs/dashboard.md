---
layout: page
title: Dashboard
subtitle: Acessando o painel de gestão de projetos e aplicações
---

<iframe width="730" height="410" src="https://www.youtube.com/embed/wnN1tiGVcu4" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

A _dashboard_ do **Embrapa I/O** está disponível em:

<div style="margin: 0 auto; text-align: center;">
    <a class="btn btn-info btn-lg" href="https://dashboard.embrapa.io" target="_blank">dashboard.embrapa.io</a>
</div>

Esta é a ferramenta pela qual os usuários podem criar, gerenciar e monitorar as principais entidades que compõem os projetos de software de **ativos digitais** na plataforma. Caso não esteja familiarizado com a terminologia da plataforma, [consulte a introdução]({{ site.baseurl }}/docs/introduction) e compreenda os conceitos básicos.

Por meio da _dashboard_ qualquer usuário pode efetuar o _login_ na plataforma. Para isto, é necessário informar apenas um e-mail válido. A ferramenta irá enviar um PIN de 6 (seis) dígitos para este e-mail, que deverá ser informado para realizar a autenticação. Caso o e-mail não seja "@embrapa.br" (indicando que o usuário não é um empregado da Embrapa), ele deverá aceitar os [termos de uso](https://dashboard.embrapa.io/privacy-policy.html) da plataforma. Caso o usuário não exista ainda na plataforma, ele é registrado de forma transparente.

![Login no Dashboard]({{ site.baseurl }}/assets/img/dashboard/01.png)

### Login por biometria {#passkey}

Como alternativa ao PIN, é possível autenticar-se com a **biometria do próprio dispositivo** — Touch ID, Face ID, Windows Hello ou o leitor digital do celular. A tecnologia utilizada são as [_passkeys_](https://fidoalliance.org/passkeys/), um padrão aberto que substitui senhas por um par de chaves criptográficas: a chave privada **nunca sai do aparelho** e não é conhecida pela plataforma, de modo que não existe senha que possa vazar.

![Opção de login por biometria]({{ site.baseurl }}/assets/img/dashboard/10.png)

No primeiro acesso por PIN em um dispositivo, a plataforma convida o usuário a cadastrar a biometria. O cadastro também pode ser feito — ou desfeito — a qualquer momento na tela de dados pessoais, acessível pelo menu do usuário.

![Convite para cadastrar a biometria]({{ site.baseurl }}/assets/img/dashboard/11.png)

A credencial é criada **por aparelho**: quem cadastrar a biometria no computador continuará sendo convidado a cadastrá-la também no celular, já que as chaves de um dispositivo não servem no outro. O PIN por e-mail permanece disponível como alternativa, em qualquer situação.

Ao autenticar na _dashboard_, o usuário poderá ver a listagem de **projetos dos quais é membro da equipe** e, dentre outras funcionalidades, a [opção de **criar um novo projeto**]({{ site.baseurl }}/docs/project) (caso seja um empregado da Embrapa).

![Listagem de projetos]({{ site.baseurl }}/assets/img/dashboard/02.png)
