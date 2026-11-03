/*
 * routes/c2-monitoring.js — 모니터링 + 종합생산현황 (C2)
 *   종합생산현황(workMonitoring), 통합모니터링(integrationMonitoring, m1, hand), 알람현황(alarm),
 *   알람이력(alarmRecord), 알람랭킹(alarmFrequency), 온도경향감시(trend, handTrend),
 *   LOT현황(lot), LOT트레킹(lotProcessor, lotProcessorHand)
 *
 * 모든 값은 MOCK.D.lots() (연속로 LOT 흐름) + MOCK.D.lineTimes() + MOCK.D.alarms() 에서 파생된다.
 * 공정값(PV)은 "그 시각에 해당 존을 지나던 LOT의 품목 패턴 설정온도"를 1차 지연으로 따라가고
 * MOCK.wave 로 미세 진동한다 → 트렌드/실시간/작업목록 값이 서로 맞는다.
 */
(function () {
  var M = window.MOCK, D = M.D;
  // trend.jsp 가 선언 없이 참조하는 전역 (원본 버그: 차트 생성 직후 ReferenceError) — 임계선 기본 OFF
  if (typeof window.showThreshold === 'undefined') window.showThreshold = false;

  /* ───────────── 공통: LOT 타임라인 ───────────── */
  var LOTS = D.lots();
  var STARTS = LOTS.map(function (l) { return M.toDate(l.start_time).getTime(); });
  var ENDS = LOTS.map(function (l) { return M.toDate(l.plan_end_time).getTime(); });
  var STAGE = {}; D.lineStages.forEach(function (s) { STAGE[s[0]] = s[1]; });

  // x(ms) 시각에 투입되고 있던(또는 마지막으로 투입된) LOT 인덱스
  function lotIdxAt(x) {
    var lo = 0, hi = STARTS.length - 1, ans = -1;
    while (lo <= hi) { var mid = (lo + hi) >> 1; if (STARTS[mid] <= x) { ans = mid; lo = mid + 1; } else hi = mid - 1; }
    return ans;
  }
  // x 시각에 실제로 라인에 들어가던 LOT (투입 공백이면 null)
  function lotChargingAt(x) {
    var i = lotIdxAt(x);
    return i >= 0 && x < ENDS[i] ? LOTS[i] : null;
  }

  var CP_BY_MAT = { SCM440: 0.42, S53C: 0.55, S45C: 0.47, SCM420H: 0.82, SCM435: 0.40, S48C: 0.50 };
  function cpOf(lot) { return CP_BY_MAT[lot.material] || 0.45; }
  var QOFF = [-10, 0, 0, 0, -10], TOFF = [0, 10, 10, 5, 0];
  function qSv(lot, i) { return lot.q_temp + QOFF[i]; }
  function tSv(lot, i) { return lot.t_temp + TOFF[i]; }

  // 존 SV 를 1차 지연으로 따라가는 값 (품목 교체 시 승온/강온 곡선)
  function follow(t, offMin, svFn, tauUp, tauDown) {
    var x = t - offMin * 60000, i = lotIdxAt(x);
    if (i < 0) i = 0;
    var cur = svFn(LOTS[i]);
    if (i === 0) return { sv: cur, v: cur };
    var prev = svFn(LOTS[i - 1]);
    if (prev === cur) return { sv: cur, v: cur };
    var dt = (x - STARTS[i]) / 60000; if (dt < 0) dt = 0;
    var tau = cur > prev ? tauUp : tauDown;
    return { sv: cur, v: cur + (prev - cur) * Math.exp(-dt / tau) };
  }

  // t 시각의 전체 공정값 (트렌드 1행과 같은 형태)
  function pv(t) {
    var tm = t instanceof Date ? t : new Date(t);
    var ms = tm.getTime(), o = { regtime: M.fmt(tm) };
    var w = function (k, base, amp, noise, per) { return M.wave(k, tm, base, amp, noise, per); };
    // 노 단위로 레시피가 바뀐다 (새 LOT 가 소입로/소려로 입구에 들어오는 시점)
    for (var i = 0; i < 5; i++) {
      var q = follow(ms, STAGE.qf1_4, (function (z) { return function (l) { return qSv(l, z); }; })(i), 9 + i, 16 + i);
      o['q_sp_' + (i + 1)] = q.sv;
      o['q_pv_' + (i + 1)] = M.round(q.v + w('qpv' + i, 0, 1.3, 0.35, 41 + i * 7), 1);
      var tz = follow(ms, STAGE.tf1_11, (function (z) { return function (l) { return tSv(l, z); }; })(i), 11 + i, 26 + i * 2);
      o['t_sp_' + (i + 1)] = tz.sv;
      o['t_pv_' + (i + 1)] = M.round(tz.v + w('tpv' + i, 0, 1.6, 0.4, 47 + i * 5), 1);
    }
    var cp = follow(ms, 40, cpOf, 20, 25);
    o.cp_sp_1 = Math.round(cp.sv * 1000); o.cp_sp_2 = Math.round((cp.sv - 0.03) * 1000);
    o.cp_pv_1 = Math.round((cp.v + w('cpa', 0, 0.012, 0.003, 33)) * 1000);
    o.cp_pv_2 = Math.round((cp.v - 0.03 + w('cpb', 0, 0.014, 0.003, 29)) * 1000);
    o.oil_sp = 80; o.oil_pv = M.round(w('oil', 80.5, 2.2, 0.25, 63), 1);
    o.f_wash_sp = 60; o.f_wash_pv = M.round(w('fwash', 59.6, 1.4, 0.2, 71), 1);
    o.m_wash_sp = 55; o.m_wash_pv = M.round(w('mwash', 54.8, 1.3, 0.2, 59), 1);
    o.bc_sp = 40; o.bc_pv = M.round(w('bc', 40.4, 0.9, 0.15, 83), 1);
    o.in_wash_sp = 30; o.in_wash_pv = M.round(w('inw', 30, 0.15, 0.05, 20), 2);
    o.in_q_sp = 25.5; o.in_q_pv = M.round(w('inq', 25.5, 0.1, 0.04, 20), 2);
    o.in_oil_sp = 35; o.in_oil_pv = M.round(w('ino', 35, 0.15, 0.05, 20), 2);
    o.in_data_sp = 45; o.in_data_pv = M.round(w('ind', 45, 0.2, 0.05, 20), 2);
    o.in_t_sp = 22; o.in_t_pv = M.round(w('int', 22, 0.1, 0.04, 20), 2);
    o.in_m_wash_sp = 30; o.in_m_wash_pv = M.round(w('inmw', 30, 0.15, 0.05, 20), 2);
    return o;
  }

  /* ───────────── 공통: LOT 트래킹 행 ───────────── */
  var lotEdits = M.db('c2_lotEdits', function () { return []; }, 'w_ci_lot');
  function erpNo(lot) { return 'JS' + lot.lot_no.slice(2, 8) + '-' + M.pad(((lot.idx * 37) % 900) + 100, 4); }
  function tongCount(lot) { return Math.max(4, Math.round(lot.weight / 120)); }
  function trackRow(lot, i, now) {
    var lt = D.lineTimes(lot), row = {
      idx: lot.idx, w_ci_lot: lot.lot_no, erp_jack_no: erpNo(lot), cust_name: lot.cust_name,
      item_name: lot.prod_name, item_no: lot.part_no, y_n: 'Y', w_state: '바코드 스캔'
    };
    if (lot.status === '대기') {
      var prev = LOTS[i - 1];
      lt.regtime = M.addMinutes(M.toDate(prev.start_time), 12 + (lot.idx % 7));
    }
    if (lt.regtime > now) return null;
    row.regtime = M.fmt(lt.regtime);
    ['d370', 'x111'].concat(D.lineStages.map(function (s) { return s[0]; })).forEach(function (f) {
      row[f] = lt[f] <= now ? M.fmt(lt[f]) : '';
    });
    if (!row.d370) row.w_state = lot.status === '대기' && LOTS[i - 1].status !== '대기' ? '바코드 스캔' : '작업등록';
    var ed = lotEdits.find(lot.lot_no);
    if (ed) for (var k in ed) if (k !== 'w_ci_lot' && row.hasOwnProperty(k)) row[k] = ed[k];
    return row;
  }
  function trackRows(from, to) {
    var now = new Date(), out = [];
    LOTS.forEach(function (l, i) {
      var r = trackRow(l, i, now);
      if (r && (!from || M.inRange(r.regtime, from, to || from))) out.push(r);
    });
    return out;
  }

  // 종합생산현황 등에서 쓰는 작업(worklist) 행
  function workRow(lot) {
    var now = new Date(), lt = D.lineTimes(lot), cp = cpOf(lot);
    return {
      w_ci_lot: lot.lot_no, erp_jack_no: erpNo(lot), cust_name: lot.cust_name, item_no: lot.part_no, item_name: lot.prod_name,
      w_sdatetime: lot.start_time, w_date: lot.work_date, w_plan_cnt: tongCount(lot), tong_count: tongCount(lot),
      d370: lt.d370 <= now ? M.fmt(lt.d370) : '', x111: lt.x111 <= now ? M.fmt(lt.x111) : '', l20: lt.l20 <= now ? M.fmt(lt.l20) : '',
      w_weight: lot.weight, q1_zone: qSv(lot, 0), t1_zone: tSv(lot, 0), cp: cp.toFixed(2), pattern: lot.pattern
    };
  }

  /* ───────────── 사용자 정보 GET (handMain 이 GET 으로 호출 — POST 는 C1 담당) ───────────── */
  {
    M.get('/user/info', function () {
      var codes = 'a01 a02 a03 a04 a05 a06 b01 b02 b03 b04 b05 b06 c01 c02 c03 c04 c05 c06 d01 d02 d03 d04 d05 d06 d07 e01 e02 e03 e04 e05 e06 e07 f01 f02 f03 f04 h01 h02 h03 h04 h05 i01 i02 i03'.split(' ');
      var perm = {}; codes.forEach(function (c) { perm[c] = 'Y'; });
      return { data: { user_code: 1, user_id: 'ez', user_name: '관리자', user_level: '관리자' }, loginUser: { user_code: 1, user_id: 'ez', user_name: '관리자' }, loginUserPage: perm };
    });
  }

  /* ───────────── 종합생산현황 (workMonitoring) ───────────── */
  M.any('/monitoring/trend/getLatestTrend', function () { return [pv(new Date())]; });

  M.any('/productionManagement/heatTreatment/list_1', function () {
    var cur = D.currentLot();
    return { data: cur && cur.status === '진행중' ? [workRow(cur)] : [] };
  });
  M.any('/productionManagement/heatTreatment/list_next', function () {
    return { data: LOTS.filter(function (l) { return l.status === '대기'; }).map(workRow) };
  });
  M.any('/productionManagement/heatTreatment/list_10', function () {
    var now = new Date();
    var rows = LOTS.filter(function (l) { return M.toDate(l.start_time) <= now; }).slice(-10).reverse();
    return { data: rows.map(workRow) };
  });
  M.any('/productionManagement/alarmRecord/list', function () {
    return {
      data: D.alarms().slice(0, 10).map(function (a, i) {
        return { idx: i + 1, a_addr: a.a_addr, a_desc: a.a_desc, a_stime: a.a_stime, a_etime: a.a_etime };
      }), last_page: 1
    };
  });

  // 작업스캔 모달
  function findLot(v) {
    v = String(v || '').trim().toUpperCase();
    for (var i = 0; i < LOTS.length; i++) if (v && (LOTS[i].lot_no === v || v.indexOf(LOTS[i].lot_no) === 0)) return LOTS[i];
    return null;
  }
  M.any('/productionManagement/heatTreatment/barcodeScan', function (req) {
    var lot = findLot(req.params.w_ci_lot);
    if (!lot) return { gb: 0, data: '등록되지 않은 LOT 입니다. (' + (req.params.w_ci_lot || '') + ')' };
    var r = M.rng('scan' + lot.lot_no);
    return {
      gb: 1, data: {
        w_ci_lot: lot.lot_no, cust_name: lot.cust_name, item_no: lot.part_no, item_name: lot.prod_name,
        spec: lot.material + ' / ' + lot.pattern, charge_weight: Math.round(lot.weight / tongCount(lot)), w_plan_cnt: tongCount(lot), wd_in_cnt: tongCount(lot) - r.int(0, 1),
        q1_zone: qSv(lot, 0), q2_zone: qSv(lot, 1), q3_zone: qSv(lot, 2), q4_zone: qSv(lot, 3), q5_zone: qSv(lot, 4), q_speed: '25.50', cp: cpOf(lot).toFixed(2),
        t1_zone: tSv(lot, 0), t2_zone: tSv(lot, 1), t3_zone: tSv(lot, 2), t4_zone: tSv(lot, 3), t5_zone: tSv(lot, 4), t_speed: '22.00'
      }
    };
  });
  M.any('/productionManagement/heatTreatment/tongList', function (req) {
    var lot = findLot(req.params.w_ci_lot);
    if (!lot) return [];
    var n = tongCount(lot), out = [];
    for (var i = 1; i <= n; i++) out.push({ wd_tong_num: lot.lot_no + '-' + M.pad(i, 2), wd_state: 1 });
    return out;
  });
  M.any('/productionManagement/heatTreatment/barcodeScanUpdate', function () { return { result: 'success', success: true }; });

  /* ───────────── LOT 현황 / LOT 트레킹 ───────────── */
  M.any('/monitoring/lotProcessor/list', function (req) {
    var p = req.params, s = p.startDay || M.today(), e = p.endDay || s;
    return { data: trackRows(s, e) };
  });
  M.any('/monitoring/lotProcessor/bulkUpdate', function (req) {
    var rows = Array.isArray(req.body) ? req.body : [];
    rows.forEach(function (r) { if (r && r.w_ci_lot) lotEdits.upsert(r); });
    return { result: 'success', success: true, count: rows.length };
  });
  M.any('/lotProcessor/list/Fupdate', function (req) { return { result: 'success', success: true, w_ci_lot: req.params.w_ci_lot }; });

  /* ───────────── 통합모니터링 (integrationMonitoring / m1 / hand) ───────────── */
  M.any('/monitoring/allLotItems', function () {
    var data = LOTS.map(function (l) { return { w_ci_lot: l.lot_no, v_item_name: l.prod_name, cust_name: l.cust_name, item_no: l.part_no }; });
    return { data: data, success: true, count: data.length };
  });

  var LOT_TAGS = ['start_hoper_2', 'f_wash_3', 'qf1_4', 'qf2_5', 'qf3_6', 'qf4_7', 'qf5_8', 'oil_9', 'm_wash_10',
    'tf1_11', 'tf2_12', 'tf3_13', 'tf4_14', 'tf5_15', 'bch_16', 'con_17'];
  // 설비 동작 신호 (대부분 운전중, 일부는 주기적으로 ON/OFF)
  var DIGITAL_ON = ['v-heater', 'v-heater2', 'v-heater3', 'v-heater4', 'v-heater5', 'v-heater6', 'v-heater7', 'v-heater8',
    'v-heater-2', 'v-heater-22', 'v-heater-23', 'v-fire', 'v-fan', 'v-fan-1', 'v-fan-2', 'v-fan-3', 'v-fan-5', 'v-fan-6', 'v-fan-7', 'v-fan-8', 'v-fan-9',
    'v-text-22', 'v-text-222', 'v-text-223', 'v-text-18',
    'a-fan', 'a-fan-1', 'a-fan-2', 'a-fan-3', 'a-fan-4', 'a-fan-5', 'a-fan-6', 'a-fan-7', 'a-fan-8', 'a-fan-9', 'a-pump', 'a-pump-1', 'a-pump-2',
    'a-text-7', 'a-text-8', 'a-text-11', 'a-text-15', 'a-text-17', 'a-text-23', 'a-text-24', 'a-text-72', 'a-text-112', 'a-text-152',
    'c-text', 'c-text-1', 'c-text-2', 'c-text-4', 'c-text-5', 'c-text-9', 'c-text-12', 'c-text-13', 'c-text-16', 'c-text-17', 'c-text-18',
    'c-text-20', 'c-text-21', 'c-text-25', 'c-text-27', 'c-text-92'];
  var DIGITAL_CYCLE = ['c-text-3', 'c-text-6', 'c-text-10', 'c-text-14', 'c-text-19', 'c-text-22', 'c-text-26', 'c-text-28', 'c-text-62', 'c-text-102',
    'v-text', 'v-text-3', 'v-text-32', 'v-text-33'];
  var DIGITAL_OFF = ['vs-text-12', 'vs-text-122', 'vs-text-123', 'vs-text-124', 'vs-text-125', 'vs-text-18'];

  M.any('/monitoring/view', function () {
    var now = new Date(), ms = now.getTime(), list = [];
    var occ = {};
    LOT_TAGS.forEach(function (tag, k) {
      var lot = lotChargingAt(ms - STAGE[tag] * 60000);
      occ[tag] = lot ? lot.lot_no : '';
      list.push(o(tag, 'value', occ[tag]));
      list.push(o('L' + M.pad(k + 2, 3), 'LLL', !!lot));
    });
    var nxt = LOTS.filter(function (l) { return l.status === '대기'; })[0];
    list.push(o('from_pc_1', 'value', nxt ? nxt.lot_no : ''));
    DIGITAL_ON.forEach(function (t) {
      var act = t.indexOf('a-') === 0 ? 'a' : t.indexOf('c-') === 0 ? 'c' : 'v';
      list.push(o(t, act, true));
    });
    DIGITAL_CYCLE.forEach(function (t) {
      var on = M.wave('dg' + t, now, 0, 1, 0, 6 + (M.hash(t) % 9)) > -0.2;
      list.push(o(t, t.indexOf('c-') === 0 ? 'c' : 'v', on));
    });
    var activeAlarm = D.alarms().some(function (a) { return !a.a_etime; });
    DIGITAL_OFF.forEach(function (t, i) { list.push(o(t, 'vs', activeAlarm && i === 0 && now.getSeconds() % 2 === 0)); });
    return { multiValues: list };
    function o(tag, action, value) { var x = {}; x[tag] = { action: action, value: value }; return x; }
  });

  M.any('/monitoring/view/string', function () {
    var p = pv(new Date()), list = [];
    function add(tag, v) { var x = {}; x[tag] = { action: 'value', value: v }; list.push(x); }
    for (var i = 1; i <= 5; i++) {
      add('Q_PV_' + i, p['q_pv_' + i]); add('Q_SP_' + i, p['q_sp_' + i]);
      add('T_PV_' + i, p['t_pv_' + i]); add('T_SP_' + i, p['t_sp_' + i]);
    }
    ['f_wash', 'm_wash', 'oil', 'bc'].forEach(function (k) { add(k.toUpperCase() + '_PV', p[k + '_pv']); add(k.toUpperCase() + '_SP', p[k + '_sp']); });
    ['in_wash', 'in_q', 'in_oil', 'in_data', 'in_t', 'in_m_wash'].forEach(function (k) {
      add(k.toUpperCase() + '_PV', String(Math.round(p[k + '_pv'] * 100))); add(k.toUpperCase() + '_SP', String(Math.round(p[k + '_sp'] * 100)));
    });
    add('CP_PV_1', String(p.cp_pv_1)); add('CP_SP_1', String(p.cp_sp_1));
    add('CP_PV_2', String(p.cp_pv_2)); add('CP_SP_2', String(p.cp_sp_2));
    return { multiValues: list };
  });

  /* ───────────── 알람현황 패널 (monitoring/alarm) ───────────── */
  var PANEL = { 'AL-101': 15, 'AL-102': 14, 'AL-111': 23, 'AL-201': 65, 'AL-202': 40, 'AL-301': 56, 'AL-302': 72, 'AL-401': 62,
    'AL-402': 57, 'AL-501': 19, 'AL-502': 55, 'AL-601': 52, 'AL-701': 79, 'AL-801': 80 };
  M.any('/monitoring/alarm/list', function () {
    var data = {};
    for (var i = 1; i <= 96; i++) data['alarm_' + i] = 0;
    D.alarms().forEach(function (a) { if (!a.a_etime && PANEL[a.a_code]) data['alarm_' + PANEL[a.a_code]] = 1; });
    return { data: data };
  });

  /* ───────────── 알람이력 / 알람랭킹 ───────────── */
  function alarmsIn(s, e) {
    return D.alarms().filter(function (a) { return M.inRange(a.a_stime, s, e); });
  }
  M.any('/productionManagement/alarmRecordListAll/list', function (req) {
    var p = req.params;
    var rows = alarmsIn(p.s_sdate, p.s_edate).map(function (a, i) {
      return { idx: i + 1, a_addr: a.a_addr, a_desc: a.a_desc, a_stime: a.a_stime, a_etime: a.a_etime, a_level: a.a_level, dur_min: a.dur_min };
    });
    return { data: rows, last_page: 1 };
  });
  M.any('/productionManagement/alarmRanking/list', function (req) {
    var p = req.params, g = {}, arr = [];
    alarmsIn(p.s_sdate, p.s_edate).forEach(function (a) {
      var k = a.a_addr;
      if (!g[k]) { g[k] = { a_addr: a.a_addr, a_desc: a.a_desc, cnt: 0, dur_min: 0 }; arr.push(g[k]); }
      g[k].cnt++; g[k].dur_min = M.round(g[k].dur_min + a.dur_min, 1);
    });
    arr.sort(function (a, b) { return b.cnt - a.cnt || b.dur_min - a.dur_min; });
    arr.forEach(function (r, i) { r.idx = i + 1; });
    return { data: arr };
  });

  /* ───────────── 온도경향감시 (trend / handTrend) ───────────── */
  var signDb = M.db('c2_trendSign', function () {
    var d = M.days(), rows = [
      [d[0] + ' 11:58:00', '열전대 교체', '소입로 3존 K-type 열전대 단선 → 예비품 교체', '장현우'],
      [d[1] + ' 09:12:00', 'CP 보정', '샘플 탄소분석 결과 반영 CP -0.03% 보정', '박성진'],
      [d[1] + ' 16:44:00', '방청액 보충', '방청액 농도 8.1% → 10% 재조정', '이정호'],
      [d[2] + ' 02:57:00', 'RX가스 조정', '공기/LPG 혼합비 재조정, 노점 -2℃ 회복', '정대현']
    ];
    // 품종(패턴) 교체 메모 — 실제 LOT 흐름에서 각 날의 오전/오후 첫 교체 시점
    [[d[0], 13], [d[1], 9], [d[2], 9]].forEach(function (x) {
      for (var i = 1; i < LOTS.length; i++) {
        var l = LOTS[i], p = LOTS[i - 1];
        if (l.work_date === x[0] && M.toDate(l.start_time).getHours() >= x[1] && l.pattern !== p.pattern) {
          rows.push([l.start_time.slice(0, 16) + ':00', '패턴 변경', p.pattern + ' → ' + l.pattern + ' (' + l.prod_name + ') 레시피 전환', D.shiftWorker(l.work_date, 10)]);
          break;
        }
      }
    });
    rows.sort(function (a, b) { return a[0] < b[0] ? -1 : 1; });
    var now = new Date();
    return rows.filter(function (r) { return M.toDate(r[0]) <= now; }).map(function (r, i) {
      return { tc_cnt: i + 1, tc_regtime: r[0], tc_name: r[1], tc_desc: r[2], tc_user_name: r[3], tc_user_code: 1 };
    });
  }, 'tc_cnt');

  M.any('/monitoring/trend/sign/list', function () { return { data: signDb.all() }; });
  M.any('/monitoring/trend/sign/save', function (req) {
    var p = req.params;
    signDb.insert({ tc_regtime: p.tc_regtime ? (String(p.tc_regtime).length === 16 ? p.tc_regtime + ':00' : p.tc_regtime) : M.fmt(new Date()),
      tc_name: p.tc_name || '', tc_desc: p.tc_desc || '', tc_user_name: p.tc_user_name || '관리자', tc_user_code: p.tc_user_code || 1 });
    return { result: 'success', success: true };
  });

  M.any('/monitoring/trend/list', function (req) {
    var p = req.params, now = new Date();
    var s = M.toDate(p.startDate), e = M.toDate(p.endDate);
    if (!s || !e) return [];
    var first = M.toDate(M.days()[0] + ' 00:00:00');
    if (s < first) s = first;
    if (e > now) e = now;
    if (e <= s) return [];
    s = new Date(Math.ceil(s.getTime() / 60000) * 60000);
    var mins = (e - s) / 60000, step = Math.max(1, Math.ceil(mins / 1500)), stepMs = step * 60000;
    var signs = signDb.all().map(function (r) { return { t: M.toDate(r.tc_regtime).getTime(), r: r }; });
    var out = [];
    for (var t = s.getTime(); t <= e.getTime(); t += stepMs) {
      var row = pv(t);
      row.tc_val = null; row.tc_name = ''; row.tc_desc = ''; row.tc_cnt = null;
      row.lot_val = null; row.lot_name = ''; row.item_name = ''; row.cust_name = '';
      var li = lotIdxAt(t + stepMs - 1);
      if (li >= 0 && STARTS[li] >= t && STARTS[li] < t + stepMs) {
        var l = LOTS[li];
        row.lot_val = 1200; row.lot_name = l.lot_no; row.w_ci_lot = l.lot_no; row.item_name = l.prod_name; row.cust_name = l.cust_name;
      }
      for (var k = 0; k < signs.length; k++) {
        if (signs[k].t >= t && signs[k].t < t + stepMs) {
          row.tc_val = 1000; row.tc_cnt = signs[k].r.tc_cnt; row.tc_name = signs[k].r.tc_name; row.tc_desc = signs[k].r.tc_desc;
        }
      }
      out.push(row);
    }
    return out;
  });

  /* 알람이력 엑셀: 원본은 서버 엑셀(/alarmRecordListAll/excel)로 페이지 이동 → 데모에서는 화면 데이터로 브라우저에서 생성 */
  if (/\/productionManagement\/alarmRecord\/?$/.test(location.pathname)) {
    document.addEventListener('DOMContentLoaded', function () {
      var $ = window.jQuery; if (!$) return;
      $('#btnExcel').off('click').on('click', function () {
        /* global alarmTable */
        var rows = (typeof alarmTable !== 'undefined' && alarmTable) ? alarmTable.getData() : [];
        if (!window.XLSX || !rows.length) return;
        var data = rows.map(function (r) { return { 'No': r.idx, 'PLC주소': r.a_addr, '알람내용': r.a_desc, '발생시간': r.a_stime, '해제시간': r.a_etime || '미해제' }; });
        var ws = XLSX.utils.json_to_sheet(data); ws['!cols'] = [{ wch: 6 }, { wch: 10 }, { wch: 36 }, { wch: 20 }, { wch: 20 }];
        var wb = XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, '알람이력');
        XLSX.writeFile(wb, '알람이력_' + ($('#s_sdate').val() || '') + '_' + ($('#s_edate').val() || '') + '.xlsx');
      });
    });
  }
})();
