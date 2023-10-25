---
layout: page
title: Monitoramento
subtitle: Acompanhando e gerindo a build no ambiente remoto
---

<iframe width="730" height="410" src="https://www.youtube.com/embed/0skE1rcQVI4" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

Após realizar o [_deploy_ de uma _build_ em ambiente remoto]({{ site.baseurl }}/docs/deploy), novas funções estarão disponíveis no _card_ da aplicação no [_dashboard_ da plataforma]({{ site.baseurl }}/docs/dashboard) para auxiliar a equipe de desenvolvimento no monitoramento e gestão da instância.

![Dialog de monitoramento e gestão da instância]({{ site.baseurl }}/assets/img/health/01.png)

Conforme [detalhado na arquitetura da plataforma]({{ site.baseurl }}/docs/arch), o **Embrapa I/O** possui um autômato de _health check_ das instâncias denominado _Doctor_. Este agente executa um processo a cada minuto atualizando as informações sobre o _status_ de execução de cada _container_ em cada _stack_ de cada aplicação instanciada pela plataforma. O resultado deste monitoramento pode ser visto no _dialog_ mostrado na imagem acima.

Além de exibir o **estado de saúde** de todos os _containers_ da instância, é possível executar algumas ações de gestão:

- **Higienizar/otimizar periodicamente:** Quando esta opção é ativada, o autômato _Doctor_ irá executar o serviço ```sanitize``` do _stack_ de _containers_ da instância. Caso este serviço não esteja presente ou apresente erro na execução, a opção é automaticamente desabilitada. Caso execute com sucesso, é agendado uma nova execução **mensal** do serviço. Mais informações sobre os processos de higienização/otimização dos _containers_ podem ser encontradas [no tutorial de criação de _boilerplates_]({{ site.baseurl }}/docs/boilerplate).

- **Diagnosticar:** ...

- **Reiniciar:** Os mantenedores do projeto podem executar a ação de reiniciar o _stack_ de _containers_ da instância por meio deste botão.

- **Desativar:** Caso seja necessário "desligar" a instância, deixando-a _offline_, os mantenedores do projeto podem utilizar esta funcionalidade. Uma instância desligada por ser novamente ativada por meio do botão "**Reiniciar**".

- **Backup**: É possível aos mantenedores do projeto gerar um backup da instância a qualquer momento. Ná prática o autômato _Doctor_ irá executar o serviço ```backup``` do _stack_ de _containers_. Para entender os detalhes deste processo, veja a [documentação específica sobre _backups_ de instâncias]({{ site.baseurl }}/docs/backup).
