---
layout: post
title: Status Page e Stack de Observabilidade
subtitle: Lançamento da página pública de status dos serviços.
tags: [ devops, infraestrutura, observabilidade ]
---

A plataforma **Embrapa I/O** passa a contar com uma **página pública de status** além de ter sido aprimorada sua **stack centralizada de observabilidade**, trazendo transparência sobre a disponibilidade dos serviços e visibilidade completa sobre a infraestrutura dos recursos no _data center_.

## Status Page

A nova **Status Page** está disponível em:

**[https://status.embrapa.io](https://status.embrapa.io)**

Construída com o [Gatus](https://gatus.io), a página monitora continuamente todos os serviços, _hosts_ e _clusters_ da plataforma e exibe o estado atual e o histórico de disponibilidade (_uptime_) em uma interface pública:

![Página de status do Embrapa I/O - status.embrapa.io]({{ site.baseurl }}/assets/img/posts/20260413084310.png)

### O que é monitorado

O monitoramento está organizado em três grupos:

#### Serviços

Verificações HTTP a cada 60 segundos para todos os serviços da plataforma, incluindo:

- **Core API**, **Dashboard**, **Manager** e **Portal** — serviços centrais da plataforma
- **GitLab**, **Matomo**, **Sentry** e **SonarQube** — ferramentas de apoio ao desenvolvimento
- **Grafana**, **ThingsBoard** e **N8N** — painéis e automação
- **MCP Servers** (Principal, Logs e Git) — integração com assistentes de IA
- **Documentação**, **API Gateway** e **Backup** — serviços de suporte
- **Arena Hub** e **Arena Testes** — ambientes do projeto Arena
- **Portainer** — painéis de gestão de containers em cada _cluster_

Cada _endpoint_ é verificado quanto ao código de resposta HTTP (200) e tempo de resposta (< 5s).

#### Hosts

Monitoramento de **acessibilidade** das máquinas virtuais do _data center_ (`*.embrapa.io`), consultando métricas do Prometheus via PromQL. O _check_ é considerado saudável quando o _host_ está **enviando métricas** via Grafana Alloy — ou seja, está acessível e operacional. Alertas de uso de disco e outros recursos são tratados separadamente via Grafana (e-mail).

#### Clusters

O mesmo monitoramento de acessibilidade é aplicado aos servidores da rede de _clusters_ (`*.agro.rocks`), garantindo visibilidade sobre quais nós de _deploy_ estão operacionais.

Os dados são persistidos, preservando o histórico de disponibilidade entre reinicializações do serviço.

## Stack de Observabilidade

A Status Page faz parte de uma **stack centralizada de observabilidade** que agrega logs e métricas de toda a infraestrutura. Os componentes são:

### Grafana — Painel unificado

O [Grafana](https://grafana.com) é o painel centralizado de visualização, acessível em [https://log.embrapa.io](https://log.embrapa.io). Nele, a equipe de operações pode explorar logs, consultar métricas de infraestrutura e configurar alertas com notificação por e-mail.

### Loki — Agregação de logs

O [Grafana Loki](https://grafana.com/oss/loki/) recebe e indexa logs de duas fontes:

1. **Grafana Alloy** — Logs do _systemd journal_ e de `/var/log` de cada _host_
2. **Docker Loki Driver** — Logs de containers enviados diretamente pelo _daemon_ do Docker

Os logs são acessíveis pelo Grafana e também via [MCP Server de Logs]({{ site.baseurl }}/docs/mcp/#loki), permitindo consultas por assistentes de IA.

### Prometheus — Métricas de infraestrutura

O [Prometheus](https://prometheus.io) opera como **receptor de métricas**. Recebe métricas de CPU, memória, disco e rede de todos os _hosts_, coletadas pelo Grafana Alloy.

Essas métricas alimentam os _dashboards_ do Grafana e também as verificações de disco da Status Page (via consultas PromQL internas).

### Grafana Alloy — Agente nos _hosts_

O [Grafana Alloy](https://grafana.com/docs/alloy/latest/) é instalado em **cada máquina virtual** do _data center_ como agente de coleta. Com uma configuração única e idêntica para todos os _hosts_, ele:

- **Coleta logs** do _systemd journal_ (últimas 12h no _startup_) e de `/var/log/*.log`, enviando ao Loki
- **Coleta métricas** de CPU, memória, disco, _filesystem_ e rede via `prometheus.exporter.unix`, enviando ao Prometheus
- **Identifica automaticamente** o _hostname_ e IP do _host_, aplicando _labels_ para facilitar a filtragem

### Alertas via Grafana

O sistema de alertas é gerenciado diretamente pelo **Grafana**, com notificações por e-mail (SMTP) configuradas nativamente. Isso permite criar regras de alerta baseadas tanto em métricas do Prometheus (p.e., disco cheio, CPU elevada) quanto em padrões de logs do Loki (p.e., erros recorrentes).

## Saiba mais

- [**Status Page →**](https://status.embrapa.io)
- [**Grafana →**](https://log.embrapa.io)
- [**MCP Server de Logs →**]({{ site.baseurl }}/docs/mcp/#loki)
