---
layout: page
title: Cluster
subtitle: Configurando e disponibilizando um cluster pela Dashboard
---

<iframe width="730" height="410" src="https://www.youtube.com/embed/nFKy_re10Os" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

> **Catálogo:** a lista dos _clusters_ disponíveis, com os recursos de cada um, está em [Recursos → Clusters]({{ site.baseurl }}/resources/clusters); os servidores de inferência acessíveis a partir deles, em [Recursos → GPU Servers]({{ site.baseurl }}/resources/gpus).

Um _cluster_ do catálogo é um servidor (físico ou, mais comumente, uma máquina virtual) de uma Unidade da Embrapa ou de um parceiro, em que a plataforma publica as aplicações das equipes. Ele é de **uso compartilhado**: várias aplicações dividem a mesma máquina. A plataforma faz cada _deploy_ por SSH, e a Unidade, pelos **mantenedores** do _cluster_, cuida da máquina: sistema operacional, disco, rede, _firewall_ e atualizações.

Desde novembro de 2026, o NTI da Unidade coloca um servidor no catálogo **sozinho, pela Dashboard**, sem depender da equipe da plataforma. O assistente de _clusters_ orienta o planejamento, gera um comando único que instala tudo na máquina (o `cluster.sh`), verifica os pré-requisitos a partir do servidor da plataforma, valida a instalação e, com o termo assinado pelos mantenedores, publica o _cluster_ no catálogo.

> **Atenção!** Os _clusters_ do catálogo são compartilhados e não há como garantir recursos de _hardware_ dedicados a uma aplicação. Para aplicações em **produção** (_release_), a recomendação é uma VM dedicada operada pelo [Releaser]({{ site.baseurl }}/docs/releaser), conforme o capítulo sobre [hospedagem de aplicações]({{ site.baseurl }}/docs/delivery). Se o _cluster_ oferecer o estágio _release_ e uma equipe o usar mesmo assim, ela deve ativar o [_backup_ automático na nuvem (S3)]({{ site.baseurl }}/docs/s3).

O processo anterior, em que a Unidade preparava o servidor à mão e pedia a entrada no catálogo, continua documentado em [Cluster: processo manual]({{ site.baseurl }}/docs/cluster/manual), com o vídeo correspondente. Ele ainda é a referência para o **Docker Swarm**, que o assistente não cobre.

# Planejamento {#planning}

## Finalidade: projetos e laboratórios virtuais {#purpose}

Ao cadastrar o _cluster_, a Unidade diz para que ele serve:

