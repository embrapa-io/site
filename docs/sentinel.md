---
layout: page
title: Sentinela
subtitle: Relatórios automáticos de segurança, estabilidade, desempenho, qualidade e uso por projeto
---

A **Sentinela** é o agente de _insights_ da plataforma **Embrapa I/O**: a cada dia ou semana, ela lê o que as ferramentas integradas já registram sobre as aplicações de um [projeto]({{ site.baseurl }}/docs/project) (_logs_, erros, vulnerabilidades, qualidade do código, atividade no repositório e acessos) e envia à equipe, por e-mail, um relatório com o que mudou e o que continua em aberto. Uma cópia em Markdown fica no repositório `io-doc` do projeto, em `06-Support/Sentinel/`.

## Como ativar {#enable}

No [_dashboard_ da plataforma]({{ site.baseurl }}/docs/dashboard), cada projeto tem o botão da Sentinela (ícone de brilho, ao lado do acesso ao Git). A ativação cabe a um **arquiteto de solução** do projeto, em três passos:

1. **Termo de ciência.** Resume o que é enviado ao modelo de IA, o que a plataforma remove antes (segredos) e pseudonimiza (endereços IP e e-mails), e as regras da Nota Técnica 10/2026-GCI/GTI/SDAD sobre IA generativa. A chave de API fica vinculada a quem aceita o termo.
2. **Provedor.** Duas opções. **GPU Server da Embrapa**: um modelo aberto rodando na GTI, equiparado a solução homologada; nenhum dado sai da Embrapa, não exige chave e não tem custo. **Provedor externo** (Anthropic, OpenAI, Google ou qualquer API compatível com a da OpenAI, como OpenRouter): exige a sua chave, validada na hora, e a declaração de que os dados do projeto são **públicos e não sensíveis**, porque é uma ferramenta não homologada.
3. **Ajustes.** Frequência (semanal, ou diária com e-mail só quando há novidade), destinatários (toda a equipe ou só os arquitetos) e se a cópia em Markdown vai para o `io-doc`.

Depois de salvar, **Executar agora** gera o primeiro relatório em alguns minutos, e pode ser usado sempre que a equipe quiser conferir o efeito de uma correção. O histórico fica no mesmo diálogo, aberto a toda a equipe.

## O que o relatório traz {#report}

- **Indicadores** e **panorama**: novidades por app e severidade, visitas por dia (Matomo) e vulnerabilidades altas e críticas nas imagens em execução (Trivy), com a proporção que já tem correção.
- **Insights por app**: de uma a três caixas com o que mais vale a atenção da equipe, por tipo (segurança, varredura ou ataque, dependências, erro recorrente, estabilidade, integração, desempenho, qualidade, distribuição, uso).
- **Achados**, agrupados por categoria, com evidência, ação sugerida, link para a ferramenta de origem e os votos **útil** e **ruído**. Um achado marcado como ruído não volta.
- **Projeto inteiro**: o que se repete em várias apps do mesmo _boilerplate_ aparece uma vez só, com a ação que resolve para todas.
- **Pendências**: o que foi reportado antes e segue sem ação.
- **Resumo do período** por app: deploy, código, logs, erros, CVEs, qualidade (notas do SonarQube e linguagens) e uso.

## Compromissos {#rules}

- **Nenhuma ação é executada automaticamente.** A Sentinela só lê e relata; correções são sugeridas à equipe, que decide o que fazer.
- **Segredos e dados pessoais não chegam ao provedor de IA.** Senhas, chaves e _tokens_ são removidos, e endereços IP e e-mails são substituídos por pseudônimos antes da análise; o relatório final é reidratado só para a equipe.
- **O relatório não avalia pessoas.** Nenhum achado nomeia autor de _commit_ nem mede produtividade individual.
- **O conteúdo é gerado por IA**, pode conter erros e exige revisão humana. O rodapé de cada relatório informa o provedor, o modelo, os tokens e o custo estimado.
- **A chave é de quem configura.** Cifrada, nunca exibida de novo, apagada se a pessoa deixa de ser arquiteta do projeto ou quando o projeto é arquivado. Outro arquiteto pode sobrescrevê-la.
