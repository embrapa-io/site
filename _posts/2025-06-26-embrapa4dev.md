---
layout: post
title: Integração do Embrapa4Dev
subtitle: Disponibilizados dois boilerplates para softwares institucionais.
# cover-img: /assets/img/dashboard/02.png
# thumbnail-img: /assets/img/icon-back.png
# share-img: /assets/img/icon-back.png
tags: [ releases ]
---

Foram disponibilizados novos recursos para acelerar o desenvolvimento de software institucional na Embrapa!

Agora a iniciativa **Embrapa4Dev**, de padronização e modernização da arquitetura de software institucional, foi integrada à plataforma **Embrapa I/O**. Assim, foram publicados dois novos _boilerplates_ no catálogo da plataforma que irão facilitar, agilizar e padronizar a criação de aplicações corporativas.

São dois modelos já disponíveis, que embarcam funcionalidades essenciais integradas:

### 1. Plataforma Web (_frontend_ + _backend_)

- Plataforma .NET utilizando [Blazor Server](https://dotnet.microsoft.com/en-us/apps/aspnet/web-apps/blazor);
- SGBD [PostgreSQL](https://www.postgresql.org);
- Autenticação via Google;
- Biblioteca de componentes visuais [Bootstrap Blazor](https://docs.blazorbootstrap.com);
- Layout configurado com o _template_ [Spark](https://themes.getbootstrap.com/product/spark-admin-dashboard-template-reactjs/) do Bootstrap;
- Tratamento de exceção;
- Localização (l10n) e globalização (i18n);
- Log de eventos ([Grafana Loki](https://log.embrapa.io));
- Rastreamento de erros ([Sentry](https://bug.embrapa.io));
- Rastreamento de uso e acessos ([Matomo Analytics](https://hit.embrapa.io));
- Análise estática de código ([SonarQube](https://code.embrapa.io)); e
- Configurações para conteinerização.

### 2. API REST

- API REST com _endpoints_ mínimos na plataforma .NET;
- _Health checks_ integrados;
- Log de eventos ([Grafana Loki](https://log.embrapa.io));
- Rastreamento de erros ([Sentry](https://bug.embrapa.io));
- Rastreamento de uso e acessos ([Matomo Analytics](https://hit.embrapa.io));
- Análise estática de código ([SonarQube](https://code.embrapa.io));
- Configurações para conteinerização;
- Configuração para ambientes de desenvolvimento, _staging_ e produção; e
- Documentação [OpenAPI](https://swagger.io/specification/).

Com esses recursos, equipes de desenvolvimento podem iniciar projetos com mais agilidade, qualidade e alinhamento às boas práticas da Embrapa. Os _boilerplates_ estão disponíveis diretamente no catálogo do **Embrapa I/O**, prontos para serem utilizados em novos projetos ou adaptados conforme a necessidade.

A iniciativa **Embrapa4Dev** é um esforço contínuo da Supervisão de Desenvolvimento de Software (SDSS) da Gerência-Adjunta de Tecnologia da Informação (GTI) para fomentar inovação, qualidade, reuso de código e colaboração entre as equipes de TI da Embrapa.

Saiba mais e explore os boilerplates em: [https://docs.embrapa.io/embrapa4dev](https://docs.embrapa.io/embrapa4dev)
