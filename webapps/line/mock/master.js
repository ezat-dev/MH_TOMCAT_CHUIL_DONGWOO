/*
 * 천일정밀 데모 공통 기준 데이터 (모든 화면이 같은 이름/코드를 쓰도록 여기서 정의)
 * MOCK.D.* 로 접근. 3일치(그제·어제·오늘) LOT 흐름은 MOCK.D.lots() 하나를 기준으로 한다.
 */
(function () {
  var M = window.MOCK;
  var D = M.D = M.D || {};

  D.company = '데모 사업장';

  D.customers = [
    { cust_code: 'C001', cust_name: '한성오토텍', ceo: '김한성', tel: '055-212-3401', addr: '경남 창원시 성산구 공단로 112', manager: '이수진', biz_no: '609-81-23451' },
    { cust_code: 'C002', cust_name: '대진정밀',   ceo: '박대진', tel: '051-831-2290', addr: '부산 강서구 녹산산단 321로 45', manager: '정우성', biz_no: '621-86-11872' },
    { cust_code: 'C003', cust_name: '세원테크',   ceo: '최세원', tel: '053-591-7720', addr: '대구 달서구 성서공단로 77', manager: '한지민', biz_no: '514-81-33620' },
    { cust_code: 'C004', cust_name: '동신공업',   ceo: '오동신', tel: '052-288-4512', addr: '울산 북구 효자로 210', manager: '김태호', biz_no: '610-81-90217' },
    { cust_code: 'C005', cust_name: '우성금속',   ceo: '서우성', tel: '055-388-1904', addr: '경남 김해시 진영읍 하계로 58', manager: '윤서영', biz_no: '615-81-45126' },
    { cust_code: 'C006', cust_name: '태광기어',   ceo: '임태광', tel: '031-492-6650', addr: '경기 안산시 단원구 해봉로 133', manager: '조민혁', biz_no: '134-81-77304' }
  ];

  // 열처리 품목 (소입/소려 연속로)
  D.products = [
    { prod_code: 'P1001', prod_name: '드라이브 샤프트',   part_no: '49500-2B100', cust_code: 'C001', material: 'SCM440',  hrc_min: 52, hrc_max: 58, unit_wt: 2.35, pattern: 'Q-860/T-450', q_temp: 860, t_temp: 450, cycle_min: 95 },
    { prod_code: 'P1002', prod_name: '허브 베어링 하우징', part_no: '51750-3K000', cust_code: 'C001', material: 'S53C',    hrc_min: 55, hrc_max: 60, unit_wt: 1.82, pattern: 'Q-850/T-180', q_temp: 850, t_temp: 180, cycle_min: 90 },
    { prod_code: 'P1003', prod_name: '스티어링 랙바',     part_no: '56510-2S000', cust_code: 'C002', material: 'S45C',    hrc_min: 50, hrc_max: 55, unit_wt: 1.46, pattern: 'Q-840/T-400', q_temp: 840, t_temp: 400, cycle_min: 85 },
    { prod_code: 'P1004', prod_name: '트랜스미션 기어',   part_no: '43221-4A010', cust_code: 'C006', material: 'SCM420H', hrc_min: 58, hrc_max: 62, unit_wt: 0.68, pattern: 'Q-880/T-170', q_temp: 880, t_temp: 170, cycle_min: 110 },
    { prod_code: 'P1005', prod_name: '볼 조인트 스터드',   part_no: '54530-1R000', cust_code: 'C003', material: 'SCM435',  hrc_min: 33, hrc_max: 38, unit_wt: 0.32, pattern: 'Q-860/T-560', q_temp: 860, t_temp: 560, cycle_min: 80 },
    { prod_code: 'P1006', prod_name: '크랭크 핀',         part_no: '23110-2G200', cust_code: 'C004', material: 'SCM440',  hrc_min: 28, hrc_max: 34, unit_wt: 0.94, pattern: 'Q-850/T-600', q_temp: 850, t_temp: 600, cycle_min: 90 },
    { prod_code: 'P1007', prod_name: '고강도 볼트 M16',    part_no: 'HB-M16-120',  cust_code: 'C005', material: 'SCM435',  hrc_min: 36, hrc_max: 40, unit_wt: 0.21, pattern: 'Q-870/T-480', q_temp: 870, t_temp: 480, cycle_min: 75 },
    { prod_code: 'P1008', prod_name: '타이로드 엔드',     part_no: '56820-D3000', cust_code: 'C002', material: 'S48C',    hrc_min: 25, hrc_max: 30, unit_wt: 0.57, pattern: 'Q-840/T-580', q_temp: 840, t_temp: 580, cycle_min: 80 },
    { prod_code: 'P1009', prod_name: '피니언 샤프트',     part_no: '43160-3B500', cust_code: 'C006', material: 'SCM420H', hrc_min: 58, hrc_max: 62, unit_wt: 1.12, pattern: 'Q-880/T-170', q_temp: 880, t_temp: 170, cycle_min: 105 },
    { prod_code: 'P1010', prod_name: '스핀들 너트',       part_no: '51712-2H000', cust_code: 'C003', material: 'S45C',    hrc_min: 45, hrc_max: 50, unit_wt: 0.44, pattern: 'Q-840/T-350', q_temp: 840, t_temp: 350, cycle_min: 80 }
  ];

  D.workers = [
    { user_code: 1, user_id: 'ez',      user_name: '관리자', dept: '관리팀', position: '팀장', tel: '010-2231-5501' },
    { user_code: 2, user_id: 'kms0412', user_name: '김민수', dept: '생산팀', position: '반장', tel: '010-4412-8823' },
    { user_code: 3, user_id: 'ljh88',   user_name: '이정호', dept: '생산팀', position: '주임', tel: '010-5521-3390' },
    { user_code: 4, user_id: 'psj21',   user_name: '박성진', dept: '품질팀', position: '대리', tel: '010-7783-1204' },
    { user_code: 5, user_id: 'cyh77',   user_name: '최영훈', dept: '설비팀', position: '과장', tel: '010-3346-9071' },
    { user_code: 6, user_id: 'jdh03',   user_name: '정대현', dept: '생산팀', position: '사원', tel: '010-6610-2245' },
    { user_code: 7, user_id: 'yjs92',   user_name: '윤재석', dept: '품질팀', position: '사원', tel: '010-9024-5518' },
    { user_code: 8, user_id: 'jhw15',   user_name: '장현우', dept: '설비팀', position: '주임', tel: '010-2759-6632' }
  ];
  D.shiftWorker = function (dateStr, hour) { // 주/야간 근무자
    var day = hour >= 8 && hour < 20;
    var r = M.rng('shift' + dateStr);
    return day ? r.pick(['김민수', '이정호']) : r.pick(['정대현', '이정호']);
  };

  // 설비 (연속 열처리 라인)
  D.equipments = [
    { equip_code: 'E01', equip_name: '연속열처리로', equip_type: '열처리 연속로', maker: '대한로공업', install_date: '2019-04-15', location: '1공장 A동' },
    { equip_code: 'E02', equip_name: '소입로',       equip_type: '열처리 연속로', maker: '대한로공업', install_date: '2019-04-15', location: '1공장 A동' },
    { equip_code: 'E03', equip_name: '소려로',       equip_type: '열처리 연속로', maker: '대한로공업', install_date: '2019-04-15', location: '1공장 A동' },
    { equip_code: 'E04', equip_name: '세척 1호기',   equip_type: '세척기',       maker: '세진테크',   install_date: '2020-02-10', location: '1공장 A동' },
    { equip_code: 'E05', equip_name: '세척 2호기',   equip_type: '세척기',       maker: '세진테크',   install_date: '2021-07-22', location: '1공장 A동' },
    { equip_code: 'E06', equip_name: '유조(소입유)', equip_type: '공용설비',     maker: '대한로공업', install_date: '2019-04-15', location: '1공장 A동' },
    { equip_code: 'E07', equip_name: '방청기',       equip_type: '공용설비',     maker: '한림기계',   install_date: '2020-11-03', location: '1공장 B동' },
    { equip_code: 'E08', equip_name: 'RX 가스발생기', equip_type: '공용설비',    maker: '동양가스텍', install_date: '2019-05-02', location: '1공장 A동' }
  ];

  // 온도 존 설정값/현재값 기준
  D.zones = {
    quench: [{ name: '소입로1존', sv: 850 }, { name: '소입로2존', sv: 860 }, { name: '소입로3존', sv: 860 }, { name: '소입로4존', sv: 860 }, { name: '소입로5존', sv: 850 }],
    temper: [{ name: '소려로1존', sv: 450 }, { name: '소려로2존', sv: 460 }, { name: '소려로3존', sv: 460 }, { name: '소려로4존', sv: 455 }, { name: '소려로5존', sv: 450 }]
  };

  D.product = function (code) { for (var i = 0; i < D.products.length; i++) if (D.products[i].prod_code === code) return D.products[i]; return D.products[0]; };
  D.customer = function (code) { for (var i = 0; i < D.customers.length; i++) if (D.customers[i].cust_code === code) return D.customers[i]; return D.customers[0]; };

  /*
   * 3일치 LOT 흐름 (그제 08:00 ~ 현재). 연속로라 LOT가 끊기지 않고 이어진다.
   *   lot_no, prod_code, prod_name, part_no, cust_name, material, qty, weight(kg),
   *   start_time, end_time('' = 진행중), status('완료'|'진행중'|'대기'), worker, work_date,
   *   hardness(평균 HRC), result('합격'|'불합격'), q_temp, t_temp
   * 미래(대기) LOT도 2건 붙인다.
   */
  var _lots = null;
  D.lots = function () {
    if (_lots) return _lots;
    var days = M.days();
    var t = M.toDate(days[0] + ' 08:00:00');
    var now = new Date();
    var out = [], seq = {}, i = 0;
    var r = M.rng('chunil-lots-' + days[0]);
    var waiting = 0;
    while (waiting < 2) {
      var p = D.products[r.int(0, D.products.length - 1)];
      var c = D.customer(p.cust_code);
      var dur = p.cycle_min + r.int(-5, 15);
      var end = new Date(t.getTime() + dur * 60000);
      var dkey = M.fmt(t, 'YYMMDD');
      seq[dkey] = (seq[dkey] || 0) + 1;
      var qty = Math.round(r.int(600, 1400) / (p.unit_wt > 1 ? 2 : 1) / 10) * 10;
      var status = end <= now ? '완료' : (t <= now ? '진행중' : '대기');
      if (status === '대기') waiting++;
      var mid = (p.hrc_min + p.hrc_max) / 2;
      var hard = M.round(r.normal(mid, (p.hrc_max - p.hrc_min) / 7), 1);
      out.push({
        idx: ++i,
        lot_no: 'CH' + dkey + '-' + M.pad(seq[dkey], 3),
        work_date: M.fmt(t, 'YYYY-MM-DD'),
        prod_code: p.prod_code, prod_name: p.prod_name, part_no: p.part_no, material: p.material,
        cust_code: c.cust_code, cust_name: c.cust_name,
        qty: qty, weight: M.round(qty * p.unit_wt, 1),
        start_time: M.fmt(t), end_time: status === '완료' ? M.fmt(end) : '',
        plan_end_time: M.fmt(end),
        status: status,
        worker: D.shiftWorker(M.fmt(t, 'YYYY-MM-DD'), t.getHours()),
        pattern: p.pattern, q_temp: p.q_temp, t_temp: p.t_temp,
        hrc_min: p.hrc_min, hrc_max: p.hrc_max,
        hardness: status === '완료' ? hard : null,
        result: status === '완료' ? (hard < p.hrc_min || hard > p.hrc_max ? '불합격' : '합격') : ''
      });
      t = new Date(end.getTime() + r.int(3, 12) * 60000);
    }
    _lots = out;
    return out;
  };
  D.lotsIn = function (from, to) {
    return D.lots().filter(function (l) { return l.status !== '대기' && M.inRange(l.start_time, from, to); });
  };
  D.currentLot = function () {
    var ls = D.lots();
    for (var i = 0; i < ls.length; i++) if (ls[i].status === '진행중') return ls[i];
    return ls[ls.length - 1];
  };

  // 알람 마스터 (연속로 공통)
  D.alarmCodes = [
    { code: 'AL-101', name: '소입로 온도 상한 초과', level: '중' },
    { code: 'AL-102', name: '소입로 온도 하한 미달', level: '중' },
    { code: 'AL-111', name: '소려로 온도 편차 경보', level: '경' },
    { code: 'AL-201', name: '소입유 온도 상승', level: '중' },
    { code: 'AL-202', name: '소입유 교반기 과부하', level: '중' },
    { code: 'AL-301', name: '메쉬벨트 사행 감지', level: '경' },
    { code: 'AL-302', name: '메쉬벨트 모터 과전류', level: '중' },
    { code: 'AL-401', name: 'RX가스 유량 저하', level: '중' },
    { code: 'AL-402', name: '노내 압력 이상', level: '중' },
    { code: 'AL-501', name: '세척기 액온 저하', level: '경' },
    { code: 'AL-502', name: '세척기 수위 저하', level: '경' },
    { code: 'AL-601', name: '비상정지 버튼 동작', level: '중' },
    { code: 'AL-701', name: '열전대 단선', level: '중' },
    { code: 'AL-801', name: '방청액 농도 이탈', level: '경' }
  ];

  /*
   * [C1] 3일치 비가동(정지) 이력 — 설비비가동현황/가동률/설비이력이 공유. 다른 화면도 재사용 가능.
   *   non_time_idx, equipment_name('열처리 연속로'), sub_equip, info_list('계획정지'|'설비고장'|'제품이상조치'|'기타'),
   *   start_time/end_time('YYYY-MM-DD HH:mm', 진행중이면 end_time=''), minutes, alarm_code, non_time_memo, worker
   */
  D.downtimes = function () {
    var days = M.days(), now = new Date(), out = [], idx = 0;
    var plan = [
      [ // 그제
        ['01:40', 26, '기타', '세척 1호기', '', '야간 세척기 세척액 보충 및 액온 회복 대기 (설정 60℃, 실측 52℃)', '정대현'],
        ['08:20', 18, '계획정지', '연속열처리로', '', '주간 일상점검 — 메쉬벨트 장력/사행 확인, 소입유조 레벨 점검', '김민수'],
        ['11:35', 47, '설비고장', '소입로', 'AL-701', '소입로 3존 열전대(K-type) 단선 알람 → 예비품 교체 후 온도 안정화 확인 (SP-TC-001 사용)', '장현우'],
        ['15:05', 42, '기타', '소려로', '', '품종 교체 — 패턴 Q-880/T-170 → Q-850/T-600 변경, 소려로 승온 대기', '이정호'],
        ['21:30', 22, '제품이상조치', '연속열처리로', '', '경도 상한 근접 LOT 샘플 재측정, CP 0.05% 하향 조정 후 재가동', '정대현']
      ],
      [ // 어제
        ['03:10', 35, '설비고장', '연속열처리로', 'AL-302', '메쉬벨트 구동모터 과전류 트립 → 체인 장력 조정 및 모터 전류 확인 (정격 대비 92%)', '정대현'],
        ['08:15', 20, '계획정지', '연속열처리로', '', '주간 일상점검 — 열전대 지시값 비교, RX가스 유량 확인', '김민수'],
        ['10:40', 95, '계획정지', '유조(소입유)', '', '월간 PM — 소입유 필터 엘리먼트 교체 및 교반기 베어링 그리스 주입', '최영훈'],
        ['16:20', 28, '제품이상조치', '방청기', 'AL-801', '방청액 농도 이탈(8.1%) → 원액 보충 후 농도 10% 재조정, 해당 바스켓 재방청', '이정호'],
        ['22:45', 15, '기타', '연속열처리로', '', '한전 순간정전(0.3초) → UPS 전환, 노 압력/가스 정상 확인 후 재가동', '정대현']
      ],
      [ // 오늘
        ['02:25', 31, '설비고장', 'RX 가스발생기', 'AL-401', 'RX가스 유량 저하 알람 → 공기/LPG 혼합비 재조정, 노점 -2℃ 회복 확인', '정대현'],
        ['08:10', 22, '계획정지', '연속열처리로', '', '주간 일상점검 — 메쉬벨트 사행, 소입유 온도(70℃) 및 레벨 점검', '김민수'],
        ['10:05', 38, '기타', '소입로', '', '품종 교체 — 트랜스미션 기어(Q-880) 투입 전 소입로 승온 및 CP 안정화 대기', '이정호'],
        ['13:50', 24, '제품이상조치', '세척 2호기', 'AL-502', '세척기 수위 저하로 잔유 세척 불량 우려 → 급수 밸브 점검, 해당 바스켓 재세척', '장현우'],
        ['17:30', 55, '설비고장', '소입로', 'AL-202', '소입유 교반기 과부하 → 교반기 모터 커플링 이완 확인 및 체결, 시운전 이상 없음', '최영훈'],
        ['21:15', 18, '기타', '연속열처리로', '', '야간 교대 인수인계 중 투입 대기 (원자재 미입고)', '정대현']
      ]
    ];
    plan.forEach(function (list, di) {
      list.forEach(function (p) {
        var st = M.toDate(days[di] + ' ' + p[0] + ':00');
        if (st > now) return;
        var en = M.addMinutes(st, p[1]);
        var running = en > now;
        out.push({
          non_time_idx: ++idx,
          equipment_name: '열처리 연속로', standard_code: '열처리 연속로',
          sub_equip: p[3], info_list: p[2], alarm_code: p[4],
          start_time: M.fmt(st, 'YYYY-MM-DD HH:mm'),
          end_time: running ? '' : M.fmt(en, 'YYYY-MM-DD HH:mm'),
          minutes: running ? Math.floor((now - st) / 60000) : p[1],
          non_time_memo: '[' + p[3] + '] ' + p[5], worker: p[6]
        });
      });
    });
    return out;
  };

  /*
   * [C2] 연속로 라인 통과 시각 (LOT트레킹/통합모니터링/트렌드 공용)
   *   D.lineStages: [필드, 투입시작(d370) 기준 분]. D.lineTimes(lot) → {필드: Date}
   *   regtime(작업등록) · d370(투입시작) · x111(투입종료) · 공정별 도착 · l20(로트종료)
   */
  D.lineStages = [
    ['start_hoper_2', 0], ['f_wash_3', 6.5], ['qf1_4', 7.5], ['qf2_5', 24.3], ['qf3_6', 41.1], ['qf4_7', 57.9], ['qf5_8', 74.7],
    ['oil_9', 91.5], ['m_wash_10', 98.8], ['tf1_11', 106.4], ['tf2_12', 133.4], ['tf3_13', 160.4], ['tf4_14', 187.4], ['tf5_15', 214.4],
    ['bch_16', 241.4], ['con_17', 254.9], ['l20', 269.9]
  ];
  D.lineTimes = function (lot) {
    var s = M.toDate(lot.start_time), r = M.rng('reg' + lot.lot_no), o = {};
    o.regtime = M.addMinutes(s, -r.int(18, 45));
    o.d370 = s;
    o.x111 = M.toDate(lot.plan_end_time);
    D.lineStages.forEach(function (st) { o[st[0]] = new Date(s.getTime() + st[1] * 60000); });
    return o;
  };

  /*
   * [C2] 3일치 알람 이력 (알람이력/알람랭킹/종합생산현황/통합모니터링 공용) — 최신순
   *   {a_code, a_addr, a_desc, a_level, a_stime, a_etime('' = 진행중), dur_min}
   *   D.downtimes() 의 alarm_code 건도 같은 시각으로 포함한다.
   */
  D.alarmAddr = function (code) { return 'M' + (1000 + parseInt(String(code).replace(/\D/g, ''), 10)); };
  D.alarms = function () {
    var days = M.days(), now = new Date(), out = [];
    var W = { 'AL-111': 9, 'AL-501': 7, 'AL-301': 6, 'AL-502': 5, 'AL-801': 4, 'AL-201': 4, 'AL-101': 3, 'AL-102': 3,
      'AL-401': 2, 'AL-402': 2, 'AL-302': 2, 'AL-202': 2, 'AL-701': 1, 'AL-601': 1 };
    var bag = [];
    D.alarmCodes.forEach(function (c) { for (var k = 0; k < (W[c.code] || 1); k++) bag.push(c); });
    function code(c) { for (var i = 0; i < D.alarmCodes.length; i++) if (D.alarmCodes[i].code === c) return D.alarmCodes[i]; return D.alarmCodes[0]; }
    function push(c, st, durMin) {
      if (st > now) return;
      var en = new Date(st.getTime() + durMin * 60000);
      var act = en > now;
      out.push({ a_code: c.code, a_addr: D.alarmAddr(c.code), a_desc: c.name, a_level: c.level,
        a_stime: M.fmt(st), a_etime: act ? '' : M.fmt(en), dur_min: act ? M.round((now - st) / 60000, 1) : M.round(durMin, 1) });
    }
    days.forEach(function (day) {
      var r = M.rng('alarms-' + day), n = r.int(16, 22), base = M.toDate(day + ' 00:00:00').getTime();
      for (var i = 0; i < n; i++) {
        var c = r.pick(bag);
        var st = new Date(base + r.int(0, 86399) * 1000);
        var dur = c.level === '경' ? r.float(0.8, 12) : Math.min(45, 2 + -Math.log(1 - r()) * 9);
        push(c, st, dur);
      }
    });
    (D.downtimes ? D.downtimes() : []).forEach(function (d) {
      if (!d.alarm_code) return;
      var st = M.addMinutes(M.toDate(d.start_time), -1);
      push(code(d.alarm_code), new Date(st.getTime() + 17000), d.end_time ? d.minutes - 3 : 9999);
    });
    // 현재 진행중 알람 2건 (1시간 단위로 고정)
    var anchor = Math.floor(now.getTime() / 3600000) * 3600000;
    push(code('AL-111'), new Date(anchor - 23 * 60000 - 14000), 9999);
    push(code('AL-501'), new Date(anchor - 51 * 60000 - 41000), 9999);
    out.sort(function (a, b) { return a.a_stime < b.a_stime ? 1 : -1; });
    return out;
  };
})();
