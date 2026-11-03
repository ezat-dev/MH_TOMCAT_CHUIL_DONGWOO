/* routes/c5-extra.js — 추가 화면 라우트 (섹션별 IIFE) */

/* ───────────── [C5] 설비효율현황(OEE) — /productionManagement/machineEfficiency/data ─────────────
 *   params: period = 'today' | 'yesterday' | '3d'
 *   D.lots() 중량 / D.downtimes() 정지 이력으로 시간대별 A·P·Q 를 만들고 그것을 합산한다 (OEE = A×P×Q).
 */
(function () {
  var M = window.MOCK, D = M && M.D;
  if (!M || !D) return;

  var MIN = 60000;
  function ov(a1, a2, b1, b2) { var s = Math.max(a1, b1), e = Math.min(a2, b2); return e > s ? (e - s) / MIN : 0; }
  function r1(v) { return M.round(v, 1); }
  function pct(v) { return M.round(v * 100, 1); }

  function reasonOf(d) {
    var m = d.non_time_memo || '';
    if (/품종 교체/.test(m)) return '품종 교체';
    if (/일상점검/.test(m)) return '일상점검';
    if (/PM/.test(m)) return '예방보전(PM)';
    if (/열전대/.test(m)) return '열전대 단선';
    if (/메쉬벨트|체인/.test(m)) return '메쉬벨트 구동부';
    if (/RX가스/.test(m)) return 'RX가스 유량';
    if (/교반기/.test(m)) return '소입유 교반기';
    if (/세척/.test(m)) return '세척액·수위';
    if (/방청/.test(m)) return '방청액 농도';
    if (/정전/.test(m)) return '순간정전';
    if (/자재|원자재/.test(m)) return '자재 대기';
    if (/경도/.test(m)) return '품질 이상 조치';
    return d.info_list || '기타';
  }

  // 정지 이벤트 (ms 단위)
  function stops() {
    var now = Date.now();
    return D.downtimes().map(function (d) {
      var s = M.toDate(d.start_time).getTime();
      var e = d.end_time ? M.toDate(d.end_time).getTime() : now;
      return { s: s, e: e, cat: d.info_list, planned: d.info_list === '계획정지', equip: d.sub_equip, reason: reasonOf(d),
        min: d.minutes, memo: d.non_time_memo, start: d.start_time, end: d.end_time, worker: d.worker, alarm: d.alarm_code };
    });
  }

  // LOT 점유 구간 [start, 다음 LOT 시작) + 표준시간·불량중량
  var _occ = null;
  function occ() {
    if (_occ) return _occ;
    var now = Date.now();
    var ls = D.lots().filter(function (l) { return l.status !== '대기'; });
    _occ = ls.map(function (l, i) {
      var p = D.product(l.prod_code);
      var s = M.toDate(l.start_time).getTime();
      var nx = i + 1 < ls.length ? M.toDate(ls[i + 1].start_time).getTime() : now;
      var r = M.rng('oee-def-' + l.lot_no);
      var defRate = l.result === '불합격' ? 1 : r.float(0.002, 0.009); // 불합격 LOT 전량 + 낙하·재작업 소량
      return { s: s, e: Math.max(nx, s + MIN), lot: l, std: p.cycle_min, kg: l.weight, defKg: l.weight * defRate };
    });
    return _occ;
  }

  // 1시간 버킷 계산
  function hourBucket(hs, he, st, oc, avg) {
    var cal = (he - hs) / MIN, plan = 0, down = 0, i;
    for (i = 0; i < st.length; i++) {
      var m = ov(hs, he, st[i].s, st[i].e);
      if (st[i].planned) plan += m; else down += m;
    }
    plan = Math.min(plan, cal); down = Math.min(down, cal - plan);
    var run = cal - plan - down;
    var kg = 0, def = 0, std = 0, occM = 0;
    for (i = 0; i < oc.length; i++) {
      var o = oc[i], m2 = ov(hs, he, o.s, o.e);
      if (!m2) continue;
      var f = m2 / ((o.e - o.s) / MIN);
      kg += o.kg * f; def += o.defKg * f; std += o.std * f; occM += m2;
    }
    var p;
    if (occM < cal * 0.3) { // LOT 기록 이전 구간 → 평균 실적으로 보정
      kg = avg.kgPerMin * cal; def = kg * avg.defRate; p = avg.p;
    } else {
      p = std / occM;
    }
    p = Math.max(0.78, Math.min(0.985, p + (M.wave('oee-p', new Date(hs), 0, 0.018, 0.008, 300))));
    var runRatio = cal ? run / cal : 0;
    kg *= runRatio; def *= runRatio;
    return { cal: cal, plan: plan, down: down, run: run, p: p, kg: kg, def: def };
  }

  function avgOf(oc) {
    var kg = 0, def = 0, std = 0, m = 0;
    oc.forEach(function (o) { var mm = (o.e - o.s) / MIN; kg += o.kg; def += o.defKg; std += o.std; m += mm; });
    return { kgPerMin: m ? kg / m : 10, defRate: kg ? def / kg : 0.005, p: m ? std / m : 0.88 };
  }

  function sum(hs) {
    var t = { cal: 0, plan: 0, down: 0, run: 0, pw: 0, kg: 0, def: 0 };
    hs.forEach(function (h) { t.cal += h.cal; t.plan += h.plan; t.down += h.down; t.run += h.run; t.pw += h.p * h.run; t.kg += h.kg; t.def += h.def; });
    var load = t.cal - t.plan;
    var a = load > 0 ? t.run / load : 0, p = t.run > 0 ? t.pw / t.run : 0, q = t.kg > 0 ? 1 - t.def / t.kg : 1;
    return { a: a, p: p, q: q, oee: a * p * q, cal: t.cal, plan: t.plan, down: t.down, run: t.run, load: load, kg: t.kg, def: t.def };
  }

  function buckets(ws, we) {
    var st = stops(), oc = occ(), avg = avgOf(oc), out = [];
    for (var hs = ws; hs < we; hs += 60 * MIN) {
      var he = Math.min(we, hs + 60 * MIN);
      var b = hourBucket(hs, he, st, oc, avg);
      b.t = hs;
      out.push(b);
    }
    return out;
  }

  function kpiOf(ws, we) {
    var hs = buckets(ws, we), s = sum(hs), st = stops();
    var lots = occ().filter(function (o) { return o.s >= ws && o.s < we; });
    var fails = lots.filter(function (o) { return o.lot.result === '불합격'; }).length;
    var ev = st.filter(function (x) { return x.s < we && x.e > ws; });
    var breaks = ev.filter(function (x) { return x.cat === '설비고장'; });
    var brMin = breaks.reduce(function (a, x) { return a + ov(ws, we, x.s, x.e); }, 0);
    return {
      oee: pct(s.oee), a: pct(s.a), p: pct(s.p), q: M.round(s.q * 100, 2),
      cal_min: Math.round(s.cal), load_min: Math.round(s.load), run_min: Math.round(s.run),
      down_min: Math.round(s.down), plan_min: Math.round(s.plan),
      kg: Math.round(s.kg), good_kg: Math.round(s.kg - s.def), defect_kg: r1(s.def),
      lots: lots.length, fail_lots: fails, stops: ev.length, breakdowns: breaks.length,
      mttr: breaks.length ? r1(brMin / breaks.length) : 0,
      mtbf: breaks.length ? r1(s.run / 60 / breaks.length) : r1(s.run / 60),
      kg_per_h: s.run > 0 ? Math.round(s.kg / (s.run / 60)) : 0,
      _s: s, _h: hs
    };
  }

  var EQUIPS = [
    { code: 'E02', name: '소입로', match: '소입로', type: '열처리로', pf: 1.0, qf: 0 },
    { code: 'E03', name: '소려로', match: '소려로', type: '열처리로', pf: 1.012, qf: 0.0006 },
    { code: 'E06', name: '유조(소입유)', match: '유조(소입유)', type: '공용설비', pf: 1.02, qf: 0.0008 },
    { code: 'E04', name: '세척 1호기', match: '세척 1호기', type: '세척기', pf: 1.035, qf: 0.0012 },
    { code: 'E05', name: '세척 2호기', match: '세척 2호기', type: '세척기', pf: 1.028, qf: 0.0009 },
    { code: 'E07', name: '방청기', match: '방청기', type: '공용설비', pf: 1.045, qf: 0.0014 },
    { code: 'E08', name: 'RX 가스발생기', match: 'RX 가스발생기', type: '공용설비', pf: 1.05, qf: 0.0016 }
  ];

  function equipRows(ws, we, line) {
    var st = stops(), now = Date.now();
    return EQUIPS.map(function (eq) {
      var mine = st.filter(function (x) { return (x.equip === eq.match || x.equip === '연속열처리로') && x.s < we && x.e > ws; });
      var cal = (we - ws) / MIN, plan = 0, down = 0, own = 0;
      mine.forEach(function (x) {
        var m = ov(ws, we, x.s, x.e);
        if (x.planned) plan += m; else down += m;
        if (x.equip === eq.match) own++;
      });
      var r = M.rng('oee-eq-' + eq.code + ws);
      // 단시간 정지(5분 미만 순간정지) — 이력 미등록분, 설비별로 소량
      var shifts8 = cal / 480;
      down += shifts8 * r.float(1.2, 5.5);
      own += Math.round(shifts8 * r.float(0.4, 1.4));
      var load = cal - plan, run = Math.max(0, load - down);
      var a = load > 0 ? run / load : 0;
      var p = Math.min(0.992, line.p * eq.pf + r.float(-0.006, 0.006));
      var q = Math.min(0.9995, line.q + eq.qf);
      var running = st.some(function (x) { return x.equip === eq.match && x.s <= now && x.e > now; });
      var lineStop = st.some(function (x) { return x.equip === '연속열처리로' && x.s <= now && x.e > now; });
      return {
        code: eq.code, name: eq.name, type: eq.type,
        status: running ? '정지' : (lineStop ? '대기' : '가동'),
        a: pct(a), p: pct(p), q: M.round(q * 100, 2), oee: pct(a * p * q),
        run_min: Math.round(run), down_min: Math.round(down), plan_min: Math.round(plan), stops: own
      };
    });
  }

  M.any('/productionManagement/machineEfficiency/data', function (req) {
    var period = (req.params.period || 'today');
    var days = M.days(), now = Date.now();
    var d0 = function (i) { return M.toDate(days[i] + ' 00:00:00').getTime(); };
    var ws, we, pws = null, pwe = null, label;
    if (period === 'yesterday') { ws = d0(1); we = d0(2); pws = d0(0); pwe = d0(1); label = days[1]; }
    else if (period === '3d') { ws = d0(0); we = now; label = days[0] + ' ~ ' + days[2]; }
    else { period = 'today'; ws = d0(2); we = now; pws = d0(1); pwe = now - 1440 * MIN; label = days[2]; }

    var k = kpiOf(ws, we), s = k._s, hs = k._h;
    var prev = pws != null ? kpiOf(pws, pwe) : null;

    var hourly = hs.map(function (h) {
      var load = h.cal - h.plan, a = load > 0 ? h.run / load : 0, q = h.kg > 0 ? 1 - h.def / h.kg : 1;
      var dt = new Date(h.t);
      return { t: M.fmt(dt, 'MM-DD HH:00'), hh: M.fmt(dt, 'HH'), ts: h.t, a: pct(a), p: pct(h.p), q: M.round(q * 100, 2),
        oee: h.run > 0 ? pct(a * h.p * q) : 0, kg: Math.round(h.kg), run: Math.round(h.run), down: Math.round(h.down), plan: Math.round(h.plan) };
    });

    // 교대별 (주간 08~20 / 야간 20~08)
    var day = hs.filter(function (h) { var x = new Date(h.t).getHours(); return x >= 8 && x < 20; });
    var night = hs.filter(function (h) { var x = new Date(h.t).getHours(); return x < 8 || x >= 20; });
    var shifts = [['주간', '08:00~20:00', day], ['야간', '20:00~08:00', night]].map(function (x) {
      var t = sum(x[2]);
      return { name: x[0], range: x[1], oee: pct(t.oee), a: pct(t.a), p: pct(t.p), q: M.round(t.q * 100, 2), kg: Math.round(t.kg), run_min: Math.round(t.run), down_min: Math.round(t.down) };
    });

    // 일자별 시간 구성 (3일 고정)
    var daily = days.map(function (dd, i) {
      var s0 = d0(i), e0 = Math.min(s0 + 1440 * MIN, now);
      var t = sum(buckets(s0, e0));
      return { date: dd, label: M.fmt(M.toDate(dd), 'MM/DD') + (i === 2 ? ' (오늘)' : i === 1 ? ' (어제)' : ''),
        run: r1(t.run / 60), down: r1(t.down / 60), plan: r1(t.plan / 60), idle: r1(Math.max(0, 1440 - t.cal) / 60),
        oee: pct(t.oee), kg: Math.round(t.kg) };
    });

    // 비가동 파레토
    var map = {}, events = [];
    stops().forEach(function (x) {
      var m = ov(ws, we, x.s, x.e);
      if (!m) return;
      var key = x.reason;
      if (!map[key]) map[key] = { reason: key, cat: x.cat, min: 0, count: 0 };
      map[key].min += m; map[key].count++;
      events.push({ start: x.start, end: x.end, equip: x.equip, cat: x.cat, reason: x.reason, min: Math.round(m), memo: x.memo, worker: x.worker, alarm: x.alarm });
    });
    var pareto = Object.keys(map).map(function (k2) { var o = map[k2]; o.min = Math.round(o.min); return o; })
      .sort(function (a, b) { return b.min - a.min; });
    var tot = pareto.reduce(function (a, o) { return a + o.min; }, 0), cum = 0;
    pareto.forEach(function (o) { cum += o.min; o.cum = tot ? r1(cum / tot * 100) : 0; });
    events.sort(function (a, b) { return a.start < b.start ? 1 : -1; });

    delete k._s; delete k._h;
    if (prev) { delete prev._s; delete prev._h; }
    return {
      success: true, period: period, label: label, updated: M.fmt(new Date()),
      line: '열처리 연속로 1라인',
      target: { oee: 85, a: 90, p: 92, q: 99.5, kg_per_h: 640 },
      kpi: k, prev: prev, hourly: hourly, shifts: shifts, daily: daily, pareto: pareto, events: events,
      equipments: equipRows(ws, we, s)
    };
  });
})();
