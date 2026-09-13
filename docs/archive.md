---
layout: page
title: Arquivar
subtitle: Como arquivar um projeto?
---

Atualmente não é possível apagar completamente um projeto do **Embrapa I/O**. Ocorre que a remoção de dados é um tema sensível, que deve ser tratado com extremo cuidado. Por conta disso, neste momento, um projeto criado na plataforma permanecerá ocupando permanentemente o nome _unix_ que tenha sido alocado e seus dados, tal como código-fonte, documentação e as instâncias das _builds_, permanecerão disponíveis.

Entretanto, por diversos motivos e visando manter o painel do **Embrapa I/O** organizado, pode ser necessário **arquivar um projeto**. O arquivamento de projetos atua executando 4 ações:

1. Desabilita os [repositórios de suporte]({{ site.baseurl }}/docs/project#support) do projeto;
2. Desativa todas as [instâncias de _builds_]({{ site.baseurl }}/docs/health) de todas as aplicações;
3. **Descarta as aplicações que nunca chegaram a ser criadas**; e
4. Remove toda a [equipe do projeto]({{ site.baseurl }}/docs/project#team), tornando-o inacessível.

Sobre o terceiro item: uma aplicação recém-solicitada permanece em uma fila até que o autômato da plataforma crie o seu repositório no [GitLab](https://git.embrapa.io). Se o projeto for arquivado antes disso, essa aplicação **não chegou a existir** — não há repositório nem _build_ —, e por isso ela é simplesmente descartada, em vez de guardada como histórico. Isso também evita que o autômato siga tentando criá-la indefinidamente, já que o grupo do projeto passa a ser somente leitura.

Vale notar que **arquivar o projeto inteiro não é o único caminho**. Se a intenção for retirar apenas uma aplicação, mantendo o projeto e as demais ativas, utilize a [remoção de aplicações]({{ site.baseurl }}/docs/remove).

> **Atenção!** Antes de executar os passos abaixo, execute o _backup_ de [todas as instâncias de _builds_]({{ site.baseurl }}/docs/backup), de todos os [repositórios do GitLab](https://git.embrapa.io) e, opcionalmente, do [histórico de erros](https://bug.embrapa.io). **Após arquivar o projeto, o _backup_ não será mais possível!**

Para iniciar o processo de arquivamento do projeto, um _Architect_ deve acessar a opção no menu contextual:

![Opção de arquivar no menu contextual do projeto]({{ site.baseurl }}/assets/img/archive/01.png)

Após ler o aviso e aceitar os termos, um PIN (_one-time password_) será enviado ao e-mail do usuário (_Architect_) para confirmar a ação.

![PIN de confirmação para arquivar o projeto]({{ site.baseurl }}/assets/img/archive/02.png)

Por fim, basta inserir o código e clicar em "Arquivar" para iniciar o processo.

## Resgatando um projeto arquivado {#restaurar}

O arquivamento **não é definitivo**: nada é apagado, e um projeto arquivado pode voltar a ser trabalhado.

Como o arquivamento retira toda a equipe, não sobra ninguém no projeto para reverter a situação — nem mesmo quem era _Architect_. O resgate, portanto, precisa ser feito por um **administrador da plataforma**, que readiciona ao menos um membro à equipe. É esse ato que desarquiva o projeto.

A partir daí, a plataforma refaz o caminho de volta sozinha:

1. O projeto reaparece na _dashboard_ de quem foi incluído na equipe;
2. O grupo do projeto no [GitLab](https://git.embrapa.io) deixa de ser somente leitura, e os repositórios das aplicações voltam a aceitar escrita; e
3. Os acessos às ferramentas integradas ([Sentry](https://bug.embrapa.io), [Matomo](https://hit.embrapa.io) e [SonarQube](https://code.embrapa.io)) são restabelecidos para a equipe.

Duas coisas, porém, **não voltam sozinhas**:

- As [instâncias de _builds_]({{ site.baseurl }}/docs/health) foram desfeitas no arquivamento e precisam ser implantadas novamente, estágio por estágio. As configurações de _build_ (variáveis de ambiente, volumes) são preservadas.
- Os [repositórios de suporte]({{ site.baseurl }}/docs/project#support) (`io-web`, `io-doc` e afins) continuam desabilitados, e devem ser reativados pela _dashboard_, na mesma tela em que foram criados.

Já as aplicações que haviam sido **descartadas** por nunca terem chegado a existir (o terceiro item da lista acima) não retornam — elas nunca tiveram repositório. Se ainda forem necessárias, basta criá-las de novo, com o mesmo nome.
