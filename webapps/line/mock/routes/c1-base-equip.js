/* routes/c1-base-equip.js — 공통(사이드바/탭/권한) + 기준정보 + 설비관리 */
(function () {
  var M = window.MOCK, D = M.D;
  var DAYS = M.days();
  var NOW = new Date();
  var TODAY = DAYS[2];

  // sideBar.jsp(/main), workMonitoring.jsp 등은 now_page_code를 선언하지 않는데 pluginpage.jsp가 참조함 → ReferenceError 방지.
  // assignment로 만든(configurable) window 속성이라 각 화면의 `let now_page_code = ...` 선언이 그대로 우선한다.
  if (!('now_page_code' in window)) window.now_page_code = 'c02';

  function P(req) { return req.params || {}; }
  function s(v) { return v == null ? '' : String(v); }
  function has(v, kw) { return !kw || s(v).toLowerCase().indexOf(s(kw).toLowerCase()) >= 0; }
  function ymd(v) { return v ? M.fmt(M.toDate(v), 'YYYY-MM-DD') : ''; }
  // "이번 달 1일 ~ 오늘" 같은 월 단위 기본 조회에서도 데모 3일이 모두 보이도록 시작일을 당겨준다
  function looseFrom(from) {
    if (!from) return from;
    var f = ymd(from);
    if (f > DAYS[0] && f <= DAYS[2] && f.slice(8, 10) === '01') return DAYS[0] + s(from).slice(10);
    return from;
  }
  function nowStr(p) { return M.fmt(new Date(), p || 'YYYY-MM-DD HH:mm:ss'); }

  /* ═════════════════════ 공통: 로그인/메뉴/권한 ═════════════════════ */
  var MENU_KEYS = ['a01', 'a02', 'a03', 'a04', 'a05', 'a06', 'b01', 'b02', 'b03', 'b04', 'b05', 'b06',
    'c01', 'c02', 'c03', 'c04', 'c05', 'c06', 'c07', 'd01', 'd02', 'd03', 'd04', 'd05',
    'e01', 'e02', 'e03', 'e04', 'e05', 'e06', 'e07', 'f01', 'f02', 'f03', 'f04', 'f05'];

  function fullPerm() { // 모든 화면 코드에 D(최고권한)
    var o = { perm_code: 1, user_code: 1 };
    'abcdefghijk'.split('').forEach(function (g) { for (var i = 1; i <= 9; i++) o[g + '0' + i] = 'D'; });
    return o;
  }

  var users = M.db('c1_users', function () {
    var extra = [
      { user_code: 9, user_id: 'smj11', user_name: '서민재', dept: '생산팀', position: '사원', tel: '010-4187-2290' },
      { user_code: 10, user_id: 'hdy07', user_name: '한도윤', dept: '관리팀', position: '대리', tel: '010-8842-1137' },
      { user_code: 11, user_id: 'bsb24', user_name: '배수빈', dept: '품질팀', position: '사원', tel: '010-5309-7746' }
    ];
    var st = ['2014-03-02', '2016-07-11', '2018-02-19', '2017-09-04', '2013-05-13', '2022-01-10', '2021-03-15', '2019-11-04', '2023-08-21', '2020-06-01', '2024-02-13'];
    return D.workers.concat(extra).map(function (w, i) {
      return {
        user_code: String(w.user_code), user_id: w.user_id, user_pw: w.user_id === 'ez' ? 'ez' : '1234',
        user_name: w.user_name, st_day: st[i] || '2020-01-02', user_phone: w.tel,
        user_level: '기본', user_busu: w.dept, user_jick: w.position
      };
    });
  }, 'user_code');

  function defaultPerm(u) {
    var o = { perm_code: Number(u.user_code), user_code: Number(u.user_code) };
    var busu = u.user_busu, jick = u.user_jick;
    MENU_KEYS.forEach(function (k) {
      var g = k.charAt(0), v = 'R';
      if (u.user_id === 'ez' || busu === '관리팀') v = 'D';
      else if (g === 'a') v = (k === 'a05' || k === 'a01') ? 'N' : 'R';
      else if (busu === '생산팀' && (g === 'b' || g === 'c' || g === 'd')) v = (jick === '반장' || jick === '주임') ? 'D' : (g === 'c' ? 'U' : 'I');
      else if (busu === '생산팀' && g === 'e') v = 'R';
      else if (busu === '품질팀' && g === 'c') v = 'I';
      else if (busu === '품질팀' && (g === 'e' || k === 'd03' || k === 'c07')) v = 'D';
      else if (busu === '설비팀' && (g === 'f' || g === 'd')) v = 'D';
      o[k] = v;
    });
    return o;
  }
  var perms = M.db('c1_perm', function () { return users.all().map(defaultPerm); }, 'user_code');

  M.post('/user/login/menuSetting', function () {
    var o = { perm_code: 1, user_code: 1 };
    MENU_KEYS.forEach(function (k) { o[k] = 'D'; });
    return { data: o };
  });
  M.post('/user/info', function () {
    return {
      loginUser: { user_code: '1', user_id: 'ez', user_name: '관리자', user_busu: '관리팀', user_jick: '팀장', user_level: '기본' },
      loginUserPage: fullPerm()
    };
  });

  var menus = M.db('c1_menus', function () {
    return [
      { menu_idx: 1, user_code: 1, menu_url: '/line/monitoring/workMonitoring', menu_name: '종합생산현황' },
      { menu_idx: 2, user_code: 1, menu_url: '/line/monitoring/integrationMonitoring', menu_name: '통합모니터링' },
      { menu_idx: 3, user_code: 1, menu_url: '/line/productionManagement/heatTreatment', menu_name: '작업지시관리' },
      { menu_idx: 4, user_code: 1, menu_url: '/line/standard/nonTime', menu_name: '설비비가동현황' }
    ];
  }, 'menu_idx');
  M.post('/user/login/menuList', function () { return { data: menus.all() }; });
  M.post('/user/login/menuSave', function (req) {
    var p = P(req);
    var url = s(p.menu_url);
    if (url && !menus.all().some(function (m) { return m.menu_url === url; })) {
      menus.insert({ user_code: 1, menu_url: url, menu_name: s(p.menu_name).replace(/&nbsp;/g, ' ') });
      // 상단 탭은 최대 6개 — 넘치면 가장 오래된 탭부터 닫음
      var all = menus.all();
      if (all.length > 6) menus.remove(all.slice(0, all.length - 6).map(function (m) { return m.menu_idx; }));
    }
    return { data: 'OK' };
  });
  M.post('/user/login/menuRemove', function (req) {
    var url = s(P(req).menu_url);
    menus.remove(menus.all().filter(function (m) { return m.menu_url === url; }).map(function (m) { return m.menu_idx; }));
    return { data: 'OK' };
  });
  M.any('/user/logout', function () { return { data: 'OK' }; });

  /* ═════════════════════ 로그인 이력 ═════════════════════ */
  function seedLoginLogs() {
    var out = [], id = 0;
    var us = users.all();
    function u(id_) { for (var i = 0; i < us.length; i++) if (us[i].user_id === id_) return us[i]; return us[0]; }
    DAYS.forEach(function (d) {
      var r = M.rng('c1-login-' + d);
      var ev = [
        ['ez', 8, 32], ['ez', 13, 10],
        [r.pick(['kms0412', 'ljh88']), 7, 44], ['psj21', 8, 41], ['cyh77', 8, 25], ['yjs92', 8, 52],
        ['jhw15', 9, 5], ['hdy07', 8, 48], ['psj21', 14, 3], ['cyh77', 15, 37],
        [r.pick(['jdh03', 'ljh88']), 19, 46], ['smj11', 19, 52], ['bsb24', 10, 16], ['kms0412', 16, 20]
      ];
      ev.forEach(function (e, k) {
        var t = M.toDate(d + ' ' + M.pad(e[1]) + ':' + M.pad(Math.max(0, Math.min(59, e[2] + r.int(-6, 6)))) + ':' + M.pad(r.int(0, 59)));
        if (t > NOW) return;
        var x = u(e[0]);
        var memo = '로그인 성공';
        if (k === 4 || k === 9) memo = '로그인 성공 (현장 태블릿)';
        if (e[1] >= 19) memo = '로그인 성공 (야간조)';
        out.push({ log_id: ++id, user_code: x.user_code, user_id: x.user_id, user_name: x.user_name, user_busu: x.user_busu, user_jick: x.user_jick, login_dt: M.fmt(t), memo: memo });
      });
    });
    return out;
  }
  var loginLogs = M.db('c1_loginlog', seedLoginLogs, 'log_id');
  M.post('/user/login/log', function (req) {
    var p = P(req), x = users.find(p.user_code) || users.all()[0];
    loginLogs.insert({ user_code: x.user_code, user_id: x.user_id, user_name: x.user_name, user_busu: x.user_busu, user_jick: x.user_jick, login_dt: nowStr(), memo: s(p.memo) || '로그인 성공' });
    return { data: 'OK' };
  });
  M.post('/user/login/log/list', function () {
    return { data: loginLogs.all().sort(function (a, b) { return a.login_dt < b.login_dt ? 1 : -1; }) };
  });

  /* ═════════════════════ 사용자관리 ═════════════════════ */
  M.post('/user/userInsert/select', function (req) {
    var p = P(req);
    return users.all().filter(function (u) { return has(u.user_name, p.user_name); });
  });
  M.post('/user/userInsert/insert', function (req) {
    var p = P(req);
    if (!s(p.user_id).trim()) return { data: '아이디를 입력해주십시오!' };
    var row = { user_id: s(p.user_id), user_pw: s(p.user_pw), user_name: s(p.user_name), st_day: s(p.st_day), user_phone: s(p.user_phone), user_level: s(p.user_level) || '기본', user_busu: s(p.user_busu), user_jick: s(p.user_jick) };
    if (p.user_code) { row.user_code = String(p.user_code); users.upsert(row); }
    else { row.user_code = String(users.nextId()); users.insert(row); perms.insert(defaultPerm(row)); }
    return { data: 'OK' };
  });
  M.post('/user/userInsert/delete', function (req) { users.remove(P(req).user_code); return 'success'; });

  /* ═════════════════════ 사용자 권한 ═════════════════════ */
  M.post('/user/userPermission/userSelect', function () {
    return { last_page: 1, data: users.all().map(function (u, i) { return { idx: i + 1, user_id: u.user_id, user_name: u.user_name, user_busu: u.user_busu, user_jick: u.user_jick, user_code: u.user_code }; }) };
  });
  M.post('/user/userPermission/userSelectPermission', function (req) {
    var code = P(req).user_code, p = perms.find(code);
    if (!p) { var u = users.find(code); p = u ? defaultPerm(u) : fullPerm(); }
    return { data: p };
  });
  M.post('/user/userPermission/update', function (req) {
    var p = P(req), row = { user_code: Number(p.user_code) };
    MENU_KEYS.forEach(function (k) { if (p[k] != null) row[k] = p[k]; });
    perms.upsert(row);
    return {};
  });

  /* ═════════════════════ 거래처관리 ═════════════════════ */
  var customers = M.db('c1_cust', function () {
    var items = { C001: '자동차 부품(구동계)', C002: '조향장치 부품', C003: '샤시/볼조인트', C004: '엔진 부품', C005: '체결부품(고강도 볼트)', C006: '변속기 기어' };
    var reg = ['2019-05-02 10:12:31', '2019-08-21 14:40:02', '2020-03-11 09:25:47', '2020-11-30 16:02:19', '2021-06-07 11:33:58', '2022-04-18 13:47:05'];
    var rows = D.customers.map(function (c, i) {
      return { cust_id: i + 1, cust_code: c.cust_code, cust_name: c.cust_name, ceo_name: c.ceo, biz_no: c.biz_no, address: c.addr, biz_type: c.tel, biz_item: items[c.cust_code] || '자동차 부품', manager_name: c.manager, reg_date: reg[i] };
    });
    // 매입처(원자재·부자재·외주)
    rows.push({ cust_id: 7, cust_code: 'V001', cust_name: '세아특수강', ceo_name: '이태성', biz_no: '214-81-05517', address: '경북 포항시 남구 괴동로 33', biz_type: '054-271-6114', biz_item: '특수강 봉강(원자재)', manager_name: '권혁준', reg_date: '2019-04-10 09:00:00' });
    rows.push({ cust_id: 8, cust_code: 'V002', cust_name: '극동유화', ceo_name: '장홍선', biz_no: '101-81-26412', address: '울산 남구 처용로 450', biz_type: '052-278-3301', biz_item: '열처리유(소입유)', manager_name: '문지훈', reg_date: '2019-04-12 15:21:44' });
    rows.push({ cust_id: 9, cust_code: 'V003', cust_name: '대한로공업', ceo_name: '홍석구', biz_no: '137-81-48820', address: '인천 남동구 남동서로 236', biz_type: '032-814-7720', biz_item: '열처리로 제작/정비', manager_name: '신동욱', reg_date: '2019-04-15 10:05:13' });
    rows.push({ cust_id: 10, cust_code: 'V004', cust_name: '한국계측기술', ceo_name: '노승필', biz_no: '128-86-31175', address: '경기 고양시 일산동구 중앙로 1275', biz_type: '031-906-4410', biz_item: '열전대/온도계 교정', manager_name: '유가영', reg_date: '2020-01-20 13:18:36' });
    return rows;
  }, 'cust_id');
  M.post('/standard/customer/list', function () { return { status: 'success', data: customers.all() }; });
  function custForm(p) {
    return { cust_name: s(p.cust_name), ceo_name: s(p.ceo_name), biz_no: s(p.biz_no), address: s(p.address), biz_type: s(p.biz_type), biz_item: s(p.biz_item), manager_name: s(p.manager_name) };
  }
  M.post('/standard/customer/save', function (req) {
    var r = custForm(P(req)), id = customers.nextId();
    r.cust_id = id; r.cust_code = 'C' + M.pad(id, 3); r.reg_date = nowStr();
    customers.insert(r);
    return { status: 'success', result: 'success' };
  });
  M.post('/standard/customer/update', function (req) { var p = P(req); customers.update(p.cust_id, custForm(p)); return { status: 'success', result: 'success' }; });
  M.post('/standard/customer/delete', function (req) { customers.remove(P(req).cust_id); return { status: 'success', result: 'success' }; });

  /* ═════════════════════ 제품관리 ═════════════════════ */
  var specs = { P1001: 'Ø28×512', P1002: 'Ø92×64', P1003: 'Ø26×720', P1004: 'M2.5×Z38', P1005: 'Ø18×86', P1006: 'Ø42×58', P1007: 'M16×120', P1008: 'Ø22×95', P1009: 'Ø35×182', P1010: 'Tr24×5' };
  var price = { P1001: 1850, P1002: 1420, P1003: 1290, P1004: 960, P1005: 380, P1006: 820, P1007: 210, P1008: 540, P1009: 1180, P1010: 470 };
  var products = M.db('c1_prod', function () {
    return D.products.map(function (p, i) {
      var c = D.customer(p.cust_code);
      return {
        prod_id: i + 1, prod_code: p.prod_code, cust_code: c.cust_code, cust_name: c.cust_name,
        item_no: p.part_no, item_name: p.prod_name, spec: specs[p.prod_code] || '', texture: p.material,
        material: String(p.unit_wt > 1 ? 450 : 380), unit_price: price[p.prod_code] || 500, weight: Math.round(p.unit_wt * 1000),
        quench_low: String(p.hrc_min), quench_high: String(p.hrc_max),
        temper_low: String(Math.max(20, p.hrc_min - 8)), temper_high: String(Math.max(25, p.hrc_max - 6)),
        img_url_1: '', img_url_2: '', img_url_3: '', img_url_4: '', img_url_5: '',
        reg_date: M.fmt(M.addDays(M.toDate('2021-03-02 10:00:00'), i * 47), 'YYYY-MM-DD HH:mm:ss')
      };
    });
  }, 'prod_id');
  function prodRows(p) {
    return products.all().map(function (r) { var c = customers.all().filter(function (x) { return x.cust_code === r.cust_code; })[0]; if (c) r.cust_name = c.cust_name; return r; })
      .filter(function (r) { return has(r.item_no, p.item_no) && has(r.item_name, p.item_name) && has(r.cust_name, p.cust_name); });
  }
  M.post('/standard/product/list', function (req) { return { status: 'success', data: prodRows(P(req)) }; });
  function prodForm(p) {
    var o = {};
    ['prod_code', 'cust_code', 'item_no', 'item_name', 'spec', 'texture', 'material', 'unit_price', 'weight', 'quench_low', 'quench_high', 'temper_low', 'temper_high']
      .forEach(function (k) { if (p[k] != null && typeof p[k] !== 'object') o[k] = s(p[k]); });
    return o;
  }
  M.post('/standard/product/save', function (req) {
    var r = prodForm(P(req)); r.prod_id = products.nextId();
    if (!r.prod_code) r.prod_code = 'P' + (1000 + r.prod_id);
    r.reg_date = nowStr(); products.insert(r);
    return { status: 'success', result: 'success' };
  });
  M.post('/standard/product/update', function (req) { var p = P(req); products.update(p.prod_id, prodForm(p)); return { status: 'success', result: 'success' }; });
  M.post('/standard/product/delete', function (req) { products.remove(P(req).prod_id); return { status: 'success', result: 'success' }; });

  /* ═════════════════════ 패턴(레시피)관리 ═════════════════════ */
  var recipes = M.db('c1_recipe', function () {
    var out = [];
    D.products.forEach(function (p, i) {
      var r = M.rng('c1-recipe-' + p.prod_code);
      var q = p.q_temp, t = p.t_temp;
      var row = {
        recipe_id: i + 1, recipe_code: 'RCP-' + p.prod_code.slice(1), prod_code: p.prod_code, cust_code: p.cust_code, cust_name: D.customer(p.cust_code).cust_name,
        item_no: p.part_no, item_name: p.prod_name, spec: specs[p.prod_code] || '', texture: p.material,
        temper_low: String(Math.max(20, p.hrc_min - 8)), temper_high: String(Math.max(25, p.hrc_max - 6)),
        charge_weight: String(p.unit_wt > 1 ? 450 : 380),
        q1_zone: String(q - 10), q2_zone: String(q), q3_zone: String(q), q4_zone: String(q), q5_zone: String(q - 10),
        q_speed: String(Math.round(5400 / p.cycle_min) / 10), cp: (p.material.indexOf('SCM420') === 0 ? 0.80 : r.pick([0.45, 0.50, 0.55])).toFixed(2),
        t1_zone: String(t), t2_zone: String(t + 10), t3_zone: String(t + 10), t4_zone: String(t + 5), t5_zone: String(t),
        t_speed: String(Math.round(5400 / p.cycle_min) / 10),
        reg_date: M.fmt(M.addDays(M.toDate('2021-03-05 14:20:00'), i * 47 + 3))
      };
      out.push(row);
    });
    return out;
  }, 'recipe_id');
  M.post('/standard/recipe/list', function (req) {
    var p = P(req);
    return { status: 'success', data: recipes.all().filter(function (r) { return has(r.item_no, p.item_no) && has(r.item_name, p.item_name) && has(r.cust_name, p.cust_name); }) };
  });
  M.post('/standard/recipe/getRecipeProduct', function () {
    return { status: 'success', data: products.all().map(function (r) { return { prod_code: r.prod_code, item_no: r.item_no, item_name: r.item_name, cust_code: r.cust_code }; }) };
  });
  function recipeForm(p) {
    var o = {};
    ['recipe_code', 'prod_code', 'charge_weight', 'q1_zone', 'q2_zone', 'q3_zone', 'q4_zone', 'q5_zone', 'q_speed', 'cp', 't1_zone', 't2_zone', 't3_zone', 't4_zone', 't5_zone', 't_speed']
      .forEach(function (k) { if (p[k] != null) o[k] = s(p[k]); });
    var pr = products.all().filter(function (x) { return x.prod_code === o.prod_code || x.item_no === p.item_name; })[0];
    if (pr) { o.prod_code = pr.prod_code; o.item_no = pr.item_no; o.item_name = pr.item_name; o.cust_code = pr.cust_code; o.cust_name = pr.cust_name; o.spec = pr.spec; o.texture = pr.texture; o.temper_low = pr.temper_low; o.temper_high = pr.temper_high; }
    return o;
  }
  M.post('/standard/recipe/save', function (req) {
    var o = recipeForm(P(req)); o.recipe_id = recipes.nextId();
    if (!o.recipe_code) o.recipe_code = 'RCP-' + M.pad(o.recipe_id, 3);
    o.reg_date = nowStr(); recipes.insert(o);
    return { status: 'success', result: 'success' };
  });
  M.post('/standard/recipe/update', function (req) { var p = P(req); recipes.update(p.recipe_id, recipeForm(p)); return { status: 'success', result: 'success' }; });
  M.post('/standard/recipe/delete', function (req) { recipes.remove(P(req).recipe_id); return { status: 'success', result: 'success' }; });

  /* ═════════════════════ 설비 비가동현황 ═════════════════════ */
  var nonTime = M.db('c1_nontime', function () { return D.downtimes(); }, 'non_time_idx');
  function ntFilter(p) {
    var from = looseFrom(p.startDate), to = p.endDate, eq = s(p.equipment_name);
    return nonTime.all().filter(function (r) {
      return (!eq || r.equipment_name === eq) && M.inRange(r.start_time, from ? ymd(from) : '', to ? ymd(to) : '');
    }).sort(function (a, b) { return a.start_time < b.start_time ? 1 : -1; });
  }
  function mins(r) {
    var st = M.toDate(r.start_time), en = r.end_time ? M.toDate(r.end_time) : new Date();
    return Math.max(0, Math.round((en - st) / 60000));
  }
  M.post('/standard/nonTime/list', function (req) {
    var data = ntFilter(P(req));
    return { status: 'success', data: data, count: data.length };
  });
  M.post('/standard/nonTime/view', function (req) {
    var data = ntFilter(P(req)), g = {};
    data.forEach(function (r) {
      var k = r.equipment_name + '|' + r.info_list;
      var x = g[k] = g[k] || { v_equipment_name: r.equipment_name, info_list_v: r.info_list, sum_time: 0, perDay: {}, month_count: 0 };
      if (r.end_time) x.sum_time += mins(r);
      x.month_count++;
      var d = r.start_time.slice(0, 10); x.perDay[d] = (x.perDay[d] || 0) + 1;
    });
    var out = Object.keys(g).map(function (k) {
      var x = g[k], mx = 0;
      for (var d in x.perDay) mx = Math.max(mx, x.perDay[d]);
      return { v_equipment_name: x.v_equipment_name, info_list_v: x.info_list_v, sum_time: x.sum_time, sum_time_ch: Math.floor(x.sum_time / 60) + '시간 ' + (x.sum_time % 60) + '분', day_count: mx, month_count: x.month_count };
    }).sort(function (a, b) { return b.sum_time - a.sum_time; });
    return { status: 'success', data: out, count: out.length };
  });
  function ntForm(p) {
    var o = { equipment_name: s(p.equipment_name) || '열처리 연속로', standard_code: s(p.standard_code) || '열처리 연속로', info_list: s(p.info_list) || '기타', start_time: s(p.start_time).slice(0, 16), end_time: s(p.end_time).slice(0, 16), non_time_memo: s(p.non_time_memo) };
    return o;
  }
  M.post('/standard/nonTime/insert', function (req) { nonTime.insert(ntForm(P(req))); return { result: 'success' }; });
  M.post('/standard/nonTime/update', function (req) { var p = P(req); nonTime.update(p.non_time_idx, ntForm(p)); return { result: 'success' }; });
  M.post('/standard/nonTime/delete', function (req) { nonTime.remove(P(req).non_time_idx); return { result: 'success' }; });

  /* ═════════════════════ 설비 가동률 분석 ═════════════════════ */
  M.post('/standard/operation/rate', function (req) {
    var p = P(req);
    var st = M.toDate(p.startDate), en = M.toDate(p.endDate), now = new Date();
    if (en > now) en = now;
    var stdMin = Math.max(0, (en - st) / 60000), downMin = 0, cnt = 0;
    var eq = s(p.equipment_name);
    nonTime.all().forEach(function (r) {
      if (eq && r.equipment_name !== eq) return;
      var a = M.toDate(r.start_time), b = r.end_time ? M.toDate(r.end_time) : now;
      var o = Math.min(b, en) - Math.max(a, st);
      if (o > 0) { downMin += o / 60000; cnt++; }
    });
    var std = M.round(stdMin / 60, 2), down = M.round(downMin / 60, 2);
    return { standardHours: std, downHours: down, runHours: M.round(std - down, 2), downCount: cnt, status: 'success' };
  });

  /* ═════════════════════ 설비이력관리 (보전) ═════════════════════ */
  var machineHist = M.db('c1_mhist', function () {
    var t = M.toDate(TODAY);
    function d(n) { return M.fmt(M.addDays(t, n), 'YYYY-MM-DD'); }
    var dt = D.downtimes();
    var rows = [
      [-2, '소입로 3존 열전대(K-type) 교체', '11:35 열전대 단선 알람(AL-701) 발생. 소입로 3존 K-type 열전대(Ø8×1000L) 예비품으로 교체 후 기준 열전대와 비교 측정, 편차 +1.2℃로 허용범위(±3℃) 이내 확인. 교체품 SPARE 출고 처리.'],
      [-1, '소입유조 필터 엘리먼트 교체 및 교반기 그리스 주입 (월간 PM)', '소입유 순환 필터 엘리먼트 2EA 교체(차압 0.18MPa → 0.04MPa). 교반기 1·2호 베어링 그리스 주입. 소입유 온도 70℃, 레벨 정상.'],
      [-1, '메쉬벨트 구동모터 과전류 조치', '03:10 메쉬벨트 모터 과전류 트립(AL-302). 구동 체인 장력 조정 및 스프로켓 마모 점검. 재가동 후 전류 정격 대비 92% 확인, 차기 PM 시 체인 교체 예정.'],
      [0, 'RX 가스발생기 혼합비 재조정', '02:25 RX가스 유량 저하 알람. 공기/LPG 혼합비 재조정, 노점 -2℃ 회복 확인. 촉매 교체 주기 도래 예정(다음달) — 촉매 구매 요청.'],
      [-6, '세척 2호기 노즐 청소 및 세척액 교체', '세척 노즐 막힘 12개소 청소, 세척액(알칼리계) 전량 교체 및 액온 60℃ 설정 확인.'],
      [-13, '소려로 순환팬 베어링 교체', '소려로 2존 순환팬 진동 상승(4.8mm/s) → 베어링 6310ZZ 2EA 교체, 교체 후 진동 1.6mm/s 정상.'],
      [-21, '온도조절계 보정 (소입로 1~5존)', '한국계측기술 입회 하 소입로 1~5존 온도조절계 보정 실시. 최대 편차 -1.8℃(3존), 보정 후 ±0.5℃ 이내.'],
      [-34, '메쉬벨트 부분 교체 (2m)', '메쉬벨트 사행 및 끊어짐 발생 구간 2m 교체(SUS310S). 장력 재조정 및 무부하 시운전 2시간 이상 없음.'],
      [-48, '소입로 히터 저항 측정', '소입로 1~5존 히터 절연저항/저항값 측정. 4존 U상 히터 저항 상승(+8%) 확인 — 예비 히터 1EA 확보 후 교체 계획 수립.'],
      [-62, 'TUS(온도균일성 조사) 실시', 'AMS2750 기준 TUS 실시. 소입로 Class 2(±5.5℃) 충족, 최대 편차 +3.1℃. 보고서 품질팀 제출.'],
      [-77, '방청기 펌프 메커니컬 씰 교체', '방청액 누유 발생. 펌프 메커니컬 씰 교체 및 배관 플랜지 가스켓 교체.'],
      [-95, '소입로 4존 히터 교체', '4존 U상 히터 단선. 예비 히터(SiC 발열체)로 교체 후 승온 시험, 전류 밸런스 정상.'],
      [-118, 'RX 가스발생기 촉매 교체', '니켈 촉매 전량 교체 및 레토르트 내부 카본 제거(번아웃). 노점 안정화 확인.'],
      [-142, '소입유 성상분석 결과 조치', '극동유화 성상분석 결과 수분 0.04%, 냉각성능 정상. 산가 소폭 상승으로 보충유 200L 투입.'],
      [-171, '열전대 정기 교체 (소입로/소려로 전 존)', '6개월 주기 정기 교체. 소입로·소려로 10개소 K-type 열전대 교체 및 교체 이력 등록.'],
      [-205, '노체 단열재 보수', '소입로 장입부 도어 주변 단열재(세라믹 화이버) 손상부 보수, 표면 온도 82℃ → 54℃.'],
      [-240, '세척 1호기 히터 교체', '세척기 탱크 히터 1EA 단선 교체(9kW). 액온 승온 시간 정상화.'],
      [-288, '연간 정기 오버홀', '하계 휴가 기간 전체 라인 정지 오버홀. 메쉬벨트 전체 교체, 레토르트 점검, 안전장치(비상정지·가스차단) 작동 시험.'],
      [-330, '비상정지 회로 점검', '라인 전체 비상정지 버튼 8개소 동작 시험 및 가스 차단 밸브 연동 확인.'],
      [-371, 'PLC 백업 및 HMI 점검', 'PLC 프로그램 백업, HMI 터치 보정, UPS 배터리 상태 점검(교체 권고).'],
      [-420, '소려로 열전대 교체', '소려로 3·4존 열전대 교체. 비교검증(SAT) 결과 편차 ±1.5℃ 이내.'],
      [-480, '메쉬벨트 구동 감속기 오일 교환', '감속기 기어오일(ISO VG220) 교환, 오일 내 마모분 소량 확인.'],
      [-560, '소입로 레토르트 점검', '레토르트 변형/균열 육안 및 내시경 점검, 이상 없음.'],
      [-650, '설비 도입 후 정기점검 (대한로공업)', '제작사 정기점검. 버너/히터, 가스라인 누설시험, 각종 인터록 동작 확인.']
    ];
    return rows.map(function (r, i) { return { m_idx: i + 1, m_date: d(r[0]), m_title: r[1], m_desc: r[2] }; })
      .sort(function (a, b) { return a.m_date < b.m_date ? 1 : -1; });
  }, 'm_idx');
  M.post('/quality/machineManage/list', function (req) {
    var p = P(req);
    var rows = machineHist.all().filter(function (r) { return M.inRange(r.m_date, p.m_sdate ? ymd(p.m_sdate) : '', p.m_edate ? ymd(p.m_edate) : ''); })
      .sort(function (a, b) { return a.m_date < b.m_date ? 1 : (a.m_date > b.m_date ? -1 : b.m_idx - a.m_idx); });
    return { data: rows };
  });
  M.post('/quality/machineManage/save', function (req) {
    var p = P(req), row = { m_date: s(p.m_date) || TODAY, m_title: s(p.m_title), m_desc: s(p.m_desc) };
    if (p.m_idx && String(p.m_idx) !== '0') { machineHist.update(p.m_idx, row); } else { machineHist.insert(row); }
    return { data: 'OK', result: 'success' };
  });
  M.post('/quality/machineManage/delete', function (req) { machineHist.remove(P(req).m_idx); return { data: 'OK', result: 'success' }; });

  /* ═════════════════════ 스페어파트 관리 ═════════════════════ */
  // [partNo, partName, category, equipment, spec, maker, unit, minStock, stockNow, price, cycle, sensitivity, lead, leadUnit, color, customerYn, remark]
  var PARTS = [
    ['SP-TC-001', '열전대 K-type (소입로)', '계측', '소입로', 'K-type Ø8×1000L, SUS310S 보호관', '한국계측기술', 'EA', 4, 3, 185000, 6, '상', 2, '주', 'Y', 'N', '전 존 공용, 6개월 정기교체'],
    ['SP-TC-002', '열전대 K-type (소려로)', '계측', '소려로', 'K-type Ø6.4×800L', '한국계측기술', 'EA', 3, 5, 142000, 6, '중', 2, '주', 'W', 'N', ''],
    ['SP-TC-003', '보상도선 K-type', '계측', '공통', 'KX-H 1.25SQ×2C', '대한전선', 'M', 50, 120, 3200, 0, '하', 5, '일', 'W', 'N', ''],
    ['SP-HT-001', '발열체 (SiC 히터)', '히터', '소입로', 'Ø45×1200L, 18kW', 'Kanthal', 'EA', 2, 1, 1680000, 24, '상', 6, '주', 'G', 'N', '4존 저항 상승 — 발주 진행중'],
    ['SP-HT-002', '시즈 히터 (세척기)', '히터', '세척 1호기', '380V 9kW, U형', '세진테크', 'EA', 2, 2, 265000, 12, '중', 10, '일', 'W', 'N', ''],
    ['SP-HT-003', '소려로 히터 엘리먼트', '히터', '소려로', 'Fe-Cr-Al 코일, 12kW', 'Kanthal', 'EA', 2, 3, 920000, 36, '중', 4, '주', 'W', 'N', ''],
    ['SP-MB-001', '메쉬벨트 (SUS310S)', '메쉬벨트', '연속열처리로', '폭 600mm, 2m 단위', '대한로공업', 'M', 4, 6, 780000, 12, '상', 8, '주', 'W', 'N', '부분 교체용 예비'],
    ['SP-MB-002', '메쉬벨트 구동 체인', '구동부', '연속열처리로', 'RS80 무단, 10ft', '대동체인', 'EA', 1, 1, 214000, 12, '중', 1, '주', 'W', 'N', ''],
    ['SP-MB-003', '구동 스프로켓', '구동부', '연속열처리로', 'RS80 Z17', '대동체인', 'EA', 2, 2, 96000, 24, '하', 2, '주', 'W', 'N', ''],
    ['SP-MT-001', '메쉬벨트 구동모터', '모터', '연속열처리로', '3.7kW 4P, 감속비 1/60', '효성중공업', 'EA', 1, 1, 1450000, 0, '상', 4, '주', 'Y', 'N', '단일 예비품 — 고장 시 라인정지'],
    ['SP-MT-002', '순환팬 모터 (소려로)', '모터', '소려로', '5.5kW 4P, 내열형', '효성중공업', 'EA', 1, 0, 1980000, 0, '상', 6, '주', 'G', 'N', '견적 접수, 발주 대기'],
    ['SP-MT-003', '교반기 모터 (소입유조)', '모터', '유조(소입유)', '2.2kW 4P', 'LS산전', 'EA', 1, 1, 680000, 0, '중', 3, '주', 'W', 'N', ''],
    ['SP-BR-001', '순환팬 베어링', '구동부', '소려로', '6310ZZ', 'NSK', 'EA', 4, 6, 38000, 12, '중', 3, '일', 'W', 'N', ''],
    ['SP-SN-001', 'O2 센서 (노점 분석)', '계측', 'RX 가스발생기', '지르코니아식, 0~1000mV', 'Marathon', 'EA', 1, 1, 2350000, 18, '상', 8, '주', 'Y', 'N', '수입품 리드타임 김'],
    ['SP-SN-002', '압력 트랜스미터', '계측', '연속열처리로', '0~50mmAq, 4~20mA', '요꼬가와', 'EA', 1, 2, 540000, 0, '중', 3, '주', 'W', 'N', ''],
    ['SP-SN-003', '레벨 스위치 (세척기)', '계측', '세척 2호기', '플로트식', '세진테크', 'EA', 2, 1, 72000, 0, '하', 7, '일', 'W', 'N', ''],
    ['SP-VL-001', '솔레노이드 밸브 (LPG)', '밸브', 'RX 가스발생기', '25A, 220VAC, 방폭', '동양가스텍', 'EA', 2, 2, 410000, 24, '상', 3, '주', 'W', 'N', ''],
    ['SP-VL-002', '니들 밸브 (공기)', '밸브', 'RX 가스발생기', '15A SUS316', '하이락', 'EA', 2, 3, 85000, 0, '하', 5, '일', 'W', 'N', ''],
    ['SP-VL-003', '급수 볼밸브', '밸브', '세척 2호기', '20A 전동식', '삼진정밀', 'EA', 1, 1, 156000, 0, '하', 5, '일', 'W', 'N', ''],
    ['SP-FL-001', '소입유 필터 엘리먼트', '필터', '유조(소입유)', '25μm, Ø150×450L', '극동유화', 'EA', 4, 2, 64000, 1, '중', 7, '일', 'G', 'N', '월간 PM 사용, 재발주 진행'],
    ['SP-FL-002', 'RX 가스 촉매 (Ni)', '소모품', 'RX 가스발생기', '니켈 촉매 20kg/BOX', '동양가스텍', 'BOX', 1, 0, 1320000, 12, '상', 6, '주', 'Y', 'N', '다음달 교체 도래 — 긴급 구매 요청'],
    ['SP-CM-001', '세라믹 화이버 블랭킷', '소모품', '연속열처리로', '1260℃, 25t×610×7200', '케이씨씨', 'ROLL', 1, 2, 128000, 0, '하', 5, '일', 'W', 'N', ''],
    ['SP-CM-002', '방청유 원액', '소모품', '방청기', '수용성 20L', '극동유화', 'CAN', 4, 3, 94000, 0, '하', 5, '일', 'W', 'N', ''],
    ['SP-EL-001', '전자접촉기 (히터용)', '전기', '소입로', 'MC-65a 220V', 'LS산전', 'EA', 2, 2, 118000, 0, '중', 3, '일', 'W', 'N', ''],
    ['SP-EL-002', 'SSR 3상', '전기', '소려로', '3상 75A', '한영넉스', 'EA', 2, 3, 186000, 0, '중', 5, '일', 'W', 'N', ''],
    ['SP-EL-003', '온도조절기', '전기', '공통', 'UP550, 96×96', '요꼬가와', 'EA', 1, 1, 870000, 0, '중', 3, '주', 'W', 'N', ''],
    ['SP-GK-001', '도어 가스켓', '소모품', '소입로', '세라믹 로프 Ø25', '대한로공업', 'M', 5, 8, 18000, 12, '하', 2, '주', 'W', 'Y', '고객(대한로공업) 지급품']
  ];
  var partsDb = M.db('c1_parts', function () {
    return PARTS.map(function (a, i) {
      return { partNo: a[0], partName: a[1], category: a[2], equipment: a[3], specModel: a[4], maker: a[5], unit: a[6], minStock: a[7], priceEa: a[9], replaceCycle: a[10], sensitivity: a[11], leadTimeVal: a[12], leadTimeUnit: a[13], colorStatus: a[14], customerYn: a[15], remark: a[16], expectedAmt: a[9] * Math.max(a[7] * 2 - a[8], a[7]), createdAt: M.fmt(M.addDays(M.toDate('2024-03-04 09:00:00'), i)), useYn: 'Y' };
    });
  }, 'partNo');
  var histDb = M.db('c1_parthist', function () {
    var out = [], id = 0, t = M.toDate(TODAY);
    // 3일간 사용/입고 (비가동·PM 이력과 맞춤)
    var moves = [
      [0, '11:58', 'SP-TC-001', 'OUT', 1, '소입로', '3존 열전대 단선 교체 (AL-701)', '장현우'],
      [0, '15:20', 'SP-CM-002', 'OUT', 1, '방청기', '방청액 원액 보충', '이정호'],
      [0, '16:40', 'SP-TC-003', 'OUT', 6, '소입로', '3존 열전대 보상도선 재배선', '장현우'],
      [1, '03:40', 'SP-MB-002', 'OUT', 0, '연속열처리로', '', ''],
      [1, '11:20', 'SP-FL-001', 'OUT', 2, '유조(소입유)', '월간 PM — 필터 엘리먼트 교체', '최영훈'],
      [1, '14:05', 'SP-BR-001', 'IN', 4, '', '정기 구매 입고 (발주 PO-2611-014)', '한도윤'],
      [1, '16:45', 'SP-CM-002', 'OUT', 1, '방청기', '방청액 농도 이탈 조치 — 원액 보충', '이정호'],
      [2, '02:50', 'SP-VL-002', 'OUT', 1, 'RX 가스발생기', '공기 니들밸브 교체 (혼합비 재조정)', '정대현'],
      [2, '09:30', 'SP-TC-002', 'IN', 2, '', '정기 구매 입고 (발주 PO-2610-088)', '한도윤'],
      [2, '10:15', 'SP-EL-002', 'IN', 1, '', '예비품 보충 입고', '한도윤'],
      [2, '14:10', 'SP-SN-003', 'OUT', 1, '세척 2호기', '수위 저하 알람 — 레벨 스위치 교체', '장현우'],
      [2, '18:05', 'SP-MT-003', 'OUT', 0, '', '', '']
    ].filter(function (m) { return m[4] > 0; });
    var used = {};
    moves.forEach(function (m) { var k = m[2]; used[k] = used[k] || 0; used[k] += m[3] === 'OUT' ? m[4] : -m[4]; });
    // 기초재고 / 과거 입고
    PARTS.forEach(function (a, i) {
      var r = M.rng('c1-part-' + a[0]);
      var target = a[8] + (used[a[0]] || 0); // 3일 전 시점 재고
      var past = r.int(0, 2), oldOut = past ? r.int(1, Math.max(1, a[7])) : 0;
      var inQty = target + oldOut;
      if (inQty > 0) out.push({ id: ++id, partNo: a[0], type: 'IN', qty: inQty, equipment: '', workDesc: past ? '정기 구매 입고' : '기초재고 등록', userName: '한도윤', createdAt: M.fmt(M.addMinutes(M.addDays(t, -r.int(40, 75)), 9 * 60 + r.int(0, 300))) });
      if (oldOut > 0) out.push({ id: ++id, partNo: a[0], type: 'OUT', qty: oldOut, equipment: a[3], workDesc: r.pick(['정기 교체', '고장 수리 교체', '예방정비 교체']), userName: r.pick(['최영훈', '장현우']), createdAt: M.fmt(M.addMinutes(M.addDays(t, -r.int(5, 35)), 8 * 60 + r.int(0, 600))) });
    });
    moves.forEach(function (m) {
      var ts = M.toDate(M.fmt(M.addDays(t, m[0] - 2), 'YYYY-MM-DD') + ' ' + m[1] + ':00');
      if (ts > NOW) ts = M.addMinutes(NOW, -5 - id);
      out.push({ id: ++id, partNo: m[2], type: m[3], qty: m[4], equipment: m[5], workDesc: m[6], userName: m[7], createdAt: M.fmt(ts) });
    });
    return out;
  }, 'id');
  function partRows() {
    var hs = histDb.all();
    return partsDb.all().filter(function (p) { return p.useYn !== 'N'; }).map(function (p) {
      var tin = 0, tout = 0;
      hs.forEach(function (h) { if (h.partNo === p.partNo) { if (h.type === 'IN') tin += +h.qty; else tout += +h.qty; } });
      var cur = tin - tout;
      var o = {}; for (var k in p) o[k] = p[k];
      o.totalIn = tin; o.totalOut = tout; o.currentStock = cur;
      o.stockStatus = cur <= 0 ? '재고없음' : (cur < p.minStock ? '부족' : '정상');
      return o;
    });
  }
  M.get('/parts/list', function (req) {
    var p = P(req);
    return { success: true, data: partRows().filter(function (r) {
      return (!p.category || r.category === p.category) && (!p.colorStatus || r.colorStatus === p.colorStatus) && (has(r.partName, p.keyword) || has(r.partNo, p.keyword));
    }) };
  });
  M.get('/parts/category/list', function () {
    var o = {}; partsDb.all().forEach(function (p) { if (p.category) o[p.category] = 1; }); return Object.keys(o).sort();
  });
  M.get('/parts/equip/list', function () {
    var o = {}; partsDb.all().forEach(function (p) { if (p.equipment) o[p.equipment] = 1; }); return Object.keys(o).sort();
  });
  M.post('/parts/save', function (req) {
    var p = P(req), row = {};
    ['partNo', 'partName', 'category', 'equipment', 'unit', 'minStock', 'replaceCycle', 'maker', 'specModel', 'colorStatus', 'customerYn', 'sensitivity', 'leadTimeVal', 'leadTimeUnit', 'expectedAmt', 'remark'].forEach(function (k) { if (p[k] != null) row[k] = p[k]; });
    var ex = partsDb.find(row.partNo);
    if (!ex) { row.priceEa = 0; row.useYn = 'Y'; row.createdAt = nowStr(); partsDb.insert(row); } else partsDb.update(row.partNo, row);
    return { success: true };
  });
  M.post('/parts/delete', function (req) {
    var no = P(req).partNo;
    partsDb.remove(no);
    histDb.remove(histDb.all().filter(function (h) { return h.partNo === no; }).map(function (h) { return h.id; }));
    return { success: true };
  });
  M.post('/parts/color', function (req) { var p = P(req); partsDb.update(p.partNo, { colorStatus: p.colorStatus }); return { success: true }; });
  M.get('/parts/history/list', function (req) {
    var p = P(req), names = {};
    partsDb.all().forEach(function (x) { names[x.partNo] = x.partName; });
    var from = looseFrom(p.fromDt);
    var rows = histDb.all().filter(function (h) {
      return (!p.partNo || h.partNo === p.partNo) && (!p.type || h.type === p.type) && M.inRange(h.createdAt, from || '', p.toDt || '');
    }).map(function (h) { var o = {}; for (var k in h) o[k] = h[k]; o.partName = names[h.partNo] || ''; return o; })
      .sort(function (a, b) { return a.createdAt < b.createdAt ? 1 : -1; });
    return { success: true, data: rows };
  });
  M.post('/parts/history/save', function (req) {
    var p = P(req);
    histDb.insert({ partNo: p.partNo, type: p.type, qty: parseInt(p.qty, 10) || 0, equipment: s(p.equipment), workDesc: s(p.workDesc), userName: s(p.userName) || '관리자', createdAt: nowStr() });
    return { success: true };
  });
  M.post('/parts/history/delete', function (req) { histDb.remove(P(req).id); return { success: true }; });
})();
