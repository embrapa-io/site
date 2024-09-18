---
layout: page
title: LGPD
subtitle: Proteção de dados pessoais em ativos digitais
---

A [Lei Geral de Proteção de Dados - LGPD (13.709/2018)](http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) tem como principal objetivo proteger os direitos fundamentais de privacidade, além de padronizar regulamentos e práticas para promover a proteção aos dados pessoais no Brasil, de acordo com os parâmetros internacionais existentes.

A lei define o que são dados pessoais e explica que alguns deles estão sujeitos a cuidados ainda mais específicos, como os dados pessoais sensíveis e de crianças e adolescentes. Esclarece ainda que todos os dados tratados, tanto no meio físico quanto no digital, estão sujeitos à regulação. Além disso, a LGPD estabelece que não importa se a sede de uma organização ou o centro de dados dela estão localizados no Brasil ou no exterior: se há o processamento de informações sobre pessoas, brasileiras ou não, que estão no território nacional, a LGPD deve ser observada.

Na LGPD, o consentimento do titular dos dados é considerado elemento essencial para o tratamento deste dados. Neste sentido, existem garantias ao cidadão que afetam de forma prática o desenvolvimento e sustentação de ativos digitais. Por exemplo, a qualquer momento o usuário pode solicitar que os seus dados pessoais sejam completamente excluídos, pode revogar o consentimento de uso ou transferir dados para outro fornecedor de serviços, entre outras ações.

Assim, deve-se atentar para que tais garantias sejam efetivamente respeitadas. Neste sentido recomenda-se que todo ativo digital que colete dados pessoais considere o requisito não-funcional do usuário apagar seu perfil (e dados correlatos) a qualquer momento, pela própria interface do ativo (se aplicável).

![Apagando meu próprio perfil de usuário.]({{ site.baseurl }}/assets/img/lgpd/01.png)

Quando o ativo digital em questão **não coleta dados pessoais**, é necessário explicitar por meio do [aviso de privacidade para aplicativo móvel sem coleta de dados pessoais](https://www.embrapa.br/acessoainformacao/aviso-de-privacidade-para-aplicativo-movel-sem-coleta-de-dados-pessoais). Neste caso, insira um botão com link para esta página na tela de "Sobre", p.e., ou outro local facilmente acessível pelo usuário.

Caso o ativo **faça tratamento de dados pessoais**, os desenvolvedores deverão se atentar aos seguintes pontos:

- Elaboração e validação (junto à AJU/SJPIN) dos "**Termos de Uso**" e "**Aviso de Privacidade**" (considere redigir minutas com base nos [modelos homologados pela área jurídica](https://drive.google.com/drive/folders/1ttWCq2nMiMy__iirf4eNlGyES-U9cQ9t?usp=sharing)), bem como posterior disponibilização destes instrumentos na interface do ativo de forma a garantir o aceite de consentimento dos usuários antes da coleta de dados pessoais.

![Aceite dos Termos de Consentimento.]({{ site.baseurl }}/assets/img/lgpd/02.png)

- Mecanismos que permitam o _backup_ destes dados pelo próprio usuário (preferencialmente em um formato legível, tal como planilhas Excel) e sua restauração posterior.

![Backup de dados pela interface da aplicação.]({{ site.baseurl }}/assets/img/lgpd/03.png)

Além disso, tenha cautela ao solicitar informações distintas, pois a "**minimização na coleta de dados pessoais**" é um dos preceitos da LGPD. Neste contexto, rege o princípio da "finalidade", segundo o qual o tratamento de dados pessoais somente deverá ser realizado para finalidades legítimas, específicas, explícitas e informadas ao seu titular, sem possibilidade de tratamento posterior de forma incompatível com as finalidades inicialmente informadas.

De forma coerente com este princípio, em todas as situações em que for necessária a coleta de dados pessoais, deve ser analisada a finalidade desta coleta e coletados apenas os dados necessários para que ela seja atendida. Assim, caso a finalidade seja, por exemplo, apenas a sincronização de dados para resguardá-los e permitir o seu compartilhamento em diferentes dispositivos, apenas o e-mail pode ser necessário.

![Perfil de usuário com e-mail como único dado obrigatório.]({{ site.baseurl }}/assets/img/lgpd/04.png)

No exemplo acima o único dado obrigatório é o "**e-mail**". Este é utilizado para vincular o perfil digital ao usuário do mundo real, permitindo que ele possa acessar seus dados a partir de múltiplos dispositivos (celular, computador, tablet, etc). A imagem do usuário, utilizada para uma melhor experiência de uso (UX), é provida pelo serviço [Gravatar](https://gravatar.com) (se disponível). Até mesmo o nome é opcional e fica a critério do usuário fornecer ou não. No estudo de caso acima, são solicitadas informações profissionais, mas elas ficam armazenadas apenas localmente (e não nos servidores remotos), endo necessário ao usuário cadastrá-las novamente em cada dispositivo.
