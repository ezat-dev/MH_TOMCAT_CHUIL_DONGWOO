/* routes/d2-monitor.js — 모니터링 메뉴 (통신 모니터링, 설비 상세, 작업LIST, 공정현황 1/2, 트렌드, 알람 이력/랭킹) */
(function () {
  var M = window.MOCK, D = M.D;
  if (!M || !D) return;

  var EQUT_MAP = {
    1: '2420M001', 2: '2420M002', 3: '2420M003', 4: '2420M004', 5: '2420M005', 6: '2420M011',
    7: '2420M006', 8: '2420M007', 9: '2420M008', 10: '2420M009', 11: '2420M010', 12: '2421M002'
  };
  var EQUT_REV = {};
  Object.keys(EQUT_MAP).forEach(function (k) { EQUT_REV[EQUT_MAP[k]] = +k; });

  /* ───────── 공통: 권한 (common_style.jsp → <page>/sample_pro/perm/my) ───────── */
  M.get(/\/perm\/my$/, function () { return {}; });

  /* ───────── 호기별 차지 인덱스 ───────── */
  var _byF = null;
  function byF() {
    if (_byF) return _byF;
    _byF = {};
    D.furnaces.forEach(function (f) { _byF[f.no] = []; });
    D.charges().forEach(function (c) {
      _byF[c.furnace_no].push({
        c: c, s: M.toDate(c.start_time).getTime(), e: M.toDate(c.end_time || c.plan_end_time).getTime(),
        p: D.product(c.prod_code)
      });
    });
    return _byF;
  }
  function chargeAt(no, ts) { // 마지막으로 시작한 차지 인덱스
    var a = byF()[no], lo = 0, hi = a.length - 1, ans = -1;
    while (lo <= hi) { var m = (lo + hi) >> 1; if (a[m].s <= ts) { ans = m; lo = m + 1; } else hi = m - 1; }
    return ans;
  }
  var PH_HEAT = 0.15, PH_DIFF = 0.60, PH_COOL = 0.85, PH_QUENCH = 0.92;
  function phaseName(frac) {
    return frac < PH_HEAT ? '승온' : frac < PH_COOL ? '본처리' : frac < PH_QUENCH ? '강온' : '냉각';
  }

  /*
   * 공정값 시뮬레이션 — 배치 침탄 사이클
   *   장입(도어 개방 → 온도/CP 급강하) → 승온 → 침탄(920~930℃, CP 0.80~0.90) → 확산(CP 하향)
   *   → 강온(850℃ 소입온도) → 유냉(유조 온도 상승) → 다음 장입까지 850℃ 유지
   */
  function proc(no, ts) {
    var a = byF()[no], i = chargeAt(no, ts), key = 'bcf' + no, now = Date.now();
    var r = { temp: 850, tempSp: 850, cp: 0.6, cpSp: 0.6, oil: 68, c3h8: 0.35, kg: 0, phase: '대기' };
    var cur = i >= 0 ? a[i] : null;
    var inCharge = cur && ts <= cur.e;
    var lastEnd = null;
    if (cur && !inCharge) lastEnd = cur.e; else if (i > 0) lastEnd = a[i - 1].e;

    if (inCharge) {
      var p = cur.p, T = p.temp, cp = p.cp, D_ = cur.e - cur.s, tm = (ts - cur.s) / 60000, frac = (ts - cur.s) / D_;
      var tCool = cur.s + D_ * PH_COOL, tDiff = cur.s + D_ * PH_DIFF;
      var heatT = function (m) { var e = Math.exp(-m / 40); return T - (T - 850) * e - 110 * (1 - Math.exp(-m / 3)) * e; };
      r.kg = cur.c.weight;
      if (ts < tCool) {
        r.temp = heatT(tm); r.tempSp = T;
      } else {
        var tc = (tCool - cur.s) / 60000;
        r.temp = 850 + (heatT(tc) - 850) * Math.exp(-(tm - tc) / 15); r.tempSp = 850;
      }
      // CP
      var e2 = Math.exp(-tm / 25);
      var cpHeat = function (m) { var e = Math.exp(-m / 25); return cp - (cp - 0.6) * e - 0.25 * (1 - Math.exp(-m / 2)) * e; };
      if (ts < tDiff) { r.cp = cpHeat(tm); r.cpSp = cp; }
      else if (ts < tCool) {
        var td = (tDiff - cur.s) / 60000, from = cpHeat(td);
        r.cpSp = cp - 0.12; r.cp = r.cpSp + (from - r.cpSp) * Math.exp(-(tm - td) / 12);
      } else {
        var tc2 = (tCool - cur.s) / 60000;
        var atC = (cp - 0.12) + (cpHeat((tDiff - cur.s) / 60000) - (cp - 0.12)) * Math.exp(-(tc2 - (tDiff - cur.s) / 60000) / 12);
        r.cpSp = cp - 0.08; r.cp = r.cpSp + (atC - r.cpSp) * Math.exp(-(tm - tc2) / 12);
      }
      r.phase = phaseName(frac);
      r.c3h8 = frac < PH_HEAT ? 1.2 : frac < PH_DIFF ? 2.6 * cp / 0.85 : frac < PH_COOL ? 0.9 : 0.6;
      void e2;
    } else if (no === 9 && cur && ts > cur.e && i === a.length - 1) {
      // 정지 호기: 마지막 배치 후 자연 냉각
      var dm = (ts - cur.e) / 60000;
      r.temp = 28 + (850 - 28) * Math.exp(-dm / 420); r.tempSp = 0;
      r.cp = (cur.p.cp - 0.08) * Math.exp(-dm / 20); r.cpSp = 0; r.c3h8 = 0; r.phase = '정지';
    } else if (cur) {
      // 소입 후 대기: CP 가 확산 끝 값에서 대기 분위기(0.60)로 서서히 내려감
      r.cp = 0.6 + (cur.p.cp - 0.08 - 0.6) * Math.exp(-(ts - cur.e) / 60000 / 10);
    }
    // 유조: 소입 직후 온도 상승
    if (lastEnd && ts >= lastEnd) r.oil += 38 * Math.exp(-(ts - lastEnd) / 60000 / 22);
    if (no === 9 && r.phase === '정지') r.oil = 30 + (r.oil - 30) * Math.exp(-(ts - a[a.length - 1].e) / 60000 / 300);
    // 활성 알람과 맞춤: 2호기 유조 온도 상승, 5호기 CP 편차
    if (no === 2 && ts > now - 14 * 60000) r.oil += 26 * Math.min(1, (ts - (now - 14 * 60000)) / (5 * 60000));
    if (no === 5 && ts > now - 25 * 60000 && inCharge) r.cp -= 0.16 * Math.min(1, (ts - (now - 25 * 60000)) / (2 * 60000));

    r.temp += M.wave(key + 't', ts, 0, 1.2, 0.35, 23);
    r.cp += M.wave(key + 'c', ts, 0, 0.007, 0.003, 17);
    r.oil += M.wave(key + 'o', ts, 0, 1.4, 0.3, 41);
    if (r.c3h8 > 0) r.c3h8 = Math.max(0.05, r.c3h8 + M.wave(key + 'g', ts, 0, 0.07, 0.03, 13));
    r.cp = Math.max(0, r.cp);
    return r;
  }
  D.d2Process = proc; // 다른 화면에서도 같은 공정값을 쓰고 싶을 때

  /* ═════════════ 통신 모니터링 ═════════════ */
  var PLCS = (function () {
    var out = [];
    D.furnaces.forEach(function (f) {
      var type = f.no <= 5 || f.no === 12 ? 'LS' : (f.no === 6 || f.no === 11) ? 'OMRON' : 'MITSUBISHI';
      out.push({
        plcId: 'bcf_' + M.pad(f.no), label: f.name + ' (' + (f.no === 6 ? '연속식 S-TKM' : f.no === 11 ? '2실형 침탄로' : '배치형 침탄로') + ')',
        ip: '192.168.10.' + (100 + f.no), port: type === 'LS' ? 2004 : type === 'MITSUBISHI' ? 5002 : 9600, plcType: type, useYn: 'Y'
      });
    });
    out.push({ plcId: 'bcf_rx', label: '변성로(RX) 1·2호기', ip: '192.168.10.121', port: 2004, plcType: 'LS', useYn: 'Y' });
    out.push({ plcId: 'bcf_tp', label: '템퍼로 1·2호기', ip: '192.168.10.122', port: 2004, plcType: 'LS', useYn: 'Y' });
    return out;
  })();
  M.get('/plc/dblist', function () { return { success: true, data: PLCS }; });
  M.get('/api/plc/status-all', function () {
    return PLCS.map(function (p) { return { id: p.plcId, ok: true, message: 'OK', lastRead: M.fmt(new Date()) }; });
  });

  /* ═════════════ 작업LIST ═════════════ */
  var wlDeleted = M.db('d2_worklist_deleted', function () { return []; }, 'statusSeq');
  function workQueue() {
    var days = M.days(), out = [];
    D.furnaces.forEach(function (f) {
      var r = M.rng('dw-wl-' + f.no + '-' + days[2]);
      var items = [], seq = f.no * 100;
      var cur = D.currentCharge(f.no);
      var list = D.chargesIn(null, null, f.no);
      var last = list[list.length - 1];
      var nn = last ? parseInt(last.lot_no.slice(-2), 10) : 0;
      if (cur) items.push({ workIndctNum: cur.lot_no, prodNm: cur.prod_name, prodNum: cur.part_no, custNm: cur.cust_name, statusSeq: String(++seq), status: '진행중' });
      var q = f.no === 4 ? 1 : f.no === 9 ? 2 : r.int(1, 3);
      for (var k = 0; k < q; k++) {
        var p = D.products[r.int(0, D.products.length - 1)];
        nn++;
        items.push({
          workIndctNum: 'DW' + M.fmt(new Date(), 'YYYYMMDD').slice(2) + '-' + M.pad(f.no) + M.pad(nn), prodNm: p.prod_name, prodNum: p.part_no,
          custNm: D.customer(p.cust_code).cust_name, statusSeq: String(++seq), status: '대기'
        });
      }
      void last;
      var del = wlDeleted.all().map(function (d) { return String(d.statusSeq); });
      items = items.filter(function (it) { return del.indexOf(it.statusSeq) < 0; });
      out.push({ machineTag: 'BCF ' + f.no + '호기', equtCd: EQUT_MAP[f.no], items: items });
    });
    return out;
  }
  M.get('/work/listData', function () { return workQueue(); });
  M.post('/work/softDelete', function (req) {
    if (req.params.statusSeq) wlDeleted.insert({ statusSeq: String(req.params.statusSeq) });
    return { success: true };
  });

  /* ═════════════ 공정현황 1/2 ═════════════ */
  function rowItem(no, rowSort, c) {
    return { equipCd: 'bcf_' + M.pad(no), rowSort: rowSort, custNm: c ? c.cust_name : '', prodNm: c ? c.prod_name : '', lotNo: c ? c.lot_no : '' };
  }
  function curPhase(no) {
    var c = D.currentCharge(no);
    if (!c) return { c: null, ph: null };
    var s = M.toDate(c.start_time).getTime(), e = M.toDate(c.plan_end_time).getTime();
    return { c: c, ph: phaseName((Date.now() - s) / (e - s)) };
  }
  function recent(no, back) { var l = D.chargesIn(null, null, no); return l[l.length - 1 - back] || null; }
  M.get('/monitor/nowWork/list', function (req) {
    var page = String(req.params.pageNo || '1'), items = [];
    if (page === '2') {
      // 6호기 연속로: 예열/가열 = 최신 로트, 침탄1~3 = 직전 로트, 강온 = 그 이전 로트, 냉각실 비어있음
      var c0 = recent(6, 0), c1 = recent(6, 1), c2 = recent(6, 2);
      [c0, c0, c1, c1, c1, c2, null].forEach(function (c, i) { items.push(rowItem(6, i + 1, c)); });
      var k = curPhase(11);
      items.push(rowItem(11, 1, k.c || recent(11, 0)));
      items.push(rowItem(11, 2, recent(11, 1)));
      items.push(rowItem(11, 3, null));
    } else {
      [1, 2, 3, 4, 5, 7, 8, 9, 10, 12].forEach(function (no) {
        var cp = curPhase(no);
        if (no === 7 || no === 8 || no === 9) {
          var cool = cp.ph === '냉각';
          items.push(rowItem(no, 1, cool ? null : cp.c));
          items.push(rowItem(no, 2, cool ? cp.c : null));
        } else items.push(rowItem(no, 1, cp.c));
      });
    }
    return items;
  });

  var SNAP_TAGS = [];
  var PHASE_TAGS = {
    1: { 승온: ['bcf1_96'], 본처리: ['bcf1_97'], 강온: ['bcf1_98'], 냉각: ['bcf1_51'], occ: ['bcf1_50'] },
    2: { 승온: ['bcf2_96'], 본처리: ['bcf2_97'], 강온: ['bcf2_98'], 냉각: ['bcf2_51'], occ: [] },
    3: { 승온: ['bcf3_96'], 본처리: ['bcf3_97'], 강온: ['bcf3_98'], 냉각: ['bcf3_51'], occ: [] },
    4: { 승온: ['bcf4_96'], 본처리: ['bcf4_97'], 강온: ['bcf4_98'], 냉각: ['bcf4_51'], occ: ['bcf4_50'] },
    5: { 승온: ['bcf5_98'], 본처리: ['bcf5_99'], 강온: ['bcf5_100'], 냉각: ['bcf5_54'], occ: ['bcf5_53'] },
    10: { 승온: ['bcf10_98'], 본처리: ['bcf10_99'], 강온: ['bcf10_100'], 냉각: ['bcf10_54'], occ: ['bcf10_53'] },
    7: { 승온: ['bcf7_272', 'bcf7_273', 'bcf7_274', 'bcf7_275'], 본처리: ['bcf7_276', 'bcf7_277', 'bcf7_278'], 강온: ['bcf7_279'], 냉각: ['bcf7_145'], occ: ['bcf7_144'] },
    9: { 승온: ['bcf9_272', 'bcf9_273', 'bcf9_274', 'bcf9_275'], 본처리: ['bcf9_276', 'bcf9_277', 'bcf9_278'], 강온: ['bcf9_279'], 냉각: ['bcf9_145'], occ: ['bcf9_144'] },
    8: { 승온: ['bcf8_164'], 본처리: ['bcf8_165'], 강온: ['bcf8_166'], 냉각: ['bcf8_117'], occ: ['bcf8_116'] },
    12: { 승온: ['bcf12_L0301'], 본처리: ['bcf12_L0302', 'bcf12_L0303', 'bcf12_L0304', 'bcf12_L0305'], 강온: ['bcf12_L0306'], 냉각: ['bcf12_Y119H'], occ: [] }
  };
  Object.keys(PHASE_TAGS).forEach(function (k) { var g = PHASE_TAGS[k]; ['승온', '본처리', '강온', '냉각', 'occ'].forEach(function (p) { SNAP_TAGS = SNAP_TAGS.concat(g[p]); }); });
  SNAP_TAGS = SNAP_TAGS.concat(['bcf6_291', 'bcf6_293', 'bcf6_294', 'bcf6_295', 'bcf6_296', 'bcf6_297', 'bcf6_298',
    'bcf11_164', 'bcf11_165', 'bcf11_166', 'bcf11_167', 'bcf11_40010', 'bcf11_40027', 'bcf11_40044', 'bcf2_50', 'bcf3_50']);

  M.get('/monitor/snapshot', function () {
    var d = {};
    SNAP_TAGS.forEach(function (t) { d[t] = 0; });
    Object.keys(PHASE_TAGS).forEach(function (k) {
      var no = +k, g = PHASE_TAGS[k], cp = curPhase(no);
      if (!cp.c) return;
      var list = g[cp.ph];
      // 다단 스텝 비트는 진행에 따라 하나만 ON
      var s = M.toDate(cp.c.start_time).getTime(), e = M.toDate(cp.c.plan_end_time).getTime();
      var idx = Math.min(list.length - 1, Math.floor(((Date.now() - s) / (e - s) * 7) % list.length));
      d[list[list.length > 1 ? idx : 0]] = 1;
      if (cp.ph === '냉각' && (no === 7 || no === 8 || no === 9)) return; // 본처리실 비고 냉각실로 이동
      g.occ.forEach(function (t) { d[t] = 1; });
    });
    // 6호기 연속로 — 냉각실(298) 비어 있음
    ['bcf6_291', 'bcf6_293', 'bcf6_294', 'bcf6_295', 'bcf6_296', 'bcf6_297'].forEach(function (t) { d[t] = 1; });
    // 11호기 2실형
    var k11 = curPhase(11);
    if (k11.c) { d[k11.ph === '승온' ? 'bcf11_164' : 'bcf11_166'] = 1; d['bcf11_40010'] = 1; }
    d['bcf11_40027'] = 1;
    return d;
  });

  /* ═════════════ 트렌드 ═════════════ */
  var TAGS = [];
  D.furnaces.forEach(function (f) {
    var n = f.no, eq = 'BCF' + n, pre = 'BCF' + n + ' ';
    [
      ['temp_pv', '침탄온도 PV', 'D100'], ['temp_sp', '침탄온도 SP', 'D101'],
      ['cp_pv', 'CP PV', 'D110'], ['cp_sp', 'CP SP', 'D111'],
      ['oil_pv', '유조온도 PV', 'D120'], ['c3h8', 'C3H8 유량', 'D130']
    ].forEach(function (x, i) {
      TAGS.push({ tempId: n, colName: 'bcf' + n + '_' + x[0], tagName: 'BCF' + n + '_' + x[0].toUpperCase(), trendName: pre + x[1], equipId: eq, address: x[2], unit: '', sortNo: i + 1 });
    });
  });
  TAGS.push({ tempId: 11, colName: '11_kg', tagName: '11_KG', trendName: 'BCF11 장입중량 kg', equipId: 'BCF11', address: 'D140' });
  M.get('/temp/cols', function () { return TAGS; });

  function snapshotRows(from, to) {
    var days = M.days(), now = Date.now();
    var f = M.toDate(from), t = M.toDate(to);
    var lo = M.toDate(days[0] + ' 00:00:00').getTime();
    var a = Math.max(f ? f.getTime() : now - 6 * 3600000, lo), b = Math.min(t ? t.getTime() : now, now);
    if (b <= a) return [];
    var step = Math.max(30000, Math.ceil((b - a) / 480 / 30000) * 30000);
    var rows = [];
    for (var ts = Math.ceil(a / step) * step; ts <= b; ts += step) {
      var row = { record_time: M.fmt(new Date(ts)) };
      for (var n = 1; n <= 12; n++) {
        var p = proc(n, ts);
        row['bcf' + n + '_temp_pv'] = M.round(p.temp, 1);
        row['bcf' + n + '_temp_sp'] = p.tempSp;
        row['bcf' + n + '_cp_pv'] = M.round(p.cp, 3);
        row['bcf' + n + '_cp_sp'] = M.round(p.cpSp, 2);
        row['bcf' + n + '_oil_pv'] = M.round(p.oil, 1);
        row['bcf' + n + '_c3h8'] = Math.round(p.c3h8 * 1000 / 3.1); // 화면에서 (v/1000)*3.1 → L/min
        if (n === 11) row['11_kg'] = p.kg;
      }
      rows.push(row);
    }
    return rows;
  }
  M.get('/temp/snapshot/range', function (req) { return snapshotRows(req.params.from, req.params.to); });

  M.get('/work/jacup/range', function (req) {
    var no = EQUT_REV[req.params.equtCd] || null;
    var f = M.toDate(req.params.from), t = M.toDate(req.params.to);
    return D.charges().filter(function (c) {
      if (no && c.furnace_no !== no) return false;
      var s = M.toDate(c.start_time), e = c.end_time ? M.toDate(c.end_time) : new Date();
      return (!t || s <= t) && (!f || e >= f);
    }).map(function (c) {
      return {
        WORK_INDCT_NUM: c.lot_no, PROD_NM: c.prod_name, PROD_NUM: c.part_no, CUST_NM: c.cust_name,
        EQUT_CD: EQUT_MAP[c.furnace_no], START_DTTM: c.start_time, END_DTTM: c.end_time || ''
      };
    });
  });

  var memos = M.db('d2_trend_memo', function () {
    var days = M.days(), now = new Date();
    var at = function (min) { return M.fmt(M.addMinutes(now, -min)); };
    return [
      { tcCnt: 1, tcName: 'CP 프로브 번아웃', tcDesc: '정기 번아웃 실시 (15분)', tcRegtime: at(135), equipId: 'BCF1', tcUserName: '김상훈' },
      { tcCnt: 2, tcName: '교대 인수인계', tcDesc: '주간조 → 야간조', tcRegtime: days[1] + ' 20:00:00', equipId: '0', tcUserName: '박민준' },
      { tcCnt: 3, tcName: '열전대 교정', tcDesc: 'K-type 교정 완료 (편차 +0.8℃)', tcRegtime: days[1] + ' 10:20:00', equipId: 'BCF1', tcUserName: '정용석' },
      { tcCnt: 4, tcName: '교대 인수인계', tcDesc: '야간조 → 주간조', tcRegtime: days[2] + ' 08:00:00', equipId: '0', tcUserName: '김상훈' },
      { tcCnt: 5, tcName: 'RX가스 유량 조정', tcDesc: '8.5 → 9.0 m³/h', tcRegtime: at(260), equipId: 'BCF5', tcUserName: '이재원' },
      { tcCnt: 6, tcName: '교반팬 점검', tcDesc: '베어링 소음 확인, 이상 없음', tcRegtime: days[0] + ' 15:40:00', equipId: 'BCF7', tcUserName: '윤지환' }
    ];
  }, 'tcCnt');
  M.get('/temp/memo/list', function (req) {
    var eq = req.params.equipId, f = req.params.from, t = req.params.to;
    return memos.all().filter(function (m) {
      return M.inRange(m.tcRegtime, f, t) && (!eq || eq === 'ALL' || m.equipId === '0' || m.equipId === eq);
    });
  });
  M.post('/temp/memo/insert', function (req) {
    var p = req.params;
    memos.insert({ tcName: p.tcName, tcDesc: p.tcDesc || '', tcRegtime: p.tcRegtime, equipId: p.equipId || '0', tcUserName: '관리자' });
    return { success: true };
  });
  M.post('/temp/memo/delete', function (req) { memos.remove(req.params.tcCnt); return { success: true }; });

  /* ═════════════ 알람 이력 / 랭킹 ═════════════ */
  M.get('/alarm/active/list', function (req) {
    var lim = +req.params.limit || 200;
    return D.activeAlarms().slice(0, lim);
  });
  // 알람 랭킹 화면(limit=1000, range)은 plcId 원문을 그대로 KPI/차트 라벨로 쓰므로 'BCF2' 형태로 준다
  function forRanking(list) {
    return list.map(function (a) { var o = {}; for (var k in a) o[k] = a[k]; o.plcId = 'BCF' + a.furnace_no; return o; });
  }
  M.get('/alarm/history/list', function (req) {
    var lim = +req.params.limit || 500;
    var list = D.alarms().slice(0, lim);
    return lim >= 1000 ? forRanking(list) : list;
  });
  // 포털 사이드바 '알람 이력' 배지는 JSP에 0 으로 고정 → 활성 알람 수로 채움
  if (/\/main_1\/main\/?$/.test(location.pathname)) {
    document.addEventListener('DOMContentLoaded', function () {
      var b = document.getElementById('alarmBadge');
      if (b) b.textContent = D.activeAlarms().length;
    });
  }
  M.get('/alarm/history/range', function (req) {
    return forRanking(D.alarms().filter(function (a) { return M.inRange(a.occurTime, req.params.from, req.params.to); }));
  });
})();
