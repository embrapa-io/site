---
layout: post
title: Lançamento da Versão 1.25.4
subtitle: Alerta de CVEs, LLMs e melhorias na gestão das builds.
# cover-img: /assets/img/dashboard/02.png
# thumbnail-img: /assets/img/icon-back.png
# share-img: /assets/img/icon-back.png
tags: [ releases, features ]
---

Foi disponibilizada uma nova versão do **Embrapa I/O** (a `1.25.4`) com novidades. Em resumo, temos as seguintes novas funcionalidades e melhorias:

1. [Busca ativa por CVEs com alertas na _dashboard_](#cve);
2. [Integração com GPU Servers para uso de LLMs nos projetos](#gpu);
3. [Possibilidade de atualizar imagens e apagar containers no _restart_ da _build_](#restart);
4. [Possibilidade de remover completamente a instância (_deploy_) de uma _build_](#remove); e
5. [Melhorias de segurança na integração de _clusters_](#ssh).

A seguir, são detalhadas cada uma delas.

## 1. Busca ativa por CVEs com alertas na _dashboard_ {#cve}

A plataforma **Embrapa I/O** implementa agora a busca ativa por **Vulnerabilidades e Exposições Comuns** (do inglês, _Common Vulnerabilities and Exposures - CVE_) nas imagens das aplicações instanciadas em sua rede de _clusters_.

O CVE é um índice que padroniza a identificação de vulnerabilidades de segurança em softwares e sistemas. Cada CVE possui um identificador único (p.e., CVE-2025-12345), que descreve uma falha específica de segurança. Por meio deste identificador, pode-se buscar mais informações em bancos de dados especializados. No **Embrapa I/O** cada CVE é detectado por meio da ferramenta [Trivy](http://trivy.dev) e está lincado ao [_National Vulnerability Database - NVD_](https://nvd.nist.gov).

Quando os processos de varredura (_scanner_) detectam CVEs nas imagens utilizadas pelos containers das aplicações, é mostrado um ícone especial no botão de _health check_ da _build_ instanciada (_a_) no _card_ do projeto:

![Alerta de CVEs no card do projeto]({{ site.baseurl }}/assets/img/posts/20250423221120.png)

Se houver apenas CVEs de severidade "alta" (**HIGH**), será mostrado um ícone laranja. Porém se existirem CVEs de severidade "crítica" (**CRITICAL**), o ícone será vermelho. Acessando o painel de _health check_ por este botão (_b_), pode-se ver exatamente qual(is) container(s) possui(em) imagens com CVEs identificados (_c_). Clicando sobre o ícone indicado, é mostrada a listagem das vulnerabilidades:

![Lista de vulnerabilidades identificadas na imagem do container]({{ site.baseurl }}/assets/img/posts/20250423221640.png)

Além da descrição, pode-se verificar qual pacote está apresentando vulnerabilidade e qual a versão corrigida (para qual o mesmo deve ser atualizado).

> **Atenção!** É importante ressaltar que as imagens são escaneadas a partir das _builds_ instanciadas na rede de _clusters_ da plataforma. Desta forma, _deploys_ em servidores externos ao ecossistema do **Embrapa I/O** (instanciadas por meio do [Releaser]({{ site.baseurl }}/docs/releaser), p.e.) não serão contempladas. Assim, sugere-se fortemente que a rede de _clusters_ seja utilizada, no mínimo, para o _deploy_ de aplicações em estágio _alpha_ (testes internos), de forma que o projeto possa se beneficiar desta funcionalidade.

Esta é mais uma _feature_ da plataforma que visa fomentar o aprimoramento contínuo da qualidade das aplicações desenvolvidas na Embrapa (tanto em âmbito institucional, quanto para a agricultura digital), bem como ajudar a zelar pela segurança do ambiente digital da Empresa.

## 2. Integração com GPU Servers para uso de LLMs nos projetos {#gpu}

Visando viabilizar (e "democratizar") o uso de _Large Language Model - LLM_ nos projetos de desenvolvimento de software com uso da plataforma **Embrapa I/O**, está sendo estabelecida uma "**Arquitetura de Referência em IA Generativa**". Esta arquitetura estabelece alguns _boilerplates_ para o desenvolvimento de agentes de IA especializados por meio de [_Retrieval Augmented Generation - RAG_](https://www.alura.com.br/artigos/o-que-e-rag) e [_Prompt Engineering_](https://www.alura.com.br/artigos/engenharia-prompt) e integrados a APIs por meio de [_Model Context Protocol - MCP_](https://www.anthropic.com/news/model-context-protocol). Uma [apresentação prévia destes conceitos e da arquitetura em si](https://youtube.com/watch?v=HE-nwGI5W6w) já foi realizada e está disponível no [canal do YouTube do **Embrapa I/O**](https://youtube.com/@embrapa-io).

Dentre as especificidades desta arquitetura, está a disponibilização de _GPU Servers_ integrados aos _clusters_ de _deploy_ de aplicações. Com isso, espera-se reduzir o custo de bilhetagem para uso de LLMs via APIs externas, zelar pelo sigilo e propriedade intelectual destes dados e possibilitar a criação de projetos exploratórios e provas de conceito (PoC) em IA generativa.

As LLMs nestes _GPU Servers_ estão sendo disponibilizadas, em um primeiro momento, por meio do [Ollama](https://ollama.com). No momento da escolha do _cluster_ de [_deploy_ da _build_]({{ site.baseurl }}/docs/deploy) é possível visualizar se este recurso está disponível (_a_) e, neste caso, as configurações para uso do serviço (_b_):

![Recurso GPU Server ativo no cluster]({{ site.baseurl }}/assets/img/posts/20250424073246.png)

A partir da aplicação instanciada no _cluster_, poderão ser realizadas chamadas à API disponibilizada pelo _LLM Runtime_. Por exemplo, se estiver utilizando o [N8N](https://n8n.io), instanciado a partir do _boilerplate_ correlato, você poderá criar uma credencial do Ollama com a URL e porta indicadas:

![Registrando as credenciais do Ollama no N8N.]({{ site.baseurl }}/assets/img/posts/20250426220822.png)

Feito isso, as LLMs disponibilizadas no _GPU Server_ estarão à disposição no momento da criação dos _workflows_. Por exemplo, ao inserir um nó do tipo "_AI Agent_" no N8N, no _chat model_ será possível vincular as credenciais (_a_) e ele listará os modelos disponíveis no _GPU Server_ (_b_) para serem utilizadas pelo nó:

![LLMs do Ollama listadas como opção de chat model para um AI Agent do N8N]({{ site.baseurl }}/assets/img/posts/20250427075432.png)

As LLMs disponíveis podem ser utilizadas:

#### a. no processo RAG para geração de _embeddings_:

Ao montar um _workflow_ para geração de um BD com vetores visando RAG, pode-se utilizar um nó do tipo "_Embeddings Ollama_". Quando escolher as credenciais configuradas, serão listados todos os modelos disponíveis. Você pode consultar o melhor modelo para ser utilizado no seu contexto, mas um bom modelo genérico disponível para esta finalidade é o `bge-large`:

![Utilizando um modelo do Ollama para RAG]({{ site.baseurl }}/assets/img/posts/20250426223529.png)

No exemplo abaixo foram extraídas perguntas e respostas da API do [SAC Gado de Corte](https://cloud.cnpgc.embrapa.br/sac/) e utilizado o modelo `bge-large` a partir do _GPU Server_ para gerar os vetores. Estes foram armazenados no banco de dados [PGVector](https://github.com/pgvector/pgvector), que acompanha o _boilerplate_ do N8N (subindo como um serviço na _stack_ de containers).

![Processo de RAG]({{ site.baseurl }}/assets/img/posts/20250426223903.png)

#### b. pelo agente de IA, nas diversas etapas de tomada de decisão:

No exemplo abaixo, é utilizada a conexão com o Ollama rodando no _GPU Server_ para recuperar as os vetores do PGVector gerados no item anterior (por meio do modelo `bge-large`) e também para a escolha das melhores respostas (por meio do modelo `llama3.1:8b`). Para a interação com o usuário, foi utilizada a API bilhetada do OpenAI (e o modelo `gpt-4o-mini`).

![Configurando um AI Agent como assistente em Pecuária de Corte]({{ site.baseurl }}/assets/img/posts/20250426225351.png)

Cabe às equipes testar qual a LLM mais indicada para cada procedimento, no contexto do projeto. Vale ressaltar que estas possuem especializações diferenciadas (p.e., em língua portuguesa, em conversas mais longas e complexas, na geração de _embeddings_, etc). Você pode [buscar o modelo no catálogo do Ollama](https://ollama.com/search) para ver os detalhes ou simplesmente [perguntar ao ChatGPT sobre eles](https://chatgpt.com).

> **Atenção!** Esta é uma _feature_ **experimental** e existem diversas limitações e restrições de uso. Por exemplo, o uso das GPUs no servidor se dá de maneira concorrente e, portanto, elas podem estar todas ocupadas e indisponíveis em diversos momentos. O Ollama não permite ainda o uso paralelizado das GPUs, portanto estão sendo disponibilizadas em cada _GPU Server_ apenas LLMs que performem em uma única GPU deste servidor.

Importante também salientar: **o Ollama não é a _LLM Runtime_ mais performática!** Poderíamos ter resultados melhores com outras alternativas, tal como o [vLLM](https://docs.vllm.ai) (que é compatível com a API da OpenAI, possui Multi-GPU/MoE automático e é utilizado em produção pelo [Chatbot Arena](https://lmarena.ai), [OpenRouter](https://openrouter.ai), dentre outros). Entretanto o Ollama foi escolhido pelo fato de já ter a integração nativa com o N8N, permitindo uma validação inicial da arquitetura como um todo, favorecendo o uso por mais pessoas e fomentando a discussão de melhoria e evolução em IA generativa na Embrapa.

## 3. Possibilidade de atualizar imagens e apagar containers no _restart_ da _build_ {#restart}

A funcionalidade de reiniciar as aplicações (que derruba e reinicia todos os seus containers), presente no painel de _health check_ das instâncias de _builds_, possibilita agora:

1. **Atualizar as imagens de containers que foram baixadas diretamente de um _registry_** (tal como o [Docker Hub](https://hub.docker.com)). Ou seja, esta _feature_ não afeta os serviços que têm _build_ (definido no `docker-compose.yml`), uma vez que estas imagens já são atualizadas no processo de _deploy_, mas sim aquelas de serviços na _stack_ de containers que estão indicadas no atributo `image`; e

2. **Apagar completamente o containers**, visando um reinício em "ambiente limpo". O processo irá apagar a _network_ da _stack_ de containers, todos os containers, os volumes implícitos e as imagens que tiveram _build_ local, forçando a recriação destes artefatos do zero.

![Dialog de restart com funções de update e remove]({{ site.baseurl }}/assets/img/posts/20250424082127.png)

A **atualização das imagens** é extremamente útil para garantir que ferramentas de apoio (tal como um [pgAdmin](https://pgadmin.org), [Redis Commander](https://github.com/joeferner/redis-commander), [Mongo Express](https://hub.docker.com/_/mongo-express/), etc) se mantenham atualizados. Ajuda também a eliminar os [CVEs identificados](#cve), uma vez que traz a versão mais recente das imagens e, portanto, com as últimas manutenções corretivas e evolutivas. Por exemplo, para atualizar o [N8N](https://n8n.io) utilizado em alguns _boilerplates_ citados na [seção anterior](#gpu), basta agora fazer o reinício da aplicação com a opção de "**ATUALIZAR**" selecionada:

![Atualizando a imagem do N8N]({{ site.baseurl }}/assets/img/posts/20250424082942.png)

A **remoção dos containers** pode ser bastante útil também, <u>porém deve ser utilizada com cuidado</u>. Esta _feature_ preserva os dados persistidos, uma vez que não apaga os volumes explícitos das aplicações (aqueles declarados na [configuração da _build_]({{ site.baseurl }}/docs/build/#volumes)), mas ainda assim se trata de um "**procedimento destrutivo**" e deve ser encarado como tal. Os comandos que serão aplicados em ambiente remoto estão detalhados nos _dialogs_ de informação e podem ser testados previamente em ambiente local para que o arquiteto da solução tenha ciência plena das consequências.

## 4. Possibilidade de remover completamente a instância (_deploy_) de uma _build_ {#remove}

Agora é possível remover completamente o _deploy_ realizado em um _cluster_. Esta funcionalidade é muito útil para desalocar recursos provisionados por uma aplicação que não será mais utilizada. Por exemplo, aquelas que foram criadas e instanciadas para aprender sobre a própria plataforma **Embrapa I/O**, para testar _features_ de _boilerplates_ ou outras iniciativas lúdicas.

> **Atenção!** O procedimento irá remover todos os containers, a _network_ da _stack_, imagens geradas (pelo processo de _build_), seus volumes de dados (implícitos e explícitos), configurações e metadados.

Reparem que se trata de uma **ação irreversível**. Ou seja, mesmo que faça um novo _deploy_ desta _build_ no mesmo _cluster_, todos os dados armazenados nas imagens e volumes <u>não serão recuperados</u>. Portanto, no caso de um novo _deploy_ desta aplicação neste estágio, a mesma estará limpa ("zerada"), apenas com os dados padrão da imagem. Dados históricos, tal como os valores de variáveis de ambiente, também serão perdidos. **Certifique-se das consequências e tome precauções (tal como salvar dados importantes) antes de realizar esta ação!**

> **Atenção!** É importante frisar que não é possível **efetuar _backup_ após a remoção!** Assim, é fortemente recomendado [efetuar _backup_ da instância da _build_]({{ site.baseurl }}/docs/backup/) antes de executar esta ação.

O processo pode ser iniciado de duas maneiras. Se a instância ainda estiver "no ar", utilize a opção de menu no painel de _health check_ da _build_. Senão, caso esteja "inativa", utilize o _dialog_ de revalidação de _build_:

![Acessando a funcionalidade de remover a build]({{ site.baseurl }}/assets/img/posts/20250424085548.png)

Um novo _dialog_ será mostrado com um longo _disclaimer_. Você deverá declarar ciência e executar o processo de validação via envio de PIN:

![Removendo a instância da build]({{ site.baseurl }}/assets/img/posts/20250424091155.png)

Após ser removida, a _build_ irá voltar para o _status_ de rascunho (**DRAFT**):

![Instâncias de builds removidas e status retornado para DRAFT]({{ site.baseurl }}/assets/img/posts/20250424125634.png)

Com isso, será possível configurar novamente e fazer o _deploy_ desta mesma _build_ em um _cluster_ diferente do catálogo.

> **Atenção!** Lembre-se que, se já existirem **_tags_ de versões** criadas no [GitLab](https://git.embrapa.io), elas <u>não serão apagadas no processo de remoção</u>. Portanto, ao configurar e validar a _build_ em um novo _cluster_, automaticamente será disparado o processo de _deploy_ para a _tag_ mais recente do estágio da _build_. Se quiser evitar isso, acesse a página de gestão de _tags_ do repositório no GitLab e apague também as _tags_ correspondentes ao estágio da _build_, após finalizar o processo de remoção e antes de configurar a _build_ em um novo _cluster_.

Recomenda-se fortemente o uso desta nova funcionalidade para desprovisionar recursos da infraestrutura em nuvem dos _data centers_ da Embrapa. Para que o **Embrapa I/O** continue disponibilizando recursos de hardware sem burocracia e amarras, é essencial o uso consciente. Assim, caso tenha instâncias de aplicações de teste ou de treino que não utilize mais, por favor, remova-as dos _clusters_ se possível.

## 5. Melhorias de segurança na integração de _clusters_ {#ssh}

Por fim, houve melhorias significativas na integração de _clusters_ ao ecossistema da plataforma **Embrapa I/O**. Agora é possível [criar um usuário exclusivo]({{ site.baseurl }}/docs/cluster/#ssh), com permissões restritas, para ativar os _pipelines_ de _deploy_.

Além disso, para evitar conflitos de rotas com outros _hosts_ na rede do _data center_ que abriga a(s) máquina(s) do _cluster_, é possível especificar agora em qual _subnet_ interna (faixa de IPs) o orquestrador irá alocar as redes das _stacks_ de containers. Os detalhes destas configurações estão na [documentação de configuração de _clusters_]({{ site.baseurl }}/docs/cluster).
