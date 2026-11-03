/*
 * mock-core.js — 영업 데모용 공통 목업 엔진 (DB/백엔드 없이 동작)
 *
 * 페이지의 XMLHttpRequest / fetch 호출을 가로채서 등록된 라우트 핸들러가 만든
 * 예시 데이터를 돌려준다. jQuery $.ajax, axios, Tabulator ajax 모두 이 두 API를 쓰므로
 * 원본 화면 코드는 건드리지 않는다.
 *
 * 사용법 (라우트 파일):
 *   MOCK.get('/quality/cpk/list', function (req) { return { data: [...] }; });
 *   MOCK.post('/user/save', function (req) { return 'success'; });          // 문자열 → text 그대로
 *   MOCK.any(/^\/plc\/read\/(\w+)$/, function (req) { req.match[1] ... });
 *   MOCK.get('/equip/:id/detail', function (req) { req.params.id ... });
 *
 * req = { method, path, url, query, body, params(=query+body+경로변수), match, raw }
 * 경로는 컨텍스트(/line 등)를 뗀 값으로 매칭한다. 다른 호스트(예: :9090 API 서버)로 가는
 * 요청도 경로만으로 매칭하고, 실제 네트워크로는 절대 내보내지 않는다.
 */
(function () {
  'use strict';
  if (window.MOCK && window.MOCK.__core) return;

  var CFG = window.MOCK_CONFIG || {};
  var CTX = CFG.ctx || '';
  var PASSTHROUGH = CFG.passthrough || [];
  var STATIC_RE = /\.(js|mjs|css|html?|jsp|png|jpe?g|gif|svg|ico|bmp|webp|woff2?|ttf|eot|otf|map|txt|xlsx?|xls|csv|pdf|mp3|mp4|webm|wav|glb|gltf|hdr|bin|wasm)$/i;

  var routes = [];
  var unhandled = [];

  /* ───────────────────────── 유틸 ───────────────────────── */

  function pad(n, w) { n = String(n); while (n.length < (w || 2)) n = '0' + n; return n; }

  // 'YYYY-MM-DD HH:mm:ss' 형태 포맷터 (토큰: YYYY YY MM DD HH mm ss SSS)
  function fmt(d, pattern) {
    if (!(d instanceof Date)) d = new Date(d);
    pattern = pattern || 'YYYY-MM-DD HH:mm:ss';
    return pattern
      .replace('YYYY', d.getFullYear())
      .replace('YY', String(d.getFullYear()).slice(2))
      .replace('MM', pad(d.getMonth() + 1))
      .replace('DD', pad(d.getDate()))
      .replace('HH', pad(d.getHours()))
      .replace('mm', pad(d.getMinutes()))
      .replace('ss', pad(d.getSeconds()))
      .replace('SSS', pad(d.getMilliseconds(), 3));
  }

  // 'YYYY-MM-DD', 'YYYY-MM-DD HH:mm(:ss)', 'YYYYMMDD', Date, number 를 모두 Date로
  function toDate(v) {
    if (v instanceof Date) return new Date(v.getTime());
    if (typeof v === 'number') return new Date(v);
    if (!v) return null;
    var s = String(v).trim();
    var m = s.match(/^(\d{4})-?(\d{2})-?(\d{2})(?:[ T](\d{2}):?(\d{2})(?::?(\d{2}))?)?/);
    if (!m) { var t = Date.parse(s); return isNaN(t) ? null : new Date(t); }
    return new Date(+m[1], +m[2] - 1, +m[3], +(m[4] || 0), +(m[5] || 0), +(m[6] || 0));
  }

  function startOfDay(d) { d = toDate(d) || new Date(); d.setHours(0, 0, 0, 0); return d; }
  function addDays(d, n) { d = toDate(d); d.setDate(d.getDate() + n); return d; }
  function addMinutes(d, n) { d = toDate(d); return new Date(d.getTime() + n * 60000); }

  // 데모 데이터가 존재하는 3일 (그제, 어제, 오늘) — 항상 접속일 기준으로 움직인다
  function demoDays() {
    var t = startOfDay(new Date());
    return [addDays(t, -2), addDays(t, -1), t].map(function (d) { return fmt(d, 'YYYY-MM-DD'); });
  }

  // from~to(날짜 또는 일시 문자열) 범위에 v가 들어가는지. from/to가 비면 제한 없음.
  // to가 날짜만 있으면 그 날 23:59:59까지 포함.
  function inRange(v, from, to) {
    var d = toDate(v); if (!d) return false;
    var f = toDate(from), t = toDate(to);
    if (t && /^\s*\d{4}-?\d{2}-?\d{2}\s*$/.test(String(to))) t.setHours(23, 59, 59, 999);
    if (f && d < f) return false;
    if (t && d > t) return false;
    return true;
  }

  function hash(str) {
    str = String(str);
    var h = 2166136261 >>> 0;
    for (var i = 0; i < str.length; i++) { h ^= str.charCodeAt(i); h = Math.imul(h, 16777619) >>> 0; }
    return h >>> 0;
  }

  // 시드 고정 난수 — 같은 시드면 새로고침해도 같은 데이터가 나온다
  function rng(seed) {
    var a = hash(seed) || 1;
    var r = function () {
      a |= 0; a = (a + 0x6D2B79F5) | 0;
      var t = Math.imul(a ^ (a >>> 15), 1 | a);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
    r.int = function (lo, hi) { return lo + Math.floor(r() * (hi - lo + 1)); };
    r.float = function (lo, hi, dec) { var v = lo + r() * (hi - lo); return dec == null ? v : +v.toFixed(dec); };
    r.pick = function (arr) { return arr[Math.floor(r() * arr.length)]; };
    r.chance = function (p) { return r() < p; };
    r.normal = function (mean, sd, dec) {
      var u = 1 - r(), v = r();
      var x = mean + sd * Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v);
      return dec == null ? x : +x.toFixed(dec);
    };
    r.shuffle = function (arr) { arr = arr.slice(); for (var i = arr.length - 1; i > 0; i--) { var j = Math.floor(r() * (i + 1)); var t = arr[i]; arr[i] = arr[j]; arr[j] = t; } return arr; };
    return r;
  }

  // 시간에 대해 부드럽게 변하는 값 (트렌드/실시간 값). 같은 key·시각이면 항상 같은 값.
  //   base: 중심값, amp: 완만한 진동폭, noise: 잔떨림, periodMin: 진동 주기(분)
  function wave(key, time, base, amp, noise, periodMin) {
    var t = (toDate(time) || new Date()).getTime() / 60000;
    var ph = (hash(key) % 1000) / 1000 * Math.PI * 2;
    var p = periodMin || 90;
    var v = base + amp * Math.sin(2 * Math.PI * t / p + ph) + amp * 0.35 * Math.sin(2 * Math.PI * t / (p * 0.37) + ph * 1.7);
    if (noise) { var r = rng(key + '|' + Math.floor(t)); v += (r() - 0.5) * 2 * noise; }
    return v;
  }

  function round(v, dec) { var p = Math.pow(10, dec || 0); return Math.round(v * p) / p; }

  function parseQuery(qs) {
    var out = {};
    if (!qs) return out;
    qs.replace(/^\?/, '').split('&').forEach(function (kv) {
      if (!kv) return;
      var i = kv.indexOf('=');
      var k = decodeURIComponent((i < 0 ? kv : kv.slice(0, i)).replace(/\+/g, ' '));
      var v = i < 0 ? '' : decodeURIComponent(kv.slice(i + 1).replace(/\+/g, ' '));
      if (k.slice(-2) === '[]') k = k.slice(0, -2);
      if (out.hasOwnProperty(k)) { if (!Array.isArray(out[k])) out[k] = [out[k]]; out[k].push(v); } else out[k] = v;
    });
    return out;
  }

  function parseBody(body) {
    if (body == null) return {};
    try {
      if (typeof body === 'string') {
        var s = body.trim();
        if (s.charAt(0) === '{' || s.charAt(0) === '[') { try { return JSON.parse(s); } catch (e) { /* fallthrough */ } }
        return parseQuery(s);
      }
      if (typeof FormData !== 'undefined' && body instanceof FormData) {
        var o = {};
        body.forEach(function (v, k) {
          var val = (typeof File !== 'undefined' && v instanceof File) ? { fileName: v.name, size: v.size } : v;
          if (o.hasOwnProperty(k)) { if (!Array.isArray(o[k])) o[k] = [o[k]]; o[k].push(val); } else o[k] = val;
        });
        return o;
      }
      if (typeof URLSearchParams !== 'undefined' && body instanceof URLSearchParams) return parseQuery(body.toString());
    } catch (e) { /* ignore */ }
    return {};
  }

  function toAbs(url) {
    try { return new URL(String(url), location.href); } catch (e) { return null; }
  }

  function compile(pattern) {
    if (pattern instanceof RegExp) return { re: pattern, keys: null };
    var keys = [];
    var src = String(pattern).replace(/[.+?^${}()|[\]\\]/g, '\\$&').replace(/\/:(\w+)/g, function (_, k) { keys.push(k); return '/([^/]+)'; }).replace(/\*/g, '.*');
    return { re: new RegExp('^' + src + '/?$'), keys: keys };
  }

  function addRoute(method, pattern, handler) {
    var c = compile(pattern);
    routes.push({ method: method, pattern: pattern, re: c.re, keys: c.keys, handler: handler });
  }

  function stripCtx(path) {
    if (CTX && (path === CTX || path.indexOf(CTX + '/') === 0)) return path.slice(CTX.length) || '/';
    return path;
  }

  function resolve(method, url) {
    var u = toAbs(url);
    if (!u) return null;
    if (u.protocol !== 'http:' && u.protocol !== 'https:') return null; // data:, blob: 등
    var sameOrigin = u.origin === location.origin;
    var rawPath = u.pathname;
    try { rawPath = decodeURI(rawPath); } catch (e) { /* keep */ }
    var path = stripCtx(rawPath);
    method = (method || 'GET').toUpperCase();

    if (sameOrigin) {
      for (var p = 0; p < PASSTHROUGH.length; p++) if (PASSTHROUGH[p] === path) return null;
    }
    for (var i = routes.length - 1; i >= 0; i--) { // 나중에 등록한 라우트가 우선
      var r = routes[i];
      if (r.method !== '*' && r.method !== method) continue;
      var m = path.match(r.re);
      if (!m) continue;
      var params = {};
      if (r.keys) r.keys.forEach(function (k, idx) { params[k] = decodeURIComponent(m[idx + 1]); });
      return { route: r, path: path, rawPath: rawPath, url: u, match: m, pathParams: params, method: method };
    }
    if (sameOrigin && STATIC_RE.test(rawPath)) return null;   // 정적 파일은 실제 서버에서
    if (!sameOrigin && STATIC_RE.test(rawPath) && !/\/api\//.test(rawPath)) return null; // 외부 CDN 등
    return { route: null, path: path, rawPath: rawPath, url: u, match: null, pathParams: {}, method: method };
  }

  function Res(status, body, contentType) { this.status = status; this.body = body; this.contentType = contentType; }

  // 핸들러 실행 → {status, text, contentType}
  function execute(hit, body) {
    var query = parseQuery(hit.url.search);
    var b = parseBody(body);
    var params = {};
    var k;
    for (k in query) params[k] = query[k];
    if (b && typeof b === 'object' && !Array.isArray(b)) for (k in b) params[k] = b[k];
    for (k in hit.pathParams) params[k] = hit.pathParams[k];
    var req = { method: hit.method, path: hit.path, url: hit.url.href, query: query, body: b, params: params, match: hit.match, raw: body };

    var out;
    if (!hit.route) {
      unhandled.push(hit.method + ' ' + hit.path);
      if (window.console) console.warn('[MOCK] 미등록 API → 기본 응답:', hit.method, hit.path, params);
      out = MOCK.fallback(req);
    } else {
      try { out = hit.route.handler(req); }
      catch (e) {
        if (window.console) console.error('[MOCK] 핸들러 오류', hit.method, hit.path, e);
        return { status: 500, text: JSON.stringify({ success: false, message: String(e) }), contentType: 'application/json' };
      }
    }
    if (out instanceof Res) {
      var t = typeof out.body === 'string' ? out.body : JSON.stringify(out.body);
      return { status: out.status, text: t, contentType: out.contentType || (typeof out.body === 'string' ? 'text/plain' : 'application/json') };
    }
    if (out === undefined) out = { success: true };
    if (typeof out === 'string') return { status: 200, text: out, contentType: 'text/plain;charset=UTF-8' };
    return { status: 200, text: JSON.stringify(out), contentType: 'application/json;charset=UTF-8' };
  }

  function latency() { return 40 + Math.floor(Math.random() * 120); }

  /* ───────────────────── XMLHttpRequest 대체 ───────────────────── */

  var RealXHR = window.XMLHttpRequest;
  var XHR_EVENTS = ['loadstart', 'progress', 'abort', 'error', 'load', 'timeout', 'loadend', 'readystatechange'];

  function MockXHR() {
    this.readyState = 0; this.status = 0; this.statusText = ''; this.responseText = ''; this.response = '';
    this.responseType = ''; this.responseURL = ''; this.responseXML = null; this.timeout = 0; this.withCredentials = false;
    this._ls = {}; this._real = null; this._hit = null; this._aborted = false; this._resHeaders = '';
    var self = this;
    this.upload = {
      addEventListener: function () {}, removeEventListener: function () {},
      onprogress: null, onload: null, onloadend: null, onerror: null
    };
    XHR_EVENTS.forEach(function (e) { self['on' + e] = null; });
  }
  MockXHR.UNSENT = 0; MockXHR.OPENED = 1; MockXHR.HEADERS_RECEIVED = 2; MockXHR.LOADING = 3; MockXHR.DONE = 4;
  MockXHR.prototype.UNSENT = 0; MockXHR.prototype.OPENED = 1; MockXHR.prototype.HEADERS_RECEIVED = 2; MockXHR.prototype.LOADING = 3; MockXHR.prototype.DONE = 4;

  MockXHR.prototype.addEventListener = function (type, fn) { (this._ls[type] = this._ls[type] || []).push(fn); };
  MockXHR.prototype.removeEventListener = function (type, fn) { var a = this._ls[type]; if (a) { var i = a.indexOf(fn); if (i >= 0) a.splice(i, 1); } };
  MockXHR.prototype.dispatchEvent = function (ev) { this._fire(ev.type, ev); return true; };
  MockXHR.prototype._fire = function (type, ev) {
    ev = ev || { type: type, target: this, currentTarget: this, lengthComputable: false, loaded: 0, total: 0 };
    try { if (typeof this['on' + type] === 'function') this['on' + type].call(this, ev); } catch (e) { setTimeout(function () { throw e; }); }
    var a = (this._ls[type] || []).slice();
    for (var i = 0; i < a.length; i++) { try { a[i].call(this, ev); } catch (e) { (function (er) { setTimeout(function () { throw er; }); })(e); } }
  };

  MockXHR.prototype.open = function (method, url, async) {
    this._method = (method || 'GET').toUpperCase();
    this._url = String(url);
    this._async = async !== false;
    this._hit = resolve(this._method, this._url);
    if (!this._hit) {
      var self = this, real = new RealXHR();
      this._real = real;
      var sync = function () {
        self.readyState = real.readyState;
        try { self.status = real.status; self.statusText = real.statusText; } catch (e) { /* ignore */ }
        try { self.responseURL = real.responseURL; } catch (e) { /* ignore */ }
        if (real.readyState === 4 || real.readyState === 3) {
          try { self.response = real.response; } catch (e) { /* ignore */ }
          if (!real.responseType || real.responseType === 'text') { try { self.responseText = real.responseText; } catch (e) { /* ignore */ } }
          try { self.responseXML = real.responseXML; } catch (e) { /* ignore */ }
        }
      };
      XHR_EVENTS.forEach(function (type) {
        real.addEventListener(type, function (ev) { sync(); self._fire(type, ev); });
      });
      real.open.apply(real, arguments);
      sync();
      return;
    }
    this._reqHeaders = {};
    this.readyState = 1;
    this._fire('readystatechange');
  };

  MockXHR.prototype.setRequestHeader = function (k, v) { if (this._real) return this._real.setRequestHeader(k, v); this._reqHeaders[k] = v; };
  MockXHR.prototype.overrideMimeType = function (m) { if (this._real) return this._real.overrideMimeType(m); };
  MockXHR.prototype.getResponseHeader = function (k) {
    if (this._real) return this._real.getResponseHeader(k);
    if (this.readyState < 2) return null;
    return String(k).toLowerCase() === 'content-type' ? this._ctype : null;
  };
  MockXHR.prototype.getAllResponseHeaders = function () {
    if (this._real) return this._real.getAllResponseHeaders();
    return this.readyState < 2 ? '' : 'content-type: ' + this._ctype + '\r\n';
  };
  MockXHR.prototype.abort = function () {
    if (this._real) return this._real.abort();
    this._aborted = true;
    if (this.readyState > 0 && this.readyState < 4) { this.readyState = 4; this.status = 0; this._fire('readystatechange'); this._fire('abort'); this._fire('loadend'); }
  };

  MockXHR.prototype.send = function (body) {
    if (this._real) {
      var r = this._real;
      try { if (this.responseType) r.responseType = this.responseType; } catch (e) { /* ignore */ }
      try { r.timeout = this.timeout; r.withCredentials = this.withCredentials; } catch (e) { /* ignore */ }
      return r.send(body);
    }
    var self = this;
    var run = function () {
      if (self._aborted) return;
      var res = execute(self._hit, body);
      self.status = res.status;
      self.statusText = res.status === 200 ? 'OK' : 'Error';
      self.responseURL = self._hit.url.href;
      self._ctype = res.contentType;
      self.readyState = 2; self._fire('readystatechange');
      self.readyState = 3; self._fire('readystatechange');
      var rt = self.responseType;
      if (rt === 'json') { try { self.response = JSON.parse(res.text); } catch (e) { self.response = null; } }
      else if (rt === 'blob') { self.response = new Blob([res.text], { type: res.contentType }); }
      else if (rt === 'arraybuffer') { self.response = new TextEncoder().encode(res.text).buffer; }
      else { self.responseText = res.text; self.response = res.text; }
      self.readyState = 4; self._fire('readystatechange');
      self._fire(res.status >= 200 && res.status < 400 ? 'load' : 'load');
      self._fire('loadend');
    };
    this._fire('loadstart');
    if (this._async) setTimeout(run, latency()); else run();
  };

  window.XMLHttpRequest = MockXHR;

  /* ───────────────────────── fetch 대체 ───────────────────────── */

  var realFetch = window.fetch ? window.fetch.bind(window) : null;
  if (realFetch) {
    window.fetch = function (input, init) {
      var url = typeof input === 'string' ? input : (input && input.url) || String(input);
      var method = (init && init.method) || (input && typeof input === 'object' && input.method) || 'GET';
      var hit = resolve(method, url);
      if (!hit) return realFetch(input, init);
      var body = init && init.body;
      return new Promise(function (resolveP) {
        setTimeout(function () {
          var res = execute(hit, body);
          var resp = new Response(res.text, { status: res.status, headers: { 'Content-Type': res.contentType } });
          try { Object.defineProperty(resp, 'url', { value: hit.url.href }); } catch (e) { /* ignore */ }
          resolveP(resp);
        }, latency());
      });
    };
  }

  // 데모 중 외부 서버로 새는 비콘 차단
  if (navigator.sendBeacon) navigator.sendBeacon = function () { return true; };

  /* ─────────────── 브라우저 세션 동안 유지되는 간이 테이블 ───────────────
   * 등록/수정/삭제 후 다시 조회하면 바뀐 내용이 보이도록 sessionStorage에 보관한다.
   *   var users = MOCK.db('users', function () { return [...초기행]; }, 'user_code');
   *   users.all(); users.insert(row); users.update(id, patch); users.remove(id); users.find(id)
   */
  function db(name, seedFn, key) {
    var sk = 'mockdb:' + (CFG.app || CTX) + ':' + name;
    key = key || 'id';
    var rows = null;
    function load() {
      if (rows) return rows;
      try { var s = sessionStorage.getItem(sk); if (s) rows = JSON.parse(s); } catch (e) { /* ignore */ }
      if (!rows) { rows = seedFn ? seedFn() : []; save(); }
      return rows;
    }
    function save() { try { sessionStorage.setItem(sk, JSON.stringify(rows)); } catch (e) { /* ignore */ } }
    function idx(id) { load(); for (var i = 0; i < rows.length; i++) if (String(rows[i][key]) === String(id)) return i; return -1; }
    return {
      key: key,
      all: function () { return load().slice(); },
      find: function (id) { var i = idx(id); return i < 0 ? null : rows[i]; },
      nextId: function () { var mx = 0; load().forEach(function (r) { var n = parseInt(r[key], 10); if (n > mx) mx = n; }); return mx + 1; },
      insert: function (row) { load(); if (row[key] == null || row[key] === '') row[key] = this.nextId(); rows.push(row); save(); return row; },
      upsert: function (row) { var i = idx(row[key]); if (i < 0 || row[key] == null || row[key] === '') return this.insert(row); for (var k in row) rows[i][k] = row[k]; save(); return rows[i]; },
      update: function (id, patch) { var i = idx(id); if (i < 0) return null; for (var k in patch) rows[i][k] = patch[k]; save(); return rows[i]; },
      remove: function (id) { var ids = Array.isArray(id) ? id : [id]; load(); rows = rows.filter(function (r) { return ids.map(String).indexOf(String(r[key])) < 0; }); save(); },
      reset: function () { rows = null; try { sessionStorage.removeItem(sk); } catch (e) { /* ignore */ } }
    };
  }

  /* ───────────────────────── 공개 API ───────────────────────── */

  var MOCK = {
    __core: true,
    ctx: CTX,
    app: CFG.app,
    routes: routes,
    unhandled: unhandled,
    get: function (p, h) { addRoute('GET', p, h); return MOCK; },
    post: function (p, h) { addRoute('POST', p, h); return MOCK; },
    put: function (p, h) { addRoute('PUT', p, h); return MOCK; },
    del: function (p, h) { addRoute('DELETE', p, h); return MOCK; },
    any: function (p, h) { addRoute('*', p, h); return MOCK; },
    res: function (status, body, contentType) { return new Res(status, body, contentType); },
    // 등록 안 된 API에 대한 기본 응답 — 저장/삭제류가 대부분이라 '성공'으로 돌려준다
    fallback: function () { return { success: true, result: 'success', status: 'success', code: 200, message: 'OK', data: [], list: [], rows: [] }; },
    resolve: resolve,

    // 유틸
    pad: pad, fmt: fmt, toDate: toDate, startOfDay: startOfDay, addDays: addDays, addMinutes: addMinutes,
    days: demoDays, inRange: inRange, hash: hash, rng: rng, wave: wave, round: round,
    parseQuery: parseQuery, db: db,
    today: function () { return fmt(new Date(), 'YYYY-MM-DD'); },
    now: function () { return new Date(); },
    // from~to 사이 날짜 문자열 배열 (데모 3일과 교집합). from/to 비면 3일 전체
    daysIn: function (from, to) {
      return demoDays().filter(function (d) { return inRange(d + ' 12:00:00', from ? fmt(startOfDay(from), 'YYYY-MM-DD') : null, to ? fmt(startOfDay(to), 'YYYY-MM-DD') : null); });
    }
  };
  window.MOCK = MOCK;
})();