- **Projetos**: recebe as _builds_ das aplicações das equipes, como os _clusters_ que a plataforma sempre teve.
- **Laboratórios**: recebe os **laboratórios virtuais** do [Forge](https://forge.embrapa.io), ferramentas prontas, criadas a partir dos _boilerplates_, para quem trabalha com pesquisa, comunicação ou gestão sem precisar programar.

O mesmo _cluster_ pode servir às duas finalidades. Um _cluster_ **só de laboratórios** aparece na configuração das _builds_ apenas para consulta: a Dashboard avisa que ele é exclusivo dos laboratórios virtuais e não deixa escolhê-lo para o _deploy_ de um projeto. A finalidade pode ser mudada depois, na aba **Dados** do _cluster_.

![Um cluster só de laboratórios na configuração da build: só para consulta]({{ site.baseurl }}/assets/img/cluster/build-lab-only.png)

## A máquina {#install}

<span id="docker"></span>

| Tamanho | vCPU | Memória | Disco de dados |
|---|---|---|---|
| Pequeno | 4 | 16 GB | 200 GB |
| Médio | 8 | 32 GB | 500 GB |
| Laboratórios | 16 | 64 GB | 1 TB |

- **Sistema operacional:** [Ubuntu Server 26.04 LTS](https://ubuntu.com/download/server) (preferencial, a versão que a plataforma usa em todos os seus servidores) ou **Debian 13**, comum nos hipervisores das Unidades.
- **Arquitetura:** <u>obrigatoriamente <b>amd64</b></u>.
- **Instalação mínima**, só com o servidor SSH. **Não instale o Docker** nem outros serviços: o `cluster.sh` instala o Docker do repositório oficial e tudo o mais.
- **IP público próprio** da VM. Uma segunda placa de rede, interna, é opcional.

> **Atenção!** No Ubuntu 26.04, o `sudo` padrão é o [`sudo-rs`](https://github.com/trifectatechfoundation/sudo-rs), que não aceita a regra usada pela plataforma para ajustar as permissões dos volumes. O `cluster.sh` volta ao `sudo` clássico, que já vem instalado, e a validação confere isso.

## O disco de dados em /var/io {#storage}

Os dados das aplicações (bancos de dados e arquivos enviados pelos usuários) ficam em _volumes_ no diretório `/var/io`, em **disco local** (_storer_ `DockerLocal`). A boa prática é que ele seja um **segundo disco**, montado nesse ponto:

- os dados não enchem o disco do sistema;
- o disco de dados pode crescer sem mexer no resto;
- o _snapshot_ e o _backup_ podem tratar os dois discos de forma diferente;
- dá para reinstalar o sistema sem perder os dados.

Não é obrigatório: sem um disco próprio, o `cluster.sh` só avisa, desde que haja espaço livre suficiente no disco do sistema. Com um disco próprio montado em `/var/io`, ele precisa ter pelo menos 200 GB.

> **Atenção!** **Não use NFS** para os _volumes_ de um _cluster_ em Docker Compose: bancos de dados sobre NFS travam quando a rede ou o _storage_ oscila e arrastam junto o serviço do Docker. Os detalhes estão no [processo manual]({{ site.baseurl }}/docs/cluster/manual#install).

## As sub-redes {#subnets}

Cada _build_ (uma aplicação num estágio) ganha uma **rede Docker própria**, e essas redes saem de uma faixa `/16` escolhida para cada estágio no cadastro (por padrão, `172.28.0.0` para o _alpha_, `172.29.0.0` para o _beta_ e `172.30.0.0` para o _release_). O assistente aceita as faixas de `172.16.0.0` a `172.31.0.0`.

- **Nunca** use uma faixa que a rede da Unidade já usa: o servidor perde o caminho até essas máquinas. Combine as faixas livres com o NTI.
- Prefira **uma faixa por estágio**. Estágios podem usar a mesma faixa, mas passam a dividir as mesmas 255 sub-redes, e o IP deixa de dizer de que estágio é a _build_.
- No _data center_ da **Sede**, a única faixa liberada é a `172.30.0.0`.

### Capacidade do _cluster_ {#capacity}

Com a faixa do estágio, a plataforma atribui a cada _build_ uma sub-rede `/24` dentro dela (`172.28.1.0/24`, `172.28.2.0/24` e assim por diante). Assim, o _cluster_ comporta:

- até **255 _builds_ por estágio** (estágios com faixas diferentes somam as suas capacidades);
- até cerca de **253 containers por _build_**; e
- **16.348 portas** (de 49152 a 65499) divididas entre todas as _builds_ do _cluster_. As portas a partir da 65500 ficam reservadas a serviços da plataforma no próprio servidor, como o [_Web Terminal_](#terminal).

Na prática, o que limita um _cluster_ é o _hardware_ muito antes das redes ou das portas. Acompanhe o consumo na aba **Saúde** do _cluster_ e, se ele estiver perto do limite, desligue as novas implantações do estágio na aba **Dados**.

## Firewall e DNS {#ports}

| Porta | Origem | Para quê |
|---|---|---|
| 22/TCP | só o `core.embrapa.io` (`200.202.148.38`) | _deploy_ e validação, por SSH |
| 80 e 443/TCP | internet | certificado do Let's Encrypt e painel local |
| 49152 a 65535 (TCP e UDP) | o _core_ (obrigatório) e a internet (opcional) | acesso às aplicações |
| 65500/TCP | rede da Embrapa | _Web Terminal_ |

A máquina também precisa de saída para a internet em HTTP/HTTPS (repositórios do sistema, do Docker e do Grafana, Docker Hub, `loki.embrapa.io` e `prometheus.embrapa.io`) e NTP. A verificação prévia do `cluster.sh` confere cada uma.

> **Atenção!** A faixa alta é por onde o roteador da plataforma chega às aplicações. Abri-la também para a internet permite publicar protocolos que não são HTTP (MQTT, CoAP, LoRaWAN, NTRIP…), acessados direto em `host:porta`; prefira sempre a versão com criptografia (MQTTS, CoAPS). Veja a tabela de protocolos no [processo manual]({{ site.baseurl }}/docs/cluster/manual#ports).

No DNS da Unidade, são dois registros (o curinga pode ser um CNAME para um nome que aponte para o _core_):

```
Nome                       Tipo   Valor
-----------------------    ----   ----------------------
io.cnpxx.embrapa.br        A      <IP público da VM>
*.io.cnpxx.embrapa.br      A      200.202.148.38
```

O nome do _cluster_ aponta para a máquina; o curinga aponta para o _core_, que recebe os acessos às aplicações (como `app.io.cnpxx.embrapa.br`) e os encaminha ao _cluster_. O nome segue um padrão: `io.` mais o **subdomínio da Unidade**. Cada Unidade já tem o seu subdomínio de terceiro nível definido (como `cnpgc.embrapa.br`) e só cria nomes dentro dele; por isso, o _cluster_ da Embrapa Gado de Corte é `io.cnpgc.embrapa.br`. Para um segundo _cluster_, `io2.` ou `lab.` no lugar do `io.` (como `lab.cnpgc.embrapa.br`).

## O token do Docker Hub {#dockerhub}

As imagens das aplicações vêm do Docker Hub, que limita os _downloads_ anônimos. Por isso, a instalação faz o _login_ numa conta do NTI com um **_token_ de acesso somente leitura**: no Docker Hub, abra **Account settings → Personal access tokens → Generate new token**, dê uma descrição que lembre o _cluster_ e escolha a permissão **Public Repo Read-only**. O _token_ é digitado no terminal da própria máquina e fica só nela: não passa pela plataforma.

![Criação do token somente leitura no Docker Hub]({{ site.baseurl }}/assets/img/cluster/dockerhub-token.png)

# Cadastro e instalação {#wizard}

## O cadastro na Dashboard

Na Dashboard, o botão **Clusters** (para empregados da Embrapa) lista os _clusters_ do catálogo, com estágios, finalidade e saúde, e os pedidos em andamento. O botão **+ Cluster** abre o cadastro em quatro passos:

![Cadastro do cluster: identificação]({{ site.baseurl }}/assets/img/cluster/wizard-identification.png)

1. **Identificação:** Unidade (em branco para universidades e parceiros), instituição, localização, nome do _cluster_, estágios oferecidos, uso (projetos e/ou laboratórios) e a sub-rede de cada estágio.
2. **Mantenedores e SMTP:** os e-mails institucionais das pessoas que cuidam do servidor e recebem os avisos de saúde e de vulnerabilidades (recomendamos dois ou mais) e, se houver, o servidor de e-mail da Unidade que aceita envios a partir do _cluster_ (_relay_ sem autenticação), oferecido às aplicações nas variáveis `${IO_SMTP_*}`.

   ![Cadastro do cluster: mantenedores e SMTP]({{ site.baseurl }}/assets/img/cluster/wizard-maintainers.png)

3. **Requisitos:** o tamanho da máquina e, prontos para copiar e mandar ao NTI, o sistema, o disco, a rede, a descrição para o inventário, a tabela do _firewall_, os registros de DNS e a orientação do Docker Hub. Aqui também se informa se a Unidade faz _snapshot_ da VM no hipervisor.

   ![Cadastro do cluster: requisitos]({{ site.baseurl }}/assets/img/cluster/wizard-requirements.png)

4. **Comando:** o pedido é criado e a Dashboard mostra o comando, com um _token_ de uso único válido por duas horas:

```bash
curl -fsSL https://embrapa.io/cluster.sh -o /root/cluster.sh
sha256sum /root/cluster.sh   # esperado: <o valor mostrado na Dashboard>
sh /root/cluster.sh setup <token>
```

Se o _token_ expirar antes da instalação, o botão **Gerar novo token** cria outro.

![O comando de instalação, com o token de uso único]({{ site.baseurl }}/assets/img/cluster/wizard-command.png)

## A linha do tempo {#timeline}

O comando roda na máquina, **como root**, e a linha do tempo da Dashboard acompanha cada etapa, com as evidências e, em caso de falha, o motivo e o que fazer:

![O cluster.sh no terminal e a linha do tempo na Dashboard, na verificação prévia]({{ site.baseurl }}/assets/img/cluster/wizard-preflight.png)


1. **Cadastro**: os dados do pedido.
2. **DNS**: o servidor da plataforma confere, de fora, o nome do _cluster_ e o curinga.
3. **Rede**: o servidor da plataforma alcança a máquina nas portas 22, 80 e na faixa alta.
4. **Verificação prévia**: o `cluster.sh` confere, sem alterar nada, o sistema, a arquitetura, o processador, a memória, o disco em `/var/io`, as portas, as sub-redes, o relógio e as saídas para a internet.
5. **Docker Hub**: o _login_ com o _token_ somente leitura.
6. **Confirmação**: com tudo verificado, o script **espera** um mantenedor clicar em **Confirmar instalação** na Dashboard. Nada é instalado sem essa confirmação.
7. **Instalação**: sistema (pacotes, nome da máquina, parâmetros do _kernel_, `sudo` clássico), Docker do repositório oficial, usuário `io` (grupo `docker`, `/var/io`, regra do `sudoers` e a chave da plataforma, restrita ao IP do _core_), _driver_ de _log_ do Loki, Grafana Alloy (logs e métricas para o [Grafana da plataforma](https://log.embrapa.io)), Docker Hub, certificado do Let's Encrypt, _Web Terminal_, painel local, CRON e ajustes, e a limpeza (o _token_ deixa de valer).
8. **Validação a partir do core**: o servidor da plataforma entra na máquina como o usuário `io`, como num _deploy_, e confere o SSH com a chave da plataforma, o Docker e o Compose, o _driver_ de _log_, o `sudo` clássico, as permissões em `/var/io`, a reserva das portas e o Alloy. Por último, sobe um contêiner de teste na faixa alta e o acessa de fora, pelo mesmo caminho das aplicações.

   ![A validação a partir do core, com as evidências]({{ site.baseurl }}/assets/img/cluster/wizard-validation.png)

9. **Termo do mantenedor**: os mantenedores leem e assinam o termo (abaixo).
10. **Disponível no catálogo**: o _cluster_ entra no catálogo, sem esperar ninguém, e passa a aparecer para as equipes na configuração das _builds_.

![A instalação concluída: o terminal e a linha do tempo, à espera do termo]({{ site.baseurl }}/assets/img/cluster/wizard-installed.png)

O termo do mantenedor do _cluster_ diz que a Unidade, representada pelos mantenedores cadastrados:

1. mantém o servidor (sistema operacional, Docker, disco, rede, _firewall_ e _snapshot_) e aplica as atualizações de segurança;
2. mantém os registros DNS do _cluster_ e avisa a equipe da plataforma antes de mudá-los;
3. não altera fora da plataforma o usuário `io`, a chave da plataforma, o `daemon.json` nem os _volumes_ em `/var/io`;
4. atende aos avisos de saúde e de CVE do _cluster_;
5. mantém o S3 da Unidade, quando houver, e guarda a senha raiz num cofre próprio;
6. sem S3, declara ciência de que os _backups_ dos projetos ficam sem cópia fora do servidor e de que faz o _backup_ por outro meio;
7. avisa com antecedência o desligamento do _cluster_, para a migração das _builds_.

![O termo do mantenedor do cluster]({{ site.baseurl }}/assets/img/cluster/wizard-term.png)

No catálogo, o _cluster_ aparece para as equipes no seletor da configuração da _build_, com a finalidade e a saúde do servidor:

![O cluster novo escolhido na configuração da build]({{ site.baseurl }}/assets/img/cluster/build-cluster-selected.png)

### Integração por SSH {#ssh}

<span id="sudoers"></span>

O `cluster.sh` cria o usuário `io`, coloca-o no grupo `docker`, dá a ele, pelo `sudoers`, a permissão de ajustar dono e permissões das subpastas de `/var/io`, e autoriza a [chave pública da plataforma]({{ site.baseurl }}/docs/cluster/manual#ssh) **só a partir do IP do _core_**. A porta do SSH deve continuar a 22.

### Logs e métricas {#loki}

O _driver_ de _log_ do Docker manda a saída de todos os containers ao Loki da plataforma, e o Grafana Alloy manda o _journal_, os arquivos de `/var/log` e as métricas da máquina (processador, memória, disco). São esses dados que alimentam a aba **Saúde** do _cluster_, os alertas e o [Grafana](https://log.embrapa.io).

# Manutenção {#maintenance}

## O painel local {#panel}

<span id="portainer"></span>

No fim da instalação, o terminal mostra o endereço do painel local, o [Arcane](https://getarcane.app), em `https://<cluster>`, com o usuário (o e-mail de quem cadastrou o _cluster_) e uma senha forte, gerada na hora. Uma cópia fica em `/root/embrapa-io-panel.txt`, legível só pelo root. Pelo painel, os mantenedores veem os contêineres, os _volumes_, as imagens e o consumo do servidor no navegador. Ele se atualiza sozinho toda noite (`/etc/cron.d/embrapa-io-panel`) e volta à versão anterior se a nova não ficar saudável.

## O Web Terminal {#terminal}

O [_Web Terminal_](https://hub.docker.com/r/embrapa/terminal) permite que [membros do projeto com o papel de **Arquitetos da Solução**]({{ site.baseurl }}/docs/squads/#architect) abram o _shell_ dos containers das suas aplicações pela Dashboard. O `cluster.sh` o instala com o `terminal.sh`, que grava um CRON diário (`/etc/cron.d/embrapa-terminal`), mantém o terminal atualizado e volta à versão anterior se a nova falhar. Ele passa a funcionar quando o _cluster_ entra no catálogo. Para conferir, acesse `https://<cluster>:65500/health`.

## Conferir e corrigir: status e repair {#repair}

Tudo o que foi instalado veio do `cluster.sh`, versionado na plataforma, que pode ser rodado de novo a qualquer momento. Por isso, o NTI **não precisa guardar cópias das configurações** que ele gera: uma edição feita à mão seria desfeita na próxima execução.

```bash
sh /root/cluster.sh status   # confere a máquina, item a item, sem alterar nada
sh /root/cluster.sh repair   # reaplica os ajustes: sysctl, sudo, usuário io, CRONs, Alloy e nginx
```

Para usar a versão mais recente do script, baixe-o de novo antes (`curl -fsSL https://embrapa.io/cluster.sh -o /root/cluster.sh`).

> **Atenção!** **Não deixe outra ferramenta de gestão de configuração** (Ansible, Puppet, cópias de um repositório SVN ou Git do NTI etc.) mexer no que o `cluster.sh` instala: `/etc/alloy`, `/etc/nginx`, `/etc/docker/daemon.json`, `/etc/sudoers.d/io`, o usuário `io` e os CRONs `embrapa-*`. Em novembro de 2026, a sincronização automática de configurações de uma Unidade trocou o Alloy e o nginx de um _cluster_ recém-instalado, que parou de mandar _logs_ e métricas à plataforma. O `repair` refaz esses arquivos, mas a ferramenta precisa deixar o servidor de fora.

## Ajustes pela aba Dados {#catalog}

Depois de publicado, o _cluster_ continua nas mãos dos mantenedores (e dos administradores da plataforma), pela aba **Dados** do _cluster_ na Dashboard, sem pedir a ninguém:

![A aba Dados do cluster]({{ site.baseurl }}/assets/img/cluster/cluster-data-tab.png)


- **Instituição e localização** e o **_snapshot_ da VM**;
- **Sub-redes**: a troca só é aceita num estágio sem _builds_ implantadas;
- **Novas implantações**: desligar um estágio faz com que ele não receba _builds_ novas, mas as que já estão no _cluster_ continuam sendo geridas normalmente (inclusive recebendo _deploys_ de novas _tags_);
- **+ estágio**: libera um estágio novo, com a sua sub-rede (confirme a faixa com o NTI antes);
- **Finalidade**: projetos e/ou laboratórios. Desligar não afeta o que já está no _cluster_; só deixa de ser ofertado;
- **Mantenedores**: incluir e remover (o _cluster_ precisa de pelo menos um);
- **SMTP**: servidor, porta, TLS e remetente.

Antes de entrar no catálogo, o pedido pode ser apagado em **Desistir do pedido**: o _token_ deixa de valer e o nome fica livre; o que o script já instalou na máquina fica com a Unidade.

O catálogo é guardado pela plataforma e espelhado no arquivo `clusters.json` do repositório `io/boilerplate/metadata`, no formato descrito no [processo manual]({{ site.baseurl }}/docs/cluster/manual#catalog).

## Backup e snapshot {#backup}

O _backup_ das aplicações é feito por projeto, sob demanda ou automático, como descrito nos capítulos de [_backup_]({{ site.baseurl }}/docs/backup) e do [S3]({{ site.baseurl }}/docs/s3). O _snapshot_ da VM no hipervisor, quando a Unidade o faz, protege o _cluster_ inteiro num problema crítico, e é informado no cadastro. O `cluster.sh` grava também uma limpeza diária do _cache_ de _build_ e das imagens sem uso há mais de 24 horas.

## Docker Swarm e registry {#swarm}

O assistente instala _clusters_ em **Docker Compose**, com um único servidor. Para o [Docker Swarm](https://docs.docker.com/engine/swarm/), indicado para grande volume de acesso ou alta disponibilidade, com várias máquinas e uma arquitetura de aplicação própria, e para um _Distribution Registry_ local<span id="registry"></span>, siga o [processo manual]({{ site.baseurl }}/docs/cluster/manual#swarm) e fale com a equipe da plataforma.
