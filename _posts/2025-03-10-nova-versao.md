---
layout: post
title: Novo Patch 1.25.2-beta.2
subtitle: Web Terminal e recursos dos clusters
# cover-img: /assets/img/dashboard/02.png
# thumbnail-img: /assets/img/icon-back.png
# share-img: /assets/img/icon-back.png
tags: [ releases, features ]
---

Foi disponibilizada um novo _patch_ para a versão `1.25.2` do **Embrapa I/O** com algumas funcionalidades complementares.

Para aprimorar a funcionalidade do relatório de análise estática do código (advinda da integração com o [SonarQube](https://www.sonarsource.com/products/sonarqube/)), foi disponibilizado nos _cards_ de projetos um novo recurso visual para exibir de forma simplificada e gráfica as **linguagens de programação que predominam nas aplicações**:

![Gráfico de linguagens de programação predominantes]({{ site.baseurl }}/assets/img/posts/20250310154339.png)

Os _clusters_ de _deploy_ de aplicações ganharam alguns novos recursos e, como são opcionais, agora no [wizard de configuração da _build_]({{ site.baseurl }}/docs/build), no passo de exibição de informações/escolha do _cluster_, aparecem quais recursos estão disponíveis:

![Recursos do cluster]({{ site.baseurl }}/assets/img/posts/20250310154639.png)

Os recursos possíveis de serem habilitados são:

- **SMTP:** Se há um servidor de SMTP para envio de e-mails associado a este _cluster_. Se existir, as informações para conexão estarão na subseção logo abaixo.

- **IP Público:** Se o _cluster_ possui um IP Público. Caso possua, é possível o acesso direto às portas provisionadas para os serviços e, com isso, disponibilizar nele serviços não-HTTP, tal como _brokers_ IoT (MQTT, CoAP, AMQP, XMPP, etc). Caso não possua, todas as aplicações neste _cluster_ estarão acessíveis apenas pelo provisionamento HTTPS que o **Embrapa I/O** faz (roteando o tráfego pelo balanceador de carga via _virtual proxy_).

- **Web Terminal:** Se o _cluster_ suporta o Web Terminal, uma nova funcionalidade que será detalhada logo abaixo.

- **Registro:** Se o _cluster_ possui registro local para as imagens dos containers. O **Embrapa I/O** não possui um registro centralizado das imagens. Porém, é possível contornar isso utilizando o registro local do _cluster_, caso esteja disponível.

- **Backup:** Se existe neste _cluster_ processo automatizado e individualizado de _backup_ das aplicações.

- **Snapshot:** Se é realizado o backup do tipo _snapshot_ na(s) VM(s) do _cluster_ em questão.

> **Atenção!** Repare que o recursos de _backup_ difere do recurso de _snapshot_. No primeiro, caso esteja disponível, será possível a recuperação de aplicações específicas, de forma individualizada. No segundo, o _restore_ da VM é realizada em caso de um problema crítico, que afete o _cluster_ como um todo.

Por fim, foi disponibilizado o recurso de **Web Terminal** na dashboard do Embrapa I/O. Assim, é possível agora acessar remotamente os _containers_ via terminal utilizando o `ash`, `bash`, `dash` ou `sh`:

![Web Terminal]({{ site.baseurl }}/assets/img/posts/Terminal.gif)

> **Atenção!** Esta funcionalidade ainda é "**experimental**", portanto deve ser utilizada com cautela e informado qualquer problema.

Conforme mencionado acima, o recurso do Web Terminal precisa estar habilitado no _cluster_ e, portanto, é necessário verificar no momento da [configuração da _build_ para _deploy_]({{ site.baseurl }}/docs/build) se está disponível no cluster preterido.
