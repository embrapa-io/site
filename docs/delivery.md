---
layout: page
title: Publicação de Aplicações
subtitle: Onde e como entregar as builds em cada estágio de maturidade
---

Uma dúvida recorrente das equipes e dos Núcleos de Tecnologia da Informação (NTIs) das Unidades é **onde** cada versão de uma aplicação deve rodar e **por qual mecanismo** ela deve ser publicada. A resposta depende de duas variáveis: o **estágio de maturidade** da _build_ e o **_Tier_** da infraestrutura disponível.

Chamamos de **_Tier_** (do inglês, patamar ou camada) o nível de robustez e de suporte de uma infraestrutura, numerado de 0 a 4: do computador do desenvolvedor, sem qualquer salvaguarda, até a nuvem contratada com suporte 24x7. É uma classificação **da infraestrutura**, inspirada nos _tiers_ de _data center_ usados pelo mercado, e não um acordo de nível de serviço (SLA) com métricas e penalidades contratuais. Os cinco _Tiers_ estão [definidos adiante](#tiers).

Em uma frase: **use o catálogo de _clusters_ compartilhados da plataforma para os estágios de menor maturidade e o utilitário Releaser, em máquina dedicada, para produção.** As seções a seguir explicam o porquê, listam os critérios que podem alterar essa regra e detalham as responsabilidades de cada caminho.

## Contexto {#context}

A plataforma **Embrapa I/O** atende a dois universos distintos de _software_. De um lado estão os **sistemas gerenciais**: sistemas de informação, utilitários e ferramentas de apoio institucional e de automação de processos da Sede e das Unidades, como o Ideare, o Integro, o ERP/SAP, o SEI, o SIExp, o Redape, o Alelo e o GeoInfo. De outro estão os **ativos digitais agropecuários**: aplicativos móveis, aplicações _web_, _software_ embarcado, ferramentas de _desktop_, APIs e modelos de linguagem voltados à agricultura, à pecuária, às florestas, à aquicultura e à indústria de processamento, organizados em produtos e plataformas institucionais e em [ecossistemas temáticos digitais]({{ site.baseurl }}/docs/macroprocess).

Os dois universos compartilham os mesmos desenvolvedores e a mesma plataforma, e é por isso que a orientação sobre publicação vale para ambos. O que muda é o **destino final** da instância de produção: sistemas gerenciais de uso global tendem para o _data center_ da Sede, e ativos digitais agropecuários para o ambiente AgroDigital, na Embrapa Agricultura Digital, ou para a infraestrutura da própria Unidade.

## Estágios, builds e o que é instanciado {#stages}

O processo de desenvolvimento da plataforma possui quatro [estágios]({{ site.baseurl }}/docs/introduction#stage): **_development_** (desenvolvimento, no computador do desenvolvedor), **_alpha_** (testes internos, em ambientes de baixa robustez), **_beta_** (testes externos ou homologação, em ambientes de pelo menos média robustez) e **_release_** (produção, em ambientes de alta robustez, com resiliência, monitoramento e salvaguardas).

A unidade de publicação é a [**_build_**]({{ site.baseurl }}/docs/introduction#build), a combinação de uma aplicação com um estágio (`siexp/coletor@alpha`, `siexp/coletor@beta`, `siexp/coletor@release`), que recebe [versões]({{ site.baseurl }}/docs/introduction#version) sucessivas. Cada _build_ é uma instância **totalmente independente das demais**, com seus próprios dados, instanciada como uma pilha (_stack_) de _containers_ com volumes e rede isolados, em um servidor ou VM que pode ser diferente para cada estágio. É esse isolamento que permite escolher o destino de cada _build_ separadamente: a _alpha_ pode viver em um _cluster_ compartilhado enquanto a _release_ roda em uma máquina dedicada.

## Métodos de deploy {#methods}

![Os dois métodos de deploy: catálogo de clusters compartilhados ou utilitário Releaser]({{ site.baseurl }}/assets/img/delivery/01.png)

Existem duas formas de realizar o _deploy_ (a instanciação de uma _build_):

### Pelo catálogo de clusters compartilhados {#catalog}

São _clusters_ previamente configurados e disponibilizados às equipes de desenvolvimento em um [catálogo]({{ site.baseurl }}/resources/clusters) na interface da plataforma, para uso compartilhado. A equipe [escolhe o _cluster_ ao configurar a _build_]({{ site.baseurl }}/docs/build) e o [_deploy_]({{ site.baseurl }}/docs/deploy) acontece ao criar uma _tag_ no repositório.

**Prós:**

- A plataforma cuida de toda a configuração: criação dos volumes, URLs (_virtual proxies_), certificados SSL, variáveis de ambiente, integração com SMTP e GPU Servers.
- Diversas ferramentas vêm integradas: _log_ centralizado, _web terminal_ para acesso aos _containers_ e monitoramento pela _dashboard_.
- **Busca ativa de vulnerabilidades (CVEs)** nas imagens construídas para a _build_. Essa varredura só é possível aqui, porque é no _deploy_ pelo _cluster_ que a plataforma constrói as imagens e passa a conhecer todas as dependências da aplicação.

**Contras:**

- Os recursos de _hardware_ (disco, memória, processamento) são compartilhados entre todas as _builds_ instanciadas no mesmo _cluster_, sem controle fino por aplicação.
- Um único _router_ (balanceador de carga) monta os _virtual proxies_ de todas as aplicações do _cluster_, o que o torna um ponto de vulnerabilidade e de falha.
- É necessário abrir portas específicas e fazer uma configuração apropriada no servidor, porque **a plataforma conecta ativamente no _cluster_** para operá-lo.

### Pelo utilitário Releaser {#releaser}

O [**Releaser**]({{ site.baseurl }}/docs/releaser) é uma imagem pública no [Docker Hub](https://hub.docker.com/r/embrapa/releaser) que pode ser instalada em qualquer _cluster_, VM ou servidor externo, em qualquer local, e que implanta os _pipelines_ de _deploy_ da plataforma nesse servidor. Roda como um _container_ com acesso ao _socket_ do Docker, expõe o comando `io` com as operações de `validate`, `deploy`, `stop`, `restart`, `rollback`, `backup`, `sanitize` e `info`, e opera como serviço em segundo plano mantendo as _builds_ na versão mais recente.

**Prós:**

- Não exige abertura de portas de entrada nem configurações especiais no servidor: **é o Releaser que acessa a plataforma**, e não o contrário.
- Além do _pipeline_ de _deploy_, implementa o _backup_ diário e a sanitização mensal das _builds_.
- Permite controle fino dos recursos de _hardware_, já que a máquina é da equipe.
- As integrações configuradas por _build_ (Sentry, Matomo, SonarQube) continuam funcionando exatamente como nos _clusters_ do catálogo.

**Contras:**

- A equipe do projeto (ou o NTI da Unidade) precisa configurar o orquestrador, o DNS, os certificados SSL, o _virtual proxy_ e os volumes.
- Integrações com servidores SMTP e GPU Servers, por exemplo, precisam ser providenciadas pela própria equipe.
- A plataforma **não controla** essas instâncias: não consegue suspender, reiniciar ou gerar _backup_ sob demanda pela _dashboard_.
- **Não há busca ativa de CVEs** nas imagens (ainda). O Releaser puxa imagens prontas e não participa da construção, então não tem como inventariar as dependências.
- Não há _web terminal_ nem _logs_ na _dashboard_: para isso, recomenda-se instalar o [Portainer]({{ site.baseurl }}/docs/releaser#portainer) ou ferramenta similar e, para centralizar os _logs_ no Grafana da plataforma, configurar o [_plugin_ do Loki]({{ site.baseurl }}/docs/releaser#loki) no Docker do servidor.
- O _backup_ diário fica **no próprio servidor**. Levá-lo para fora é [responsabilidade da equipe](#responsibilities), como detalhado no [capítulo de _backup_]({{ site.baseurl }}/docs/backup#production).

### Qual usar em cada estágio {#which}

![Em resumo: clusters compartilhados para alpha e beta, Releaser para release]({{ site.baseurl }}/assets/img/delivery/02.png)

Em resumo, recomenda-se utilizar **o catálogo de _clusters_ compartilhados para os níveis de maturidade mais baixos** (_alpha_ e _beta_) e **o utilitário Releaser para os níveis mais altos** (_release_). Os contras do catálogo (recursos compartilhados e _router_ único) são aceitáveis em testes, mas viram risco em produção. Os contras do Releaser (configuração por conta da equipe) são um investimento que só se justifica quando a aplicação está madura o suficiente para ir a produção.

Há uma segunda razão para separar a produção, que não é técnica: **otimizar a equipe humana**. Quando a _release_ roda em uma máquina operada pela Unidade, empregados da própria Unidade passam a se envolver e a se responsabilizar pelo suporte e pela sustentação da aplicação em produção, em vez de tudo recair sobre a equipe central da plataforma. É esse envolvimento que dá escala à plataforma e que mantém o conhecimento sobre a aplicação perto de quem a usa.

#### A alpha fica no catálogo {#alpha}

A _alpha_ deve permanecer no catálogo de _clusters_. Seu papel é o teste interno rápido e descartável, e ela se beneficia de tudo o que a plataforma automatiza. Mas há um motivo mais forte: **a busca ativa de CVEs acontece apenas nos _clusters_ compartilhados**, nas imagens construídas no _deploy_ da _build_, porque só nesse momento a plataforma conhece todas as dependências da aplicação. O Releaser não faz essa varredura. Manter a _alpha_ no catálogo é, portanto, a forma de garantir que toda versão da aplicação passe pela varredura de vulnerabilidades antes de chegar à _beta_ e à _release_.

#### A beta como ensaio da produção {#beta}

O estágio _beta_ é o coringa dessa recomendação. Ele pode ser instanciado no catálogo de _clusters_ compartilhados, como qualquer estágio de testes, mas também pode ser instanciado **pelo Releaser, em uma VM no mesmo _data center_ onde a produção vai rodar**. A vantagem desta segunda abordagem é que a _beta_ passa a ter características de instanciação muito mais próximas das da _release_: o mesmo orquestrador, a mesma forma de expor portas e subdomínios, o mesmo _virtual proxy_ e os mesmos certificados, o mesmo SMTP, as mesmas rotinas de _backup_ e sanitização e, principalmente, a mesma equipe operando a máquina.

Isso importa porque a _beta_ é o **último teste antes da produção**. Se ela roda em um ambiente que a plataforma configura sozinha e a _release_ roda em um ambiente que a equipe configura por conta própria, a homologação valida a aplicação, mas não valida a operação: os erros de configuração de DNS, de _proxy_, de volumes ou de variáveis de ambiente só vão aparecer no dia do _deploy_ em produção. Instanciar a _beta_ pelo Releaser antecipa esses erros para a fase em que ainda é barato corrigi-los e, de quebra, serve de treinamento para quem vai operar a produção.

A recomendação, portanto, é gradual: comece a _beta_ no catálogo de _clusters_ enquanto o foco ainda é o comportamento da aplicação e, **assim que a produção estiver no horizonte**, migre-a para o Releaser no _data center_ de destino, de preferência em uma VM separada da de produção (ou, na falta de recursos, na mesma VM, já que o Releaser isola as _builds_ em pilhas de _containers_ independentes). Como a _alpha_ continua no catálogo, a varredura de CVEs segue cobrindo cada versão antes de ela chegar à _beta_.

> **Atenção!** Enquanto a plataforma estiver em _Beta Release_, a disponibilização de aplicações em produção por meio do catálogo de _clusters_ compartilhados é **fortemente desencorajada**, conforme já explicado no [capítulo do Releaser]({{ site.baseurl }}/docs/releaser). Essa é a situação atual, não a arquitetura-alvo: à medida que a plataforma amadurecer e ganhar controle fino de recursos, poderão existir _clusters_ dedicados de produção no próprio catálogo.

## Tiers de infraestrutura {#tiers}

![Tiers de infraestrutura e estágios recomendados para cada um]({{ site.baseurl }}/assets/img/delivery/03.png)

Para responder "onde instanciar", é preciso classificar a infraestrutura disponível. A orientação adota cinco **_Tiers_**, definidos pela robustez do ambiente e pelo suporte que ele recebe:

| _Tier_ | Descrição | Estágios | Instanciador |
|---|---|---|---|
| **Tier 0** | Próprio computador do desenvolvedor (_workstation_), sem IP público ou visibilidade externa. | Apenas _development_ | Não se aplica |
| **Tier 1** | Servidores ou PCs do tipo _desktop_ configurados para atuar como servidores de aplicação. Com limitações de _nobreak_, grupo gerador, _backup_ e monitoramento. Com visibilidade externa ou apenas na intranet da Unidade, via IP público ou NAT. | Apenas _alpha_ | Releaser (em VM compartilhada ou direto no _bare metal_) |
| **Tier 2** | Servidores de aplicação nos _data centers_ das Unidades, com salvaguardas e resiliência (_nobreak_, grupo gerador, _backup_ e monitoramento), porém sem necessariamente suporte contratado ou garantia ativa. | _alpha_, _beta_ e, **eventualmente**, _release_ (veja os [critérios adicionais](#criteria)) | Catálogo de _clusters_ para _alpha_ e _beta_. Releaser para qualquer estágio, com **VM dedicada** em _release_. |
| **Tier 3** | Servidores em _data centers_ robustos, com suporte pleno contratado, como o da **Sede** (para sistemas gerenciais de uso institucional global) e o **AgroDigital**, na Embrapa Agricultura Digital (para ativos digitais agropecuários). | _alpha_, _beta_ e _release_ | Catálogo de _clusters_ para _alpha_ e _beta_. Releaser para qualquer estágio, com **VM dedicada** em _release_. |
| **Tier 4** | Servidores em **nuvens externas privadas**, contratadas ou disponibilizadas no contexto do projeto. Além da robustez, das salvaguardas e da resiliência, possuem suporte 24x7. | _alpha_, _beta_ e _release_ | Releaser para qualquer estágio, com **VM dedicada** em _release_. |

Dois pontos merecem destaque. O primeiro é que um _cluster_ compartilhado do catálogo pode estar hospedado em Tier 2 ou Tier 3 (e muitos estão), mas o **compartilhamento** dos recursos é o que o torna inadequado para produção, não o _Tier_ do _data center_. O segundo é que "VM dedicada" significa uma máquina virtual exclusiva para a _build_ de produção, com recursos reservados e sem outras _builds_ concorrendo por eles.

## Critérios adicionais {#criteria}

O estágio de maturidade e o _Tier_ dão a regra geral. Antes de decidir o destino de uma _build_ de produção, a equipe deve cruzar essa regra com cinco critérios que podem endurecê-la ou flexibilizá-la:

1. **Sensibilidade dos dados.** Aplicações que tratam dados pessoais (veja o capítulo sobre [proteção de dados pessoais]({{ site.baseurl }}/docs/lgpd)), dados sigilosos ou resultados de pesquisa ainda não publicados devem ficar em infraestrutura da Embrapa (Tier 2 ou Tier 3). A nuvem externa (Tier 4) só entra com contrato que cubra a guarda dos dados e a responsabilidade do operador.
2. **Requisito de disponibilidade.** Pergunte quanto tempo a aplicação pode ficar fora do ar e quantos dados pode perder em um incidente (o mercado chama isso de RTO e RPO). Uma aplicação de campo, usada esporadicamente e que funciona _offline_, tolera horas de indisponibilidade, e isso **pode justificar sua produção em Tier 2**, no _data center_ da própria Unidade. Um sistema gerencial que para o trabalho de muita gente quando cai pede Tier 3.
3. **Público e integrações.** Aplicações de uso interno que dependem de serviços da rede corporativa (autenticação no AD/LDAP, SEI, bases da Sede) rodam melhor onde essas integrações já existem, em geral a Sede. Aplicações para o público externo precisam de IP público, proteção de borda e um domínio institucional, o que favorece o AgroDigital ou a Sede.
4. **Carga e recursos especiais.** Aplicações com banco de dados pesado, processamento em lote, GPU para inferência ou muitos usuários simultâneos precisam de recursos reservados, e não devem dividir máquina com nada, nem mesmo com a própria _beta_.
5. **Capacidade de operação.** O Releaser transfere para a equipe (ou para o NTI) a operação da máquina. Se ninguém na Unidade puder assumir atualização do sistema operacional, _backup_ fora do servidor e resposta a incidentes, é melhor buscar a Sede ou o AgroDigital do que colocar produção em uma VM que não terá dono.

## Recomendações às Unidades {#recommendations}

![Recomendações às Unidades: onde instanciar as builds em cada estágio]({{ site.baseurl }}/assets/img/delivery/04.png)

Onde instanciar as _builds_ em cada estágio de desenvolvimento:

- **_development_**: sempre em ambiente local utilizando o Docker, ou seja, no próprio computador do desenvolvedor (Tier 0). Todos os [_boilerplates_]({{ site.baseurl }}/resources/boilerplates) da plataforma já trazem a configuração para isso.
- **_alpha_**: em servidores compartilhados do [catálogo de _clusters_]({{ site.baseurl }}/resources/clusters) da plataforma (recomendado, pela [varredura de CVEs](#alpha)) ou na Unidade, em Tier 1 ou superior.
- **_beta_**: em servidores compartilhados do catálogo de _clusters_ da plataforma (recomendado) ou na Unidade, em Tier 2 ou superior. Quando a produção estiver próxima, vale instanciá-la pelo Releaser no _data center_ de destino, como [ensaio da produção](#beta).
- **_release_**:
  - na Unidade, em Tier 3 ou superior, em **VM dedicada**; eventualmente em Tier 2, quando os [critérios adicionais](#criteria) permitirem (por exemplo, aplicação de campo com baixo requisito de disponibilidade e sem dados sensíveis);
  - se for **_software_ institucional**, na Sede, em VM dedicada (Tier 3);
  - se for **ativo digital agropecuário**, no AgroDigital, no ambiente "UDS" gerenciado pela própria Unidade, em **VPS dedicada** (Tier 3); ou
  - eventualmente, se o projeto dispuser de recursos ou de parceria, em nuvem privada externa (Tier 4), com VPS dedicada.

A VM dedicada no _data center_ da Sede é solicitada pela Central de Atendimento da GTI, no serviço "Equipamentos de TI e VMs", opção "Solicitar Máquina Virtual - VM". No chamado, informe o projeto, a finalidade (produção de uma aplicação do Embrapa I/O), os recursos estimados (vCPUs, memória e disco) e que a máquina será operada pelo Releaser, o que dispensa a abertura de portas de entrada além das do serviço publicado.

### Sobre a nuvem externa {#cloud}

A opção de nuvem privada externa (Tier 4) aparece como "eventual" por uma razão discutida com a GTI em setembro de 2025. A [Lei nº 14.129/2021](https://www.gov.br/governodigital/pt-br/legislacao/lei-do-governo-digital) (Lei do Governo Digital) e a estratégia que a materializa orientam a administração federal a contratar computação em nuvem como serviço, e a [Portaria SGD/MGI nº 5.950/2023](https://www.gov.br/governodigital/pt-br/contratacoes-de-tic/legislacao/modelo-de-contratacao-de-software-e-servicos-em-nuvem/vigentes/portaria-sgd-mgi-no-5-950-de-26-de-outubro-de-2023) estabelece o modelo obrigatório de contratação de _software_ e de serviços de nuvem para os órgãos do SISP. Fornecedores de sistemas corporativos, por sua vez, passaram a oferecer suas soluções apenas nesse formato. Por outro lado, a experiência da GTI é que migrar para a nuvem as aplicações da forma como estão arquitetadas hoje tende a custar mais do que mantê-las nos _data centers_ próprios, cujo investimento ainda está em amortização, além de trazer riscos próprios de segurança, de dependência do fornecedor e de gestão financeira. Assim, a nuvem externa fica reservada aos projetos que já dispõem desse recurso, em geral por meio de parceria, e não é um caminho que a Unidade deva contratar apenas para hospedar uma _build_ de produção.

## Subdomínios de projetos {#subdomains}

> **Atenção!** Assim como ocorre com aplicativos móveis nas lojas de terceiros (Google Play e App Store), aplicações _web_ só podem ser colocadas em produção após devidamente qualificadas em **TRL 7** (_Beta Release_) ou superior. Veja as [orientações sobre o nível de maturidade]({{ site.baseurl }}/docs/guidelines#trl) e o capítulo sobre [lançamento de MVPs]({{ site.baseurl }}/docs/mvp).

Nos _clusters_ do catálogo, as URLs são [geradas automaticamente]({{ site.baseurl }}/docs/build#urls) a partir dos domínios do _cluster_. Em produção, a aplicação precisa de um domínio institucional. Para os serviços publicados no _data center_ da GTI, é criado no DNS da Embrapa um registro no formato **`nome-do-projeto.embrapa.br`** que redireciona qualquer prefixo (subdomínio), permitindo que a equipe utilize, no âmbito do projeto, endereços como `www.nome-do-projeto.embrapa.br`, `app.nome-do-projeto.embrapa.br` ou `portal.nome-do-projeto.embrapa.br`.

O registro do domínio do projeto é solicitado à GTI pela Central de Atendimento. A partir daí, a gestão dos subdomínios e dos certificados SSL de cada serviço é responsabilidade da equipe, no _virtual proxy_ da própria VM, conforme as [orientações do capítulo do Releaser]({{ site.baseurl }}/docs/releaser#proxy). Em casos específicos, quando o serviço é publicado por trás do _proxy_ central da GTI, os subdomínios passam a ser geridos pelos arquitetos de solução do projeto na ferramenta <https://proxy.embrapa.io>, uma instância do Nginx Proxy Manager. Consulte a SDAD para saber se o seu projeto se enquadra nesse caso.

Um exemplo concreto é o projeto Flora, publicado em outubro de 2025 em uma VPS dedicada no _data center_ da Sede. A máquina expõe publicamente uma única porta, a do _proxy_; todos os serviços ficam em portas internas mapeadas pelo Nginx Proxy Manager, cada um com seu subdomínio. O Releaser mantém as _builds_ atualizadas, o Portainer dá visibilidade de _logs_ e terminal à equipe, e as integrações com o Sentry, o Matomo e o SonarQube continuam funcionando exatamente como nos _clusters_ do catálogo, porque são configuradas por _build_ e não pelo servidor.

## Responsabilidades por método {#responsibilities}

Escolher o Releaser é escolher um **dono para a produção**. A tabela abaixo deixa explícito o que muda de mãos em cada método. Nela, "plataforma" é a equipe do Embrapa I/O, e "equipe" é a equipe do projeto ou o NTI da Unidade que opera a máquina.

| Atividade | Catálogo de _clusters_ | Releaser em máquina dedicada |
|---|---|---|
| _Deploy_, _rollback_ e atualização de versão | Plataforma (automática, por _tag_) | Releaser (automático, por _tag_); a equipe acompanha |
| Construção das imagens e **varredura de CVEs** | Plataforma | Não há varredura; a equipe deve atualizar as imagens-base (veja [imagens em _latest_]({{ site.baseurl }}/docs/app)) |
| Monitoramento de disponibilidade e _health check_ | Plataforma (_dashboard_ e alertas) | Equipe (Portainer, Grafana da Unidade ou _plugin_ do Loki) |
| _Error tracking_ e _analytics_ (Sentry, Matomo) | Plataforma | Plataforma (configurados por _build_) |
| _Backup_ | Sob demanda pela _dashboard_; rotina do _cluster_ pelo mantenedor | Diário pelo Releaser no servidor; **cópia para fora do servidor pela equipe** ([regra 3-2-1]({{ site.baseurl }}/docs/backup#production)) |
| Sanitização e limpeza de _cache_ | Plataforma | Releaser (mensal) |
| Sistema operacional, Docker e segurança da máquina | Mantenedor do _cluster_ | Equipe |
| DNS, _virtual proxy_ e certificados SSL | Plataforma (automático) | Equipe |
| SMTP, GPU Servers e outras integrações de infraestrutura | Plataforma | Equipe |
| Resposta a incidentes (aplicação fora do ar, invasão, perda de dados) | Plataforma aciona a equipe | Equipe, com apoio da SDAD |
| Suporte ao usuário final | Equipe | Equipe |

> **Atenção!** Antes de solicitar a VM de produção, a equipe deve nomear quem responde por cada linha da coluna "Releaser" e registrar isso no _README_ do projeto. Uma VM sem dono é o cenário que mais gera incidentes na plataforma.

## Resumo {#summary}

| Estágio | Onde | Como |
|---|---|---|
| _development_ | Computador do desenvolvedor (Tier 0) | Docker local, a partir do _boilerplate_ |
| _alpha_ | Catálogo de _clusters_ (recomendado, pela varredura de CVEs) ou Unidade em Tier 1+ | _Tag_ no GitLab; Releaser se for na Unidade |
| _beta_ | Catálogo de _clusters_ (recomendado) ou Unidade em Tier 2+; perto da produção, o _data center_ de destino | _Tag_ no GitLab; Releaser se for na Unidade ou como ensaio da produção |
| _release_ | VM ou VPS **dedicada** em Tier 3 (Sede, AgroDigital ou Unidade); eventualmente Tier 2 ou Tier 4, conforme os [critérios adicionais](#criteria) | Releaser |

Em caso de dúvida sobre o enquadramento da infraestrutura da sua Unidade em um dos _Tiers_, ou sobre a solicitação de VM e de subdomínio, entre em contato com a SDAD pelo e-mail <gti.sdad@embrapa.br>.
