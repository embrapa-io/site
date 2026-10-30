---
layout: page
title: MCP do SonarQube
subtitle: Qualidade do código, issues e Quality Gate do code.embrapa.io via linguagem natural
share-title: "MCP do SonarQube | Embrapa I/O"
share-description: "MCP Server do Embrapa I/O para consultar a qualidade do código das aplicações no SonarQube (code.embrapa.io) em linguagem natural: issues, Quality Gate, métricas, duplicações e hotspots de segurança."
permalink: /docs/mcp/code/
---

A [análise estática de código]({{ site.baseurl }}/docs/quality) da plataforma utiliza o **MCP oficial do SonarQube**, o [`SonarSource/sonarqube-mcp-server`](https://github.com/SonarSource/sonarqube-mcp-server), mantido pela própria [SonarSource](https://www.sonarsource.com). Ele conecta assistentes de IA (Claude, Gemini, Copilot, Cursor, etc.) à instância de qualidade de código do **Embrapa I/O** ([code.embrapa.io](https://code.embrapa.io)), permitindo consultar as _issues_ de cada aplicação, o _Quality Gate_, as métricas, as duplicações e os _hotspots_ de segurança, e até analisar um trecho de código antes do _commit_, tudo via linguagem natural.

Assim como o [MCP do Sentry]({{ site.baseurl }}/docs/mcp/bug/), e diferente dos demais MCPs da plataforma (servidores HTTP com _login_ OAuth e URL de conexão), este roda por **transporte `stdio`**: o processo executa **localmente**, na máquina do desenvolvedor, num container Docker, e se conecta ao `code.embrapa.io` com um _token_ pessoal.

## Conectar

Não há URL de conexão (o transporte é `stdio`). O servidor é a imagem Docker oficial **`sonarsource/sonarqube-mcp`**, executada localmente. Pré-requisitos:

- **Docker** instalado e em execução ([Docker Desktop](https://www.docker.com/products/docker-desktop/), [OrbStack](https://orbstack.dev) ou o Docker Engine no Linux);
- um **_token_ de usuário** do SonarQube criado em `code.embrapa.io` (veja abaixo).

Comando base (referência; os clientes abaixo encapsulam isto):

```bash
docker run --init --pull=always -i --rm -e SONARQUBE_TOKEN -e SONARQUBE_URL sonarsource/sonarqube-mcp
```

com as variáveis de ambiente:

- `SONARQUBE_URL=https://code.embrapa.io`, que aponta para a instância da plataforma (sem ela, e com `SONARQUBE_ORG`, o servidor tentaria o SonarQube _Cloud_);
- `SONARQUBE_TOKEN`, o seu _token_ de usuário.

### Criar o _token_

1. Acesse [code.embrapa.io](https://code.embrapa.io) e faça _login_ com a sua conta do [GitLab da plataforma](https://git.embrapa.io);
2. Clique no seu avatar, no canto superior direito, e vá em **My Account → Security**;
3. Em **Generate Tokens**, dê um nome ao _token_ (ex.: `mcp`), escolha o tipo **User Token** e uma validade, e clique em **Generate**;
4. Copie o _token_ gerado (começa com `squ_…`): ele **não** é exibido novamente.

> **Atenção!** Use um _token_ do tipo **User Token**. _Tokens_ de projeto ou globais não funcionam com o servidor MCP. O _token_ herda as permissões da **sua conta**: você só enxerga as aplicações dos projetos dos quais participa na plataforma.

> **Dica!** O `--pull=always` atualiza a imagem a cada início. Para um ambiente estável, troque-o por uma versão fixa da imagem (ex.: `sonarsource/sonarqube-mcp:1.30.0.4763`) e atualize deliberadamente.

## Funcionalidades

O servidor oficial expõe _tools_ para os principais fluxos de qualidade de código:

**Projetos e _branches_**: listagem das aplicações acessíveis (cada aplicação da plataforma é um projeto no SonarQube, com a chave `projeto_app`, p.e. `pasto-certo_api`), das _branches_ e dos _merge requests_ analisados.

**_Issues_**: busca das _issues_ (_bugs_, vulnerabilidades e _code smells_) por aplicação, severidade e arquivo, com a regra violada e a explicação de como corrigir, e mudança de _status_ (aceitar, marcar como falso positivo, reabrir).

**_Quality Gate_**: situação do _Quality Gate_ de cada aplicação (aprovado ou reprovado) e as condições que falharam.

**Métricas**: medidas de cada aplicação ou arquivo, como linhas de código, cobertura, duplicação, dívida técnica e as notas de manutenibilidade, confiabilidade e segurança.

**Duplicações**: arquivos com código duplicado e os trechos repetidos.

**_Hotspots_ de segurança**: busca, detalhamento e revisão dos trechos sensíveis que pedem verificação humana.

**Análise de trecho de código**: análise de um arquivo ou trecho enviado pelo assistente, com as regras do SonarQube, antes mesmo do _commit_.

> **Nota!** A instância da plataforma não importa os relatórios de cobertura de testes do _pipeline_ das aplicações. Por isso, as _tools_ de cobertura (`search_files_by_coverage` e `get_file_coverage_details`) e a métrica de cobertura costumam retornar vazio: não é falha do servidor nem do _token_.

## Exemplos de _Prompts_

Abaixo, exemplos do que pode ser solicitado em linguagem natural a um assistente de IA conectado a este MCP:

```
Liste as minhas aplicações no SonarQube e a situação do Quality Gate de cada uma.
```

```
Por que o Quality Gate da aplicação pasto-certo/api está reprovado?
Mostre as condições que falharam.
```

```
Quais são as vulnerabilidades e os bugs de severidade alta da aplicação
controlpec/api? Para cada um, diga o arquivo, a linha e como corrigir.
```

```
Quais arquivos da aplicação mecaniza/pwa têm mais código duplicado?
```

```
Analise este trecho de código com as regras do SonarQube antes do commit.
```

```
Revise os hotspots de segurança abertos da aplicação fertiliza/backend
e me ajude a decidir quais são seguros.
```

## Configuração no Claude Code

Como o transporte é `stdio`, a configuração informa o **comando** a executar (não uma URL). O **Claude Code** é o cliente de referência na plataforma: comece por ele.

Adicione o servidor com um único comando (`--scope user` o deixa disponível em qualquer projeto):

```bash
claude mcp add sonarqube --scope user \
  --env SONARQUBE_TOKEN=SEU_TOKEN \
  --env SONARQUBE_URL=https://code.embrapa.io \
  -- docker run --init --pull=always -i --rm -e SONARQUBE_TOKEN -e SONARQUBE_URL sonarsource/sonarqube-mcp
```

Confirme a conexão com `claude mcp list` (o `sonarqube` deve aparecer como _connected_) ou digitando `/mcp` dentro do Claude Code. Na primeira execução, o Docker baixa a imagem, o que pode levar alguns segundos.

> **Dica!** Para impedir que o assistente altere o _status_ de _issues_ e _hotspots_, acrescente `--env SONARQUBE_READ_ONLY=true` e `-e SONARQUBE_READ_ONLY` ao comando: o servidor passa a expor só as _tools_ de leitura.

## Outros clientes

De forma acessória, os demais clientes usam o **mesmo servidor `stdio`**. O bloco JSON **canônico** (formato `mcpServers`) é:

```json
{
  "mcpServers": {
    "sonarqube": {
      "command": "docker",
      "args": ["run", "--init", "--pull=always", "-i", "--rm", "-e", "SONARQUBE_TOKEN", "-e", "SONARQUBE_URL",
               "sonarsource/sonarqube-mcp"],
      "env": { "SONARQUBE_TOKEN": "SEU_TOKEN", "SONARQUBE_URL": "https://code.embrapa.io" }
    }
  }
}
```

**Cursor, Windsurf, Antigravity e Claude Desktop** usam exatamente esse bloco: cole-o no arquivo correspondente:

| Cliente | Arquivo de configuração |
|---------|--------------------------|
| Claude Desktop | `claude_desktop_config.json` (via **Customize → Developer → Edit Config**) |
| Cursor | `~/.cursor/mcp.json` |
| Windsurf | `~/.codeium/windsurf/mcp_config.json` |
| Google Antigravity | `~/.gemini/antigravity/mcp_config.json` |

**OpenAI Codex CLI** e **Gemini CLI**, com a mesma lógica do Claude Code:

```bash
# OpenAI Codex CLI
codex mcp add sonarqube --env SONARQUBE_TOKEN=SEU_TOKEN --env SONARQUBE_URL=https://code.embrapa.io \
  -- docker run --init --pull=always -i --rm -e SONARQUBE_TOKEN -e SONARQUBE_URL sonarsource/sonarqube-mcp

# Gemini CLI
gemini mcp add sonarqube -e SONARQUBE_TOKEN=SEU_TOKEN -e SONARQUBE_URL=https://code.embrapa.io \
  -- docker run --init --pull=always -i --rm -e SONARQUBE_TOKEN -e SONARQUBE_URL sonarsource/sonarqube-mcp
```

**VS Code (GitHub Copilot)**: em `.vscode/mcp.json` (por projeto) ou nas _User Settings_, usa a chave `servers` com `type: stdio`:

```json
{
  "servers": {
    "sonarqube": {
      "type": "stdio",
      "command": "docker",
      "args": ["run", "--init", "--pull=always", "-i", "--rm", "-e", "SONARQUBE_TOKEN", "-e", "SONARQUBE_URL",
               "sonarsource/sonarqube-mcp"],
      "env": { "SONARQUBE_TOKEN": "SEU_TOKEN", "SONARQUBE_URL": "https://code.embrapa.io" }
    }
  }
}
```

**GitHub Copilot CLI**: dentro dele, `/mcp add`, com tipo **Local**, comando `docker`, os mesmos argumentos e as duas variáveis de ambiente. A configuração fica em `~/.copilot/mcp-config.json`.

> **Nota!** A partir destes exemplos é possível extrapolar para outros clientes com suporte a MCP `stdio` com poucos ajustes.

## Referência Técnica

A superfície de _tools_ do servidor oficial **evolui entre versões**. Na versão 1.30, conectada ao `code.embrapa.io` (SonarQube Community Build 25.1), são 18 _tools_:

| Domínio | _Tools_ |
|---------|---------|
| Projetos | `search_my_sonarqube_projects`, `list_branches`, `list_pull_requests` |
| _Issues_ e regras | `search_sonar_issues_in_projects`, `change_sonar_issue_status`, `show_rule` |
| _Quality Gate_ | `get_project_quality_gate_status`, `list_quality_gates` |
| Métricas | `get_component_measures`, `search_metrics` |
| Duplicações | `search_duplicated_files`, `get_duplications` |
| _Hotspots_ de segurança | `search_security_hotspots`, `show_security_hotspot`, `change_security_hotspot_status` |
| Cobertura _(sem dados)_ | `search_files_by_coverage`, `get_file_coverage_details`: a plataforma não importa a cobertura dos testes; retornam vazio. |
| Análise | `analyze_code_snippet` |

> **Nota!** O servidor exige o SonarQube Server 2025.1 ou o Community Build 25.1 em diante e confere a versão da instância ao iniciar. Para a referência completa e sempre atualizada das _tools_, parâmetros e variáveis, consulte a documentação oficial (_links_ abaixo).

## Documentação oficial (SonarQube MCP Server)

- [Repositório `SonarSource/sonarqube-mcp-server`](https://github.com/SonarSource/sonarqube-mcp-server)
- [Documentação do SonarQube MCP Server](https://docs.sonarsource.com/sonarqube-mcp-server/)
- [Imagem `sonarsource/sonarqube-mcp` (Docker Hub)](https://hub.docker.com/r/sonarsource/sonarqube-mcp)
- [Gerando e usando _tokens_ (SonarQube Server)](https://docs.sonarsource.com/sonarqube-server/latest/user-guide/managing-tokens/)
