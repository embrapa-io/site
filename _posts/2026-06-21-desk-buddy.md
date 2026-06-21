---
layout: post
title: Desk Buddy
subtitle: Um companheiro de mesa, físico e de código aberto, para monitorar a saúde da plataforma.
tags: [ hardware, iot, observabilidade, features ]
---

Apresentamos o **Desk Buddy** — um pequeno dispositivo de mesa que mostra, em tempo real e sem que você precise abrir nada, se a plataforma **Embrapa I/O** está no ar. Ele consome a [Status Page](https://status.embrapa.io) (construída com o [Gatus](https://gatus.io)) e exibe o estado de _clusters_, _hosts_ e serviços num display colorido com toque, dentro de um _case_ impresso em 3D. Tudo de **código aberto**.

<video src="{{ site.baseurl }}/assets/img/posts/20260621011500.mp4" autoplay loop muted playsinline style="max-width:100%;border-radius:8px;"></video>

## O que ele faz hoje

No estado atual, o Desk Buddy funciona como um **monitor do status global da plataforma**, usando a mesma linguagem da Status Page (`Healthy` / `N off`):

- **Visão geral** — _tiles_ de Clusters, Hosts e Serviços, com quantos estão no ar e um veredito **Geral** da plataforma;
- **Listas por grupo** — cada _cluster_, _host_ e serviço com seu estado e latência;
- **Navegação por toque** — menu lateral, relógio e data no topo;
- **Farol físico** — um LED RGB que indica o estado mesmo de longe (verde quando está tudo no ar);
- **Configuração pela própria tela** — Wi-Fi, fuso horário, intervalo de atualização e brilho, sem cabo nem computador.

![Tela de visão geral: status global de clusters, hosts e serviços.]({{ site.baseurl }}/assets/img/posts/20260621010418.jpg)

A leitura é leve: o dispositivo busca apenas a medição mais recente de cada _endpoint_, mantendo o consumo mínimo.

![Tela de sistema: rede, atualização e configuração do dispositivo.]({{ site.baseurl }}/assets/img/posts/20260621010450.jpg)

## Acessível e _open source_

O Desk Buddy é construído sobre um **Cheap Yellow Display (CYD / ESP32)** — um display de toque que custa cerca de **US$ 10** — e um _case_ impresso em 3D a partir de um modelo da comunidade. O firmware é aberto (licença MIT), e **qualquer pessoa pode montar o seu**: basta adquirir a placa, imprimir o _case_ e **gravar o firmware direto pelo navegador**, sem instalar nada.

- **Gravar agora:** [buddy.embrapa.io](https://buddy.embrapa.io)
- **Código-fonte:** [github.com/embrapa-io/desk-buddy](https://github.com/embrapa-io/desk-buddy)

## Leve o Desk Buddy para a sua unidade

Talvez esta seja a parte mais interessante para uso geral pelos colegas de TI das diversas Unidades da Embrapa. A mesma _stack_ de observabilidade que alimenta o [status.embrapa.io](https://status.embrapa.io) está disponível como **_boilerplate_ na plataforma** — qualquer **unidade descentralizada** pode subir a sua: **Grafana** (_dashboards_ e alertas por e-mail), **Loki** (logs), **Prometheus** (métricas), **Alloy** (agente nos _hosts_) e o **Gatus** (a própria página de _status_). Foi exatamente o que fizemos na **Embrapa Gado de Corte**: [status.cnpgc.embrapa.br](https://status.cnpgc.embrapa.br).

![Criando o app da stack de observabilidade a partir do boilerplate, no dashboard.embrapa.io.]({{ site.baseurl }}/assets/img/posts/20260417191204.png)

A página de status é implementada pelo **Gatus**, que já vem incluso na _stack_ e consome as métricas coletadas pelo Prometheus:

![Página de status (Gatus) gerada pela stack — a mesma fonte de dados que o Desk Buddy lê.]({{ site.baseurl }}/assets/img/posts/20260417191616.png)

E é aqui que o **Desk Buddy** se encaixa: como ele **só consome a API do Gatus**, apontá-lo para a _status page_ da sua unidade é **trivial** — uma troca de configuração no _firmware_. Com a sua _stack_ local no ar, ter um monitor físico da **sua** infraestrutura é só um _fork_ e uma gravação:

1. Crie um projeto para a sua unidade no [dashboard.embrapa.io](https://dashboard.embrapa.io) e ative o _boilerplate_ [**`grafana`**](https://git.embrapa.io/io/boilerplate/grafana) — a plataforma faz o _fork_ para você;
2. Faça o _deploy_ da _stack_ e configure a sua **_status page_** (Gatus) com seus _hosts_ e serviços (o README do _boilerplate_ tem o passo a passo);
3. **Faça um _fork_ do [desk-buddy](https://github.com/embrapa-io/desk-buddy)**, aponte para o seu Gatus e grave pelo navegador em [buddy.embrapa.io](https://buddy.embrapa.io).

E não precisa ser só de mesa: trocando o _case_ por um modelo de parede — há projetos prontos, como este [_wall mount_ para CYD](https://makerworld.com/pt/models/2655345-wall-mount-for-cyd-cheap-yellow-display-xtouch) — o mesmo dispositivo vira um **painel de parede**. Uma boa ideia é fixá-lo **do lado de fora do _data center_**, para qualquer um ver o _status_ dos serviços antes mesmo de entrar na sala.

O resultado: cada unidade com o seu próprio **Desk Buddy**, mostrando a saúde dos **seus** ativos — na mesa de quem cuida deles, ou na parede para todos verem. A _stack_ de observabilidade já foi apresentada aos colegas no _space_ **"TI - Embrapa"** — agora o monitor físico pode ir junto.

## Para onde vamos

Hoje o Desk Buddy mostra a saúde **global** da plataforma. A próxima fronteira é trazer essa visão **para o nível de cada projeto**: ao trocar de tela, o desenvolvedor verá **seus ativos digitais**, cada um com um **status de saúde sintetizado**, reunindo num só lugar tudo o que já é monitorado na plataforma:

- **Pipeline** — estágio de validação e _deploy_ de cada _build_ (_alpha_, _beta_, _release_…);
- **Bugs** — incidentes e erros capturados pelo [Sentry](https://bug.embrapa.io);
- **Acessos** — um resumo de uso/_analytics_ do [Matomo](https://hit.embrapa.io);
- **Qualidade** — _issues_ e o _quality gate_ do [SonarQube](https://code.embrapa.io);
- **Segurança** — CVEs e vulnerabilidades conhecidas;

…tudo condensado num **semáforo de saúde por projeto**, com a possibilidade de "entrar" em um deles para ver o detalhe.

> A inteligência fica **na plataforma**, não no dispositivo: um _endpoint_ de agregação reúne pipeline, Sentry, Matomo, SonarQube e CVEs e devolve um resumo enxuto por projeto — exatamente como o Desk Buddy já consome o Gatus hoje. Assim o dispositivo segue simples e barato, e a síntese aproveita as fontes que **já estão integradas** ao _core_ do Embrapa I/O (inclusive expostas via [MCP Servers](https://embrapa.io/docs/mcp/)).

## E os alertas?

Estamos avaliando **alertas configuráveis** para chamar a atenção quando algo realmente cai. A premissa é **avisar sem ser invasivo** num ambiente de trabalho: o aviso visual fica ligado por padrão, e um eventual **alerta sonoro** (o CYD aceita um pequeno alto-falante) seria **curto, opcional e silenciável**, disparado apenas na transição para um incidente — nunca um alarme contínuo.

## Saiba mais

- [**Gravar o firmware →**](https://buddy.embrapa.io)
- [**Repositório no GitHub →**](https://github.com/embrapa-io/desk-buddy)
- [**Status Page →**](https://status.embrapa.io)
