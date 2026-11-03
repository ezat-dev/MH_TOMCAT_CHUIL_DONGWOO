/*
 * YM SMART MES 데모 공통 기준 데이터 — 연속열처리로(MBF) 1~6호기
 * MOCK.D.* 로 접근. 응답은 백엔드 ApiResponse 형태 {success, code, message, data} 로 감싼다 → MOCK.D.ok(data)
 * 3일치 LOT 흐름은 MOCK.D.lots() 하나를 기준으로 한다.
 */
(function () {
  var M = window.MOCK;
  var D = M.D = M.D || {};

  D.ok = function (data) { return { success: true, code: 'OK', message: null, data: data === undefined ? null : data }; };
  D.fail = function (message, code) { return { success: false, code: code || 'ERROR', message: message, data: null }; };
  // PageResponse 형태가 필요할 때 (content/totalCount 등은 실제 화면 코드 확인 후 사용)
  D.page = function (list, page, size) {
    page = +page || 1; size = +size || 50;
    return { content: list.slice((page - 1) * size, page * size), list: list.slice((page - 1) * size, page * size), totalCount: list.length, total: list.length, page: page, size: size };
  };

  var REG = M.fmt(M.addDays(new Date(), -120), 'YYYY-MM-DD') + ' 09:30:00';

  D.vendors = [
    { vendorId: 1, vendorCode: 'V001', vendorName: '세진모터스',   vendorType: '고객사', ceoName: '정세진', bizNo: '609-81-55210', bizType: '제조업', bizItem: '자동차부품', tel: '055-280-1100', fax: '055-280-1109', zipCode: '51536', address: '경남 창원시 성산구 완암로 50', addressDetail: '2공장', managerName: '김지훈', managerPhone: '010-3321-4450', managerEmail: 'jh.kim@sejin-motors.co.kr', remark: '주요 고객', useYn: 'Y' },
    { vendorId: 2, vendorCode: 'V002', vendorName: '한일베어링',   vendorType: '고객사', ceoName: '한명수', bizNo: '514-86-20381', bizType: '제조업', bizItem: '베어링', tel: '053-610-2240', fax: '053-610-2249', zipCode: '42709', address: '대구 달서구 성서서로 101', addressDetail: '', managerName: '이윤아', managerPhone: '010-5520-7781', managerEmail: 'ya.lee@hanilbr.co.kr', remark: '', useYn: 'Y' },
    { vendorId: 3, vendorCode: 'V003', vendorName: '대영정공',     vendorType: '고객사', ceoName: '최대영', bizNo: '621-81-77432', bizType: '제조업', bizItem: '기어, 샤프트', tel: '051-970-3350', fax: '051-970-3359', zipCode: '46757', address: '부산 강서구 녹산산업중로 222', addressDetail: 'B동', managerName: '박준영', managerPhone: '010-7710-2203', managerEmail: 'jy.park@daeyoung.kr', remark: '', useYn: 'Y' },
    { vendorId: 4, vendorCode: 'V004', vendorName: '성광볼트',     vendorType: '고객사', ceoName: '오성광', bizNo: '615-81-30017', bizType: '제조업', bizItem: '체결부품', tel: '055-345-6610', fax: '055-345-6619', zipCode: '50969', address: '경남 김해시 주촌면 골든루트로 80', addressDetail: '', managerName: '정다은', managerPhone: '010-2289-6634', managerEmail: 'de.jung@skbolt.co.kr', remark: '월말 정산', useYn: 'Y' },
    { vendorId: 5, vendorCode: 'V005', vendorName: '우진오토파츠', vendorType: '고객사', ceoName: '류우진', bizNo: '134-81-62590', bizType: '제조업', bizItem: '조향부품', tel: '031-499-7720', fax: '031-499-7729', zipCode: '15610', address: '경기 안산시 단원구 신원로 33', addressDetail: '', managerName: '서민호', managerPhone: '010-9031-4428', managerEmail: 'mh.seo@woojin-ap.com', remark: '', useYn: 'Y' },
    { vendorId: 6, vendorCode: 'S001', vendorName: '동양열처리유', vendorType: '공급사', ceoName: '문동양', bizNo: '220-81-11873', bizType: '도소매', bizItem: '산업용 유류', tel: '02-2645-3310', fax: '02-2645-3319', zipCode: '07299', address: '서울 영등포구 경인로 775', addressDetail: '', managerName: '강태윤', managerPhone: '010-4402-5539', managerEmail: 'ty.kang@dyoil.co.kr', remark: '소입유 공급', useYn: 'Y' }
  ];
  D.vendors.forEach(function (v) { v.regUserName = '관리자'; v.regDt = REG; v.updDt = REG; });

  // 제품 (표면/심부 경도 규격 포함)
  D.products = [
    { productId: 1,  productCode: 'P-1101', vendorId: 1, partNo: '49560-2T100', productName: '등속 조인트 샤프트', material: 'SCM440',  spec: 'Ø32×410',  chargeWeightKg: 620, unitWeightG: 2350, unitPrice: 1850, surfaceHardMin: 52, surfaceHardMax: 58, coreHardMin: 30, coreHardMax: 38 },
    { productId: 2,  productCode: 'P-1102', vendorId: 1, partNo: '43210-4A200', productName: '아웃풋 기어',       material: 'SCM420H', spec: 'Ø86×32',   chargeWeightKg: 480, unitWeightG: 690,  unitPrice: 1320, surfaceHardMin: 58, surfaceHardMax: 62, coreHardMin: 32, coreHardMax: 42 },
    { productId: 3,  productCode: 'P-2101', vendorId: 2, partNo: 'BR-6205-IR', productName: '베어링 내륜',       material: 'SUJ2',    spec: 'Ø25×15',   chargeWeightKg: 350, unitWeightG: 82,   unitPrice: 240,  surfaceHardMin: 60, surfaceHardMax: 64, coreHardMin: 58, coreHardMax: 64 },
    { productId: 4,  productCode: 'P-2102', vendorId: 2, partNo: 'BR-6308-OR', productName: '베어링 외륜',       material: 'SUJ2',    spec: 'Ø90×23',   chargeWeightKg: 420, unitWeightG: 310,  unitPrice: 520,  surfaceHardMin: 60, surfaceHardMax: 64, coreHardMin: 58, coreHardMax: 64 },
    { productId: 5,  productCode: 'P-3101', vendorId: 3, partNo: '45822-3B010', productName: '유성 피니언',       material: 'SCr420H', spec: 'M2.0 Z18', chargeWeightKg: 300, unitWeightG: 145,  unitPrice: 680,  surfaceHardMin: 58, surfaceHardMax: 63, coreHardMin: 30, coreHardMax: 40 },
    { productId: 6,  productCode: 'P-3102', vendorId: 3, partNo: '43120-2C600', productName: '카운터 샤프트',     material: 'SCM420H', spec: 'Ø28×265',  chargeWeightKg: 520, unitWeightG: 1180, unitPrice: 1540, surfaceHardMin: 58, surfaceHardMax: 62, coreHardMin: 30, coreHardMax: 40 },
    { productId: 7,  productCode: 'P-4101', vendorId: 4, partNo: 'HB-M12-80',  productName: '플랜지 볼트 M12',   material: 'SCM435',  spec: 'M12×80',   chargeWeightKg: 650, unitWeightG: 96,   unitPrice: 85,   surfaceHardMin: 33, surfaceHardMax: 39, coreHardMin: 33, coreHardMax: 39 },
    { productId: 8,  productCode: 'P-4102', vendorId: 4, partNo: 'HN-M16-H',   productName: '고장력 너트 M16',   material: 'S45C',    spec: 'M16',      chargeWeightKg: 600, unitWeightG: 34,   unitPrice: 42,   surfaceHardMin: 26, surfaceHardMax: 32, coreHardMin: 26, coreHardMax: 32 },
    { productId: 9,  productCode: 'P-5101', vendorId: 5, partNo: '56540-3S000', productName: '스티어링 웜',       material: 'SCM415',  spec: 'Ø24×180',  chargeWeightKg: 380, unitWeightG: 640,  unitPrice: 960,  surfaceHardMin: 57, surfaceHardMax: 62, coreHardMin: 28, coreHardMax: 38 },
    { productId: 10, productCode: 'P-5102', vendorId: 5, partNo: '57712-2K100', productName: '타이로드 볼스터드', material: 'SCM435',  spec: 'Ø22×95',   chargeWeightKg: 450, unitWeightG: 260,  unitPrice: 410,  surfaceHardMin: 34, surfaceHardMax: 40, coreHardMin: 30, coreHardMax: 38 }
  ];
  D.products.forEach(function (p) {
    var v = D.vendors[p.vendorId - 1];
    p.vendorCode = v.vendorCode; p.vendorName = v.vendorName;
    p.priceUnit = '원/EA'; p.surfaceHardUnit = 'HRC'; p.coreHardUnit = 'HRC';
    p.remark = ''; p.useYn = 'Y'; p.regUserName = '관리자'; p.regDt = REG; p.updDt = REG; p.images = [];
  });

  // 열처리 패턴 (제품별 1~2개). q1~q5 = 퀜칭로 1~5존, t1~t5 = 템퍼링로 1~5존
  var PT = [
    [1, 'Q880-T450', [860, 880, 880, 880, 850], [440, 450, 450, 450, 440], 0.45, 28, 26],
    [2, 'CQ930-T170', [880, 910, 930, 930, 860], [170, 170, 170, 165, 160], 0.85, 32, 28],
    [3, 'Q840-T170', [820, 840, 840, 840, 830], [170, 170, 170, 170, 165], 0.95, 36, 30],
    [4, 'Q845-T175', [825, 845, 845, 845, 830], [175, 175, 175, 170, 170], 0.95, 34, 30],
    [5, 'CQ920-T170', [870, 900, 920, 920, 850], [170, 170, 170, 165, 160], 0.80, 35, 30],
    [6, 'CQ930-T170', [880, 910, 930, 930, 860], [170, 170, 170, 165, 160], 0.85, 30, 27],
    [7, 'Q870-T480', [850, 870, 870, 870, 850], [470, 480, 480, 480, 470], 0.40, 40, 34],
    [8, 'Q850-T580', [830, 850, 850, 850, 840], [570, 580, 580, 580, 570], 0.40, 42, 36],
    [9, 'CQ910-T180', [860, 890, 910, 910, 850], [180, 180, 175, 175, 170], 0.80, 33, 29],
    [10, 'Q860-T520', [840, 860, 860, 860, 845], [510, 520, 520, 520, 510], 0.40, 38, 33],
    [2, 'CQ920-T180', [875, 900, 920, 920, 855], [180, 180, 180, 175, 170], 0.80, 34, 29],
    [6, 'CQ940-T160', [885, 915, 940, 940, 865], [160, 160, 160, 160, 155], 0.90, 28, 25]
  ];
  D.patterns = PT.map(function (a, i) {
    var p = D.products[a[0] - 1];
    return {
      patternId: i + 1, patternCode: 'PT-' + M.pad(i + 1, 3), patternName: a[1], productId: p.productId, chargeWeightKg: p.chargeWeightKg,
      q1Zone: a[2][0], q2Zone: a[2][1], q3Zone: a[2][2], q4Zone: a[2][3], q5Zone: a[2][4], quenchSpeed: a[5], cp: a[4],
      t1Zone: a[3][0], t2Zone: a[3][1], t3Zone: a[3][2], t4Zone: a[3][3], t5Zone: a[3][4], temperSpeed: a[6], speedUnit: 'Hz',
      remark: '', useYn: 'Y', regUserName: '관리자', updUserName: '관리자', regDt: REG, updDt: REG,
      productCode: p.productCode, partNo: p.partNo, productName: p.productName, spec: p.spec, material: p.material,
      surfaceHardMin: p.surfaceHardMin, surfaceHardMax: p.surfaceHardMax, surfaceHardUnit: 'HRC',
      coreHardMin: p.coreHardMin, coreHardMax: p.coreHardMax, coreHardUnit: 'HRC',
      vendorId: p.vendorId, vendorCode: p.vendorCode, vendorName: p.vendorName
    };
  });

  // 설비 — 화면 내장 목업(src/mocks/furnaceMock.js)과 같은 상태: 4호기 알람, 6호기 정지(정기 점검)
  D.furnaces = [1, 2, 3, 4, 5, 6].map(function (n) {
    return { no: n, code: 'MBF' + n, name: '연속열처리로 ' + n + '호기', status: n === 4 ? 'alarm' : n === 6 ? 'idle' : 'run' };
  });
  D.equipments = D.furnaces.map(function (f, i) {
    return { equipId: i + 1, equipCode: f.code, equipName: f.name, equipType: '연속열처리로', maker: i < 3 ? '대한로공업' : '한국써모텍', modelName: 'MBF-' + (i < 3 ? '600' : '800') + 'C', managerName: i % 2 ? '정용호' : '김태성', installDate: (2016 + i) + '-03-15', startDate: (2016 + i) + '-05-02', equipStatus: f.status === 'idle' ? '정지' : '가동', plcModel: 'MELSEC Q03UDV', plcIp: '192.168.10.' + (11 + i), plcProtocol: 'MC Protocol', remark: '', useYn: 'Y', regUserName: '관리자', regDt: REG, updDt: REG };
  }).concat([
    { equipId: 7,  equipCode: 'WSH1', equipName: '세척기 1호기',   equipType: '세척기',   maker: '세진테크', modelName: 'SW-1200', managerName: '김태성', installDate: '2018-07-01', startDate: '2018-07-20', equipStatus: '가동', plcModel: 'LS XGK', plcIp: '192.168.10.31', plcProtocol: 'XGT', remark: '', useYn: 'Y' },
    { equipId: 8,  equipCode: 'WSH2', equipName: '세척기 2호기',   equipType: '세척기',   maker: '세진테크', modelName: 'SW-1200', managerName: '김태성', installDate: '2020-02-10', startDate: '2020-03-01', equipStatus: '가동', plcModel: 'LS XGK', plcIp: '192.168.10.32', plcProtocol: 'XGT', remark: '', useYn: 'Y' },
    { equipId: 9,  equipCode: 'RXG1', equipName: 'RX 가스발생기', equipType: '공용설비', maker: '동양가스텍', modelName: 'RX-150', managerName: '정용호', installDate: '2016-03-15', startDate: '2016-05-02', equipStatus: '가동', plcModel: '-', plcIp: '', plcProtocol: '', remark: '', useYn: 'Y' },
    { equipId: 10, equipCode: 'CT01', equipName: '냉각탑',         equipType: '공용설비', maker: '경인쿨링', modelName: 'KC-200', managerName: '정용호', installDate: '2016-03-15', startDate: '2016-05-02', equipStatus: '가동', plcModel: '-', plcIp: '', plcProtocol: '', remark: '', useYn: 'Y' }
  ]);
  D.equipments.forEach(function (e) { e.regUserName = e.regUserName || '관리자'; e.regDt = e.regDt || REG; e.updDt = e.updDt || REG; });

  D.users = [
    { userId: 1, loginId: 'ez',     userName: '관리자', deptName: '관리팀',   phone: '010-2231-5501', email: 'admin@ym-mes.co.kr' },
    { userId: 2, loginId: 'tskim',  userName: '김태성', deptName: '생산팀',   phone: '010-3345-1128', email: 'ts.kim@ym-mes.co.kr' },
    { userId: 3, loginId: 'yhjung', userName: '정용호', deptName: '설비보전팀', phone: '010-7712-4490', email: 'yh.jung@ym-mes.co.kr' },
    { userId: 4, loginId: 'sylee',  userName: '이서연', deptName: '품질팀',   phone: '010-9083-2275', email: 'sy.lee@ym-mes.co.kr' },
    { userId: 5, loginId: 'mjpark', userName: '박민재', deptName: '생산팀',   phone: '010-5521-8806', email: 'mj.park@ym-mes.co.kr' },
    { userId: 6, loginId: 'hwchoi', userName: '최현우', deptName: '생산팀',   phone: '010-6634-1172', email: 'hw.choi@ym-mes.co.kr' },
    { userId: 7, loginId: 'jyhan',  userName: '한지영', deptName: '품질팀',   phone: '010-2210-9934', email: 'jy.han@ym-mes.co.kr' },
    { userId: 8, loginId: 'dsoh',   userName: '오동석', deptName: '설비보전팀', phone: '010-4471-3358', email: 'ds.oh@ym-mes.co.kr' }
  ];
  D.users.forEach(function (u) { u.useYn = 'Y'; u.regDt = REG; u.updDt = REG; });

  D.vendor = function (id) { for (var i = 0; i < D.vendors.length; i++) if (D.vendors[i].vendorId === +id) return D.vendors[i]; return null; };
  D.product = function (id) { for (var i = 0; i < D.products.length; i++) if (D.products[i].productId === +id) return D.products[i]; return null; };
  D.pattern = function (id) { for (var i = 0; i < D.patterns.length; i++) if (D.patterns[i].patternId === +id) return D.patterns[i]; return null; };

  /*
   * 3일치 LOT 흐름 — 호기별 연속 투입. 6호기는 오늘 08시부터 정기 점검으로 정지, 4호기는 현재 알람 중이지만 가동.
   *   lotNo, furnaceCode, furnaceName, patternId/patternCode, productId/productName/partNo, vendorName,
   *   qty, weightKg, startDt, endDt('' = 진행중), status('완료'|'진행중'), workerName, workDate,
   *   surfaceHard, coreHard, judge('합격'|'불합격')
   */
  var _lots = null;
  D.lots = function () {
    if (_lots) return _lots;
    var days = M.days();
    var now = new Date();
    var out = [];
    D.furnaces.forEach(function (f) {
      var r = M.rng('ym-lots-' + f.code + '-' + days[0]);
      var t = M.toDate(days[0] + ' 06:00:00');
      t = new Date(t.getTime() + r.int(0, 50) * 60000);
      var stopAt = f.status === 'idle' ? M.toDate(days[2] + ' 08:00:00') : null;
      var seq = 0;
      while (t < now && (!stopAt || t < stopAt)) {
        var pt = D.patterns[r.int(0, D.patterns.length - 1)];
        var p = D.product(pt.productId);
        var dur = r.int(70, 130);
        var end = new Date(t.getTime() + dur * 60000);
        var running = end > now;
        seq++;
        var qty = Math.round(pt.chargeWeightKg * 1000 / p.unitWeightG / 10) * 10;
        var sh = M.round(r.normal((p.surfaceHardMin + p.surfaceHardMax) / 2, (p.surfaceHardMax - p.surfaceHardMin) / 6.5), 1);
        var ch = M.round(r.normal((p.coreHardMin + p.coreHardMax) / 2, (p.coreHardMax - p.coreHardMin) / 6.5), 1);
        out.push({
          lotNo: f.code + '-' + M.fmt(t, 'YYMMDD') + '-' + M.pad(seq, 3),
          furnaceCode: f.code, furnaceName: f.name, furnaceNo: f.no,
          patternId: pt.patternId, patternCode: pt.patternCode, patternName: pt.patternName,
          productId: p.productId, productCode: p.productCode, productName: p.productName, partNo: p.partNo, material: p.material,
          vendorId: p.vendorId, vendorName: p.vendorName,
          qty: qty, weightKg: M.round(qty * p.unitWeightG / 1000, 1),
          workDate: M.fmt(t, 'YYYY-MM-DD'), startDt: M.fmt(t), endDt: running ? '' : M.fmt(end), planEndDt: M.fmt(end),
          status: running ? '진행중' : '완료',
          workerName: (t.getHours() >= 8 && t.getHours() < 20) ? r.pick(['김태성', '박민재']) : r.pick(['최현우', '박민재']),
          surfaceHardMin: p.surfaceHardMin, surfaceHardMax: p.surfaceHardMax, coreHardMin: p.coreHardMin, coreHardMax: p.coreHardMax,
          surfaceHard: running ? null : sh, coreHard: running ? null : ch,
          judge: running ? '' : ((sh < p.surfaceHardMin || sh > p.surfaceHardMax || ch < p.coreHardMin || ch > p.coreHardMax) ? '불합격' : '합격')
        });
        if (running) break;
        t = new Date(end.getTime() + r.int(2, 10) * 60000);
      }
    });
    out.sort(function (a, b) { return a.startDt < b.startDt ? -1 : 1; });
    _lots = out;
    return out;
  };
  D.lotsIn = function (from, to, furnaceCode) {
    return D.lots().filter(function (l) { return M.inRange(l.startDt, from, to) && (!furnaceCode || l.furnaceCode === furnaceCode); });
  };
  D.currentLot = function (furnaceCode) {
    var ls = D.lots();
    for (var i = ls.length - 1; i >= 0; i--) if (ls[i].furnaceCode === furnaceCode && ls[i].status === '진행중') return ls[i];
    return null;
  };

  // 여러 화면(종합생산현황 등)이 쓰는 기본 패턴 목록 — 패턴관리 화면 라우트(y1)가 더 자세히 덮어쓴다
  M.get('/api/base/pattern', function (req) {
    var q = req.params;
    return D.ok(D.patterns.filter(function (p) {
      return (!q.vendorId || p.vendorId === +q.vendorId) && (!q.productId || p.productId === +q.productId) &&
        (!q.useYn || p.useYn === q.useYn) &&
        (!q.keyword || (p.patternCode + p.patternName + p.productName + p.partNo).indexOf(q.keyword) >= 0);
    }));
  });

  /* ── [y1 추가] 비가동 사유 · 비가동 내역 · 경도 규격 — 설비비가동현황/CHECK SHEET/경도측정/CPK 공용 ──
   * 화면 저장분은 y1 라우트가 MOCK.db('downtimeReason'|'downtime'|'hardnessSpec')로 관리 (같은 이름으로 열면 공유됨) */
  var RS = [
    ['계획정지', '정기 점검', '공통문제'], ['계획정지', '패턴 교체', '생산'], ['계획정지', '청소·정비', '생산'], ['계획정지', '예방 보전', '설비문제(기계)'],
    ['고장정지', '메쉬벨트 사행', '설비문제(기계)'], ['고장정지', '버너 점화 불량', '설비문제(전기)'], ['고장정지', '히터 단선', '설비문제(전기)'], ['고장정지', '온도 이상', '설비문제(전기)'],
    ['고장정지', '컨베이어 모터 트립', '설비문제(기계)'], ['고장정지', 'RX가스 노점 이상', '설비문제(기계)'], ['고장정지', 'PLC 통신 오류', '설비문제(전기)'],
    ['대기', '자재 대기', '생산관리'], ['대기', '작업자 대기', '생산'], ['대기', '품질 판정 대기', '생산관리'], ['기타', '정전·순간정전', '공통문제'], ['기타', '기타', '공통문제']
  ];
  D.downtimeReasons = RS.map(function (a, i) {
    return { reasonId: i + 1, reasonCode: 'DR' + M.pad(i + 1, 3), reasonName: a[1], reasonType: a[0], reasonGroup: a[2], sortOrder: i + 1, remark: '', useYn: 'Y',
      regUserId: 'ez', regUserName: '관리자', updUserId: null, updUserName: null, regDt: REG.replace(' ', 'T'), updDt: REG.replace(' ', 'T') };
  });
  var DT_MEMO = {
    '정기 점검': '월간 정기 점검 — 버너·열전대·벨트 장력 점검', '패턴 교체': '패턴 교체 후 승온·CP 안정화 대기', '청소·정비': '소입조 슬러지 제거 및 입구 커튼 청소',
    '예방 보전': '컨베이어 감속기 오일 교환', '메쉬벨트 사행': '메쉬벨트 사행 발생, 가이드 롤러 조정', '버너 점화 불량': '3존 버너 점화 실패 알람 — 점화봉 청소 후 재점화',
    '히터 단선': '템퍼링로 2존 히터 1상 단선, 교체 완료', '온도 이상': '퀜칭로 3존 온도 편차 +12℃, 조절계 PID 재조정', '컨베이어 모터 트립': '출구 컨베이어 모터 과부하 트립, 리셋 후 재가동',
    'RX가스 노점 이상': 'RX가스 노점 상승(+4℃), 발생기 촉매 점검', 'PLC 통신 오류': 'PLC-HMI 통신 끊김, 허브 재부팅', '자재 대기': '세척 완료 물량 부족으로 투입 대기',
    '작업자 대기': '교대 인수인계 지연', '품질 판정 대기': '초물 경도 판정 대기', '정전·순간정전': '한전 순간정전 — UPS 전환 후 재가동', '기타': ''
  };
  var _dts = null;
  D.downtimes = function () {
    if (_dts) return _dts;
    var days = M.days(), now = new Date(), out = [], id = 0;
    var R = function (name) { for (var i = 0; i < D.downtimeReasons.length; i++) if (D.downtimeReasons[i].reasonName === name) return D.downtimeReasons[i]; };
    var ops = ['tskim', 'mjpark', 'hwchoi', 'yhjung', 'dsoh'];
    var add = function (eq, rs, s, e, src, r) {
      var wid = r.pick(rs.reasonType === '고장정지' ? ['yhjung', 'dsoh'] : ops); var who = D.users.filter(function (u) { return u.loginId === wid; })[0];
      var reg = e ? new Date(e.getTime() + r.int(3, 40) * 60000) : new Date(s.getTime() + r.int(2, 10) * 60000);
      if (reg > now) reg = now;
      out.push({ downtimeId: ++id, equipId: eq.equipId, equipCode: eq.equipCode, equipName: eq.equipName, reasonId: rs.reasonId, reasonCode: rs.reasonCode,
        reasonName: rs.reasonName, reasonType: rs.reasonType, startDt: M.fmt(s, 'YYYY-MM-DDTHH:mm:ss'), endDt: e ? M.fmt(e, 'YYYY-MM-DDTHH:mm:ss') : null,
        source: src, checkRowId: null, memo: DT_MEMO[rs.reasonName] || '', regUserId: who.loginId, regUserName: who.userName,
        updUserId: null, updUserName: null, regDt: M.fmt(reg, 'YYYY-MM-DDTHH:mm:ss'), updDt: M.fmt(reg, 'YYYY-MM-DDTHH:mm:ss') });
    };
    var POOL = { '고장정지': ['메쉬벨트 사행', '버너 점화 불량', '히터 단선', '온도 이상', '컨베이어 모터 트립', 'RX가스 노점 이상', 'PLC 통신 오류'],
      '계획정지': ['패턴 교체', '청소·정비', '예방 보전'], '대기': ['자재 대기', '작업자 대기', '품질 판정 대기'] };
    var DUR = { '고장정지': [15, 95], '계획정지': [30, 140], '대기': [10, 55] };
    D.equipments.slice(0, 6).forEach(function (eq) {
      days.forEach(function (day) {
        var r = M.rng('ym-dt-' + eq.equipCode + '-' + day);
        var n = eq.equipCode === 'MBF4' ? r.int(1, 3) : r.int(0, 2);
        var used = [];
        for (var k = 0; k < n; k++) {
          var x = r(), type = x < (eq.equipCode === 'MBF4' ? 0.55 : 0.28) ? '고장정지' : x < 0.75 ? '계획정지' : '대기';
          var dur = r.int(DUR[type][0], DUR[type][1]);
          var s = M.toDate(day + ' 00:00:00'); s = new Date(s.getTime() + r.int(60, 1380 - dur) * 60000);
          var e = new Date(s.getTime() + dur * 60000);
          if (e > now) continue;
          if (eq.equipCode === 'MBF6' && day === days[2] && e > M.toDate(day + ' 08:00:00')) continue;
          if (used.some(function (u) { return s < u[1] && e > u[0]; })) continue;
          used.push([s, e]);
          add(eq, R(r.pick(POOL[type])), s, e, r.chance(0.3) ? 'SHEET' : 'MANUAL', r);
        }
      });
    });
    var r0 = M.rng('ym-dt-special-' + days[2]);
    // 6호기: 오늘 08시부터 정기 점검(진행 중), 4호기: 25분 전부터 온도 이상(진행 중) — 모니터링 화면과 같은 상황
    add(D.equipments[5], R('정기 점검'), M.toDate(days[2] + ' 08:00:00'), null, 'MANUAL', r0);
    add(D.equipments[3], R('온도 이상'), new Date(Math.floor((now.getTime() - 25 * 60000) / 60000) * 60000), null, 'MANUAL', r0);
    add(D.equipments[6], R('청소·정비'), M.toDate(days[1] + ' 13:10:00'), M.toDate(days[1] + ' 14:25:00'), 'MANUAL', r0);
    add(D.equipments[8], R('RX가스 노점 이상'), M.toDate(days[0] + ' 21:40:00'), M.toDate(days[0] + ' 22:35:00'), 'MANUAL', r0);
    out.forEach(function (o) { if (new Date(o.startDt) > now) o.startDt = M.fmt(now, 'YYYY-MM-DDTHH:mm:ss'); });
    out.sort(function (a, b) { return a.startDt < b.startDt ? -1 : 1; });
    out.forEach(function (o, i) { o.downtimeId = i + 1; });
    _dts = out;
    return out;
  };

  // 경도 규격 — 호기 × 제품 × (표면/심부 경도, 침탄품은 유효경화깊이 추가)
  var _specs = null;
  D.hardnessSpecs = function () {
    if (_specs) return _specs;
    var out = [], id = 0, lots = D.lots();
    D.furnaces.forEach(function (f) {
      D.products.forEach(function (p) {
        var items = [['표면 경도', 'HRC', p.surfaceHardMin, p.surfaceHardMax, 1], ['심부 경도', 'HRC', p.coreHardMin, p.coreHardMax, 1]];
        if (p.productId === 2 || p.productId === 6 || p.productId === 5) items.push(['유효경화깊이', 'mm', p.productId === 5 ? 0.5 : 0.8, p.productId === 5 ? 0.9 : 1.2, 2]);
        var mine = lots.filter(function (l) { return l.furnaceCode === f.code && l.productId === p.productId && l.status === '완료'; });
        items.forEach(function (it) {
          out.push({ specId: ++id, equipCode: f.code, equipName: f.name, productId: p.productId, vendorName: p.vendorName, material: p.material,
            partNo: p.partNo, productName: p.productName, itemName: it[0], unit: it[1], lsl: it[2], usl: it[3], target: M.round((it[2] + it[3]) / 2, it[4]),
            decimals: it[4], sampleSize: it[1] === 'mm' ? 3 : 5, useYn: 'Y', remark: '', regUserId: 'sylee', regUserName: '이서연', updUserId: null, updUserName: null,
            regDt: REG.replace(' ', 'T'), updDt: REG.replace(' ', 'T'), measCount: mine.length,
            lastMeasDt: mine.length ? mine[mine.length - 1].endDt.replace(' ', 'T') : null });
        });
      });
    });
    _specs = out;
    return out;
  };
})();
