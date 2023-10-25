---
layout: post
title: Alternativas ao Docker Desktop
subtitle: Ferramentas para trabalhar com o Docker em ambiente de desenvolvimento
# cover-img: /assets/img/dashboard/02.png
# thumbnail-img: /assets/img/icon-back.png
# share-img: /assets/img/icon-back.png
tags: [ tips ]
---

Em agosto de 2019 o [Docker Desktop](https://www.docker.com/products/docker-desktop/) alterou sua licença de uso. Com isso, ele se tornou pago para qualquer empresa com mais de 250 funcionários.

É importante no entanto ressaltar que o **Docker Desktop** (exlusivo para Windows e MacOS) é diferente do **Docker CLI** (exclusivo para Linux). Este último não sofreu qualquer alteração e continua um software livre. Assim, quem utiliza o Docker para desenvolver em Linux não precisa se preocupar em tomar qualquer ação. Quem, no entanto, utiliza o Docker em MacOS e Windows está, provavelmente, utilizando a versão Desktop. Neste caso ele precisa ser regularizado até o dia 31 deste mês, quando se extingue o prazo de anistia. Na prática, é necessário remover dos computadores da Embrapa todas as instalações do Docker Desktop.

Assim, para continuarmos utilizando o Docker será necessário uma alternativa para rodar o Docker CLI em Windows e MacOS. No caso do Windows, uma solução é utilizar o [WSL2](https://learn.microsoft.com/pt-br/windows/wsl/), que é nativo ao sistema operacional. A instância padrão, com Ubuntu, atende bem.

No caso do MacOS, uma alternativa é utilizar o [Lima](https://lima-vm.io/), que pode ser instalado pelo [Homebrew](https://brew.sh). Ele se integra perfeitamente ao SO hospedeiro e tem um bom desempenho. Também utiliza o Ubuntu como instância _default_, o que padroniza um pouco as coisas. A proposta dele é ser "WSL2 para MacOS" e atende bem.

Em ambos os casos, para Windows e MacOS, perde-se apenas a UI. Entretanto ela pode ser substituída, p.e., pelo [Portainer](https://portainer.io) ou pelo [Rancher Desktop](https://rancherdesktop.io).
