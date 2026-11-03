/* y3-condition-quality.js — 조건관리(열전대/센서·조절계·열처리유·일상점검·설비점검표·표준서) + 품질관리(CPK/PPK·F/PROOF·TUS·경도측정·부적합)
 * 모든 날짜는 접속일 기준. LOT 흐름은 MOCK.D.lots() 를 따른다.
 */
(function () {
  'use strict';
  var M = window.MOCK, D = M.D;
  var ok = D.ok;
  var NOW = new Date();
  var T0 = Date.now();
  var TODAY = M.fmt(NOW, 'YYYY-MM-DD');
  var CUR_YM = TODAY.slice(0, 7);
  var TODAY_NUM = NOW.getDate();
  var CY = NOW.getFullYear();
  var FN = D.furnaces;

  function ymd(d) { return M.fmt(d, 'YYYY-MM-DD'); }
  function iso(d) { return M.fmt(d, 'YYYY-MM-DDTHH:mm:ss'); }
  function addD(s, n) { return ymd(M.addDays(M.toDate(s), n)); }
  function addY(s, n) { var d = M.toDate(s); var m = d.getMonth(); d.setFullYear(d.getFullYear() + n); if (d.getMonth() !== m) d.setDate(0); return ymd(d); }
  function idList(req) { var b = req.body; if (Array.isArray(b)) return b.map(String); if (b && Array.isArray(b.ids)) return b.ids.map(String); return []; }
  function arr(v) { return v == null ? [] : Array.isArray(v) ? v : [v]; }
  function num(v) { return v === '' || v == null || isNaN(+v) ? null : +v; }
  function clone(o) { return JSON.parse(JSON.stringify(o)); }
  function nowStr() { return M.fmt(new Date()); }
  function fileOf(f) { return f && typeof f === 'object' && f.fileName ? f : null; }
  function bad(msg) { return M.res(400, D.fail(msg, 'INVALID_PARAMETER')); }
  function furnByName(n) { for (var i = 0; i < FN.length; i++) if (FN[i].name === n) return FN[i]; return null; }
  function furnByCode(c) { for (var i = 0; i < FN.length; i++) if (FN[i].code === c) return FN[i]; return null; }
  function daysInYm(ym) { var p = ym.split('-'); return new Date(+p[0], +p[1], 0).getDate(); }
  function ymAdd(ym, n) { var p = ym.split('-'); return M.fmt(new Date(+p[0], +p[1] - 1 + n, 1), 'YYYY-MM'); }

  /* ═══════════════════ 불량 구분 (master에 공유) ═══════════════════ */
  if (!D.defectTypes) {
    D.defectTypes = [
      ['D01', '경도불량'], ['D02', '변형'], ['D03', '크랙'], ['D04', '찍힘'], ['D05', '스케일'], ['D06', '이종혼입']
    ].map(function (a, i) { return { defectId: i + 1, defectCode: a[0], defectName: a[1], sortOrder: i + 1, useYn: 'Y' }; });
  }

  /* ═══════════════════ 조건관리 > 열전대/센서 관리 ═══════════════════ */
  var TC_ZONES = ['퀜칭로 1존', '퀜칭로 2존', '퀜칭로 3존', '퀜칭로 4존', '퀜칭로 5존', '템퍼링로 1존', '템퍼링로 2존', '템퍼링로 3존', '템퍼링로 4존', '템퍼링로 5존'];
  var SENSORS = ['CP 센서(산소 프로브)', '퀜칭유 온도센서', '퀜칭유 레벨센서', '로내 압력센서'];
  var SENSOR_REMARK = {
    'CP 센서(산소 프로브)': ['지르코니아 산소 프로브 교체 · 교정가스(N₂/공기) 확인', '프로브 교체 · 버너아웃 주기 재설정'],
    '퀜칭유 온도센서': ['PT100Ω 3선식 교체', 'PT100Ω 교체 · 보호관 세척'],
    '퀜칭유 레벨센서': ['플로트식 레벨스위치 교체', '레벨스위치 교체 · 접점 점검'],
    '로내 압력센서': ['차압 트랜스미터 교체 · 영점 조정', '압력 트랜스미터 교체']
  };
  var TC_REMARK = ['K타입 Φ8×600 교체', 'K타입 Φ8×600 · 보호관(SUS310S) 함께 교체', '정기 교체', 'N타입 Φ10×800 교체', '지시값 편차(+3℃) 확인되어 교체', '정기 교체 · 단자대 정리', ''];
  // 교체 시기가 다가온 항목(알림 팝업): 키 → 오늘 기준 차기교체일까지 남은 날
  var SENSOR_DUE = { 'MBF2|퀜칭로 3존': -3, 'MBF4|퀜칭로 4존': 2, 'MBF5|템퍼링로 2존': 5 };
  var sensorDb = M.db('y3_sensor', function () {
    var rows = [], id = 1;
    FN.forEach(function (f) {
      TC_ZONES.map(function (z) { return ['열전대', z]; }).concat(SENSORS.map(function (z) { return ['센서', z]; })).forEach(function (k) {
        var type = k[0], zone = k[1];
        var r = M.rng('y3sen|' + f.code + '|' + zone);
        var cyc = type === '열전대' ? 1 : 2;
        var due = SENSOR_DUE[f.code + '|' + zone];
        var nextLatest = addD(TODAY, due != null ? due : r.int(14, cyc * 365 - 20));
        var changes = [addY(nextLatest, -cyc)];
        for (var i = 1; i < 5; i++) changes.push(addD(addY(changes[i - 1], -cyc), r.int(-12, 8)));
        for (var j = changes.length - 2; j >= 0; j--) {
          var ch = changes[j], y = +ch.slice(0, 4);
          if (y < CY - 3) continue;
          rows.push({
            id: id++, year: y, equipName: f.name, sensorType: type, zoneName: zone,
            prevChangeDate: changes[j + 1], changeDate: ch, nextChangeDate: j === 0 ? nextLatest : addY(ch, cyc),
            regUserName: r.pick(['정용호', '오동석']),
            remark: type === '열전대' ? r.pick(TC_REMARK) : r.pick(SENSOR_REMARK[zone]),
            regDt: ch + ' 16:' + M.pad(r.int(0, 59)) + ':00'
          });
        }
      });
    });
    return rows;
  }, 'id');
  function sensorOrder(r) {
    var zi = TC_ZONES.indexOf(r.zoneName); if (zi < 0) zi = 20 + SENSORS.indexOf(r.zoneName);
    return r.equipName + '|' + (r.sensorType === '열전대' ? 0 : 1) + '|' + M.pad(zi + 1, 3);
  }
  M.get('/api/condition/sensor', function (req) {
    var q = req.params;
    var list = sensorDb.all().filter(function (r) {
      return (!q.year || +r.year === +q.year) && (!q.sensorType || r.sensorType === q.sensorType);
    }).sort(function (a, b) { return sensorOrder(a) < sensorOrder(b) ? -1 : 1; });
    return ok(list);
  });
  function sensorPrev(row) {
    var prev = '';
    sensorDb.all().forEach(function (r) {
      if (r.id !== row.id && r.equipName === row.equipName && r.zoneName === row.zoneName && r.sensorType === row.sensorType &&
        r.changeDate && (!row.changeDate || r.changeDate < row.changeDate) && r.changeDate > prev) prev = r.changeDate;
    });
    return prev || null;
  }
  M.post('/api/condition/sensor', function (req) {
    var b = req.body || {};
    var row = { id: null, year: +b.year || CY, equipName: b.equipName, sensorType: b.sensorType, zoneName: b.zoneName, changeDate: b.changeDate || null, nextChangeDate: b.nextChangeDate || null, remark: b.remark || '', regUserName: b.regUserName || '관리자', regDt: nowStr() };
    row = sensorDb.insert(row);
    sensorDb.update(row.id, { prevChangeDate: sensorPrev(row) });
    return ok(sensorDb.find(row.id));
  });
  M.post('/api/condition/sensor/delete', function (req) { sensorDb.remove(idList(req)); return ok(null); });
  M.put('/api/condition/sensor/:id', function (req) {
    var b = req.body || {}, cur = sensorDb.find(req.params.id);
    if (!cur) return M.res(404, D.fail('대상을 찾을 수 없습니다.'));
    sensorDb.update(cur.id, { year: +b.year || cur.year, equipName: b.equipName, sensorType: b.sensorType, zoneName: b.zoneName, changeDate: b.changeDate || null, nextChangeDate: b.nextChangeDate || null, remark: b.remark || '' });
    sensorDb.update(cur.id, { prevChangeDate: sensorPrev(sensorDb.find(cur.id)) });
    return ok(sensorDb.find(cur.id));
  });

  /* ═══════════════════ 조건관리 > 조절계 관리 ═══════════════════ */
  var Q_STD = [860, 880, 900, 900, 850];
  var ctrlDb = M.db('y3_ctrl', function () {
    var rows = [], id = 1;
    for (var y = CY - 3; y <= CY; y++) {
      FN.forEach(function (f) {
        TC_ZONES.forEach(function (z, zi) {
          var r = M.rng('y3ctrl|' + y + f.code + z);
          var std = zi < 5 ? Q_STD[zi] : (f.no % 2 ? (zi === 9 ? 440 : 450) : (zi === 9 ? 170 : 180));
          var meas = M.round(std + r.normal(0, 0.9), 1);
          var h1 = [], h2 = [];
          var tag = f.code + '_' + z.replace(/\s/g, '');
          var rowId = id++;
          h1.push({ id: rowId * 10 + 1, origFileName: tag + '_' + y + '_상반기_교정성적서.pdf', fileSize: r.int(180, 420) * 1024 + r.int(0, 1000) });
          if (r.chance(0.3)) h1.push({ id: rowId * 10 + 2, origFileName: tag + '_' + y + '_상반기_측정사진.jpg', fileSize: r.int(900, 2400) * 1024 });
          var h2Done = y < CY || (f.code !== 'MBF6' && !(f.code === 'MBF4' && zi >= 5));
          if (h2Done) h2.push({ id: rowId * 10 + 3, origFileName: tag + '_' + y + '_하반기_교정성적서.pdf', fileSize: r.int(180, 420) * 1024 + r.int(0, 1000) });
          rows.push({
            id: rowId, calibYear: y, equipName: f.name, zoneName: z, stdTemp: std, measTemp: meas, deviation: M.round(meas - std, 1),
            h1Files: h1, h2Files: h2, regUserName: r.pick(['정용호', '오동석']), regDt: y + '-0' + r.int(3, 5) + '-' + M.pad(r.int(2, 27)) + ' 15:' + M.pad(r.int(0, 59)) + ':00'
          });
        });
      });
    }
    return rows;
  }, 'id');
  function ctrlOut(r) {
    var o = clone(r); o.h1FileCount = (r.h1Files || []).length; o.h2FileCount = (r.h2Files || []).length; return o;
  }
  M.get('/api/condition/controller', function (req) {
    var q = req.params;
    return ok(ctrlDb.all().filter(function (r) { return (!q.year || +r.calibYear === +q.year) && (!q.equipName || r.equipName === q.equipName); })
      .map(function (r) { var o = ctrlOut(r); delete o.h1Files; delete o.h2Files; return o; }));
  });
  M.get('/api/condition/controller/equipNames', function () {
    var s = {}; ctrlDb.all().forEach(function (r) { s[r.equipName] = 1; }); return ok(Object.keys(s).sort());
  });
  M.get('/api/condition/controller/:id', function (req) { var r = ctrlDb.find(req.params.id); return r ? ok(ctrlOut(r)) : M.res(404, D.fail('대상을 찾을 수 없습니다.')); });
  function ctrlFiles(list, half, keep, rowId) {
    var kept = (list || []).filter(function (f) { return keep.indexOf(String(f.id)) >= 0; });
    return kept;
  }
  function ctrlSave(req, cur) {
    var b = req.body || {};
    var std = num(b.stdTemp), meas = num(b.measTemp);
    var row = cur ? clone(cur) : { id: null, h1Files: [], h2Files: [], regUserName: b.regUserName || '관리자', regDt: nowStr() };
    row.calibYear = +b.calibYear || CY; row.equipName = b.equipName; row.zoneName = b.zoneName;
    row.stdTemp = std; row.measTemp = meas; row.deviation = std != null && meas != null ? M.round(meas - std, 1) : null;
    if (cur) { var keep = arr(b.keepFileIds).map(String); row.h1Files = ctrlFiles(cur.h1Files, 'H1', keep); row.h2Files = ctrlFiles(cur.h2Files, 'H2', keep); }
    var seed = Date.now();
    arr(b.h1Files).map(fileOf).filter(Boolean).forEach(function (f, i) { row.h1Files.push({ id: seed + i, origFileName: f.fileName, fileSize: f.size }); });
    arr(b.h2Files).map(fileOf).filter(Boolean).forEach(function (f, i) { row.h2Files.push({ id: seed + 100 + i, origFileName: f.fileName, fileSize: f.size }); });
    return cur ? ctrlDb.update(cur.id, row) : ctrlDb.insert(row);
  }
  M.post('/api/condition/controller', function (req) { return ok(ctrlOut(ctrlSave(req, null))); });
  M.post('/api/condition/controller/delete', function (req) { ctrlDb.remove(idList(req)); return ok(null); });
  M.put('/api/condition/controller/:id', function (req) { var cur = ctrlDb.find(req.params.id); return cur ? ok(ctrlOut(ctrlSave(req, cur))) : M.res(404, D.fail('대상을 찾을 수 없습니다.')); });

  /* ═══════════════════ 조건관리 > 열처리유 성상분석 ═══════════════════ */
  var oilDb = M.db('y3_oil', function () {
    var rows = [], id = 1;
    FN.forEach(function (f) {
      var r0 = M.rng('y3oil|' + f.code);
      var off = r0.int(3, 40);
      for (var q = 0; q < 9; q++) {
        var r = M.rng('y3oil|' + f.code + '|' + q);
        var cr = addD(TODAY, -(off + q * 91 + r.int(-6, 6)));
        var visc = M.round(r.normal(22.0, 0.6), 1), water = r.int(60, 260), tan = M.round(r.float(0.04, 0.16), 2), flash = r.int(196, 212);
        var memo = '동점도 ' + visc + ' cSt(40℃) · 수분 ' + water + ' ppm · 전산가 ' + tan + ' mgKOH/g · 인화점 ' + flash + '℃ — 적합';
        if (f.code === 'MBF4' && q === 0) memo = '동점도 23.6 cSt(40℃) · 수분 520 ppm · 전산가 0.21 mgKOH/g — 수분 관리기준(500 ppm) 초과, 탈수 처리 후 재분석 예정';
        if (f.code === 'MBF2' && q === 4) memo = '열처리유 전량 교환 후 초기 분석 · 동점도 21.4 cSt(40℃) · 수분 45 ppm — 적합';
        var tag = f.code + '_' + cr.replace(/-/g, '');
        var regDt = addD(cr, r.int(5, 9)); if (regDt > TODAY) regDt = TODAY;
        var row = {
          id: id++, crDate: cr, mchName: f.name, memo: memo,
          box1FileName: 'oil_' + tag + '_1.pdf', box1OrigFileName: '성상분석보고서_' + tag + '.pdf', box1FileSize: r.int(240, 680) * 1024,
          box2FileName: 'oil_' + tag + '_2.pdf', box2OrigFileName: '냉각성능곡선_' + tag + '.pdf', box2FileSize: r.int(150, 400) * 1024,
          box3FileName: null, box3OrigFileName: null, box3FileSize: null,
          box4FileName: null, box4OrigFileName: null, box4FileSize: null,
          regDt: regDt + ' 1' + r.int(0, 7) + ':' + M.pad(r.int(0, 59)) + ':00'
        };
        if (r.chance(0.3)) { row.box3FileName = 'oil_' + tag + '_3.pdf'; row.box3OrigFileName = '시료채취_기록지_' + tag + '.pdf'; row.box3FileSize = r.int(80, 200) * 1024; }
        rows.push(row);
      }
    });
    return rows;
  }, 'id');
  M.get('/api/condition/oilAnalysis', function (req) {
    var q = req.params;
    return ok(oilDb.all().filter(function (r) { return M.inRange(r.crDate, q.from, q.to) && (!q.mchName || r.mchName === q.mchName); })
      .sort(function (a, b) { return a.crDate === b.crDate ? (a.mchName < b.mchName ? -1 : 1) : (a.crDate < b.crDate ? 1 : -1); }));
  });
  M.get('/api/condition/oilAnalysis/mchNames', function () { var s = {}; oilDb.all().forEach(function (r) { s[r.mchName] = 1; }); return ok(Object.keys(s).sort()); });
  M.get('/api/condition/oilAnalysis/:id', function (req) { var r = oilDb.find(req.params.id); return r ? ok(r) : M.res(404, D.fail('대상을 찾을 수 없습니다.')); });
  function oilSave(req, cur) {
    var b = req.body || {};
    var row = cur ? clone(cur) : { id: null, regDt: nowStr() };
    row.crDate = b.crDate; row.mchName = b.mchName; row.memo = b.memo || '';
    for (var n = 1; n <= 4; n++) {
      var f = fileOf(b['box' + n]);
      if (f) { row['box' + n + 'FileName'] = 'oil_new_' + Date.now() + '_' + n + '.pdf'; row['box' + n + 'OrigFileName'] = f.fileName; row['box' + n + 'FileSize'] = f.size; }
      else if (!cur) { row['box' + n + 'FileName'] = null; row['box' + n + 'OrigFileName'] = null; row['box' + n + 'FileSize'] = null; }
    }
    return cur ? oilDb.update(cur.id, row) : oilDb.insert(row);
  }
  M.post('/api/condition/oilAnalysis', function (req) { return ok(oilSave(req, null)); });
  M.put('/api/condition/oilAnalysis/:id', function (req) { var cur = oilDb.find(req.params.id); return cur ? ok(oilSave(req, cur)) : M.res(404, D.fail('대상을 찾을 수 없습니다.')); });
  M.del('/api/condition/oilAnalysis/:id', function (req) { oilDb.remove(req.params.id); return ok(null); });

  /* ═══════════════════ 조건관리 > 일상점검일지 ═══════════════════ */
  var DC_ITEMS = [
    ['RX 가스발생기 노점 확인', '관리기준 -2 ~ +2 ℃(DP)', 'number', function (r) { return M.round(r.normal(-0.4, 0.6), 1).toFixed(1); }],
    ['퀜칭유 온도', '관리기준 60 ~ 80 ℃', 'number', function (r) { return String(r.int(64, 76)); }],
    ['퀜칭유 레벨 확인', '레벨게이지 기준선 이상', 'check'],
    ['로내 압력', '관리기준 +10 ~ +20 mmAq', 'number', function (r) { return String(r.int(12, 18)); }],
    ['메쉬벨트 장력 · 사행 상태', '육안 점검(좌우 사행 20mm 이내)', 'check'],
    ['버너 · 히터 이상 유무', '점화 상태, 이상음, 단선 경보', 'check'],
    ['냉각수 온도', '관리기준 25 ~ 35 ℃', 'number', function (r) { return String(r.int(26, 32)); }],
    ['공압(에어) 압력', '관리기준 5.0 ~ 7.0 kgf/㎠', 'number', function (r) { return M.round(r.float(5.6, 6.4), 1).toFixed(1); }],
    ['세척기 세척액 농도', '관리기준 2 ~ 4 %', 'number', function (r) { return M.round(r.float(2.4, 3.6), 1).toFixed(1); }],
    ['비상정지 스위치 작동', '작동 및 복귀 확인', 'check'],
    ['화염커튼 · 배기 후드 점화', '장입/추출구 화염커튼 점화 유지', 'check'],
    ['작업장 정리정돈(5S)', '통로 확보, 소화기 위치', 'check'],
    ['특이사항', '교대 인수인계 내용', 'text']
  ];
  var DC_TEXT = ['이상 없음', '이상 없음', '이상 없음', '4호기 퀜칭로 3존 온도 알람 — 보전팀 통보', '6호기 정기 점검(벨트 교체) 진행', '야간조 인수인계 완료', '이상 없음'];
  function dcDb(ym) {
    return M.db('y3_daily_' + ym, function () {
      var base = +ym.replace('-', '') * 100;
      var last = ym < CUR_YM ? daysInYm(ym) : ym === CUR_YM ? TODAY_NUM : 0;
      return DC_ITEMS.map(function (it, i) {
        var row = { cnt: base + i + 1, dTitle: it[0], dDesc: it[1], valueType: it[2], dBigo: '', imgUrl: null };
        for (var d = 1; d <= 31; d++) {
          var key = 'd' + M.pad(d);
          if (d > last) { row[key] = ''; continue; }
          var r = M.rng('y3dc|' + ym + '|' + i + '|' + d);
          if (it[2] === 'check') row[key] = r.chance(0.012) ? 'NG' : 'OK';
          else if (it[2] === 'number') row[key] = it[3](r);
          else row[key] = ym === CUR_YM && d === TODAY_NUM && TODAY_NUM > 0 ? '4호기 퀜칭로 3존 온도 알람 — 보전팀 통보' : r.pick(DC_TEXT);
          if (row[key] === 'NG') row.dBigo = d + '일 NG — 즉시 조치 후 정상 확인';
        }
        return row;
      });
    }, 'cnt');
  }
  function dcYmOf(cnt) { var s = String(Math.floor(+cnt / 100)); return s.slice(0, 4) + '-' + s.slice(4, 6); }
  var DC_FIELD = { d_title: 'dTitle', d_desc: 'dDesc', d_bigo: 'dBigo', value_type: 'valueType' };
  M.post('/api/condition/dailyCheck/list', function (req) { var ym = req.params.ym || CUR_YM; return ok(dcDb(ym).all().sort(function (a, b) { return a.cnt - b.cnt; })); });
  M.post('/api/condition/dailyCheck/update', function (req) {
    var p = req.params, db = dcDb(dcYmOf(p.cnt)), patch = {};
    patch[DC_FIELD[p.dField] || p.dField] = p.dValue == null ? '' : p.dValue;
    db.update(p.cnt, patch);
    return ok(1);
  });
  M.post('/api/condition/dailyCheck/insert', function (req) {
    var ym = req.params.ym || CUR_YM, db = dcDb(ym);
    var mx = +ym.replace('-', '') * 100; db.all().forEach(function (r) { if (r.cnt > mx) mx = r.cnt; });
    var row = { cnt: mx + 1, dTitle: '새 점검항목', dDesc: '', valueType: 'check', dBigo: '', imgUrl: null };
    for (var d = 1; d <= 31; d++) row['d' + M.pad(d)] = '';
    db.insert(row); return ok(1);
  });
  M.post('/api/condition/dailyCheck/delete', function (req) { dcDb(dcYmOf(req.params.cnt)).remove(req.params.cnt); return ok(1); });
  M.post('/api/condition/dailyCheck/uploadImage', function (req) {
    var p = req.params, f = fileOf(p.file);
    dcDb(dcYmOf(p.cnt)).update(p.cnt, { imgUrl: f ? f.fileName : 'upload.jpg' });
    return ok(f ? f.fileName : 'upload.jpg');
  });

  /* ═══════════════════ 조건관리 > 설비점검표 ═══════════════════ */
  var EC_LEGEND = JSON.stringify([{ mark: '○', label: '양호' }, { mark: '△', label: '수리' }, { mark: '□', label: '조정' }, { mark: 'X', label: '교환' }]);
  var EC_CYCLE = JSON.stringify([{ code: 'D', label: '매일' }, { code: 'W', label: '주 1회(월)' }, { code: 'M', label: '월 1회' }]);
  var EC_SIGN = JSON.stringify(['담당', '검토', '확인']);
  var EC_FOOT = '※ 이상 발견 시 즉시 설비보전팀(내선 231)에 연락하고 특기사항에 기록한다. 수치 항목은 측정값을 기록한다.';
  var EC_FURN_ITEMS = [
    ['퀜칭로', '로내 온도 지시값 · 설정값 확인', 'D'],
    ['퀜칭로', '버너 점화 · 화염 상태', 'D'],
    ['퀜칭로', '로내 압력 (mmAq)', 'D', 10, 20],
    ['분위기', 'CP 값 (%)', 'D', 0.7, 1.0],
    ['퀜칭조', '퀜칭유 온도 (℃)', 'D', 60, 80],
    ['퀜칭조', '교반기 작동 · 이음', 'D'],
    ['메쉬벨트', '벨트 사행 · 손상 여부', 'D'],
    ['메쉬벨트', '구동 모터 · 감속기 이음/진동', 'W'],
    ['템퍼링로', '순환팬 작동 · 진동', 'D'],
    ['냉각수', '냉각수 유량 · 누수', 'D'],
    ['배기', '화염커튼 · 배기 후드 점화', 'D'],
    ['전기', '제어반 내부 청결 · 발열', 'W'],
    ['안전', '비상정지 스위치 작동 시험', 'M']
  ];
  var EC_RX_ITEMS = [
    ['반응관', '반응관 온도 지시 확인', 'D'],
    ['가스', '노점(DP) 측정값 확인', 'D'],
    ['가스', '공기 · 원료가스(LNG) 비율 확인', 'D'],
    ['냉각', '냉각수 유량 (L/min)', 'D', 20, 40],
    ['공급', '변성가스 공급 압력 (kPa)', 'D', 100, 150],
    ['배관', '가스 배관 누설 점검(비눗물)', 'W'],
    ['안전', '가스 누설 경보기 작동', 'W'],
    ['촉매', '촉매 상태 · 교체 주기 확인', 'M']
  ];
  var EC_INSPECTOR = { 1: '김태성', 2: '박민재', 3: '김태성', 4: '최현우', 5: '박민재', 6: '최현우', 7: '오동석' };
  var ecSheetDb = M.db('y3_ec_sheet', function () {
    var rows = FN.map(function (f, i) {
      return { sheetId: i + 1, title: '설비점검표', equipName: f.name, modelNo: D.equipments[i].modelName + ' / ' + D.equipments[i].maker, legendJson: EC_LEGEND, cycleJson: EC_CYCLE, signJson: EC_SIGN, footerNote: EC_FOOT, sortOrder: i + 1, useYn: 'Y', regUserId: 'yhjung', regUserName: '정용호', regDt: '2025-12-15T10:20:00', updUserId: 'yhjung', updUserName: '정용호', updDt: '2026-01-05T09:12:00' };
    });
    rows.push({ sheetId: 7, title: '설비점검표', equipName: 'RX 가스발생기', modelNo: 'RX-150 / 동양가스텍', legendJson: EC_LEGEND, cycleJson: EC_CYCLE, signJson: EC_SIGN, footerNote: '※ 가스 누설 의심 시 즉시 원료가스 차단밸브를 잠그고 보전팀에 연락한다.', sortOrder: 7, useYn: 'Y', regUserId: 'yhjung', regUserName: '정용호', regDt: '2025-12-15T10:40:00', updUserId: 'yhjung', updUserName: '정용호', updDt: '2026-01-05T09:20:00' });
    return rows;
  }, 'sheetId');
  var ecItemDb = M.db('y3_ec_item', function () {
    var rows = [];
    ecSheetDb.all().forEach(function (s) {
      (s.sheetId === 7 ? EC_RX_ITEMS : EC_FURN_ITEMS).forEach(function (a, i) {
        rows.push({ itemId: s.sheetId * 100 + i + 1, sheetId: s.sheetId, location: a[0], itemName: a[1], cycle: a[2], rangeMin: a[3] == null ? null : a[3], rangeMax: a[4] == null ? null : a[4], photoName: null, photoType: null, seq: i + 1, useYn: 'Y', updDt: '2026-01-05T09:12:00' });
      });
    });
    return rows;
  }, 'itemId');
  var ecResDb = M.db('y3_ec_res', null, 'key');
  var ecMonthDb = M.db('y3_ec_month', null, 'key');
  var ecConfDb = M.db('y3_ec_conf', null, 'key');
  var ecNoteDb = M.db('y3_ec_note', null, 'key');

  function ecDow(ym, day) { var p = ym.split('-'); return new Date(+p[0], +p[1] - 1, day).getDay(); }
  function ecLastDay(ym) { return ym < CUR_YM ? daysInYm(ym) : ym === CUR_YM ? TODAY_NUM : 0; }
  // 오늘 점검 진행 — 1·2·3·6·7호기 완료, 4호기 일부, 5호기 아직
  function ecTodayLimit(sheetId) { return sheetId === 5 ? 0 : sheetId === 4 ? 7 : 99; }
  function ecBaseResult(item, ym, day) {
    if (item.sheetId > 7 || item.itemId % 100 > 20) return null; // 사용자가 추가한 항목/점검표는 기록 없음
    if (ym < '2025-12' || day > ecLastDay(ym)) return null;
    if (ym === CUR_YM && day === TODAY_NUM && (item.itemId % 100) > ecTodayLimit(item.sheetId)) return null;
    var dow = ecDow(ym, day);
    if (item.cycle === 'W' && dow !== 1) return null;
    if (item.cycle === 'M' && day !== 3) return null;
    var r = M.rng('y3ec|' + item.itemId + '|' + ym + '|' + day);
    var mark;
    if (item.rangeMin != null || item.rangeMax != null) {
      var lo = +item.rangeMin, hi = +item.rangeMax, w = hi - lo;
      var v = lo + w * (0.3 + 0.4 * r());
      if (r.chance(0.01)) v = hi + w * 0.08;
      if (item.sheetId === 4 && /압력/.test(item.itemName) && ym === CUR_YM && day === TODAY_NUM) v = hi + 3;
      mark = w < 2 ? (Math.round(v * 100) / 100).toFixed(2) : String(Math.round(v));
    } else {
      var x = r();
      mark = x < 0.008 ? '△' : x < 0.018 ? '□' : x < 0.021 ? 'X' : '○';
    }
    var who = EC_INSPECTOR[item.sheetId] || '김태성';
    var hh = item.sheetId === 7 ? 9 : 8;
    return { resultId: item.itemId * 100000 + (+ym.replace('-', '') % 10000) * 100 + day, itemId: item.itemId, ym: ym, day: day, mark: mark, userId: '', userName: who, checkedDt: ym + '-' + M.pad(day) + 'T' + M.pad(hh) + ':' + M.pad(5 + (item.itemId % 100) * 3) + ':' + M.pad(r.int(0, 59)) };
  }
  function ecResults(items, ym) {
    var out = [];
    var ovr = {};
    ecResDb.all().forEach(function (o) { if (o.ym === ym) ovr[o.itemId + '|' + o.day] = o; });
    var nd = daysInYm(ym);
    items.forEach(function (it) {
      for (var d = 1; d <= nd; d++) {
        var o = ovr[it.itemId + '|' + d];
        if (o) { if (o.mark) out.push({ resultId: o.resultId, itemId: it.itemId, ym: ym, day: d, mark: o.mark, userId: o.userId, userName: o.userName, checkedDt: o.checkedDt }); continue; }
        var b = ecBaseResult(it, ym, d); if (b) out.push(b);
      }
    });
    return out;
  }
  function ecItems(sheetId) { return ecItemDb.all().filter(function (i) { return i.sheetId === +sheetId; }).sort(function (a, b) { return a.seq - b.seq; }); }
  function ecMonth(sheetId, ym) {
    var base = { monthId: sheetId * 10000 + (+ym.replace('-', '') % 10000), sheetId: +sheetId, ym: ym, inspectorName: null, remark: null };
    for (var s = 1; s <= 3; s++) { base['sign' + s + 'UserId'] = null; base['sign' + s + 'Name'] = null; base['sign' + s + 'Dt'] = null; base['sign' + s + 'Img'] = null; }
    if (+sheetId <= 7 && ym >= '2025-12' && ym <= CUR_YM) {
      base.inspectorName = EC_INSPECTOR[sheetId];
      if (ym < CUR_YM) {
        var nx = ymAdd(ym, 1) + '-0';
        base.sign1UserId = 'tskim'; base.sign1Name = EC_INSPECTOR[sheetId]; base.sign1Dt = nx + '1T08:40:00';
        base.sign2UserId = 'yhjung'; base.sign2Name = '정용호'; base.sign2Dt = nx + '1T10:15:00';
        if (!(+sheetId === 5 && ym === ymAdd(CUR_YM, -1))) { base.sign3UserId = 'ez'; base.sign3Name = '관리자'; base.sign3Dt = nx + '2T09:30:00'; }
        base.remark = { 1: '메쉬벨트 사행 조정(□) 후 정상', 4: '퀜칭로 3존 열전대 교체 · 로내압력 일시 상승 조치', 2: '특이사항 없음', 7: '촉매 상태 양호 — 다음 교체 예정 3월' }[sheetId] || '특이사항 없음';
      } else {
        base.remark = +sheetId === 4 ? '로내 압력 상한 초과 — 배기 댐퍼 점검 요청(보전팀)' : +sheetId === 6 ? '정기 점검(메쉬벨트 교체) 진행 중' : '';
      }
    }
    var o = ecMonthDb.find(sheetId + '|' + ym);
    if (o) for (var k in o) if (k !== 'key') base[k] = o[k];
    return base;
  }
  function ecWeeks(ym) { var last = daysInYm(ym), w = []; for (var s = 1, no = 1; s <= last; s += 7, no++) w.push({ no: no, from: s, to: Math.min(s + 6, last) }); return w; }
  function ecConfirms(sheetId, ym) {
    var out = [];
    ecWeeks(ym).forEach(function (w) {
      var o = ecConfDb.find(sheetId + '|' + ym + '|' + w.no);
      if (o) { if (o.on) out.push({ sheetId: +sheetId, ym: ym, weekNo: w.no, userId: o.userId, userName: o.userName, signImg: o.signImg || null, confirmDt: o.confirmDt }); return; }
      if (+sheetId > 7 || ym < '2025-12') return;
      var done = ym < CUR_YM || (ym === CUR_YM && w.to < TODAY_NUM);
      if (done) {
        var dd = Math.min(w.to + 1, daysInYm(ym));
        out.push({ sheetId: +sheetId, ym: ym, weekNo: w.no, userId: 'yhjung', userName: '정용호', signImg: null, confirmDt: ym + '-' + M.pad(dd) + 'T10:' + M.pad(10 + w.no * 3) + ':00' });
      }
    });
    return out;
  }
  function ecNotes(items, ym) {
    var out = [];
    items.forEach(function (it) {
      var o = ecNoteDb.find(it.itemId + '|' + ym);
      if (o) { if (o.note) out.push({ itemId: it.itemId, ym: ym, note: o.note }); return; }
      if (ym === ymAdd(CUR_YM, -1) && it.sheetId <= 6) {
        var n = it.itemId % 100;
        if (n === 8) out.push({ itemId: it.itemId, ym: ym, note: '감속기 오일 보충(10/13)' });
        if (n === 13) out.push({ itemId: it.itemId, ym: ym, note: '비상정지 작동 시험 정상' });
      }
    });
    return out;
  }
  function ecBoard(sheetId, ym) {
    var sheet = ecSheetDb.find(sheetId); if (!sheet) return null;
    var items = ecItems(sheetId);
    var month = ecMonth(sheetId, ym);
    return { sheet: sheet, items: items, month: month, results: ecResults(items, ym), notes: ecNotes(items, ym), confirms: ecConfirms(sheetId, ym), today: TODAY, locked: !!month.sign3Name };
  }
  function ecGood(sheet) { try { return JSON.parse(sheet.legendJson)[0].mark; } catch (e) { return '○'; } }
  function ecIsIssue(it, m, good) {
    if (/^\d+(\.\d+)?$/.test(m)) { var v = +m; return (it.rangeMin != null && v < +it.rangeMin) || (it.rangeMax != null && v > +it.rangeMax); }
    return m !== good;
  }
  function ecSheetSummary(s) {
    var items = ecItems(s.sheetId).filter(function (i) { return i.useYn === 'Y'; });
    var res = ecResults(items, CUR_YM), good = ecGood(s);
    var byId = {}; items.forEach(function (i) { byId[i.itemId] = i; });
    var o = clone(s);
    o.itemCount = items.length;
    o.todayDone = res.filter(function (r) { return r.day === TODAY_NUM; }).length;
    // 오늘 할 일 — 그날 주기에 해당하는 항목 수로 비교되도록 itemCount는 전체 항목 수 유지(종이 양식 그대로)
    var dueToday = items.filter(function (i) { return i.cycle === 'D' || (i.cycle === 'W' && ecDow(CUR_YM, TODAY_NUM) === 1) || (i.cycle === 'M' && TODAY_NUM === 3); }).length;
    if (o.todayDone >= dueToday && dueToday > 0) o.todayDone = o.itemCount;
    o.monthIssueCount = res.filter(function (r) { return ecIsIssue(byId[r.itemId], r.mark, good); }).length;
    var last = ''; res.forEach(function (r) { if (r.checkedDt > last) last = r.checkedDt; });
    o.lastCheckedDt = last || null;
    return o;
  }
  var EC = '/api/condition/equipCheck';
  M.get(EC + '/sheet', function (req) {
    var u = req.params.useYn;
    return ok(ecSheetDb.all().filter(function (s) { return !u || s.useYn === u; }).sort(function (a, b) { return a.sortOrder - b.sortOrder; }).map(ecSheetSummary));
  });
  M.post(EC + '/sheet', function (req) {
    var b = req.body || {};
    var from = b.copyFromId ? ecSheetDb.find(b.copyFromId) : null;
    var mx = 0; ecSheetDb.all().forEach(function (s) { if (s.sheetId > mx) mx = s.sheetId; });
    var id = Math.max(mx + 1, 11);
    var s = { sheetId: id, title: b.title || '설비점검표', equipName: b.equipName || '새 설비', modelNo: b.modelNo || '', legendJson: from ? from.legendJson : EC_LEGEND, cycleJson: from ? from.cycleJson : EC_CYCLE, signJson: from ? from.signJson : EC_SIGN, footerNote: from ? from.footerNote : EC_FOOT, sortOrder: id, useYn: 'Y', regUserId: b.regUserId, regUserName: b.regUserName, regDt: iso(new Date()), updUserId: b.regUserId, updUserName: b.regUserName, updDt: iso(new Date()) };
    ecSheetDb.insert(s);
    if (from) ecItems(from.sheetId).forEach(function (it, i) { var n = clone(it); n.itemId = id * 100 + i + 1; n.sheetId = id; n.photoName = null; ecItemDb.insert(n); });
    return ok(ecSheetSummary(s));
  });
  M.put(EC + '/sheet/:sheetId', function (req) {
    var b = req.body || {}, cur = ecSheetDb.find(req.params.sheetId);
    if (!cur) return M.res(404, D.fail('점검표를 찾을 수 없습니다.'));
    ['title', 'equipName', 'modelNo', 'legendJson', 'cycleJson', 'signJson', 'footerNote', 'useYn', 'updUserId', 'updUserName'].forEach(function (k) { if (b[k] !== undefined) cur[k] = b[k]; });
    cur.updDt = iso(new Date());
    return ok(ecSheetDb.update(cur.sheetId, cur));
  });
  M.post(EC + '/sheet/delete', function (req) {
    var ids = idList(req); ecSheetDb.remove(ids);
    ecItemDb.remove(ecItemDb.all().filter(function (i) { return ids.indexOf(String(i.sheetId)) >= 0; }).map(function (i) { return i.itemId; }));
    return ok(null);
  });
  M.get(EC + '/sheet/:sheetId/board', function (req) {
    var b = ecBoard(req.params.sheetId, req.params.ym || CUR_YM);
    return b ? ok(b) : M.res(404, D.fail('점검표를 찾을 수 없습니다.'));
  });
  M.post(EC + '/sheet/:sheetId/item', function (req) {
    var b = req.body || {}, sid = +req.params.sheetId, items = ecItems(sid);
    var mxId = sid * 100 + 20, mxSeq = 0;
    items.forEach(function (i) { if (i.itemId > mxId) mxId = i.itemId; if (i.seq > mxSeq) mxSeq = i.seq; });
    var it = { itemId: mxId + 1, sheetId: sid, location: b.location || '', itemName: b.itemName || '새 점검항목', cycle: b.cycle || 'D', rangeMin: num(b.rangeMin), rangeMax: num(b.rangeMax), photoName: null, photoType: null, seq: mxSeq + 1, useYn: 'Y', updDt: iso(new Date()) };
    return ok(ecItemDb.insert(it));
  });
  M.put(EC + '/item/:itemId', function (req) {
    var b = req.body || {}, cur = ecItemDb.find(req.params.itemId);
    if (!cur) return M.res(404, D.fail('항목을 찾을 수 없습니다.'));
    return ok(ecItemDb.update(cur.itemId, { location: b.location != null ? b.location : cur.location, itemName: b.itemName != null ? b.itemName : cur.itemName, cycle: b.cycle || cur.cycle, rangeMin: b.rangeMin === undefined ? cur.rangeMin : num(b.rangeMin), rangeMax: b.rangeMax === undefined ? cur.rangeMax : num(b.rangeMax), updDt: iso(new Date()) }));
  });
  M.post(EC + '/item/:itemId/delete', function (req) { ecItemDb.remove(req.params.itemId); return ok(null); });
  M.post(EC + '/item/:itemId/move', function (req) {
    var cur = ecItemDb.find(req.params.itemId); if (!cur) return ok(null);
    var items = ecItems(cur.sheetId), i = items.map(function (x) { return x.itemId; }).indexOf(cur.itemId);
    var j = req.params.dir === 'up' ? i - 1 : i + 1;
    if (j >= 0 && j < items.length) { var a = items[i].seq, bseq = items[j].seq; ecItemDb.update(items[i].itemId, { seq: bseq }); ecItemDb.update(items[j].itemId, { seq: a }); }
    return ok(null);
  });
  M.post(EC + '/item/:itemId/photo', function (req) { return ok(ecItemDb.find(req.params.itemId)); });
  M.post(EC + '/item/:itemId/photo/delete', function (req) { return ok(ecItemDb.update(req.params.itemId, { photoName: null, photoType: null })); });
  function ecSetMark(itemId, ym, day, mark, who) {
    var key = itemId + '|' + ym + '|' + day;
    var row = { key: key, itemId: +itemId, ym: ym, day: +day, mark: mark || '', userId: who.userId || '', userName: who.userName || '', checkedDt: iso(new Date()), resultId: Date.now() % 100000000 + (+itemId) };
    if (ecResDb.find(key)) ecResDb.update(key, row); else ecResDb.insert(row);
    return mark ? { resultId: row.resultId, itemId: row.itemId, ym: ym, day: row.day, mark: mark, userId: row.userId, userName: row.userName, checkedDt: row.checkedDt } : null;
  }
  M.put(EC + '/item/:itemId/result', function (req) {
    var b = req.body || {};
    return ok(ecSetMark(req.params.itemId, b.ym, b.day, b.mark, b));
  });
  M.post(EC + '/sheet/:sheetId/fill', function (req) {
    var b = req.body || {}, sid = req.params.sheetId;
    var sheet = ecSheetDb.find(sid);
    var items = ecItems(sid).filter(function (i) { return i.useYn === 'Y'; });
    var have = {}; ecResults(items, b.ym).forEach(function (r) { if (r.day === +b.day) have[r.itemId] = 1; });
    items.forEach(function (it) { if (!have[it.itemId]) ecSetMark(it.itemId, b.ym, b.day, b.mark || ecGood(sheet), b); });
    return ok(ecBoard(sid, b.ym));
  });
  function ecMonthPatch(sheetId, ym, patch) {
    var key = sheetId + '|' + ym, cur = ecMonthDb.find(key);
    if (cur) ecMonthDb.update(key, patch); else { patch.key = key; ecMonthDb.insert(patch); }
    return ecMonth(sheetId, ym);
  }
  M.put(EC + '/sheet/:sheetId/month', function (req) {
    var b = req.body || {};
    return ok(ecMonthPatch(req.params.sheetId, b.ym, { inspectorName: b.inspectorName, remark: b.remark }));
  });
  M.put(EC + '/item/:itemId/note', function (req) {
    var b = req.body || {}, key = req.params.itemId + '|' + b.ym;
    var row = { key: key, note: (b.note || '').trim() };
    if (ecNoteDb.find(key)) ecNoteDb.update(key, row); else ecNoteDb.insert(row);
    return ok(null);
  });
  M.post(EC + '/sheet/:sheetId/sign', function (req) {
    var b = req.body || {}, s = +b.slot, p = {};
    if (b.on) { p['sign' + s + 'UserId'] = b.userId || ''; p['sign' + s + 'Name'] = b.signName || b.userName || ''; p['sign' + s + 'Dt'] = iso(new Date()); p['sign' + s + 'Img'] = b.signImg || null; }
    else { p['sign' + s + 'UserId'] = null; p['sign' + s + 'Name'] = null; p['sign' + s + 'Dt'] = null; p['sign' + s + 'Img'] = null; }
    return ok(ecMonthPatch(req.params.sheetId, b.ym, p));
  });
  M.post(EC + '/sheet/:sheetId/confirm', function (req) {
    var b = req.body || {}, key = req.params.sheetId + '|' + b.ym + '|' + b.weekNo;
    var row = { key: key, on: !!b.on, userId: b.userId || '', userName: b.signName || b.userName || '', signImg: b.signImg || null, confirmDt: iso(new Date()) };
    if (ecConfDb.find(key)) ecConfDb.update(key, row); else ecConfDb.insert(row);
    return ok(ecConfirms(req.params.sheetId, b.ym));
  });

  /* ═══════════════════ 조건관리 > 관리계획서 및 작업표준서 ═══════════════════ */
  var stdDb = M.db('y3_std', function () {
    var L = [
      ['관리계획서', 'CONTROL PLAN — 등속 조인트 샤프트(49560-2T100) Q/T', '연속열처리로 1~3호기', '4', -210, '세진모터스 승인본'],
      ['관리계획서', 'CONTROL PLAN — 아웃풋 기어 · 카운터 샤프트 침탄 퀜칭', '연속열처리로 1~6호기', '3', -150, 'SCM420H 침탄 CQ930/CQ940 패턴'],
      ['관리계획서', 'CONTROL PLAN — 베어링 내륜 · 외륜(SUJ2) 광휘 퀜칭', '연속열처리로 3·4호기', '2', -320, '한일베어링 PPAP 제출본'],
      ['관리계획서', 'CONTROL PLAN — 유성 피니언 침탄 퀜칭', '연속열처리로 2·5호기', '2', -95, '대영정공 승인'],
      ['관리계획서', 'CONTROL PLAN — 플랜지 볼트 · 고장력 너트 조질', '연속열처리로 4~6호기', '5', -60, '성광볼트 KS B 1002 강도구분 10.9'],
      ['관리계획서', 'CONTROL PLAN — 스티어링 웜 · 타이로드 볼스터드', '연속열처리로 1·5호기', '1', -30, '우진오토파츠 신규 품번 반영'],
      ['작업표준서', '연속열처리로(MBF) 운전 작업표준서', '연속열처리로 1~6호기', '7', -120, '기동·정지·패턴 변경 절차'],
      ['작업표준서', '침탄 퀜칭 작업표준서 (SCM420H · SCr420H)', '연속열처리로 1~6호기', '5', -150, 'CP 0.80~0.95% 관리'],
      ['작업표준서', '템퍼링 작업표준서', '연속열처리로 1~6호기', '4', -180, ''],
      ['작업표준서', '경도 측정 작업표준서 (로크웰 HRC)', '품질검사실', '3', -45, '초물·중물·종물 세트당 5점'],
      ['작업표준서', '퀜칭유 관리 표준 (온도 · 수분 · 성상분석)', '연속열처리로 1~6호기', '2', -260, '분기 1회 성상분석 의뢰'],
      ['작업표준서', '메쉬벨트 교체 작업표준서', '연속열처리로 1~6호기', '2', -400, '6호기 정기 점검 시 적용'],
      ['작업표준서', 'RX 가스발생기 운전 표준서', 'RX 가스발생기', '3', -300, '노점 -2~+2℃ 관리'],
      ['작업표준서', '세척기 운전 및 세척액 농도 관리 표준', '세척기 1·2호기', '2', -220, ''],
      ['작업표준서', '열전대 교체 · 조절계 교정 작업표준서', '연속열처리로 1~6호기', '2', -90, '열전대 1년 · 센서 2년 주기'],
      ['작업표준서', '비상 정지 및 정전 시 조치 표준', '공통', '4', -500, '질소 퍼지 절차 포함']
    ];
    return L.map(function (a, i) {
      var r = M.rng('y3std' + i);
      var eff = addD(TODAY, a[4]);
      var ext = a[0] === '관리계획서' ? (i % 2 ? 'xlsx' : 'pdf') : (i % 3 === 0 ? 'docx' : 'pdf');
      return { id: i + 1, docTitle: a[1], docCategory: a[0], equipName: a[2], revNo: a[3], effectiveDate: eff, remark: a[5], fileName: 'std_' + (i + 1) + '.' + ext, origFileName: a[1].replace(/[\s—()·/]+/g, '_').replace(/_+/g, '_').replace(/_$/, '') + '_' + 'Rev' + a[3] + '.' + ext, fileSize: r.int(180, 2400) * 1024, regUserName: a[0] === '관리계획서' ? '이서연' : '정용호', regDt: addD(eff, -r.int(1, 6)) + ' 14:' + M.pad(r.int(0, 59)) + ':00', updDt: eff + ' 09:00:00' };
    });
  }, 'id');
  M.get('/api/condition/standard', function (req) {
    var q = req.params, k = (q.keyword || '').toLowerCase();
    return ok(stdDb.all().filter(function (d) { return (!q.category || d.docCategory === q.category) && (!k || (d.docTitle + d.equipName).toLowerCase().indexOf(k) >= 0); })
      .sort(function (a, b) { return a.docCategory === b.docCategory ? (a.effectiveDate < b.effectiveDate ? 1 : -1) : (a.docCategory < b.docCategory ? -1 : 1); }));
  });
  function stdSave(req, cur) {
    var b = req.body || {}, f = fileOf(b.file);
    var row = cur ? clone(cur) : { id: null, regUserName: '관리자', regDt: nowStr() };
    ['docTitle', 'docCategory', 'equipName', 'revNo', 'effectiveDate', 'remark'].forEach(function (k) { if (b[k] !== undefined) row[k] = b[k]; });
    if (f) { row.fileName = 'std_new_' + Date.now(); row.origFileName = f.fileName; row.fileSize = f.size; }
    row.updDt = nowStr();
    return cur ? stdDb.update(cur.id, row) : stdDb.insert(row);
  }
  M.post('/api/condition/standard', function (req) { return ok(stdSave(req, null)); });
  M.put('/api/condition/standard/:id', function (req) { var c = stdDb.find(req.params.id); return c ? ok(stdSave(req, c)) : M.res(404, D.fail('문서를 찾을 수 없습니다.')); });
  M.del('/api/condition/standard/:id', function (req) { stdDb.remove(req.params.id); return ok(null); });

  /* ═══════════════════ 품질관리 > 경도 규격 · 측정 · 공정능력 ═══════════════════ */
  var D2 = [0, 0, 1.128, 1.693, 2.059, 2.326, 2.534, 2.704, 2.847, 2.970, 3.078];
  var D3 = [0, 0, 0, 0, 0, 0, 0, 0.076, 0.136, 0.184, 0.223];
  var D4 = [0, 0, 3.267, 2.574, 2.282, 2.114, 2.004, 1.924, 1.864, 1.816, 1.777];
  var SET_TYPES = ['초물', '중물', '종물'];
  var HD_WORKERS = ['이서연', '한지영'];
  // 공정 실력: 대부분 Cp 1.5~2.1, 4호기 두 품번은 평균이 치우쳐 CPK 1.0~1.2 (개선 대상)
  var HD_MARGINAL = { 63: { cp: 1.42, shift: 1.0 }, 69: { cp: 1.5, shift: -0.95 } };
  var hdSpecDb = M.db('y3_hd_spec', function () {
    var rows = [];
    FN.forEach(function (f) {
      D.products.forEach(function (p) {
        [['표면 경도', p.surfaceHardMin, p.surfaceHardMax, 5], ['심부 경도', p.coreHardMin, p.coreHardMax, 3]].forEach(function (it, k) {
          var specId = (f.no - 1) * 20 + (p.productId - 1) * 2 + k + 1;
          rows.push({
            specId: specId, equipCode: f.code, equipName: f.name, productId: p.productId, vendorName: p.vendorName, material: p.material,
            partNo: p.partNo, productName: p.productName, itemName: it[0], unit: 'HRC', lsl: it[1], usl: it[2], target: (it[1] + it[2]) / 2,
            decimals: 1, sampleSize: it[3], useYn: 'Y', remark: k ? '절단면 중심부 측정' : '외경 표면 3점 이상 측정',
            regUserId: 'sylee', regUserName: '이서연', updUserId: 'sylee', updUserName: '이서연', regDt: '2025-11-20T10:00:00', updDt: '2026-01-08T14:30:00'
          });
        });
      });
    });
    return rows;
  }, 'specId');
  function hdQual(spec) {
    var q = HD_MARGINAL[spec.specId];
    if (!q) { var r = M.rng('y3hdq' + spec.specId); q = { cp: r.float(1.65, 2.05), shift: r.float(-0.3, 0.3) }; }
    var w = (+spec.usl) - (+spec.lsl), sw = w / (6 * q.cp);
    return { sw: sw, mu: (+spec.lsl + +spec.usl) / 2 + q.shift * sw, sb: 0.35 * sw, width: w };
  }
  function r1(v) { return Math.round(v * 10) / 10; }

  var hdBase = null; // { list: [meas], byId: {} }
  function hdBuild() {
    if (hdBase) return hdBase;
    var specs = hdSpecDb.all(), specOf = {};
    specs.forEach(function (s) { specOf[s.equipCode + '|' + s.productId + '|' + s.itemName] = s; });
    var raw = [];
    var nowMs = Date.now();
    var lots = D.lots().filter(function (l) { return l.status === '완료'; });
    var liveLot = lots.slice().sort(function (a, b) { return a.endDt < b.endDt ? 1 : -1; })[0];
    // 3일치 LOT — LOT마다 표면·심부 측정
    lots.forEach(function (l) {
      [['표면 경도', 'surfaceHard'], ['심부 경도', 'coreHard']].forEach(function (it, k) {
        var s = specOf[l.furnaceCode + '|' + l.productId + '|' + it[0]]; if (!s) return;
        var r = M.rng('y3hdl|' + l.lotNo + '|' + k);
        var end = M.toDate(l.endDt);
        var isLive = l === liveLot && k === 0;
        var dt = new Date(end.getTime() + r.int(15, 40) * 60000);
        if (isLive) dt = new Date(Math.min(end.getTime() + 8 * 60000, nowMs - 4 * 60000));
        else if (dt.getTime() > nowMs - 5 * 60000) return; // 아직 측정 전
        var q = hdQual(s), z = (l[it[1]] - (+s.lsl + +s.usl) / 2) / (q.width / 6.5);
        raw.push({ spec: s, dt: dt, lotNo: l.lotNo, equipCode: l.furnaceCode, mean: q.mu + Math.max(-2.5, Math.min(2.5, z)) * q.sb, sw: q.sw, r: r, clamp: true, live: isLive, worker: dt.getHours() >= 8 && dt.getHours() < 20 ? HD_WORKERS[k] : '최현우' });
      });
    });
    // 지난 90일 측정 이력 — 규격마다 8건 정도
    specs.forEach(function (s) {
      var r = M.rng('y3hdh|' + s.specId), q = hdQual(s), used = {};
      for (var i = 0; i < 8; i++) {
        var off = r.int(3, 88); if (used[off]) continue; used[off] = 1;
        var dt = M.toDate(addD(TODAY, -off) + ' ' + M.pad(r.int(7, 21)) + ':' + M.pad(r.int(0, 59)) + ':00');
        raw.push({ spec: s, dt: dt, lotNo: s.equipCode + '-' + M.fmt(dt, 'YYMMDD') + '-' + M.pad(r.int(2, 14), 3), equipCode: s.equipCode, mean: q.mu + r.normal(0, 1) * q.sb, sw: q.sw, r: M.rng('y3hdv|' + s.specId + '|' + off), clamp: false, worker: r.pick(HD_WORKERS) });
      }
    });
    // 경도불량 사례(부적합 NC와 연결) — 4호기 아웃풋 기어 표면 경도, 9일 전
    raw.forEach(function (x) { if (x.spec.specId === 63 && !x.ngCase && !x.clamp && x.dt < M.toDate(addD(TODAY, -8)) && x.dt > M.toDate(addD(TODAY, -12))) x.ngCase = true; });
    var hasNg = raw.some(function (x) { return x.ngCase; });
    if (!hasNg) {
      var s63 = hdSpecDb.find(63);
      if (s63) { var dt9 = M.toDate(addD(TODAY, -9) + ' 14:20:00'); var q63 = hdQual(s63); raw.push({ spec: s63, dt: dt9, lotNo: 'MBF4-' + M.fmt(dt9, 'YYMMDD') + '-007', equipCode: 'MBF4', mean: q63.mu + q63.sb * 1.5, sw: q63.sw, r: M.rng('y3hdng'), clamp: false, worker: '이서연', ngCase: true }); }
    }
    raw.sort(function (a, b) { return a.dt - b.dt; });
    var list = [], byId = {}, monthSeq = {};
    raw.forEach(function (x, i) {
      var s = x.spec, n = s.sampleSize, measId = i + 1;
      var mk = M.fmt(x.dt, 'YYYYMM'); monthSeq[mk] = (monthSeq[mk] || 0) + 1;
      var meas = {
        measId: measId, measNo: 'HDM-' + mk + '-' + M.pad(monthSeq[mk], 3), specId: s.specId, checkRowId: null,
        partNo: s.partNo, productName: s.productName, itemName: s.itemName, unit: s.unit, lsl: s.lsl, usl: s.usl, sampleSize: n, decimals: s.decimals,
        lotNo: x.lotNo, equipCode: x.equipCode, measDt: iso(x.dt), status: '완료', judgement: '합격', receiving: 'N', workerName: x.worker, remark: '',
        completedDt: iso(new Date(x.dt.getTime() + (8 + n * 2) * 60000)), regUserId: '', regUserName: x.worker, updUserId: '', updUserName: x.worker,
        regDt: iso(x.dt), updDt: iso(x.dt), sets: []
      };
      var allVals = [];
      SET_TYPES.forEach(function (t, si) {
        var setId = measId * 10 + si + 1, vals = [];
        for (var j = 1; j <= n; j++) {
          var v = r1(x.mean + x.r.normal(0, 1) * x.sw);
          if (x.clamp) v = Math.max(+s.lsl + 0.2, Math.min(+s.usl - 0.2, v));
          if (x.ngCase && si === 1 && j === 3) v = r1(+s.usl + 0.6);
          allVals.push(v);
          vals.push({ valueId: setId * 10 + j, setId: setId, idx: j, value: v, source: x.r.chance(0.92) ? 'AUTO' : 'MANUAL', deviceId: 'HRC-01', measuredAt: iso(new Date(x.dt.getTime() + (si * n + j) * 45000)) });
        }
        meas.sets.push({ setId: setId, measId: measId, setType: t, seq: si + 1, values: vals });
      });
      if (x.ngCase) { meas.judgement = '불합격'; meas.remark = '중물 경도3 상한 초과 — 재템퍼링 후 재측정 합격(부적합 처리)'; }
      if (x.live) {
        // 경도계 자동 수신 중 — 6개 들어온 상태에서 5초마다 1개씩 들어온다
        meas.status = '측정중'; meas.judgement = ''; meas.receiving = 'Y'; meas.completedDt = null;
        meas.pending = [];
        meas.sets.forEach(function (st) { st.values.forEach(function (v) { meas.pending.push({ setId: st.setId, idx: v.idx, value: v.value }); }); st.values = []; });
        meas.liveT0 = T0 - 6 * 5000; meas.consumed = 0;
      }
      list.push(meas); byId[measId] = meas;
    });
    hdBase = { list: list, byId: byId, maxId: list.length };
    return hdBase;
  }
  var hdOvr = M.db('y3_hd_ovr', null, 'measId');
  var hdDel = M.db('y3_hd_del', null, 'measId');
  function hdTick(m, persist) {
    if (m.status !== '측정중' || m.receiving !== 'Y' || !m.pending || !m.pending.length) return m;
    var due = Math.floor((Date.now() - m.liveT0) / 5000) - (m.consumed || 0);
    var changed = false;
    while (due > 0 && m.pending.length) {
      var slot = null;
      for (var i = 0; i < m.sets.length && !slot; i++) {
        var st = m.sets[i];
        for (var j = 1; j <= m.sampleSize; j++) { if (!st.values.some(function (v) { return v.idx === j; })) { slot = { st: st, idx: j }; break; } }
      }
      if (!slot) { m.pending = []; break; }
      var pv = m.pending.shift();
      m.consumed = (m.consumed || 0) + 1;
      slot.st.values.push({ valueId: slot.st.setId * 10 + slot.idx, setId: slot.st.setId, idx: slot.idx, value: pv.value, source: 'AUTO', deviceId: 'HRC-01', measuredAt: iso(new Date(m.liveT0 + m.consumed * 5000)) });
      slot.st.values.sort(function (a, b) { return a.idx - b.idx; });
      due--; changed = true;
    }
    if (changed && persist) hdOvr.upsert(m);
    return m;
  }
  function hdGet(id) {
    if (hdDel.find(id)) return null;
    var o = hdOvr.find(id);
    if (o) return hdTick(o, true);
    var b = hdBuild().byId[id];
    return b ? hdTick(b, false) : null;
  }
  function hdAll() {
    var base = hdBuild(), dels = {}, seen = {};
    hdDel.all().forEach(function (d) { dels[d.measId] = 1; });
    var out = [];
    hdOvr.all().forEach(function (o) { seen[o.measId] = 1; if (!dels[o.measId]) out.push(hdTick(o, true)); });
    base.list.forEach(function (m) { if (!seen[m.measId] && !dels[m.measId]) out.push(hdTick(m, false)); });
    return out;
  }
  function hdSave(m) { hdOvr.upsert(clone(m)); return m; }
  function hdEditable(id) { var m = hdGet(id); return m ? clone(m) : null; }
  function hdSummary(m) {
    var o = {}; for (var k in m) if (k !== 'sets' && k !== 'pending' && k !== 'liveT0' && k !== 'consumed') o[k] = m[k];
    var vc = 0, ng = 0;
    m.sets.forEach(function (s) { s.values.forEach(function (v) { vc++; if (v.value < m.lsl || v.value > m.usl) ng++; }); });
    o.setCount = m.sets.length; o.valueCount = vc; o.ngCount = ng;
    return o;
  }
  function hdDetail(m) { var o = hdSummary(m); o.sets = clone(m.sets); return o; }
  function hdSpecOut(s, stat) { var o = clone(s); var st = stat[s.specId] || {}; o.measCount = st.c || 0; o.lastMeasDt = st.last || null; return o; }

  M.get('/api/quality/hardness/spec', function (req) {
    var q = req.params, k = (q.keyword || '').toLowerCase(), stat = {};
    hdAll().forEach(function (m) { var st = stat[m.specId] = stat[m.specId] || { c: 0, last: '' }; st.c++; if (m.measDt > st.last) st.last = m.measDt; });
    return ok(hdSpecDb.all().filter(function (s) {
      return (!q.useYn || s.useYn === q.useYn) && (!q.equipCode || s.equipCode === q.equipCode) &&
        (!k || [s.partNo, s.productName, s.itemName, s.equipCode, s.equipName, s.vendorName].join(' ').toLowerCase().indexOf(k) >= 0);
    }).sort(function (a, b) { return a.specId - b.specId; }).map(function (s) { return hdSpecOut(s, stat); }));
  });
  function hdSpecFill(row, b) {
    ['equipCode', 'productId', 'itemName', 'unit', 'lsl', 'usl', 'target', 'decimals', 'sampleSize', 'useYn', 'remark'].forEach(function (k) { if (b[k] !== undefined) row[k] = b[k]; });
    ['lsl', 'usl', 'target'].forEach(function (k) { row[k] = num(row[k]); });
    row.decimals = row.decimals == null ? 1 : +row.decimals; row.sampleSize = +row.sampleSize || 5;
    var f = furnByCode(row.equipCode); row.equipName = f ? f.name : row.equipCode;
    var p = D.product(row.productId); if (p) { row.partNo = p.partNo; row.productName = p.productName; row.vendorName = p.vendorName; row.material = p.material; }
    if (b.partNo && !p) row.partNo = b.partNo;
    return row;
  }
  M.post('/api/quality/hardness/spec', function (req) {
    var b = req.body || {}, mx = 0; hdSpecDb.all().forEach(function (s) { if (s.specId > mx) mx = s.specId; });
    var row = hdSpecFill({ specId: mx + 1, useYn: 'Y', regUserId: b.regUserId, regUserName: b.regUserName || '관리자', regDt: iso(new Date()), updDt: iso(new Date()) }, b);
    return ok(hdSpecDb.insert(row));
  });
  M.put('/api/quality/hardness/spec/:specId', function (req) {
    var cur = hdSpecDb.find(req.params.specId); if (!cur) return M.res(404, D.fail('경도 규격을 찾을 수 없습니다.'));
    var row = hdSpecFill(clone(cur), req.body || {}); row.updDt = iso(new Date()); row.updUserName = (req.body || {}).updUserName || row.updUserName;
    return ok(hdSpecDb.update(cur.specId, row));
  });
  M.post('/api/quality/hardness/spec/delete', function (req) { hdSpecDb.remove(idList(req)); return ok(null); });

  M.get('/api/quality/hardness/meas', function (req) {
    var q = req.params, k = (q.keyword || '').toLowerCase();
    var from = q.from ? String(q.from).replace(' ', 'T') : '', to = q.to ? String(q.to).replace(' ', 'T') : '';
    return ok(hdAll().filter(function (m) {
      return (!from || m.measDt >= from) && (!to || m.measDt < to) && (!q.specId || +m.specId === +q.specId) && (!q.status || m.status === q.status) &&
        (!k || [m.measNo, m.partNo, m.productName, m.lotNo, m.workerName, m.itemName].join(' ').toLowerCase().indexOf(k) >= 0);
    }).sort(function (a, b) { return a.measDt < b.measDt ? 1 : a.measDt > b.measDt ? -1 : b.measId - a.measId; }).map(hdSummary));
  });
  M.get('/api/quality/hardness/meas/:measId', function (req) { var m = hdGet(req.params.measId); return m ? ok(hdDetail(m)) : M.res(404, D.fail('경도 측정을 찾을 수 없습니다.')); });
  M.post('/api/quality/hardness/meas', function (req) {
    var b = req.body || {}, s = hdSpecDb.find(b.specId);
    if (!s) return bad('경도 규격을 골라주세요.');
    var all = hdAll(), mx = hdBuild().maxId, mk = M.fmt(new Date(), 'YYYYMM'), seq = 0;
    all.forEach(function (m) { if (m.measId > mx) mx = m.measId; if (m.measNo.indexOf('HDM-' + mk) === 0) seq = Math.max(seq, +m.measNo.slice(-3)); });
    var id = Math.max(mx + 1, 900001);
    var m = {
      measId: id, measNo: 'HDM-' + mk + '-' + M.pad(seq + 1, 3), specId: s.specId, checkRowId: null, partNo: s.partNo, productName: s.productName, itemName: s.itemName, unit: s.unit,
      lsl: s.lsl, usl: s.usl, sampleSize: s.sampleSize, decimals: s.decimals, lotNo: b.lotNo || '', equipCode: b.equipCode || s.equipCode, measDt: iso(new Date()), status: '측정중', judgement: '',
      receiving: 'N', workerName: b.workerName || b.regUserName || '', remark: b.remark || '', completedDt: null, regUserId: b.regUserId || '', regUserName: b.regUserName || '', updUserId: '', updUserName: '', regDt: iso(new Date()), updDt: iso(new Date()), sets: []
    };
    (arr(b.setTypes).length ? arr(b.setTypes) : SET_TYPES).forEach(function (t, i) { m.sets.push({ setId: id * 10 + i + 1, measId: id, setType: t, seq: i + 1, values: [] }); });
    hdSave(m);
    return ok(hdDetail(m));
  });
  M.put('/api/quality/hardness/meas/:measId', function (req) {
    var m = hdEditable(req.params.measId), b = req.body || {}; if (!m) return M.res(404, D.fail('경도 측정을 찾을 수 없습니다.'));
    ['lotNo', 'equipCode', 'workerName', 'remark'].forEach(function (k) { if (b[k] !== undefined) m[k] = b[k]; });
    m.updDt = iso(new Date()); hdSave(m); return ok(hdDetail(m));
  });
  M.post('/api/quality/hardness/meas/delete', function (req) { idList(req).forEach(function (id) { hdDel.upsert({ measId: +id }); }); return ok(null); });
  M.post('/api/quality/hardness/meas/:measId/set', function (req) {
    var m = hdEditable(req.params.measId); if (!m) return M.res(404, D.fail('경도 측정을 찾을 수 없습니다.'));
    var seq = 0; m.sets.forEach(function (s) { seq = Math.max(seq, s.seq, s.setId - m.measId * 10); });
    m.sets.push({ setId: m.measId * 10 + seq + 1, measId: m.measId, setType: (req.body || {}).setType || '중물', seq: seq + 1, values: [] });
    hdSave(m); return ok(hdDetail(m));
  });
  function hdBySet(setId) { var mid = Math.floor(+setId / 10); return hdEditable(mid); }
  M.post('/api/quality/hardness/set/:setId/delete', function (req) {
    var m = hdBySet(req.params.setId); if (!m) return M.res(404, D.fail('세트를 찾을 수 없습니다.'));
    m.sets = m.sets.filter(function (s) { return s.setId !== +req.params.setId; });
    if (m.pending) m.pending = m.pending.filter(function (p) { return p.setId !== +req.params.setId; });
    hdSave(m); return ok(hdDetail(m));
  });
  M.put('/api/quality/hardness/set/:setId/value/:idx', function (req) {
    var m = hdBySet(req.params.setId); if (!m) return M.res(404, D.fail('세트를 찾을 수 없습니다.'));
    if (m.status !== '측정중') return bad("완료된 측정입니다. 고치려면 '다시 측정'으로 열어주세요.");
    var v = (req.body || {}).value, idx = +req.params.idx;
    if (v != null && (+v < 10 || +v > 75)) return bad('측정값 ' + v + ' HRC은(는) 범위(10~75)를 벗어납니다. 값을 확인해주세요.');
    m.sets.forEach(function (s) {
      if (s.setId !== +req.params.setId) return;
      s.values = s.values.filter(function (x) { return x.idx !== idx; });
      if (v != null) s.values.push({ valueId: s.setId * 10 + idx, setId: s.setId, idx: idx, value: +v, source: 'MANUAL', deviceId: null, measuredAt: iso(new Date()) });
      s.values.sort(function (a, b) { return a.idx - b.idx; });
    });
    hdSave(m); return ok(hdDetail(m));
  });
  M.post('/api/quality/hardness/meas/:measId/complete', function (req) {
    var m = hdEditable(req.params.measId); if (!m) return M.res(404, D.fail('경도 측정을 찾을 수 없습니다.'));
    var empty = 0, ng = 0;
    m.sets.forEach(function (s) { empty += m.sampleSize - s.values.length; s.values.forEach(function (v) { if (v.value < m.lsl || v.value > m.usl) ng++; }); });
    if (!m.sets.length || empty > 0) return bad('빈 칸이 ' + empty + '개 있습니다. 모두 측정한 뒤 완료해주세요.');
    m.status = '완료'; m.receiving = 'N'; m.judgement = ng ? '불합격' : '합격'; m.completedDt = iso(new Date()); m.pending = [];
    hdSave(m); return ok(hdDetail(m));
  });
  M.post('/api/quality/hardness/meas/:measId/reopen', function (req) {
    var m = hdEditable(req.params.measId); if (!m) return M.res(404, D.fail('경도 측정을 찾을 수 없습니다.'));
    m.status = '측정중'; m.judgement = ''; m.completedDt = null; hdSave(m); return ok(hdDetail(m));
  });
  M.post('/api/quality/hardness/meas/:measId/receive', function (req) {
    var m = hdEditable(req.params.measId), on = !!(req.body || {}).on; if (!m) return M.res(404, D.fail('경도 측정을 찾을 수 없습니다.'));
    if (on) {
      // 다른 측정의 자동 수신은 끈다(경도계 1대)
      hdAll().forEach(function (o) { if (o.receiving === 'Y' && o.measId !== m.measId) { var c = clone(o); c.receiving = 'N'; hdSave(c); } });
      m.receiving = 'Y';
      var s = hdSpecDb.find(m.specId), q = s ? hdQual(s) : { mu: (+m.lsl + +m.usl) / 2, sw: 0.5 }, r = M.rng('y3live' + m.measId + Date.now());
      m.pending = [];
      m.sets.forEach(function (st) { for (var j = 1; j <= m.sampleSize; j++) if (!st.values.some(function (v) { return v.idx === j; })) m.pending.push({ setId: st.setId, idx: j, value: r1(q.mu + r.normal(0, 1) * q.sw) }); });
      m.liveT0 = Date.now(); m.consumed = 0;
    } else { m.receiving = 'N'; m.pending = []; }
    hdSave(m); return ok(hdDetail(m));
  });
  M.post('/api/quality/hardness/reading', function (req) {
    var b = req.body || {}, m = hdAll().filter(function (x) { return x.receiving === 'Y' && x.status === '측정중'; })[0];
    if (!m) return bad('자동 수신 중인 측정이 없습니다.');
    m = clone(m);
    for (var i = 0; i < m.sets.length; i++) {
      var st = m.sets[i];
      for (var j = 1; j <= m.sampleSize; j++) if (!st.values.some(function (v) { return v.idx === j; })) {
        st.values.push({ valueId: st.setId * 10 + j, setId: st.setId, idx: j, value: +b.value, source: 'AUTO', deviceId: b.deviceId || 'HRC-01', measuredAt: iso(new Date()) });
        st.values.sort(function (a, c) { return a.idx - c.idx; });
        hdSave(m); return ok(hdDetail(m));
      }
    }
    return bad('빈 칸이 없습니다.');
  });

  function hdIndices(mean, sigma, lsl, usl) {
    var p = lsl != null && usl != null ? (usl - lsl) / (6 * sigma) : null;
    var u = usl != null ? (usl - mean) / (3 * sigma) : null;
    var l = lsl != null ? (mean - lsl) / (3 * sigma) : null;
    var k = u == null ? l : l == null ? u : Math.min(u, l);
    return [p, u, l, k];
  }
  function hdCapability(spec, from, to) {
    from = from ? String(from).replace(' ', 'T') : ''; to = to ? String(to).replace(' ', 'T') : '';
    var meas = hdAll().filter(function (m) { return +m.specId === +spec.specId && m.status === '완료' && (!from || m.measDt >= from) && (!to || m.measDt < to); })
      .sort(function (a, b) { return a.measDt < b.measDt ? -1 : 1; });
    var subs = [], all = [], rangeSum = 0, sigmaSum = 0, sizeCount = {};
    meas.forEach(function (m) {
      m.sets.slice().sort(function (a, b) { return a.seq - b.seq; }).forEach(function (s) {
        var vals = s.values.slice().sort(function (a, b) { return a.idx - b.idx; }).map(function (v) { return +v.value; });
        all.push.apply(all, vals);
        var ni = vals.length; if (ni < 2 || ni >= D2.length) return;
        var mn = Math.min.apply(null, vals), mx = Math.max.apply(null, vals), sum = vals.reduce(function (a, b) { return a + b; }, 0);
        rangeSum += mx - mn; sigmaSum += (mx - mn) / D2[ni]; sizeCount[ni] = (sizeCount[ni] || 0) + 1;
        subs.push({ measId: m.measId, measNo: m.measNo, lotNo: m.lotNo, equipCode: m.equipCode, setType: s.setType, seq: s.seq, measDt: m.measDt, values: vals, mean: sum / ni, range: mx - mn });
      });
    });
    var sizes = Object.keys(sizeCount).map(Number), n = spec.sampleSize;
    if (sizes.length) n = sizes.sort(function (a, b) { return sizeCount[b] - sizeCount[a] || b - a; })[0];
    var lsl = spec.lsl == null ? null : +spec.lsl, usl = spec.usl == null ? null : +spec.usl;
    var c = { spec: spec, subgroupSize: n, subgroupSizeMin: sizes.length ? Math.min.apply(null, sizes) : n, subgroupSizeMax: sizes.length ? Math.max.apply(null, sizes) : n, subgroupCount: subs.length, totalCount: all.length, minSubgroups: 25, subgroups: subs,
      mean: null, rangeBar: null, sigmaWithin: null, sigmaOverall: null, min: null, max: null, cp: null, cpu: null, cpl: null, cpk: null, pp: null, ppu: null, ppl: null, ppk: null, uclX: null, lclX: null, uclR: null, lclR: null };
    c.outOfSpec = all.filter(function (v) { return (lsl != null && v < lsl) || (usl != null && v > usl); }).length;
    if (!all.length) return c;
    var mean = all.reduce(function (a, b) { return a + b; }, 0) / all.length;
    c.mean = mean; c.min = Math.min.apply(null, all); c.max = Math.max.apply(null, all);
    var so = 0; if (all.length > 1) { var ss = 0; all.forEach(function (v) { ss += (v - mean) * (v - mean); }); so = Math.sqrt(ss / (all.length - 1)); }
    c.sigmaOverall = so;
    if (all.length >= 2 && so > 0) { var r = hdIndices(mean, so, lsl, usl); c.pp = r[0]; c.ppu = r[1]; c.ppl = r[2]; c.ppk = r[3]; }
    if (!subs.length) return c;
    var rBar = rangeSum / subs.length, sw = sigmaSum / subs.length;
    c.rangeBar = rBar; c.sigmaWithin = sw;
    var rc = D2[n] * sw;
    c.uclX = mean + 3 * sw / Math.sqrt(n); c.lclX = mean - 3 * sw / Math.sqrt(n); c.uclR = D4[n] * rc; c.lclR = D3[n] * rc;
    if (subs.length >= 2 && sw > 0) { var k = hdIndices(mean, sw, lsl, usl); c.cp = k[0]; c.cpu = k[1]; c.cpl = k[2]; c.cpk = k[3]; }
    return c;
  }
  M.get('/api/quality/hardness/capability', function (req) {
    var s = hdSpecDb.find(req.params.specId);
    if (!s) return M.res(404, D.fail('경도 규격을 찾을 수 없습니다.', 'NOT_FOUND'));
    return ok(hdCapability(s, req.params.from, req.params.to));
  });

  /* ═══════════════════ 품질관리 > F/PROOF SAVE · LIST ═══════════════════ */
  var FP_TAGS = [
    ['FP_START', 'M100', 'Fool Proof 시작', 1],
    ['FP_END', 'M101', 'Fool Proof 종료', 1],
    ['PN_MISMATCH', 'M110', '품번-열처리 패턴 불일치 (투입 차단)', 3],
    ['LOT_NOSCAN', 'M111', 'LOT 바코드 미스캔 투입', 3],
    ['RECIPE_NOSEL', 'M112', '열처리 패턴 미선택 상태 투입', 3],
    ['CHARGE_OVER', 'M113', '장입 중량 초과', 2],
    ['Q_TEMP_DEV', 'M120', '퀜칭로 온도 편차 ±10℃ 초과', 3],
    ['CP_DEV', 'M121', 'CP 설정값 이탈 (±0.05%)', 2],
    ['OIL_TEMP_HI', 'M122', '퀜칭유 온도 상한 초과 (85℃)', 2],
    ['OIL_LEVEL_LO', 'M123', '퀜칭유 레벨 저하', 2],
    ['BELT_STOP', 'M130', '메쉬벨트 정지 (속도 0Hz)', 3],
    ['BELT_SPD_DEV', 'M131', '벨트 속도 설정값 이탈', 2],
    ['T_TEMP_DEV', 'M140', '템퍼링로 온도 편차 ±8℃ 초과', 2],
    ['DOOR_DELAY', 'M150', '장입구 도어 개방 지연', 1],
    ['N2_PURGE_LO', 'M151', '질소 퍼지 유량 저하', 2]
  ];
  var FP_DEFAULT_SEL = [2, 3, 4, 6, 7, 8, 10, 12];
  function fpTags(folderId) { return FP_TAGS.map(function (t, i) { return { tagId: folderId * 100 + i + 1, tagName: 'MBF' + folderId + '_' + t[0], address: t[1], alarmMsg: t[2], level: t[3] }; }); }
  var fpSelDb = M.db('y3_fp_sel', function () { return FN.map(function (f) { return { folderId: f.no, tagIds: FP_DEFAULT_SEL.map(function (i) { return f.no * 100 + i + 1; }) }; }); }, 'folderId');
  var fpTrigDb = M.db('y3_fp_trig', null, 'folderId');
  function fpEquips() {
    return FN.map(function (f) {
      var t = fpTrigDb.find(f.no);
      return { folderId: f.no, folderName: f.name, startTagId: t ? t.startTagId : f.no * 100 + 1, endTagId: t ? t.endTagId : f.no * 100 + 2, custom: !!t, tags: fpTags(f.no) };
    });
  }
  M.get('/api/quality/fproof/equips', function () { return ok(fpEquips()); });
  M.get('/api/quality/fproof/selected', function (req) { var s = fpSelDb.find(req.params.folderId); return ok(s ? s.tagIds : []); });
  M.post('/api/quality/fproof/select', function (req) {
    var p = req.params, s = fpSelDb.find(p.folderId) || fpSelDb.insert({ folderId: +p.folderId, tagIds: [] });
    var ids = s.tagIds.slice(); if (ids.indexOf(+p.tagId) < 0) ids.push(+p.tagId);
    fpSelDb.update(p.folderId, { tagIds: ids }); return ok(null);
  });
  M.post('/api/quality/fproof/deselect', function (req) {
    var p = req.params, s = fpSelDb.find(p.folderId); if (s) fpSelDb.update(p.folderId, { tagIds: s.tagIds.filter(function (x) { return x !== +p.tagId; }) });
    return ok(null);
  });
  M.put('/api/quality/fproof/trigger', function (req) {
    var p = req.params; if (+p.startTagId === +p.endTagId) return bad('시작과 종료 트리거는 서로 달라야 합니다.');
    fpTrigDb.upsert({ folderId: +p.folderId, startTagId: +p.startTagId, endTagId: +p.endTagId }); return ok(null);
  });
  M.del('/api/quality/fproof/trigger', function (req) { fpTrigDb.remove(req.params.folderId); return ok(null); });

  function fpAlarms(lot) {
    var f = furnByCode(lot.furnaceCode), sel = (fpSelDb.find(f.no) || { tagIds: [] }).tagIds;
    var tags = fpTags(f.no).filter(function (t) { return sel.indexOf(t.tagId) >= 0; });
    var r = M.rng('y3fp|' + lot.lotNo);
    var cnt = f.code === 'MBF4' ? r.int(0, 3) : (r.chance(0.22) ? r.int(1, 2) : 0);
    if (!tags.length) return [];
    var st = M.toDate(lot.startDt).getTime(), en = lot.endDt ? M.toDate(lot.endDt).getTime() : Date.now();
    var out = [];
    for (var i = 0; i < cnt; i++) {
      var t = f.code === 'MBF4' && r.chance(0.5) ? (tags.filter(function (x) { return /Q_TEMP_DEV/.test(x.tagName); })[0] || r.pick(tags)) : r.pick(tags);
      var oc = st + (en - st) * r.float(0.05, 0.9);
      var clr = oc + r.int(1, 12) * 60000 + r.int(0, 59) * 1000;
      var open = !lot.endDt && f.code === 'MBF4' && i === cnt - 1;
      out.push({ historyId: +(f.no + '' + (M.hash(lot.lotNo) % 100000) + i), tagName: t.tagName, alarmMsg: t.alarmMsg, occurTime: M.fmt(new Date(oc)), clearTime: open || clr > Date.now() ? null : M.fmt(new Date(clr)), _oc: oc });
    }
    return out.sort(function (a, b) { return a._oc - b._oc; }).map(function (a) { delete a._oc; return a; });
  }
  function fpSessions(from, to) {
    return D.lotsIn(from, to).map(function (l, i) {
      var f = furnByCode(l.furnaceCode);
      return { folderId: f.no, folderName: f.name, startId: M.hash(l.lotNo) % 1000000, endId: l.endDt ? M.hash(l.lotNo + 'e') % 1000000 : null, startTime: l.startDt, endTime: l.endDt || null, alarmCount: fpAlarms(l).length, _lot: l };
    }).sort(function (a, b) { return a.startTime < b.startTime ? 1 : a.startTime > b.startTime ? -1 : a.folderId - b.folderId; });
  }
  M.get('/api/quality/fproofList/sessions', function (req) { return ok(fpSessions(req.params.from, req.params.to).map(function (s) { delete s._lot; return s; })); });
  M.get('/api/quality/fproofList/detail', function (req) {
    var p = req.params, f = FN[+p.folderId - 1];
    var lot = D.lots().filter(function (l) { return f && l.furnaceCode === f.code && l.startDt === p.start; })[0];
    return ok(lot ? fpAlarms(lot) : []);
  });
  M.get('/api/quality/fproofList/export', function (req) {
    var rows = [];
    fpSessions(req.params.from, req.params.to).reverse().forEach(function (s) {
      var al = fpAlarms(s._lot);
      if (!al.length) rows.push({ folderId: s.folderId, folderName: s.folderName, startTime: s.startTime, endTime: s.endTime, tagName: null, alarmMsg: null, occurTime: null, clearTime: null });
      al.forEach(function (a) { rows.push({ folderId: s.folderId, folderName: s.folderName, startTime: s.startTime, endTime: s.endTime, tagName: a.tagName, alarmMsg: a.alarmMsg, occurTime: a.occurTime, clearTime: a.clearTime }); });
    });
    return ok(rows);
  });

  /* ═══════════════════ 품질관리 > 온도균일성보고서(TUS) ═══════════════════ */
  var TC_POS = ['입구 하부', '입구 상부', '전단 좌측', '전단 우측', '중앙 상부', '중앙 하부', '후단 좌측', '후단 우측', '출구 중앙'];
  var tuDb = M.db('y3_tus', function () {
    var rows = [], id = 1;
    FN.forEach(function (f) {
      var off = M.rng('y3tu' + f.code).int(6, 70);
      for (var q = 0; q < 6; q++) {
        var date = addD(TODAY, -(off + q * 91));
        [['퀜칭로', Q_STD[2], 10], ['템퍼링로', f.no % 2 ? 450 : 180, 8]].forEach(function (z, zi) {
          var r = M.rng('y3tu|' + f.code + q + zi);
          var hi = r.float(2.2, z[2] * 0.72), lo = r.float(2.0, z[2] * 0.7);
          var fail = f.code === 'MBF4' && zi === 1 && q === 1;
          if (fail) hi = z[2] + 1.4;
          var maxT = M.round(z[1] + hi, 1), minT = M.round(z[1] - lo, 1);
          var dev = M.round(Math.max(Math.abs(maxT - z[1]), Math.abs(minT - z[1])), 1);
          var pHi = r.int(0, 8), pLo = (pHi + r.int(2, 6)) % 9;
          var remark = z[0] + ' 9점 측정(TC1~TC9) · 최고 TC' + (pHi + 1) + '(' + TC_POS[pHi] + ') · 최저 TC' + (pLo + 1) + '(' + TC_POS[pLo] + ')';
          if (fail) remark = z[0] + ' 순환팬 베어링 마모로 TC5(중앙 상부) 편차 초과 — 팬 교체 후 재조사';
          rows.push({ id: id++, equipName: f.name, surveyDate: date, setTemp: z[1], maxTemp: maxT, minTemp: minT, tolerance: z[2], deviation: dev, judgment: dev <= z[2] ? '합격' : '불합격', inspector: r.pick(['이서연', '한지영']), remark: remark, fileName: 'tus_' + id + '.pdf', origFileName: 'TUS_' + f.code + '_' + z[0] + '_' + date.replace(/-/g, '') + '.pdf', fileSize: r.int(320, 900) * 1024, regUserName: '이서연', useYn: 'Y', regDt: date + ' 17:' + M.pad(r.int(0, 59)) + ':00', updDt: date + ' 17:40:00' });
          if (fail) {
            var d2 = addD(date, 12), mx2 = M.round(z[1] + 4.1, 1), mn2 = M.round(z[1] - 3.6, 1);
            rows.push({ id: id++, equipName: f.name, surveyDate: d2, setTemp: z[1], maxTemp: mx2, minTemp: mn2, tolerance: z[2], deviation: 4.1, judgment: '합격', inspector: '이서연', remark: z[0] + ' 순환팬 교체 후 재조사 — 9점 모두 ±8℃ 이내', fileName: 'tus_' + id + '.pdf', origFileName: 'TUS_' + f.code + '_' + z[0] + '_' + d2.replace(/-/g, '') + '_재조사.pdf', fileSize: 512000, regUserName: '이서연', useYn: 'Y', regDt: d2 + ' 16:20:00', updDt: d2 + ' 16:20:00' });
          }
        });
      }
    });
    return rows;
  }, 'id');
  M.get('/api/quality/tempUniform', function (req) {
    var q = req.params;
    return ok(tuDb.all().filter(function (r) { return (!q.equipName || r.equipName === q.equipName) && (!q.judgment || r.judgment === q.judgment) && M.inRange(r.surveyDate, q.from, q.to); })
      .sort(function (a, b) { return a.surveyDate === b.surveyDate ? (a.equipName < b.equipName ? -1 : a.equipName > b.equipName ? 1 : b.setTemp - a.setTemp) : (a.surveyDate < b.surveyDate ? 1 : -1); }));
  });
  M.get('/api/quality/tempUniform/equipNames', function () { var s = {}; tuDb.all().forEach(function (r) { s[r.equipName] = 1; }); return ok(Object.keys(s).sort()); });
  M.get('/api/quality/tempUniform/:id', function (req) { var r = tuDb.find(req.params.id); return r ? ok(r) : M.res(404, D.fail('대상을 찾을 수 없습니다.')); });
  function tuSave(req, cur) {
    var b = req.body || {}, f = fileOf(b.file);
    var row = cur ? clone(cur) : { id: null, regUserName: b.regUserName || '관리자', regDt: nowStr(), useYn: 'Y', fileName: null, origFileName: null, fileSize: null };
    row.equipName = b.equipName; row.surveyDate = b.surveyDate; row.setTemp = num(b.setTemp); row.maxTemp = num(b.maxTemp); row.minTemp = num(b.minTemp);
    row.tolerance = num(b.tolerance) == null ? 10 : num(b.tolerance); row.inspector = b.inspector || ''; row.remark = b.remark || '';
    row.deviation = M.round(Math.max(Math.abs(row.maxTemp - row.setTemp), Math.abs(row.minTemp - row.setTemp)), 1);
    row.judgment = row.deviation <= row.tolerance ? '합격' : '불합격';
    if (f) { row.fileName = 'tus_new_' + Date.now() + '.pdf'; row.origFileName = f.fileName; row.fileSize = f.size; }
    row.updDt = nowStr();
    return cur ? tuDb.update(cur.id, row) : tuDb.insert(row);
  }
  M.post('/api/quality/tempUniform', function (req) { return ok(tuSave(req, null)); });
  M.put('/api/quality/tempUniform/:id', function (req) { var c = tuDb.find(req.params.id); return c ? ok(tuSave(req, c)) : M.res(404, D.fail('대상을 찾을 수 없습니다.')); });
  M.del('/api/quality/tempUniform/:id', function (req) { tuDb.remove(req.params.id); return ok(null); });

  /* ═══════════════════ 품질관리 > 부적합품 · 불량 구분 ═══════════════════ */
  var defDb = M.db('y3_defect', function () { return clone(D.defectTypes); }, 'defectId');
  var ncDb = M.db('y3_nc', function () {
    var lots = D.lots().filter(function (l) { return l.status === '완료'; });
    var days = M.days();
    function pickLot(seed, pred) { var c = lots.filter(pred); return c.length ? c[M.rng(seed).int(0, c.length - 1)] : lots[0]; }
    function on(day) { return function (l) { return l.workDate === day; }; }
    var cases = [
      // [lot, defect, qty 비율/수량, unit, status, disposition, action, source]
      [pickLot('nc1', function (l) { return on(days[0])(l) && (l.productId === 1 || l.productId === 6); }), 'D02', 18, 'EA', '완료', '재작업', '프레스 교정 후 진직도 0.05 이내 확인 · 재검사 합격', 'SHEET'],
      [pickLot('nc2', function (l) { return on(days[0])(l) && l.productId === 7; }), 'D04', 42, 'EA', '완료', '폐기', '나사부 찍힘 — 선별 후 불량분 폐기, 장입 바스켓 완충재 보강', 'SHEET'],
      [pickLot('nc3', function (l) { return on(days[0])(l) && l.furnaceCode === 'MBF2'; }), 'D05', 120, 'KG', '완료', '재작업', '쇼트블라스트 재처리 후 외관 합격', 'MANUAL'],
      [pickLot('nc4', function (l) { return on(days[1])(l) && (l.productId === 3 || l.productId === 4); }), 'D06', 6, 'EA', '처리중', '선별', '내륜/외륜 이종 혼입 — 전수 선별 중(치수 게이지)', 'MANUAL'],
      [pickLot('nc5', function (l) { return on(days[1])(l) && l.productId === 5; }), 'D03', 3, 'EA', '처리중', '폐기', '치형부 미세 크랙(MT 검사) — 원인 분석 중(소재 협의)', 'SHEET'],
      [pickLot('nc6', function (l) { return on(days[1])(l) && l.furnaceCode === 'MBF4'; }), 'D02', 24, 'EA', '처리중', '특채', '평면도 0.08 (규격 0.05) — 고객사 특채 승인 요청', 'SHEET'],
      [pickLot('nc7', function (l) { return on(days[2])(l) && l.furnaceCode === 'MBF4'; }), 'D05', 85, 'KG', '대기', '', '', 'SHEET'],
      [pickLot('nc8', function (l) { return on(days[2])(l) && l.productId === 8; }), 'D04', 30, 'EA', '대기', '', '', 'MANUAL']
    ];
    var rows = [], seq = {};
    // 경도불량(경도측정 HDM 불합격 건과 연결) — 9일 전 4호기 아웃풋 기어
    var ng = hdAll().filter(function (m) { return m.specId === 63 && m.judgement === '불합격'; })[0];
    if (ng) cases.unshift([{ lotNo: ng.lotNo, furnaceCode: 'MBF4', furnaceName: '연속열처리로 4호기', partNo: ng.partNo, productName: ng.productName, workDate: ng.measDt.slice(0, 10), startDt: ng.measDt.replace('T', ' ') }, 'D01', 240, 'EA', '완료', '재작업', '표면 경도 상한 초과(62.6 HRC) — 재템퍼링(T180) 후 재측정 합격', 'MANUAL']);
    cases.forEach(function (c, i) {
      var l = c[0], def = D.defectTypes.filter(function (d) { return d.defectCode === c[1]; })[0];
      var date = l.workDate, mk = date.slice(0, 7).replace('-', '');
      seq[mk] = (seq[mk] || 0) + 1;
      var reg = (l.endDt || l.startDt).slice(0, 10) + ' ' + (l.endDt || l.startDt).slice(11, 16) + ':00';
      var row = { ncId: i + 1, ncNo: 'NC-' + mk + '-' + M.pad(seq[mk], 3), occurDate: date, equipCode: l.furnaceCode, equipName: l.furnaceName, partNo: l.partNo, productName: l.productName, lotNo: l.lotNo, defectCode: def.defectCode, defectName: def.defectName, qty: c[2], unit: c[3], status: c[4], disposition: c[5], actionNote: c[6], source: c[7], checkRowId: c[7] === 'SHEET' ? 5000 + i : null, sheetRowNo: c[7] === 'SHEET' ? M.rng('ncr' + i).int(3, 14) : null, remark: '', regUserId: 'sylee', regUserName: c[7] === 'SHEET' ? (l.workerName || '김태성') : '이서연', regDt: reg, updUserId: c[4] === '대기' ? null : 'sylee', updUserName: c[4] === '대기' ? null : '이서연', updDt: c[4] === '대기' ? null : addD(date, c[4] === '완료' ? 1 : 0) + ' 16:30:00' };
      if (row.updDt && row.updDt > nowStr()) row.updDt = nowStr();
      rows.push(row);
    });
    return rows;
  }, 'ncId');
  M.get('/api/quality/nonconform', function (req) {
    var q = req.params, k = (q.keyword || '').toLowerCase();
    return ok(ncDb.all().filter(function (r) {
      return M.inRange(r.occurDate, q.from, q.to) && (!q.equipCode || r.equipCode === q.equipCode) && (!q.status || r.status === q.status) && (!q.defectCode || r.defectCode === q.defectCode) &&
        (!k || [r.ncNo, r.partNo, r.productName, r.lotNo].join(' ').toLowerCase().indexOf(k) >= 0);
    }).sort(function (a, b) { return a.occurDate === b.occurDate ? b.ncId - a.ncId : (a.occurDate < b.occurDate ? 1 : -1); }));
  });
  M.get('/api/quality/nonconform/:ncId', function (req) { var r = ncDb.find(req.params.ncId); return r ? ok(r) : M.res(404, D.fail('부적합을 찾을 수 없습니다.')); });
  function ncFill(row, b) {
    ['occurDate', 'equipCode', 'partNo', 'productName', 'lotNo', 'defectCode', 'qty', 'unit', 'status', 'disposition', 'actionNote', 'remark'].forEach(function (k) { if (b[k] !== undefined) row[k] = b[k]; });
    var f = furnByCode(row.equipCode); row.equipName = f ? f.name : null;
    var d = defDb.all().filter(function (x) { return x.defectCode === row.defectCode; })[0]; row.defectName = d ? d.defectName : row.defectName;
    if (row.partNo && !row.productName) { var p = D.products.filter(function (x) { return x.partNo === row.partNo; })[0]; if (p) row.productName = p.productName; }
    row.qty = +row.qty || 0;
    return row;
  }
  M.post('/api/quality/nonconform', function (req) {
    var b = req.body || {}, date = b.occurDate || TODAY, mk = date.slice(0, 7).replace('-', ''), seq = 0;
    ncDb.all().forEach(function (r) { if (r.ncNo.indexOf('NC-' + mk) === 0) seq = Math.max(seq, +r.ncNo.slice(-3)); });
    var row = ncFill({ ncId: null, ncNo: 'NC-' + mk + '-' + M.pad(seq + 1, 3), status: '대기', source: 'MANUAL', checkRowId: null, sheetRowNo: null, regUserId: b.regUserId, regUserName: b.regUserName || '관리자', regDt: nowStr(), updUserId: null, updUserName: null, updDt: null }, b);
    return ok(ncDb.insert(row));
  });
  M.put('/api/quality/nonconform/:ncId', function (req) {
    var cur = ncDb.find(req.params.ncId), b = req.body || {}; if (!cur) return M.res(404, D.fail('부적합을 찾을 수 없습니다.'));
    var row = clone(cur);
    if (cur.source === 'SHEET') { ['status', 'disposition', 'actionNote', 'remark'].forEach(function (k) { if (b[k] !== undefined) row[k] = b[k]; }); } else ncFill(row, b);
    row.updUserId = b.updUserId; row.updUserName = b.updUserName || '관리자'; row.updDt = nowStr();
    return ok(ncDb.update(cur.ncId, row));
  });
  M.post('/api/quality/nonconform/delete', function (req) { ncDb.remove(idList(req)); return ok(null); });

  M.get('/api/quality/defect-type', function (req) {
    var u = req.params.useYn, cnt = {};
    ncDb.all().forEach(function (r) { cnt[r.defectCode] = (cnt[r.defectCode] || 0) + 1; });
    return ok(defDb.all().filter(function (d) { return !u || d.useYn === u; }).sort(function (a, b) { return a.sortOrder - b.sortOrder; })
      .map(function (d) { var o = clone(d); o.useCount = cnt[d.defectCode] || 0; return o; }));
  });
  M.post('/api/quality/defect-type', function (req) {
    var b = req.body || {}, mx = 0; defDb.all().forEach(function (d) { mx = Math.max(mx, d.defectId, d.sortOrder); });
    if (defDb.all().some(function (d) { return d.defectCode === b.defectCode; })) return bad('이미 있는 불량 코드입니다.');
    return ok(defDb.insert({ defectId: mx + 1, defectCode: b.defectCode, defectName: b.defectName, sortOrder: +b.sortOrder || mx + 1, useYn: b.useYn || 'Y' }));
  });
  M.put('/api/quality/defect-type/:defectId', function (req) {
    var b = req.body || {}, cur = defDb.find(req.params.defectId); if (!cur) return M.res(404, D.fail('불량 구분을 찾을 수 없습니다.'));
    var p = {}; ['defectCode', 'defectName', 'sortOrder', 'useYn'].forEach(function (k) { if (b[k] !== undefined) p[k] = b[k]; });
    return ok(defDb.update(cur.defectId, p));
  });
  M.post('/api/quality/defect-type/delete', function (req) { defDb.remove(idList(req)); return ok(null); });

  // 다른 화면(CHECK SHEET 등)에서 참고할 수 있게 공개
  D.y3 = { hardnessMeas: hdAll, hardnessSpecs: function () { return hdSpecDb.all(); }, nonconforms: function () { return ncDb.all(); }, defectTypes: function () { return defDb.all(); } };
})();

/* 일상점검일지(/condition/dailyCheck)는 메뉴 목록에서 빠져 있어 권한 응답에 없다 → 기존 권한 라우트(y1) 응답에 이 화면만 덧붙인다 */
(function () {
  var M = window.MOCK, prev = null;
  for (var i = M.routes.length - 1; i >= 0; i--) { var r = M.routes[i]; if (r.method === 'GET' && r.re.test('/api/base/auth/1')) { prev = r; break; } }
  if (!prev) return;
  M.get('/api/base/auth/:userId', function (req) {
    var out = prev.handler(req);
    var list = out && Array.isArray(out.data) ? out.data : null;
    if (list && !list.some(function (it) { return it.menuPath === '/condition/dailyCheck'; })) {
      var ref = list.filter(function (it) { return it.menuPath === '/condition/equipCheck'; })[0] || { canCreate: true, canRead: true, canUpdate: true, canDelete: true };
      list.push({ category: '조건관리', menuName: '일상점검일지', menuPath: '/condition/dailyCheck', canCreate: ref.canCreate, canRead: ref.canRead, canUpdate: ref.canUpdate, canDelete: ref.canDelete });
    }
    return out;
  });
})();
