---
layout: page
title: Projetos
subtitle: Como criar um novo projeto de ativo digital?
---

Ao [acessar a _dashboard_]({{ site.baseurl }}/docs/dashboard) da plataforma, o usuário verá na barra superior um **botão para criar um novo projeto**.

> **Atenção!** Somente empregados da Embrapa podem criar novos projetos.

Ao clicar neste botão abrirá um _wizard_ para criação do projeto. O primeiro passo é um _disclaimer_, o qual o usuário deverá estar ciente.

![Tela de aviso da criação de projetos]({{ site.baseurl }}/assets/img/project/01.png)

No segundo passo o usuário poderá escolher um **nome legível para o projeto**, um **nome _unix_** (somente minúsculas, sem acentos, espaços ou caracteres especiais) e quais **repositórios de suporte** deverão ser gerados automaticamente.

![Configuração do projeto]({{ site.baseurl }}/assets/img/project/02.png)

## Repositórios de Suporte

Os repositórios de suporte podem ser de 6 (seis) tipos distintos:

#### I. Site de informações públicas do projeto

Todo projeto **embrapa.io** pode instanciar um **site público de documentação**. Esta funcionalidade é baseada no [GitHub Pages](https://pages.github.com) e funciona de forma muito similar. Na prática o desenvolvedor pode documentar as aplicações que compõem o projeto utilizando [linguagem Markdown](https://www.markdownguide.org) de forma bastante simplificada.

Quando esta opção é selecionada, o autômato de criação de entidades da plataforma irá criar um novo repositório (denominado ```_web```) no grupo do projeto no [GitLab](https://git.embrapa.io) com o código-fonte inicial desta página. Ao mesmo tempo, o autômato de _deploy_ da plataforma irá instanciar a página e disponibilizá-la publicamente no endereço:

```https://project.embrapa.io/[nome unix do projeto]```

Toda alteração realizada neste repositório e versionada (_pull_) é automaticamente atualizada no site do projeto. O tema padrão do site é o mesmo utilizado neste site de documentação da própria plataforma **embrapa.io**.

#### II. Documentação pública da API

O desenvolvedor poderá instanciar a documentação em [Swagger](https://swagger.io) da(s) API(s) disponível(is) no projeto. Ao selecionar esta opção, o autômato de criação de entidades irá criar um  ele poderá evoluir um novo repositório (denominado ```_api```) no grupo do projeto no [GitLab](https://git.embrapa.io) com o código-fonte inicial desta documentação. Ao mesmo tempo, o autômato de _deploy_ da plataforma irá instanciar a página de documentação da API e disponibilizá-la publicamente no endereço:

```https://api.embrapa.io/[nome unix do projeto]```

Da mesma forma que o site público, cada alteração e versionamento (_pull_) neste repositório atualiza automaticamente esta documentação pública.

#### III. Documentação técnica (não pública)

Ao ativar este repositório (denominado ```_doc```) será provisionada a estrutura básica de diretórios e arquivos para documentação do projeto de software. Desta forma, a equipe de desenvolvimento já terá acesso aos modelos dos arquivos de que necessita desde a concepção do ativo. Os diretórios inicialmente criados são:

1. **Kickoff:** Arquivos das tratativas iniciais do projeto que levaram a sua concepção;
2. **About:** Informações gerais sobre o projeto;
3. **Team:** Dados dos parceiros institucionais e membros do projeto;
4. **Roadmap:** Planejamento de entrega de resultados;
5. **Development:** Documentação do desenvolvimento dos softwares que integram o projeto, tal como diagramas UML, esquemas dos bancos de dados, arcabouço tecnológico, etc;
6. **Support:** Guias para publicação dos softwares, monitoramento e manutenção;
7. **Meetings:** Atas de reuniões;
8. **Presentations:** Apresentações diversas realizadas em eventos e reuniões;
9. **Clipping:** Notícias veiculadas e notas midiáticas sobre o projeto; e
10. **Publications:** Artigos e publicações relacionados ao projeto.

#### IV. Logos e e artefatos visuais

Este repositório (denominado ```_art```) é dedicado ao armazenamento de arquivos de mídia do projeto, tal como a arte da logo (e suas diversas variações), manual de uso da marca e paleta de cores, artefatos de identidade visual, etc.

#### V. Binários

Este repositório (denominado ```_bin```) é utilizado para o usuário inserir binários e chaves de distribuição nas lojas virtuais. Por exemplo, quando um aplicativo desenvolvido para Android é veiculado na [Google Play](https://play.google.com/store/games), um dos requisitos é a criação de uma _keystore_, ou seja, uma chave criptográfica que é utilizada para assinar os arquivos APKs (binários de distribuição). Desta forma, esta chave (e sua senha) não pode ser perdida, pois neste caso não será possível enviar novas versões do aplicativo.

Este mesmo conceito é utilizado por outras lojas virtuais, como a [Microsoft Store](https://www.microsoft.com/pt-br/store/apps/) (passa assinar seus binários APPX). Assim, neste repositório podem ser armazenadas as _keystores_ utilizadas pelo projeto para distribuição, bem como os próprios binários já assinados que serão publicados nestas lojas.

#### VI. Encapsulamento TWA

Este repositório (denominado ```_twa```), quando criado, disponibilizará no projeto o código-base para encapsular aplicações do tipo [Progressive Web Applications - PWAs](https://web.dev/progressive-web-apps/) ou [Single-Page Applications - SPA](https://developer.mozilla.org/en-US/docs/Glossary/SPA) utilizando a técnica de [Trusted Web Activity - TWA](https://developer.chrome.com/docs/android/trusted-web-activity/) para distribuição na loja virtual da [Google Play](https://play.google.com/store/games).

Esta é uma das formas de encapsular aplicações em JavaScript, mas existem outras como, por exemplo, utilizando o [CapacitorJS](https://capacitorjs.com) ou o [Apache Cordova](https://cordova.apache.org/).

![Repositórios de suporte do projeto]({{ site.baseurl }}/assets/img/project/03.png)

Quando o usuário opta por todos os repositórios de suporte do projeto, o grupo inicial no [GitLab](https://git.embrapa.io) irá ser inicializado de forma semelhante à imagem acima.

## Equipe do Projeto

Quando o projeto é criado fica disponível como um _card_ na _dashboard_ do usuário. Por meio deste _card_ os **mantenedores do projeto** (do inglês, _maintainers_) poderão gerenciá-lo. Por exemplo, é possível ativar e desativar os repositórios de suporte.

![Menu de contexto do projeto]({{ site.baseurl }}/assets/img/project/04.png)

Outra funcionalidade disponível é a **gestão da equipe do projeto**. Inicialmente o projeto terá um único membro na equipe, que é o próprio usuário que o criou. Este usuário poderá então adicionar novos usuários que podem ser de dois tipos:

- **Mantenedores:** Possuem diversas permissões especiais, tal como adicionar novos membros à equipe, relalizar o _deploy_ em produção, o _backup_ de uma _build_ ou 'derrubar' uma instância; ou
- **Desenvolvedores:** Podem fazer _pull_ para a _branch_ ```main``` e o _deploy_ em ambiente _alpha_ e _beta_ (testes internos e externos, respectivamente).

> **Atenção!** Somente empregados da Embrapa podem ser **mantenedores**.

![Adicionando um usuário externo à equipe do projeto]({{ site.baseurl }}/assets/img/project/05.png)

Podem ser incluídos na equipe do projeto usuários que já estejam cadastrados na plataforma ou não. Neste último caso, quando o usuário se cadastrar ele será automaticamente vinculado ao projeto.

![Membros da equipe do projeto]({{ site.baseurl }}/assets/img/project/06.png)

Uma vez que o projeto tenha sido criado e esteja devidamente configurado, os usuários mantenedores poderão agora [adicionar aplicações]({{ site.baseurl }}/docs/app) por meio do botão "**Nova App**" disponível no _card_.