# Site do Embrapa I/O (embrapa.io) — guia para agentes de IA

Site estático em **Jekyll** (tema Beautiful Jekyll, Bootstrap 4.4.1, Font Awesome, jQuery), publicado pelo **GitHub Pages** a partir da branch `master`. Conteúdo em `docs/*.md` (documentação técnica), `resources/*.md` (catálogos dinâmicos), `_posts/` (blog) e `about.md`. Idioma: português brasileiro com acentuação correta. URLs e âncoras sempre em **inglês** (`/resources/clusters`, `#catalog`).

## REGRA ABSOLUTA: nada é instalado na máquina do desenvolvedor

**Todo build, serve ou teste deste site roda em Docker.** É proibido executar `bundle install`, `bundle exec`, `gem install`, `jekyll` ou qualquer instalação de Ruby/gems no host, com ou sem `BUNDLE_PATH`, `GEM_HOME` ou `--install-dir`. Em 15/09/2026 um `bundle install` "só para validar" instalou gems no Ruby do Homebrew do Camilo antes de falhar por permissão e teve de ser desfeito à mão. Não repetir.

Se algo parecer exigir instalação fora do container, **pare e pergunte**.

### Como servir localmente (o que o README manda)

```bash
docker run --rm --name jekyll -p 8123:4000 -v $(pwd):/site bretfisher/jekyll-serve:alpine
# http://localhost:8123
```

### Como validar um build sem servir (Liquid, includes, páginas geradas)

```bash
docker run --rm -v "$(pwd):/site" -v "<dir-temporário>:/out" bretfisher/jekyll-serve:alpine \
  sh -c 'cd /site && bundle exec jekyll build --destination /out'
```

Escrever a saída num diretório temporário fora do repositório (nunca em `_site/` dentro dele, que está no `.gitignore` mas polui o `docker run` do serve). Um build limpo termina com `done in N seconds` **sem nenhum `Liquid Warning`**. Texto com chaves duplas que não é Liquid (ex.: `{{.Name}}` de templates Go em comandos Docker) deve ficar entre `{% raw %}…{% endraw %}`, inclusive quando inline em parágrafo.

A imagem `bretfisher/jekyll-serve:alpine` já existe no Docker local. O `Gemfile.lock` está no `.gitignore` e é gerado dentro do container — não commitá-lo.

## Estrutura que importa

| Caminho | Papel |
|---|---|
| `_config.yml` | Configuração do tema, `navbar-links` (menu), cores (`link-col: #008AFF`), `exclude`. |
| `docs/*.md` | Um arquivo por capítulo; front matter `layout: page`, `title`, `subtitle`. Âncoras explícitas em inglês nos títulos: `## Texto {#anchor}`. `docs/preface.md` é o índice (seções Getting Start, Avançado, Recursos). |
| `resources/*.md` | Páginas dos **catálogos dinâmicos** (`boilerplates`, `clusters`, `gpus`), montados no navegador a partir da API pública `https://core.embrapa.io/metadata/*.json` via `{% include catalog.html type="…" %}`. |
| `_includes/catalog.html`, `assets/js/catalog.js`, `assets/css/catalog.css` | Implementação dos catálogos. O JS escapa todo texto da API e **nunca exibe** IPs, sub-redes, SMTP, SSH, telefones ou e-mails, mesmo que o JSON os contenha. Manter isso ao evoluir. |
| `_includes/`, `_layouts/` | Tema (Beautiful Jekyll). Evitar mexer; preferir `_includes` novos e `assets/css/custom-styles.css`. |
| `assets/img/<capítulo>/NN.png` | Capturas de tela referenciadas pelos docs como `{{ site.baseurl }}/assets/img/...`. |

## Convenções de escrita

- Links internos sempre com `{{ site.baseurl }}/docs/<capítulo>` ou `{{ site.baseurl }}/resources/<catálogo>`; nunca caminho absoluto sem `site.baseurl`.
- Avisos em blockquote iniciado por `> **Atenção!**`; termos técnicos em inglês em itálico (`_boilerplate_`, `_build_`, `_deploy_`), nomes de ferramentas em negrito na primeira menção (**Embrapa I/O**, **Matomo**).
- Código e comandos em blocos cercados; variáveis de ambiente e nomes de arquivos em `crase`.
- Uma mudança de comportamento da plataforma vira também uma nota na documentação correspondente (ex.: rota nova do backend → `docs/app.md` ou `docs/releaser.md`).

## Fluxo de publicação

1. Editar; validar com o build em Docker (acima); se for conteúdo dinâmico, testar no navegador com o `jekyll serve` em Docker.
2. `git commit` com mensagem em português explicando o porquê; `git push origin master`.
3. O GitHub Pages publica sozinho em alguns minutos. Não há tag nem versão.
