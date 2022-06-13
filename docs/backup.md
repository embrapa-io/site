---
layout: page
title: Backup
subtitle: Executando e obtendo o backup da build
---

Pela tela de [monitoramento de gestão da instância]({{ site.baseurl }}/docs/health) é possível realizar o _backup_ dos dados da aplicação.

![Executando o processo de backup de instância]({{ site.baseurl }}/assets/img/backup/01.png)

Mais especificamente, ao ativar esta função, o autômato _Doctor_ irá executar o serviço ```backup``` do _stack_ de _containers_ da instância. Para que o processo funcione corretamente, é necessário que um _volume_ denominado ```backup``` esteja devidamente montado e que o serviço tenha sido devidamente implementado no arquivo de configuração do orquestrador.

Por exemplo, abaixo temos o serviço ```backup``` implementado no _stack_ de uma aplicação [WordPress](https://br.wordpress.org):

```yaml
backup:
  image: mariadb:latest
  restart: "no"
  environment:
    MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWD}
    MYSQL_DATABASE: pbc_portal
    MYSQL_USER: wordpress
    MYSQL_PASSWORD: ${DB_PASSWD}
  depends_on:
    - db
  links:
    - db
  volumes:
    - data_backup:/backup
    - data_wp:/var/www/html
  command: >
    sh -c  "set -ex &&
      export BACKUP_DIR=${COMPOSE_PROJECT_NAME}_${VERSION}_$$(date +'%Y-%m-%d_%H-%M-%S') &&
      cd /backup && mkdir $$BACKUP_DIR &&
      mysqldump --host db -uroot -p${DB_ROOT_PASSWD} pbc_portal > $$BACKUP_DIR/db.sql &&
      cp -R /var/www/html $$BACKUP_DIR/ &&
      tar -czf $$BACKUP_DIR.tar.gz $$BACKUP_DIR &&
      rm -rf /backup/$$BACKUP_DIR"
  profiles:
    - cli
```

Ao ser executado, o serviço ```backup``` precisa, necessariamente, gerar um arquivo ```.tar.gz``` no _volume_ de _backup_. Todos os [_boilerplates_ já possuem uma implementação prévia do serviço]({{ site.baseurl }}/docs/boilerplate).

Estando configurado corretamente, o serviço irá executar e, ao final, será enviado um e-mail aos mantenedores do projeto com um conteúdo semelhante ao abaixo:

```
INFO > Starting BACKUP proccess to build 'orcamento-forrageiro/site@alpha' (as requested by 'camilo.carromeu@embrapa.br')...
INFO > Trying to load '.embrapa/settings.json' from remote repository... done!
INFO > Trying to make backup of version '0.22.6-alpha.2' deployed as 'container' using orchestrator 'DockerCompose' at server 'cluster.sede.embrapa.br'!
INFO > Trying to clone app... done!
INFO > Checking SSH connection to host 'cluster.sede.embrapa.br'... ok!
INFO > Trying to execute backup service...
COMMAND > env $(cat .env.cli) DOCKER_HOST="ssh://root@cluster.sede.embrapa.br" /usr/bin/docker-compose build --force-rm --no-cache backup
COMMAND > env $(cat .env.cli) DOCKER_HOST="ssh://root@cluster.sede.embrapa.br" /usr/bin/docker-compose run --rm --no-deps backup
SUCCESS > The build was successfully backed up!
INFO > Providing access to maintainers in build backup folder...
INFO > Protecting build backup folder at 'http://backup.embrapa.io/orcamento-forrageiro' with a password... done!
SUCCESS > All done! Access backup files at 'http://backup.embrapa.io/orcamento-forrageiro' with user 'orcamento-forrageiro' and password '************'.
```

Na última linha podem ser vistas as instruções de acesso aos arquivos de _backup_. Em resumo, eles estarão disponíveis no servidor [**http://backup.embrapa.io**](http://backup.embrapa.io), em uma pasta com o nome _unix_ do projeto.

> **Atenção** A senha para acesso será alterada a cada nova execução do processo de _backup_.

![Arquivos de backup da instância disponíveis para download]({{ site.baseurl }}/assets/img/backup/02.png)
