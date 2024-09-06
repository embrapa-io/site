---
layout: page
title: Ferramentas
subtitle: Ferramentas úteis para o desenvolvimento de ativos digitais
---

A plataforma **Embrapa I/O** faz uso de uma abordagem de desenvolvimento local, sendo portanto necessário o uso de algumas ferramentas para executar localmente as aplicações em desenvolvimento. Esta estratégia possui [vantagens e desvantagens](https://www.bunnyshell.com/blog/local-development-vs-remote-development/), se comparada com o chamado _remote software development_, sendo os principais benefícios o _feedback_ imediato, o acesso _offline_, a privacidade e segurança e a depuração facilitada.

Em contrapartida, pesa em desfavor o fato do ambiente local ser inevitavelmente distinto quanto à desempenho, escalabilidade, plataforma e dados em relação aos ambientes de teste, homologação e produção. Neste contexto, a conteinerização tem o papel fundamental de mitigar estas discrepâncias, tornando os ambientes local e remotos fidedignos mutuamente.

Por conta disso, o [Docker](https://docker.com) é provavelmente a ferramenta mais importante e comum a todos os projetos desenvolvidos por meio do **Embrapa I/O**, mas existem muitas outras que podem apoiar as diversas atividades do processo de desenvolvimento de ativos digitais agropecuários. Listaremos algumas delas a seguir.

## Docker

Todos os _boilerplates_ do **Embrapa I/O** são homologados no [Docker](https://docker.com). Além disso, em ambiente remoto (_alpha_, _beta_ e _release_) será sempre utilizado o Docker para fazer a _build_ dos containers, gerando as imagens que farão _deploy_ nos orquestradores. Por conta disso, é fortemente recomendado o seu uso ao invés de alternativas como o [Podman](https://podman.io).

Em todos os servidores remotos é padronizado o uso de Linux em arquitetura AMD64 (`linux/amd64`), [sendo sugerido o uso das distribuições Debian ou Ubuntu]({{ site.baseurl }}/docs/cluster). Assim, é fortemente recomendado que seu ambiente local tenha este sistema operacional, nesta arquitetura e, se possível, em uma destas distribuições, seja nativamente ou por meio de uma máquina virtual.

Caso esteja utilizando um computador com Windows, sugere-se a [instalação e uso do WSL2](https://learn.microsoft.com/pt-br/windows/wsl/install) (do inglês, _Windows Subsystem for Linux_). Por meio desta ferramenta, oficial do ecossistema da  Microsoft, será possível executar máquinas virtuais Linux com compartilhamento automático do sistema de arquivos e roteamento de portas.

> **Atenção!** Desde 2019 que o uso do [Docker Desktop](https://www.docker.com/products/docker-desktop/) possui [sérias limitações]({{ site.baseurl }}/2022-01-20-alternativas-ao-docker-desktop) em função de sua licença, portanto não deve-se utilizá-lo no desenvolvimento de ativos digitais que tenham finalidade comercial.

Caso esteja utilizando um computador com MacOS, sugere-se a [instalação e uso do Lima](https://github.com/lima-vm/lima), que se propõe a ser similar ao WSL2.
