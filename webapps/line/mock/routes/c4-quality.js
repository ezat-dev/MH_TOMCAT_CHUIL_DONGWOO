/* routes/c4-quality.js — 품질관리 (Cpk/Ppk, F/PROOF, 온도균일성, 경도, 열전대 비교검증) + 낙하품/부적합품 */
(function () {
  var M = window.MOCK, D = M.D;
  if (!M || !D) return;

  /* ───────────────────────── 공통 유틸 ───────────────────────── */
  var PATH = location.pathname.replace(/^\/line/, '').replace(/\/$/, '');
  function onPage(re) { return re.test(PATH); }
  function hm(d) { return M.fmt(M.toDate(d), 'HH:mm'); }
  function r1(v) { return M.round(v, 1); }
  function f2(v) { return (Math.round(v * 100) / 100).toFixed(2); }
  function f3(v) { return (Math.round(v * 1000) / 1000).toFixed(3); }
  function ymOf(d) { return M.fmt(M.toDate(d), 'YYYY-MM'); }
  function daysInMonth(ym) { var a = ym.split('-'); return new Date(+a[0], +a[1], 0).getDate(); }
  function todayYM() { return ymOf(new Date()); }
  function prodBy(v) {
    if (!v) return null;
    v = String(v).trim();
    for (var i = 0; i < D.products.length; i++) {
      var p = D.products[i];
      if (p.part_no === v || p.prod_code === v || p.prod_name === v) return p;
    }
    return null;
  }
  function custOf(p) { return D.customer(p.cust_code).cust_name; }
  function doneLots(from, to) { return D.lotsIn(from, to).filter(function (l) { return l.status === '완료'; }); }
  function str(v) { return v == null ? '' : String(v); }
  function normCdf(z) { // Abramowitz-Stegun
    var t = 1 / (1 + 0.2316419 * Math.abs(z));
    var d = 0.3989423 * Math.exp(-z * z / 2);
    var p = d * t * (0.3193815 + t * (-0.3565638 + t * (1.781478 + t * (-1.821256 + t * 1.330274))));
    return z > 0 ? 1 - p : p;
  }

  // 소입(as-quenched) 경도 규격 — 재질별
  var QSPEC = { SCM440: [55, 61], SCM435: [52, 58], S45C: [52, 58], S53C: [56, 62], S48C: [53, 59], SCM420H: [60, 65] };
  function qSpec(p) { return QSPEC[p.material] || [54, 60]; }

  // 품목별 공정능력 목표 (대부분 1.33 이상, P1004·P1007 은 경계 수준)
  var CAP = {
    P1001: { cpk: 1.62, k: 0.08, s: 1 }, P1002: { cpk: 1.45, k: 0.12, s: -1 }, P1003: { cpk: 1.78, k: 0.05, s: 1 },
    P1004: { cpk: 1.15, k: 0.15, s: -1 }, P1005: { cpk: 1.52, k: 0.10, s: 1 }, P1006: { cpk: 1.78, k: 0.04, s: -1 },
    P1007: { cpk: 1.15, k: 0.12, s: 1 }, P1008: { cpk: 1.41, k: 0.09, s: -1 }, P1009: { cpk: 1.36, k: 0.11, s: 1 },
    P1010: { cpk: 1.67, k: 0.06, s: -1 }
  };
  function proc(p) {
    var c = CAP[p.prod_code] || { cpk: 1.5, k: 0.08, s: 1 };
    var half = (p.hrc_max - p.hrc_min) / 2, mid = (p.hrc_max + p.hrc_min) / 2;
    return { mid: mid, half: half, mean: mid + c.s * c.k * half, sw: half * (1 - c.k) / (3 * c.cpk) };
  }

  /* ───────────── 품번 검색 (여러 화면 공용) — 다른 화면은 기존 핸들러에 위임 ───────────── */
  var prevPumbun = null;
  (function () {
    for (var i = M.routes.length - 1; i >= 0; i--) {
      var r = M.routes[i];
      if ((r.method === 'POST' || r.method === '*') && r.re.test('/productionManagement/heatTreatment/pumbun/list')) { prevPumbun = r.handler; break; }
    }
  })();
  M.post('/productionManagement/heatTreatment/pumbun/list', function (req) {
    var mine = onPage(/^\/(quality\/(cpk|ppk)|productionManagement\/noProduct)$/);
    if (!mine && prevPumbun) return prevPumbun(req);
    var q = req.params, cpkPage = onPage(/^\/quality\/cpk$/);
    var rows = D.products.filter(function (p) {
      return (!q.item_no || p.part_no.indexOf(q.item_no) >= 0) &&
        (!q.item_name || p.prod_name.indexOf(q.item_name) >= 0) &&
        (!q.cust_name || custOf(p).indexOf(q.cust_name) >= 0);
    }).map(function (p) {
      var qs = qSpec(p);
      return {
        item_no: p.part_no, item_name: p.prod_name, cust_name: custOf(p), prod_code: p.prod_code, texture: p.material,
        temp_spec: 'HRC ' + p.hrc_min + '~' + p.hrc_max, temper_low: p.hrc_min, temper_high: p.hrc_max,
        // cpk 화면은 '상한' 칸에 quench_low, '하한' 칸에 quench_high 를 표시한다 → Cpk 기준(템퍼 경도)으로 맞춰 준다
        quench_low: cpkPage ? p.hrc_max : qs[0], quench_high: cpkPage ? p.hrc_min : qs[1],
        w_pnum: p.part_no, w_pname: p.prod_name, w_gang: p.material, w_t_gb: '', w_qf: p.q_temp, w_tf: p.t_temp,
        w_cp: 0.45, w_std_weight: 380, w_hardness: 'HRC ' + p.hrc_min + '~' + p.hrc_max
      };
    });
    return { last_page: 1, data: rows };
  });

  /* ───────────────────────── Cpk 분석 ───────────────────────── */
  // 품목·기간의 군(subgroup) 데이터: 완료 LOT 마다 15분 간격 최대 5군 × n=3
  function cpkSubgroups(p, from, to) {
    var pr = proc(p), out = []; pr.sw *= 1.12; // R/d2 추정이 군내 변동만 보므로 보정
    doneLots(from, to).filter(function (l) { return l.prod_code === p.prod_code; }).forEach(function (l) {
      var r = M.rng('cpk|' + l.lot_no);
      var lotShift = 0.3 * ((l.hardness || pr.mid) - pr.mid) + r.normal(0, pr.sw * 0.25);
      var st = M.toDate(l.start_time), en = M.toDate(l.end_time);
      var cnt = Math.max(2, Math.min(5, Math.floor((en - st) / 60000 / 18)));
      for (var g = 0; g < cnt; g++) {
        var t = M.addMinutes(st, 15 + g * 16);
        var xs = [r.normal(pr.mean + lotShift, pr.sw, 1), r.normal(pr.mean + lotShift, pr.sw, 1), r.normal(pr.mean + lotShift, pr.sw, 1)];
        var avg = (xs[0] + xs[1] + xs[2]) / 3;
        out.push({
          h_day: M.fmt(t, 'YYYY-MM-DD'), h_time: hm(t), h_lot: l.lot_no,
          h_x1: xs[0], h_x2: xs[1], h_x3: xs[2], h_avg: M.round(avg, 2),
          h_range: M.round(Math.max.apply(null, xs) - Math.min.apply(null, xs), 1)
        });
      }
    });
    return out;
  }
  function bestCpkProduct() {
    var cnt = {};
    doneLots().forEach(function (l) { cnt[l.prod_code] = (cnt[l.prod_code] || 0) + 1; });
    var best = D.products[0], mx = -1;
    D.products.forEach(function (p) { if ((cnt[p.prod_code] || 0) > mx) { mx = cnt[p.prod_code] || 0; best = p; } });
    return best;
  }
  M.post('/quality/cpk/standard/list', function (req) {
    var q = req.params;
    var p = prodBy(q.h_pnum) || bestCpkProduct();
    var std = [{ h_pnum: p.part_no, h_pname: p.prod_name, h_gang: p.material + ' / HRC ' + p.hrc_min + '~' + p.hrc_max, h_t_gb: '380 kg/h', h_hard_up: p.hrc_max, h_hard_dw: p.hrc_min }];
    var sg = cpkSubgroups(p, q.h_sdate, q.h_edate);
    var n = 3, d2 = 1.693, a2 = 1.023, d4 = 2.574;
    var calc = { n: n, d2: d2, a2: a2, d4: d4, ucl_x: '-', cl_x: '-', lcl_x: '-', ucl_r: '-', cl_r: '-', lcl_r: '-', r_d2: '-', cp: '-', k: '-', cpk: '-' };
    var trend = [];
    if (sg.length) {
      var xbb = sg.reduce(function (a, s) { return a + s.h_avg; }, 0) / sg.length;
      var rb = sg.reduce(function (a, s) { return a + s.h_range; }, 0) / sg.length;
      var sigma = rb / d2, U = p.hrc_max, L = p.hrc_min;
      var cp = (U - L) / (6 * sigma), k = Math.abs((U + L) / 2 - xbb) / ((U - L) / 2);
      calc.ucl_x = f2(xbb + a2 * rb); calc.cl_x = f2(xbb); calc.lcl_x = f2(xbb - a2 * rb);
      calc.ucl_r = f2(d4 * rb); calc.cl_r = f2(rb);
      calc.r_d2 = f3(sigma); calc.cp = f3(cp); calc.k = f3(k); calc.cpk = f3((1 - k) * cp);
      sg.forEach(function (s) {
        trend.push({ g_avg: s.h_avg, g_range: s.h_range, g_ucl_x: +calc.ucl_x, g_cl_x: +calc.cl_x, g_lcl_x: +calc.lcl_x, g_ucl_r: +calc.ucl_r, g_cl_r: +calc.cl_r, g_max: U, g_min: L });
      });
    }
    return { standardData: std, cpkValueData: sg, cpkValueCalcData: calc, trendData: trend };
  });

  /* ───────────────────────── Ppk 분석 ───────────────────────── */
  var ppkOv = M.db('c4-ppk-override', function () { return []; }, 'p_cnt');
  function ppkStudies(year) {
    year = +year || new Date().getFullYear();
    var now = new Date(), cy = now.getFullYear(), out = [];
    if (year > cy) return out;
    var lastM = year === cy ? now.getMonth() + 1 : 12;
    var recent = [];
    var cnt = {};
    doneLots().forEach(function (l) { cnt[l.prod_code] = (cnt[l.prod_code] || 0) + 1; });
    recent = D.products.slice().sort(function (a, b) { return (cnt[b.prod_code] || 0) - (cnt[a.prod_code] || 0); });
    var days = M.days();
    for (var m = lastM; m >= 1; m--) {
      var ym = year + '-' + M.pad(m);
      var r = M.rng('ppk|' + ym);
      var picks = ym === todayYM() ? recent.slice(0, 4) : r.shuffle(D.products).slice(0, 3);
      picks.forEach(function (p, i) {
        var md = days.filter(function (d) { return d.slice(0, 7) === ym; });
        var chk = md.length ? md[i % md.length] : ym + '-' + M.pad(r.int(18, 28));
        var w = r.pick([D.workers[3], D.workers[6]]);
        out.push({ p_cnt: year * 1000 + m * 10 + i, p_ymon: ym, prod: p, p_chkdate: chk, p_user_name: w.user_name, p_user_code: w.user_code });
      });
    }
    return out;
  }
  function ppkValues(st) {
    var p = st.prod, pr = proc(p), r = M.rng('ppkv|' + st.p_cnt);
    var shift = r.normal(0, pr.sw * 0.12), so = pr.sw * r.float(1.0, 1.07), vals = [];
    for (var i = 0; i < 100; i++) vals.push(r1(r.normal(pr.mean + shift, so)));
    return vals;
  }
  function ppkStats(vals, U, L) {
    var v = vals.filter(function (x) { return x !== 0 && x !== '' && x != null && !isNaN(+x); }).map(Number);
    if (!v.length) return null;
    var avg = v.reduce(function (a, b) { return a + b; }, 0) / v.length;
    var sd = Math.sqrt(v.reduce(function (a, b) { return a + (b - avg) * (b - avg); }, 0) / Math.max(1, v.length - 1)) || 0.001;
    var ppu = (U - avg) / (3 * sd), ppl = (avg - L) / (3 * sd);
    var ppm = Math.round(((1 - normCdf((U - avg) / sd)) + normCdf((L - avg) / sd)) * 1e6);
    return { v: v, n: v.length, min: Math.min.apply(null, v), max: Math.max.apply(null, v), avg: avg, sd: sd, pp: (U - L) / (6 * sd), ppu: ppu, ppl: ppl, ppk: Math.min(ppu, ppl), ppm: ppm };
  }
  function ppkFull(st) {
    var ov = ppkOv.find(st.p_cnt), p = st.prod;
    var row = {
      p_cnt: st.p_cnt, p_ymon: st.p_ymon, p_pno: '표면경도', p_pname: p.prod_name, p_pnum: p.part_no, cust_name: custOf(p),
      p_user_name: st.p_user_name, p_user_code: st.p_user_code, p_chkdate: st.p_chkdate, p_sampling: 100,
      p_item: '로크웰 C', p_measure: '로크웰경도계 HR-150A', p_unit: 'HRC', p_spec: 'HRC ' + p.hrc_min + '~' + p.hrc_max,
      p_upp: String(p.hrc_max), p_low: String(p.hrc_min), vals: ppkValues(st)
    };
    if (ov) for (var k in ov) if (k !== 'p_cnt') row[k] = ov[k];
    var s = ppkStats(row.vals, +row.p_upp, +row.p_low);
    row.p_m_ppk = s ? f2(s.ppk) : '';
    row.stats = s;
    return row;
  }
  M.post('/quality/ppk/allList', function (req) {
    return { data: ppkStudies(req.params.p_year).map(function (st) {
      var r = ppkFull(st), o = {};
      ['p_cnt', 'p_ymon', 'p_pname', 'p_pnum', 'cust_name', 'p_m_ppk', 'p_chkdate', 'p_user_name', 'p_upp', 'p_low'].forEach(function (k) { o[k] = r[k]; });
      return o;
    }) };
  });
  function findStudy(cnt) {
    cnt = +cnt;
    var st = ppkStudies(Math.floor(cnt / 1000));
    for (var i = 0; i < st.length; i++) if (st[i].p_cnt === cnt) return st[i];
    return st[0] || ppkStudies(new Date().getFullYear())[0];
  }
  M.post('/quality/ppk/detailList', function (req) {
    var row = ppkFull(findStudy(req.params.p_cnt));
    var U = +row.p_upp, L = +row.p_low, s = row.stats;
    var top = [{
      p_ymon: row.p_ymon, p_pno: row.p_pno, p_pname: row.p_pname, p_pnum: row.p_pnum, p_user_name: row.p_user_name, p_user_code: row.p_user_code,
      p_chkdate: row.p_chkdate, p_sampling: row.p_sampling, p_item: row.p_item, p_measure: row.p_measure, p_unit: row.p_unit,
      p_spec: row.p_spec, p_upp: row.p_upp, p_low: row.p_low, p_type: 'A / Both'
    }];
    var mid = [];
    for (var g = 0; g < 10; g++) {
      var o = { p_cnt: row.p_cnt, p_t_gb: (g * 10 + 1 < 10 ? '0' : '') + (g * 10 + 1) + '~' + (g * 10 + 10) };
      for (var j = 1; j <= 10; j++) { var v = row.vals[g * 10 + j - 1]; o['p_t_val' + M.pad(j)] = v == null || v === 0 ? '' : v; }
      mid.push(o);
    }
    var btm = s ? [{ p_min: s.min.toFixed(1), p_max: s.max.toFixed(1), p_avg: f2(s.avg), p_dev: f3(s.sd), p_total_ppm: s.ppm + 'ppm', p_pp: f2(s.pp), p_ppu: f2(s.ppu), p_ppl: f2(s.ppl), p_ppk: f2(s.ppk) }] : [];
    var midV = ((U + L) / 2).toFixed(1);
    var run = row.vals.map(function (v, i) { return { p_upp: row.p_upp, p_low: row.p_low, p_diff: midV, p_val: v ? String(v) : null, p_xval: i }; });
    // 히스토그램 (원본 PpkGraph 와 같은 241 격자: 하한=60번, 상한=160번)
    var hist = [];
    if (s) {
      var dif = (U - L) / 100, gx = [], freq = [], i, k;
      for (i = 0; i < 241; i++) gx.push(M.round(L + (i - 60) * dif, 3));
      for (i = 0; i < 241; i++) {
        freq[i] = s.v.filter(function (x) { return i === 0 ? x < gx[0] : (x < gx[i] && x >= gx[i - 1]); }).length;
      }
      var fs = [];
      for (k = 0; k < 24; k++) { var c = 0; for (i = k * 10; i < k * 10 + 10; i++) c += freq[i]; fs.push(c); }
      var K = [], Lr = [], H = [], N = [], J = [], I = [];
      for (i = 0; i < 241; i++) {
        var m20 = i % 20, q = Math.floor(i / 20);
        K[i] = m20 <= 10 ? fs[2 * q] : (m20 === 0 ? fs[2 * q] : 0);
        Lr[i] = m20 >= 10 ? fs[2 * q + 1] : (m20 === 0 && q > 0 ? fs[2 * q - 1] : 0);
        if (K[i] == null) K[i] = 0; if (Lr[i] == null) Lr[i] = 0;
        H[i] = i % 10 === 0 ? Math.max(K[i] || 0, Lr[i] || 0) : 0;
        N[i] = Math.exp(-Math.pow(gx[i] - s.avg, 2) / (2 * s.sd * s.sd)) / (s.sd * Math.sqrt(2 * Math.PI));
      }
      var nSum = N.reduce(function (a, b2) { return a + b2; }, 0) || 1;
      var jMax = 0, hMax = Math.max.apply(null, H);
      for (i = 0; i < 241; i++) { J[i] = M.round(N[i] * (s.n * 10 / nSum), 3); if (J[i] > jMax) jMax = J[i]; }
      var iv = Math.round(Math.max(hMax, jMax) * 1.4);
      for (i = 0; i < 241; i++) I[i] = (i === 60 || i === 110 || i === 160) ? iv : 0;
      for (i = 0; i < 241; i++) hist.push({ p_xval2: gx[i], p_k_val: K[i] || 0, p_l_val: Lr[i] || 0, p_j_val: J[i], p_i_val: I[i], p_h_val: H[i], p_n_val: M.round(N[i], 4) });
    }
    return { topData: top, midData: mid, btmData: btm, runChart: run, historyChart: hist };
  });
  M.post('/quality/ppk/save', function (req) {
    var b = req.params, cnt = +b.p_cnt;
    if (!cnt) return { data: 0 };
    var vals = [];
    for (var i = 1; i <= 100; i++) { var v = b['p_val' + i]; vals.push(v === '' || v == null ? 0 : +v); }
    var patch = { p_cnt: cnt, vals: vals };
    if (b.p_user_code) { patch.p_user_code = b.p_user_code; var w = D.workers.filter(function (x) { return String(x.user_code) === String(b.p_user_code); })[0]; if (w) patch.p_user_name = w.user_name; }
    var p = prodBy(b.p_pnum);
    if (p) { patch.p_pnum = p.part_no; patch.p_pname = p.prod_name; patch.p_upp = String(p.hrc_max); patch.p_low = String(p.hrc_min); patch.p_spec = 'HRC ' + p.hrc_min + '~' + p.hrc_max; patch.cust_name = custOf(p); }
    ppkOv.upsert(patch);
    return { data: 1 };
  });
  M.post('/quality/ppk/userList', function () {
    return { last_page: 1, data: D.workers.map(function (w) { return { user_code: w.user_code, user_id: w.user_id, user_name: w.user_name, user_busu: w.dept, user_jick: w.position }; }) };
  });

  /* ───────────────────────── F/PROOF ───────────────────────── */
  var FP_ITEMS = [
    ['소입로', '860±10℃', '온도 상한 경보', 'FP-01_소입로_온도상한경보.pdf', '라인 정지 → 설비팀 연락, 해당 LOT 격리'],
    ['소입로', '860±10℃', '온도 하한 경보', 'FP-02_소입로_온도하한경보.pdf', '투입 중지, 승온 후 재투입'],
    ['소려로', '450±10℃', '온도 편차 경보', 'FP-03_소려로_온도편차경보.pdf', '조절계 점검, 해당 LOT 경도 전수검사'],
    ['유조', '60~80℃', '소입유 온도 상한 인터록', 'FP-04_유조_유온인터록.pdf', '냉각기 가동 확인, 투입 중지'],
    ['유조', '교반기 가동', '교반 정지 시 투입 인터록', 'FP-05_유조_교반기인터록.pdf', '교반기 복구 전 투입 금지'],
    ['메쉬벨트', '사행 ±20mm', '사행 감지 센서 동작', 'FP-06_메쉬벨트_사행감지.pdf', '벨트 조정 후 재가동'],
    ['RX가스발생기', '15 Nm³/h 이상', 'RX가스 유량 저하 경보', 'FP-07_RX가스_유량경보.pdf', 'N₂ 퍼지 전환, 설비팀 연락'],
    ['투입부', '400kg/h 이하', '과적재 로드셀 경보', 'FP-08_투입부_과적재경보.pdf', '장입량 재조정 후 투입'],
    ['세척 1호기', '액온 50℃ 이상', '액온 저하 인터록', 'FP-09_세척기_액온인터록.pdf', '히터 점검, 승온 후 가동'],
    ['방청기', '농도 5~8%', '방청액 농도 이탈 경보', 'FP-10_방청기_농도경보.pdf', '방청액 보충·교체'],
    ['공통', '비상정지', '비상정지 버튼 동작 확인', 'FP-11_비상정지_동작확인.pdf', '버튼·릴레이 교체'],
    ['소입로', 'TC 단선 검출', '열전대 단선 경보', 'FP-12_열전대_단선경보.pdf', '예비 TC 전환, 열전대 교체']
  ];
  function fpDb(ym) {
    ym = (ym || todayYM()).replace('/', '-');
    return M.db('c4-fproof:' + ym, function () {
      var now = new Date(), cur = todayYM(), last;
      if (ym > cur) last = 0; else if (ym === cur) last = now.getDate(); else last = daysInMonth(ym);
      var r = M.rng('fp|' + ym), ngRow = r.int(0, FP_ITEMS.length - 1), ngDay = last > 6 ? r.int(3, last - 2) : -1;
      return FP_ITEMS.map(function (it, i) {
        var row = { id: (+ym.replace('-', '')) * 100 + i + 1, y_m: ym.replace('-', '/'), mch_name: it[0], standard: it[1], up_down: it[2], img_url: it[3], memo_f: it[4] };
        for (var d = 1; d <= 31; d++) row['m_' + d] = d <= last ? (i === ngRow && d === ngDay ? 'NG' : 'OK') : '';
        if (i === ngRow && ngDay > 0) row.memo_f = it[4] + ' (' + ngDay + '일 NG → 센서 교체 후 재점검 OK)';
        return row;
      });
    }, 'id');
  }
  M.post('/quality/fProof/list', function (req) { return fpDb(req.params.y_m).all(); });
  M.post('/quality/fProof/save', function (req) {
    var b = req.params, ym = String(b.id).slice(0, 6), t = fpDb(ym.slice(0, 4) + '-' + ym.slice(4, 6)), p = {};
    p[b.column] = b.value; t.update(b.id, p);
    return { result: 'success' };
  });
  M.post('/quality/fProof/insert', function (req) {
    var ym = (req.params.y_m || todayYM()).replace('/', '-'), t = fpDb(ym), rows = t.all(), mx = 0;
    rows.forEach(function (r) { if (r.id > mx) mx = r.id; });
    t.insert({ id: mx ? mx + 1 : (+ym.replace('-', '')) * 100 + 1, y_m: ym.replace('-', '/'), mch_name: '', standard: '', up_down: '', img_url: '', memo_f: '' });
    return { result: 'success' };
  });
  M.post('/quality/fProof/del', function (req) {
    var id = String(req.params.id || ''); if (!id) return { data: '행 선택하세요' };
    fpDb(id.slice(0, 4) + '-' + id.slice(4, 6)).remove(req.params.id);
    return { data: 'success' };
  });
  M.post('/quality/fProof/uploadImage', function (req) {
    var f = req.params.file, name = (f && f.fileName) || 'upload.pdf', id = String(req.params.cnt || '');
    if (id) fpDb(id.slice(0, 4) + '-' + id.slice(4, 6)).update(id, { img_url: name });
    return { result: 'success', fileName: name };
  });

  /* ─────────────────────── 온도균일성 (TUS) ─────────────────────── */
  function tusSeed() {
    var now = new Date(), cy = now.getFullYear(), out = [], id = 1, days = M.days();
    for (var y = cy - 2; y <= cy; y++) {
      [1, 4, 7, 10].forEach(function (m) {
        var r = M.rng('tus|' + y + m);
        [['소입로', 860], ['소려로', 450]].forEach(function (f, fi) {
          var day = r.int(8, 26), dt = new Date(y, m - 1, day);
          if (y === cy && m === 10) { dt = M.toDate(days[0]); day = dt.getDate(); m = dt.getMonth() + 1; }
          if (dt > now) return;
          var hi = r.float(1.8, 4.6, 1), lo = -r.float(1.5, 4.2, 1), fail = (y === cy && m === 4 && fi === 1);
          if (fail) hi = 11.4;
          var base = { mch_name: '소려로 소입로', furnace: f[0], sv: f[1], t_year: String(y), t_month: M.pad(m), t_day: M.pad(day),
            t_url: 'TUS_' + y + M.pad(m) + '_' + f[0] + '.pdf', seed: y + '-' + m + '-' + f[0] };
          out.push(Object.assign({ id: id++, t_gb: fail ? '불합격' : '합격',
            t_ok: f[0] + ' ' + f[1] + '℃ · 9점 · 최대편차 +' + hi.toFixed(1) + ' / ' + lo.toFixed(1) + '℃ (허용 ±10℃)' + (fail ? ' → 4존 히터 교체 후 재측정' : ''), hi: hi, lo: lo }, base));
          if (fail) {
            out.push(Object.assign({}, base, { id: id++, t_day: M.pad(Math.min(day + 3, 28)), t_url: 'TUS_' + y + M.pad(m) + '_' + f[0] + '_재측정.pdf', t_gb: '합격',
              t_ok: f[0] + ' ' + f[1] + '℃ · 9점 · 최대편차 +3.1 / -2.6℃ (재측정)', hi: 3.1, lo: -2.6, seed: base.seed + 'R' }));
          }
        });
      });
    }
    return out;
  }
  var tusDb = M.db('c4-tus', tusSeed, 'id');
  M.post('/quality/tusTest/list', function (req) {
    var y = str(req.params.t_year);
    return tusDb.all().filter(function (r) { return !y || r.t_year === y; })
      .sort(function (a, b) { return (b.t_year + b.t_month + b.t_day).localeCompare(a.t_year + a.t_month + a.t_day); });
  });
  M.post('/quality/tusTest/insert', function (req) {
    var b = req.params, row = {};
    ['mch_name', 't_year', 't_month', 't_day', 't_gb', 't_url', 't_ok'].forEach(function (k) { if (b[k] != null) row[k] = b[k]; });
    if (b.uploadFile && b.uploadFile.fileName) row.t_url = b.uploadFile.fileName;
    if (row.t_month && row.t_month.length >= 4) { row.t_year = row.t_month.slice(0, 4); row.t_month = row.t_month.slice(5, 7) || row.t_month; }
    if (b.id) { row.id = +b.id; tusDb.upsert(row); } else tusDb.insert(row);
    return { result: 'success' };
  });
  M.post('/quality/tusTest/del', function (req) { if (!req.params.id) return { data: '행 선택하세요' }; tusDb.remove(req.params.id); return { data: 'success' }; });
  M.post('/quality/tusTest/excel', function () { return { result: 'success' }; });

  function tusReportHtml(row) {
    var sv = row.sv || (/소려/.test(row.t_ok || '') ? 450 : 860), fur = row.furnace || (sv === 450 ? '소려로' : '소입로');
    var r = M.rng('tusrep|' + (row.seed || row.id)), hi = row.hi != null ? row.hi : 3.5, lo = row.lo != null ? row.lo : -3;
    var pts = ['TC1 전-좌-상', 'TC2 전-우-상', 'TC3 후-좌-상', 'TC4 후-우-상', 'TC5 중앙', 'TC6 전-좌-하', 'TC7 전-우-하', 'TC8 후-좌-하', 'TC9 후-우-하'];
    var off = pts.map(function () { return r.float(lo * 0.7, hi * 0.7); });
    off[r.int(0, 8)] = hi - 0.4; off[r.int(0, 8)] = lo + 0.4;
    var times = [], t0 = M.toDate(row.t_year + '-' + row.t_month + '-' + row.t_day + ' 10:00:00');
    for (var i = 0; i <= 30; i += 5) times.push(i);
    var mx = -99, mn = 99;
    var body = pts.map(function (p, pi) {
      var cells = times.map(function (tm, ti) {
        var v = sv + off[pi] + (ti === times.length - 1 && pi === 0 ? 0.4 : 0) + r.float(-0.4, 0.4);
        var d = v - sv; if (d > mx) mx = d; if (d < mn) mn = d;
        return '<td>' + v.toFixed(1) + '</td>';
      }).join('');
      return '<tr><th style="text-align:left">' + p + '</th>' + cells + '</tr>';
    }).join('');
    var ok = row.t_gb !== '불합격';
    return '<div style="font:13px \'Noto Sans KR\',sans-serif;color:#1e293b">' +
      '<h2 style="margin:0 0 4px">온도균일성조사(TUS) 보고서</h2>' +
      '<div style="color:#64748b;margin-bottom:12px">' + D.company + ' · 연속열처리로 ' + fur + ' · 문서 ' + (row.t_url || '') + '</div>' +
      '<table style="border-collapse:collapse;margin-bottom:12px" border="1" cellpadding="5">' +
      '<tr><th>측정일</th><td>' + row.t_year + '-' + row.t_month + '-' + row.t_day + '</td><th>설정온도</th><td>' + sv + '℃</td><th>허용편차</th><td>±10℃</td></tr>' +
      '<tr><th>측정점</th><td>9점 (작업영역 8코너 + 중앙)</td><th>열전대</th><td>K-type Ø1.6 시스형</td><th>기록계</th><td>Yokogawa GP10 (교정 2026-03)</td></tr>' +
      '<tr><th>측정방법</th><td colspan="5">설정온도 도달 후 안정화 30분, 5분 간격 7회 기록 · 측정자 ' + D.workers[4].user_name + ' / 확인 ' + D.workers[3].user_name + '</td></tr></table>' +
      '<table style="border-collapse:collapse;text-align:center;width:100%" border="1" cellpadding="4"><tr style="background:#f1f5f9"><th>측정점 \\ 경과(분)</th>' +
      times.map(function (t) { return '<th>' + t + '</th>'; }).join('') + '</tr>' + body + '</table>' +
      '<div style="margin-top:12px;font-size:14px">최대편차 <b style="color:#dc2626">+' + mx.toFixed(1) + '℃</b> / <b style="color:#2563eb">' + mn.toFixed(1) + '℃</b> · 균일도 ' + (mx - mn).toFixed(1) + '℃ · 판정 ' +
      '<b style="padding:2px 10px;border-radius:10px;color:#fff;background:' + (ok ? '#16a34a' : '#dc2626') + '">' + (row.t_gb || '합격') + '</b></div>' +
      '<div style="margin-top:6px;color:#64748b">' + (row.t_ok || '') + '</div></div>';
  }
  function showOverlay(html, w) {
    var ov = document.getElementById('c4-overlay');
    if (!ov) {
      ov = document.createElement('div'); ov.id = 'c4-overlay';
      ov.style.cssText = 'position:fixed;inset:0;background:rgba(15,23,42,.55);z-index:99999;display:flex;align-items:center;justify-content:center';
      ov.addEventListener('click', function (e) { if (e.target === ov || e.target.className === 'c4-x') ov.remove(); });
      document.body.appendChild(ov);
    }
    ov.innerHTML = '<div style="background:#fff;border-radius:10px;padding:22px 26px;max-width:' + (w || 980) + 'px;width:94%;max-height:90vh;overflow:auto;position:relative;box-shadow:0 20px 50px rgba(0,0,0,.3)">' +
      '<button class="c4-x" style="position:absolute;top:10px;right:12px;border:none;background:#f1f5f9;border-radius:6px;width:30px;height:30px;cursor:pointer">✕</button>' + html + '</div>';
  }

  /* ───────────────────────── 경도 관리 ───────────────────────── */
  var hardOv = M.db('c4-hardness-override', function () { return []; }, 'idx');
  function hardnessRows(from, to, lotNo) {
    var lots = D.lots().filter(function (l) { return l.status !== '대기'; });
    if (lotNo) lots = lots.filter(function (l) { return l.lot_no === lotNo; });
    else lots = lots.filter(function (l) { return M.inRange(l.start_time, from, to); });
    var out = [];
    lots.forEach(function (l) {
      var p = D.product(l.prod_code), pr = proc(p), qs = qSpec(p), r = M.rng('hard|' + l.lot_no);
      var common = { w_ci_lot: l.lot_no, cust_name: l.cust_name, item_name: p.prod_name, item_no: p.part_no, spec: 'HRC ' + p.hrc_min + '~' + p.hrc_max,
        texture: p.material, w_plan_cnt: l.qty, quench_low: qs[0], quench_high: qs[1], temper_low: p.hrc_min, temper_high: p.hrc_max };
      var qT = M.addMinutes(l.start_time, Math.round(p.cycle_min * 0.55));
      if (qT > new Date()) return;
      var q = Object.assign({ idx: l.idx * 2 - 1, q_or_tp: 'Quenching 경도', regtime: M.fmt(qT) }, common);
      var qc = (qs[0] + qs[1]) / 2 + r.normal(0.3, 0.4), qsd = (qs[1] - qs[0]) / 12;
      for (var i = 1; i <= 20; i++) q['h_val' + i] = r1(r.normal(qc, qsd));
      out.push(q);
      if (l.status !== '완료') return;
      var t = Object.assign({ idx: l.idx * 2, q_or_tp: 'Tempering 경도', regtime: M.fmt(M.addMinutes(l.end_time, 12)) }, common);
      var tc = l.hardness != null ? l.hardness : pr.mean;
      for (i = 1; i <= 20; i++) t['h_val' + i] = r1(r.normal(tc + (i > 15 ? 0.1 : 0), pr.sw));
      if (p.prod_code === 'P1007') for (i = 26; i <= 30; i++) t['h_val' + i + '_s'] = 'OK';
      t.img_url_3 = l.lot_no + '_T1.jpg'; t.img_url_4 = l.lot_no + '_T2.jpg'; t.img_url_5 = l.lot_no + '_T3.jpg';
      out.push(t);
    });
    return out.map(function (row) { var ov = hardOv.find(row.idx); if (ov) for (var k in ov) row[k] = ov[k]; return row; });
  }
  M.post('/quality/hardness/list', function (req) {
    var q = req.params;
    return { status: 'success', data: hardnessRows(q.m_sdate, q.m_edate, q.w_ci_lot) };
  });
  M.post('/quality/hardness/update', function (req) {
    var b = req.params;
    if (!(+b.idx > 0)) return { status: 'error', message: '수정할 idx가 없습니다.' };
    var patch = { idx: +b.idx };
    for (var k in b) if (/^h_val\d+(_s)?$/.test(k) || k === 'pass_yn') patch[k] = b[k];
    hardOv.upsert(patch);
    return { status: 'success' };
  });

  /* ───────────────────────── 낙하품 관리 ───────────────────────── */
  var dropOv = M.db('c4-dropped-override', function () { return []; }, 'w_ci_lot');
  var DROP_NOTES = [
    ['d_tf', '소입유조 바닥 낙하품 2EA 회수 → 경도 재측정 합격, 본 LOT 합류'],
    ['d_qf', '전세정기 바스켓 하부 낙하 1EA → 외관 찍힘으로 폐기'],
    ['d_out', '중간세정기 체인 사이 낙하 3EA 회수 → 재소려 후 합류'],
    ['d_in', '투입 컨베이어 측면 낙하 1EA → 재투입']
  ];
  M.post('/productionManagement/droppedGoods/getDroppedGoodsList', function (req) {
    var day = str(req.params.w_date).slice(0, 10) || M.today(), now = new Date();
    var lots = D.lots().filter(function (l) { return l.status !== '대기' && l.work_date === day; });
    var data = lots.map(function (l) {
      var p = D.product(l.prod_code), r = M.rng('drop|' + l.lot_no), st = M.toDate(l.start_time), en = M.toDate(l.plan_end_time), dur = (en - st) / 60000;
      var row = { w_ci_lot: l.lot_no, w_sdatetime: M.fmt(st, 'YYYY-MM-DD HH:mm'), w_edatetime: l.end_time, cust_name: l.cust_name, prod_code: p.part_no, item_no: p.part_no, item_name: p.prod_name, w_date: l.work_date, d_bigo: '' };
      var stages = [['d_in', 4], ['d_qf', 14], ['d_tf', dur * 0.58], ['d_out', dur * 0.72], ['d_new', dur - 4]];
      var hit = r.chance(0.14) ? r.pick(DROP_NOTES) : null, last = null;
      stages.forEach(function (s) {
        var t = M.addMinutes(st, Math.round(s[1] + r.int(0, 4)));
        if (t > now) { row[s[0]] = ''; row[s[0] + '_time'] = ''; return; }
        row[s[0]] = hit && hit[0] === s[0] ? 'O' : 'X'; row[s[0] + '_time'] = hm(t); last = t;
      });
      if (hit && row[hit[0]] === 'O') row.d_bigo = hit[1];
      row.d_name = last ? D.shiftWorker(M.fmt(last, 'YYYY-MM-DD'), last.getHours()) : '';
      var ov = dropOv.find(l.lot_no); if (ov) for (var k in ov) row[k] = ov[k];
      return row;
    });
    return { last_page: 1, data: data };
  });
  M.post('/productionManagement/droppedGoods/updateDroppedGoods', function (req) {
    var b = req.params; if (!b.d_lot || !b.column) return { result: 'fail', message: 'LOT 정보가 없습니다.' };
    var patch = { w_ci_lot: b.d_lot }; patch[b.column] = b.value;
    if (/^d_(in|qf|tf|out|new)$/.test(b.column)) patch[b.column + '_time'] = hm(new Date());
    dropOv.upsert(patch);
    return { result: 'success' };
  });

  /* ───────────────────────── 부적합품 관리 ───────────────────────── */
  var NC_TYPES = [
    { way: '크랙', cause: '소입 냉각 시 단면 급변부 응력 집중 (형상 R부)', after: '자분탐상 전수검사 → 크랙품 폐기', bigo: '폐기' },
    { way: '찍힘', cause: '바스켓 이송 중 제품 간 충돌', after: '외관 선별 → 경미품 사상 재작업', bigo: '재작업' },
    { way: '경도미달', cause: '소입유 온도 상승(82℃)으로 냉각능 저하', after: '재소입·재소려 재작업 후 경도 재측정 합격', bigo: '재작업' },
    { way: '변형', cause: '장입 적재 높이 과다로 고온 처짐 발생', after: '프레스 교정 후 진직도 0.05 이내 확인', bigo: '재작업' },
    { way: '이종혼입', cause: '이전 LOT 잔류품 투입부 혼입', after: '전수 재질 선별(스파크) → 이종품 분리 반납', bigo: '선별' },
    { way: '녹 발생', cause: '방청액 농도 저하(3.8%)', after: '재세척·재방청, 방청액 농도 6% 보정', bigo: '재작업' },
    { way: '액고임', cause: '막힌 홀 내부 세척액 잔류', after: '에어 블로우 후 건조, 지그 각도 변경', bigo: '재작업' },
    { way: '색상 이상', cause: '소려로 분위기 산화로 표면 변색', after: '고객 품질팀 협의 → 특채 승인', bigo: '특채' }
  ];
  var ncDb = M.db('c4-noproduct', function () {
    var out = [], idx = 1, r = M.rng('nc|' + M.days()[0]);
    var lots = doneLots();
    // 경도 불합격 LOT 은 반드시 부적합 등록
    lots.forEach(function (l) {
      if (l.result === '불합격') {
        var under = l.hardness < l.hrc_min;
        out.push({ lot: l, t: { way: under ? '경도미달' : '기타', cause: under ? '소입 냉각 불충분 (평균 HRC ' + l.hardness + ')' : '경도 상한 초과 (평균 HRC ' + l.hardness + ')', after: under ? '재소입·재소려 재작업' : '재소려(+20℃) 재작업', bigo: '재작업' } });
      }
    });
    var picks = r.shuffle(lots).slice(0, 9);
    picks.forEach(function (l, i) { out.push({ lot: l, t: NC_TYPES[(i + r.int(0, 2)) % NC_TYPES.length] }); });
    var now = new Date();
    return out.sort(function (a, b) { return a.lot.start_time < b.lot.start_time ? -1 : 1; }).map(function (o) {
      var l = o.lot, rr = M.rng('ncrow|' + l.lot_no + o.t.way), p = D.product(l.prod_code);
      var qty = o.t.way === '경도미달' ? l.qty : (o.t.way === '이종혼입' ? rr.int(1, 4) : rr.int(2, 38));
      var recent = (now - M.toDate(l.end_time)) < 8 * 3600000;
      var who = rr.pick([D.workers[3], D.workers[6]]);
      return {
        idx: idx++, d_date: l.work_date, d_lot: l.lot_no, d_cust_name: l.cust_name, d_pum_bun: p.part_no, d_pum_name: p.prod_name,
        d_way: o.t.way, d_end_time: hm(l.end_time), no_pro_cnt: qty, d_cause: o.t.cause,
        d_after: o.t.after + (o.t.bigo === '폐기' ? ' (' + qty + 'EA 폐기)' : ''),
        d_yn_1: 'O', d_yn_2: recent ? 'X' : 'O', d_name: who.user_name,
        d_bigo: '처리구분: ' + o.t.bigo + (recent ? ' · 조치 진행중' : ' · 조치완료') + (o.t.bigo === '특채' ? ' (' + l.cust_name + ' 승인)' : '')
      };
    });
  }, 'idx');
  M.post('/productionManagement/noProduct/getNoProductList', function (req) {
    var w = str(req.params.w_date);
    var data = ncDb.all().filter(function (r) { return !w || String(r.d_date || '').indexOf(w) === 0; })
      .sort(function (a, b) { return (b.d_date + b.d_end_time).localeCompare(a.d_date + a.d_end_time); });
    return { last_page: 1, data: data };
  });
  function ncSave(req) {
    var b = req.params, row = {};
    ['idx', 'd_date', 'd_lot', 'd_pum_bun', 'd_pum_name', 'd_way', 'd_end_time', 'no_pro_cnt', 'd_cause', 'd_after', 'd_yn_1', 'd_yn_2', 'd_name', 'd_bigo'].forEach(function (k) { if (b[k] !== undefined) row[k] = b[k]; });
    if (row.idx) { row.idx = +row.idx; ncDb.upsert(row); } else { delete row.idx; ncDb.insert(row); }
    return { result: 'success' };
  }
  M.post('/productionManagement/noProduct/insertNoProduct', ncSave);
  M.post('/productionManagement/noProduct/updateNoProduct', ncSave);
  M.post('/productionManagement/noProduct/deleteNoProduct', function (req) { ncDb.remove(req.params.idx || []); return { result: 'success' }; });

  /* ───────────────────── 열전대 비교검증 (SAT) ───────────────────── */
  function satDb(ym) {
    ym = ym || todayYM();
    return M.db('c4-sat:' + ym, function () {
      var cur = todayYM(), last = ym > cur ? 0 : (ym === cur ? new Date().getDate() : daysInMonth(ym));
      var zones = [['소입로 1존', 850], ['소입로 3존', 860], ['소입로 5존', 850], ['소려로 1존', 450], ['소려로 3존', 460], ['소려로 5존', 450]];
      var out = [], cnt = 1;
      zones.forEach(function (z) {
        var a = { cnt: cnt++, s_gb: z[0] + ' 제어 TC 지시값(℃)', s_chk: String(z[1]) };
        var b = { cnt: cnt++, s_gb: z[0] + ' 표준 TC 측정값(℃)', s_chk: '-' };
        var c = { cnt: cnt++, s_gb: z[0] + ' 편차(℃)', s_chk: '±3' };
        var bias = M.rng('satb|' + z[0]).float(-0.8, 0.8);
        for (var d = 1; d <= 31; d++) {
          var k = 's' + M.pad(d);
          if (d > last) { a[k] = b[k] = c[k] = ''; continue; }
          var r = M.rng('sat|' + ym + z[0] + d), pv = r1(z[1] + r.float(-1.2, 1.2)), st = r1(pv - bias - r.float(-0.6, 0.6));
          a[k] = pv.toFixed(1); b[k] = st.toFixed(1); c[k] = (pv - st >= 0 ? '+' : '') + (pv - st).toFixed(1);
        }
        out.push(a, b, c);
      });
      var j = { cnt: cnt++, s_gb: '판정', s_chk: '-' }, w = { cnt: cnt++, s_gb: '점검자', s_chk: '-' };
      for (var d = 1; d <= 31; d++) { var k = 's' + M.pad(d); j[k] = d <= last ? 'OK' : ''; w[k] = d <= last ? M.rng('satw' + ym + d).pick(['박성진', '윤재석']) : ''; }
      out.push(j, w);
      return out;
    }, 'cnt');
  }
  M.post('/quality/sat/list', function (req) { return { data: satDb(str(req.params.s_smonth).slice(0, 7)).all() }; });
  M.post('/quality/sat/save', function (req) {
    var b = req.params;
    if (b.field && b.cnt) { var p = {}; p[b.field] = b.value; satDb(todayYM()).update(b.cnt, p); }
    return { data: 1 };
  });
  M.post('/quality/sat/delete', function () { return { data: 1 }; });

  /* ───────────────────── 화면 보조 (원본 JSP 수정 없이 데모 편의) ───────────────────── */
  function svgPhoto(label, sub) {
    var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="320" height="220" viewBox="0 0 320 220">' +
      '<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#cfd6de"/><stop offset="1" stop-color="#7d8894"/></linearGradient></defs>' +
      '<rect width="320" height="220" fill="#e9edf1"/><rect x="40" y="80" width="240" height="60" rx="14" fill="url(#g)" stroke="#5b6672"/>' +
      '<rect x="20" y="92" width="30" height="36" rx="6" fill="#8d97a2"/><rect x="270" y="92" width="30" height="36" rx="6" fill="#8d97a2"/>' +
      '<circle cx="120" cy="110" r="4" fill="#2b3138"/><circle cx="160" cy="110" r="4" fill="#2b3138"/><circle cx="200" cy="110" r="4" fill="#2b3138"/>' +
      '<text x="160" y="40" font-family="sans-serif" font-size="15" text-anchor="middle" fill="#334155">' + label + '</text>' +
      '<text x="160" y="190" font-family="sans-serif" font-size="12" text-anchor="middle" fill="#64748b">' + sub + '</text></svg>';
    return 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
  }
  window.addEventListener('load', function () {
    setTimeout(function () {
      var $ = window.jQuery;
      // Cpk: 첫 화면에서 최근 LOT 가 가장 많은 품번으로 자동 조회
      if (onPage(/^\/quality\/cpk$/) && $ && typeof window.dataSearch === 'function') {
        var inp = $("input[name='w_pnum']");
        if (inp.length && !inp.val()) { inp.val(bestCpkProduct().part_no); window.dataSearch(); }
      }
      // F/PROOF: 점검방법 문서 보기 / 엑셀
      if (onPage(/^\/quality\/fProof$/)) {
        window.openPdf = function (enc) {
          var fn = decodeURIComponent(enc || ''), it = null;
          FP_ITEMS.forEach(function (x) { if (x[3] === fn) it = x; });
          it = it || ['설비', '-', fn.replace(/\.\w+$/, ''), fn, '-'];
          var html = '<div style="font:14px sans-serif;padding:24px;color:#1e293b"><h2 style="margin:0">F/PROOF 점검 기준서</h2><div style="color:#64748b;margin:4px 0 16px">' + fn + ' · 개정 3 · 승인 ' + D.workers[3].user_name + '</div>' +
            '<table border="1" cellpadding="8" style="border-collapse:collapse;width:100%"><tr><th style="width:140px;background:#f1f5f9">설비</th><td>' + it[0] + '</td></tr><tr><th style="background:#f1f5f9">점검항목</th><td>' + it[2] + '</td></tr><tr><th style="background:#f1f5f9">규격</th><td>' + it[1] + '</td></tr>' +
            '<tr><th style="background:#f1f5f9">점검주기</th><td>매일 1회 (주간 근무 시작 시)</td></tr><tr><th style="background:#f1f5f9">점검방법</th><td>1. 조작반에서 시험 모드 선택<br>2. 설정값을 경보 조건으로 일시 변경 (또는 시험 버튼 조작)<br>3. 경보등·부저 동작 및 인터록(투입 정지) 확인<br>4. 설정값 원복 후 정상 운전 복귀 확인<br>5. 점검표에 OK/NG 기록</td></tr>' +
            '<tr><th style="background:#f1f5f9">판정기준</th><td>경보 및 인터록이 3초 이내 정상 동작하면 OK</td></tr><tr><th style="background:#f1f5f9">이상 시 조치</th><td>' + it[4] + '</td></tr></table></div>';
          var fr = document.getElementById('pdfFrame'); if (fr) { fr.removeAttribute('src'); fr.srcdoc = html; }
          var m = document.getElementById('pdfViewerModal'); if (m) m.style.display = 'flex';
        };
        if ($) $('#btnExcel').off('click').on('click', function (e) {
          e.preventDefault();
          if (window.dataTable) { try { window.dataTable.download(window.XLSX ? 'xlsx' : 'csv', 'F_PROOF_' + $('#y_m').val() + (window.XLSX ? '.xlsx' : '.csv')); } catch (er) { /* ignore */ } }
        });
      }
      // 온도균일성: 첨부파일 링크 → TUS 보고서 미리보기
      if (onPage(/^\/quality\/tusTest$/)) {
        document.addEventListener('click', function (e) {
          var a = e.target.closest && e.target.closest('a.file-link');
          if (!a) return;
          e.preventDefault(); e.stopPropagation();
          var fn = decodeURIComponent((a.getAttribute('href') || '').split('filename=')[1] || '');
          var row = tusDb.all().filter(function (r) { return r.t_url === fn; })[0] || tusDb.all()[0];
          showOverlay(tusReportHtml(row));
        }, true);
      }
      // 경도: 검사품 사진 미리보기
      if (onPage(/^\/quality\/hardness$/)) {
        window.setPreviewImage = function (imgId, fileName) {
          var img = document.getElementById(imgId); if (!img) return;
          img.src = svgPhoto(fileName ? '검사품 ' + imgId.slice(-1) : '사진 없음', fileName || '');
          img.style.display = 'block'; img.onclick = null;
        };
      }
      // 부적합품: 불량유형 선택지 보강
      if (onPage(/^\/productionManagement\/noProduct$/)) {
        var sel = document.querySelector("select[name='d_way']");
        ['경도미달', '변형'].forEach(function (v) {
          if (sel && !Array.prototype.some.call(sel.options, function (o) { return o.value === v; })) {
            var o = document.createElement('option'); o.value = o.textContent = v; sel.insertBefore(o, sel.lastElementChild);
          }
        });
      }
    }, 200);
  });
})();
