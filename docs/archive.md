---
layout: page
title: Arquivar
subtitle: Como arquivar um projeto?
---

Atualmente não é possível apagar completamente um projeto do **embrapa.io**. Ocorre que a remoção de dados é um tema sensível, que deve ser tratado com extremo cuidado. Por conta disso, neste momento, um projeto criado na plataforma permanecerá ocupando permanentemente o nome _unix_ que tenha sido alocado e seus dados, tal como código-fonte, documentação e as instâncias das _builds_, permanecerão disponíveis.

Entretanto, por diversos motivos e visando manter o painel do **embrapa.io** organizado, pode ser necessário **arquivar um projeto**. O arquivamento de projetos atua executando 3 ações:

1. Desabilita os [repositórios de suporte]({{ site.baseurl }}/docs/project#support) do projeto;
2. Desativa todas as [instâncias de _builds_]({{ site.baseurl }}/docs/health) de todas as aplicações; e
3. Remove toda a [equipe do projeto]({{ site.baseurl }}/docs/project#team), tornando-o inacessível.

> **Atenção!** Antes de executar os passos abaixo, execute o _backup_ de [todas as instâncias de _builds_]({{ site.baseurl }}/docs/backup), de todos os [repositórios do GitLab](https://git.embrapa.io) e, opcionalmente, do [histórico de erros](https://bug.embrapa.io). **Após arquivar o projeto, o _backup_ não será mais possível!**

Para iniciar o processo de arquivamento do projeto, um _Architect_ deve acessar a opção no menu contextual:

![Opção de arquivar no menu contextual do projeto]({{ site.baseurl }}/assets/img/archive/01.png)

Após ler o aviso e aceitar os termos, um PIN (_one-time password_) será enviado ao e-mail do usuário (_Architect_) para confirmar a ação.

![PIN de confirmação para arquivar o projeto]({{ site.baseurl }}/assets/img/archive/02.png)

Por fim, basta inserir o código e clicar em "Arquivar" para iniciar o processo.
