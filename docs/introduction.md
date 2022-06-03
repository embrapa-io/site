---
layout: page
title: Introdução
subtitle: Conceitos básicos da plataforma
---

A plataforma **embrapa.io** permite que, de forma cadenciada, seja estruturado todo um novo projeto de **ativo digital** para a agropecuária. Para isso, faz-se necessário compreender alguns conceitos inerentes à plataforma.

Primeiramente, assume-se que cada ativo digital será formado por diversos softwares desacoplados, além de outros artefatos de software de apoio. Este conceito reflete o padrão atual de desenvolvimento de software, onde uma solução tem um _backend_ integrado ao banco de dados, um _frontend_ na Web, um aplicativo _mobile_, dentre outros (ou pode ainda ainda ser baseada em micro-serviços), com diversos "módulos" que seguem ciclos de vida independentes.

## Projeto

Assim, mais especificamente, um **projeto** de ativo digital no **embrapa.io** será composto por diversos repositórios, que podem ser de 3 (três) tipos:

- **repositório de código-fonte de aplicação**: que contém o código-fonte de um dos softwares que compõe o ativo digital, sendo gerado automaticamente pela plataforma a partir do código-fonte de um _boilerplate_ escolhido pelo usuário;
- **repositório de suporte**: que são gerados automaticamente pela plataforma, seguindo padrões bem definidos, para prover o site técnico de divulgação pública do projeto, a documentação _online_ da API, o empacotamente para disponibilização em lojas virtuais, o diretório privado de documentação, os artefatos de identidade visual e/ou binários de compilações; e
- **repositório de arquivos de apoio**: que nada mais são do que repositórios criados pelos mantenedores do projeto para guardar outros arquivos que não se enquadrem nos tipos anteriores.

Para criar um **projeto**, [acesse a _dashboard_]({{ site.baseurl }}/docs/dashboard) e [siga os passos na própria interface]({{ site.baseurl }}/docs/project).

## Aplicação

Dentre os tipos de repositórios listados, o do código-fonte de **aplicação** (ou **app**) é o mais importante, pois permitirá que os desenvolvedores codifiquem cada módulo desacoplado do ativo em si e, posteriormente, faça a entrega deste módulo (_deploy_).