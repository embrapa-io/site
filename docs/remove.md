---
layout: page
title: Remover
subtitle: Como remover uma aplicação de um projeto?
---

Uma aplicação criada por engano, um protótipo que não vingou ou um módulo que foi absorvido por outro: eventualmente é preciso **remover uma aplicação** de um projeto no **Embrapa I/O**, mantendo o projeto e as demais aplicações intactas.

A remoção é diferente do [arquivamento de um projeto]({{ site.baseurl }}/docs/archive), que atua sobre o projeto inteiro. Aqui, apenas a aplicação indicada é retirada, e o nome _unix_ que ela ocupava volta a ficar livre dentro do projeto.

> **Atenção!** Esta é uma ação destrutiva. Antes de prosseguir, faça o [_backup_]({{ site.baseurl }}/docs/backup) do que for relevante: o histórico de erros, as métricas de acesso e, sobretudo, os valores das [variáveis de ambiente]({{ site.baseurl }}/docs/build) configuradas nas _builds_, que **não são recuperáveis** depois da remoção.

## O que a remoção faz — e o que ela preserva {#efeitos}

A remoção **desfaz a configuração da aplicação na plataforma**:

1. Apaga os valores das variáveis de ambiente e dos volumes de todos os estágios;
2. Apaga o histórico de _builds_ e o estado dos _deploys_;
3. Libera as portas que estavam reservadas para a aplicação nos _clusters_; e
4. Retira a aplicação da _dashboard_.

Por outro lado, ela **não apaga o código-fonte nem as integrações**:

1. O repositório é **arquivado** no [GitLab](https://git.embrapa.io) e renomeado com a data e a hora da remoção — por exemplo, `pwa_20260910_133155` —, ficando somente leitura;
2. A organização no [_bug tracking_](https://bug.embrapa.io), o site na [analítica](https://hit.embrapa.io), o projeto na [qualidade de código](https://code.embrapa.io) e os painéis de [observabilidade](https://log.embrapa.io) **permanecem como estão**.

O sublinhado no nome do repositório arquivado é proposital: o nome _unix_ de uma aplicação aceita apenas letras minúsculas, números e hífen, de modo que o repositório arquivado **nunca colide** com uma aplicação criada depois.

É justamente por isso que **é possível criar uma nova aplicação com o mesmo nome** — inclusive a partir de um [_boilerplate_]({{ site.baseurl }}/docs/boilerplate) diferente. Ela reaproveitará as integrações que sobreviveram, com todo o histórico de erros e de acessos que já existia.

## Pré-requisitos {#requisitos}

Para remover uma aplicação é necessário:

1. Ser [_Architect_]({{ site.baseurl }}/docs/squads#architect) do projeto; e
2. Que a aplicação **não tenha nenhuma _build_ instanciada** em _cluster_ algum.

Se ainda houver instâncias no ar, [remova as _builds_]({{ site.baseurl }}/docs/health) de todos os estágios antes de prosseguir — a plataforma recusa a remoção enquanto existir qualquer uma.

## Removendo a aplicação {#passos}

No _card_ do projeto, deixe em foco a aplicação que será removida e acesse a opção **Remover** no menu contextual, na seção "Avançado". O nome da aplicação em foco aparece no próprio item do menu, para não haver dúvida sobre qual delas será retirada.

![Opção de remover no menu contextual do projeto]({{ site.baseurl }}/assets/img/remove/01.png)

O diálogo apresenta as consequências da remoção: o que se perde, o que é preservado e como desfazer. Leia com atenção, aceite os termos e clique em "Prosseguir".

![Diálogo com as consequências da remoção]({{ site.baseurl }}/assets/img/remove/02.png)

Um PIN (_one-time password_) será enviado ao e-mail do _Architect_ para confirmar a ação. Insira o código e clique em "Remover".

![PIN de confirmação para remover a aplicação]({{ site.baseurl }}/assets/img/remove/03.png)

A remoção é imediata: ao final, a aplicação desaparece do _card_ do projeto.

## Desfazendo uma remoção {#restaurar}

Como o código-fonte é preservado, uma remoção pode ser desfeita — mas **não pelo próprio _Architect_**. Desarquivar um repositório no GitLab exige permissão de dono, e o papel do _Architect_ no GitLab é o de _Maintainer_, que renomeia repositórios mas não os desarquiva.

Para restaurar uma aplicação, um administrador da plataforma precisa:

1. Desarquivar o repositório no [GitLab](https://git.embrapa.io);
2. Devolver-lhe o nome original, removendo o sufixo com a data; e
3. Recriar a aplicação no projeto a partir do repositório existente.

Vale lembrar que apenas o código-fonte volta: as variáveis de ambiente, os volumes e o histórico de _builds_ foram apagados na remoção e precisarão ser configurados novamente.
