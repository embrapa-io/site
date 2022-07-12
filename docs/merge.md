---
layout: page
title: Merge Request
subtitle: Propondo melhorias aos boilerplates
---

Um dos [objetivos]({{ site.baseurl }}/about) da plataforma **embrapa.io** é fomentar o <u>desenvolvimento colaborativo</u> junto à comunidade de desenvolvedores. Assim, os artefatos de software que compõem os projetos são, em grande parte, _forks_ de repositórios-base no [GitLab da plataforma](https://git.embrapa.io).

Esta estratégia possibilita que qualquer problema encontrado nas derivações destes repositórios (seja no momento de desenvolver uma aplicação, ou quando estiver customizando um repositório de suporte) possam ser corrigidos pela própria equipe que identificou o problema e, em seguida, retroalimentar o repositório-base, corrigindo o problema também em sua origem. A partir daí, todos os demais repositórios que foram derivados a partir desta origem, poderão também ser corrigidos por um processo simples de _merge_ no GIT.

Para demonstrar como isso pode ser realizado, vamos exemplificar por meio de um estudo de caso. Imagine que, ao tentar realizar o [processo de _backup_ por demanda]({{ site.baseurl }}/docs/backup) em uma _build_ denominada `agroapp/api@alpha`, o seguinte erro tenha sido emitido:

```bash
COMMAND > env $(cat .env.cli) DOCKER_HOST="ssh://root@cluster.agro.rocks" /usr/bin/docker-compose run --rm --no-deps backup
sh: syntax error: unexpected "&&"
CRITICAL > Impossibe to backup build. Backup service failed to RUN!
```

Ao observar o arquivo `docker-compose.yaml` na raiz do repositório é possível constatar que o atributo `command` no serviço `backup` do _stack_ de containers está implementado de forma errônea:

```yaml
backup:
  build:
    context: .
    dockerfile: ./docker/${ENVIRONMENT}/backup/Dockerfile
  restart: "no"
  depends_on:
    - db
  links:
    - db
  volumes:
    - data_backup:/backup
  command: >
    sh -c  "set -ex
      && export BACKUP_DIR=${COMPOSE_PROJECT_NAME}_${STAGE}_$$(date +'%Y-%m-%d_%H-%M-%S')
      && cd /backup && mkdir $$BACKUP_DIR
      && mongodump --host db --username root --password ${MONGO_ROOT_PASSWORD} --authenticationDatabase admin --out /backup/$$BACKUP_DIR/db
      && tar -czf $$BACKUP_DIR.tar.gz $$BACKUP_DIR
      && rm -rf /backup/$$BACKUP_DIR"
  profiles:
    - cli
```

Uma vez que este erro é originário do _boilerplate_, iremos realizar a correção de forma que, posteriormente, possamos sugerí-la também ao repositório-base. Para isso, precisamos primeiro criar uma _branch_ de correção, que deverá ser **uma ramificação da _main_ a partir do _commit_ imediatamente anterior ao _fork_ do repositório-base**. Para criar esta _branch_, primeiramente acesse o histórico de _commits_ do repositório:

![Merge request: histórico de commits]({{ site.baseurl }}/assets/img/merge/01.png)

Em seguida, procure na listagem de _commits_ por uma entrada denomidada "**Configuração inicial automática do repositório.**", submetida pelo usuário "**embrapa.io Genesis Automaton**" e copie o `Commit SHA` do _commit_ realizado imediatamente antes desta entrada:

![Merge request: obtendo o SHA do commit-base]({{ site.baseurl }}/assets/img/merge/02.png)

Agora, crie uma nova _branch_ utilizando este _commit_ como base:

![Merge request: criando a branch de correção]({{ site.baseurl }}/assets/img/merge/03.png)

Utilizando um cliente GIT ou a própria interface do GitLab, faça o _checkout_ para esta nova _branch_, efetue as correções no código-fonte e realize o _commit_:

![Merge request: fazendo as alterações no código-fonte]({{ site.baseurl }}/assets/img/merge/04.png)

Faça agora o _merge_ da sua _branch_ de correção para o troco do projeto (_main_). Teste em ambiente de desenvolvimento. Estando tudo certo, faça o _merge_ da _main_ para a _branch_ de estágio de maturidade _alpha_ e [realize o _deploy_ criando uma nova _tag_]({{ site.baseurl }}/docs/deploy). No nosso exemplo, uma vez que o _deploy_ da _build_ `agroapp/api@alpha` tenha sido realizado com sucesso, iremos testar novamente o serviço de _backup_ diretamente no ambiente de testes internos.

Uma vez que esteja tudo funcionando corretamente, iremos realizar um _merge request_ da nossa _branch_ de correção para o repositório-base (ou seja, do _boileplate_), que no nosso estudo de caso é `io/boilerplate/nodejs-mongodb-jwt-password-less` (veja a primeira imagem desta página). Para isso, crie um _merge request_ tendo como _source_ a _branch_ de correção e como _target_ o tronco do repositório do _boilerplate_:

![Merge request]({{ site.baseurl }}/assets/img/merge/05.png)

Pronto! Um mantenedor do _boilerplate_ poderá agora avaliar as alterações, aprovar e realizar o _merge_ no repositório-base. Isto permitirá também a outros desenvolvedores que tenham aplicações derivadas do mesmo _boilerplate_ aplicarem as correções.
