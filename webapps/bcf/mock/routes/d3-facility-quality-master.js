/* routes/d3-facility-quality-master.js
 * 설비보존관리(정기보전/일상점검/부대설비/스페어파트/BACKUP/소모재) · 품질(F/PROOF) · 기준정보(사용자/권한)
 */
(function () {
  var M = window.MOCK, D = M.D;
  var PATH = location.pathname;
  var ok = function (extra) { var o = { success: true, result: 'success' }; if (extra) for (var k in extra) o[k] = extra[k]; return o; };
  var today = function () { return M.startOfDay(new Date()); };
  var dstr = function (n) { return M.fmt(M.addDays(today(), n), 'YYYY-MM-DD'); };
  var num = function (v) { var f = parseFloat(String(v == null ? '' : v).replace(/[^0-9.\-]/g, '')); return isNaN(f) ? null : f; };
  function body(req) { return req.params || {}; }

  /* ═════════════════════════ 권한 (공통) ═════════════════════════ */
  // common_style.jsp 는 '/main_1/<page>/sample_pro/perm/my' 로 호출하므로 접미사로 매칭
  M.get(/\/perm\/my$/, function () { return {}; });

  /* ═════════════════════════ 사용자 관리 ═════════════════════════ */
  var EXTRA_USERS = [
    { id: 'sjoh',   emp_name: '오세진', dept: '품질팀',   position: '사원', phone: '010-7734-2018' },
    { id: 'mkhan',  emp_name: '한미경', dept: '관리팀',   position: '대리', phone: '010-3390-6627' },
    { id: 'thlim',  emp_name: '임태호', dept: '생산1팀',  position: '사원', phone: '010-5821-4409', off: true },
    { id: 'gwseo',  emp_name: '서광우', dept: '생산2팀',  position: '주임', phone: '010-2087-3375' }
  ];
  var emps = M.db('d3_emp', function () {
    var list = D.workers.concat(EXTRA_USERS);
    return list.map(function (w, i) {
      var reg = M.addDays(today(), -(820 - i * 61));
      return {
        emp_id: i + 1, id: w.id, emp_name: w.emp_name, dept_name: w.dept, title_name: w.position,
        mobile_no: w.phone, direct_no: '055-312-' + (2100 + i * 7), reg_date: M.fmt(reg, 'YYYY-MM-DD'),
        use_yn: w.off ? 'N' : 'Y', emp_code: w.emp_code || ('E' + M.pad(i + 1, 3))
      };
    });
  }, 'emp_id');

  M.get('/emp/list', function () { return ok({ data: emps.all() }); });
  M.post('/emp/save', function (req) {
    var b = body(req);
    var row = { id: b.id, emp_name: b.emp_name, dept_name: b.dept_name, title_name: b.title_name, mobile_no: b.mobile_no, direct_no: b.direct_no };
    if (b.emp_id) emps.update(b.emp_id, row);
    else { row.reg_date = M.today(); row.use_yn = 'Y'; emps.insert(row); }
    return ok();
  });
  M.post('/emp/toggle', function (req) {
    var r = emps.find(body(req).emp_id); if (r) emps.update(r.emp_id, { use_yn: r.use_yn === 'Y' ? 'N' : 'Y' });
    return ok();
  });
  M.post('/emp/delete', function (req) { emps.remove(body(req).emp_id); return ok(); });

  /* ═════════════════════════ 권한 부여 ═════════════════════════ */
  var PAGE_URLS = ['main/monitor', 'equip/monitor', 'equip/detail', 'work/list', 'work/now1', 'work/now2', 'trend', 'alarm/history', 'alarm/ranking',
    'calib/status', 'inspect/daily', 'auxiliary/inspection', 'spare/parts', 'facility/backup', 'consumable/ledger', 'inspect/fproof', 'inspect/fprooflist',
    'user/manage', 'user/permission'];
  var FACILITY = ['calib/status', 'inspect/daily', 'auxiliary/inspection', 'spare/parts', 'facility/backup', 'consumable/ledger'];
  var QUALITY = ['inspect/fproof', 'inspect/fprooflist'];
  var ADMIN = ['user/manage', 'user/permission'];
  function defaultPerms(emp) {
    var dept = (emp && emp.dept_name) || '';
    var title = (emp && emp.title_name) || '';
    var lead = /팀장|과장|반장/.test(title);
    return PAGE_URLS.map(function (u) {
      var v = 'Y', a = 'Y', e = 'Y', d = 'Y';
      if (dept !== '관리팀') {
        if (ADMIN.indexOf(u) >= 0) { v = 'N'; a = 'N'; e = 'N'; d = 'N'; }
        else {
          var own = (dept === '설비보전팀' && FACILITY.indexOf(u) >= 0) || (dept === '품질팀' && QUALITY.indexOf(u) >= 0) ||
                    (/생산/.test(dept) && (u.indexOf('work/') === 0 || u === 'inspect/daily' || u === 'consumable/ledger'));
          if (!own) { a = 'N'; e = 'N'; d = 'N'; }
          else if (!lead) d = 'N';
        }
      }
      return { pageUrl: u, canView: v, canAdd: a, canEdit: e, canDel: d };
    });
  }
  var perms = M.db('d3_perm', function () { return []; }, 'empId');
  M.get('/perm/list', function (req) {
    var id = req.params.empId;
    var saved = perms.find(id);
    return saved ? saved.perms : defaultPerms(emps.find(id));
  });
  M.post('/perm/save', function (req) {
    var b = body(req); perms.upsert({ empId: String(b.empId), perms: b.perms || [] });
    return ok();
  });

  /* ═════════════════════════ 정기보전 ═════════════════════════ */
  var calib = M.db('d3_calib', function () {
    var H = ['정용석', '윤지환'];
    var rows = [
      // [구분, 설비, 항목, 내용, 예정일(오늘기준 일수), 상태, 연기사유]
      ['퀜칭', 'BCF 1호기', '열전대(R-type)', '상부/중부/하부 3점 교정 · SAT', -3, '보전 예정', ''],
      ['퀜칭', 'BCF 2호기', 'TUS 온도균일성', '9점 측정 (AMS2750 Class 2 ±6℃)', -1, '보전 예정', ''],
      ['퀜칭', 'BCF 3호기', 'O2 센서', '산소프로브 교정 및 버언아웃', 0, '보전 예정', ''],
      ['퀜칭', 'BCF 4호기', '래디언트튜브', '튜브 균열·변형 점검, 버너 노즐 청소', 3, '보전 예정', ''],
      ['퀜칭', 'BCF 5호기', '교반팬 모터', '베어링 그리스 주입, 진동 측정', 6, '보전 예정', ''],
      ['퀜칭', 'BCF 6호기', '도어 패킹', '내열 패킹 교체, 실린더 작동 점검', 9, '보전 예정', ''],
      ['퀜칭', 'BCF 7호기', '열전대(K-type)', '유조 열전대 교정', 14, '보전 예정', ''],
      ['퀜칭', 'BCF 8호기', 'CP 컨트롤러', 'CP 보정 · 쉼스톡(Shim stock) 비교', 18, '보전 예정', ''],
      ['퀜칭', 'BCF 9호기', '엘리베이터 체인', '체인 장력/마모 점검 및 교체', -6, '보전 연기', '9호기 정지 중 — 히터 교체 작업 후 시행'],
      ['퀜칭', 'BCF 10호기', 'TUS 온도균일성', '9점 측정 (AMS2750 Class 2)', 24, '보전 예정', ''],
      ['퀜칭', 'BCF 11호기', '소입유 성상', '냉각성능(냉각곡선)·수분 분석 의뢰', 31, '보전 예정', ''],
      ['퀜칭', 'BCF 12호기', '열전대(R-type)', '상부/중부/하부 3점 교정 · SAT', 45, '보전 예정', ''],
      ['퀜칭', 'BCF 1호기', '교반팬 모터', '베어링 교체', -12, '보전 완료', ''],
      ['퀜칭', 'BCF 5호기', 'TUS 온도균일성', '9점 측정 결과 ±4.2℃ 합격', -20, '보전 완료', ''],
      ['퀜칭', 'BCF 8호기', '도어 패킹', '내열 패킹 교체 완료', -9, '보전 완료', ''],
      ['탬퍼링', '템퍼로 1호기', '열전대(K-type)', '상/하 2점 교정', 5, '보전 예정', ''],
      ['탬퍼링', '템퍼로 2호기', '순환팬', 'V벨트 장력 및 베어링 점검', 12, '보전 예정', ''],
      ['탬퍼링', '템퍼로 1호기', 'TUS 온도균일성', '5점 측정 ±5℃ 합격', -15, '보전 완료', ''],
      ['세정', '세척기 1호기', '세척액 농도', '농도 측정 및 세척액 교체', 2, '보전 예정', ''],
      ['세정', '세척기 2호기', '히터·펌프', '탱크 슬러지 제거, 펌프 임펠러 점검', 20, '보전 예정', ''],
      ['세정', '세척기 1호기', '노즐', '분사 노즐 막힘 청소', -4, '보전 완료', ''],
      ['기타', '변성로(RX) 1호기', '촉매(Ni)', '촉매 버언아웃 및 이슬점 점검', 8, '보전 예정', ''],
      ['기타', '변성로(RX) 2호기', '이슬점 분석기', '분석기 교정', 40, '보전 예정', ''],
      ['기타', '냉각탑', '충진재·팬', '충진재 세척, 팬 모터 절연저항 측정', 27, '보전 예정', ''],
      ['기타', '공기압축기', '흡입필터·오일', '흡입필터/오일필터 교체', -2, '보전 완료', ''],
      ['기타', '유조 냉각기', '열교환기', '판형 열교환기 스케일 제거', 60, '보전 연기', '정기 휴무(설) 기간으로 일정 조정']
    ];
    return rows.map(function (r, i) {
      var due = M.addDays(today(), r[4]);
      return {
        calibId: i + 1, equipType: r[0], equipName: r[1], zoneLocation: r[2], measLocation: r[3],
        lastCalibDt: M.fmt(due, 'YYYY-MM-DD'), nextCalibDt: M.fmt(M.addDays(due, r[0] === '퀜칭' ? 90 : 180), 'YYYY-MM-DD'),
        handler: H[i % 2], status: r[5], remark: r[6], attachFile: ''
      };
    });
  }, 'calibId');

  M.get('/calib/list', function (req) {
    var p = req.params;
    var list = calib.all().filter(function (r) {
      if (p.calibId && String(r.calibId) !== String(p.calibId)) return false;
      if (p.equipType && r.equipType !== p.equipType) return false;
      if (p.status && r.status !== p.status) return false;
      if (p.keyword) { var k = p.keyword.toLowerCase(); if ((r.equipName + r.zoneLocation + r.measLocation + r.handler).toLowerCase().indexOf(k) < 0) return false; }
      return true;
    });
    list.sort(function (a, b) { return a.lastCalibDt < b.lastCalibDt ? -1 : a.lastCalibDt > b.lastCalibDt ? 1 : 0; });
    return ok({ data: list });
  });
  M.post('/calib/save', function (req) {
    var b = body(req);
    var row = { equipType: b.equipType, equipName: b.equipName, zoneLocation: b.zoneLocation, measLocation: b.measLocation,
      lastCalibDt: b.lastCalibDt, handler: b.handler, status: b.status, remark: b.remark };
    if (b.calibId) calib.update(b.calibId, row); else { row.attachFile = ''; calib.insert(row); }
    return ok();
  });
  M.post('/calib/delete', function (req) { calib.remove(body(req).calibId); return ok(); });
  M.post('/calib/attach/upload', function () { return ok(); });

  /* ═════════════════════════ 일상점검일지 (BCF 월간 매트릭스) ═════════════════════════ */
  var DAILY_ITEMS = [
    { k: 'temp',  name: '노내 온도 (침탄)',      std: '설정온도 ±10℃',          type: 'NUM' },
    { k: 'cp',    name: 'CP (탄소포텐셜)',       std: '0.80 ~ 0.95 %',          type: 'NUM' },
    { k: 'oil',   name: '소입유 온도',           std: '60 ~ 80 ℃',              type: 'NUM' },
    { k: 'rx',    name: 'RX 가스 유량',          std: '12 ~ 16 m³/h',           type: 'NUM' },
    { k: 'cw',    name: '냉각수 압력',           std: '2.0 ~ 3.5 kgf/cm²',      type: 'NUM' },
    { k: 'fan',   name: '교반팬 이상음·진동',    std: '이상음/진동 없을 것',     type: 'OX' },
    { k: 'door',  name: '도어 실링·화염커튼',     std: '누설·소염 없을 것',       type: 'OX' },
    { k: 'burn',  name: '버너 착화 상태',         std: '착화 불량 없을 것',       type: 'OX' },
    { k: 'tc',    name: '열전대 지시 편차',       std: '기록계와 ±3℃ 이내',      type: 'OX' },
    { k: 'elev',  name: '엘리베이터·푸셔 작동',   std: '이상 동작 없을 것',       type: 'OX' },
    { k: 'gas',   name: '가스감지기·비상차단밸브', std: '작동 확인 (√)',          type: 'NUM' },
    { k: 'insp',  name: '점검자',                std: '',                        type: 'OX' },
    { k: 'conf',  name: '확인자',                std: '',                        type: 'OX' }
  ];
  var dailyInspectors = M.db('d3_daily_inspectors', function () {
    return ['김상훈', '이재원', '박민준', '강도현', '서광우', '정용석', '윤지환'].map(function (n, i) { return { idx: i + 1, name: n }; });
  }, 'idx');
  var dailyItemOv = M.db('d3_daily_item_ov', function () { return []; }, 'itemId'); // 항목 수정/추가/입력형식 변경
  var dailyCells = M.db('d3_daily_cells', function () { return []; }, 'key');
  var dailyHeaders = M.db('d3_daily_headers', function () { return []; }, 'key');
  function furnaceNoOf(equipId) { var m = String(equipId || '').match(/(\d+)/); return m ? +m[1] : 1; }
  function dailyItems(equipId) {
    var no = furnaceNoOf(equipId);
    var base = DAILY_ITEMS.map(function (it, i) {
      return { itemId: no * 100 + i + 1, k: it.k, itemName: it.name, itemStd: it.std, inputType: it.type, imgFile: '' };
    });
    var ov = dailyItemOv.all();
    base.forEach(function (it) { ov.forEach(function (o) { if (String(o.itemId) === String(it.itemId)) { for (var k in o) if (k !== 'itemId') it[k] = o[k]; } }); });
    ov.forEach(function (o) { if (o.isNew && o.equipId === equipId) base.splice(base.length - 2, 0, { itemId: +o.itemId, k: 'extra', itemName: o.itemName, itemStd: o.itemStd || '', inputType: o.inputType || 'OX', imgFile: '' }); });
    return base.filter(function (it) { return !it.deleted; });
  }
  function dailyValue(no, it, dateStr, shift, r) {
    var f = no;
    var p = D.products[(f * 3 + +dateStr.slice(8)) % D.products.length];
    switch (it.k) {
      case 'temp': return D.furnaceState(f) === '대기' ? r.int(845, 852) : p.temp + r.int(-3, 4);
      case 'cp':   return M.round(Math.max(0.81, p.cp + r.float(-0.02, 0.04)), 2);
      case 'oil':  return r.int(64, 77);
      case 'rx':   return M.round(r.float(12.6, 15.4), 1);
      case 'cw':   return M.round(r.float(2.3, 3.1), 1);
      case 'gas':  return 99;
      case 'insp': return shift === 'D' ? ['김상훈', '이재원', '박민준'][(f + +dateStr.slice(8)) % 3] : ['강도현', '서광우'][(f + +dateStr.slice(8)) % 2];
      case 'conf': return shift === 'D' ? '정용석' : '윤지환';
      default:     return r.chance(0.015) ? 'X' : 'O';
    }
  }
  function loadDaily(equipId, ym, isTablet) {
    var no = furnaceNoOf(equipId);
    var y = +ym.slice(0, 4), mo = +ym.slice(4, 6);
    var days = new Date(y, mo, 0).getDate();
    var now = new Date(), tdy = M.fmt(now, 'YYYY-MM-DD');
    var items = dailyItems(equipId);
    var cells = {};
    dailyCells.all().forEach(function (c) { if (c.equipId === equipId && c.ym === ym) cells[c.itemId + '|' + c.day + '|' + c.shift] = c.val; });
    items.forEach(function (it) {
      var res = {};
      for (var d = 1; d <= days; d++) {
        var ds = y + '-' + M.pad(mo) + '-' + M.pad(d);
        var o = {};
        ['D', 'N'].forEach(function (sh) {
          var v = '';
          var due = ds < tdy || (ds === tdy && (sh === 'D' ? now.getHours() >= 9 : now.getHours() >= 21));
          var stopped = D.furnaceState(no) === '정지' && ds >= M.fmt(M.addDays(today(), -1), 'YYYY-MM-DD');
          if (due && !stopped && it.k !== 'extra') v = dailyValue(no, it, ds, sh, M.rng('daily|' + equipId + '|' + ds + '|' + sh + '|' + it.k));
          var key = it.itemId + '|' + d + '|' + sh;
          if (cells.hasOwnProperty(key)) v = cells[key];
          if (v !== '') o[sh] = v;
        });
        if (o.D != null || o.N != null) res[d] = o;
      }
      it.results = res;
    });
    var hdr = dailyHeaders.find(equipId + '|' + ym);
    var curYm = M.fmt(now, 'YYYYMM');
    var out = {
      success: true, equipId: equipId, ym: ym, daysInMonth: days,
      status: hdr ? hdr.status : (ym < curYm ? 'DONE' : 'TEMP'),
      inspectorName: hdr && hdr.inspector || '김상훈', confirmerName: hdr && hdr.confirmer || '정용석', loginName: '관리자',
      inspectors: dailyInspectors.all(),
      items: isTablet ? items.filter(function (it) { return it.k !== 'insp' && it.k !== 'conf'; }) : items
    };
    return out;
  }
  M.get('/inspect/load', function (req) {
    var ym = String(req.params.ym || M.fmt(new Date(), 'YYYYMM')).replace('-', '');
    return loadDaily(req.params.equipId || 'BCF_1', ym, /\/tablet/.test(location.pathname));
  });
  M.post('/inspect/result/cell', function (req) {
    var b = body(req);
    dailyCells.upsert({ key: [b.equipId, b.ym, b.itemId, b.day, b.shift].join('|'), equipId: b.equipId, ym: String(b.ym), itemId: b.itemId, day: b.day, shift: b.shift, val: b.val });
    return ok();
  });
  M.post('/inspect/header/save', function (req) {
    var b = body(req);
    dailyHeaders.upsert({ key: b.equipId + '|' + b.ym, inspector: b.inspector, confirmer: b.confirmer, status: b.status || 'TEMP' });
    return ok();
  });
  M.get('/inspect/inspector/list', function () { return ok({ inspectors: dailyInspectors.all() }); });
  M.post('/inspect/inspector/add', function (req) { dailyInspectors.insert({ name: body(req).name }); return ok(); });
  M.post('/inspect/inspector/delete', function (req) { dailyInspectors.remove(body(req).idx); return ok(); });
  M.post('/inspect/item/inputtype', function (req) { var b = body(req); dailyItemOv.upsert({ itemId: String(b.itemId), inputType: b.inputType }); return ok(); });
  M.post('/inspect/item/add', function (req) {
    var b = body(req);
    dailyItemOv.insert({ itemId: String(9000 + dailyItemOv.all().length + 1), isNew: true, equipId: b.equipId, itemName: b.itemName, itemStd: b.itemStd, inputType: 'OX' });
    return ok();
  });
  M.post('/inspect/item/edit', function (req) { var b = body(req); dailyItemOv.upsert({ itemId: String(b.itemId), itemName: b.itemName, itemStd: b.itemStd }); return ok(); });
  M.post('/inspect/item/delete', function () { return ok(); }); // 다음 달부터 반영 — 이번 달 화면은 유지
  M.post('/inspect/item/image/upload', function () { return ok(); });
  M.post('/inspect/excel/import', function () { return ok({ count: 0 }); });

  /* ═════════════════════════ 부대설비 점검표 ═════════════════════════ */
  var auxInspectors = M.db('d3_aux_inspectors', function () {
    return ['정용석', '윤지환', '김상훈', '박민준', '이재원', '강도현', '서광우'].map(function (n, i) { return { idx: i + 1, name: n }; });
  }, 'idx');
  var auxSaved = M.db('d3_aux_saved', function () { return []; }, 'inspect_date');
  var OD_NUM = {
    '1_1': [55, 68, 0], '1_2': [55, 68, 0], '3_1': [6.5, 9.5, 1], '3_2': [6.5, 9.5, 1], '4_1': [48, 82, 0], '4_2': [44, 78, 0], '5_0': [0.6, 0.8, 2],
    '6_1': [55, 66, 0], '6_2': [54, 66, 0], '8_0': [6.0, 9.0, 1], '9_0': [4.5, 7.0, 1], '10_0': [0.8, 1.2, 2], '11_0': [3, 6, 0],
    '12_0': null, '13_0': [3.0, 3.8, 1], '15_0': [3.0, 3.5, 1]
  };
  var OD_OX = ['2_1', '2_2', '7_1', '7_2', '14_0', '16_0'];
  var AUX_NOTES = [
    'LPG 기화기 2호 온수 보충 주기 짧아짐 — 수위 센서 점검 요망\n암모니아 봄베 교체 시 보호구(방독마스크) 필착',
    '냉각탑 2호 팬 진동 약간 증가 — 다음 정기보전 시 베어링 확인\n콤프레샤 3호 드레인 자동배출 정상',
    '질소 탱크 레벨 1,250 이하 시 즉시 발주 (현재 여유)\n옥외 배관 동파 방지 보온재 점검 (11월 중)'
  ];
  var AUX_SPECIAL = [
    '콤프레샤 4호 차압 0.7bar — 필터 교체 예정 (스페어 재고 확인 완료)',
    '암모니아 공급압력 일시 저하(0.6) → 2호 봄베 전환 후 정상화 ⊙',
    'N₂ 탱크 충전 완료 (대성산업가스, 09:40)'
  ];
  function auxGenerate(date) {
    var days = M.days();
    var di = days.indexOf(date);
    var now = new Date();
    var isToday = date === M.today();
    var dayDone = !isToday || now.getHours() >= 9;
    var nightDone = !isToday || now.getHours() >= 21;
    var r = M.rng('aux|' + date);
    var od = {}, comp = {}, n2 = {};
    ['day', 'night'].forEach(function (sh) {
      if ((sh === 'day' && !dayDone) || (sh === 'night' && !nightDone)) return;
      Object.keys(OD_NUM).forEach(function (k) {
        var s = OD_NUM[k];
        od[k + '_' + sh] = s ? String(M.round(r.float(s[0], s[1]), s[2])) : (r.chance(0.5) ? '1' : '2');
      });
      OD_OX.forEach(function (k) { od[k + '_' + sh] = r.chance(0.02) ? 'X' : 'O'; });
      [1, 3, 4].forEach(function (m) {
        comp['1_' + m + '_' + sh] = 'O';
        comp['2_' + m + '_' + sh] = String(M.round(r.float(0.3, m === 4 ? 0.72 : 0.6), 2));
        comp['3_' + m + '_' + sh] = String(r.int(71, 86));
        comp['4_' + m + '_' + sh] = 'O';
        comp['5_' + m + '_' + sh] = 'O';
      });
      for (var i = 1; i <= 10; i++) {
        if (i === 6) n2[i + '_' + sh] = String(M.round(r.float(6.8, 8.6), 1));
        else if (i === 8) n2[i + '_' + sh] = String(r.int(1380, 1720) - (di >= 0 ? di * 60 : 0) - (sh === 'night' ? 40 : 0));
        else if (i === 9) n2[i + '_' + sh] = String(M.round(r.float(5.6, 6.6), 1));
        else n2[i + '_' + sh] = 'O';
      }
    });
    var names = auxInspectors.all().map(function (x) { return x.name; });
    var idx = (di < 0 ? 0 : di);
    return {
      inspect_date: date,
      day_inspector: dayDone ? (names[idx % names.length] || '') : '',
      night_inspector: nightDone ? (names[(idx + 3) % names.length] || '') : '',
      notes: AUX_NOTES[idx % 3], special_notes: AUX_SPECIAL[idx % 3],
      outdoor_data: JSON.stringify(od), comp_data: JSON.stringify(comp), n2gas_data: JSON.stringify(n2)
    };
  }
  M.get('/auxiliary/inspection/data', function (req) {
    var date = req.params.date || M.today();
    var saved = auxSaved.find(date);
    if (saved) return ok({ data: saved, isNew: false });
    if (M.days().indexOf(date) >= 0) return ok({ data: auxGenerate(date), isNew: false });
    // 기록 없는 날짜: 유의사항/특기사항만 이전 기록에서 인계
    return ok({ data: { inspect_date: date, notes: AUX_NOTES[2], special_notes: AUX_SPECIAL[2], outdoor_data: '{}', comp_data: '{}', n2gas_data: '{}' }, isNew: true });
  });
  M.post('/auxiliary/inspection/save', function (req) { auxSaved.upsert(body(req)); return ok(); });
  M.get('/auxiliary/inspection/inspector/list', function () { return ok({ list: auxInspectors.all() }); });
  M.post('/auxiliary/inspection/inspector/add', function (req) { auxInspectors.insert({ name: body(req).name }); return ok(); });
  M.post('/auxiliary/inspection/inspector/update', function (req) { var b = body(req); auxInspectors.update(b.idx, { name: b.name }); return ok(); });
  M.post('/auxiliary/inspection/inspector/delete', function (req) { auxInspectors.remove(body(req).idx); return ok(); });

  /* ═════════════════════════ 스페어파트 ═════════════════════════ */
  // [부품번호, 품명, 카테고리, 적용설비, 단위, 최소재고, 교체주기(월), 기초재고]
  var PARTS = [
    ['HT-001', 'U형 히터 엘리먼트 (Kanthal APM 12kW)', '히터', 'BCF 1~6호기', 'EA', 4, 24, 9],
    ['HT-002', 'U형 히터 엘리먼트 (Kanthal APM 15kW)', '히터', 'BCF 7~12호기', 'EA', 4, 24, 4],
    ['HT-003', '템퍼로 시즈 히터 6kW', '히터', '템퍼로 1·2호기', 'EA', 2, 36, 3],
    ['HT-004', '세척기 탱크 히터 9kW', '히터', '세척기 1·2호기', 'EA', 1, 36, 2],
    ['TC-001', '열전대 K-type Ø8 L=1000', '열전대', 'BCF 전 호기 / 유조', 'EA', 6, 6, 12],
    ['TC-002', '열전대 R-type Ø15 세라믹보호관 L=900', '열전대', 'BCF 전 호기 (제어용)', 'EA', 4, 12, 4],
    ['TC-003', '열전대 K-type 시즈 Ø3.2 (TUS용)', '열전대', '측정 장비', 'EA', 10, 12, 18],
    ['TC-004', '보상도선 KX 2P×1.25sq', '열전대', '공용', 'M', 50, 0, 120],
    ['OS-001', '산소 프로브 (지르코니아) L=650', 'O2센서', 'BCF 전 호기', 'EA', 2, 18, 3],
    ['OS-002', 'CP 컨트롤러 센서 필터', 'O2센서', 'BCF 전 호기', 'EA', 4, 6, 8],
    ['OS-003', '이슬점 분석기 센서', 'O2센서', '변성로(RX) 1·2호기', 'EA', 1, 24, 1],
    ['FM-001', '교반팬 모터 7.5kW 4P (내열형)', '팬모터', 'BCF 1~6호기', 'EA', 1, 60, 2],
    ['FM-002', '교반팬 모터 11kW 4P (내열형)', '팬모터', 'BCF 7~12호기', 'EA', 1, 60, 1],
    ['FM-003', '교반팬 임펠러 (SCH22)', '팬모터', 'BCF 전 호기', 'EA', 2, 48, 3],
    ['FM-004', '팬 샤프트 베어링 6312ZZ', '팬모터', 'BCF 전 호기', 'EA', 6, 12, 10],
    ['VL-001', '솔레노이드 밸브 (RX가스) 25A', '밸브', 'BCF 전 호기', 'EA', 3, 0, 5],
    ['VL-002', '버너 가스 전자밸브 15A', '밸브', 'BCF 전 호기', 'EA', 3, 0, 4],
    ['VL-003', '유량계 (프로판) 0.5~5 m³/h', '밸브', 'BCF 전 호기', 'EA', 2, 0, 2],
    ['FT-001', '공기압축기 흡입 필터', '필터', '공기압축기', 'EA', 2, 6, 4],
    ['FT-002', '소입유 순환 필터 엘리먼트', '필터', '유조 냉각기', 'EA', 4, 3, 6],
    ['ET-001', '래디언트튜브 Ø180 (SCH22) U-type', '기타', 'BCF 7~12호기', 'EA', 2, 36, 2],
    ['ET-002', '도어 내열 패킹 (세라믹 로프 Ø25)', '기타', 'BCF 전 호기', 'M', 30, 6, 60],
    ['ET-003', '버너 점화 플러그', '기타', 'BCF 전 호기', 'EA', 6, 12, 8],
    ['ET-004', '엘리베이터 체인 RS80', '기타', 'BCF 전 호기', 'M', 10, 24, 18],
    ['ET-005', '트레이 (내열주강 600×600)', '기타', 'BCF 전 호기', 'EA', 8, 0, 14]
  ];
  var parts = M.db('d3_parts', function () {
    return PARTS.map(function (p) { return { partNo: p[0], partName: p[1], category: p[2], equipment: p[3], unit: p[4], minStock: p[5], replaceCycle: p[6] }; });
  }, 'partNo');
  var partHist = M.db('d3_parts_hist', function () {
    var rows = [], id = 0;
    var open = M.addDays(today(), -34);
    PARTS.forEach(function (p, i) {
      rows.push({ id: ++id, partNo: p[0], type: 'IN', qty: p[7], equipment: '', workDesc: '기초 재고 (재고실사 반영)', userName: '정용석', createdAt: M.fmt(M.addMinutes(open, 540 + i * 3), 'YYYY-MM-DD HH:mm') });
    });
    var days = M.days();
    // [일자idx, 시각, 부품, 구분, 수량, 설비, 작업내용, 담당자]
    var MV = [
      [0, '08:40', 'TC-001', 'OUT', 2, 'BCF 3호기', '유조 열전대 지시 불량 교체', '윤지환'],
      [0, '10:15', 'HT-002', 'OUT', 2, 'BCF 9호기', '히터 단선(R상) 교체', '정용석'],
      [0, '13:30', 'FT-002', 'OUT', 2, '유조 냉각기', '정기 교환 (3개월)', '윤지환'],
      [0, '15:05', 'ET-002', 'OUT', 12, 'BCF 8호기', '도어 패킹 교체', '정용석'],
      [0, '16:20', 'TC-003', 'IN', 6, '', '정기 발주 입고 (한국계측)', '정용석'],
      [1, '09:10', 'HT-002', 'OUT', 1, 'BCF 9호기', '히터 추가 교체 (S상)', '정용석'],
      [1, '10:45', 'OS-002', 'OUT', 2, 'BCF 5호기', 'CP 센서 필터 교환', '윤지환'],
      [1, '11:20', 'ET-003', 'OUT', 3, 'BCF 7호기', '버너 착화 실패 — 점화플러그 교체', '윤지환'],
      [1, '14:00', 'FM-004', 'OUT', 2, 'BCF 1호기', '교반팬 베어링 교체', '정용석'],
      [1, '15:30', 'VL-001', 'IN', 2, '', '긴급 발주 입고', '정용석'],
      [1, '16:40', 'ET-005', 'OUT', 4, 'BCF 2호기', '변형 트레이 폐기 교체', '박민준'],
      [2, '08:30', 'OS-001', 'OUT', 1, 'BCF 3호기', '산소 프로브 교체 (정기보전)', '윤지환'],
      [2, '09:50', 'HT-002', 'OUT', 1, 'BCF 9호기', '히터 교체 (T상) — 시운전 대기', '정용석'],
      [2, '10:30', 'TC-002', 'OUT', 1, 'BCF 2호기', 'TUS 전 제어 열전대 교체', '윤지환'],
      [2, '11:15', 'FT-001', 'IN', 4, '', '정기 발주 입고', '정용석']
    ];
    var now = new Date();
    MV.forEach(function (m) {
      var t = M.toDate(days[m[0]] + ' ' + m[1]);
      if (t > now) return;
      rows.push({ id: ++id, partNo: m[2], type: m[3], qty: m[4], equipment: m[5], workDesc: m[6], userName: m[7], createdAt: M.fmt(t, 'YYYY-MM-DD HH:mm') });
    });
    return rows;
  }, 'id');
  function partOf(no) { return parts.find(no) || {}; }
  M.get('/parts/list', function (req) {
    var p = req.params, hist = partHist.all();
    var list = parts.all().filter(function (r) {
      if (p.category && r.category !== p.category) return false;
      if (p.keyword) { var k = p.keyword.toLowerCase(); if ((r.partNo + r.partName).toLowerCase().indexOf(k) < 0) return false; }
      return true;
    }).map(function (r) {
      var tin = 0, tout = 0;
      hist.forEach(function (h) { if (h.partNo === r.partNo) { if (h.type === 'IN') tin += +h.qty; else tout += +h.qty; } });
      var cur = tin - tout, min = +r.minStock || 0;
      var o = {}; for (var k in r) o[k] = r[k];
      o.minStock = min; o.replaceCycle = +r.replaceCycle || 0;
      o.totalIn = tin; o.totalOut = tout; o.currentStock = cur;
      o.stockStatus = cur <= 0 ? '재고없음' : cur < min ? '부족' : '정상';
      return o;
    });
    return ok({ data: list });
  });
  M.get('/parts/history/list', function (req) {
    var p = req.params;
    var list = partHist.all().filter(function (h) {
      if (p.type && h.type !== p.type) return false;
      return M.inRange(h.createdAt, p.fromDt || null, p.toDt || null);
    }).map(function (h) {
      var pt = partOf(h.partNo); var o = {}; for (var k in h) o[k] = h[k];
      o.partName = pt.partName || ''; o.category = pt.category || ''; return o;
    });
    list.sort(function (a, b) { return a.createdAt < b.createdAt ? 1 : -1; });
    return ok({ data: list });
  });
  M.post('/parts/save', function (req) {
    var b = body(req);
    parts.upsert({ partNo: b.partNo, partName: b.partName, category: b.category, equipment: b.equipment, unit: b.unit, minStock: +b.minStock || 0, replaceCycle: +b.replaceCycle || 0 });
    return ok();
  });
  M.post('/parts/delete', function (req) {
    var no = body(req).partNo; parts.remove(no);
    partHist.remove(partHist.all().filter(function (h) { return h.partNo === no; }).map(function (h) { return h.id; }));
    return ok();
  });
  M.post('/parts/history/save', function (req) {
    var b = body(req);
    partHist.insert({ partNo: b.partNo, type: b.type, qty: +b.qty || 1, equipment: b.equipment || '', workDesc: b.workDesc || '', userName: b.userName || '관리자', createdAt: M.fmt(new Date(), 'YYYY-MM-DD HH:mm') });
    return ok();
  });
  M.post('/parts/history/delete', function (req) { partHist.remove(body(req).id); return ok(); });

  /* ═════════════════════════ 유류·소모재 관리대장 ═════════════════════════ */
  // [구분, 품명/규격, 포장단위, 보유재고, 재고단위, 안전재고, 안전단위, 비고]
  var CONS = [
    ['소입유', '마콜 BW-2200 (고속 소입유)', '200L / DRUM', '14', 'DRUM', '10', 'DRUM', 'BCF 1~6호기 유조 보충용'],
    ['소입유', '마콜 QS-150 (마르퀜칭유)', '200L / DRUM', '6', 'DRUM', '6', 'DRUM', 'BCF 7~12호기'],
    ['템퍼링·방청', '방청유 RP-30 (수용성)', '18L / CAN', '22', 'CAN', '10', 'CAN', '출하품 방청'],
    ['침탄가스', '프로판 (C3H8) LPG', '벌크 탱크', '2.45', 't', '1.5', 't', '탱크 1·2호 합계 — 기화기 경유'],
    ['침탄가스', '암모니아 (NH3) 99.9%', '50kg / 봄베', '9', '병', '6', '병', '침질 공정 (BCF 7·9·10·12)'],
    ['변성가스', '메탄올 (CH3OH) 공업용', '200L / DRUM', '8', 'DRUM', '5', 'DRUM', 'N2-메탄올 분위기 (BCF 11호기)'],
    ['변성가스', 'RX 변성로 Ni 촉매', '20kg / BOX', '3', 'BOX', '2', 'BOX', '변성로 1·2호기 교체용'],
    ['질소', '액체질소 (LN2)', '벌크 탱크', '1520', 'm³', '1000', 'm³', 'N₂ 탱크 — 1,000 이하 발주'],
    ['세척제', '알칼리 탈지제 DW-CL300', '20kg / PAIL', '11', 'PAIL', '8', 'PAIL', '세척기 1·2호기'],
    ['세척제', '소포제 AF-10', '18kg / CAN', '3', 'CAN', '4', 'CAN', '세척기 거품 발생 시 투입'],
    ['보온·내화', '세라믹 파이버 블랭킷 25t', '7.2m / ROLL', '5', 'ROLL', '3', 'ROLL', '도어·덕트 보수'],
    ['보온·내화', '내화 모르타르 (고알루미나)', '25kg / 포', '12', '포', '6', '포', ''],
    ['윤활유', '고온 그리스 (교반팬 베어링용)', '16kg / PAIL', '4', 'PAIL', '2', 'PAIL', '정기 주입 월 1회'],
    ['윤활유', '공기압축기 오일 (ISO VG46)', '20L / CAN', '3', 'CAN', '2', 'CAN', ''],
    ['시험·검사', '경도 시험편 (HRC 기준편 60)', '1EA', '2', 'EA', '2', 'EA', '로크웰 경도계 일상점검용'],
    ['시험·검사', '쉼스톡 (Shim stock) 0.05t', '100매 / 팩', '1', '팩', '2', '팩', 'CP 확인용 — 발주 진행 중']
  ];
  var cons = M.db('d3_cons', function () {
    return CONS.map(function (c, i) { return { id: i + 1, category: c[0], itemName: c[1], packageUnit: c[2], stockQty: c[3], stockUnit: c[4], safetyQty: c[5], safetyUnit: c[6], remark: c[7], sortOrder: i + 1 }; });
  }, 'id');
  var consHist = M.db('d3_cons_hist', function () {
    var days = M.days(), now = new Date(), rows = [], id = 0;
    // [일자idx, 시각, ledgerId, 구분, 수량, 비고, 담당자]
    var MV = [
      [0, '07:50', 1, 'OUT', '2', 'BCF 2호기 유조 보충', '김상훈'],
      [0, '09:20', 8, 'OUT', '180', '1일 사용량 (탱크 레벨 기준)', '윤지환'],
      [0, '10:30', 4, 'OUT', '0.38t', '1일 사용량 (탱크 1·2호)', '윤지환'],
      [0, '13:10', 9, 'OUT', '2', '세척기 1호기 세척액 교체', '박민준'],
      [0, '14:40', 3, 'IN', '10', '정기 발주 입고 (동남석유)', '정용석'],
      [0, '16:00', 5, 'OUT', '1', 'BCF 9호기 질화 공정', '강도현'],
      [1, '08:10', 8, 'OUT', '175', '1일 사용량 (탱크 레벨 기준)', '윤지환'],
      [1, '09:30', 4, 'OUT', '0.41t', '1일 사용량 (탱크 1·2호)', '윤지환'],
      [1, '10:20', 6, 'OUT', '1', 'BCF 11호기 메탄올 탱크 보충', '이재원'],
      [1, '11:00', 2, 'OUT', '1', 'BCF 10호기 유조 보충', '박민준'],
      [1, '13:40', 13, 'OUT', '1', '교반팬 베어링 그리스 주입 (BCF 1~6)', '정용석'],
      [1, '15:20', 1, 'IN', '8', '정기 발주 입고 (마콜코리아)', '정용석'],
      [1, '16:30', 10, 'OUT', '1', '세척기 2호기 거품 발생', '서광우'],
      [2, '08:05', 8, 'OUT', '170', '1일 사용량 (탱크 레벨 기준)', '윤지환'],
      [2, '09:15', 4, 'OUT', '0.36t', '1일 사용량 (탱크 1·2호)', '윤지환'],
      [2, '09:40', 8, 'IN', '1200', 'N₂ 탱크 충전 (대성산업가스)', '정용석'],
      [2, '10:50', 5, 'OUT', '1', 'BCF 12호기 질화 공정', '강도현'],
      [2, '11:30', 9, 'OUT', '1', '세척기 2호기 농도 보정', '서광우']
    ];
    MV.forEach(function (m) {
      var t = M.toDate(days[m[0]] + ' ' + m[1]); if (t > now) return;
      var c = CONS[m[2] - 1];
      rows.push({ id: ++id, ledgerId: m[2], type: m[3], qty: m[3] === 'OUT' ? '-' + m[4] : m[4], remark: m[5], userName: m[6], regDate: M.fmt(t, 'YYYY-MM-DD HH:mm'), category: c[0], itemName: c[1] });
    });
    return rows;
  }, 'id');
  M.get('/consumable/list', function () {
    var list = cons.all(); list.sort(function (a, b) { return (a.sortOrder || 0) - (b.sortOrder || 0); });
    return ok({ data: list });
  });
  M.get('/consumable/history/list', function (req) {
    var p = req.params;
    var list = consHist.all().filter(function (h) {
      if (p.type && h.type !== p.type) return false;
      if (p.keyword && (h.category + h.itemName).indexOf(p.keyword) < 0) return false;
      return M.inRange(h.regDate, p.fromDt || null, p.toDt || null);
    });
    list.sort(function (a, b) { return a.regDate < b.regDate ? 1 : -1; });
    return ok({ data: list });
  });
  function adjustStock(ledgerId, qtyStr, sign) {
    var c = cons.find(ledgerId); if (!c) return;
    var cur = num(c.stockQty), q = num(qtyStr);
    if (cur == null || q == null) return;
    var nv = M.round(cur + sign * Math.abs(q), 2);
    cons.update(ledgerId, { stockQty: String(nv) });
  }
  M.post('/consumable/history/save', function (req) {
    var b = body(req), c = cons.find(b.ledgerId) || {};
    var q = String(b.qty || '').replace(/^[+\-]/, '');
    consHist.insert({ ledgerId: +b.ledgerId, type: b.type, qty: (b.type === 'OUT' ? '-' : '') + q, remark: b.remark || '', userName: b.userName || '관리자',
      regDate: M.fmt(new Date(), 'YYYY-MM-DD HH:mm'), category: c.category || '', itemName: c.itemName || '' });
    adjustStock(b.ledgerId, q, b.type === 'OUT' ? -1 : 1);
    return ok();
  });
  M.post('/consumable/history/delete', function (req) {
    var h = consHist.find(body(req).id);
    if (h) { adjustStock(h.ledgerId, h.qty, h.type === 'OUT' ? 1 : -1); consHist.remove(h.id); }
    return ok();
  });
  M.post('/consumable/save', function (req) {
    var b = body(req);
    var row = { category: b.category, itemName: b.itemName, packageUnit: b.packageUnit, stockQty: b.stockQty, stockUnit: b.stockUnit, safetyQty: b.safetyQty, safetyUnit: b.safetyUnit, remark: b.remark, sortOrder: +b.sortOrder || 0 };
    if (b.id) cons.update(b.id, row); else { if (!row.sortOrder) row.sortOrder = 99; cons.insert(row); }
    return ok();
  });
  M.post('/consumable/delete', function (req) { cons.remove(body(req).id); return ok(); });

  /* ═════════════════════════ F/PROOF (Fool Proof) ═════════════════════════ */
  var FP_TAGS = [
    ['TIC_HH', '침탄실 온도 상한 초과 (SP+15℃)', 3], ['TIC_LL', '침탄실 온도 하한 미달 (SP-15℃)', 3],
    ['CP_DEV', 'CP 편차 이탈 (±0.05%)', 2], ['O2_FAIL', '산소 프로브 이상 (mV 범위 이탈)', 3],
    ['RX_LOW', 'RX 가스 유량 저하', 3], ['C3H8_HI', '프로판 유량 과다', 2],
    ['OIL_HI', '소입유 온도 상한 (90℃ 초과)', 3], ['OIL_LV', '소입유 레벨 저하', 2],
    ['AGIT_OL', '유조 교반기 과부하', 2], ['FAN_OL', '교반팬 모터 과부하', 3],
    ['DOOR_ERR', '내부 도어 개폐 이상', 2], ['ELV_POS', '엘리베이터 위치 이상', 2],
    ['QT_DELAY', '퀜칭 이송 지연 (20초 초과)', 3], ['BURN_FAIL', '버너 착화 실패', 2],
    ['CW_LOW', '냉각수 유량 저하', 1], ['TC_OPEN', '제어 열전대 단선', 3],
    ['PURGE_NG', 'N₂ 퍼지 미완료 상태 가스 투입', 3], ['FLAME_OFF', '화염커튼 소염', 1]
  ];
  function fpAll(plcId) {
    var no = furnaceNoOf(plcId);
    return FP_TAGS.map(function (t, i) { return { tagId: no * 100 + i + 1, tagName: 'BCF' + no + '_' + t[0], alarmMsg: t[1], level: t[2] }; });
  }
  var fpSel = M.db('d3_fproof_sel', function () {
    var rows = [];
    for (var f = 1; f <= 12; f++) {
      var r = M.rng('fpsel' + f);
      FP_TAGS.forEach(function (t, i) {
        if (t[2] === 3 ? r.chance(0.85) : r.chance(0.2)) rows.push({ key: 'bcf_' + M.pad(f) + '|' + (f * 100 + i + 1), plcId: 'bcf_' + M.pad(f), tagId: f * 100 + i + 1 });
      });
    }
    return rows;
  }, 'key');
  function fpSelected(plcId) { return fpSel.all().filter(function (s) { return s.plcId === plcId; }).map(function (s) { return +s.tagId; }); }
  M.get('/fproof/list', function (req) {
    var plc = req.params.plcId || 'bcf_01';
    return { all: fpAll(plc), selected: fpSelected(plc) };
  });
  M.post('/fproof/select', function (req) { var b = body(req); fpSel.upsert({ key: b.plcId + '|' + b.tagId, plcId: b.plcId, tagId: +b.tagId }); return ok(); });
  M.post('/fproof/deselect', function (req) { var b = body(req); fpSel.remove(b.plcId + '|' + b.tagId); return ok(); });

  function fpAlarms(c) {
    var plc = 'bcf_' + M.pad(c.furnace_no);
    var sel = fpSelected(plc), tags = fpAll(plc).filter(function (t) { return sel.indexOf(t.tagId) >= 0; });
    var r = M.rng('fpal|' + c.charge_no);
    var n = r.chance(0.45) ? 0 : r.int(1, 3);
    if (!tags.length) return [];
    var st = M.toDate(c.start_time), en = c.end_time ? M.toDate(c.end_time) : new Date();
    var span = (en - st) / 60000, out = [];
    for (var i = 0; i < n; i++) {
      var t = tags[r.int(0, tags.length - 1)];
      var occ = M.addMinutes(st, r.int(10, Math.max(11, Math.floor(span) - 10)));
      if (occ > new Date()) continue;
      var clr = M.addMinutes(occ, r.int(1, 18));
      out.push({ tagId: t.tagId, tagName: t.tagName, alarmMsg: t.alarmMsg, occurTime: M.fmt(occ), clearTime: (clr > new Date() || (!c.end_time && i === n - 1 && r.chance(0.5))) ? null : M.fmt(clr) });
    }
    out.sort(function (a, b) { return a.occurTime < b.occurTime ? -1 : 1; });
    return out;
  }
  M.get('/fprooflist/sessions', function (req) {
    var list = D.chargesIn(req.params.from, req.params.to).map(function (c) {
      return { plcId: 'bcf_' + M.pad(c.furnace_no), startTime: c.start_time, endTime: c.end_time || null, alarmCount: fpAlarms(c).length, chargeNo: c.charge_no };
    });
    list.sort(function (a, b) { return a.startTime < b.startTime ? 1 : -1; });
    return list;
  });
  M.get('/fprooflist/detail', function (req) {
    var p = req.params, no = furnaceNoOf(p.plcId);
    var c = D.charges().filter(function (x) { return x.furnace_no === no && x.start_time === p.start; })[0];
    return c ? fpAlarms(c) : [];
  });

  /* ═════════════════════════ BACKUP-DATA (구 HTMS 백업) ═════════════════════════ */
  var EQUT_MAP = { '2420M001': 1, '2420M002': 2, '2420M003': 3, '2420M004': 4, '2420M005': 5, '2420M011': 6, '2420M006': 7, '2420M007': 8, '2420M008': 9, '2420M009': 10, '2420M010': 11, '2421M002': 12 };
  // 노 사이클 모델 — 같은 시각이면 항상 같은 상태
  function cycleAt(f, t) {
    var r0 = M.rng('bkcyc' + f);
    var P = Math.round(r0.float(7.2, 9.4) * 60);            // 사이클(분)
    var off = r0.int(0, P);
    var tm = Math.floor(t.getTime() / 60000) + off;
    var k = Math.floor(tm / P), u = tm - k * P;
    var p = D.products[M.rng('bkprod' + f + '|' + k).int(0, D.products.length - 1)];
    return { k: k, u: u, P: P, p: p, start: new Date((k * P - off) * 60000) };
  }
  function procAt(f, t) {
    var c = cycleAt(f, t), u = c.u, P = c.P, sp = c.p.temp;
    var tsp, tpv, cpsp, oil, flow;
    var endCarb = P - 150, endDiff = P - 75, endCool = P - 35;
    if (u < 15) { tsp = sp; tpv = 850 - u * 3; cpsp = 0.8; }
    else if (u < 80) { tsp = sp; tpv = 805 + (sp - 805) * (1 - Math.exp(-(u - 15) / 18)); cpsp = 1.05; }
    else if (u < endCarb) { tsp = sp; tpv = sp; cpsp = 1.05; }
    else if (u < endDiff) { tsp = sp; tpv = sp; cpsp = c.p.cp; }
    else if (u < endCool) { tsp = 850; tpv = sp - (sp - 850) * Math.min(1, (u - endDiff) / 30); cpsp = c.p.cp; }
    else { tsp = 850; tpv = 850; cpsp = 0.8; }
    var since = u - endCool;
    oil = since >= 0 && since < 30 ? 70 + 38 * Math.exp(-since / 9) : 68;
    flow = cpsp > 1 ? 1 : (cpsp > 0.82 ? 0.65 : 0.35);
    return { c: c, tsp: tsp, tpv: tpv, cpsp: cpsp, oil: oil, flow: flow };
  }
  var C3H8_RAW = { '1': 1550, '3': 1550, '4': 1550, '2': 3150, '5': 3800, '8': 3800, '10': 3800, '7': 960, '9': 980, '11': 4.8, '12': 4.8, '6': 480 };
  M.get('/backup/trend/data', function (req) {
    var bcf = String(req.params.bcf || '1'), f = +bcf;
    var from = M.toDate(req.params.from), to = M.toDate(req.params.to);
    if (!from || !to || to <= from) return [];
    var mins = (to - from) / 60000, step = Math.max(1, Math.ceil(mins / 1800));
    var cols = f === 6 ? 16 : f === 11 ? 12 : (f >= 7 ? 8 : 7);
    var cpMul = (f === 7 || f === 9) ? 0.5 : f === 6 ? 1000 : 1;
    var rows = [];
    for (var t = new Date(from); t <= to; t = M.addMinutes(t, step)) {
      var s = procAt(f, t), key = 'bk' + f;
      var nz = function (k, amp) { return M.wave(key + k, t, 0, amp, amp * 0.6, 23); };
      var tpv = M.round(s.tpv + nz('t', 1.2), 1), cppv = s.cpsp + nz('c', 0.01);
      var c3 = C3H8_RAW[bcf] * s.flow * (1 + nz('f', 0.012));
      var row = { DataDate: M.fmt(t) };
      if (f === 6) {
        var zones = [s.tsp - 70, s.tsp, s.tsp, s.tsp, s.tsp - 40];
        for (var z = 0; z < 5; z++) { row['Data' + (z * 2 + 1)] = M.round(zones[z] + (s.tpv - s.tsp) + nz('z' + z, 1.5), 1); row['Data' + (z * 2 + 2)] = zones[z]; }
        row.Data11 = M.round((cppv - 0.1) * cpMul, 0); row.Data12 = M.round((s.cpsp - 0.1) * cpMul, 0);
        row.Data13 = M.round(cppv * cpMul, 0); row.Data14 = M.round(s.cpsp * cpMul, 0);
        row.Data15 = M.round(c3 * 0.6, 0); row.Data16 = M.round(c3, 0);
      } else if (f === 11) {
        row.Data1 = tpv; row.Data2 = s.tsp; row.Data3 = M.round(s.tpv + nz('t2', 1.5), 1); row.Data4 = s.tsp;
        row.Data5 = M.round(s.oil + nz('o', 0.8), 1); row.Data6 = 70;
        row.Data7 = M.round(cppv, 3); row.Data8 = s.cpsp; row.Data9 = M.round(cppv - 0.02, 3); row.Data10 = s.cpsp;
        row.Data11 = M.round(c3, 2); row.Data12 = M.round(c3 * 0.8, 2);
      } else {
        row.Data1 = tpv; row.Data2 = s.tsp; row.Data3 = M.round(cppv * cpMul, 3); row.Data4 = M.round(s.cpsp * cpMul, 3);
        var oilAdj = f === 9 ? 9 : f === 7 ? -8 : 0;
        row.Data5 = M.round(s.oil + oilAdj + nz('o', 0.8), 1); row.Data6 = 70 + (f === 9 ? -9 : 0);
        row.Data7 = M.round(c3, bcf === '12' ? 2 : 0);
        if (cols >= 8) { var nh = s.cpsp > 1 ? 0 : 0.45 + nz('n', 0.03); row.Data8 = f === 9 ? M.round(nh * 100, 1) : f === 10 ? M.round(nh * 10, 2) : f === 12 ? M.round(nh, 3) : M.round(nh * 100, 1); }
      }
      rows.push(row);
    }
    return rows;
  });
  if (/\/facility\/backup/.test(PATH)) {
    // 다른 화면(트렌드 등)의 작업지시 라우트를 덮어쓰지 않도록 BACKUP 화면에서만 등록
    M.get('/work/jacup/range', function (req) {
      var f = EQUT_MAP[req.params.equtCd] || 1;
      var from = M.toDate(req.params.from), to = M.toDate(req.params.to);
      if (!from || !to) return [];
      var out = [], t = cycleAt(f, from).start, seen = {};
      for (var guard = 0; t <= to && guard < 80; guard++) {
        var c = cycleAt(f, M.addMinutes(t, 5));
        if (!seen[c.k]) {
          seen[c.k] = 1;
          var end = M.addMinutes(c.start, c.P - 35);
          if (end >= from) {
            var cu = D.customer(c.p.cust_code);
            out.push({ WORK_INDCT_NUM: 'WI' + M.fmt(c.start, 'YYYYMMDD').slice(2) + '-' + M.pad(f) + M.pad(Math.floor((c.start.getHours() * 60 + c.start.getMinutes()) / c.P) + 1), CUST_COMP_NM: cu.cust_name, PROD_MM: c.p.prod_name + ' (' + c.p.part_no + ')',
              START_DTTM: M.fmt(c.start), END_DTTM: M.fmt(end) });
          }
        }
        t = M.addMinutes(c.start, c.P);
      }
      return out;
    });
  }
  M.get('/backup/alarm/list', function (req) {
    var p = req.params, mask = +p.areaMask || 0;
    var furn = [];
    for (var f = 1; f <= 12; f++) if (!mask || (mask & (1 << (f - 1)))) furn.push(f);
    var ALS = [
      ['TIC101.HI', '침탄실 온도 상한 경보', function (s) { return [s.tsp + 12 + 0.4, s.tsp + 12, '℃']; }],
      ['TIC101.LO', '침탄실 온도 하한 경보 (장입 후 회복 지연)', function (s) { return [s.tsp - 25.6, s.tsp - 25, '℃']; }],
      ['CP101.DEV', 'CP 편차 경보', function (s) { return [M.round(s.cpsp - 0.07, 3), M.round(s.cpsp - 0.05, 3), '%']; }],
      ['TI201.HI', '소입유 온도 상한 경보', function () { return [91.3, 90, '℃']; }],
      ['FI301.LO', 'RX 가스 유량 저하 경보', function () { return [9.6, 10, 'm³/h']; }],
      ['FAN.OL', '교반팬 모터 과부하 트립', function () { return [18.9, 18.0, 'A']; }],
      ['FI401.LO', '냉각수 유량 저하 경보', function () { return [38.0, 40.0, 'L/min']; }],
      ['DOOR.ERR', '내부 도어 동작 시간 초과', function () { return [14.2, 12.0, 'sec']; }]
    ];
    var out = [], d = M.toDate(p.from), end = M.toDate(p.to);
    if (!d || !end) return [];
    for (var guard = 0; d <= end && guard < 40; d = M.addDays(d, 1), guard++) {
      var ds = M.fmt(d, 'YYYY-MM-DD');
      furn.forEach(function (f) {
        var r = M.rng('bkal|' + f + '|' + ds), n = r.int(1, 5);
        for (var i = 0; i < n; i++) {
          var a = ALS[r.int(0, ALS.length - 1)];
          var t = new Date(M.toDate(ds).getTime() + r.int(0, 86399) * 1000);
          var v = a[2](procAt(f, t));
          out.push({ source: 'BCF' + f + '.' + a[0], pv: (+v[0]).toFixed(v[2] === '%' ? 2 : 1) + ' ' + v[2], tripValue: (+v[1]).toFixed(v[2] === '%' ? 2 : 1) + ' ' + v[2], timeAct: M.fmt(t), descString: 'BCF' + f + ' ' + a[1] });
        }
      });
    }
    out.sort(function (a, b) { return a.timeAct < b.timeAct ? 1 : -1; });
    return out;
  });
})();
