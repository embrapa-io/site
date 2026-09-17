---
layout: page
title: Repositórios de Suporte
subtitle: Publicando a documentação do projeto e da API
---

## Visão geral {#overview}

Além dos repositórios das aplicações, todo projeto na plataforma **Embrapa I/O** pode ativar dois **repositórios de suporte** voltados à documentação pública, [como apresentado na criação do projeto]({{ site.baseurl }}/docs/project#support):

- **`io-web`** — o **site de documentação** do projeto, um site estático em [Jekyll](https://jekyllrb.com) com o tema [Just the Docs](https://just-the-docs.com), publicado em `https://docs.embrapa.io/<projeto>/`; e
- **`io-api`** — a **documentação da API REST**, um arquivo `api.json` no padrão [OpenAPI 3](https://spec.openapis.org/oas/v3.0.3) renderizado com o [Swagger UI](https://swagger.io/tools/swagger-ui/), publicado em `https://api.embrapa.io/<projeto>/`.

Os dois são ativados na _dashboard_, pelo _card_ do projeto, na opção de repositórios de suporte. Cada um nasce como um _fork_ de um _boilerplate_ da plataforma (`io/support/web` e `io/support/api`) criado pelo autômato _Genesis_ no grupo do projeto no [GitLab](https://git.embrapa.io). O fluxo de trabalho é o mesmo para ambos: clonar, editar, testar em ambiente local com Docker e fazer _push_ na _branch_ `main`. Não há _pipeline_ para configurar nem servidor para administrar — [a publicação é automática](#publishing).

> **Atenção!** Tudo o que estiver na `main` desses repositórios é **público**. Não versione credenciais, endereços internos ou dados pessoais. Documentação privada do projeto pertence ao repositório `io-doc`, [descrito no capítulo de projeto]({{ site.baseurl }}/docs/project#doc).

Manter essa documentação atualizada é uma das [orientações da plataforma]({{ site.baseurl }}/docs/guidelines#docs) para a sustentação dos ativos digitais.

## Site de documentação (Jekyll) {#web}

### Ativando e clonando

Ative o repositório `io-web` no _card_ do projeto e aguarde alguns minutos até que o _Genesis_ o crie no GitLab. Em seguida, clone-o:

```bash
git clone git@git.embrapa.io:<projeto>/io-web.git
cd io-web
```

Os _placeholders_ `%GENESIS_*%` do _boilerplate_ (nome do projeto, identificador _unix_, ano) já vêm substituídos no _fork_ — não é preciso mexer neles.

### Estrutura do repositório

| Caminho | Papel |
|---|---|
| `_config.yml` | Título, descrição, rodapé, _callouts_ e demais opções do tema. |
| `index.md` | Página inicial do site. |
| `docs/index.md` | Raiz da seção "Documentação" (`has_children: true`). |
| `docs/*.md` | Um arquivo por página, com `title`, `nav_order` e `parent` no _front matter_. |
| `_includes/head_custom.html` | Integração com o **Matomo** e carga do WebMCP. Raramente precisa ser editado. |
| `images/` | Imagens referenciadas pelas páginas. |
| `Gemfile` | Dependências Ruby usadas no _build_. |

> **Atenção!** Não defina `url` nem `baseurl` no `_config.yml`. A plataforma injeta os dois valores no momento do _build_, de acordo com o endereço em que o site é publicado. Defini-los à mão quebra os _links_ e os _assets_ do site publicado.

### Escrevendo páginas

Crie um arquivo em `docs/` com o _front matter_ do Just the Docs:

```yaml
---
layout: default
title: Instalação
parent: Documentação
nav_order: 3
---
```

O conteúdo é Markdown processado pelo [Kramdown](https://kramdown.gettalong.org). O tema traz busca automática em todo o conteúdo, alternância entre tema claro e escuro, âncoras nos títulos e três _callouts_ prontos, aplicados com um atributo logo após o parágrafo:

```markdown
Este recurso está em fase de testes.
{: .note }

Faça _backup_ antes de executar o comando.
{: .warning }

A variável precisa ser definida antes do primeiro _deploy_.
{: .important }
```

Diagramas em [Mermaid](https://mermaid.js.org) funcionam em blocos de código com a linguagem `mermaid`. Se uma página precisar de mais níveis, use `has_children: true` nela e aponte as filhas com `parent`.

O site também expõe, sem configuração adicional, um conjunto de ferramentas **WebMCP** para agentes de IA que navegam pela documentação — o mesmo mecanismo [descrito no capítulo de WebMCP]({{ site.baseurl }}/docs/webmcp) deste site.

### Testando em ambiente local

O `README.md` do repositório traz um `docker-compose.yml` com a imagem oficial `jekyll/jekyll:4`. Sem o Compose, o comando equivalente é:

```bash
docker run --rm --name <projeto>_web -p 4000:4000 \
  -v "$(pwd):/srv/jekyll" jekyll/jekyll:4 \
  jekyll serve --host 0.0.0.0 --force_polling
```

Acesse `http://localhost:4000`. O `--force_polling` faz o servidor recompilar a cada arquivo salvo. Nada é instalado na sua máquina: Ruby, Bundler e as _gems_ vivem dentro do contêiner.

### Publicando

Faça _commit_ e _push_ na `main`. Em poucos minutos o site é reconstruído e publicado em `https://docs.embrapa.io/<projeto>/`, e passa a aparecer no catálogo de [docs.embrapa.io](https://docs.embrapa.io) assim que o repositório tiver _commits_ próprios além do _fork_ inicial.

### Erros comuns

- **Página não aparece no menu:** falta `parent` ou `nav_order` no _front matter_, ou o `title` do pai não coincide exatamente.
- **Build quebra com _gem_ ausente (`csv`, `logger`, `base64`, `bigdecimal`):** o Ruby moderno deixou de embutir essas bibliotecas. Mantenha-as declaradas no `Gemfile`, como vêm no _boilerplate_; não as remova.
- **`Gemfile.lock` gerado na sua máquina:** não o versione. Ele é gerado dentro do contêiner e um _lock_ produzido com outro Bundler pode derrubar o _build_ publicado.
- **_Links_ quebrados só em produção:** quase sempre é `url`/`baseurl` definidos no `_config.yml` ou caminhos absolutos começando por `/`. Use `{% raw %}{{ site.baseurl }}{% endraw %}/caminho` nos _links_ internos.

## Documentação da API (Swagger) {#api}

### Ativando e clonando

Ative o repositório `io-api` no _card_ do projeto, [como descrito na criação do projeto]({{ site.baseurl }}/docs/project#api), e clone-o:

```bash
git clone git@git.embrapa.io:<projeto>/io-api.git
cd io-api
```

### Estrutura do repositório

O repositório é mínimo: `api.json` (a especificação OpenAPI 3, que é o que importa), `config.json` (título, descrição e versão de reserva, opcional) e `README.md`.

### Escrevendo a especificação

Edite o `api.json` em [OpenAPI 3.0](https://spec.openapis.org/oas/v3.0.3). Os campos que fazem diferença na página publicada:

- `info.title`, `info.description` e `info.version` — cabeçalho da documentação;
- `servers` — um item por estágio da aplicação, para que o "_Try it out_" do Swagger UI aponte para a _build_ certa:

```json
"servers": [
  { "url": "https://alpha.embrapa.io/<projeto>/api", "description": "Alpha" },
  { "url": "https://beta.embrapa.io/<projeto>/api",  "description": "Beta" },
  { "url": "https://<projeto>.embrapa.io/api",        "description": "Produção" }
]
```

- `paths` — cada _endpoint_ com `summary`, `description`, `tags` e `operationId`. O catálogo de [api.embrapa.io](https://api.embrapa.io) usa exatamente esses campos para a busca por _endpoint_ entre todas as APIs da plataforma; _endpoints_ sem `summary` ficam invisíveis na busca.

Valide o arquivo no [Swagger Editor](https://editor.swagger.io) antes de publicar: um JSON inválido não é renderizado.

### Testando em ambiente local

```bash
docker run --rm -v "$(pwd):/api" -p 5000:8080 \
  -e SWAGGER_JSON=/api/api.json swaggerapi/swagger-ui
```

Acesse `http://localhost:5000`. Como o volume é montado, basta recarregar a página para ver as alterações no `api.json`.

### Publicando

_Commit_ e _push_ na `main`. A documentação é atualizada em `https://api.embrapa.io/<projeto>/` em poucos minutos e entra no catálogo de [api.embrapa.io](https://api.embrapa.io) quando o repositório tiver _commits_ próprios.

### Erros comuns

- **Página em branco ou erro de _parse_:** vírgula sobrando ou aspas erradas no `api.json`. O Swagger Editor aponta a linha.
- **"_Try it out_" falha por CORS:** a API precisa responder aos cabeçalhos `Access-Control-Allow-Origin` para a origem `https://api.embrapa.io`.
- **Versão errada no cabeçalho:** `info.version` do `api.json` prevalece sobre o `config.json`.

Uma especificação OpenAPI bem descrita também serve de base para expor a API a agentes de IA por meio de um [MCP Server]({{ site.baseurl }}/docs/mcp).

## Como a publicação funciona {#publishing}

A publicação é **automática e estática**. A cada ciclo de cinco minutos a plataforma verifica a `main` de cada `io-web` e `io-api`, reconstrói o que mudou e serve os arquivos gerados nos domínios `docs.embrapa.io` e `api.embrapa.io`, cada um com um **site-mãe** que cataloga todos os projetos e, no caso das APIs, permite buscar por _endpoint_.

Três comportamentos valem a pena conhecer:

- **Um _build_ com erro não derruba a versão anterior.** O site publicado continua no ar com o último _build_ bem-sucedido, e o erro chega por e-mail à equipe da plataforma, que avisa o time do projeto.
- **Sites ainda "no modelo" ficam ocultos no catálogo.** Enquanto o repositório só tiver o _commit_ do _fork_, o site continua acessível pelo _link_ direto, mas não é listado no site-mãe — o catálogo mostra apenas projetos que de fato escreveram algo.
- **Não há configuração de servidor.** Se o site precisa de uma _gem_ ou de um _plugin_ que não está no `Gemfile` do _boilerplate_, o caminho é [propor a melhoria no _boilerplate_]({{ site.baseurl }}/docs/merge), e não ajustar o servidor.
