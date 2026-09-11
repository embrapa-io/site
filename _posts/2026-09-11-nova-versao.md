---
layout: post
title: Lançamento da Versão 1.26.9
subtitle: Login por biometria, remoção de aplicações e mais autonomia para as equipes.
# cover-img: /assets/img/dashboard/02.png
# thumbnail-img: /assets/img/icon-back.png
# share-img: /assets/img/icon-back.png
tags: [ releases, features ]
---

Foi disponibilizada uma nova versão do **Embrapa I/O** (a `1.26.9`) com novidades. Em resumo, temos as seguintes novas funcionalidades e melhorias:

1. [Login por biometria com _passkeys_](#passkey);
2. [Remoção de aplicações de um projeto](#remove);
3. [Saída voluntária da equipe de um projeto](#leave);
4. [Catálogo detalhado dos GPU Servers na configuração da _build_](#gpu); e
5. [Limites para a criação de projetos](#limits).

A seguir, são detalhadas cada uma delas.

## 1. Login por biometria com _passkeys_ {#passkey}

Até agora, entrar no **Embrapa I/O** exigia aguardar um PIN de seis dígitos por e-mail a cada acesso. A partir desta versão é possível autenticar-se com a **biometria do próprio dispositivo** — Touch ID, Face ID, Windows Hello ou o leitor digital do celular.

A tecnologia por trás disso são as [_passkeys_](https://fidoalliance.org/passkeys/), um padrão aberto da FIDO Alliance que substitui senhas por um par de chaves criptográficas. A chave privada **nunca sai do aparelho** e não é conhecida pela plataforma: o que trafega é apenas uma assinatura, que prova a posse da chave sem revelá-la. Não há, portanto, senha que possa vazar em um banco de dados.

![Botão de login com biometria na tela de acesso]({{ site.baseurl }}/assets/img/posts/20260911-passkey-login.png)

No primeiro acesso por PIN em um dispositivo, a plataforma convida o usuário a cadastrar a biometria. O cadastro também pode ser feito — ou desfeito — a qualquer momento pela tela de dados pessoais.

![Cadastro da biometria no perfil do usuário]({{ site.baseurl }}/assets/img/posts/20260911-passkey-perfil.png)

Vale destacar que a credencial é criada **por aparelho**: quem cadastrar a biometria no computador continuará sendo convidado a cadastrá-la também no celular, já que as chaves de um dispositivo não servem no outro. O PIN por e-mail permanece disponível como alternativa, em qualquer situação.

## 2. Remoção de aplicações de um projeto {#remove}

Uma aplicação criada por engano, um protótipo que não vingou ou um módulo absorvido por outro: até esta versão, não havia como retirá-los de um projeto. Agora um _Architect_ pode **remover uma aplicação**, mantendo o projeto e as demais aplicações intactas.

![Opção de remover no menu contextual do projeto]({{ site.baseurl }}/assets/img/posts/20260911-remover-menu.png)

A remoção desfaz a configuração da aplicação na plataforma — variáveis de ambiente, volumes, histórico de _builds_ e as portas reservadas nos _clusters_ —, mas **preserva o código-fonte**: o repositório é arquivado no [GitLab](https://git.embrapa.io) e renomeado com a data da remoção. As integrações com _bug tracking_, analítica, qualidade de código e observabilidade também permanecem intactas.

Graças a isso, **é possível criar depois uma nova aplicação com o mesmo nome** — inclusive a partir de outro _boilerplate_ —, e ela reaproveitará todo o histórico de erros e de acessos que já existia.

Por ser uma ação destrutiva, a remoção exige que nenhuma _build_ esteja instanciada e é confirmada por um PIN enviado ao e-mail do _Architect_.

![Diálogo de confirmação da remoção]({{ site.baseurl }}/assets/img/posts/20260911-remover-dialogo.png)

O procedimento completo está descrito na [documentação de remoção de aplicações]({{ site.baseurl }}/docs/remove).

## 3. Saída voluntária da equipe de um projeto {#leave}

Quem deixa de atuar em um projeto já podia ser removido por um _Architect_ — mas dependia dele. Agora **qualquer membro pode sair da equipe por conta própria**, pela opção "Sair do Projeto" no menu contextual do _card_.

![Opção de sair do projeto no menu contextual]({{ site.baseurl }}/assets/img/posts/20260911-sair-menu.png)

Ao sair, o usuário perde o acesso ao projeto na _dashboard_ e é retirado do grupo de repositórios no GitLab e das ferramentas integradas. Há uma única exceção: o **último _Architect_ não pode sair**, porque o projeto ficaria sem ninguém capaz de administrá-lo — nesse caso, a plataforma orienta a promover outro membro ou a [arquivar o projeto]({{ site.baseurl }}/docs/archive).

## 4. Catálogo detalhado dos GPU Servers na configuração da _build_ {#gpu}

Os [GPU Servers]({{ site.baseurl }}/docs/cluster) da plataforma, que permitem às aplicações utilizarem modelos de linguagem (LLMs) hospedados na infraestrutura da Embrapa, passam a ser apresentados em **detalhe no _wizard_ de configuração da _build_**.

Em vez de uma única opção genérica, o catálogo agora traz um painel por servidor, com o modelo de GPU disponível, a memória e os modelos servidos em cada um. Assim a equipe escolhe o servidor adequado ao seu caso de uso com a informação à vista.

![Catálogo de GPU Servers no wizard da build]({{ site.baseurl }}/assets/img/posts/20260911-gpu-servers.png)

## 5. Limites para a criação de projetos {#limits}

O nome _unix_ de um projeto é **permanente** — ele identifica o grupo no GitLab, a organização no _bug tracking_, o site na analítica e os painéis de observabilidade. Um projeto criado por engano ocupa esse nome para sempre.

Para reduzir o dano de criações acidentais — e também o de uma eventual credencial comprometida —, a plataforma passa a aplicar **dois limites**: um intervalo mínimo entre criações sucessivas e um teto diário de projetos por usuário. Os limites valem para todos, inclusive administradores.

Quando um limite é atingido, a _dashboard_ explica o motivo e o que fazer — lembrando, por exemplo, que **um único projeto comporta diversas aplicações**, e que criar vários projetos raramente é o caminho.

---

Além dessas novidades, esta versão traz correções e melhorias menores: o arquivamento de projetos passou a descartar corretamente as aplicações que nunca chegaram a ser criadas, as mensagens de erro da autenticação ganharam texto compreensível no lugar dos códigos técnicos, e a página "Sobre" foi revista com a atribuição correta da autoria da plataforma.

Como sempre, [estamos à disposição]({{ site.baseurl }}/docs/support) para dúvidas, críticas e sugestões.
