---
layout: page
title: Sentinela
subtitle: Relatórios automáticos de segurança, estabilidade, desempenho, qualidade e uso por projeto
---

A **Sentinela** é o agente de _insights_ da plataforma **Embrapa I/O**: a cada dia ou semana, ela lê o que as ferramentas integradas já registram sobre as aplicações de um [projeto]({{ site.baseurl }}/docs/project) (_logs_, erros, vulnerabilidades, qualidade do código, atividade no repositório e acessos) e envia à equipe, por e-mail, um relatório com o que mudou e o que continua em aberto. Uma cópia em Markdown fica no repositório `io-doc` do projeto, em `06-Support/Sentinela/`.

<div class="alert alert-info" role="alert">
Esta página está reservada: a Sentinela está em fase piloto e a documentação completa (ativação no <em>card</em> do projeto, provedores de IA aceitos, termo de ciência, o que entra e o que nunca entra no relatório) será publicada aqui quando a funcionalidade for liberada para todos os projetos.
</div>

Enquanto isso, três compromissos já valem para os pilotos:

- **Nenhuma ação é executada automaticamente.** A Sentinela só lê e relata; correções são sugeridas à equipe, que decide o que fazer.
- **Segredos e dados pessoais não chegam ao provedor de IA.** Senhas, chaves e _tokens_ são removidos, e endereços IP e e-mails são substituídos por pseudônimos antes da análise; o relatório final é reidratado só para a equipe.
- **O relatório não avalia pessoas.** Nenhum achado nomeia autor de _commit_ nem mede produtividade individual, em conformidade com a Nota Técnica 10/2026-GCI/GTI/SDAD sobre uso de IA generativa na Embrapa.
