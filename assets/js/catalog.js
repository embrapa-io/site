/*
 * Catálogos dinâmicos do Embrapa I/O — boilerplates, clusters e GPU Servers.
 *
 * Lê os JSONs públicos do backend da plataforma (core.embrapa.io/metadata/…)
 * e monta painéis expansíveis com o Bootstrap 4 do tema. Só entram na página
 * informações não sensíveis: nada de IPs, sub-redes, SMTP, SSH, telefones ou
 * e-mails — mesmo que o JSON os contenha.
 *
 * Uso: <div class="io-catalog" data-catalog="boilerplates|clusters|gpus" [data-api="…"]></div>
 */
(function () {
  'use strict';

  if (window.ioCatalogLoaded) return;
  window.ioCatalogLoaded = true;

  var DEFAULT_API = 'https://core.embrapa.io';
  var GITLAB = 'https://git.embrapa.io';

  var STAGES = ['alpha', 'beta', 'release'];

  // Nomes dos orquestradores como aparecem na documentação (o JSON traz o identificador do driver).
  var ORCHESTRATOR_LABELS = { DockerCompose: 'Docker Compose', DockerSwarm: 'Docker Swarm' };

  var CATEGORY_LABELS = {
    ai: 'IA', backend: 'Backend', frontend: 'Frontend', corporate: 'Corporativo',
    tool: 'Ferramenta', database: 'Banco de dados', daemon: 'Daemon', iot: 'IoT'
  };

  // Mesmos rótulos e padrões do wizard de build da dashboard (WizardEnvironment.vue):
  // quando o atributo não existe no JSON, vale o "default".
  var FEATURES = [
    { key: 'external', icon: 'fa-solid fa-globe', label: 'IP Público', def: true },
    { key: 'smtp', icon: 'fa-solid fa-envelope', label: 'SMTP Server', def: false },
    { key: 'terminal', icon: 'fa-solid fa-terminal', label: 'Web Terminal', def: false },
    { key: 'registry', icon: 'fa-brands fa-docker', label: 'Registro de imagens', def: false },
    { key: 'backup', icon: 'fa-solid fa-box-archive', label: 'Backup individualizado', def: false },
    { key: 'snapshot', icon: 'fa-solid fa-camera', label: 'Snapshot', def: true },
    { key: 'gpu', icon: 'fa-solid fa-microchip', label: 'GPU Server', def: false }
  ];

  function resourceActive (resources, f) {
    var r = resources && resources[f.key];
    if (!r || typeof r !== 'object' || !Object.prototype.hasOwnProperty.call(r, 'active')) return f.def;
    return !!r.active;
  }

  // ---------------------------------------------------------------- utilidades

  function esc (s) {
    return String(s === undefined || s === null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  // Só aceita classes Font Awesome simples vindas do JSON (ex.: "fa-solid fa-database").
  function iconClass (s, fallback) {
    return (typeof s === 'string' && /^[a-z0-9 -]{3,60}$/.test(s)) ? s : fallback;
  }

  // Texto puro com URLs viradas em links.
  function linkify (s) {
    return esc(s).replace(/(https?:\/\/[^\s<)]+)/g, function (u) {
      return '<a href="' + u + '" target="_blank" rel="noopener">' + u + '</a>';
    });
  }

  function badge (text, cls) {
    return '<span class="badge ' + (cls || 'badge-secondary') + '">' + esc(text) + '</span>';
  }

  function hostOf (url) {
    return String(url || '').replace(/^https?:\/\//, '').replace(/[/:].*$/, '');
  }

  function fetchJson (api, file) {
    return fetch(api + '/metadata/' + file, { cache: 'no-store' }).then(function (r) {
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.json();
    });
  }

  var uid = 0;
  function nextId () { uid += 1; return 'io-cat-' + uid; }

  // Card expansível (Bootstrap 4 collapse).
  function card (opts) {
    var id = nextId();
    return '' +
      '<div class="card' + (opts.disabled ? ' io-disabled' : '') + '">' +
        '<div class="card-header" id="' + id + '-h">' +
          '<button class="btn btn-link collapsed" type="button" data-toggle="collapse" data-target="#' + id + '" aria-expanded="false" aria-controls="' + id + '">' +
            '<i class="io-icon ' + esc(opts.icon) + '"></i>' +
            '<span class="io-title">' + esc(opts.title) + '</span>' +
            '<span class="io-badges">' + (opts.badges || '') + '</span>' +
            '<i class="io-caret fa-solid fa-chevron-down"></i>' +
          '</button>' +
        '</div>' +
        '<div id="' + id + '" class="collapse" aria-labelledby="' + id + '-h">' +
          '<div class="card-body">' + opts.body + '</div>' +
        '</div>' +
      '</div>';
  }

  function props (pairs) {
    var html = '<dl class="io-props">';
    pairs.forEach(function (p) {
      if (p[1] === undefined || p[1] === null || p[1] === '') return;
      html += '<dt>' + esc(p[0]) + '</dt><dd>' + p[1] + '</dd>';
    });
    return html + '</dl>';
  }

  // ---------------------------------------------------------------- boilerplates

  function renderBoilerplates (root, api) {
    return fetchJson(api, 'boilerplates.json').then(function (list) {
      if (!Array.isArray(list)) throw new Error('formato inesperado');

      list = list.slice().sort(function (a, b) { return String(a.label).localeCompare(String(b.label), 'pt-BR'); });

      var categories = {};
      list.forEach(function (b) { (b.categories || []).forEach(function (c) { categories[c] = (categories[c] || 0) + 1; }); });

      var state = { category: '', search: '', showDisabled: false };

      var toolbar = '<div class="io-toolbar">' +
        '<input type="search" class="form-control form-control-sm io-search" placeholder="Filtrar por nome ou descrição…" aria-label="Filtrar boilerplates por nome ou descrição">' +
        '<select class="form-control form-control-sm io-category" aria-label="Filtrar boilerplates por tipo">' +
          '<option value="">Todos os tipos</option>' +
          Object.keys(categories).sort(function (a, b) { return (CATEGORY_LABELS[a] || a).localeCompare(CATEGORY_LABELS[b] || b, 'pt-BR'); }).map(function (c) {
            return '<option value="' + esc(c) + '">' + esc(CATEGORY_LABELS[c] || c) + ' (' + categories[c] + ')</option>';
          }).join('') +
        '</select>' +
        '<label class="io-muted mb-0"><input type="checkbox" class="io-show-disabled"> mostrar descontinuados</label>' +
      '</div>';

      var listEl = document.createElement('div');
      var statusEl = document.createElement('p');
      statusEl.className = 'io-status';

      root.innerHTML = toolbar;
      root.appendChild(statusEl);
      root.appendChild(listEl);

      function draw () {
        var q = state.search.trim().toLowerCase();
        var shown = list.filter(function (b) {
          if (b.disabled && !state.showDisabled) return false;
          if (state.category && (b.categories || []).indexOf(state.category) < 0) return false;
          if (q && (String(b.label) + ' ' + String(b.description) + ' ' + String(b.unix)).toLowerCase().indexOf(q) < 0) return false;
          return true;
        });

        statusEl.textContent = shown.length + ' de ' + list.length + ' boilerplates' + (state.showDisabled ? '' : ' ativos') + '.';

        listEl.innerHTML = shown.map(function (b) {
          var badges = (b.categories || []).map(function (c) { return badge(CATEGORY_LABELS[c] || c, 'badge-info'); }).join('') +
            (b.disabled ? badge('descontinuado', 'badge-secondary') : '');
          var repo = GITLAB + '/io/boilerplate/' + encodeURIComponent(String(b.unix));
          var body = '<p>' + linkify(b.description) + '</p>' +
            props([
              ['Identificador', '<code>' + esc(b.unix) + '</code>'],
              ['Repositório', '<a href="' + repo + '" target="_blank" rel="noopener">' + esc(hostOf(repo) + '/io/boilerplate/' + b.unix) + '</a> <span class="io-muted">(requer login na plataforma)</span>']
            ]) +
            // Detalhes do .embrapa/settings.json (referências, mantenedores, plataforma),
            // carregados só quando o painel é aberto — uma chamada por boilerplate.
            '<div class="io-details" data-unix="' + esc(b.unix) + '"><p class="io-muted">Carregando referências e mantenedores…</p></div>';
          return card({ icon: iconClass(b.icon, 'fa-solid fa-cube'), title: b.label, badges: badges, body: body, disabled: !!b.disabled });
        }).join('') || '<p class="io-muted">Nenhum boilerplate corresponde ao filtro.</p>';
      }

      root.querySelector('.io-search').addEventListener('input', function (e) { state.search = e.target.value; draw(); });
      root.querySelector('.io-category').addEventListener('change', function (e) { state.category = e.target.value; draw(); });
      root.querySelector('.io-show-disabled').addEventListener('change', function (e) { state.showDisabled = e.target.checked; draw(); });

      // Bootstrap 4 dispara os eventos do collapse via jQuery; delegação no container
      // sobrevive aos redesenhos do filtro.
      if (window.jQuery) {
        window.jQuery(listEl).on('show.bs.collapse', '.collapse', function () {
          var details = this.querySelector('.io-details');
          if (!details || details.getAttribute('data-loaded')) return;
          details.setAttribute('data-loaded', '1');
          loadBoilerplateDetails(api, details.getAttribute('data-unix'), details);
        });
      }

      draw();
    });
  }

  // Referências, mantenedores (só nomes) e plataforma do .embrapa/settings.json,
  // pela rota pública /boilerplate/:unix do backend (a mesma que a dashboard usa).
  function loadBoilerplateDetails (api, unix, el) {
    fetch(api + '/boilerplate/' + encodeURIComponent(unix), { cache: 'no-store' }).then(function (r) {
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.json();
    }).then(function (s) {
      var refs = Array.isArray(s.references) ? s.references.filter(function (x) { return x && x.url; }) : [];
      var maint = Array.isArray(s.maintainers) ? s.maintainers.map(function (m) { return m && m.name; }).filter(Boolean) : [];
      el.innerHTML = props([
        ['Plataforma', s.platform ? '<code>' + esc(s.platform) + '</code>' : ''],
        ['Referências', refs.length ? '<ul class="mb-0 pl-3">' + refs.map(function (x) {
          return '<li><a href="' + esc(x.url) + '" target="_blank" rel="noopener">' + esc(x.label || x.name || x.url) + '</a></li>';
        }).join('') + '</ul>' : ''],
        ['Mantenedores', maint.length ? esc(maint.join(', ')) : '']
      ]);
      if (!el.innerHTML.replace(/<dl[^>]*><\/dl>/, '').trim()) el.innerHTML = '';
    }).catch(function () {
      el.innerHTML = '<p class="io-muted">Referências e mantenedores indisponíveis no momento.</p>';
    });
  }

  // ---------------------------------------------------------------- clusters

  // Uma entrada por host, agregando os estágios em que ele aparece.
  function groupClusters (json) {
    var hosts = {};
    STAGES.forEach(function (stage) {
      (json[stage] || []).forEach(function (c) {
        var h = hosts[c.host] || (hosts[c.host] = { host: c.host, stages: {}, entry: c });
        h.stages[stage] = { disabled: !!c.disabled };
        if (!c.disabled) h.entry = c; // prefere um estágio ativo como referência
      });
    });
    return Object.keys(hosts).sort(function (a, b) {
      var A = hosts[a], B = hosts[b];
      var da = STAGES.every(function (s) { return !A.stages[s] || A.stages[s].disabled; });
      var db = STAGES.every(function (s) { return !B.stages[s] || B.stages[s].disabled; });
      if (da !== db) return da ? 1 : -1; // desativados por último
      return String(A.entry.local || '').localeCompare(String(B.entry.local || ''), 'pt-BR') || a.localeCompare(b);
    }).map(function (k) { return hosts[k]; });
  }

  function stageBadges (stages) {
    return STAGES.filter(function (s) { return stages[s]; }).map(function (s) {
      return stages[s].disabled ? badge(s, 'badge-secondary') : badge(s, 'badge-stage-' + s);
    }).join('');
  }

  function renderClusters (root, api) {
    return fetchJson(api, 'clusters.json').then(function (json) {
      var hosts = groupClusters(json);
      var active = hosts.filter(function (h) { return STAGES.some(function (s) { return h.stages[s] && !h.stages[s].disabled; }); });

      var html = '<p class="io-status">' + active.length + ' clusters ativos de ' + hosts.length + ' registrados.</p>';

      html += hosts.map(function (h) {
        var c = h.entry;
        var allOff = STAGES.every(function (s) { return !h.stages[s] || h.stages[s].disabled; });
        var res = c.resources || {};
        var gpus = Array.isArray(res.gpus) ? res.gpus.filter(function (g) { return g && g.active !== false; }) : [];

        var features = '<ul class="io-features">' + FEATURES.map(function (f) {
          var on = resourceActive(res, f);
          return '<li class="' + (on ? '' : 'io-off') + '"><i class="' + f.icon + '"></i>' + esc(f.label) + (on ? '' : ' <span class="io-muted">(não)</span>') + '</li>';
        }).join('') + '</ul>';

        var gpuHtml = gpus.length
          ? gpus.map(function (g) {
              return '<a href="' + esc(gpuAnchorHref(g)) + '">' + esc(g.label || hostOf(g.base)) + '</a>';
            }).join(', ') + (res.gpu && res.gpu.tool ? ' <span class="io-muted">— ' + esc(res.gpu.tool) + '</span>' : '')
          : '';

        var body = props([
          ['Onde', esc([c.local, c.location].filter(Boolean).join(' — '))],
          ['Orquestrador', esc(ORCHESTRATOR_LABELS[c.orchestrator] || c.orchestrator)],
          ['Nós', c.nodes && typeof c.nodes === 'object' && Object.keys(c.nodes).length ? String(Object.keys(c.nodes).length) : ''],
          ['Aliases', Array.isArray(c.aliases) && c.aliases.length ? c.aliases.map(function (a) { return '<code>' + esc(a) + '</code>'; }).join(' ') : ''],
          ['Mantenedores', Array.isArray(c.maintainers) && c.maintainers.length ? esc(c.maintainers.map(function (m) { return m && m.name; }).filter(Boolean).join(', ')) : ''],
          ['GPU Servers', gpuHtml]
        ]) + '<p class="io-muted mb-1">Recursos:</p>' + features +
          (allOff ? '<p class="io-muted">Este cluster não aceita novos deploys no momento.</p>' : '');

        return card({ icon: allOff ? 'fa-solid fa-server' : 'fa-solid fa-server', title: h.host, badges: stageBadges(h.stages), body: body, disabled: allOff });
      }).join('');

      root.innerHTML = html;
    });
  }

  // ---------------------------------------------------------------- GPU Servers

  // Um GPU Server pode ser referenciado por vários clusters; a chave é a URL base.
  function collectGpus (json) {
    var map = {};
    STAGES.forEach(function (stage) {
      (json[stage] || []).forEach(function (c) {
        var list = c.resources && Array.isArray(c.resources.gpus) ? c.resources.gpus : [];
        list.forEach(function (g) {
          if (!g || !g.base) return;
          var k = hostOf(g.base);
          var e = map[k] || (map[k] = { key: k, gpu: g, clusters: {} });
          if (!c.disabled) e.clusters[c.host] = true;
        });
      });
    });
    return Object.keys(map).sort(function (a, b) {
      return String(map[a].gpu.label || a).localeCompare(String(map[b].gpu.label || b), 'pt-BR');
    }).map(function (k) { return map[k]; });
  }

  function gpuAnchorHref (g) {
    var here = window.location.pathname.indexOf('/resources/gpus') >= 0;
    return (here ? '' : (window.ioCatalogBase || '') + '/resources/gpus') + '#' + gpuAnchor(g);
  }

  function gpuAnchor (g) {
    return 'gpu-' + hostOf(g.base).replace(/[^a-z0-9]+/gi, '-').toLowerCase();
  }

  function engine (label, e) {
    if (!e || !e.runtime) return '';
    var models = Array.isArray(e.models) && e.models.length
      ? '<span class="io-models">' + e.models.map(function (m) { return '<code>' + esc(m) + '</code>'; }).join('') + '</span>'
      : '<span class="io-muted">sem modelos publicados</span>';
    var runtime = e.url ? '<a href="' + esc(e.url) + '" target="_blank" rel="noopener">' + esc(e.runtime) + '</a>' : esc(e.runtime);
    var where = [e.type ? esc(String(e.type).toUpperCase()) : '', e.arch ? esc(e.arch) : '', e.memory ? esc(e.memory) : ''].filter(Boolean).join(' · ');
    return '<p class="mb-1"><strong>' + esc(label) + ':</strong> ' + runtime +
      (e.api ? ' <span class="io-muted">(API <code>' + esc(e.api) + '</code>)</span>' : '') +
      (where ? ' <span class="io-muted">— ' + where + '</span>' : '') + '</p>' +
      '<p>' + models + '</p>';
  }

  function renderGpus (root, api) {
    return fetchJson(api, 'clusters.json').then(function (json) {
      var gpus = collectGpus(json);

      var html = '<p class="io-status">' + gpus.length + ' GPU Servers disponíveis para as aplicações da plataforma.</p>';

      html += gpus.map(function (e) {
        var g = e.gpu;
        var inf = g.inference || {};
        var badges = [inf.arch ? badge(inf.arch, 'badge-info') : '', inf.memory ? badge(inf.memory, 'badge-light') : '', g.active === false ? badge('inativo', 'badge-secondary') : ''].join('');
        var clusters = Object.keys(e.clusters).sort();
        var body = props([
          ['Host', '<code>' + esc(hostOf(g.base)) + '</code> <span class="io-muted">(acessível apenas a partir dos clusters da plataforma)</span>'],
          ['Disponível a partir de', clusters.length ? clusters.map(function (h) { return '<code>' + esc(h) + '</code>'; }).join(' ') : '<span class="io-muted">nenhum cluster ativo</span>']
        ]) + engine('Inferência', g.inference) + engine('Embeddings', g.embedding) +
          '<p class="io-muted">Endereço completo, chaves e limites são exibidos na <em>dashboard</em> ao configurar a <em>build</em> num cluster que enxerga este servidor.</p>';

        return '<div id="' + esc(gpuAnchor(g)) + '">' + card({ icon: 'fa-solid fa-microchip', title: g.label || hostOf(g.base), badges: badges, body: body, disabled: g.active === false }) + '</div>';
      }).join('') || '<p class="io-muted">Nenhum GPU Server publicado no momento.</p>';

      root.innerHTML = html;

      // abre o painel apontado pela âncora da URL
      if (window.location.hash) {
        var target = root.querySelector(window.location.hash + ' .collapse');
        if (target && window.jQuery) window.jQuery(target).collapse('show');
      }
    });
  }

  // ---------------------------------------------------------------- bootstrap

  var RENDERERS = { boilerplates: renderBoilerplates, clusters: renderClusters, gpus: renderGpus };

  function init () {
    document.querySelectorAll('.io-catalog[data-catalog]').forEach(function (root) {
      var type = root.getAttribute('data-catalog');
      var api = (root.getAttribute('data-api') || DEFAULT_API).replace(/\/+$/, '');
      var render = RENDERERS[type];
      if (!render) { root.innerHTML = '<p class="io-status io-error">Tipo de catálogo desconhecido: ' + esc(type) + '.</p>'; return; }
      render(root, api).catch(function (err) {
        root.innerHTML = '<p class="io-status io-error">Não foi possível carregar o catálogo agora (' + esc(err && err.message) + '). ' +
          'Os dados brutos ficam em <a href="' + esc(api) + '/metadata/' + (type === 'boilerplates' ? 'boilerplates' : 'clusters') + '.json" target="_blank" rel="noopener">' + esc(api) + '</a>.</p>';
      });
    });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
