---
layout: page
title: Cluster
subtitle: Configurando e disponibilizando um cluster
---

Conforme explicado no [capítulo de arquitetura]({{ site.baseurl }}/docs/architecture), o **embrapa.io** é uma plataforma do tipo _Cloud Agnostic Architecture_. Ou seja, se propõe a atuar com <u>diferentes tecnologias de conteinerização e clusterização em nuvem</u>, às quais são aqui chamadas de "**orquestradores**".

Assim, é possível que uma aplicação, devidamente conteinerizada, seja instanciada em estágio de maturidade _alpha_ (para testes internos) em um orquestrador [Docker Swarm](https://docs.docker.com/engine/swarm/) rodando em um cluster de servidores localizado fisicamente na [Embrapa Gado de Corte](https://www.embrapa.br/gado-de-corte). A mesma aplicação poderia ser instanciada em estágio _beta_ (para testes externos) em um orquestrador [Kubernetes](https://kubernetes.io/pt-br/) rodando em um cluster de servidores localizado fisicamente na [Embrapa Agricultura Digital](https://www.embrapa.br/agricultura-digital). Por fim, esta mesma aplicação poderia estar instanciada em estágio de maturidade _release_ (produção) em um orquestrador [Cloud Foundry](https://www.cloudfoundry.org) rodando na [IBM Cloud](https://www.ibm.com/cloud).

Para possibilitar a "orquestração" dos ativos digitais nesta rede descentralizada de _clusters_, a plataforma implementa **_drivers_** de serviços. Estes _drivers_ podem ser de dois tipos:

- **orquestrador**: que efetua tarefas de validação dos _stacks_ de _containers_, _deploy_/_undeploy_, _health check_, _backup_, sanitização, etc; e
- **storer**: que instancia _volumes_ no próprio _cluster_ ou em servidores externos do tipo _storage_.

O provisionamento de novos _clusters_, _storers_ e o desenvolvimento de _drivers_, estão alinhados com a estratégia de desenvolvimento colaborativo e manutenção compartilhada da plataforma. Assim, [da mesma forma que ocorre com os _boilerplates_]({{ site.baseurl }}/docs/boilerplate), _clusters_ são mantidos por equipes descentralizadas, que podem ser internas ou externas à Embrapa.

![Detalhes do cluster escolhido para deploy da aplicação]({{ site.baseurl }}/assets/img/cluster/01.png)

Desta forma, unidades descentralizadas, instituições e empresas parceiras da Embrapa podem compor a rede de _clusters_ do **embrapa.io**, integrando servidores reais ou VMs de seus próprios CPDs. Com isso, a gestão das aplicações nestes servidores físicos ou máquinas virtuais passa a ser realizada pelos processos de DevOps da plataforma.

> **Atenção!** Os processos de automatizados de _backup_ nos _clusters_ são de atribuição da equipe de mantenedores, sendo que o **embrapa.io** aborda apenas o _backup_ sob demanda, [já detalhado anteriormente]({{ site.baseurl }}/docs/backup). Da mesma forma, recursos essenciais adicionais, tal como envio de e-mail (SMTP) devem ser disponibilizados na rede interna em que o servidor está instalado e devidamente informado na documentação do _cluster_.

Para realizar a integração, os mantenedores deverão configurar as máquinas, reais ou virtuais, conforme a instrução para o orquestrador e _storer_ escolhido. A seguir, são listados os _drivers_ já disponíveis para criação de _clusters_. Para diversos destes _drivers_ o **embrapa.io** realiza a conexão via SSH. Portanto é necessário, quando for este o caso, liberar o acesso do IP `200.202.148.38` na **porta 22** do servidor e adicionar a seguinte chave pública no arquivo `~/.ssh/authorized_keys` do `root`:

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCykAvX7CZmqw1bgOCOmRtgpfr55cjqO0v1+DImp4pKrITdFxZu0OqsJgHjio/yp4w5+KvWmFJa5woYbZry9inFciwKo3+rpGjBHJfNfDq70/q3VdSSInFrSMtWgBk0x5QZQ78ENkNkO9DRIdnnffN9bY1uibR6ZX0pCSSyTGgx3NlAakW47tYIzVcrrUGKGG8vZwSkl7GhEEXtNETp02WQpkUvYrNqgRrmw2lvv41QfRETIuNN7PDhJrDO4tYHtix5D+Pvd05IacgTVQxpi6vnMVdgrwbZ1RPw9TLLkoy3kZs45hLG9oipiYOiD6rxiIYC0f1iUaKz9PKZdfnF8Ya5XJFoL6NcBTPDGh01dkEBonOWt3lgpC/2SBM/SeClt8M2lI6KtqAkjPEKWhnirDP0lXzY2CYamnu2rD6p4z4OWAYG6ngQcCIK45vQvsSz8mfitWnJe89WCCaEVj+L1QO/hjnKJ+eKf5ze35HagFRhpIAB34FmGHO3N8yFCLqvHFNLw6dKl5IXU2cvJF1jwhL3coOx9oeFZLPk45Zze2e/Itjd9x84gWtmo60MvXVBsYGYlcZLzSgAbNGldMuxAFWs0ZvghNx+KZjg6fZ2hAlPHIg1MiAlztyLbbjV2Mjc6ke6sjBDvPkPZQde6G/T8Mp56cCtAb/77/dw78zruX5qyQ== embrapa.io
```

Além disso, o **embrapa.io** expõe as aplicações instanciadas em portas na **faixa de 49152 a 65535**. Portanto, toda esta faixa de portas deverá ser exposta para acesso público nos servidores de aplicação que compõem o _cluster_ (p.e., os _Manager Nodes_ no [Docker Swarm](https://docs.docker.com/engine/swarm/)). Adicionalmente, é fortemente recomendado que seja [instalado o Portainer](https://docs.portainer.io/start/install) para auxiliar a equipe mantenedora de _clusters_ em [Docker Compose](https://docs.portainer.io/start/install/server/docker/linux), [Docker Swarm](https://docs.portainer.io/start/install/server/swarm/linux) ou [Kubernetes](https://docs.portainer.io/start/install/server/kubernetes/baremetal) em sua gestão. Por padrão, recomenda-se que este seja disponibilizado no HTTPS (porta 443) da URL do _cluster_, com o HTTP (porta 80) redirecionando para o HTTPS.

## Docker Compose

Para instalação deste orquestrador é recomendado o uso da distribuição [Linux Ubuntu Server 22.04 LTS](https://ubuntu.com/download/server). É necessário que seja utilizada a arquitetura **amd64**. No momento da instalação do SO, haverá a possibilidade de instalar pacotes adicionais. Neste momento, selecione o **SSH Server** e o **Docker**.

![Pacote do Docker selecionado para instalação]({{ site.baseurl }}/assets/img/cluster/03.png)

Após acessar o servidor, adicione a chave pública SSH da plataforma, conforme já mencionado. Agora será necessário configurar um _storer_ associado ao _cluster_, que é o servidor físico onde serão armazenados os _volumes_ utilizados pelos containers para persistir dados:

`DockerLocal`: Caso não haja uma VM ou um servidor do tipo _storage_ disponível, que seria o equipamento mais apropriado, é possível configurar um _storer_ local. Na prática será um diretório no próprio _cluster_ onde todos os _volumes_ serão criados fisicamente. Para isto, basta criar um diretório em qualquer local no servidor e atribuir permissões de escrita.

`DockerNFSv4`: Havendo uma VM ou servidor físico de _storage_ disponível, os mantenedores poderão [instalar e/ou habilitar o NFS (versão 4)](https://phoenixnap.com/kb/ubuntu-nfs-server) nele. Assim como no caso do _cluster_, é necessário também configurar a chave SSH pública da plataforma no usuário `root`. É importante que no arquivo `/etc/exports` sejam parametrizados, pelo menos, as seguintes opções no diretório a ser montado: `rw`, `no_root_squash`, `sync`, `no_subtree_check` e `insecure`.

Pronto, agora basta montar as configurações em formato JSON e [enviar para a equipe de gestão da plataforma](mailto:io@embrapa.br). O exemplo abaixo demonstra como deverão ser as configurações:

```
{
  "release": [
    {
      "host": "io.facom.ufms.br",
      "local": "Faculdade de Computação da UFMS",
      "location": "Campo Grande - MS",
      "orchestrator": "DockerCompose",
      "storage": {
        "type": "DockerNFSv4",
        "host": "storage.facom.ufms.br",
        "path": "/mnt/nfs"
      },
      "aliases": [
        "releases.facom.ufms.br",
        "agro.facom.ufms.br",
        "farm.facom.ufms.br",
        "live.facom.ufms.br",
      ],
      "disabled": false,
      "maintainers": [
        { "name": "José da Silva", "email": "jose.silva@ufms.br", "phone": "+55 (67) 9 8888-7777" },
        { "name": "Maria do Rosário", "email": "maria.rosario@ufms.br", "phone": "+55 (67) 9 6666-5555" }
      ]
    }
  ],
  "beta": [
    {
      "host": "io.facom.ufms.br",
      "local": "Faculdade de Computação da UFMS",
      "location": "Campo Grande - MS",
      "orchestrator": "DockerCompose",
      "storage": {
        "type": "DockerNFSv4",
        "host": "storage.facom.ufms.br",
        "path": "/mnt/nfs"
      },
      "aliases": [
        "test.facom.ufms.br",
        "beta.facom.ufms.br"
      ],
      "disabled": false,
      "maintainers": [
        { "name": "José da Silva", "email": "jose.silva@ufms.br", "phone": "+55 (67) 9 8888-7777" },
        { "name": "Maria do Rosário", "email": "maria.rosario@ufms.br", "phone": "+55 (67) 9 6666-5555" }
      ]
    }
  ],
  "alpha": [
    {
      "host": "io.facom.ufms.br",
      "local": "Faculdade de Computação da UFMS",
      "location": "Campo Grande - MS",
      "orchestrator": "DockerCompose",
      "storage": {
        "type": "DockerLocal",
        "path": "/mnt/storer"
      },
      "aliases": [
        "sandbox.facom.ufms.br",
        "alpha.facom.ufms.br"
      ],
      "disabled": false,
      "maintainers": [
        { "name": "José da Silva", "email": "jose.silva@ufms.br", "phone": "+55 (67) 9 8888-7777" },
        { "name": "Pedro da Rocha", "email": "pedro.rocha@ufms.br", "phone": "+55 (67) 9 4444-3333" },
        { "name": "Bruno Albuquerque", "email": "bruno.albuquerque@ufms.br", "phone": "+55 (67) 9 2222-1111" }
      ]
    }
  ]
```

Repare que o _cluster_ deve ser configurado especificamente para cada estágio de maturidade da aplicação. Assim, ele pode estar disponível para os estágios _alpha_, _beta_ e/ou _release_, ou seja, não necessariamente para todos. O `host` deverá apontar para o IP real do servidor ou VM. Os atributos `local` e `location` indicam a Unidade da Embrapa, instituição ou empresa e a sua localização geográfica.

O `orchestrator` indica o _driver_ de orquestração que está sendo utilizado. O atributo `storage` contém o _driver_ de _storer_ e atributos relacionados. Por exemplo, para o estágio _alpha_ foi configurado um _storer_ utilizando o _driver_ `DockerLocal` e, desta forma, os _volumes_ serão criados no diretório `/mnt/storer` indicado no atributo `path`. Já em estágio _beta_ e _release_ está sendo utilizado o _driver_ para **NFSv4** e, desta forma, os _volumes_ serão criados fisicamente no diretório remoto `/mnt/nfs` do _storage_ "storage.facom.ufms.br". Localmente no _cluster_ este diretório remoto será montado em `/mnt/storage.facom.ufms.br`.

Os `aliases` são subdomínios configurados pela Unidade da Embrapa, instituição ou empresa parceira que [possibilitam alocar as aplicações em domínios mais condizentes semânticamente com a sua finalidade]({{ site.baseurl }}/docs/build#urls). Estes aliases **devem ser configurados no DNS** da seguinte forma:

1. Para cada _alias_, crie um registro do tipo `CNAME` apontando para `router.embrapa.io`; e
2. Para cada _alias_, crie um _wildcard subdomain_ (registro do tipo `A`) apontando para o **IP** do `router.embrapa.io` (ou seja, `200.202.148.38`).

Assim, para um _alias_ `app.cnpgc.embrapa.br`, teríamos:

```
Name                      Type     Value
----------------------    -----    -----------------
app.cnpgc.embrapa.br      CNAME    router.embrapa.io
*.app.cnpgc.embrapa.br    A        200.202.148.38
```

Caso o atributo `disabled` sejá setado para `true`, o _cluster_ não aceitará novos _deploys_ naquele estágio específico, porém as _builds_ já instanciadas continuarão sendo geridas normalmente (inclusive recebendo _deploys_ de novas _tags_). Por fim, é possível estabelecer grupos diferentes de mantenedores para o _cluster_ em cada estágio de maturidade.
