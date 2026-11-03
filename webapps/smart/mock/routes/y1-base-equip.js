/*
 * y1-base-equip.js — 앱 셸(로그인·메뉴·권한) + 기준정보 + 설비관리 목업 라우트
 * 기준 데이터는 master.js(MOCK.D)를 쓰고, 저장되는 표는 MOCK.db(sessionStorage)로 유지한다.
 */
(function () {
  var M = window.MOCK, D = M.D;
  var ISO = 'YYYY-MM-DDTHH:mm:ss';
  var iso = function (d) { return d ? M.fmt(d, ISO) : null; };
  var toIso = function (v) { var d = M.toDate(v); return d ? iso(d) : null; };
  var nowIso = function () { return iso(new Date()); };
  var BAD = function (msg) { return M.res(400, D.fail(msg, 'INVALID_PARAMETER')); };
  var arr = function (req) { var b = req.body; return Array.isArray(b) ? b : (b && Array.isArray(b.ids) ? b.ids : []); };
  var has = function (s, k) { return String(s == null ? '' : s).toLowerCase().indexOf(String(k).toLowerCase()) >= 0; };
  var copy = function (o) { return JSON.parse(JSON.stringify(o)); };
  var assign = function (t) { for (var i = 1; i < arguments.length; i++) { var s = arguments[i]; if (s) for (var k in s) t[k] = s[k]; } return t; };
  var REG_ISO = function (r) { return r && r.indexOf('T') < 0 ? r.replace(' ', 'T') : r; };
  var days = M.days();

  // 데모 화면에 그대로 찍히는 'MOCK' 배지(전력량·가동률 화면 내장 목업 표시)는 숨긴다
  try { var st = document.createElement('style'); st.textContent = '.ut-mock,.pw-mock{display:none!important}'; document.head.appendChild(st); } catch (e) { /* ignore */ }

  /* ───────────────────────── 메뉴 (menuData.js / MenuServiceImpl과 동일) ───────────────────────── */
  var MENU = [
    { category: '기준정보', path: '/base', menus: [['사용자관리', '/base/user'], ['거래처관리', '/base/vendor'], ['제품관리', '/base/product'], ['패턴관리', '/base/pattern'], ['설비관리', '/base/equipment'], ['비가동관리', '/base/downtime'], ['경도관리', '/base/hardnessSpec'], ['사용자권한', '/base/auth'], ['로그인이력', '/base/loginHist']] },
    { category: '모니터링', path: '/monitoring', menus: [['종합생산현황', '/monitoring/prodStatus'], ['통합모니터링', '/monitoring/integrated'], ['경보모니터링', '/monitoring/alarm'], ['경보랭킹', '/monitoring/alarmRank'], ['TREND', '/monitoring/trend'], ['LOT 현황', '/monitoring/lotStatus'], ['LOT 트래킹', '/monitoring/lotTracking']] },
    { category: '생산관리', path: '/production', menus: [['작업지시관리', '/production/workOrder'], ['제품별작업관리', '/production/byItem'], ['설비효율현황', '/production/equipEff'], ['작업일보', '/production/dailyReport'], ['CHECK SHEET', '/production/checkSheet'], ['LOT 보고서', '/production/lotReport']] },
    { category: '조건관리', path: '/condition', menus: [['열전대/센서 관리', '/condition/sensor'], ['조절계 관리', '/condition/controller'], ['열처리유성상분석', '/condition/oilAnalysis'], ['설비점검표', '/condition/equipCheck'], ['관리계획서 및 작업표준서', '/condition/standard']] },
    { category: '품질관리', path: '/quality', menus: [['F/PROOF SAVE', '/quality/fproofSave'], ['F/PROOF LIST', '/quality/fproofList'], ['온도균일성보고서', '/quality/tempUniform'], ['경도측정', '/quality/hardness'], ['CPK 분석', '/quality/cpk'], ['PPK 분석', '/quality/ppk'], ['부적합품관리', '/quality/nonconform']] },
    { category: '설비관리', path: '/equipment', menus: [['설비비가동현황', '/equipment/downStatus'], ['설비가동률분석', '/equipment/utilRate'], ['전력량', '/equipment/powerUsage'], ['설비이력관리', '/equipment/history'], ['수리이력관리', '/equipment/repairHist'], ['SPARE 부품관리', '/equipment/sparePart']] }
  ];
  M.get('/api/menu/tree', function () {
    return D.ok(MENU.map(function (g) { return { category: g.category, path: g.path, menus: g.menus.map(function (m) { return { name: m[0], path: m[1] }; }) }; }));
  });

  /* ───────────────────────── 사용자 ───────────────────────── */
  var users = M.db('users', function () {
    var list = D.users.map(function (u) { return assign({}, u, { password: u.loginId, regDt: REG_ISO(u.regDt), updDt: REG_ISO(u.updDt) }); });
    list.push({ userId: 9, loginId: 'kmyoon', userName: '윤경민', deptName: '생산팀', phone: '010-3328-7710', email: 'km.yoon@ym-mes.co.kr', useYn: 'N', password: 'x', regDt: REG_ISO(D.users[0].regDt), updDt: REG_ISO(D.users[0].regDt) });
    list[0].password = 'ez';
    return list;
  }, 'userId');
  var pub = function (u) { var o = assign({}, u); delete o.password; return o; };

  M.get('/api/base/user', function (req) {
    var k = req.params.keyword;
    var list = users.all().filter(function (u) { return !k || has(u.loginId + u.userName, k); }).map(pub);
    return D.ok({ content: list, page: 1, size: list.length, totalElements: list.length, totalPages: 1 });
  });
  M.post('/api/base/user', function (req) {
    var b = req.body || {};
    if (!b.loginId || !b.password) return BAD('아이디와 비밀번호는 필수입니다.');
    if (users.all().some(function (u) { return u.loginId === b.loginId; })) return BAD('이미 사용 중인 아이디입니다.');
    var row = users.insert({ loginId: b.loginId, password: b.password, userName: b.userName, deptName: b.deptName, phone: b.phone, email: b.email, useYn: b.useYn || 'Y', regDt: nowIso(), updDt: nowIso() });
    return D.ok(pub(row));
  });
  M.put('/api/base/user/:userId', function (req) {
    var b = assign({}, req.body); delete b.userId; if (!b.password) delete b.password; b.updDt = nowIso();
    var row = users.update(req.params.userId, b);
    return row ? D.ok(pub(row)) : M.res(404, D.fail('존재하지 않는 사용자입니다.', 'NOT_FOUND'));
  });
  M.del('/api/base/user/:userId', function (req) {
    if (String(req.params.userId) === '1') return BAD('관리자 계정은 삭제할 수 없습니다.');
    users.remove(req.params.userId); return D.ok(null);
  });

  /* ───────────────────────── 로그인 / 로그인 이력 ───────────────────────── */
  var IP = { ez: '192.168.10.100', tskim: '192.168.10.121', yhjung: '192.168.10.135', sylee: '192.168.10.142', mjpark: '192.168.10.123', hwchoi: '192.168.10.124', jyhan: '192.168.10.143', dsoh: '192.168.10.136' };
  var loginHist = M.db('loginHist', function () {
    var out = [], now = new Date();
    var plan = { // [시작 시:분, 흔들림(분)]
      ez: [[8, 25, 20], [13, 10, 15]], tskim: [[7, 42, 10]], mjpark: [[7, 45, 12], [19, 44, 8]], hwchoi: [[19, 38, 10]],
      yhjung: [[8, 5, 15], [14, 30, 40]], dsoh: [[8, 12, 10]], sylee: [[8, 40, 12], [15, 10, 30]], jyhan: [[8, 50, 10]]
    };
    days.forEach(function (day) {
      var r = M.rng('ym-loginhist-' + day);
      D.users.forEach(function (u) {
        (plan[u.loginId] || []).forEach(function (p) {
          if (r.chance(0.12)) return;
          var t = M.addMinutes(M.toDate(day + ' 00:00:00'), p[0] * 60 + p[1] + r.int(-p[2], p[2]));
          if (t > now) return;
          if (r.chance(0.08)) out.push({ loginDt: iso(M.addMinutes(t, -1)), loginId: u.loginId, userName: u.userName, loginIp: IP[u.loginId], successYn: 'N', failReason: '비밀번호 불일치' });
          out.push({ loginDt: iso(t), loginId: u.loginId, userName: u.userName, loginIp: IP[u.loginId], successYn: 'Y', failReason: null });
        });
      });
      var t2 = M.addMinutes(M.toDate(day + ' 00:00:00'), r.int(600, 1000));
      if (t2 < now) out.push({ loginDt: iso(t2), loginId: r.pick(['admin', 'test', 'tskim1']), userName: null, loginIp: '192.168.10.' + r.int(150, 199), successYn: 'N', failReason: '존재하지 않는 아이디' });
    });
    var t3 = M.addMinutes(M.toDate(days[1] + ' 08:02:00'), 0);
    out.push({ loginDt: iso(t3), loginId: 'kmyoon', userName: '윤경민', loginIp: '192.168.10.127', successYn: 'N', failReason: '비활성화된 계정' });
    out.sort(function (a, b) { return a.loginDt < b.loginDt ? -1 : 1; });
    out.forEach(function (o, i) { o.histId = i + 1; });
    return out;
  }, 'histId');

  M.post('/api/base/login', function (req) {
    var b = req.body || {};
    var u = users.all().filter(function (x) { return x.loginId === b.loginId; })[0];
    var fail = !u ? '존재하지 않는 아이디' : u.useYn !== 'Y' ? '비활성화된 계정' : (u.loginId !== 'ez' || b.password !== 'ez') ? '비밀번호 불일치' : null;
    loginHist.insert({ loginDt: nowIso(), loginId: b.loginId, userName: u ? u.userName : null, loginIp: '192.168.10.100', successYn: fail ? 'N' : 'Y', failReason: fail });
    if (fail) return BAD('아이디 또는 비밀번호가 일치하지 않습니다.');
    return D.ok(pub(u));
  });
  M.get('/api/base/loginHist', function () {
    var list = loginHist.all().sort(function (a, b) { return a.loginDt < b.loginDt ? 1 : -1; });
    return D.ok({ content: list, page: 1, size: list.length, totalElements: list.length, totalPages: 1 });
  });

  /* ───────────────────────── 사용자권한 ───────────────────────── */
  var DEPT_CRUD = { '관리팀': null, '생산팀': ['모니터링', '생산관리'], '품질팀': ['품질관리', '조건관리'], '설비보전팀': ['설비관리', '조건관리'] };
  function defaultAuth(u) {
    var full = !u || u.deptName === '관리팀' || u.loginId === 'ez';
    var cats = DEPT_CRUD[u && u.deptName] || [];
    var items = [];
    MENU.forEach(function (g) {
      g.menus.forEach(function (m) {
        var edit = full || cats.indexOf(g.category) >= 0;
        var isBase = g.category === '기준정보';
        var read = full || !(isBase && (m[1] === '/base/auth' || m[1] === '/base/loginHist' || m[1] === '/base/user'));
        items.push({ category: g.category, menuName: m[0], menuPath: m[1], canCreate: edit, canRead: read, canUpdate: edit, canDelete: full || (edit && !isBase && u.loginId !== 'mjpark' && u.loginId !== 'hwchoi') });
      });
    });
    return items;
  }
  var auth = M.db('auth', function () { return []; }, 'userId');
  M.get('/api/base/auth/:userId', function (req) {
    var saved = auth.find(req.params.userId);
    if (saved) return D.ok(saved.items);
    return D.ok(defaultAuth(users.find(req.params.userId)));
  });
  M.put('/api/base/auth/:userId', function (req) {
    auth.upsert({ userId: +req.params.userId, items: Array.isArray(req.body) ? req.body : [] });
    return D.ok(null);
  });

  /* ───────────────────────── 거래처 ───────────────────────── */
  var vendors = M.db('vendors', function () { return D.vendors.map(function (v) { return assign({}, v, { regDt: REG_ISO(v.regDt), updDt: REG_ISO(v.updDt) }); }); }, 'vendorId');
  M.get('/api/base/vendor', function (req) {
    var q = req.params;
    return D.ok(vendors.all().filter(function (v) {
      return (!q.vendorType || v.vendorType === q.vendorType) && (!q.useYn || v.useYn === q.useYn) &&
        (!q.keyword || has(v.vendorCode + v.vendorName + v.ceoName + v.managerName + v.bizNo, q.keyword));
    }));
  });
  M.get('/api/base/vendor/:vendorId', function (req) { return D.ok(vendors.find(req.params.vendorId)); });
  M.post('/api/base/vendor', function (req) {
    var b = assign({}, req.body); delete b.vendorId;
    if (!b.vendorCode) {
      var pre = b.vendorType === '공급사' ? 'S' : 'V';
      var n = vendors.all().filter(function (v) { return v.vendorCode && v.vendorCode.charAt(0) === pre; }).length + 1;
      b.vendorCode = pre + M.pad(n, 3);
    }
    b.useYn = b.useYn || 'Y'; b.regDt = b.updDt = nowIso();
    return D.ok(vendors.insert(b));
  });
  M.put('/api/base/vendor/:vendorId', function (req) { var b = assign({}, req.body, { updDt: nowIso() }); delete b.vendorId; return D.ok(vendors.update(req.params.vendorId, b)); });
  M.post('/api/base/vendor/delete', function (req) { vendors.remove(arr(req)); return D.ok(null); });

  /* ───────────────────────── 제품 ───────────────────────── */
  var products = M.db('products', function () { return D.products.map(function (p) { return assign({}, p, { priceUnit: 'EA', regDt: REG_ISO(p.regDt), updDt: REG_ISO(p.updDt), images: [] }); }); }, 'productId');
  var joinVendor = function (p) { var v = vendors.find(p.vendorId) || {}; return assign({}, p, { vendorCode: v.vendorCode || p.vendorCode, vendorName: v.vendorName || p.vendorName, images: p.images || [] }); };
  M.get('/api/base/product', function (req) {
    var q = req.params;
    return D.ok(products.all().map(joinVendor).filter(function (p) {
      return (!q.vendorId || String(p.vendorId) === String(q.vendorId)) && (!q.useYn || p.useYn === q.useYn) &&
        (!q.keyword || has(p.productCode + p.partNo + p.productName + p.material + p.spec, q.keyword));
    }));
  });
  M.get('/api/base/product/:productId', function (req) { var p = products.find(req.params.productId); return D.ok(p ? joinVendor(p) : null); });
  M.post('/api/base/product', function (req) {
    var b = assign({}, req.body); delete b.productId; delete b.images;
    if (!b.productCode) b.productCode = 'P-' + (9000 + products.nextId());
    b.useYn = b.useYn || 'Y'; b.regDt = b.updDt = nowIso(); b.images = [];
    return D.ok(joinVendor(products.insert(b)));
  });
  M.put('/api/base/product/:productId', function (req) { var b = assign({}, req.body, { updDt: nowIso() }); delete b.productId; delete b.images; return D.ok(joinVendor(products.update(req.params.productId, b))); });
  M.post('/api/base/product/delete', function (req) { products.remove(arr(req)); return D.ok(null); });
  // 이미지 — 데모에서는 파일 서버가 없으므로 받기만 하고 목록에는 싣지 않는다
  M.post('/api/base/product/:productId/images', function (req) { return D.ok({ imageId: Date.now() % 100000, productId: +req.params.productId, slot: +req.params.slot || 1, origFileName: 'image.jpg' }); });
  M.del('/api/base/product/:productId/images/:imageId', function () { return D.ok(null); });
  M.put('/api/base/product/:productId/images/order', function () { return D.ok(null); });

  /* ───────────────────────── 패턴 + 변경 이력 ───────────────────────── */
  var patterns = M.db('patterns', function () { return D.patterns.map(function (p) { return assign({}, p, { regDt: REG_ISO(p.regDt), updDt: REG_ISO(p.updDt) }); }); }, 'patternId');
  var HF = [['패턴명', 'patternName'], ['장입량(kg)', 'chargeWeightKg'], ['퀜칭로 1존', 'q1Zone'], ['퀜칭로 2존', 'q2Zone'], ['퀜칭로 3존', 'q3Zone'], ['퀜칭로 4존', 'q4Zone'], ['퀜칭로 5존', 'q5Zone'],
    ['퀜칭로 속도', 'quenchSpeed'], ['CP(%)', 'cp'], ['템퍼링로 1존', 't1Zone'], ['템퍼링로 2존', 't2Zone'], ['템퍼링로 3존', 't3Zone'], ['템퍼링로 4존', 't4Zone'], ['템퍼링로 5존', 't5Zone'],
    ['템퍼링로 속도', 'temperSpeed'], ['속도 단위', 'speedUnit'], ['사용여부', 'useYn'], ['비고', 'remark']];
  var patternHist = M.db('patternHist', function () {
    var out = [], id = 0;
    var base = M.toDate(D.patterns[0].regDt);
    var mk = function (p, action, dt, user, label, b, a) { out.push({ histId: ++id, patternId: p.patternId, patternCode: p.patternCode, action: action, fieldLabel: label || null, beforeValue: b == null ? null : String(b), afterValue: a == null ? null : String(a), userName: user, regDt: iso(dt) }); };
    D.patterns.forEach(function (p) {
      var r = M.rng('ym-pthist-' + p.patternId);
      mk(p, '등록', M.addMinutes(base, p.patternId * 7), '관리자');
      var n = r.int(0, 3), t = M.addDays(base, r.int(5, 20));
      for (var k = 0; k < n; k++) {
        t = M.addMinutes(M.addDays(t, r.int(8, 30)), r.int(0, 480));
        var who = r.pick(['김태성', '이서연', '관리자']);
        var kind = r.int(0, 3);
        if (kind === 0) { mk(p, '수정', t, who, '퀜칭로 3존', p.q3Zone - 10, p.q3Zone); mk(p, '수정', t, who, '퀜칭로 4존', p.q4Zone - 10, p.q4Zone); }
        else if (kind === 1) mk(p, '수정', t, who, 'CP(%)', M.round(p.cp - 0.05, 2), p.cp);
        else if (kind === 2) mk(p, '수정', t, who, '템퍼링로 속도', p.temperSpeed + 2, p.temperSpeed);
        else { mk(p, '수정', t, who, '퀜칭로 속도', p.quenchSpeed - 2, p.quenchSpeed); mk(p, '수정', t, who, '비고', '', '초물 경도 상한 근접 — 속도 조정'); }
      }
    });
    return out;
  }, 'histId');
  var joinPattern = function (pt) {
    var p = products.find(pt.productId) || D.product(pt.productId) || {};
    var v = vendors.find(p.vendorId) || {};
    return assign({}, pt, {
      productCode: p.productCode, partNo: p.partNo, productName: p.productName, spec: p.spec, material: p.material,
      surfaceHardMin: p.surfaceHardMin, surfaceHardMax: p.surfaceHardMax, surfaceHardUnit: p.surfaceHardUnit || 'HRC',
      coreHardMin: p.coreHardMin, coreHardMax: p.coreHardMax, coreHardUnit: p.coreHardUnit || 'HRC',
      vendorId: p.vendorId, vendorCode: v.vendorCode, vendorName: v.vendorName
    });
  };
  M.get('/api/base/pattern', function (req) {
    var q = req.params;
    return D.ok(patterns.all().map(joinPattern).filter(function (p) {
      return (!q.vendorId || String(p.vendorId) === String(q.vendorId)) && (!q.productId || String(p.productId) === String(q.productId)) &&
        (!q.useYn || p.useYn === q.useYn) && (!q.keyword || has(p.patternCode + p.patternName + p.productName + p.partNo, q.keyword));
    }));
  });
  M.get('/api/base/pattern/:patternId', function (req) { var p = patterns.find(req.params.patternId); return D.ok(p ? joinPattern(p) : null); });
  M.get('/api/base/pattern/:patternId/history', function (req) {
    return D.ok(patternHist.all().filter(function (h) { return String(h.patternId) === String(req.params.patternId); })
      .sort(function (a, b) { return a.regDt === b.regDt ? b.histId - a.histId : (a.regDt < b.regDt ? 1 : -1); }));
  });
  M.post('/api/base/pattern', function (req) {
    var b = assign({}, req.body); delete b.patternId;
    b.patternCode = 'PT-' + M.pad(patterns.nextId(), 3);
    b.useYn = b.useYn || 'Y'; b.speedUnit = b.speedUnit || 'Hz'; b.regDt = b.updDt = nowIso(); b.updUserName = b.regUserName;
    var row = patterns.insert(b);
    patternHist.insert({ patternId: row.patternId, patternCode: row.patternCode, action: '등록', fieldLabel: null, beforeValue: null, afterValue: null, userName: b.regUserName || '관리자', regDt: row.regDt });
    return D.ok(joinPattern(row));
  });
  M.put('/api/base/pattern/:patternId', function (req) {
    var old = patterns.find(req.params.patternId);
    if (!old) return M.res(404, D.fail('존재하지 않는 패턴입니다.', 'NOT_FOUND'));
    old = copy(old);
    var b = assign({}, req.body, { updDt: nowIso() }); delete b.patternId;
    var row = patterns.update(req.params.patternId, b);
    var who = b.updUserName || '관리자';
    if (String(old.productId) !== String(row.productId)) {
      var po = products.find(old.productId) || {}, pn = products.find(row.productId) || {};
      patternHist.insert({ patternId: row.patternId, patternCode: row.patternCode, action: '수정', fieldLabel: '제품', beforeValue: po.partNo + ' ' + po.productName, afterValue: pn.partNo + ' ' + pn.productName, userName: who, regDt: b.updDt });
    }
    HF.forEach(function (f) {
      var a = old[f[1]], c = row[f[1]];
      if (f[1] === 'useYn') { a = a === 'N' ? '미사용' : '사용'; c = c === 'N' ? '미사용' : '사용'; }
      if (String(a == null ? '' : a) !== String(c == null ? '' : c) && !(a != null && c != null && a !== '' && c !== '' && Number(a) === Number(c))) {
        patternHist.insert({ patternId: row.patternId, patternCode: row.patternCode, action: '수정', fieldLabel: f[0], beforeValue: a == null ? '' : String(a), afterValue: c == null ? '' : String(c), userName: who, regDt: b.updDt });
      }
    });
    return D.ok(joinPattern(row));
  });
  M.post('/api/base/pattern/delete', function (req) {
    var ids = arr(req);
    ids.forEach(function (id) { var p = patterns.find(id); if (p) patternHist.insert({ patternId: p.patternId, patternCode: p.patternCode, action: '삭제', userName: req.params.userName || '관리자', regDt: nowIso() }); });
    patterns.remove(ids); return D.ok(null);
  });

  /* ───────────────────────── 설비 ───────────────────────── */
  var equips = M.db('equipments', function () { return D.equipments.map(function (e) { return assign({}, e, { regDt: REG_ISO(e.regDt), updDt: REG_ISO(e.updDt) }); }); }, 'equipId');
  M.get('/api/base/equipment', function (req) {
    var q = req.params;
    // useYn=Y 로만 부르는 화면은 경도관리·경도측정·부적합품(호기 칩/선택) — 열처리로만 보여야 '1호기' 칩이 겹치지 않는다
    var furnaceOnly = q.useYn === 'Y' && !q.equipStatus && !q.keyword;
    return D.ok(equips.all().filter(function (e) {
      return (!furnaceOnly || e.equipType === '연속열처리로') && (!q.equipStatus || e.equipStatus === q.equipStatus) && (!q.useYn || e.useYn === q.useYn) &&
        (!q.keyword || has(e.equipCode + e.equipName + e.equipType + e.maker + e.modelName + e.managerName, q.keyword));
    }));
  });
  M.get('/api/base/equipment/:equipId', function (req) { return D.ok(equips.find(req.params.equipId)); });
  M.post('/api/base/equipment', function (req) {
    var b = assign({}, req.body); delete b.equipId;
    if (!b.equipCode) return BAD('설비코드를 입력해주세요.');
    if (equips.all().some(function (e) { return e.equipCode === b.equipCode; })) return BAD('이미 사용 중인 설비코드입니다.');
    b.useYn = b.useYn || 'Y'; b.regDt = b.updDt = nowIso();
    return D.ok(equips.insert(b));
  });
  M.put('/api/base/equipment/:equipId', function (req) { var b = assign({}, req.body, { updDt: nowIso() }); delete b.equipId; return D.ok(equips.update(req.params.equipId, b)); });
  M.post('/api/base/equipment/delete', function (req) { equips.remove(arr(req)); return D.ok(null); });
  var eqOf = function (id) { return equips.find(id) || {}; };

  /* ───────────────────────── 비가동 사유 / 비가동 내역 ───────────────────────── */
  var reasons = M.db('downtimeReason', function () { return copy(D.downtimeReasons); }, 'reasonId');
  var downtimes = M.db('downtime', function () { return copy(D.downtimes()); }, 'downtimeId');

  M.get('/api/base/downtime-reason', function (req) {
    var q = req.params, dts = downtimes.all();
    return D.ok(reasons.all().filter(function (r) { return (!q.reasonType || r.reasonType === q.reasonType) && (!q.useYn || r.useYn === q.useYn); })
      .sort(function (a, b) { return (a.sortOrder || 0) - (b.sortOrder || 0); })
      .map(function (r) { return assign({}, r, { useCount: dts.filter(function (d) { return String(d.reasonId) === String(r.reasonId); }).length }); }));
  });
  M.post('/api/base/downtime-reason', function (req) {
    var b = assign({}, req.body); delete b.reasonId;
    if (!b.reasonCode) b.reasonCode = 'DR' + M.pad(reasons.nextId(), 3);
    b.useYn = b.useYn || 'Y'; b.regDt = b.updDt = nowIso();
    return D.ok(reasons.insert(b));
  });
  M.put('/api/base/downtime-reason/:reasonId', function (req) { var b = assign({}, req.body, { updDt: nowIso() }); delete b.reasonId; return D.ok(reasons.update(req.params.reasonId, b)); });
  M.post('/api/base/downtime-reason/delete', function (req) {
    var ids = arr(req), dts = downtimes.all();
    var used = ids.filter(function (id) { return dts.some(function (d) { return String(d.reasonId) === String(id); }); });
    if (used.length) return BAD('이미 비가동 내역에 쓰인 사유는 삭제할 수 없습니다. 미사용으로 바꿔주세요.');
    reasons.remove(ids); return D.ok(null);
  });

  function dtView(d) {
    var e = eqOf(d.equipId), r = reasons.find(d.reasonId) || {};
    var s = M.toDate(d.startDt), en = d.endDt ? M.toDate(d.endDt) : new Date();
    return assign({}, d, { equipCode: e.equipCode || d.equipCode, equipName: e.equipName || d.equipName, reasonCode: r.reasonCode || d.reasonCode, reasonName: r.reasonName || d.reasonName,
      reasonType: r.reasonType || d.reasonType, durationMin: Math.max(0, Math.round((en - s) / 60000)) });
  }
  function dtList(q) {
    var f = M.toDate(q.from), t = M.toDate(q.to);
    return downtimes.all().map(dtView).filter(function (d) {
      var s = M.toDate(d.startDt), e = d.endDt ? M.toDate(d.endDt) : new Date();
      return (!t || s < t) && (!f || e >= f) && (!q.equipId || String(d.equipId) === String(q.equipId)) && (!q.reasonType || d.reasonType === q.reasonType) &&
        (!q.keyword || has(d.reasonName + d.memo + d.regUserName + d.regUserId + d.equipName, q.keyword));
    }).sort(function (a, b) { return a.startDt < b.startDt ? 1 : -1; });
  }
  M.get('/api/base/downtime', function (req) { return D.ok(dtList(req.params)); });
  M.post('/api/base/downtime', function (req) {
    var b = req.body || {}, ids = b.equipIds || [];
    if (!ids.length) return BAD('설비를 선택해주세요.');
    var made = ids.map(function (eid) {
      return dtView(downtimes.insert({ equipId: +eid, reasonId: +b.reasonId, startDt: toIso(b.startDt), endDt: toIso(b.endDt), source: 'MANUAL', memo: b.memo || '',
        regUserId: b.regUserId || 'ez', regUserName: b.regUserName || '관리자', updUserId: null, updUserName: null, regDt: nowIso(), updDt: nowIso() }));
    });
    return D.ok(made);
  });
  M.put('/api/base/downtime/:downtimeId', function (req) {
    var b = req.body || {};
    var patch = { reasonId: +b.reasonId, startDt: toIso(b.startDt), endDt: toIso(b.endDt), memo: b.memo || '',
      updUserId: b.updUserId || 'ez', updUserName: b.updUserName || '관리자', updDt: nowIso() };
    if (b.equipId != null && b.equipId !== '') patch.equipId = +b.equipId;
    var row = downtimes.update(req.params.downtimeId, patch);
    return D.ok(row ? dtView(row) : null);
  });
  M.post('/api/base/downtime/delete', function (req) { downtimes.remove(arr(req)); return D.ok(null); });
  // 설비비가동현황 전용 API (현재 화면은 /api/base/downtime 사용)
  M.get('/api/equipment/downStatus', function (req) {
    var q = req.params;
    return D.ok(dtList({ from: q.from || q.startDate || days[0], to: q.to || q.endDate ? M.addDays(q.to || q.endDate, 1) : null, equipId: q.equipId, reasonType: q.reasonType, keyword: q.keyword }));
  });

  /* ───────────────────────── 경도 규격 (기준정보 > 경도관리) ───────────────────────── */
  var specs = M.db('hardnessSpec', function () { return copy(D.hardnessSpecs()); }, 'specId');
  var specView = function (s) {
    var p = products.find(s.productId) || {}, v = vendors.find(p.vendorId) || {}, e = equips.all().filter(function (x) { return x.equipCode === s.equipCode; })[0] || {};
    return assign({}, s, { equipName: e.equipName || s.equipName, vendorName: v.vendorName || s.vendorName, material: p.material || s.material, partNo: p.partNo || s.partNo, productName: p.productName || s.productName, measCount: s.measCount || 0 });
  };
  M.get('/api/quality/hardness/spec', function (req) {
    var q = req.params;
    return D.ok(specs.all().map(specView).filter(function (s) {
      return (!q.useYn || s.useYn === q.useYn) && (!q.equipCode || s.equipCode === q.equipCode) && (!q.keyword || has(s.partNo + s.productName + s.itemName, q.keyword));
    }).sort(function (a, b) { return (a.equipCode + a.partNo + a.itemName) < (b.equipCode + b.partNo + b.itemName) ? -1 : 1; }));
  });
  M.get('/api/quality/hardness/spec/:specId', function (req) { var s = specs.find(req.params.specId); return D.ok(s ? specView(s) : null); });
  M.post('/api/quality/hardness/spec', function (req) {
    var b = assign({}, req.body); delete b.specId;
    if (!b.equipCode || !b.productId) return BAD('호기와 품번을 선택해주세요.');
    if (specs.all().some(function (s) { return s.equipCode === b.equipCode && String(s.productId) === String(b.productId) && s.itemName === b.itemName; })) return BAD('같은 호기·품번·검사 항목의 규격이 이미 있습니다.');
    b.useYn = b.useYn || 'Y'; b.measCount = 0; b.regDt = b.updDt = nowIso();
    return D.ok(specView(specs.insert(b)));
  });
  M.put('/api/quality/hardness/spec/:specId', function (req) { var b = assign({}, req.body, { updDt: nowIso() }); delete b.specId; delete b.measCount; return D.ok(specView(specs.update(req.params.specId, b))); });
  M.post('/api/quality/hardness/spec/delete', function (req) { specs.remove(arr(req)); return D.ok(null); });

  /* ───────────────────────── 설비이력 · 수리이력 · 첨부 ───────────────────────── */
  var MAINT = ['정용호', '오동석'];
  var attaches = M.db('equipAttach', function () { return []; }, 'attachId');
  var repairs = M.db('repairHist', function () {
    var now = new Date(), out = [];
    var T = function (dAgo, hm) { var d = M.addDays(M.toDate(days[2] + ' 00:00:00'), -dAgo); var p = hm.split(':'); d.setHours(+p[0], +p[1], 0, 0); return d; };
    // [설비id, 며칠 전, 시각, 유형, 알람, 증상, 원인, 조치, 담당, 자체/외주, 외주업체, 고장→시작(분), 작업(분), 완료→복구(분), 상태, 부품비, 외주비, 부품[[명,품번,수량]]]
    var S = [
      [2, 84, '03:20', '히터 단선', 'AL-112', '퀜칭로 2존 승온 지연, 히터 전류 1상 0A', '히터 엘리먼트 노후 단선', '2존 히터 엘리먼트 1조 교체, 절연저항 측정 양호', '정용호', '자체', '', 25, 210, 40, '완료', 680000, 0, [['히터 엘리먼트 (칸탈 A1)', 'HE-KA1-12', 1]]],
      [5, 71, '14:05', '컨베이어 모터 고장', 'AL-305', '출구 컨베이어 정지, 모터 과열 냄새', '감속기 베어링 파손으로 과부하', '컨베이어 감속기 모터 교체(외주), 체인 장력 조정', '오동석', '외주', '경남모터서비스', 40, 300, 30, '완료', 1450000, 380000, [['기어드 모터 0.75kW', 'GM-075-1/30', 1], ['베어링 6205ZZ', '6205ZZ', 2]]],
      [1, 63, '22:40', '열전대 이상', 'AL-140', '퀜칭로 4존 온도 표시 급변(±30℃ 헌팅)', 'K열전대 보호관 크랙으로 소선 열화', 'K-Type 열전대 교체 후 교정 확인', '정용호', '자체', '', 15, 75, 20, '완료', 185000, 0, [['K-Type 열전대 Ø8×600', 'TC-K8-600', 1]]],
      [4, 52, '09:15', '과온 알람', 'AL-101', '템퍼링로 3존 과온 경보 (설정 +25℃)', 'SSR 단락으로 출력 고정', 'SSR 3상 75A 교체, 방열 그리스 재도포', '오동석', '자체', '', 10, 95, 25, '완료', 240000, 0, [['SSR 3상 75A', 'SSR-3P75', 1]]],
      [3, 45, '05:50', 'PLC 통신 오류', 'AL-901', 'HMI 전체 값 갱신 중단', '산업용 스위칭 허브 전원부 불량', '허브 교체 및 통신 케이블 재결선', '정용호', '자체', '', 20, 50, 10, '완료', 130000, 0, [['산업용 스위칭 허브 8P', 'EDS-208A', 1]]],
      [6, 38, '16:30', '인버터 이상', 'AL-320', '메쉬벨트 속도 지령 대비 실속도 -8%', '인버터 냉각팬 고장으로 과열 디레이팅', '인버터 냉각팬 교체, 파라미터 백업', '오동석', '자체', '', 30, 60, 15, '완료', 95000, 0, [['인버터 냉각팬 92mm', 'FAN-9225', 2]]],
      [9, 30, '11:10', '기계', '', 'RX가스 노점 상승(+6℃)', '촉매 활성 저하', 'RX 발생기 니켈 촉매 교체(외주)', '정용호', '외주', '동양가스텍', 120, 480, 90, '완료', 2300000, 650000, [['니켈 촉매', 'CAT-NI-20', 20]]],
      [2, 22, '02:10', '기계', 'AL-210', '메쉬벨트 사행, 우측 가이드 접촉음', '입구측 텐션 롤러 편마모', '텐션 롤러 교체 및 사행 보정', '오동석', '자체', '', 35, 140, 30, '완료', 420000, 0, [['텐션 롤러 Ø114', 'TR-114-1200', 1]]],
      [7, 15, '10:00', '기계', '', '세척기 스프레이 압력 저하', '노즐 막힘 및 필터 오염', '노즐 12EA 교체, 세척액 필터 교체', '정용호', '자체', '', 20, 80, 10, '완료', 156000, 0, [['스프레이 노즐 1/4"', 'NZ-1/4-65', 12], ['세척액 필터 10"', 'FL-10-25', 2]]],
      [5, 9, '19:40', '온도', 'AL-140', '퀜칭로 1존 온도 편차 -15℃', '버너 공연비 틀어짐', '공연비 조정 및 UV 플레임 센서 청소', '오동석', '자체', '', 15, 65, 20, '완료', 0, 0, []],
      [3, 4, '07:30', '히터 단선', 'AL-112', '템퍼링로 5존 승온 불량', '히터 단자부 산화로 접촉 불량', '단자 교체 및 체결 토크 관리', '정용호', '자체', '', 20, 70, 15, '완료', 45000, 0, [['히터 단자 세트', 'HT-TB-01', 1]]],
      [1, 2, '15:20', '기계', 'AL-210', '메쉬벨트 사행 경보', '벨트 장력 불균형', '가이드 롤러 조정, 벨트 장력 재설정', '오동석', '자체', '', 10, 45, 15, '완료', 0, 0, []],
      [6, 1, '23:05', '전기', 'AL-330', '소입유 교반기 정지', '교반기 모터 열동 트립', '열동계전기 리셋, 모터 절연 점검 — 베어링 소음 있어 교체 예정', '정용호', '자체', '', 15, 40, 10, '보류', 0, 0, [['베어링 6308ZZ', '6308ZZ', 2]]],
      [4, 0, null, '과온 알람', 'AL-101', '퀜칭로 3존 온도 이상 경보, 설정 대비 +12℃', '조절계 PID 응답 지연 추정 — 점검 중', '조절계 오토튜닝 진행 중', '오동석', '자체', '', 10, 0, 0, '진행', 0, 0, []]
    ];
    S.forEach(function (a, i) {
      var r = M.rng('ym-repair-' + i);
      var fail = a[2] ? T(a[1], a[2]) : new Date(Math.floor((now.getTime() - 25 * 60000) / 60000) * 60000);
      var start = M.addMinutes(fail, a[11]), end = a[12] ? M.addMinutes(start, a[12]) : null, rec = end ? M.addMinutes(end, a[13]) : null;
      if (a[14] === '보류') { end = null; rec = M.addMinutes(start, a[12]); }
      if (start > now) start = now;
      var e = D.equipments[a[0] - 1];
      out.push({ repairId: i + 1, repairNo: 'REP-' + M.fmt(fail, 'YYYYMM') + '-' + M.pad(i + 1, 3), equipId: e.equipId, failDt: iso(fail), failType: a[3], alarmCode: a[4], symptom: a[5], cause: a[6], action: a[7],
        repairerName: a[8], repairKind: a[9], vendorName: a[10], startDt: iso(start), endDt: iso(end), recoverDt: iso(rec), testResult: a[14] === '완료' ? '정상' : '', status: a[14],
        partCost: a[15], outsourceCost: a[16], parts: a[17].map(function (p, k) { return { partId: i * 10 + k + 1, repairId: i + 1, partName: p[0], partNo: p[1], qty: p[2], sortOrder: k + 1 }; }),
        regUserId: a[8] === '정용호' ? 'yhjung' : 'dsoh', regUserName: a[8], updUserId: null, updUserName: null, regDt: iso(new Date(Math.min(now, M.addMinutes(fail, a[11] + r.int(5, 30))))), updDt: iso(rec || start) });
    });
    return out;
  }, 'repairId');

  var histories = M.db('equipHistory', function () {
    var out = [], id = 0;
    var T = function (dAgo, hm) { var d = M.addDays(M.toDate(days[2] + ' 00:00:00'), -dAgo); var p = hm.split(':'); d.setHours(+p[0], +p[1], 0, 0); return d; };
    var H = [
      [1, 88, '09:00', '점검', '분기 정기 점검 (1분기)', '버너 12EA 점화 상태, 열전대 5EA 교정, 메쉬벨트 장력 점검 — 이상 없음', '정용호'],
      [2, 86, '10:30', '점검', '분기 정기 점검 (1분기)', '퀜칭로·템퍼링로 존별 온도 균일성 확인(±5℃ 이내), 소입유 레벨 보충', '정용호'],
      [3, 80, '13:00', '교체', '소입유 교반기 임펠러 교체', '마모된 교반 임펠러 교체, 소입유 유동 확인', '오동석'],
      [10, 77, '08:30', '점검', '냉각탑 수질 관리', '스케일 방지제 투입, 팬 벨트 장력 조정', '오동석'],
      [4, 74, '09:10', '변경', '템퍼링로 PID 파라미터 변경', '3존 오버슈트 개선을 위해 P 12→10, I 240→260 변경', '정용호'],
      [5, 69, '15:00', '교체', '메쉬벨트 교체', 'SUS310S 메쉬벨트 전체 교체(사용 26개월), 사행 조정 및 시운전', '오동석'],
      [6, 61, '10:00', '개조', '입구 장입 컨베이어 연장', '장입 대기 공간 확보를 위해 입구 컨베이어 1.2m 연장', '정용호'],
      [8, 58, '14:00', '설치', '세척기 2호기 오일 스키머 설치', '세척액 부유유 제거용 벨트식 오일 스키머 신규 설치', '오동석'],
      [9, 55, '09:00', '점검', 'RX가스 발생기 점검', '노점 측정(+2℃), 공기/가스 비율 조정', '정용호'],
      [1, 49, '11:20', '교체', '열전대 정기 교체', '퀜칭로 1~5존 K열전대 정기 교체(6개월 주기)', '정용호'],
      [3, 41, '16:00', '기타', '도어 실링 보수', '입구 도어 세라믹 로프 실링 부분 보수', '오동석'],
      [2, 33, '09:30', '변경', '퀜칭로 CP 제어 설정 변경', '산소센서 교정 후 CP 보정값 -0.03% 적용', '정용호'],
      [4, 27, '13:40', '교체', '템퍼링로 순환팬 베어링 교체', '순환팬 진동 4.2mm/s → 교체 후 1.1mm/s', '오동석'],
      [6, 20, '10:10', '점검', '전기 설비 열화상 점검', '판넬 단자 열화상 점검 — MCCB 2차측 1개소 체결 보강', '정용호'],
      [5, 12, '08:50', '점검', '분기 정기 점검 (2분기)', '버너·열전대·벨트 상태 양호, 소입유 산가 분석 의뢰', '정용호'],
      [7, 8, '13:30', '교체', '세척액 교체', '세척기 1호기 세척액 전량 교체(알칼리 탈지제 5%)', '오동석'],
      [3, 5, '10:20', '변경', '메쉬벨트 속도 레시피 정리', 'CQ 계열 패턴 속도 단위 Hz 통일, 레시피 백업', '정용호'],
      [1, 2, '09:40', '점검', '일상 점검 이상 조치', '퀜칭로 출구 커튼 화염 불안정 — 커튼 버너 노즐 청소', '오동석'],
      [9, 2, '21:40', '기타', 'RX가스 노점 이상 대응', '노점 상승으로 공기비 재조정, 촉매 상태 모니터링 강화', '정용호'],
      [2, 1, '14:10', '교체', '소입유 필터 교체', '소입유 순환 필터 엘리먼트 교체, 차압 0.8→0.2bar', '오동석'],
      [6, 0, '08:00', '점검', '6호기 정기 점검 착수', '정기 점검 착수 — 버너 분해 청소, 메쉬벨트 장력·롤러 점검, 열전대 교정 예정', '정용호']
    ];
    H.forEach(function (a) {
      var t = T(a[1], a[2]), e = D.equipments[a[0] - 1];
      id++;
      out.push({ histId: id, histNo: 'EQH-' + M.fmt(t, 'YYYYMM') + '-' + M.pad(id, 3), equipId: e.equipId, histType: a[3], title: a[4], content: a[5], workDt: iso(t), workerName: a[6], repairId: null,
        regUserId: a[6] === '정용호' ? 'yhjung' : 'dsoh', regUserName: a[6], updUserId: null, updUserName: null, regDt: iso(M.addMinutes(t, 90)), updDt: iso(M.addMinutes(t, 90)) });
    });
    return out;
  }, 'histId');

  // 첨부 시드 (파일명만 — 이미지 형식은 파일 서버가 없어 피한다)
  (function seedAttach() {
    if (attaches.all().length) return;
    var A = [['HISTORY', 1, '1분기_정기점검_체크리스트_1호기.pdf', 412300], ['HISTORY', 2, '온도균일성_측정결과_2호기.xlsx', 58120], ['HISTORY', 6, '메쉬벨트_교체_작업보고서.pdf', 1203400],
      ['HISTORY', 6, '메쉬벨트_사양서_SUS310S.pdf', 352000], ['HISTORY', 7, '입구컨베이어_연장_도면.dwg', 2280500], ['HISTORY', 14, '열화상점검_보고서_6호기.pdf', 3021000], ['HISTORY', 15, '정기점검_5호기_2분기.hwp', 88400],
      ['REPAIR', 2, '모터수리_견적서_경남모터서비스.pdf', 210300], ['REPAIR', 2, '수리완료_확인서.pdf', 160200], ['REPAIR', 7, 'RX촉매교체_작업보고서.pdf', 980300], ['REPAIR', 7, '노점측정_기록.xlsx', 22100],
      ['REPAIR', 4, 'SSR_교체_전후_전류기록.xlsx', 18300], ['REPAIR', 8, '텐션롤러_마모측정.xlsx', 15800]];
    A.forEach(function (a) {
      var base = a[0] === 'HISTORY' ? histories.find(a[1]) : repairs.find(a[1]);
      attaches.insert({ refType: a[0], refId: a[1], origName: a[2], fileSize: a[3], contentType: '', regUserId: base ? base.regUserId : 'yhjung', regUserName: base ? base.regUserName : '정용호', regDt: base ? base.regDt : nowIso() });
    });
  })();
  var attOf = function (type, id) { return attaches.all().filter(function (a) { return a.refType === type && String(a.refId) === String(id); }); };

  function repairView(r, detail) {
    var e = eqOf(r.equipId);
    var o = assign({}, r, { equipCode: e.equipCode, equipName: e.equipName, totalCost: (+r.partCost || 0) + (+r.outsourceCost || 0),
      downMin: r.failDt ? Math.round(((r.recoverDt ? M.toDate(r.recoverDt) : new Date()) - M.toDate(r.failDt)) / 60000) : null,
      workMin: r.startDt && r.endDt ? Math.round((M.toDate(r.endDt) - M.toDate(r.startDt)) / 60000) : null,
      attachCount: attOf('REPAIR', r.repairId).length, partCount: (r.parts || []).length });
    if (detail) o.attachments = attOf('REPAIR', r.repairId); else delete o.attachments;
    return o;
  }
  // 수리 '완료' ↔ 설비이력 '수리' 행 자동 연동
  function repairToHistory(r) {
    var linked = histories.all().filter(function (h) { return String(h.repairId) === String(r.repairId); })[0];
    var hasRepairRow = function () { return histories.all().some(function (h) { return String(h.repairId) === String(r.repairId); }); };
    if (r.status !== '완료') { if (linked) histories.remove(linked.histId); return; }
    var body = { equipId: r.equipId, histType: '수리', title: (r.failType || '수리') + ' 수리 — ' + (r.symptom || '').slice(0, 24), content: [r.cause && '원인: ' + r.cause, r.action && '조치: ' + r.action].filter(Boolean).join('\n'),
      workDt: r.endDt || r.startDt || r.failDt, workerName: r.repairerName, repairId: r.repairId, regUserId: r.regUserId, regUserName: r.regUserName, regDt: r.updDt || r.regDt, updDt: r.updDt || r.regDt };
    if (linked) histories.update(linked.histId, body);
    else if (!hasRepairRow()) { var row = histories.insert(body); var t = M.toDate(row.workDt) || new Date(); histories.update(row.histId, { histNo: 'EQH-' + M.fmt(t, 'YYYYMM') + '-' + M.pad(row.histId, 3) }); }
  }
  repairs.all().forEach(repairToHistory);

  function histView(h, detail) {
    var e = eqOf(h.equipId), rp = h.repairId ? repairs.find(h.repairId) : null;
    var o = assign({}, h, { equipCode: e.equipCode, equipName: e.equipName, repairNo: rp ? rp.repairNo : null, attachCount: attOf('HISTORY', h.histId).length + (rp ? attOf('REPAIR', rp.repairId).length : 0) });
    if (detail) o.attachments = attOf('HISTORY', h.histId).concat(rp ? attOf('REPAIR', rp.repairId) : []);
    return o;
  }
  var inR = function (v, q) { var d = M.toDate(v), f = M.toDate(q.from), t = M.toDate(q.to); return d && (!f || d >= f) && (!t || d < t); };

  M.get('/api/equipment/history', function (req) {
    var q = req.params;
    return D.ok(histories.all().filter(function (h) {
      return inR(h.workDt, q) && (!q.equipId || String(h.equipId) === String(q.equipId)) && (!q.histType || h.histType === q.histType);
    }).map(function (h) { return histView(h); }).filter(function (h) {
      return !q.keyword || has(h.histNo + h.title + h.content + h.workerName + h.equipName, q.keyword);
    }).sort(function (a, b) { return a.workDt < b.workDt ? 1 : -1; }));
  });
  M.get('/api/equipment/history/:histId', function (req) { var h = histories.find(req.params.histId); return h ? D.ok(histView(h, true)) : M.res(404, D.fail('존재하지 않는 이력입니다.', 'NOT_FOUND')); });
  M.post('/api/equipment/history', function (req) {
    var b = assign({}, req.body); delete b.histId; b.workDt = toIso(b.workDt) || nowIso(); b.repairId = null; b.regDt = b.updDt = nowIso();
    var row = histories.insert(b);
    return D.ok(histView(histories.update(row.histId, { histNo: 'EQH-' + M.fmt(M.toDate(b.workDt), 'YYYYMM') + '-' + M.pad(row.histId, 3) })));
  });
  M.put('/api/equipment/history/:histId', function (req) {
    var h = histories.find(req.params.histId);
    if (h && h.repairId) return BAD('수리이력에서 자동 생성된 이력은 수리이력관리에서 수정해주세요.');
    var b = assign({}, req.body, { updDt: nowIso() }); delete b.histId; if (b.workDt) b.workDt = toIso(b.workDt);
    return D.ok(histView(histories.update(req.params.histId, b)));
  });
  M.post('/api/equipment/history/delete', function (req) {
    var ids = arr(req).filter(function (id) { var h = histories.find(id); return h && !h.repairId; });
    histories.remove(ids); return D.ok(null);
  });

  M.get('/api/equipment/repairHist', function (req) {
    var q = req.params;
    return D.ok(repairs.all().filter(function (r) {
      return inR(r.failDt, q) && (!q.equipId || String(r.equipId) === String(q.equipId)) && (!q.status || r.status === q.status) && (!q.repairKind || r.repairKind === q.repairKind);
    }).map(function (r) { return repairView(r); }).filter(function (r) {
      return !q.keyword || has(r.repairNo + r.failType + r.alarmCode + r.symptom + r.cause + r.action + r.repairerName + r.vendorName + r.equipName, q.keyword);
    }).sort(function (a, b) { return a.failDt < b.failDt ? 1 : -1; }));
  });
  M.get('/api/equipment/repairHist/:repairId', function (req) { var r = repairs.find(req.params.repairId); return r ? D.ok(repairView(r, true)) : M.res(404, D.fail('존재하지 않는 수리이력입니다.', 'NOT_FOUND')); });
  var normRepair = function (b) {
    ['failDt', 'startDt', 'endDt', 'recoverDt'].forEach(function (k) { if (k in b) b[k] = toIso(b[k]); });
    b.partCost = +b.partCost || 0; b.outsourceCost = +b.outsourceCost || 0;
    b.parts = (b.parts || []).filter(function (p) { return p && p.partName; }).map(function (p, i) { return { partId: Date.now() % 1000000 + i, partName: p.partName, partNo: p.partNo || '', qty: p.qty == null ? 1 : +p.qty, sortOrder: i + 1 }; });
    delete b.repairId; delete b.attachments;
    return b;
  };
  M.post('/api/equipment/repairHist', function (req) {
    var b = normRepair(assign({}, req.body)); b.status = b.status || '접수'; b.regDt = b.updDt = nowIso();
    var row = repairs.insert(b);
    var t = M.toDate(row.failDt) || new Date();
    row = repairs.update(row.repairId, { repairNo: 'REP-' + M.fmt(t, 'YYYYMM') + '-' + M.pad(row.repairId, 3) });
    repairToHistory(row);
    return D.ok(repairView(row, true));
  });
  M.put('/api/equipment/repairHist/:repairId', function (req) {
    var b = normRepair(assign({}, req.body)); b.updDt = nowIso();
    var row = repairs.update(req.params.repairId, b);
    if (!row) return M.res(404, D.fail('존재하지 않는 수리이력입니다.', 'NOT_FOUND'));
    repairToHistory(row);
    return D.ok(repairView(row, true));
  });
  M.post('/api/equipment/repairHist/delete', function (req) {
    var ids = arr(req);
    histories.remove(histories.all().filter(function (h) { return h.repairId && ids.map(String).indexOf(String(h.repairId)) >= 0; }).map(function (h) { return h.histId; }));
    attaches.remove(attaches.all().filter(function (a) { return a.refType === 'REPAIR' && ids.map(String).indexOf(String(a.refId)) >= 0; }).map(function (a) { return a.attachId; }));
    repairs.remove(ids); return D.ok(null);
  });

  M.post('/api/equipment/attach', function (req) {
    var b = req.body || {}, files = b.files == null ? [] : (Array.isArray(b.files) ? b.files : [b.files]);
    var made = files.map(function (f) {
      return attaches.insert({ refType: b.refType, refId: +b.refId, origName: (f && f.fileName) || String(f), fileSize: (f && f.size) || 0, contentType: '', regUserId: b.regUserId, regUserName: b.regUserName, regDt: nowIso() });
    });
    return D.ok(made);
  });
  M.post('/api/equipment/attach/delete', function (req) { attaches.remove(arr(req)); return D.ok(null); });
  // 미리보기/다운로드 — 데모에는 실제 파일이 없어 안내 문구만
  M.get('/api/equipment/attach/:attachId', function (req) {
    var a = attaches.find(req.params.attachId);
    return M.res(200, '<!doctype html><meta charset="utf-8"><body style="font-family:sans-serif;padding:40px;color:#444">' + (a ? a.origName : '첨부파일') + '<br><small>데모 환경에서는 원본 파일을 제공하지 않습니다.</small></body>', 'text/html;charset=UTF-8');
  });

  /* ───────────────────────── SPARE 부품 ───────────────────────── */
  var SP = [ // [품명, 설비, 규격, 메이커, 단위, 안전재고, 교체유형, 구매주기, 보관위치, 랙, 초기입고]
    ['메쉬벨트 SUS310S', '연속열처리로 공용', '폭 1200 × 길이 32m', '한국메쉬', 'EA', 1, '정기', '년', '자재창고 A동', 'A-01', 2],
    ['K-Type 열전대', '연속열처리로 공용', 'Ø8 × 600L, 인코넬 보호관', '우진계기', 'EA', 10, '정기', '반기', '보전실', 'B-03', 30],
    ['R-Type 열전대', '연속열처리로 공용', 'Ø10 × 750L, 세라믹 보호관', '우진계기', 'EA', 3, '정기', '년', '보전실', 'B-03', 6],
    ['히터 엘리먼트 (칸탈 A1)', '연속열처리로 공용', 'Ø5.0, 12kW', 'Kanthal', 'EA', 4, '상시', '수시', '자재창고 A동', 'A-04', 8],
    ['래디언트 튜브', '연속열처리로 공용', 'Ø150 × 1800L, HK40', '대한로공업', 'EA', 2, '상시', '년', '자재창고 A동', 'A-02', 4],
    ['버너 점화봉', '연속열처리로 공용', 'IG-200', '한국써모텍', 'EA', 6, '상시', '반기', '보전실', 'B-01', 15],
    ['UV 플레임 센서', '연속열처리로 공용', 'UVS-10D0G1', 'Azbil', 'EA', 3, '상시', '수시', '보전실', 'B-01', 5],
    ['SSR 3상 75A', '연속열처리로 공용', '480VAC 75A', '한영넉스', 'EA', 3, '상시', '수시', '보전실', 'B-05', 6],
    ['인버터 3.7kW', '연속열처리로 공용', 'LSLV0037S100-4', 'LS ELECTRIC', 'EA', 1, '상시', '수시', '보전실', 'B-06', 2],
    ['산소센서 (CP 제어)', '연속열처리로 공용', 'ZrO2 Probe 900L', 'Marathon', 'EA', 1, '정기', '년', '보전실', 'B-04', 2],
    ['베어링 6308ZZ', '연속열처리로 공용', '40×90×23', 'NSK', 'EA', 6, '상시', '수시', '보전실', 'C-02', 12],
    ['베어링 6205ZZ', '연속열처리로 공용', '25×52×15', 'NSK', 'EA', 8, '상시', '수시', '보전실', 'C-02', 20],
    ['도어 실링 세라믹 로프', '연속열처리로 공용', 'Ø25, 1300℃', 'KCC', 'M', 10, '정기', '반기', '자재창고 A동', 'A-06', 30],
    ['소입유 필터 엘리먼트', '연속열처리로 공용', '10μm, 20"', 'Pall', 'EA', 4, '정기', '월', '자재창고 B동', 'D-01', 12],
    ['감속기 오일', '연속열처리로 공용', 'ISO VG220, 20L', 'SK루브리컨츠', 'CAN', 2, '정기', '반기', '자재창고 B동', 'D-03', 6],
    ['스프레이 노즐 1/4"', '세척기', '65° 플랫, SUS304', 'Spraying Systems', 'EA', 12, '상시', '수시', '자재창고 B동', 'D-05', 36],
    ['세척액 필터 10"', '세척기', '25μm 카트리지', '한국필터', 'EA', 6, '정기', '월', '자재창고 B동', 'D-05', 24],
    ['세척 펌프 메카니컬 씰', '세척기', 'Ø25, SiC/SiC', '이글버그만', 'SET', 1, '상시', '수시', '보전실', 'C-04', 2],
    ['니켈 촉매', 'RX 가스발생기', 'Ni 15%, Ø16 링', '동양가스텍', 'KG', 20, '정기', '년', '자재창고 B동', 'D-07', 40],
    ['RX 공기 필터', 'RX 가스발생기', 'HEPA 305×305', '동양가스텍', 'EA', 2, '정기', '반기', '자재창고 B동', 'D-07', 6],
    ['냉각탑 팬 벨트', '냉각탑', 'B-68', '반도', 'EA', 2, '정기', '년', '보전실', 'C-06', 4],
    ['PLC 입력카드 QX40', '연속열처리로 공용', 'DC24V 16점', 'Mitsubishi', 'EA', 1, '상시', '수시', '보전실', 'B-07', 2]
  ];
  var spareParts = M.db('spareParts', function () {
    return SP.map(function (a, i) {
      return { id: i + 1, partName: a[0], equipName: a[1], standard: a[2], maker: a[3], unit: a[4], safeStock: a[5], replaceType: a[6], buyCycle: a[7], storageLocation: a[8], rackNo: a[9],
        remark: '', regUserName: '오동석', useYn: 'Y', regDt: iso(M.addDays(M.toDate(days[0] + ' 09:00:00'), -150)), updDt: iso(M.addDays(M.toDate(days[0] + ' 09:00:00'), -150)) };
    });
  }, 'id');
  var spareHist = M.db('spareHist', function () {
    var out = [], id = 0, now = new Date();
    var WORK_OUT = { '연속열처리로 공용': ['MBF1', 'MBF2', 'MBF3', 'MBF4', 'MBF5', 'MBF6'], '세척기': ['WSH1', 'WSH2'] };
    SP.forEach(function (a, i) {
      var r = M.rng('ym-spare-' + i);
      var stock = a[10];
      out.push({ id: ++id, sparePartId: i + 1, type: 'IN', qty: a[10], workDesc: '초기 재고 등록', regUserName: '오동석', regDt: iso(M.addMinutes(M.addDays(M.toDate(days[0] + ' 09:00:00'), -150), i)) });
      var nOut = r.int(1, 4), t = M.addDays(M.toDate(days[0] + ' 10:00:00'), -r.int(100, 130));
      // 의도적으로 몇 품목은 안전재고 미만/재고없음이 되게
      var target = i === 4 ? 0 : (i === 7 || i === 13 || i === 18) ? Math.max(0, a[5] - r.int(1, 2)) : null;
      for (var k = 0; k < nOut; k++) {
        t = M.addMinutes(M.addDays(t, r.int(10, 30)), r.int(0, 400));
        if (t > now) break;
        var q = Math.min(stock - (target == null ? a[5] : 0), r.int(1, Math.max(1, Math.ceil(a[10] / 4))));
        if (q <= 0 || stock - q < 0) break;
        stock -= q;
        var where = WORK_OUT[a[1]] ? r.pick(WORK_OUT[a[1]]) : a[1];
        out.push({ id: ++id, sparePartId: i + 1, type: 'OUT', qty: q, workDesc: where + ' ' + r.pick(['정기 교체', '고장 수리 사용', '예방 보전 교체', '점검 중 교체']), regUserName: r.pick(MAINT), regDt: iso(t) });
      }
      if (target != null && stock > target) {
        var tt = M.addMinutes(M.toDate(days[r.int(0, 2)] + ' 00:00:00'), r.int(540, 960)); if (tt > now) tt = M.addMinutes(now, -90);
        out.push({ id: ++id, sparePartId: i + 1, type: 'OUT', qty: stock - target, workDesc: (i === 4 ? 'MBF2 래디언트 튜브 균열 교체' : 'MBF4 고장 수리 사용'), regUserName: r.pick(MAINT), regDt: iso(tt) });
        stock = target;
      } else if (r.chance(0.35)) {
        var ti = M.addMinutes(M.toDate(days[r.int(0, 2)] + ' 00:00:00'), r.int(560, 1000)); if (ti > now) ti = M.addMinutes(now, -120);
        out.push({ id: ++id, sparePartId: i + 1, type: 'IN', qty: Math.max(1, a[5]), workDesc: '정기 구매 입고', regUserName: '오동석', regDt: iso(ti) });
      }
    });
    return out;
  }, 'id');
  function partView(p) {
    var cur = spareHist.all().filter(function (h) { return String(h.sparePartId) === String(p.id); }).reduce(function (s, h) { return s + (h.type === 'IN' ? +h.qty : -h.qty); }, 0);
    return assign({}, p, { currentStock: cur, stockStatus: cur <= 0 ? '재고없음' : cur < p.safeStock ? '부족' : '정상' });
  }
  M.get('/api/equipment/sparePart', function (req) {
    var q = req.params;
    return D.ok(spareParts.all().filter(function (p) { return (!q.equipName || p.equipName === q.equipName) && (!q.keyword || has(p.partName, q.keyword)); }).map(partView));
  });
  M.get('/api/equipment/sparePart/equipNames', function () {
    var s = []; spareParts.all().forEach(function (p) { if (p.equipName && s.indexOf(p.equipName) < 0) s.push(p.equipName); }); return D.ok(s.sort());
  });
  M.get('/api/equipment/sparePart/history', function (req) {
    var q = req.params;
    return D.ok(spareHist.all().filter(function (h) {
      return (!q.partId || String(h.sparePartId) === String(q.partId)) && (!q.type || h.type === q.type) && M.inRange(h.regDt, q.from || null, q.to || null);
    }).map(function (h) { var p = spareParts.find(h.sparePartId) || {}; return assign({}, h, { partName: p.partName, unit: p.unit, equipName: p.equipName }); })
      .sort(function (a, b) { return a.regDt < b.regDt ? 1 : -1; }));
  });
  M.get(/^\/api\/equipment\/sparePart\/(\d+)$/,function (req) { var p = spareParts.find(req.match[1]); return D.ok(p ? partView(p) : null); });
  M.post('/api/equipment/sparePart', function (req) {
    var b = assign({}, req.body); delete b.id; b.useYn = b.useYn || 'Y'; b.regDt = b.updDt = nowIso();
    var row = spareParts.insert(b);
    if (+req.params.initialQty > 0) spareHist.insert({ sparePartId: row.id, type: 'IN', qty: +req.params.initialQty, workDesc: '초기 재고 등록', regUserName: b.regUserName || '관리자', regDt: nowIso() });
    return D.ok(partView(row));
  });
  M.put('/api/equipment/sparePart/:id', function (req) { var b = assign({}, req.body, { updDt: nowIso() }); delete b.id; delete b.currentStock; delete b.stockStatus; return D.ok(partView(spareParts.update(req.params.id, b))); });
  M.post('/api/equipment/sparePart/delete', function (req) {
    var ids = arr(req);
    spareHist.remove(spareHist.all().filter(function (h) { return ids.map(String).indexOf(String(h.sparePartId)) >= 0; }).map(function (h) { return h.id; }));
    spareParts.remove(ids); return D.ok(null);
  });
  M.post('/api/equipment/sparePart/history', function (req) {
    var b = req.body || {};
    var p = spareParts.find(b.sparePartId);
    if (!p) return BAD('부품을 선택해주세요.');
    if (b.type === 'OUT' && +b.qty > partView(p).currentStock) return BAD('현재고보다 많이 사용할 수 없습니다.');
    return D.ok(spareHist.insert({ sparePartId: +b.sparePartId, type: b.type === 'OUT' ? 'OUT' : 'IN', qty: +b.qty || 1, workDesc: b.workDesc || '', regUserName: b.regUserName || '관리자', regDt: nowIso() }));
  });
  M.del('/api/equipment/sparePart/history/:id', function (req) { spareHist.remove(req.params.id); return D.ok(null); });

  /* ───────────────────────── 가동률 / 전력량 (화면은 내장 목업 사용 — API 형식만 맞춰 둔다) ───────────────────────── */
  var TYPE_KEY = { '계획정지': 'plan', '고장정지': 'fail', '대기': 'wait', '기타': 'wait' };
  function utilDays(from, to) {
    var now = new Date(), out = [];
    M.daysIn(from, to).forEach(function (day) {
      var ds = M.toDate(day + ' 00:00:00'), de = M.addDays(ds, 1);
      var span = Math.max(0, Math.min(1440, Math.floor((Math.min(now, de) - ds) / 60000)));
      D.furnaces.forEach(function (f) {
        var eq = equips.all().filter(function (e) { return e.equipCode === f.code; })[0] || {};
        var stops = dtList({ from: iso(ds), to: iso(de), equipId: eq.equipId }).map(function (d) {
          var s = Math.max(M.toDate(d.startDt).getTime(), ds.getTime()), e = Math.min(d.endDt ? M.toDate(d.endDt).getTime() : now.getTime(), de.getTime(), now.getTime());
          return { type: TYPE_KEY[d.reasonType] || 'wait', cause: d.reasonName, start: s, end: e };
        }).filter(function (s) { return s.end > s.start; }).sort(function (a, b) { return a.start - b.start; });
        var o = { code: f.code, date: day, dayStart: ds.getTime(), span: span, run: 0, plan: 0, fail: 0, wait: 0, stops: stops };
        stops.forEach(function (s) { o[s.type] += Math.round((s.end - s.start) / 60000); });
        o.run = Math.max(0, span - o.plan - o.fail - o.wait);
        out.push(o);
      });
    });
    return out;
  }
  M.get('/api/equipment/utilRate/days', function (req) { return D.ok(utilDays(req.params.from, req.params.to)); });
  M.get('/api/equipment/utilRate', function (req) {
    var list = utilDays(req.params.from || req.params.startDate, req.params.to || req.params.endDate);
    var by = {};
    list.forEach(function (d) { var b = by[d.code] = by[d.code] || { equipCode: d.code, span: 0, run: 0, plan: 0, fail: 0, wait: 0 }; ['span', 'run', 'plan', 'fail', 'wait'].forEach(function (k) { b[k] += d[k]; }); });
    return D.ok(Object.keys(by).map(function (k) { var b = by[k]; b.equipName = (D.furnaces.filter(function (f) { return f.code === k; })[0] || {}).name; b.utilRate = b.span ? M.round(b.run / b.span * 100, 1) : 0; return b; }));
  });

  var KW = { MBF1: [214, 0.93], MBF2: [198, 0.855], MBF3: [226, 0.92], MBF4: [205, 0.9], MBF5: [188, 0.94], MBF6: [176, 0.91] };
  var HOUR = 3600000;
  function hourWh(code, hs) {
    var r = M.rng(code + '-pw-' + hs), h = new Date(hs).getHours();
    var idle = code === 'MBF6' && hs >= M.toDate(days[2] + ' 08:00:00').getTime();
    var kw = idle ? 58 * (0.95 + r() * 0.1) : KW[code][0] * (1 + 0.05 * Math.sin((h - 8) / 24 * Math.PI * 2)) * (0.94 + r() * 0.1);
    return { wh: Math.round(kw * 1000), varh: Math.round(kw * 1000 * Math.tan(Math.acos(KW[code][1]))) };
  }
  M.get('/api/equipment/powerUsage/series', function (req) {
    var now = Date.now(), unit = req.params.unit === 'day' ? 'day' : 'hour';
    var from = +req.params.from || M.toDate(days[0]).getTime(), to = Math.min(+req.params.to || now, now);
    var buckets = [], rows = [];
    var step = function (t) { return unit === 'day' ? M.addDays(new Date(t), 1).getTime() : t + HOUR; };
    var start = unit === 'day' ? M.startOfDay(new Date(from)).getTime() : Math.floor(from / HOUR) * HOUR;
    for (var t = start; t < to; t = step(t)) {
      buckets.push(t);
      var te = Math.min(step(t), to);
      D.furnaces.forEach(function (f) {
        var wh = 0, varh = 0;
        for (var hs = t; hs < te; hs += HOUR) { var u = hourWh(f.code, hs), frac = Math.min(1, (te - hs) / HOUR); wh += u.wh * frac; varh += u.varh * frac; }
        rows.push({ code: f.code, ts: t, wh: Math.round(wh), varh: Math.round(varh) });
      });
    }
    return D.ok({ unit: unit, buckets: buckets, rows: rows });
  });
  M.get('/api/equipment/powerUsage/meters', function () {
    var now = new Date();
    return D.ok(D.furnaces.map(function (f, i) {
      var base = 1102397412 + i * 48211337, hrs = (now - M.toDate(now.getFullYear() + '-01-01')) / HOUR;
      return { code: f.code, name: f.name, meterId: 'KDX300-' + M.pad(i + 1, 2), whTotal: Math.round(base + hrs * KW[f.code][0] * 1000), varhTotal: Math.round((base * 0.4) + hrs * KW[f.code][0] * 400), readAt: now.getTime(), status: 'ok' };
    }));
  });
  M.get('/api/equipment/powerUsage', function (req) {
    var out = [];
    M.daysIn(req.params.from || req.params.startDate, req.params.to || req.params.endDate).forEach(function (day) {
      var ds = M.toDate(day + ' 00:00:00').getTime(), end = Math.min(ds + 24 * HOUR, Date.now());
      D.furnaces.forEach(function (f) {
        var wh = 0; for (var hs = ds; hs < end; hs += HOUR) wh += hourWh(f.code, hs).wh;
        out.push({ workDate: day, equipCode: f.code, equipName: f.name, kwh: M.round(wh / 1000, 1) });
      });
    });
    return D.ok(out);
  });
})();
