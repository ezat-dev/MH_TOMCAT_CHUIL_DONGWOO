/* routes/c3-prod-cond.js — 생산관리(작업지시/설비효율/제품별작업/수리이력/작업일보/LOT보고서) + 조건관리(열전대/온도조절계/소입유/일상점검/표준서)
 * 모든 LOT 수치는 MOCK.D.lots() 기준. 파일 보기/다운로드는 브라우저에서 만든 PDF(한글 CID 폰트)로 대체한다.
 */
(function () {
  var M = window.MOCK, D = M.D;
  if (!M || !D) return;

  /* ═════════════════════════ 공통 유틸 ═════════════════════════ */
  function ymd(d) { return M.fmt(d, 'YYYY-MM-DD'); }
  function today() { return ymd(new Date()); }
  function num(v) { return Math.round(v).toLocaleString('en-US'); }
  function prodIdx(code) { for (var i = 0; i < D.products.length; i++) if (D.products[i].prod_code === code) return i; return 0; }
  function prodByPart(no) { for (var i = 0; i < D.products.length; i++) if (D.products[i].part_no === no) return D.products[i]; return null; }
  function worker(name) { for (var i = 0; i < D.workers.length; i++) if (D.workers[i].user_name === name) return D.workers[i]; return D.workers[0]; }

  // 품목별 장입 기준 (kg/통), 규격
  var CHARGE = [60, 55, 50, 45, 40, 55, 40, 45, 50, 40];
  var SPEC = ['Ø28×412L', 'Ø96×64H', 'Ø26×740L', 'M2.5 Z38 Ø102', 'M14×1.5 Ø22', 'Ø42×88L', 'M16×120L', 'M14×1.5 Ø30', 'M2 Z14 Ø36×185L', 'Tr24×5 Ø40'];
  function recipe(p) {
    var i = prodIdx(p.prod_code);
    return {
      recipe_id: 'R-' + (101 + i), recipe_code: 'RC' + p.prod_code.substring(1),
      cust_name: D.customer(p.cust_code).cust_name, item_no: p.part_no, item_name: p.prod_name,
      q1_zone: p.q_temp - 10, q2_zone: p.q_temp, q3_zone: p.q_temp, q4_zone: p.q_temp, q5_zone: p.q_temp - 10,
      q_speed: M.round(12 + 600 / p.cycle_min, 1),
      t1_zone: p.t_temp - 10, t2_zone: p.t_temp, t3_zone: p.t_temp, t4_zone: p.t_temp, t5_zone: p.t_temp - 5,
      t_speed: M.round(12 + 560 / p.cycle_min, 1),
      cp: p.material.indexOf('SCM420') === 0 ? 0.80 : 0.45,
      charge_weight: CHARGE[i], quench_high: 'HRC ' + (p.hrc_min + 3) + '↑',
      ea_per_cnt: Math.round(CHARGE[i] / p.unit_wt), spec: SPEC[i]
    };
  }

  /* ─── 작업지시 (LOT) 행: 기본 LOT + 재처리 1건 + 사용자 등록/수정/삭제 ─── */
  var woAdd = M.db('c3_wo_add', function () { return []; }, 'w_ci_lot');
  var woDel = M.db('c3_wo_del', function () { return []; }, 'w_ci_lot');

  function lotRow(l) {
    var p = D.product(l.prod_code), rc = recipe(p);
    var r = M.rng('c3wo' + l.lot_no);
    var plan = Math.max(2, Math.ceil(l.weight / rc.charge_weight));
    var st = M.toDate(l.start_time), en = M.toDate(l.plan_end_time), now = new Date();
    var dur = (en - st) / 60000;
    var inEnd = M.addMinutes(st, Math.round(dur * 0.55));
    var row = {
      idx: l.idx, w_date: l.work_date, w_ci_lot: l.lot_no, w_old_lot: '',
      erp_jack_no: 'JK' + l.lot_no.substring(2, 8) + '-' + M.pad(40 + l.idx, 4),
      cust_name: l.cust_name, item_no: l.part_no, item_name: l.prod_name,
      w_plan_cnt: plan, play_cnt: 0, charge_weight: rc.charge_weight,
      w_sdatetime: '', d370: '', x111: '', l20: '',
      img_url_1: p.part_no + '_1.png', img_url_2: p.part_no + '_2.png',
      w_rcode: rc.recipe_code, spec: rc.spec, weight: Math.round(p.unit_wt * 1000), material: rc.ea_per_cnt,
      qty: l.qty, kg: l.weight, status: l.status, worker: l.worker, lot: l
    };
    if (l.status !== '대기') {
      row.w_sdatetime = M.fmt(M.addMinutes(st, -r.int(4, 11)));
      row.d370 = l.start_time;
      if (inEnd <= now) row.x111 = M.fmt(inEnd);
      row.l20 = l.end_time || '';
      row.play_cnt = l.status === '완료' || inEnd <= now ? plan : Math.max(1, Math.floor(plan * (now - st) / (inEnd - st)));
    }
    return row;
  }
  function baseOrders() {
    var ls = D.lots(), out = ls.map(lotRow);
    // 재처리 지시 1건 (그제 LOT 중 경도 편차 고객 클레임 → 오늘 재소려 대기)
    var src = null;
    for (var i = 0; i < ls.length; i++) if (ls[i].work_date === M.days()[0] && ls[i].status === '완료' && i > 3) { src = ls[i]; break; }
    if (src) {
      var re = lotRow(src);
      re.idx = 900; re.w_old_lot = src.lot_no; re.w_ci_lot = 'RI' + src.lot_no.substring(2);
      re.w_date = today(); re.erp_jack_no = 'JK' + M.fmt(new Date(), 'YYYYMMDD').substring(2) + '-R01';
      re.w_plan_cnt = Math.max(2, Math.ceil(re.w_plan_cnt / 3)); re.play_cnt = 0;
      re.w_sdatetime = re.d370 = re.x111 = re.l20 = ''; re.status = '대기';
      out.push(re);
    }
    return out;
  }
  function allOrders() {
    var del = woDel.all().map(function (x) { return x.w_ci_lot; });
    var adds = woAdd.all(), map = {};
    adds.forEach(function (a) { map[a.w_ci_lot] = a; });
    var out = baseOrders().map(function (o) {
      var a = map[o.w_ci_lot];
      if (a) { delete map[o.w_ci_lot]; var c = {}; for (var k in o) c[k] = o[k]; for (k in a) if (a[k] !== '' && a[k] != null) c[k] = a[k]; return c; }
      return o;
    });
    for (var k in map) out.push(map[k]);
    return out.filter(function (o) { return del.indexOf(o.w_ci_lot) < 0; });
  }
  function ordersIn(from, to) {
    return allOrders().filter(function (o) { return M.inRange(o.w_date + ' 12:00:00', from || null, to || null); })
      .sort(function (a, b) { return (b.w_date + (b.d370 || '9')).localeCompare(a.w_date + (a.d370 || '9')); });
  }
  function strip(o) { var c = {}; for (var k in o) if (k !== 'lot') c[k] = o[k]; return c; }

  /* ═════════════════════════ PDF 생성기 (한글: HYGoThic-Medium / UniKS-UCS2-H, 비임베드) ═════════════════════════ */
  function hex4(s) { var h = ''; for (var i = 0; i < s.length; i++) { var c = s.charCodeAt(i); if (c > 0xffff) c = 0x3f; h += ('000' + c.toString(16)).slice(-4); } return h; }
  function tw(s, size) { var w = 0; for (var i = 0; i < s.length; i++) w += s.charCodeAt(i) < 128 ? 0.5 : 1; return w * size; }
  function Page() { this.ops = []; }
  var H = 842;
  Page.prototype.text = function (x, y, s, size, align, bold) {
    s = String(s == null ? '' : s); size = size || 9;
    if (align === 'center') x -= tw(s, size) / 2; else if (align === 'right') x -= tw(s, size);
    this.ops.push('BT /F1 ' + size + ' Tf ' + (bold ? '2 Tr 0.25 w ' : '0 Tr ') + x.toFixed(1) + ' ' + (H - y).toFixed(1) + ' Td <' + hex4(s) + '> Tj ET');
    return this;
  };
  Page.prototype.line = function (x1, y1, x2, y2, w) { this.ops.push((w || 0.6) + ' w ' + x1 + ' ' + (H - y1) + ' m ' + x2 + ' ' + (H - y2) + ' l S'); return this; };
  Page.prototype.rect = function (x, y, w, h, fill) {
    if (fill) this.ops.push('q ' + fill + ' rg ' + x + ' ' + (H - y - h) + ' ' + w + ' ' + h + ' re f Q');
    this.ops.push('0.6 w ' + x + ' ' + (H - y - h) + ' ' + w + ' ' + h + ' re S'); return this;
  };
  // 표: cols=[{t,w,a}], rows=[[..]], 시작 x,y, 행높이
  Page.prototype.table = function (x, y, cols, rows, rh, size) {
    rh = rh || 18; size = size || 8.5;
    var self = this, cx = x, totalW = 0;
    cols.forEach(function (c) { totalW += c.w; });
    self.rect(x, y, totalW, rh, '0.88 0.91 0.96');
    cols.forEach(function (c) { self.rect(cx, y, c.w, rh); self.text(cx + c.w / 2, y + rh / 2 + size / 2 - 1, c.t, size, 'center', true); cx += c.w; });
    rows.forEach(function (r, ri) {
      var yy = y + rh * (ri + 1); cx = x;
      cols.forEach(function (c, ci) {
        self.rect(cx, yy, c.w, rh);
        var v = r[ci] == null ? '' : String(r[ci]);
        var a = c.a || 'center';
        self.text(a === 'left' ? cx + 4 : a === 'right' ? cx + c.w - 4 : cx + c.w / 2, yy + rh / 2 + size / 2 - 1, v, size, a);
        cx += c.w;
      });
    });
    return y + rh * (rows.length + 1);
  };
  // 결재란
  Page.prototype.sign = function (x, y, names) {
    var self = this, labels = ['작성', '검토', '승인'];
    labels.forEach(function (l, i) {
      self.rect(x + i * 52, y, 52, 16, '0.93 0.93 0.93'); self.text(x + i * 52 + 26, y + 11.5, l, 8.5, 'center');
      self.rect(x + i * 52, y + 16, 52, 34); if (names && names[i]) self.text(x + i * 52 + 26, y + 37, names[i], 9, 'center');
    });
  };
  Page.prototype.header = function (title, sub) {
    this.rect(30, 30, 535, 46, '0.12 0.23 0.42');
    this.ops.push('q 1 1 1 rg 1 1 1 RG'); this.text(46, 60, title, 18, 'left', true); this.ops.push('Q');
    this.ops.push('q 1 1 1 rg 1 1 1 RG'); this.text(549, 50, D.company + ' 열처리공장', 9, 'right'); if (sub) this.text(549, 66, sub, 8.5, 'right'); this.ops.push('Q');
    return this;
  };
  Page.prototype.footer = function (p, n) { this.line(30, 812, 565, 812, 0.4); this.text(30, 824, D.company + ' MES  |  출력일시 ' + M.fmt(new Date(), 'YYYY-MM-DD HH:mm'), 7.5); this.text(565, 824, p + ' / ' + n, 7.5, 'right'); };

  function buildPdf(pages) {
    var objs = [];
    objs[1] = '<< /Type /Catalog /Pages 2 0 R >>';
    objs[3] = '<< /Type /Font /Subtype /Type0 /BaseFont /HYGoThic-Medium /Encoding /UniKS-UCS2-H /DescendantFonts [4 0 R] >>';
    objs[4] = '<< /Type /Font /Subtype /CIDFontType0 /BaseFont /HYGoThic-Medium /CIDSystemInfo << /Registry (Adobe) /Ordering (Korea1) /Supplement 1 >> /FontDescriptor 5 0 R /DW 1000 /W [1 95 500] >>';
    objs[5] = '<< /Type /FontDescriptor /FontName /HYGoThic-Medium /Flags 6 /FontBBox [-6 -145 1003 880] /ItalicAngle 0 /Ascent 880 /Descent -120 /CapHeight 720 /StemV 93 >>';
    var kids = [];
    pages.forEach(function (pg, i) {
      pg.footer(i + 1, pages.length);
      var po = 6 + i * 2, co = po + 1, stream = pg.ops.join('\n');
      kids.push(po + ' 0 R');
      objs[po] = '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R >> >> /Contents ' + co + ' 0 R >>';
      objs[co] = '<< /Length ' + stream.length + ' >>\nstream\n' + stream + '\nendstream';
    });
    objs[2] = '<< /Type /Pages /Kids [' + kids.join(' ') + '] /Count ' + pages.length + ' >>';
    var out = '%PDF-1.4\n', offs = [];
    for (var n = 1; n < objs.length; n++) { offs[n] = out.length; out += n + ' 0 obj\n' + objs[n] + '\nendobj\n'; }
    var x = out.length;
    out += 'xref\n0 ' + objs.length + '\n0000000000 65535 f \n';
    for (n = 1; n < objs.length; n++) out += ('000000000' + offs[n]).slice(-10) + ' 00000 n \n';
    out += 'trailer\n<< /Size ' + objs.length + ' /Root 1 0 R >>\nstartxref\n' + x + '\n%%EOF';
    return out;
  }
  function pdfRes(pages) { return M.res(200, buildPdf(pages), 'application/pdf'); }
  function pdfUrl(pages) { return URL.createObjectURL(new Blob([buildPdf(pages)], { type: 'application/pdf' })); }
  M.C3PDF = { Page: Page, build: buildPdf };

  /* ─── 문서 내용 ─── */
  function lotDetail(o) {
    var l = o.lot, p = D.product(l ? l.prod_code : (prodByPart(o.item_no) || D.products[0]).prod_code), rc = recipe(p);
    var r = M.rng('c3lotdet' + o.w_ci_lot);
    var zones = [];
    ['q1', 'q2', 'q3', 'q4', 'q5'].forEach(function (z, i) { var sv = rc[z + '_zone'], av = M.round(sv + r.normal(0, 0.8), 1); zones.push(['소입로 ' + (i + 1) + '존', sv, av, M.round(av - r.float(1.2, 3.5), 1), M.round(av + r.float(1.0, 3.2), 1)]); });
    ['t1', 't2', 't3', 't4', 't5'].forEach(function (z, i) { var sv = rc[z + '_zone'], av = M.round(sv + r.normal(0, 0.9), 1); zones.push(['소려로 ' + (i + 1) + '존', sv, av, M.round(av - r.float(1.5, 4), 1), M.round(av + r.float(1.2, 3.8), 1)]); });
    var hard = [], mid = l && l.hardness != null ? l.hardness : (p.hrc_min + p.hrc_max) / 2;
    for (var i = 0; i < 5; i++) hard.push(M.round(mid + r.normal(0, (p.hrc_max - p.hrc_min) / 10), 1));
    return { p: p, rc: rc, zones: zones, hard: hard, oil: M.round(r.normal(68, 2), 1), cpv: M.round(rc.cp + r.normal(0, 0.01), 2) };
  }
  function lotPages(o) {
    var d = lotDetail(o), pg = new Page(), l = o.lot || {};
    pg.header('LOT 열처리 성적서', 'LOT No. ' + o.w_ci_lot);
    var y = pg.table(30, 92, [{ t: '항목', w: 90 }, { t: '내용', w: 177, a: 'left' }, { t: '항목', w: 90 }, { t: '내용', w: 178, a: 'left' }], [
      ['LOT No.', o.w_ci_lot, 'ERP 작지번호', o.erp_jack_no],
      ['거래처', o.cust_name, '작업일자', o.w_date],
      ['품번', o.item_no, '품명', o.item_name],
      ['재질', d.p.material, '열처리 패턴', d.p.pattern],
      ['수량 / 중량', num(o.qty || 0) + ' EA / ' + (o.kg || '-') + ' kg', '계획 / 투입 통수', o.w_plan_cnt + ' / ' + (o.play_cnt || 0) + ' 통'],
      ['투입시간', o.d370 || '-', '작업완료', o.l20 || '-'],
      ['재처리 원LOT', o.w_old_lot || '-', '작업자', l.worker || '-']
    ], 20, 9);
    pg.text(30, y + 22, '■ 구역별 온도 기록 (℃)', 10.5, 'left', true);
    y = pg.table(30, y + 30, [{ t: '구역', w: 135 }, { t: '설정(SV)', w: 100 }, { t: '평균(PV)', w: 100 }, { t: '최저', w: 100 }, { t: '최고', w: 100 }], d.zones, 18, 8.5);
    pg.text(30, y + 18, '소입유 온도 평균 ' + d.oil + '℃   ·   CP ' + d.cpv + '%   ·   소입 속도 ' + d.rc.q_speed + 'Hz / 소려 속도 ' + d.rc.t_speed + 'Hz', 9);
    pg.text(30, y + 44, '■ 경도 검사 (HRC, 규격 ' + d.p.hrc_min + ' ~ ' + d.p.hrc_max + ')', 10.5, 'left', true);
    var avg = M.round(d.hard.reduce(function (a, b) { return a + b; }, 0) / 5, 1);
    var ok = o.l20 ? (avg >= d.p.hrc_min && avg <= d.p.hrc_max ? '합격' : '불합격') : '검사대기';
    y = pg.table(30, y + 52, [{ t: '#1', w: 76 }, { t: '#2', w: 76 }, { t: '#3', w: 76 }, { t: '#4', w: 76 }, { t: '#5', w: 76 }, { t: '평균', w: 76 }, { t: '판정', w: 79 }],
      [o.l20 ? d.hard.concat([avg, ok]) : ['-', '-', '-', '-', '-', '-', ok]], 20, 9);
    pg.text(30, y + 26, '비고: ' + (o.w_old_lot ? '고객 클레임(경도 편차) 재소려 처리 LOT' : '외관 이상 없음, 변형량 규격 이내'), 9);
    pg.sign(409, y + 50, [l.worker || '김민수', '박성진', '관리자']);
    return [pg];
  }
  function dayPages(day) {
    var os = allOrders().filter(function (o) { return o.w_date === day && o.d370; }).sort(function (a, b) { return a.d370.localeCompare(b.d370); });
    var pg = new Page(); pg.header('열처리 작업일보', '작업일 ' + day);
    var sum = function (arr, f) { return arr.reduce(function (a, o) { return a + (+o[f] || 0); }, 0); };
    var dayS = os.filter(function (o) { var h = +o.d370.substr(11, 2); return h >= 8 && h < 20; }), night = os.filter(function (o) { return dayS.indexOf(o) < 0; });
    var r = M.rng('c3day' + day);
    var stopMin = r.int(25, 70), wD = D.shiftWorker(day, 10), wN = D.shiftWorker(day, 22);
    if (wN === wD) wN = wD === '정대현' ? '이정호' : '정대현';
    var y = pg.table(30, 92, [{ t: '구분', w: 85 }, { t: '근무자', w: 90 }, { t: 'LOT 수', w: 70 }, { t: '투입 통수', w: 80 }, { t: '수량(EA)', w: 100 }, { t: '중량(kg)', w: 110 }], [
      ['주간(08~20)', wD, dayS.length, sum(dayS, 'play_cnt'), num(sum(dayS, 'qty')), num(sum(dayS, 'kg'))],
      ['야간(20~08)', wN, night.length, sum(night, 'play_cnt'), num(sum(night, 'qty')), num(sum(night, 'kg'))],
      ['합계', '', os.length, sum(os, 'play_cnt'), num(sum(os, 'qty')), num(sum(os, 'kg'))]
    ], 19, 9);
    pg.text(30, y + 22, '■ LOT별 작업 내역', 10.5, 'left', true);
    var rows = os.map(function (o, i) { return [i + 1, o.w_ci_lot, o.item_name, o.cust_name, num(o.qty), o.kg, o.d370.substr(11, 5), o.l20 ? o.l20.substr(11, 5) : '진행중', o.lot && o.lot.hardness != null ? o.lot.hardness : '-', o.lot && o.lot.result ? o.lot.result : '-']; });
    y = pg.table(30, y + 30, [{ t: 'No', w: 26 }, { t: 'LOT', w: 82 }, { t: '품명', w: 92, a: 'left' }, { t: '거래처', w: 62 }, { t: '수량', w: 44, a: 'right' }, { t: '중량', w: 50, a: 'right' }, { t: '투입', w: 42 }, { t: '완료', w: 42 }, { t: 'HRC', w: 40 }, { t: '판정', w: 55 }], rows, 17, 8);
    pg.text(30, y + 22, '■ 비가동 / 특이사항', 10.5, 'left', true);
    y = pg.table(30, y + 30, [{ t: '시간', w: 90 }, { t: '구분', w: 70 }, { t: '내용', w: 300, a: 'left' }, { t: '시간(분)', w: 75 }], [
      [r.pick(['10:20~10:35', '14:05~14:25', '02:40~03:05']), '설비점검', r.pick(['메쉬벨트 장력 점검 및 사행 조정', '소입유 교반기 이상음 점검', 'RX가스 유량계 점검']), Math.round(stopMin * 0.6)],
      [r.pick(['16:30~16:45', '05:10~05:25']), '품종교체', '레시피 변경에 따른 소려로 온도 안정화 대기', stopMin - Math.round(stopMin * 0.6)]
    ], 18, 8.5);
    pg.text(30, y + 20, '가동률 ' + M.round(100 - stopMin / 14.4, 1) + '%  (비가동 ' + stopMin + '분 / 1,440분)   ·   전 LOT 경도 규격 이내, 외관 불량 없음', 9);
    pg.sign(409, Math.max(y + 40, 700), [D.shiftWorker(day, 10), '김민수', '관리자']);
    return [pg];
  }

  /* ═════════════════════════ 공통: 권한 (다른 라우트에 없을 때만) ═════════════════════════ */
  var hit = M.resolve('POST', M.ctx + '/user/info');
  if (!hit || !hit.route) {
    M.post('/user/info', function () {
      var perm = {};
      'abcdefghij'.split('').forEach(function (c) { for (var i = 1; i <= 20; i++) perm[c + M.pad(i)] = 'Y'; });
      return { loginUser: { user_code: 1, user_id: 'ez', user_name: '관리자' }, loginUserPage: perm };
    });
  }

  /* ═════════════════════════ 작업지시관리 (heatTreatment) ═════════════════════════ */
  M.post('/productionManagement/heatTreatment/list', function (req) {
    var p = req.params, from = p.w_date || today(), to = p.w_date_end || from;
    return { data: ordersIn(from, to).map(strip) };
  });
  M.post('/productionManagement/heatTreatment/pcode/list', function (req) {
    var p = req.params;
    var rows = D.products.map(recipe).filter(function (r) {
      return (!p.w_cname || r.cust_name.indexOf(p.w_cname) >= 0) && (!p.w_pnum || r.item_no.indexOf(p.w_pnum) >= 0) && (!p.w_pname || r.item_name.indexOf(p.w_pname) >= 0);
    });
    return { data: rows };
  });
  M.post('/productionManagement/heatTreatment/save', function (req) {
    var p = req.params, lot = p.w_ci_lot;
    var pr = prodByPart(p.w_pnum) || D.products[0], rc = recipe(pr), c = D.customer(pr.cust_code);
    var row = { w_date: p.w_date || today(), erp_jack_no: p.erp_jack_no || '', item_no: p.w_pnum || pr.part_no, item_name: p.w_pname || pr.prod_name, w_plan_cnt: +p.w_plan_cnt || 0, w_rcode: p.w_rcode || rc.recipe_code, w_old_lot: p.w_old_lot || '' };
    var exists = allOrders().some(function (o) { return o.w_ci_lot === lot; });
    if (!lot || !exists) {
      if (!lot) {
        var dk = (row.w_date || today()).replace(/-/g, '').substring(2);
        lot = 'CH' + dk + '-' + (901 + woAdd.all().length);
      }
      row.w_ci_lot = lot; row.idx = 1000 + woAdd.all().length; row.cust_name = c.cust_name; row.charge_weight = rc.charge_weight;
      row.w_sdatetime = row.d370 = row.x111 = row.l20 = ''; row.play_cnt = 0; row.status = '대기'; row.spec = rc.spec; row.weight = Math.round(pr.unit_wt * 1000); row.material = rc.ea_per_cnt;
      row.img_url_1 = pr.part_no + '_1.png'; row.img_url_2 = pr.part_no + '_2.png'; row.qty = 0; row.kg = 0;
    } else row.w_ci_lot = lot;
    woAdd.upsert(row);
    return { result: 'success', status: 'success' };
  });
  M.post('/productionManagement/heatTreatment/delete', function (req) {
    var lot = req.params.w_lot;
    woAdd.remove(lot);
    if (lot) woDel.upsert({ w_ci_lot: lot });
    return { result: 'success' };
  });
  M.post('/productionManagement/heatTreatment/workHeatListPrint', function (req) {
    var sel = Array.isArray(req.body) ? req.body : [];
    var all = allOrders(), pages = [];
    sel.forEach(function (s) {
      var o = all.filter(function (x) { return x.w_ci_lot === s.w_ci_lot; })[0] || s;
      var d = lotDetail(o), pg = new Page();
      pg.header('열처리 작업지시서', 'LOT No. ' + o.w_ci_lot);
      var y = pg.table(30, 92, [{ t: '항목', w: 90 }, { t: '내용', w: 177, a: 'left' }, { t: '항목', w: 90 }, { t: '내용', w: 178, a: 'left' }], [
        ['작업일자', o.w_date, 'ERP 작지번호', o.erp_jack_no], ['거래처', o.cust_name, '재질', d.p.material],
        ['품번', o.item_no, '품명', o.item_name], ['계획 통수', o.w_plan_cnt + ' 통', '기준 장입량', o.charge_weight + ' kg/통'],
        ['레시피', d.rc.recipe_id + ' (' + d.p.pattern + ')', '요구 경도', 'HRC ' + d.p.hrc_min + ' ~ ' + d.p.hrc_max]
      ], 20, 9);
      pg.text(30, y + 22, '■ 열처리 조건', 10.5, 'left', true);
      pg.table(30, y + 30, [{ t: '구분', w: 75 }, { t: '1존', w: 65 }, { t: '2존', w: 65 }, { t: '3존', w: 65 }, { t: '4존', w: 65 }, { t: '5존', w: 65 }, { t: '속도(Hz)', w: 65 }, { t: 'CP(%)', w: 70 }], [
        ['소입(℃)', d.rc.q1_zone, d.rc.q2_zone, d.rc.q3_zone, d.rc.q4_zone, d.rc.q5_zone, d.rc.q_speed, d.rc.cp],
        ['소려(℃)', d.rc.t1_zone, d.rc.t2_zone, d.rc.t3_zone, d.rc.t4_zone, d.rc.t5_zone, d.rc.t_speed, '-']
      ], 20, 9);
      pg.text(30, y + 120, '※ 장입 시 제품 간 간격 유지, 소입유 온도 60~80℃ 확인 후 투입. 초품 경도 확인 후 양산 진행.', 9);
      pg.sign(409, y + 150, ['김민수', '박성진', '관리자']);
      pages.push(pg);
    });
    if (!pages.length) { var e = new Page(); e.header('열처리 작업지시서'); pages.push(e); }
    return pdfRes(pages);
  });

  /* ═════════════════════════ 제품별작업관리 (productWork) ═════════════════════════ */
  M.post('/productionManagement/product_report/list', function (req) {
    var p = req.params;
    var rows = ordersIn(p.s_sdate, p.s_edate).filter(function (o) {
      return (!p.item_name || o.item_name.indexOf(p.item_name) >= 0) && (!p.item_no || o.item_no.indexOf(p.item_no) >= 0);
    }).map(function (o, i) { var c = strip(o); c.idx = i + 1; return c; });
    return { data: rows };
  });

  /* ═════════════════════════ LOT보고서 (lot_report) ═════════════════════════ */
  M.post('/productionManagement/lot_report/list', function (req) {
    var p = req.params;
    return { data: ordersIn(p.s_sdate || today(), p.s_edate || p.s_sdate || today()).map(function (o, i) { var c = strip(o); c.idx = i + 1; return c; }) };
  });
  M.post('/productionManagement/lot_report/lotPrint', function (req) {
    var lot = req.params.w_ci_lot;
    var o = allOrders().filter(function (x) { return x.w_ci_lot === lot; })[0] || allOrders()[0];
    return pdfRes(lotPages(o));
  });

  /* ═════════════════════════ 작업일보 (workReport) ═════════════════════════ */
  M.post('/productionManagement/work_report/list', function (req) {
    var ym = (req.params.s_sdate || today()).substring(0, 7);
    var curYm = today().substring(0, 7);
    var days = M.days().filter(function (d) { return d.substring(0, 7) === ym || ym === curYm; }).reverse();
    var all = allOrders();
    return {
      data: days.map(function (d, i) {
        var os = all.filter(function (o) { return o.w_date === d && o.d370; }).sort(function (a, b) { return a.d370.localeCompare(b.d370); });
        // 제품명·거래처: 해당 일자 LOT 의 고유값을 LOT 많은 순으로 (DB 의 STRING_AGG 결과와 같은 쉼표 구분 문자열)
        function agg(k) {
          var c = {};
          os.forEach(function (o) { if (o[k]) c[o[k]] = (c[o[k]] || 0) + 1; });
          return Object.keys(c).sort(function (a, b) { return c[b] - c[a]; }).join(',');
        }
        return { idx: i + 1, w_date: d, work_count: os.length, min_w_ci_lot: os.length ? os[0].w_ci_lot : '', max_w_ci_lot: os.length ? os[os.length - 1].w_ci_lot : '',
          item_names: agg('item_name'), cust_names: agg('cust_name') };
      })
    };
  });
  M.post('/productionManagement/work_report/dayPrint', function (req) {
    return pdfRes(dayPages(req.params.w_date || today()));
  });

  /* ═════════════════════════ 수리이력관리 (repairHistory) ═════════════════════════ */
  var VENDOR = {
    '대한로공업': ['송기철', '055-264-1180'], '세진테크': ['강동원', '051-972-3345'], '동양가스텍': ['문상훈', '052-227-8812'],
    '한림기계': ['배정민', '055-345-6021'], '한국계측제어': ['권오석', '031-8041-2270'], '자체수리': ['최영훈', '010-3346-9071']
  };
  var REPAIRS = [
    ['열처리', '소입로', '대한로공업', '[돌발고장] 소입로 3존 히터 단선', '3존 U-type 히터', [1500000, 2200000], '3존 승온 지연 알람(AL-102) 발생. 히터 저항 측정 결과 1본 단선 확인 → 히터 교체 후 승온 테스트 정상.', '예비 히터 1본 재고 확보 필요'],
    ['열처리', '연속열처리로', '대한로공업', '[계획수리] 메쉬벨트 교체', '메쉬벨트 SUS310S 22m', [11800000, 13200000], '메쉬벨트 신율 3% 초과로 계획 교체. 구동롤 정렬 및 장력 조정, 공회전 4시간 시운전 후 생산 재개.', '하계 휴무기간 시행'],
    ['열처리', '유조(소입유)', '대한로공업', '[정기수리] 소입유 교반기 베어링 교체', '교반기 #2 베어링/오일씰', [680000, 950000], '교반기 #2 진동치 상승(4.8mm/s). 베어링 6312ZZ 및 오일씰 교체 후 진동 1.6mm/s 확인.', ''],
    ['열처리', '연속열처리로', '자체수리', '[돌발고장] 메쉬벨트 구동모터 과전류', '구동모터 감속기', [320000, 520000], 'AL-302 발생으로 라인 정지. 감속기 윤활유 열화 및 체인 장력 과다 확인 → 윤활유 교환, 장력 재조정.', '정지시간 45분'],
    ['공용설비', 'RX 가스발생기', '동양가스텍', '[정기수리] RX가스발생기 니켈촉매 교체', '레토르트 촉매', [4200000, 5100000], '노점 상승(+2℃ 이상) 경향으로 촉매 교체 및 레토르트 번아웃 실시. 교체 후 노점 -2℃ 안정.', '연 1회 정기'],
    ['세척', '세척 1호기', '세진테크', '[돌발고장] 세척 1호기 펌프 메커니컬 씰 누수', '순환펌프 메커니컬 씰', [450000, 620000], '세척액 누수 및 수위 저하 알람(AL-502). 메커니컬 씰 교체, 누수 없음 확인.', ''],
    ['열처리', '소려로', '대한로공업', '[계획수리] 소려로 순환팬 베어링/V벨트 교체', '순환팬 #1, #3', [1100000, 1450000], '순환팬 이상음 발생 전 예방 교체. 베어링 4EA, V벨트 6EA 교체 후 존간 온도편차 ±3℃ 이내 확인.', ''],
    ['열처리', '소입로', '자체수리', '[돌발고장] 소입로 2존 열전대 단선', 'K-type 열전대 Ø8×1200', [180000, 260000], '열전대 단선 알람(AL-701). 예비 열전대 교체 후 온도조절계 지시값 비교 확인(±1℃).', '열전대 교체이력 등록 완료'],
    ['방청', '방청기', '한림기계', '[정기수리] 방청기 노즐 청소 및 필터 교체', '분사노즐 12EA/필터', [240000, 380000], '방청액 분사 불균일 개선을 위해 노즐 세척 및 필터 교체. 농도 4.2% 재조정.', ''],
    ['열처리', '연속열처리로', '대한로공업', '[돌발고장] 노내압력 이상 - 프레임커튼 버너 노즐 막힘', '입구 프레임커튼 버너', [380000, 560000], '노내 압력 이상 알람(AL-402). 버너 노즐 카본 퇴적 제거 및 점화플러그 교체.', ''],
    ['세척', '세척 2호기', '세진테크', '[정기수리] 세척 2호기 히터 스케일 제거', '세척조 히터 3EA', [520000, 760000], '액온 승온 지연 → 히터 스케일 제거 및 탱크 청소, 세척액 전량 교체.', ''],
    ['열처리', '소입로', '대한로공업', '[계획수리] 소입로 내화물 부분 보수', '입구측 천정 내화물', [6800000, 8200000], '입구측 천정 내화물 균열 부위 캐스타블 보수. 건조 승온 스케줄 준수 후 생산 재개.', '보수 후 TUS 재측정 예정'],
    ['열처리', '유조(소입유)', '대한로공업', '[돌발고장] 소입유 냉각기 튜브 누수', '판형 열교환기 가스켓', [1300000, 1750000], '소입유 수분 증가(0.08%) 확인 → 열교환기 가스켓 누수. 가스켓 교체 및 소입유 탈수 처리.', '소입유 성상분석 추가 의뢰'],
    ['열처리', '연속열처리로', '한국계측제어', '[정기수리] 온도조절계 점검 및 보정', '온도조절계 10CH', [900000, 1100000], '소입·소려 전 존 온도조절계 교정 실시. 보정값 온도조절계 보정현황에 반영.', '성적서 첨부']
  ];
  function genRepairs(year) {
    var r = M.rng('c3rep' + year), out = [], now = new Date(), cy = now.getFullYear();
    var endDoy = year === cy ? Math.floor((now - new Date(cy, 0, 1)) / 86400000) - 4 : 360;
    var n = year === cy ? Math.max(4, Math.round(endDoy / 22)) : 16;
    for (var i = 0; i < n; i++) {
      var t = REPAIRS[r.int(0, REPAIRS.length - 1)];
      var reqD = new Date(year, 0, 1 + Math.floor(5 + (endDoy - 5) * (i + r.float(0.1, 0.9)) / n));
      out.push(mkRepair(t, reqD, r));
    }
    return out;
  }
  function mkRepair(t, reqD, r, startD) {
    var sd = startD || M.addDays(reqD, t[3].indexOf('돌발') >= 0 ? 0 : r.int(1, 6));
    var sh = t[3].indexOf('돌발') >= 0 ? r.int(1, 22) : r.pick([9, 10, 13, 14]);
    var st = new Date(sd.getFullYear(), sd.getMonth(), sd.getDate(), sh, r.pick([0, 10, 20, 30, 40, 50]));
    var hrs = t[3].indexOf('계획') >= 0 ? r.int(8, 30) : r.int(1, 6);
    var en = M.addMinutes(st, hrs * 60 + r.pick([0, 15, 30, 45]));
    var acct = M.addDays(en, r.int(5, 20));
    var v = VENDOR[t[2]];
    return {
      box_1: t[0], box_2: t[1], box_3: t[2], box_4: ymd(reqD), box_5: r.pick(['김민수', '이정호', '정대현', '최영훈', '장현우']),
      box_6: ymd(st), box_7: M.fmt(st, 'HH:mm'), box_8: ymd(en), box_9: M.fmt(en, 'HH:mm'), box_10: acct <= new Date() ? ymd(acct) : '',
      box_11: t[3], box_12: t[4], box_13: t[2] === '자체수리' ? Math.round(r.int(t[5][0], t[5][1]) / 10000) * 10000 : Math.round(r.int(t[5][0], t[5][1]) / 10000) * 10000,
      box_14: v[0], box_15: v[1], box_16: t[6], box_17: t[7], file_name_1: '', file_name_2: ''
    };
  }
  var repairDb = M.db('c3_repair', function () {
    var cy = new Date().getFullYear(), rows = [];
    [cy - 2, cy - 1, cy].forEach(function (y) { rows = rows.concat(genRepairs(y)); });
    // 데모 3일 내 수리 2건 (어제 돌발, 오늘 정기)
    var days = M.days(), r = M.rng('c3rep-demo' + days[0]);
    var a = mkRepair(['열처리', '연속열처리로', '자체수리', '[돌발고장] 메쉬벨트 사행 감지 센서 교체', '사행감지 근접센서', [150000, 180000], '야간 작업 중 메쉬벨트 사행 경보(AL-301) 반복 발생. 근접센서 감지면 오염 및 브라켓 유격 확인 → 센서 교체 및 브라켓 고정.', '정지 20분, 생산 영향 경미'], M.toDate(days[1]), r, M.toDate(days[1]));
    a.box_6 = days[1]; a.box_7 = '03:15'; a.box_8 = days[1]; a.box_9 = '03:40'; a.box_10 = ''; a.box_5 = '정대현';
    var b = mkRepair(['세척', '세척 1호기', '세진테크', '[정기수리] 세척 1호기 액온 히터 접촉기 교체', '히터 마그네트 접촉기', [210000, 260000], '액온 저하 경보(AL-501) 예방 차원 접촉기 점검 결과 접점 마모 확인 → 교체 후 액온 55℃ 유지 확인.', ''], M.toDate(days[0]), r, M.toDate(days[2]));
    b.box_6 = days[2]; b.box_7 = '09:10'; b.box_8 = days[2]; b.box_9 = '10:30'; b.box_10 = '';
    rows.push(a, b);
    rows.sort(function (x, y) { return (y.box_6 + y.box_7).localeCompare(x.box_6 + x.box_7); });
    rows.forEach(function (x, i) { x.idx = rows.length - i; });
    return rows;
  }, 'idx');
  M.any('/productionManagement/repairHistory/select', function (req) {
    var p = req.params, y = String(p.startDate || '').trim(), t = p.endDate || '';
    return repairDb.all().filter(function (x) {
      if (y && x.box_4.substring(0, 4) !== y) return false;
      if (t && (x.box_11 || '').indexOf(t) < 0) return false;
      return true;
    }).sort(function (a, b) { return ((b.box_6 || b.box_4) + (b.box_7 || '')).localeCompare((a.box_6 || a.box_4) + (a.box_7 || '')); });
  });
  function repairSave(req) {
    var p = req.params, row = {};
    for (var i = 1; i <= 17; i++) row['box_' + i] = p['box_' + i] != null ? p['box_' + i] : '';
    row.box_13 = +row.box_13 || 0;
    row.file_name_1 = p.file_name_1 || ''; row.file_name_2 = p.file_name_2 || '';
    if (p.idx) row.idx = p.idx;
    repairDb.upsert(row);
    return { status: 'success' };
  }
  M.post('/productionManagement/repairHistory/insert', repairSave);
  M.post('/productionManagement/repairHistory/update', repairSave);
  M.post('/productionManagement/repairHistory/delete', function (req) { repairDb.remove(req.params.idx); return { status: 'success' }; });
  M.post('/productionManagement/repairHistory/jasperDownload', function (req) {
    var p = req.params, x = repairDb.find(p.idx) || p;
    var pg = new Page(); pg.header('설비 수리 이력서', (x.box_2 || '') + ' / ' + (x.box_4 || ''));
    var y = pg.table(30, 92, [{ t: '항목', w: 90 }, { t: '내용', w: 177, a: 'left' }, { t: '항목', w: 90 }, { t: '내용', w: 178, a: 'left' }], [
      ['설비공정', x.box_1, '설비명', x.box_2], ['담당업체', x.box_3, '의뢰일 / 의뢰자', (x.box_4 || '') + ' / ' + (x.box_5 || '')],
      ['수리 시작', (x.box_6 || '') + ' ' + (x.box_7 || ''), '수리 완료', (x.box_8 || '') + ' ' + (x.box_9 || '')],
      ['수리제목', x.box_11, '수리부위', x.box_12], ['수리비용', num(+x.box_13 || 0) + ' 원', '회계처리일', x.box_10 || '-'],
      ['담당자', x.box_14, '연락처', x.box_15]
    ], 22, 9);
    pg.text(30, y + 24, '■ 상세내역', 10.5, 'left', true); pg.rect(30, y + 32, 535, 70); pg.text(38, y + 50, (x.box_16 || '').substring(0, 60), 9); pg.text(38, y + 66, (x.box_16 || '').substring(60, 120), 9);
    pg.text(30, y + 124, '■ 메모: ' + (x.box_17 || '-'), 9.5);
    pg.sign(409, y + 150, [x.box_5 || '', '최영훈', '관리자']);
    return pdfRes([pg]);
  });

  /* ═════════════════════════ 열전대 교체이력 (thermocoupleChange) ═════════════════════════ */
  var TC_ZONES = [
    ['퀜칭 1존', -240], ['퀜칭 2존', -238], ['퀜칭 3존', -180], ['퀜칭 4존', -178], ['퀜칭 5존', -95],
    ['템퍼링 1존', -260], ['템퍼링 2존', -150], ['템퍼링 3존', -60], ['템퍼링 4존', 18], ['템퍼링 5존', 43],
    ['소입유조', -120], ['RX 가스발생기', -8, 'overdue']
  ];
  var TC_BIGO = ['K-type 열전대 Ø8×1200L 교체', 'K-type 시스 열전대 교체, 보상도선 점검', 'N-type 열전대 Ø8×900L 교체', 'K-type 열전대 교체, 단자대 재체결'];
  var tcDb = M.db('c3_tc', function () {
    var rows = [], now = new Date(), cy = now.getFullYear(), cnt = 0;
    for (var y = cy - 3; y <= cy + 1; y++) {
      TC_ZONES.forEach(function (z, i) {
        var an = M.addDays(new Date(cy, now.getMonth(), now.getDate()), z[1]);
        var d = new Date(y, an.getMonth(), an.getDate());
        var done = d <= now && !(y === cy && z[2] === 'overdue');
        var r = M.rng('c3tc' + y + i);
        var dd = done ? M.addDays(d, r.int(-3, 3)) : null;
        rows.push({
          cnt: ++cnt, year: String(y), hogi: i === 11 ? 'RX 가스발생기' : i === 10 ? '유조(소입유)' : '연속열처리로', zone: z[0],
          change_date: dd ? ymd(dd) : '', change_ndate: dd ? ymd(new Date(dd.getFullYear() + 1, dd.getMonth(), dd.getDate())) : '',
          bigo: dd ? r.pick(TC_BIGO) + (r.chance(0.3) ? ' (교체 전 편차 ' + r.float(2.1, 4.8, 1) + '℃)' : '') : ''
        });
      });
    }
    return rows;
  }, 'cnt');
  M.any('/condition/thermocoupleChange/getThermocoupleList', function (req) {
    var y = String(req.params.year || new Date().getFullYear());
    var all = tcDb.all();
    var rows = all.filter(function (x) { return x.year === y; }).map(function (x) {
      var prev = all.filter(function (p) { return p.zone === x.zone && +p.year === +y - 1; })[0];
      var c = {}; for (var k in x) c[k] = x[k];
      c.change_bdate = prev ? prev.change_date : '';
      if (!c.change_ndate && prev && prev.change_date) { var pd = M.toDate(prev.change_date); c.change_ndate = ymd(new Date(pd.getFullYear() + 1, pd.getMonth(), pd.getDate())); }
      if (!c.change_date && !c.bigo && c.change_ndate) c.bigo = M.toDate(c.change_ndate) < new Date() ? '교체 지연 - 예비품 입고 대기' : '교체 예정';
      return c;
    });
    return { data: rows };
  });
  M.post('/condition/thermocoupleChange/thermocoupleSave', function (req) {
    var p = req.params;
    tcDb.update(p.cnt, { change_date: p.change_date || '', change_ndate: p.change_ndate || '', bigo: p.bigo || '' });
    return { status: 'success' };
  });

  /* ═════════════════════════ 온도조절계 보정현황 (tempCorrection) ═════════════════════════ */
  var TCAL_MCH = [['소입로 온도조절계 (UT55A)', 5], ['소려로 온도조절계 (UT55A)', 5], ['소입유조 온도조절계 (TZN4S)', 1], ['세척기 온도조절계 (TZN4S)', 2]];
  function sgn(v) { return (v > 0 ? '+' : v < 0 ? '' : '±') + v.toFixed(1) + '℃'; }
  var tcalDb = M.db('c3_tcal', function () {
    var rows = [], now = new Date(), cy = now.getFullYear(), id = 0;
    for (var y = cy - 5; y <= cy; y++) {
      TCAL_MCH.forEach(function (m, mi) {
        for (var z = 1; z <= m[1]; z++) {
          var r = M.rng('c3cal' + y + mi + z);
          var b = r.float(-2.6, 2.6, 1), f = r.float(-0.4, 0.4, 1), s = r.float(-0.4, 0.4, 1);
          var fd = new Date(y, 4, 10 + mi * 2), sd = new Date(y, 9, 12 + mi * 2);
          var sDone = sd <= now;
          var fn = function (h, d) { return [{ file_id: y * 1000 + mi * 100 + z * 10 + h, file_name: y + '_' + (h === 1 ? '상반기' : '하반기') + '_' + m[0].split(' ')[0] + '_' + z + '존_교정성적서.pdf', file_size: r.int(180000, 640000), file_path: '#', d: ymd(d) }]; };
          rows.push({
            id: ++id, year: String(y), mch_name: m[0], zone: String(z), before_val: sgn(b),
            first_half: fd <= now ? sgn(f) : '', second_half: sDone ? sgn(s) : '',
            files_first: fd <= now ? fn(1, fd) : [], files_second: sDone ? fn(2, sd) : [],
            reg_date: ymd(sDone ? sd : fd) + ' 15:20:00', reg_user: r.pick(['최영훈', '장현우'])
          });
        }
      });
    }
    return rows;
  }, 'id');
  M.post('/condition/tempCalibration/list', function (req) {
    var p = req.params, y = String(p.year || new Date().getFullYear());
    return { success: true, list: tcalDb.all().filter(function (x) { return x.year === y && (!p.mch_name || x.mch_name === p.mch_name); }) };
  });
  function tcalSave(req) {
    var p = req.params, ex = p.id ? tcalDb.find(p.id) : null;
    var row = { mch_name: p.mch_name, zone: p.zone, before_val: p.before_val || '', first_half: p.first_half || '', second_half: p.second_half || '' };
    var keep = function (old, k) { try { var ids = JSON.parse(k || '[]'); return (old || []).filter(function (f) { return ids.indexOf(f.file_id) >= 0; }); } catch (e) { return old || []; } };
    var nf = function (v) { v = v == null ? [] : Array.isArray(v) ? v : [v]; return v.filter(function (f) { return f && f.fileName; }).map(function (f, i) { return { file_id: Date.now() + i, file_name: f.fileName, file_size: f.size, file_path: '#' }; }); };
    row.files_first = keep(ex && ex.files_first, p.keep_first).concat(nf(p.file_first));
    row.files_second = keep(ex && ex.files_second, p.keep_second).concat(nf(p.file_second));
    if (ex) { tcalDb.update(p.id, row); }
    else { row.year = String(new Date().getFullYear()); row.reg_date = M.fmt(new Date()); row.reg_user = '관리자'; tcalDb.insert(row); }
    return { success: true };
  }
  M.post('/condition/tempCalibration/insert', tcalSave);
  M.post('/condition/tempCalibration/update', tcalSave);
  M.post('/condition/tempCalibration/del', function (req) { tcalDb.remove(req.params.ids || []); return { success: true }; });
  M.post('/condition/tempCalibration/excel', function (req) {
    var p = req.params, y = String(p.year || new Date().getFullYear());
    var rows = tcalDb.all().filter(function (x) { return x.year === y && (!p.mch_name || x.mch_name === p.mch_name); });
    var csv = '\ufeff년도,설비명,구분(존),보정 전,상반기 보정,하반기 보정,등록일,등록자\n' + rows.map(function (x) { return [x.year, x.mch_name, x.zone + '존', x.before_val, x.first_half || '미보정', x.second_half || '미보정', (x.reg_date || '').substring(0, 10), x.reg_user].join(','); }).join('\n');
    return { success: true, downloadPath: URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8' })) };
  });

  /* ═════════════════════════ 열처리유 성상분석 (heatTreatingOil) ═════════════════════════ */
  function oilVals(key) {
    var r = M.rng('c3oil' + key);
    return { visc: r.float(20.4, 23.6, 1), water: r.float(0.01, 0.05, 2), acid: r.float(0.03, 0.12, 2), flash: r.int(206, 224), sludge: r.float(0.02, 0.09, 2),
      cool: r.int(86, 98), maxT: r.int(598, 640), t300: r.float(7.2, 9.4, 1), color: r.pick(['L2.5', 'L3.0', 'L3.5']) };
  }
  var oilDb = M.db('c3_oil', function () {
    var rows = [], now = new Date(), idx = 0;
    for (var k = 23; k >= 0; k--) {
      var d = new Date(now.getFullYear(), now.getMonth() - k, 14 + (k % 3));
      if (d > now) d = M.addDays(now, -1);
      var key = ymd(d), v = oilVals(key);
      var lab = k % 6 === 0 ? 'SK엔무브 기술연구소' : '한국석유관리원';
      rows.push({
        idx: ++idx, cr_date: key, mch_name: '열처리 연속로',
        box1: '소입유_성상분석_' + key.replace(/-/g, '') + '.pdf', box2: '냉각성능시험_' + key.replace(/-/g, '') + '.pdf',
        box3: k % 3 === 0 ? '수분측정_칼피셔_' + key.replace(/-/g, '') + '.pdf' : '', box4: k % 6 === 0 ? '분석의뢰서_' + key.replace(/-/g, '') + '.pdf' : '',
        memo: '동점도 ' + v.visc.toFixed(1) + 'cSt · 수분 ' + v.water.toFixed(2) + '% · 산가 ' + v.acid.toFixed(2) + ' · 인화점 ' + v.flash + '℃ · 냉각속도 ' + v.cool + '℃/s → 적합 (' + lab + ')'
      });
    }
    return rows.reverse();
  }, 'idx');
  M.post('/condition/heatOil/list', function (req) {
    var p = req.params;
    return { data: oilDb.all().filter(function (x) { return M.inRange(x.cr_date + ' 12:00:00', p.startDate || null, p.endDate || null) && (!p.mch_name || x.mch_name === p.mch_name); }).sort(function (a, b) { return b.cr_date.localeCompare(a.cr_date); }) };
  });
  function fileRow(db, p, boxes) {
    var row = { cr_date: p.cr_date || today(), mch_name: p.mch_name || '열처리 연속로', memo: p.memo || '' };
    var ex = p.idx ? db.find(p.idx) : null;
    boxes.forEach(function (b) { var f = p[b]; row[b] = f && f.fileName ? f.fileName : (ex ? ex[b] : ''); });
    if (ex) db.update(p.idx, row); else db.insert(row);
  }
  M.post('/condition/heatOil/insert', function (req) { fileRow(oilDb, req.params, ['box1', 'box2', 'box3', 'box4']); return { result: 'success' }; });
  M.post('/condition/heatOil/del', function (req) { oilDb.remove(req.params.idx); return { result: 'success' }; });

  function oilPages(name) {
    var m = /(\d{8})/.exec(name || ''), key = m ? m[1].substr(0, 4) + '-' + m[1].substr(4, 2) + '-' + m[1].substr(6, 2) : today();
    var v = oilVals(key), pg = new Page();
    var cool = name.indexOf('냉각') >= 0;
    pg.header(cool ? '소입유 냉각성능 시험 성적서' : '소입유 성상 분석 성적서', '시료채취일 ' + key);
    var y = pg.table(30, 92, [{ t: '항목', w: 90 }, { t: '내용', w: 177, a: 'left' }, { t: '항목', w: 90 }, { t: '내용', w: 178, a: 'left' }], [
      ['의뢰처', D.company, '설비', '열처리 연속로 소입유조'], ['유종', '소입유 (Quenching Oil, 1종 2호)', '시료량', '1 L'], ['시료채취일', key, '시험방법', cool ? 'JIS K 2242 (은 프로브)' : 'KS M ISO 3104 외']
    ], 20, 9);
    if (!cool) {
      y = pg.table(30, y + 24, [{ t: '시험항목', w: 140 }, { t: '단위', w: 80 }, { t: '관리기준', w: 120 }, { t: '측정값', w: 100 }, { t: '판정', w: 95 }], [
        ['동점도 (40℃)', 'cSt', '18 ~ 26', v.visc, '적합'], ['수분', 'wt%', '0.10 이하', v.water, '적합'], ['전산가', 'mgKOH/g', '0.50 이하', v.acid, '적합'],
        ['인화점 (COC)', '℃', '190 이상', v.flash, '적합'], ['슬러지 (불용분)', 'wt%', '0.20 이하', v.sludge, '적합'], ['색상 (ASTM)', '-', 'L4.0 이하', v.color, '적합']
      ], 22, 9);
    } else {
      y = pg.table(30, y + 24, [{ t: '시험항목', w: 160 }, { t: '단위', w: 80 }, { t: '관리기준', w: 120 }, { t: '측정값', w: 90 }, { t: '판정', w: 85 }], [
        ['최대 냉각속도', '℃/s', '80 이상', v.cool, '적합'], ['최대 냉각속도 온도', '℃', '580 ~ 660', v.maxT, '적합'], ['300℃ 도달 시간', 's', '10 이하', v.t300, '적합'], ['특성온도', '℃', '-', v.maxT + 95, '-']
      ], 22, 9);
      // 냉각곡선 그림
      var gx = 60, gy = y + 30, gw = 470, gh = 200;
      pg.rect(gx, gy, gw, gh); pg.text(gx, gy - 6, '냉각곡선 (온도 ℃ - 시간 s)', 9, 'left', true);
      var pts = [], T0 = 810;
      for (var s = 0; s <= 30; s += 0.5) { var T = 40 + (T0 - 40) * Math.exp(-Math.pow(s / (v.t300 * 0.55), 1.6)); pts.push([gx + s / 30 * gw, gy + gh - (T / 850) * gh]); }
      var path = pts.map(function (q, i) { return q[0].toFixed(1) + ' ' + (H - q[1]).toFixed(1) + (i ? ' l' : ' m'); }).join(' ');
      pg.ops.push('q 0.85 0.2 0.15 RG 1.6 w ' + path + ' S Q');
      [0, 200, 400, 600, 800].forEach(function (t) { pg.text(gx - 4, gy + gh - t / 850 * gh + 3, t, 7, 'right'); });
      [0, 10, 20, 30].forEach(function (t) { pg.text(gx + t / 30 * gw, gy + gh + 11, t, 7, 'center'); });
      y = gy + gh + 10;
    }
    pg.text(30, y + 30, '종합판정: 적합  —  모든 항목이 관리기준 이내로 계속 사용 가능함. 차기 분석 예정: 1개월 후', 9.5, 'left', true);
    pg.sign(409, y + 56, ['박성진', '윤재석', '관리자']);
    return [pg];
  }

  /* ═════════════════════════ 관리계획서 및 작업 표준서 (standardDoc) ═════════════════════════ */
  var DOC_EVT = [
    ['한성오토텍 드라이브 샤프트 경도 규격 변경(HRC 52~58) 반영', 7, 5, 3], ['소려로 5존 설정온도 변경(455→450℃) 반영', 7, 6, 3], ['신규 품목 피니언 샤프트(태광기어) 추가', 8, 6, 3],
    ['소입유 관리기준(수분 0.10% 이하) 개정', 8, 7, 3], ['IATF 16949 사후심사 지적사항 시정', 9, 7, 4], ['메쉬벨트 교체 후 장입 기준 재설정', 9, 8, 4],
    ['CQI-9 자체평가 결과 반영 (열전대 교체주기 명확화)', 10, 8, 4], ['볼 조인트 스터드 소려온도 조정 (560℃)', 10, 9, 4], ['일상점검 항목 추가 (RX가스 노점)', 11, 9, 5],
    ['연간 정기 개정 (조직 변경 반영)', 11, 10, 5], ['고객사(대진정밀) 요구사항 – 초품 경도 5점 측정 추가', 12, 10, 5], ['소입로 온도 균일성(TUS) 재측정 결과 반영', 12, 11, 6]
  ];
  var docDb = M.db('c3_stddoc', function () {
    var now = new Date(), rows = [];
    DOC_EVT.forEach(function (e, i) {
      var d = M.addDays(now, -Math.round((DOC_EVT.length - i) * 58 - 12 + (i % 3) * 5));
      var tag = ymd(d).replace(/-/g, '').substring(2);
      rows.push({ idx: i + 1, cr_date: ymd(d), mch_name: '열처리 연속로',
        box1: 'CP-HT-001_관리계획서_Rev.' + M.pad(e[1]) + '.pdf', box2: 'WI-HT-012_소입소려_작업표준서_Rev.' + M.pad(e[2]) + '.pdf',
        box3: i % 2 === 0 || i > 8 ? 'FM-EQ-003_설비점검일지_Rev.' + M.pad(e[3]) + '.pdf' : '', memo: e[0] });
    });
    return rows;
  }, 'idx');
  M.post('/condition/standardDoc/list', function (req) {
    var p = req.params;
    return { data: docDb.all().filter(function (x) { return M.inRange(x.cr_date + ' 12:00:00', p.startDate || null, p.endDate || null) && (!p.mch_name || x.mch_name === p.mch_name); }).sort(function (a, b) { return b.cr_date.localeCompare(a.cr_date); }) };
  });
  M.post('/condition/standardDoc/insert', function (req) { fileRow(docDb, req.params, ['box1', 'box2', 'box3']); return { result: 'success' }; });
  M.post('/condition/standardDoc/del', function (req) { docDb.remove(req.params.idx); return { result: 'success' }; });

  function docPages(name) {
    var pg = new Page(), rev = (/Rev\.(\d+)/.exec(name) || [0, '01'])[1];
    var cp = name.indexOf('관리계획서') >= 0, wi = name.indexOf('작업표준서') >= 0;
    var title = cp ? '관리계획서 (Control Plan)' : wi ? '작업표준서 – 소입·소려' : '설비점검일지';
    var no = cp ? 'CP-HT-001' : wi ? 'WI-HT-012' : 'FM-EQ-003';
    var row = docDb.all().filter(function (x) { return x.box1 === name || x.box2 === name || x.box3 === name; })[0];
    pg.header(title, '문서번호 ' + no + '  Rev.' + rev);
    var y = pg.table(30, 92, [{ t: '문서번호', w: 90 }, { t: '개정번호', w: 80 }, { t: '시행일', w: 100 }, { t: '적용설비', w: 130 }, { t: '관리부서', w: 135 }],
      [[no, 'Rev.' + rev, row ? row.cr_date : today(), '열처리 연속로', '생산팀 / 품질팀']], 20, 9);
    if (cp) {
      y = pg.table(30, y + 22, [{ t: '공정', w: 70 }, { t: '관리항목', w: 95 }, { t: '규격/기준', w: 120 }, { t: '측정방법', w: 90 }, { t: '주기', w: 70 }, { t: '이상시 조치', w: 90 }], [
        ['세척', '세척액 온도', '50 ~ 60℃', '온도계', '2회/교대', '히터 점검'], ['소입', '노내 온도', '레시피 SV ±5℃', '열전대/기록계', '연속', '투입 중지'],
        ['소입', '카본포텐셜', '0.40 ~ 0.45%', 'CP 센서', '연속', 'RX가스 조정'], ['소입', '소입유 온도', '60 ~ 80℃', '온도계', '연속', '냉각기 점검'],
        ['소려', '노내 온도', '레시피 SV ±5℃', '열전대/기록계', '연속', '투입 중지'], ['검사', '표면경도', '품목별 HRC 규격', '록웰경도계', 'LOT별 5점', '격리/재처리'],
        ['방청', '방청액 농도', '3 ~ 5%', '굴절계', '1회/일', '농도 보정']
      ], 20, 8.5);
    } else if (wi) {
      ['1. 작업 전 준비: 레시피 번호 확인, 소입유 온도(60~80℃) 및 RX가스 유량 확인', '2. 장입: 통당 기준 장입량 준수, 제품 겹침 금지, 바코드 스캔 후 투입',
        '3. 소입: 설정온도 도달 및 CP 안정 후 투입, 메쉬벨트 속도 레시피 준수', '4. 소려: 소입 후 30분 이내 소려 투입, 존별 온도 편차 ±5℃ 이내 유지',
        '5. 검사: LOT별 초·중·종품 경도 측정(5점), 규격 이탈 시 즉시 격리 및 보고', '6. 기록: 작업일보 및 LOT 보고서 작성, 이상 발생 시 수리이력 등록'
      ].forEach(function (t, i) { pg.text(36, y + 32 + i * 22, t, 9.5); });
      y += 32 + 6 * 22;
    } else {
      y = pg.table(30, y + 22, [{ t: 'No', w: 40 }, { t: '점검항목', w: 160, a: 'left' }, { t: '점검기준', w: 200, a: 'left' }, { t: '주기', w: 135 }], [
        [1, '소입로/소려로 온도', '설정온도 ±5℃ 이내', '매일'], [2, 'RX가스 유량', '12 ~ 15 Nm³/h', '매일'], [3, '소입유 유면/온도', '기준선 이상 / 60~80℃', '매일'],
        [4, '메쉬벨트 상태', '사행·파손 없음', '매일'], [5, '세척기 액온/농도', '50~60℃ / 2~3%', '매일'], [6, '비상정지 스위치', '정상 작동', '매주']
      ], 20, 8.5);
    }
    pg.text(30, y + 30, '■ 개정 이력', 10.5, 'left', true);
    var hist = docDb.all().slice(-4).reverse().map(function (x) { var r2 = (/Rev\.(\d+)/.exec(cp ? x.box1 : wi ? x.box2 : (x.box3 || x.box2)) || [0, '-'])[1]; return ['Rev.' + r2, x.cr_date, x.memo]; });
    y = pg.table(30, y + 38, [{ t: '개정', w: 60 }, { t: '일자', w: 80 }, { t: '개정 내용', w: 395, a: 'left' }], hist, 19, 8.5);
    pg.sign(409, y + 24, ['박성진', '김민수', '관리자']);
    return [pg];
  }

  /* ═════════════════════════ 일상점검일지 (dailyCheck) ═════════════════════════ */
  var DC_ITEMS = [
    ['소입로 온도', '각 존 지시온도가 설정온도 ±5℃ 이내인지 확인'], ['소려로 온도', '각 존 지시온도가 설정온도 ±5℃ 이내인지 확인'],
    ['RX가스 유량/노점', '유량 12~15 Nm³/h, 노점 -2 ~ +2℃ 확인'], ['카본포텐셜(CP)', 'CP 지시값 0.40~0.45% 유지 확인'],
    ['소입유 온도', '유온 60~80℃ 유지, 냉각기 작동 확인'], ['소입유 유면', '유면계 기준선 이상, 이물/수분 혼입 여부 확인'],
    ['교반기 작동상태', '교반기 #1~#3 작동, 이상음/진동 유무 확인'], ['메쉬벨트 상태', '사행, 파손, 이물 부착 여부 및 구동 상태 확인'],
    ['세척기 액온/농도', '액온 50~60℃, 세척액 농도 2~3% 확인'], ['방청액 농도', '방청액 농도 3~5% (굴절계) 확인'],
    ['냉각수 압력/온도', '냉각수 압력 2.0~3.0 kgf/㎠, 온도 35℃ 이하'], ['비상정지 스위치', '비상정지 버튼 외관 및 작동 상태 확인'],
    ['안전커버/인터록', '구동부 안전커버 체결 및 인터록 정상 확인'], ['작업장 정리정돈', '3정5S 상태, 바닥 유류 누유 여부 확인'],
    ['점검자 확인', '점검자 서명 (주간)']
  ];
  var dcAdd = M.db('c3_dc_add', function () { return []; }, 'cnt');
  var dcEdit = M.db('c3_dc_edit', function () { return []; }, 'k');
  var dcDel = M.db('c3_dc_del', function () { return []; }, 'cnt');
  function dcRows(ym) {
    var parts = ym.split('-'), y = +parts[0], mo = +parts[1];
    var now = new Date(), curYm = M.fmt(now, 'YYYY-MM');
    var rows = [];
    if (ym <= curYm && ym >= '2024-01') {
      var last = new Date(y, mo, 0).getDate(), upTo = ym === curYm ? now.getDate() : last;
      DC_ITEMS.forEach(function (it, i) {
        var row = { cnt: y * 10000 + mo * 100 + i + 1, d_ym: ym, d_title: it[0], d_desc: it[1], img_url: '', d_bigo: '' };
        var r = M.rng('c3dc' + ym + i);
        for (var d = 1; d <= 31; d++) {
          var k = 'd' + M.pad(d);
          if (d > last || d > upTo) { row[k] = ''; continue; }
          if (i === DC_ITEMS.length - 1) row[k] = D.shiftWorker(ym + '-' + M.pad(d), 10);
          else if (r.chance(0.012) && i !== 11) { row[k] = 'X'; row.d_bigo = mo + '/' + d + ' 이상 → ' + r.pick(['즉시 조정 완료', '설비팀 조치 완료', '보충 후 정상']); }
          else row[k] = 'O';
        }
        if (i === 5 && upTo > 3) row.img_url = '유면점검_' + ym.replace('-', '') + '.pdf';
        if (i === 7 && upTo > 10) row.img_url = '메쉬벨트_점검사진_' + ym.replace('-', '') + '.pdf';
        rows.push(row);
      });
    }
    rows = rows.concat(dcAdd.all().filter(function (x) { return x.d_ym === ym; }));
    var del = dcDel.all().map(function (x) { return String(x.cnt); });
    var edits = dcEdit.all();
    rows = rows.filter(function (x) { return del.indexOf(String(x.cnt)) < 0; });
    edits.forEach(function (e) { rows.forEach(function (x) { if (String(x.cnt) === String(e.cnt)) x[e.f] = e.v; }); });
    return rows;
  }
  M.post('/condition/dailyCheck/list', function (req) { return { data: dcRows(req.params.d_sdate || today().substring(0, 7)) }; });
  M.post('/condition/dailycheck/update', function (req) {
    var p = req.params; dcEdit.upsert({ k: p.cnt + '_' + p.d_field, cnt: p.cnt, f: p.d_field, v: p.d_value }); return { result: 'success' };
  });
  M.post('/condition/dailycheck/insert', function (req) {
    var ym = req.params.y_m || today().substring(0, 7);
    dcAdd.insert({ cnt: 900000000 + Date.now() % 100000000, d_ym: ym, d_title: '', d_desc: '', img_url: '', d_bigo: '' });
    return { result: 'success' };
  });
  M.post('/condition/dailycheck/del', function (req) { var c = req.params.cnt; dcAdd.remove(c); dcDel.upsert({ cnt: c }); return { result: 'success' }; });
  M.post('/condition/dailycheck/uploadImage', function (req) {
    var f = req.params.file, name = f && f.fileName ? f.fileName : 'upload.pdf';
    dcEdit.upsert({ k: req.params.cnt + '_img_url', cnt: req.params.cnt, f: 'img_url', v: name });
    return { result: 'success', fileName: name };
  });
  M.post('/condition/dailyCheck/excelDownload', function (req) {
    var ym = req.params.d_sdate || today().substring(0, 7), rows = dcRows(ym);
    var csv = '﻿년-월,점검항목,점검내용,' + Array.apply(null, Array(31)).map(function (_, i) { return (i + 1) + '일'; }).join(',') + ',비고\n';
    rows.forEach(function (r) { var a = [r.d_ym, r.d_title, '"' + r.d_desc + '"']; for (var d = 1; d <= 31; d++) a.push(r['d' + M.pad(d)] || ''); a.push(r.d_bigo || ''); csv += a.join(',') + '\n'; });
    return M.res(200, csv, 'text/csv;charset=utf-8');
  });
  function dcPages(name) {
    var pg = new Page(); pg.header('일상점검 첨부 – 점검 기록', name);
    var m = /(\d{6})/.exec(name), ym = m ? m[1].substr(0, 4) + '-' + m[1].substr(4) : today().substring(0, 7);
    var mesh = name.indexOf('메쉬') >= 0;
    var y = pg.table(30, 92, [{ t: '점검일', w: 90 }, { t: '설비', w: 120 }, { t: '점검항목', w: 120 }, { t: '측정/상태', w: 120 }, { t: '점검자', w: 85 }], [1, 2, 3, 4].map(function (k) {
      var r = M.rng('c3dcp' + name + k);
      return [ym + '-' + M.pad(k * 7 - 4), mesh ? '연속열처리로' : '유조(소입유)', mesh ? '메쉬벨트 사행/장력' : '유면/유온', mesh ? '사행 ' + r.int(2, 6) + 'mm (정상)' : '기준선 +' + r.int(15, 40) + 'mm / ' + r.int(63, 74) + '℃', D.shiftWorker(ym + '-' + M.pad(k), 10)];
    }), 22, 9);
    pg.text(30, y + 26, '※ 현장 사진은 원본 파일(점검 태블릿)에 보관. 이상 없음 확인.', 9);
    pg.sign(409, y + 50, ['김민수', '최영훈', '관리자']);
    return [pg];
  }

  /* ═════════════════════════ 파일 보기/다운로드: 서버 대신 생성 PDF 표시 ═════════════════════════ */
  function dlBlob(pages, fname) {
    var a = document.createElement('a'); a.href = pdfUrl(pages); a.download = fname || 'document.pdf';
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
  }
  window.addEventListener('load', function () {
    var path = location.pathname.replace(M.ctx, '');
    var showIn = function (pagesFn) {
      return function (enc) {
        if (!enc) return;
        var name = decodeURIComponent(enc);
        var fr = document.getElementById('pdfFrame'), md = document.getElementById('pdfViewerModal');
        if (fr) fr.src = pdfUrl(pagesFn(name));
        if (md) { md.style.display = 'flex'; md.classList.add('show'); }
      };
    };
    if (path.indexOf('/quality/heatTreatingOil') === 0) window.openPdf = showIn(oilPages);
    else if (path.indexOf('/condition/standardDoc') === 0) window.openPdf = showIn(docPages);
    else if (path.indexOf('/condition/dailyCheck') === 0) window.openPdf = showIn(dcPages);
    else if (path.indexOf('/condition/tempCorrection') === 0) {
      // 첨부파일 다운로드 버튼 → 생성한 교정성적서 PDF
      document.addEventListener('click', function (e) {
        var b = e.target && e.target.closest && e.target.closest('.file-dl-btn');
        if (!b) return;
        e.stopPropagation(); e.preventDefault();
        var it = b.closest('.file-preview-item'), name = it ? it.querySelector('.file-info-name').textContent : 'calibration.pdf';
        var mm = /^(\d{4})_(\S+?)_(\S+?)_(\d)존/.exec(name) || [];
        var pg = new Page(); pg.header('온도조절계 교정 성적서', name);
        var r = M.rng('c3calpdf' + name), base = name.indexOf('소려') >= 0 ? 450 : name.indexOf('소입유') >= 0 ? 70 : name.indexOf('세척') >= 0 ? 55 : 860;
        var y = pg.table(30, 92, [{ t: '항목', w: 90 }, { t: '내용', w: 177, a: 'left' }, { t: '항목', w: 90 }, { t: '내용', w: 178, a: 'left' }], [
          ['의뢰처', D.company, '교정기관', '한국계측제어 (KOLAS)'], ['기기명', (mm[3] || '') + ' 온도조절계', '구분', (mm[2] || '') + ' / ' + (mm[4] || '1') + '존'], ['표준기', 'Fluke 7526A / K-type', '교정일', (mm[1] || '') + (name.indexOf('상반기') >= 0 ? '-05' : '-10') + '-' + M.pad(r.int(10, 20))]
        ], 20, 9);
        var rows = [-50, 0, 50].map(function (o) { var std = base + o, e1 = r.float(-1.2, 1.2, 1), e2 = r.float(-0.3, 0.3, 1); return [std, M.round(std + e1, 1), sgn(-e1), M.round(std + e2, 1), '±2.0℃', '적합']; });
        y = pg.table(30, y + 24, [{ t: '기준온도(℃)', w: 90 }, { t: '보정전 지시', w: 90 }, { t: '보정값', w: 85 }, { t: '보정후 지시', w: 90 }, { t: '허용오차', w: 90 }, { t: '판정', w: 90 }], rows, 22, 9);
        pg.sign(409, y + 40, ['장현우', '최영훈', '관리자']);
        dlBlob([pg], name);
      }, true);
    }
  });
})();
