---
layout: page
title: Deploy
subtitle: Fazendo o deploy da build no ambiente remoto
---

<iframe width="730" height="410" src="https://www.youtube.com/embed/gY3_lgV4U4U" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

Uma vez que a configuração da _build_ tenha sido validada com sucesso, ela está apta a entrar na fila de _deploy_ para ser instanciada no servidor remoto. Para o _deploy_ não é necessário utilizar a [_dashboard_ da plataforma](https://dashboard.embrapa.io), sendo o processo executado diretamente pelo [GitLab](https://git.embrapa.io) ou pelo cliente GIT de sua preferência. Conforme já visto, quando uma nova aplicação é adicionada na plataforma são criadas 4 (quatro) _branches_ em seu repositório GIT: _main_, _alpha_, _beta_ e _release_. Como detalhado no [capítulo de introdução]({{ site.baseurl }}/docs/introduction#build), a _branch_ denominada "_main_" é o tronco (_trunk_) do repositório. As outras três _branches_ são utilizadas pela o _deploy_ de cada um dos estágios de maturidade da aplicação.

Assim, em linhas gerais, para realizar o _deploy_ de uma _build_, bastará ao desenvolvedor realizar o _merge_ da _branch_ "_main_" para a _branch_ do estágio da _build_ e, em seguida, criar um _tag_ com o número de versão da _build_.

> **Atenção!** A _tag_ com o número de versão da _build_ deve ser criada a partir da _branch_ de estágio (_alpha_, _beta_ ou _release_).

A plataforma é criteriosa quanto ao formato do número de versão da _tag_. Já explicamos a sintaxe do número de versão no [capítulo de introdução]({{ site.baseurl }}/docs/introduction#version). Caso a versão não esteja no formato requerido ou a _tag_ não seja originária da _branch_ de estágio correlato, o _deploy_ **não será realizado**.

![Realizando o deploy de uma versão de build]({{ site.baseurl }}/assets/img/deploy/01.gif)

Ao fazer o _push_ da _tag_ para a _origin_, o autômato irá detectar a nova versão e iniciar o processo de _deploy_ no ambiente. Este processo envolve as seguintes etapas:

1. Validação da _build_ na versão específica;
2. Criação da _network_ da _stack_ de containers;
3. Criação dos _volumes_ no servidor de _storage_;
4. Backup dos dados da instância atual da _build_;
5. Construção (p.e., `docker compose build`) dos serviços da _stack_ de containers; e
6. Inicialização (p.e., `docker compose run`) dos serviços no _cluster_.

> **Atenção (a)!** A execução do **backup** durante o processo de deploy (item 4) possui um tempo limite de **1 hora**. Caso não seja concluído neste período, a execução do backup é interrompida, mas o processo de deploy continua.

> **Atenção (b)!** A **construção dos serviços** (item 5) possui um tempo limite de **15 minutos**. Caso não seja concluído neste período, o processo de deploy é interrompido e a build é marcada como inválida.

Um e-mail será enviado aos membros da equipe do projeto com os _logs_ do processo executado, semelhante ao abaixo:

```
INFO > New tag found to build 'pbc/mobile@alpha'!
INFO > Updating from 2.22.5-alpha.4 to 2.22.5-alpha.5, commited by Camilo Carromeu <camilo.carromeu@embrapa.br> at 2022-06-13T09:34:57.000-04:00.
INFO > Checking if new tag has been created from branch 'alpha'... ok!
WARNING > No related milestone found! Has good practice, a milestone named '2.22.5' is required to manage issues releated to this release.
INFO > Trying to load '.embrapa/settings.json' from remote repository... done!
INFO > Trying to load metadata info...
INFO > Metadata info of boilerplates, clusters and types loaded!
INFO > New version will be deployed as 'container' using orchestrator 'DockerCompose' at server 'cluster.sede.embrapa.br'!
INFO > CI/DI environment variables:

COMPOSE_PROJECT_NAME=pbc_mobile_alpha
COMPOSE_PROFILES=alpha
IO_SERVER=cluster.sede.embrapa.br
IO_PROJECT=pbc
IO_APP=mobile
IO_STAGE=development
IO_VERSION=2.22.5-alpha.5
IO_DEPLOYER=camilo@carromeu.com
SENTRY_DSN=https://6389eb20b717423344fea535c489ef93@bug.embrapa.io/47
MATOMO_ID=2
MATOMO_TOKEN=e4c42495a19e1c63ecaa7e1c7285d599

INFO > Trying to clone app... done!
INFO > Checking SSH connection to host 'cluster.sede.embrapa.br'... ok!
INFO > Validating Docker Compose file:
COMMAND > env $(cat .env.ci) DOCKER_HOST="ssh://root@cluster.sede.embrapa.br" /usr/bin/docker-compose config
INFO > Trying to validate declared VOLUMEs and PORTs...
INFO > All published PORTs are valid!
COMMAND > env $(cat .env.cli) DOCKER_HOST="ssh://root@cluster.sede.embrapa.br" /usr/bin/docker-compose config --services
WARNING > Some CLI recomended services are NOT FOUND at docker-compose.yaml: restore, sanitize, test! Please, check configuration.
WARNING > File docker-compose.yaml is VALID, but has some alerts to fix!
INFO > Trying to execute backup service before deploy...
COMMAND > env $(cat .env.cli) DOCKER_HOST="ssh://root@cluster.sede.embrapa.br" /usr/bin/docker-compose build --force-rm --no-cache backup
COMMAND > env $(cat .env.cli) DOCKER_HOST="ssh://root@cluster.sede.embrapa.br" /usr/bin/docker-compose run --rm --no-deps backup
Creating pbc_mobile_alpha_backup_run ...
Creating pbc_mobile_alpha_backup_run ... done
SUCCESS > Backup service executed successfully!
INFO > Building application with Docker Compose...
COMMAND > set -e && env $(cat .env.ci) DOCKER_HOST="ssh://root@cluster.sede.embrapa.br" /usr/bin/docker-compose up --force-recreate --build --no-start && echo "Exit code: $?"
Successfully built c0ddfaae85a5
Successfully tagged pbc_mobile_alpha_pwa:latest
Exit code: 0
INFO > Getting valid services (will ignore: backup, restore, sanitize, test)...
COMMAND > env $(cat .env.ci) DOCKER_HOST="ssh://root@cluster.sede.embrapa.br" /usr/bin/docker-compose config --services
INFO > Starting application with Docker Compose...
COMMAND > env $(cat .env.ci) DOCKER_HOST="ssh://root@cluster.sede.embrapa.br" /usr/bin/docker-compose start pwa
SUCCESS > All done! Version '2.22.5-alpha.5' in 'alpha' stage of application 'pbc/mobile' is DEPLOYED!
INFO > The following PORTs have been exposed:
https://cluster.sede.embrapa.br:49155 [https://test.sede.embrapa.br/pbc]
```

Pela [dashboard da plataforma](https://dashboard.embrapa.io) todos os membros da equipe podem acompanhar as versões instanciadas de cada _build_. Pelo _card_ é possível também acessar a instância por meio dos links para as portas expostas publicamente.

![Card da app com informações das versões das builds instanciadas]({{ site.baseurl }}/assets/img/deploy/02.png)

Os membros da equipe do projeto poderão agora, pelo _card_ da aplicação, [monitorar a instância da _build_ e gerenciá-la]({{ site.baseurl }}/docs/health).
