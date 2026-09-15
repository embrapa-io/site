---
layout: page
title: Clusters
subtitle: Catálogo de clusters disponíveis na plataforma
---

Um [_cluster_]({{ site.baseurl }}/docs/introduction#cluster) é o conjunto de máquinas (virtuais ou físicas), sob gestão de uma Unidade da Embrapa ou de um parceiro, onde as [_builds_]({{ site.baseurl }}/docs/build) das aplicações são instanciadas. Cada _cluster_ é configurado por estágio (_alpha_, _beta_ e _release_) e anuncia à plataforma os recursos que oferece. Unidades e parceiros podem [configurar e disponibilizar novos _clusters_]({{ site.baseurl }}/docs/cluster).

A lista abaixo é montada no momento do acesso a partir do catálogo oficial da plataforma. Expanda um _cluster_ para ver onde ele está, o orquestrador, os _aliases_ de domínio, os recursos disponíveis e os [GPU Servers]({{ site.baseurl }}/resources/gpus) que ele enxerga. Dados de rede, credenciais e contatos não são publicados aqui: eles aparecem na [_dashboard_](https://dashboard.embrapa.io), no momento de [configurar a _build_]({{ site.baseurl }}/docs/build#cluster).

{% include catalog.html type="clusters" %}
