/*
 * 동우 데모 공통 기준 데이터 — BCF(배치형 침탄로) 1~12호기
 * MOCK.D.* 로 접근. 3일치 작업(차지) 흐름은 MOCK.D.charges() 하나를 기준으로 한다.
 */
(function () {
  var M = window.MOCK;
  var D = M.D = M.D || {};

  D.company = '데모 사업장';

  D.customers = [
    { cust_code: 'C01', cust_name: '현성기어',   tel: '055-264-1180', manager: '김도윤' },
    { cust_code: 'C02', cust_name: '명진오토',   tel: '053-582-4471', manager: '박서준' },
    { cust_code: 'C03', cust_name: '대광정밀',   tel: '051-972-3310', manager: '이하은' },
    { cust_code: 'C04', cust_name: '성우트랜스', tel: '031-354-8826', manager: '최지훈' },
    { cust_code: 'C05', cust_name: '신흥중공업', tel: '055-336-9012', manager: '정예린' }
  ];

  // 침탄 열처리 품목
  D.products = [
    { prod_code: 'DW-101', prod_name: '링기어',          part_no: '45711-3D100', cust_code: 'C01', material: 'SCM420H', depth: '0.8~1.2', hrc_min: 58, hrc_max: 62, recipe: 'CQ-920-08', temp: 920, cp: 0.85, hours: 7.5 },
    { prod_code: 'DW-102', prod_name: '피니언 기어',     part_no: '45720-3D200', cust_code: 'C01', material: 'SCM420H', depth: '0.7~1.0', hrc_min: 58, hrc_max: 62, recipe: 'CQ-920-07', temp: 920, cp: 0.85, hours: 6.5 },
    { prod_code: 'DW-201', prod_name: '사이드 기어',     part_no: '45831-2A000', cust_code: 'C02', material: 'SCr420H', depth: '0.6~0.9', hrc_min: 58, hrc_max: 63, recipe: 'CQ-930-06', temp: 930, cp: 0.80, hours: 6.0 },
    { prod_code: 'DW-202', prod_name: '아웃풋 샤프트',   part_no: '43281-4C000', cust_code: 'C02', material: 'SCM822H', depth: '1.0~1.4', hrc_min: 57, hrc_max: 62, recipe: 'CQ-930-12', temp: 930, cp: 0.90, hours: 9.0 },
    { prod_code: 'DW-301', prod_name: '싱크로 허브',     part_no: '43370-2B500', cust_code: 'C03', material: 'SCr420H', depth: '0.5~0.8', hrc_min: 56, hrc_max: 61, recipe: 'CQ-910-05', temp: 910, cp: 0.80, hours: 5.5 },
    { prod_code: 'DW-302', prod_name: '카운터 기어',     part_no: '43290-3A700', cust_code: 'C03', material: 'SCM420H', depth: '0.8~1.1', hrc_min: 58, hrc_max: 62, recipe: 'CQ-920-08', temp: 920, cp: 0.85, hours: 7.0 },
    { prod_code: 'DW-401', prod_name: '유성기어 캐리어', part_no: '45920-4F000', cust_code: 'C04', material: 'SCM420H', depth: '0.7~1.0', hrc_min: 58, hrc_max: 62, recipe: 'CQ-920-07', temp: 920, cp: 0.85, hours: 6.5 },
    { prod_code: 'DW-402', prod_name: '드라이브 피니언', part_no: '53010-2J100', cust_code: 'C04', material: 'SNCM420', depth: '1.0~1.3', hrc_min: 58, hrc_max: 63, recipe: 'CQ-930-10', temp: 930, cp: 0.90, hours: 8.5 },
    { prod_code: 'DW-501', prod_name: '감속기 웜샤프트', part_no: 'RW-2240-S',   cust_code: 'C05', material: 'SCM415',  depth: '0.6~0.9', hrc_min: 57, hrc_max: 61, recipe: 'CQ-910-06', temp: 910, cp: 0.80, hours: 6.0 },
    { prod_code: 'DW-502', prod_name: '스플라인 샤프트', part_no: 'SS-1180-K',   cust_code: 'C05', material: 'SCM420H', depth: '0.8~1.2', hrc_min: 58, hrc_max: 62, recipe: 'CQ-920-08', temp: 920, cp: 0.85, hours: 7.5 }
  ];

  D.workers = [
    { emp_code: 'E001', id: 'ez',     emp_name: '관리자', dept: '관리팀', position: '팀장', phone: '010-2231-5501' },
    { emp_code: 'E002', id: 'shkim',  emp_name: '김상훈', dept: '생산1팀', position: '반장', phone: '010-3381-2290' },
    { emp_code: 'E003', id: 'jwlee',  emp_name: '이재원', dept: '생산1팀', position: '주임', phone: '010-5512-7734' },
    { emp_code: 'E004', id: 'mjpark', emp_name: '박민준', dept: '생산2팀', position: '반장', phone: '010-9927-1180' },
    { emp_code: 'E005', id: 'hschoi', emp_name: '최혜수', dept: '품질팀', position: '대리', phone: '010-6643-3021' },
    { emp_code: 'E006', id: 'ysjung', emp_name: '정용석', dept: '설비보전팀', position: '과장', phone: '010-4108-5576' },
    { emp_code: 'E007', id: 'dhkang', emp_name: '강도현', dept: '생산2팀', position: '사원', phone: '010-8852-6612' },
    { emp_code: 'E008', id: 'jhyoon', emp_name: '윤지환', dept: '설비보전팀', position: '주임', phone: '010-2276-9043' }
  ];

  // 설비: BCF 1~12호기 (배치형 침탄 소입로) + 부대설비
  D.furnaces = [];
  for (var i = 1; i <= 12; i++) {
    D.furnaces.push({ no: i, code: 'BCF' + i, name: 'BCF ' + i + '호기', label: '침탄' + i, type: '배치형 침탄로', maker: i <= 6 ? '대한로공업' : '동양열처리기계', install_date: (2012 + Math.floor((i - 1) / 3)) + '-0' + (1 + (i % 9)) + '-15' });
  }
  D.auxEquipments = ['템퍼로 1호기', '템퍼로 2호기', '세척기 1호기', '세척기 2호기', '변성로(RX) 1호기', '변성로(RX) 2호기', '냉각탑', '공기압축기', '유조 냉각기'];

  D.product = function (code) { for (var i = 0; i < D.products.length; i++) if (D.products[i].prod_code === code) return D.products[i]; return D.products[0]; };
  D.customer = function (code) { for (var i = 0; i < D.customers.length; i++) if (D.customers[i].cust_code === code) return D.customers[i]; return D.customers[0]; };

  // 설비 상태: 대부분 가동, 일부 대기/정지 (화면에 다양한 상태가 보이도록 고정)
  D.furnaceState = function (no) { return ({ 4: '대기', 9: '정지' })[no] || '가동'; };

  /*
   * 3일치 차지(배치) 이력 — 호기별로 그제 06:00부터 연속 배치.
   *   charge_no, furnace_no, furnace, prod_code, prod_name, part_no, cust_name, material,
   *   recipe, temp, cp, qty, weight, tray, start_time, end_time('' = 진행중), status, worker,
   *   hardness, depth_result, result
   */
  var _charges = null;
  D.charges = function () {
    if (_charges) return _charges;
    var days = M.days();
    var now = new Date();
    var out = [];
    D.furnaces.forEach(function (f) {
      var r = M.rng('dw-charge-' + f.no + '-' + days[0]);
      var t = M.toDate(days[0] + ' 06:00:00');
      t = new Date(t.getTime() + r.int(0, 180) * 60000);
      var n = 0;
      while (t < now) {
        var p = D.products[r.int(0, D.products.length - 1)];
        var c = D.customer(p.cust_code);
        var dur = Math.round(p.hours * 60 + r.int(-20, 30));
        var end = new Date(t.getTime() + dur * 60000);
        var state = D.furnaceState(f.no);
        var running = end > now;
        if (running && state !== '가동') break; // 대기/정지 호기는 진행중 배치 없음
        n++;
        var qty = r.int(18, 46) * 20;
        var hard = M.round(r.normal((p.hrc_min + p.hrc_max) / 2, 0.9), 1);
        var dmin = parseFloat(p.depth.split('~')[0]), dmax = parseFloat(p.depth.split('~')[1]);
        var depth = M.round(r.float(dmin + 0.03, dmax - 0.03), 2);
        out.push({
          charge_no: 'B' + M.pad(f.no) + '-' + M.fmt(t, 'MMDD') + '-' + M.pad(n),
          lot_no: 'DW' + M.fmt(t, 'YYMMDD') + '-' + M.pad(f.no) + M.pad(n),
          furnace_no: f.no, furnace: f.name, furnace_code: f.code,
          prod_code: p.prod_code, prod_name: p.prod_name, part_no: p.part_no, material: p.material,
          cust_code: c.cust_code, cust_name: c.cust_name,
          recipe: p.recipe, temp: p.temp, cp: p.cp, depth_spec: p.depth, hrc_min: p.hrc_min, hrc_max: p.hrc_max,
          qty: qty, weight: M.round(qty * r.float(0.6, 1.4), 1), tray: r.int(4, 8),
          work_date: M.fmt(t, 'YYYY-MM-DD'),
          start_time: M.fmt(t), end_time: running ? '' : M.fmt(end), plan_end_time: M.fmt(end),
          status: running ? '진행중' : '완료',
          progress: running ? Math.max(1, Math.min(99, Math.round((now - t) / (end - t) * 100))) : 100,
          worker: r.pick(['김상훈', '이재원', '박민준', '강도현']),
          hardness: running ? null : hard,
          depth_result: running ? null : depth,
          result: running ? '' : ((hard < p.hrc_min || hard > p.hrc_max) ? '불합격' : '합격')
        });
        t = new Date(end.getTime() + r.int(20, 70) * 60000);
      }
    });
    out.sort(function (a, b) { return a.start_time < b.start_time ? -1 : 1; });
    _charges = out;
    return out;
  };
  D.chargesIn = function (from, to, furnaceNo) {
    return D.charges().filter(function (c) {
      return M.inRange(c.start_time, from, to) && (!furnaceNo || String(c.furnace_no) === String(furnaceNo));
    });
  };
  D.currentCharge = function (furnaceNo) {
    var cs = D.charges();
    for (var i = cs.length - 1; i >= 0; i--) if (cs[i].furnace_no === +furnaceNo && cs[i].status === '진행중') return cs[i];
    return null;
  };

  D.alarmCodes = [
    { code: 'A001', name: '노내 온도 상한 초과', level: '중' },
    { code: 'A002', name: '노내 온도 하한 미달', level: '중' },
    { code: 'A003', name: 'CP(탄소포텐셜) 편차 이탈', level: '경' },
    { code: 'A004', name: '분위기 가스 유량 저하', level: '중' },
    { code: 'A005', name: '유조 온도 상승', level: '경' },
    { code: 'A006', name: '교반팬 모터 과부하', level: '중' },
    { code: 'A007', name: '도어 개폐 이상', level: '경' },
    { code: 'A008', name: '엘리베이터 위치 이상', level: '중' },
    { code: 'A009', name: '버너 착화 실패', level: '중' },
    { code: 'A010', name: '냉각수 유량 저하', level: '경' },
    { code: 'A011', name: '열전대 단선', level: '중' },
    { code: 'A012', name: '트레이 이송 지연', level: '경' }
  ];

  /*
   * [D2] 공용 알람 이력 — 3일치, 호기별. 알람 이력/랭킹/배지가 모두 이것을 기준으로 한다.
   *   id, plcId('bcf_NN'), furnace_no, furnace, code, tagName, alarmMsg, level(1위험~4정보),
   *   level_name(중/경), valueAtOccur, occurTime, clearTime(''=활성), ackTime, duration_min, active
   * 활성 알람: 9호기 열전대 단선(정지 원인), 5호기 CP 편차, 2호기 유조 온도 상승
   */
  var _alarms = null, _alarmsAt = 0;
  D.alarmMeta = {
    A001: { tag: 'TEMP_HI', lv: 1, w: 3 },  A002: { tag: 'TEMP_LO', lv: 2, w: 4 },
    A003: { tag: 'CP_DEV', lv: 3, w: 10 },  A004: { tag: 'GAS_FLOW_LO', lv: 2, w: 5 },
    A005: { tag: 'OIL_TEMP_HI', lv: 3, w: 6 }, A006: { tag: 'FAN_OVL', lv: 2, w: 2 },
    A007: { tag: 'DOOR_ERR', lv: 4, w: 8 },  A008: { tag: 'ELEV_POS', lv: 2, w: 3 },
    A009: { tag: 'BURNER_IGN', lv: 2, w: 2 }, A010: { tag: 'CW_FLOW_LO', lv: 3, w: 4 },
    A011: { tag: 'TC_BREAK', lv: 1, w: 1 },  A012: { tag: 'TRAY_DELAY', lv: 4, w: 7 }
  };
  function alarmValue(code, r, f) {
    switch (code) {
      case 'A001': return M.round(r.float(938, 946), 1);
      case 'A002': return M.round(r.float(872, 891), 1);
      case 'A003': return M.round(r.pick([r.float(0.62, 0.70), r.float(1.02, 1.10)]), 3);
      case 'A004': return M.round(r.float(5.1, 6.4), 1);
      case 'A005': return M.round(r.float(91, 98), 1);
      case 'A006': return M.round(r.float(17.8, 19.6), 1);
      case 'A007': return 'OPEN';
      case 'A008': return 'POS-' + r.int(1, 4);
      case 'A009': return r.int(2, 3) + '회';
      case 'A010': return M.round(r.float(11.2, 13.8), 1);
      case 'A011': return 1372;
      default: return r.int(150, 240);
    }
  }
  D.alarms = function () {
    if (_alarms && Date.now() - _alarmsAt < 60000) return _alarms;
    var days = M.days(), now = new Date(), out = [], seq = 0;
    var t0 = M.toDate(days[0] + ' 00:00:00').getTime();
    var codes = D.alarmCodes, wsum = 0;
    codes.forEach(function (c) { wsum += D.alarmMeta[c.code].w; });
    function mk(f, c, occ, clr, ack, r) {
      var meta = D.alarmMeta[c.code];
      seq++;
      return {
        id: seq, alarmId: seq, plcId: 'bcf_' + M.pad(f.no), furnace_no: f.no, furnace: f.name, equipName: f.name,
        code: c.code, alarmCode: c.code, tagName: f.code + '.' + meta.tag, alarmMsg: ({ A003: 'CP 편차 이탈', A004: '분위기가스 유량 저하' })[c.code] || c.name, alarm_name: c.name,
        level: meta.lv, level_name: c.level, valueAtOccur: alarmValue(c.code, r, f),
        occurTime: M.fmt(occ), clearTime: clr ? M.fmt(clr) : '', ackTime: ack ? M.fmt(ack) : '',
        duration_min: Math.max(1, Math.round(((clr || now) - occ) / 60000)), active: !clr
      };
    }
    var nine = D.chargesIn(null, null, 9), nineStop = nine.length ? M.toDate(nine[nine.length - 1].end_time) : M.addMinutes(now, -300);
    D.furnaces.forEach(function (f) {
      var r = M.rng('dw-alarm-' + f.no + '-' + days[0]);
      var factor = ({ 2: 1.6, 7: 1.8, 11: 1.4, 5: 1.2, 4: 0.5, 9: 0.8 })[f.no] || 1;
      var n = Math.round(15 * factor) + r.int(-2, 3);
      for (var i = 0; i < n; i++) {
        var occ = new Date(t0 + r() * 3 * 86400000);
        var x = r() * wsum, c = codes[0];
        for (var k = 0; k < codes.length; k++) { x -= D.alarmMeta[codes[k].code].w; if (x <= 0) { c = codes[k]; break; } }
        var chronic = ({ 2: 'A005', 7: 'A012', 5: 'A003', 11: 'A001', 12: 'A007', 1: 'A003', 3: 'A010', 6: 'A004', 8: 'A008', 10: 'A003' })[f.no];
        if (chronic && r.chance(0.35)) c = codes.filter(function (q) { return q.code === chronic; })[0];
        var dur = Math.max(1, Math.round(Math.exp(r.normal(2.0, 0.9)) + (c.level === '중' ? 6 : 0)));
        if (r.chance(0.05)) dur += r.int(40, 120);
        var clr = M.addMinutes(occ, dur);
        var ack = M.addMinutes(occ, Math.max(0, Math.round(dur * r.float(0.1, 0.6))));
        if (clr > now) continue;
        if (f.no === 9 && occ > nineStop) continue;
        out.push(mk(f, c, occ, clr, ack, r));
      }
    });
    var cA = function (code) { for (var i = 0; i < codes.length; i++) if (codes[i].code === code) return codes[i]; };
    var ra = M.rng('dw-alarm-active-' + days[0]);
    var a9 = M.addMinutes(nineStop, -4);
    out.push(mk(D.furnaces[8], cA('A011'), a9, null, M.addMinutes(a9, 6), ra));
    var a5 = new Date(now.getTime() - 23 * 60000); a5.setSeconds(17);
    out.push(mk(D.furnaces[4], cA('A003'), a5, null, null, ra));
    var a2 = new Date(now.getTime() - 9 * 60000); a2.setSeconds(42);
    out.push(mk(D.furnaces[1], cA('A005'), a2, null, null, ra));
    out.sort(function (a, b) { return a.occurTime < b.occurTime ? 1 : -1; });
    _alarms = out; _alarmsAt = Date.now();
    return out;
  };
  D.activeAlarms = function () { return D.alarms().filter(function (a) { return a.active; }); };

  // [D2] lot_no 보정: M.fmt 는 'YY' 토큰이 없어 'DWYY1102-..' 로 나오므로 연도 2자리로 치환
  var _rawCharges = D.charges;
  D.charges = function () {
    var cs = _rawCharges();
    if (cs.length && cs[0].lot_no.indexOf('DWYY') === 0) {
      cs.forEach(function (c) { c.lot_no = c.lot_no.replace(/^DWYY/, 'DW' + c.start_time.slice(2, 4)); });
    }
    return cs;
  };
})();
