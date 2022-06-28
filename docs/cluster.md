---
layout: page
title: Cluster
subtitle: Configurando e disponibilizando um cluster
---

Conforme explicado no [capítulo de arquitetura]({{ site.baseurl }}/docs/architecture), o **embrapa.io** é uma plataforma do tipo _Cloud Agnostic Architecture_. Ou seja, se propõe a atuar com <u>diferentes tecnologias de conteinerização e clusterização em nuvem</u>, às quais são aqui chamadas de "**orquestradores**".

Assim, é possível que uma aplicação, devidamente conteinerizada, seja instanciada em estágio de maturidade _alpha_ (para testes internos) em um orquestrador [Docker Swarm](https://docs.docker.com/engine/swarm/) rodando em um cluster de servidores localizado fisicamente na [Embrapa Gado de Corte](https://www.embrapa.br/gado-de-corte). A mesma aplicação poderia ser instanciada em estágio _beta_ (para testes externos) em um orquestrador [Kubernetes](https://kubernetes.io/pt-br/) rodando em cum cluster de servidores localizado fisicamente na [Embrapa Agricultura Digital](https://www.embrapa.br/agricultura-digital). Por fim, esta mesma aplicação poderia estas instanciada em estágio de maturidade _release_ (produção) em um orquestrador [Cloud Foundry](https://www.cloudfoundry.org) rodando na [IBM Cloud](https://www.ibm.com/cloud).

Para possibilitar a "orquestração" dos ativos digitais nesta rede descentralizada de _clusters_, a plataforma implementa **_drivers_** de serviços. Estes _drivers_ pode ser de dois tipos:

- **orquestrador**: que efetua tarefas de validação dos _stacks_ de _containers_, _deploy_/_undeploy_, _health check_, _backup_, sanitização, etc; e
- **storer**: que instancia _volumes_ no próprio _cluster_ ou em servidores externos do tipo _storage_.

O provisionamento de novos _clusters_, _storers_ e o desenvolvimento de _drivers_, estão alinhados com a estratégia de desenvolvimento colaborativo e manutenção compartilhada da plataforma. Assim, [da mesma forma que ocorre com os _boilerplates_]({{ site.baseurl }}/docs/boilerplate), 
