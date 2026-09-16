---
# Processado pelo Jekyll (Liquid) para receber baseurl e o token do origin trial. Sem layout: é JavaScript puro.
layout: null
---
/*
 * WebMCP — ferramentas (tools) da documentação do Embrapa I/O para agentes de IA.
 *
 * Implementa a API imperativa do WebMCP (W3C Web Machine Learning CG, rascunho):
 *   document.modelContext.registerTool({ name, description, inputSchema, annotations, execute })
 * com fallback para navigator.modelContext (nome anterior, descontinuado no Chrome 150).
 *
 * É um aprimoramento progressivo: em navegadores sem a API nada acontece.
 * Todas as ferramentas são somente leitura, exceto `open_page`, que apenas navega
 * dentro deste site. Nenhuma ferramenta expõe dados sensíveis dos catálogos
 * (IPs, sub-redes, SMTP, SSH, telefones ou e-mails), mesmo que a API os contenha.
 */
(function () {
  'use strict';

  var BASE = '{{ site.baseurl }}';
  var ORIGIN_TRIAL_TOKEN = '{{ site.webmcp.origin_trial_token | default: "" }}';
  var API = '{{ site.webmcp.api | default: "https://core.embrapa.io" }}';
  var INDEX_URL = BASE + '/webmcp/docs.json';
  var MAX_TEXT = 24000;

  // Origin trial do Chrome (149–156): o token pode ser injetado por JavaScript.
  if (ORIGIN_TRIAL_TOKEN) {
    var ot = document.createElement('meta');
    ot.httpEquiv = 'origin-trial';
    ot.content = ORIGIN_TRIAL_TOKEN;
    document.head.appendChild(ot);
  }

  var mc = document.modelContext || navigator.modelContext;
  if (!mc || typeof mc.registerTool !== 'function') return;

  /* ------------------------------------------------------------------ */
  /* Índice das páginas de documentação (carregado sob demanda)          */
  /* ------------------------------------------------------------------ */

  var indexPromise = null;

  function loadIndex() {
    if (!indexPromise) {
      indexPromise = fetch(INDEX_URL, { cache: 'force-cache' }).then(function (r) {
        if (!r.ok) throw new Error('Índice da documentação indisponível (HTTP ' + r.status + ').');
        return r.json();
      }).then(function (pages) {
        pages.forEach(function (p) { p._norm = norm(p.title + ' ' + p.subtitle + ' ' + p.text); });
        return pages;
      });
      indexPromise.catch(function () { indexPromise = null; });
    }
    return indexPromise;
  }

  function norm(s) {
    return String(s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
  }

  var STOPWORDS = ('a o e de da do das dos em no na nos nas um uma uns umas para por com sem que se ao aos as os como qual quais onde ' +
    'quando mais menos muito pouco ser ter esta este isto isso aqui ali ou ja nao sim sobre entre ate desde apos ' +
    'the of and or to in on for with is are be this that').split(' ');

  function terms(q) {
    return norm(q).split(/[^a-z0-9_\-]+/).filter(function (t) { return t.length > 1 && STOPWORDS.indexOf(t) < 0; });
  }

  function snippet(text, ts, width) {
    var n = norm(text), pos = -1;
    for (var i = 0; i < ts.length && pos < 0; i++) pos = n.indexOf(ts[i]);
    if (pos < 0) return text.slice(0, width) + (text.length > width ? '…' : '');
    var start = Math.max(0, pos - Math.floor(width / 3));
    return (start > 0 ? '…' : '') + text.slice(start, start + width) + (start + width < text.length ? '…' : '');
  }

  function slugOf(url) {
    return url.replace(BASE, '').replace(/^\/docs\//, '').replace(/\/$/, '');
  }

  function findPage(pages, slug) {
    var s = norm(slug).replace(/^\/?docs\//, '').replace(/\/$/, '');
    for (var i = 0; i < pages.length; i++) {
      if (slugOf(pages[i].url) === s) return pages[i];
    }
    for (var j = 0; j < pages.length; j++) {
      if (norm(pages[j].title) === s) return pages[j];
    }
    return null;
  }

  function pageSummary(p) {
    return { slug: slugOf(p.url), title: p.title, subtitle: p.subtitle, url: location.origin + p.url };
  }

  /* ------------------------------------------------------------------ */
  /* Catálogos públicos da plataforma (com lista branca de campos)      */
  /* ------------------------------------------------------------------ */

  function fetchJson(path) {
    return fetch(API + path, { cache: 'no-store' }).then(function (r) {
      if (!r.ok) throw new Error('Catálogo indisponível (HTTP ' + r.status + ').');
      return r.json();
    });
  }

  function safeMaintainers(list) {
    return (Array.isArray(list) ? list : []).map(function (m) {
      return typeof m === 'string' ? m : (m && m.name) || '';
    }).filter(Boolean);
  }

  function safeEngine(e) {
    if (!e || !e.runtime) return null;
    return { runtime: e.runtime, type: e.type || '', arch: e.arch || '', memory: e.memory || '', models: Array.isArray(e.models) ? e.models : [] };
  }

  // Sem `base`, `ip` e URLs internas: o host só é alcançável a partir dos clusters.
  function safeGpu(g) {
    g = g || {};
    return { label: g.label || '', active: g.active !== false, inference: safeEngine(g.inference), embedding: safeEngine(g.embedding) };
  }

  function safeCluster(c, stage) {
    c = c || {};
    var res = c.resources || {};
    var active = function (k) { return !!(res[k] && res[k].active); };
    return {
      stage: stage,
      host: c.host || '',
      location: c.location || '',
      orchestrator: c.orchestrator || '',
      disabled: !!c.disabled,
      maintainers: safeMaintainers(c.maintainers),
      resources: {
        public_ip: active('external'), smtp: active('smtp'), web_terminal: active('terminal'),
        registry: active('registry'), backup: active('backup'), snapshot: active('snapshot'), gpu: active('gpu')
      },
      gpus: (Array.isArray(res.gpus) ? res.gpus : []).map(safeGpu)
    };
  }

  function safeBoilerplate(b) {
    b = b || {};
    return {
      unix: b.unix || '', label: b.label || '', description: b.description || '',
      categories: Array.isArray(b.categories) ? b.categories : [], disabled: !!b.disabled,
      url: location.origin + BASE + '/resources/boilerplates#' + encodeURIComponent(b.unix || '')
    };
  }

  /* ------------------------------------------------------------------ */
  /* Texto da página atual                                              */
  /* ------------------------------------------------------------------ */

  function currentPageText() {
    var main = document.querySelector('[role="main"]') || document.body;
    var clone = main.cloneNode(true);
    clone.querySelectorAll('script, style, nav, noscript, iframe').forEach(function (e) { e.remove(); });
    return clone.textContent.replace(/\s+/g, ' ').trim();
  }

  /* ------------------------------------------------------------------ */
  /* Ferramentas                                                        */
  /* ------------------------------------------------------------------ */

  var tools = [
    {
      name: 'search_docs',
      description: 'Busca na documentação técnica da plataforma Embrapa I/O (embrapa.io/docs) por palavras-chave, em português. Retorna os capítulos mais relevantes com título, URL e um trecho. Use antes de get_doc para descobrir qual capítulo responde à pergunta do usuário.',
      inputSchema: {
        type: 'object',
        properties: {
          query: { type: 'string', description: 'Palavras-chave ou pergunta, em português (por exemplo: "deploy em produção", "backup", "releaser", "boilerplate").' },
          limit: { type: 'integer', description: 'Número máximo de resultados (padrão 5, máximo 15).', minimum: 1, maximum: 15 }
        },
        required: ['query'],
        additionalProperties: false
      },
      annotations: { readOnlyHint: true },
      execute: function (input) {
        var ts = terms(input.query);
        var limit = Math.min(Math.max(parseInt(input.limit, 10) || 5, 1), 15);
        return loadIndex().then(function (pages) {
          if (!ts.length) return { query: input.query, results: [] };
          // Pontuação: cobertura dos termos pesa mais que repetição; ocorrências por termo são
          // limitadas e normalizadas pelo tamanho da página, para capítulos longos não dominarem.
          var scored = pages.map(function (p) {
            var score = 0, matched = 0, nt = norm(p.title + ' ' + p.subtitle);
            var lengthFactor = Math.sqrt(Math.max(p._norm.length, 2000) / 8000);
            ts.forEach(function (t) {
              var re = new RegExp(t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
              var inBody = Math.min((p._norm.match(re) || []).length, 25);
              var inTitle = (nt.match(re) || []).length;
              if (inBody || inTitle) matched++;
              score += inBody / lengthFactor + inTitle * 15;
            });
            score += matched * 30 + (matched === ts.length ? 40 : 0);
            return { p: p, score: matched ? Math.round(score) : 0 };
          }).filter(function (x) { return x.score > 0; }).sort(function (a, b) { return b.score - a.score; }).slice(0, limit);
          return {
            query: input.query,
            results: scored.map(function (x) {
              var s = pageSummary(x.p);
              s.snippet = snippet(x.p.text, ts, 320);
              s.score = x.score;
              return s;
            })
          };
        });
      }
    },
    {
      name: 'get_doc',
      description: 'Retorna o texto de um capítulo da documentação do Embrapa I/O, identificado pelo slug da URL (por exemplo "releaser", "delivery", "deploy", "cluster") ou pelo título. Capítulos longos vêm em partes: se "truncated" for true, chame de novo com "offset" igual a "next_offset". Use list_docs ou search_docs para descobrir os slugs.',
      inputSchema: {
        type: 'object',
        properties: {
          slug: { type: 'string', description: 'Slug do capítulo (o trecho da URL após /docs/), por exemplo "releaser".' },
          offset: { type: 'integer', description: 'Posição (em caracteres) a partir da qual devolver o texto. Padrão 0.', minimum: 0 }
        },
        required: ['slug'],
        additionalProperties: false
      },
      annotations: { readOnlyHint: true },
      execute: function (input) {
        return loadIndex().then(function (pages) {
          var p = findPage(pages, input.slug);
          if (!p) return { error: 'Capítulo não encontrado: ' + input.slug + '. Use list_docs para ver os slugs disponíveis.' };
          var s = pageSummary(p);
          var offset = Math.max(parseInt(input.offset, 10) || 0, 0);
          var end = Math.min(offset + MAX_TEXT, p.text.length);
          s.text = p.text.slice(offset, end);
          s.offset = offset;
          s.total_length = p.text.length;
          s.truncated = end < p.text.length;
          if (s.truncated) s.next_offset = end;
          return s;
        });
      }
    },
    {
      name: 'list_docs',
      description: 'Lista todos os capítulos da documentação do Embrapa I/O com slug, título, subtítulo e URL.',
      inputSchema: { type: 'object', properties: {}, additionalProperties: false },
      annotations: { readOnlyHint: true },
      execute: function () {
        return loadIndex().then(function (pages) { return { count: pages.length, docs: pages.map(pageSummary) }; });
      }
    },
    {
      name: 'get_current_page',
      description: 'Retorna o título, a URL e o texto principal da página do site do Embrapa I/O aberta no momento.',
      inputSchema: { type: 'object', properties: {}, additionalProperties: false },
      annotations: { readOnlyHint: true },
      execute: function () {
        var text = currentPageText();
        return { title: document.title, url: location.href, text: text.length > MAX_TEXT ? text.slice(0, MAX_TEXT) + '…' : text };
      }
    },
    {
      name: 'list_boilerplates',
      description: 'Lista os boilerplates (modelos de aplicação) disponíveis na plataforma Embrapa I/O, com nome unix, rótulo, descrição e categorias. Aceita um filtro textual opcional.',
      inputSchema: {
        type: 'object',
        properties: {
          search: { type: 'string', description: 'Filtro opcional por texto (nome, rótulo, descrição ou categoria).' }
        },
        additionalProperties: false
      },
      annotations: { readOnlyHint: true },
      execute: function (input) {
        return fetchJson('/metadata/boilerplates.json').then(function (data) {
          var list = (Array.isArray(data) ? data : Object.values(data || {})).map(safeBoilerplate);
          var q = norm(input && input.search);
          if (q) list = list.filter(function (b) { return norm(b.unix + ' ' + b.label + ' ' + b.description + ' ' + b.categories.join(' ')).indexOf(q) >= 0; });
          return { count: list.length, boilerplates: list };
        });
      }
    },
    {
      name: 'list_clusters',
      description: 'Lista os clusters compartilhados do catálogo do Embrapa I/O onde as builds podem ser instanciadas, agrupados por estágio (alpha, beta, release), com host, localização, orquestrador, mantenedores e recursos disponíveis (SMTP, IP público, web terminal, registro, backup, snapshot, GPU). Não inclui dados de rede.',
      inputSchema: {
        type: 'object',
        properties: {
          stage: { type: 'string', description: 'Filtrar por estágio: alpha, beta ou release. Opcional.', enum: ['alpha', 'beta', 'release'] }
        },
        additionalProperties: false
      },
      annotations: { readOnlyHint: true },
      execute: function (input) {
        return fetchJson('/metadata/clusters.json').then(function (data) {
          var out = [];
          Object.keys(data || {}).forEach(function (stage) {
            if (input && input.stage && input.stage !== stage) return;
            (Array.isArray(data[stage]) ? data[stage] : []).forEach(function (c) { out.push(safeCluster(c, stage)); });
          });
          return { count: out.length, clusters: out, catalog: location.origin + BASE + '/resources/clusters' };
        });
      }
    },
    {
      name: 'list_gpu_servers',
      description: 'Lista os GPU Servers (servidores de inferência de LLMs e embeddings) acessíveis a partir dos clusters do Embrapa I/O, com rótulo, runtime, modelos publicados, arquitetura, memória e a partir de quais clusters são alcançáveis.',
      inputSchema: { type: 'object', properties: {}, additionalProperties: false },
      annotations: { readOnlyHint: true },
      execute: function () {
        return fetchJson('/metadata/clusters.json').then(function (data) {
          var seen = {}, out = [];
          Object.keys(data || {}).forEach(function (stage) {
            (Array.isArray(data[stage]) ? data[stage] : []).forEach(function (c) {
              var gpus = (c && c.resources && Array.isArray(c.resources.gpus)) ? c.resources.gpus : [];
              gpus.forEach(function (g) {
                var s = safeGpu(g), key = String((g && g.base) || s.label);
                if (!seen[key]) { s.clusters = []; seen[key] = s; out.push(s); }
                if (c.host && seen[key].clusters.indexOf(c.host) < 0) seen[key].clusters.push(c.host);
              });
            });
          });
          return { count: out.length, gpu_servers: out, catalog: location.origin + BASE + '/resources/gpus' };
        });
      }
    },
    {
      name: 'open_page',
      description: 'Navega para uma página deste site (embrapa.io), dada a URL ou o caminho relativo (por exemplo "/docs/releaser"). Só aceita endereços do próprio site.',
      inputSchema: {
        type: 'object',
        properties: {
          url: { type: 'string', description: 'URL absoluta em embrapa.io ou caminho relativo iniciado por "/".' }
        },
        required: ['url'],
        additionalProperties: false
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true },
      execute: function (input) {
        var target;
        try { target = new URL(input.url, location.origin); } catch (e) { return { error: 'URL inválida.' }; }
        if (target.origin !== location.origin) return { error: 'Só é permitido navegar dentro de ' + location.origin + '.' };
        location.assign(target.href);
        return { navigating_to: target.href };
      }
    }
  ];

  tools.forEach(function (t) {
    try {
      var r = mc.registerTool(t);
      if (r && typeof r.catch === 'function') r.catch(function (e) { console.warn('[webmcp] falha ao registrar ' + t.name + ':', e); });
    } catch (e) {
      console.warn('[webmcp] falha ao registrar ' + t.name + ':', e);
    }
  });

  // Ponto de inspeção para depuração manual no console: window.__embrapaIoWebMCP.tools
  window.__embrapaIoWebMCP = { tools: tools, api: mc === document.modelContext ? 'document.modelContext' : 'navigator.modelContext' };
})();
