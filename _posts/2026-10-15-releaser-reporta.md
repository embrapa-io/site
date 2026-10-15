---
layout: post
title: "Releaser: as builds dos servidores externos chegam à dashboard"
subtitle: Versão, saúde dos serviços e vulnerabilidades das apps implantadas pelo Releaser agora aparecem no card do projeto, e alimentam a Sentinela.
tags: [ releases, devops, releaser ]
---

Muitas aplicações da plataforma rodam em servidores das Unidades e de parceiros, implantadas pelo [**Releaser**]({{ site.baseurl }}/docs/releaser). Até ontem, essas _builds_ ficavam invisíveis para a _dashboard_ do **Embrapa I/O**: sem versão no _card_, sem saúde dos serviços e sem varredura de vulnerabilidades. _Logs_, erros e acessos funcionavam, pois Loki, Sentry e Matomo são configurados pela própria equipe, mas o Trivy só alcançava os _clusters_ da plataforma.

A versão `1.26.10-2` do Releaser fecha essa lacuna. A partir dela, cada servidor **reporta à plataforma** o que sabe sobre as _builds_ que implanta, e a _dashboard_ passa a mostrá-las como mostra os estágios dos _clusters_:

![Card com os estágios release e beta vindos do Releaser e o alpha na plataforma]({{ site.baseurl }}/assets/img/releaser/20261015091339.png){: width="60%" .img-center }

- a **versão** aparece em laranja, com o ícone de servidor, para distinguir dos estágios da plataforma, em ciano. Passe o mouse para ver em qual servidor a _build_ está e quando foi o último contato;
- o **coração** passa a considerar a **saúde dos serviços** (estado e _healthcheck_ dos _containers_) e as **CVEs** das imagens em execução, para todos os estágios, da plataforma ou do Releaser;
- o **Health Check** mostra os serviços, a origem e as vulnerabilidades encontradas pelo Trivy, que agora roda no próprio servidor, hora em hora.

![Health Check de uma build implantada pelo Releaser]({{ site.baseurl }}/assets/img/releaser/20261015091353.png){: width="80%" .img-center }

Esses dados também alimentam a [Sentinela]({{ site.baseurl }}/docs/sentinel), lançada hoje: os relatórios do projeto passam a incluir as _builds_ do Releaser, com suas CVEs e sua saúde, e não só as da plataforma.

## O que você precisa fazer {#update}

**Apenas atualizar a imagem**, seguindo o [procedimento de sempre]({{ site.baseurl }}/docs/releaser#update). A autenticação usa o mesmo _token_ do GitLab que o Releaser já tem, e as _builds_, o `.env` e as chaves do diretório de configuração continuam valendo. Um minuto depois da atualização, os estágios aparecem no _card_.

O que cada _build_ reporta é controlado pelo atributo `stats` do seu arquivo de configuração, com tudo ligado por padrão. Faz sentido desligar a varredura de CVEs (`"cve": false`) em servidores pequenos ou sem acesso ao `ghcr.io`, de onde o Trivy baixa o banco de vulnerabilidades.

Um detalhe: um estágio é implantado pela plataforma **ou** por um Releaser, nunca pelos dois. Se uma _build_ antiga ficou configurada num servidor depois de migrada para a plataforma, o relato dela é recusado e o `io info` mostra o motivo. É a hora de removê-la do servidor.

## Mais duas novidades {#more}

A mesma versão traz duas mudanças na configuração do Releaser:

- **Um arquivo por _build_.** Em vez de um único `builds.json`, cada _build_ é um arquivo em `builds/<projeto>_<app>_<estágio>.json`. Para desativar uma _build_ sem perder a configuração, basta renomear o arquivo para `.bkp`. O `builds.json` antigo continua funcionando, e o comando `io split` migra quando você quiser.
- **`io install`.** Configuração guiada de uma _build_ nova: escolhe o projeto, a _app_ e o estágio por menus, busca na plataforma a equipe, o DSN do Sentry, o site e o _token_ do Matomo e as variáveis do `settings.json` da aplicação, gera senhas aleatórias e a próxima porta livre, e grava o arquivo pronto para o primeiro _deploy_. Nada mais de copiar DSN e _token_ à mão.

Tudo está detalhado no capítulo do [Releaser]({{ site.baseurl }}/docs/releaser) da documentação. Dúvidas e problemas na atualização, como sempre, na [sala Arquitetos de Soluções](https://chat.google.com/room/AAAA853zctw?cls=11) do Google Chat.
