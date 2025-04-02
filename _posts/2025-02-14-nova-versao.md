---
layout: post
title: Lançamento da Versão 1.25.2
subtitle: Integração com o SonarQube e Grafana Loki, dentre outros
# cover-img: /assets/img/dashboard/02.png
# thumbnail-img: /assets/img/icon-back.png
# share-img: /assets/img/icon-back.png
tags: [ releases, features ]
---

Foi disponibilizada uma nova versão do **Embrapa I/O** (a `1.25.2`) com algumas novidades. As principais, que serão detalhadas a seguir, são:
- A possibilidade de **revalidação** de uma _build_ marcada como "inválida" por qualquer membro do projeto (e não apenas Arquitetos de Solução);
- A integração com o **SonarQube** para aprimoramento do monitoramento de qualidade de código (e, consequentemente, do ativo como um todo); e
- A integração com o **Grafana Loki** para _logging_ em tempo real dos ativos instanciados nos _clusters_ da plataforma.

## I. Revalidação de _builds_

Uma demanda das equipes dos projetos era a possibilidade de membros comuns poderem disparar o processo de validação de uma _build_ quando esta era marcada como "inválida" durante o processo de _deploy_. Quando isso ocorre, o _pipeline_ fica parado, aguardando a eventual correção dos problemas apontados. Entretanto, para disparar novamente o processo de validação (e posterior _deploy_) era necessário que um "Arquiteto da Solução" da equipe do projeto refizesse os passos do [_wizard_ de configuração da _build_]({{ site.baseurl }}/docs/build) (ainda que nada fosse alterado).

Com esta mudança, qualquer membro do projeto pode agora efetuar a correção do erro, fazer o _merge_ na _branch_ de _deploy_ e, em seguida, clicar sobre o ícone de "inválido" do _status_ da _build_ e selecionar a opção "**revalidar**". Com isso os _pipelines_ do **Embrapa I/O** voltam a ser executados, validando e fazendo o _deploy_ automático da _build_ (caso esteja tudo certo).

![Revalidar a build]({{ site.baseurl }}/assets/img/posts/20250214143353.png)

Observação: Os membros do projeto que não sejam "Arquitetos da Solução" conseguem utilizar este recurso apenas em _builds_ em estágio de _alpha_ e _beta_, ou seja, em _release_ (produção) ainda será necessário a intervenção do Arquiteto.

## II. Integração com o SonarQube

Foi realizada uma integração completa do **Embrapa I/O** com o [SonarQube](https://www.sonarsource.com/products/sonarqube/), que é uma ferramenta de análise estática de código que detecta _bugs_, vulnerabilidades e problemas de qualidade de software.

Ao acessar a [_dashboard_ da plataforma](http://dashboard.embrapa.io) será mostrado agora, para cada aplicação de cada projeto, uma aba com _scores_:

![Scores do SonarQube na dashboard do Embrapa I/O]({{ site.baseurl }}/assets/img/posts/20250214143649.png)

Estes _scores_ medem (da esquerda para a direita): **manutenibilidade do código**, **confiabilidade**, **segurança**, **vulnerabilidade** e, por fim, se sua versão mais nova foi "**aprovada para entrega**". Este último _score_ (chamado pelo [SonarQube de _Quality Gate_](https://docs.sonarsource.com/sonarqube-server/latest/instance-administration/analysis-functions/quality-gates/)) é um conjunto de regras que determina se um código-fonte enviado atende a determinado padrões de qualidade, <u>podendo ser aprovado ou reprovado</u>.

![Quality Gate sendo mostrado na dashboard do Embrapa I/O]({{ site.baseurl }}/assets/img/posts/20250214144023.png)

Ao clicar sobre qualquer um dos ícones, o desenvolvedor será levado à interface do SonarQube (disponível em [https://code.embrapa.io](https://code.embrapa.io)), na qual pode autenticar utilizando a conta do [GitLab do **Embrapa I/O**](https://git.embrapa.io):

![Login no SonarQube]({{ site.baseurl }}/assets/img/posts/20250214163129.png)

Ali será possível visualizar detalhes das _issues_ e corrigí-las de forma apropriada.

![Visualização dos detalhes de uma issue no SonarQube]({{ site.baseurl }}/assets/img/posts/20250214144451.png)

Por padrão, o SonarQube está configurado para examinar todos os _commits_ apenas na _branch_ `main`, entretanto é possível estender para outras _branches_ editando o arquivo `.gitlab-ci.yml`, presente na raiz do repositório da aplicação. O monitoramento de todo ativo digital no **Embrapa I/O** é automaticamente configurado pela plataforma e não demanda nenhuma ação dos desenvolvedores.

## III. _Logging_ utilizando o Grafana Loki

Outra integração realizada foi com o [Grafana Loki](https://grafana.com/docs/loki/latest/), um sistema de _logging_ escalável e eficiente, otimizado para armazenar e consultar _logs_ de forma rápida, sem necessidade de indexação pesada, e integrado ao [Grafana](https://grafana.com) para visualização.

Toda _stack_ de _containers_ de aplicações instanciadas na rede de _clusters_ do **Embrapa I/O** tem seus _logs_ capturados, que podem ser visualizados em tempo real pela equipe do projeto. Há duas formas de acessar diretamente a _dashboard_ no Grafana (disponível em [https://log.embrapa.io](https://log.embrapa.io)) com os _logs_ de determinada aplicação: diretamente pelo ícone no _card_ do projeto (que mostrará todas as _dashboards_ daquele projeto) ou no _dialog_ de monitoramento da saúde da _build_:

![Acessando a dashboard no Grafana com os logs da build]({{ site.baseurl }}/assets/img/posts/20250214145254.png)

O _login_ no Grafana é realizado também utilizando a conta do [GitLab do **Embrapa I/O**](https://git.embrapa.io):

![Login no Grafana]({{ site.baseurl }}/assets/img/posts/20250214163228.png)

A plataforma configura automaticamente, para cada aplicação de cada projeto, as _dashboards_ de visualização dos _logs_, não sendo necessário portanto nenhuma configuração pela equipe de desenvolvedores do projeto. Os _logs_ serão exibidos da mesma forma que são gerados pelo comando `docker compose logs [container] -f` em ambiente de desenvolvimento. Portanto, para realizar o _debug_ da aplicação, basta imprimir a saída no _stdout_.

![Logs sendo mostrados na dashboard do Grafana]({{ site.baseurl }}/assets/img/posts/20250214145549.png)

Observação: Para que os _logs_ passem a ser capturados é necessário que a _stack_ de _containers_ tenha passado pelo processo de _build_ e _deploy_ no _cluster_ após a implantação do monitoramento. Se tiver dúvida quanto a isso, pode-se forçar um novo _deploy_ criando uma nova [_tag_ de versão na _branch_ correlata]({{ site.baseurl }}/docs/deploy).
