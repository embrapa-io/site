---
layout: page
title: Planejamento
subtitle: Registrando e acompanhando milestones e issues do projeto
---

O [GitLab](https://git.embrapa.br) da plataforma **embrapa.io** possui uma [ferramenta de gestão de projetos integrada](https://statushero.com/blog/project-management-with-gitlab/), baseada na [metodologia de desenvolvimento ágil **Kanban**](https://statushero.com/blog/comparing-scrum-kanban-lean/). Assim, é possível planejar as versões do ciclo-de-vida das aplicações por meio do [registro de _milestones_](https://docs.gitlab.com/ee/user/project/milestones/). As tarefas a serem executadas em cada _milestone_ são [registradas e atribuídas por meio de _issues_](https://docs.gitlab.com/ee/user/project/issues/).

Para iniciar o planejamento do desenvolvimento, é recomendado estabelecer a versão almejada no ciclo atual de desenvolvimento e registrá-la como um _milestone_. O nome da versão e, portanto, o nome do _milestone_, deverá respeitar as regras de nome de versão da plataforma [explicitadas na introdução]({{ site.baseurl }}/docs/introduction#version). Por exemplo, se este é o 3º macro-ciclo de desenvolvimento do projeto e se o cronograma deste ciclo de desenvolvimento finaliza em **outubro de 2022**, poderia ser proposto um _milestone_ denominado "**3.22.10**".

![Criação de um milestone]({{ site.baseurl }}/assets/img/kanban/01.png)

As _issues_ que serão registradas para este _milestone_ são organizadas por meio de rótulos (_labels_). Quando um novo projeto é criado na plataforma, é atribuído um conjunto inicial de _labels_. Dentre elas, algumas _labels_ irão formar a _board_ do projeto, que possibilitará acompanhar a evolução das _issues_ de seu registro no _backlog_ até a conclusão.

![Board do projeto]({{ site.baseurl }}/assets/img/kanban/02.png)

Na _board_ do projeto, mostrada na figura acima, existem 6 (seis) colunas. São elas:

1. **_Open_:** Esta é a coluna de _backlog_ do projeto e nela são registradas todas as demandas do projeto (que podem ou não ser atendidas). Existem dois _labels_ disponíveis para qualificar estas demandas: _Bug_ e _Request_.
2. **_To Do_:** Quando a _issue_ sai da coluna de _backlog_ para esta coluna significa que ela será executada. É necessário, portanto, atribuir esta _issue_ a um _milestone_ aberto, atribuir um responsável da equipe pela execução e determinar o prazo limite.
3. **_Doing_:** Quando o desenvolvedor responsável pela _issue_ começa a executá-la, ele deve mudá-la para esta coluna.
4. **_Alpha_:** Quando a codificação da _issue_ está finalizada ela deve ser disponibilizada para os testes internos mudando para esta coluna.
5. **_Beta_:** Após passar pelos testes internos, a _issue_ deve mudar para esta coluna de forma a ser disponibilizada para testes externos.
6. **_Closed_:** Quando a _issue_ passa pelos testes externos ela pode ser encerrada. Neste momento é possível atribuir três qualificadores a ela:
 - _Release_: Ou seja, a implementação está apta a entrar em produção;
 - _On Hold_: Caso esta _issue_ esteja suspensa; e
 - _Invalid_: Caso a execução da _issue_ tenha sido cancelada por qualquer motivo.

![Alteração de uma issue]({{ site.baseurl }}/assets/img/kanban/03.png)

Como uma _issue_ inicial a ser registrada e atribuída, sugerimos a [configuração do _error tracking_]({{ site.baseurl }}/docs/bug) em cada aplicação do projeto. Uma vez configurado, os erros começarão a ser registrados mesmo em ambiente de desenvolvimento.
