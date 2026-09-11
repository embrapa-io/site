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
