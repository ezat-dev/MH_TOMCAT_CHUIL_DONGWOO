/*
 * y2-monitoring-production.js — 모니터링(경보·랭킹·TREND·LOT) + 생산관리(CHECK SHEET) 목업
 *
 *  - 경보: MOCK.D.alarms() — 최근 35일 알람 이력을 6분 단위 시간칸마다 결정적으로 만든다(같은 시각이면 항상 같은 결과).
 *          시각이 흐르면 새 알람이 생기고 해제되므로 '현재 발생 중' 목록이 실제처럼 바뀐다.
 *          4호기 퀜칭로 3존 온도 상한 초과는 세션 동안 계속 진행 중(종합생산현황·통합모니터링 4호기 알람과 같은 내용).
 *  - TREND(예시 끄기 시 실데이터 경로): 호기별 LOT 패턴 설정 온도를 따라가는 PV(패턴 변경 시 1차 지연), 6호기 08시 이후 냉각,
 *          4호기 3존은 알람 시점에 맞춰 상한 초과.
 *  - CHECK SHEET: MOCK.D.lots()의 완료 LOT 1건 = 통 1줄, 3일치 시트·경도·결재 서명·기록(audit)을 sessionStorage(MOCK.db)에 보관.
 *  - 다른 화면 담당(y1/y3) API가 아직 없을 때만 쓰는 대체 라우트(비가동 사유·불량 구분·경도 규격·권한)를 둔다 — 있으면 등록하지 않는다.
 */
(function () {
  'use strict';
  var M = window.MOCK, D = M.D;
  var ok = D.ok;
  var pad = M.pad;
  var MIN = 60000;

  function iso(d) { return M.fmt(d, 'YYYY-MM-DDTHH:mm:ss'); }
  function sql(d) { return M.fmt(d, 'YYYY-MM-DD HH:mm:ss'); }
  function ymd(d) { return M.fmt(d, 'YYYY-MM-DD'); }
  function hm(d) { return M.fmt(d, 'HH:mm'); }
  function ms(v) { var d = M.toDate(v); return d ? d.getTime() : NaN; }
  function userByName(n) { for (var i = 0; i < D.users.length; i++) if (D.users[i].userName === n) return D.users[i]; return D.users[0]; }
  function ipOf(u) { return '192.168.10.' + (100 + (u ? u.userId : 1)); }

  // 등록된 다른 라우트 핸들러를 직접 불러 데이터 배열을 얻는다(다른 담당 화면과 코드값을 맞추기 위해)
  function callApi(path, params) {
    try {
      var hit = M.resolve('GET', path);
      if (!hit || !hit.route) return null;
      var p = {}; var k;
      for (k in (params || {})) p[k] = params[k];
      for (k in hit.pathParams) p[k] = hit.pathParams[k];
      var out = hit.route.handler({ method: 'GET', path: path, url: path, query: params || {}, body: {}, params: p, match: hit.match, raw: null });
      if (out && out.status && out.body !== undefined) out = out.body;
      if (typeof out === 'string') out = JSON.parse(out);
      if (Array.isArray(out)) return out;
      if (out && Array.isArray(out.data)) return out.data;
      if (out && out.data && Array.isArray(out.data.content)) return out.data.content;
      if (out && out.data && Array.isArray(out.data.list)) return out.data.list;
    } catch (e) { /* ignore */ }
    return null;
  }
  function registered(path) { var h = M.resolve('GET', path); return !!(h && h.route); }

  // 세션 동안 고정되는 '지금 알람' 기준 시각 (4호기 3존 상한 초과 발생 시각)
  var ALARM_ANCHOR = (function () {
    var key = 'mock:ym:y2:alarmAnchor';
    var v = null;
    try { v = +sessionStorage.getItem(key); } catch (e) { /* ignore */ }
    var now = Date.now();
    if (!v || now - v > 6 * 3600000 || v > now) {
      v = Math.floor((now - 23 * MIN) / 1000) * 1000;
      try { sessionStorage.setItem(key, String(v)); } catch (e) { /* ignore */ }
    }
    return v;
  })();
  var TODAY0 = M.startOfDay(new Date()).getTime();
  var MBF6_STOP = TODAY0 + 8 * 3600000;

  /* ═════════════════════════════ 경보(알람) ═════════════════════════════ */

  var REG = iso(M.addDays(new Date(), -150)).slice(0, 10) + 'T09:00:00';
  var FOLDERS = D.furnaces.map(function (f) {
    return { folderId: f.no, folderName: f.code, parentId: null, sortOrder: f.no, createdAt: REG, updatedAt: REG };
  }).concat([{ folderId: 7, folderName: '공용설비', parentId: null, sortOrder: 7, createdAt: REG, updatedAt: REG }]);

  var PLCS = D.furnaces.map(function (f) {
    return { plcId: 'PLC_' + f.code, ip: '192.168.10.' + (10 + f.no), port: 5002, plcType: 'MELSEC-Q (MC 3E)', label: f.no + '호기 메인 PLC', enabled: 1 };
  }).concat([{ plcId: 'PLC_UTIL', ip: '192.168.10.30', port: 2004, plcType: 'LS XGK (XGT)', label: '공용설비 PLC', enabled: 1 }]);

  // [키, 메시지, 레벨, 주소오프셋, 가중치, 값종류]
  var TAG_T = [
    ['Q1_TEMP_HI', '퀜칭로 1존 온도 상한 초과', 3, 100, 1.5, 'qhi'],
    ['Q3_TEMP_HI', '퀜칭로 3존 온도 상한 초과', 3, 102, 2.0, 'qhi'],
    ['Q2_TEMP_LO', '퀜칭로 2존 온도 하한 이탈', 2, 111, 2.5, 'qlo'],
    ['T2_TEMP_DEV', '템퍼링로 2존 온도 편차', 2, 131, 4.0, 'tdev'],
    ['CP_LO', 'CP 하한 이탈', 2, 150, 4.5, 'cp'],
    ['OIL_TEMP_HI', '오일조 온도 상한', 2, 160, 3.5, 'oil'],
    ['OIL_LEVEL_LO', '소입유 레벨 저하', 1, 161, 2.5, 'lvl'],
    ['BELT_SPD_DEV', '메쉬벨트 속도 편차', 1, 170, 6.0, 'belt'],
    ['RX_FLOW_LO', 'RX 가스 유량 저하', 2, 180, 3.5, 'rx'],
    ['CW_PRESS_LO', '냉각수 압력 저하', 1, 190, 2.5, 'cw'],
    ['WASH_TEMP_LO', '세척기 세척액 온도 하한', 1, 200, 3.5, 'wash'],
    ['LOAD_CONV_OL', '장입 컨베이어 과부하', 3, 210, 0.8, 'bit'],
    ['BURNER_IGN_FAIL', '버너 착화 실패', 3, 220, 0.7, 'bit'],
    ['DOOR_TIMEOUT', '장입 도어 개폐 시간 초과', 1, 230, 4.5, 'bit'],
    ['EXH_FAN_INV', '배기팬 인버터 이상', 2, 240, 1.2, 'bit'],
    ['RUN_STOP', '설비 운전 정지', 1, 250, 0, 'bit']
  ];
  var UTIL_T = [
    ['RXG1_RETORT_LO', 'RX 가스발생기 레토르트 온도 하한', 2, 10, 2.0, 'rxg'],
    ['CT01_OUT_TEMP_HI', '냉각탑 출구 온도 상한', 1, 20, 3.0, 'ct'],
    ['AIR_PRESS_LO', '공압 압력 저하', 1, 30, 2.5, 'air'],
    ['N2_PRESS_LO', '질소 공급 압력 저하', 2, 40, 1.0, 'n2']
  ];

  var TAGS = [];
  D.furnaces.forEach(function (f) {
    var r = M.rng('y2-tagw-' + f.code);
    TAG_T.forEach(function (t, i) {
      var w = t[4] * (0.6 + r() * 0.9);
      if (f.code === 'MBF3' && t[0] === 'BELT_SPD_DEV') w *= 2.2;
      if (f.code === 'MBF2' && t[0] === 'CP_LO') w *= 2;
      if (f.code === 'MBF5' && t[0] === 'OIL_TEMP_HI') w *= 2;
      if (f.code === 'MBF4' && /^Q\d_TEMP/.test(t[0])) w *= 2.4;
      TAGS.push({
        tagId: f.no * 100 + i + 1, folderId: f.no, folderName: f.code, tagName: f.code + '_' + t[0],
        address: 'M' + (f.no * 1000 + t[3]), plcId: 'PLC_' + f.code, alarmMsg: t[1], level: t[2],
        enabled: 1, createdAt: REG, updatedAt: REG, _w: w, _kind: t[5]
      });
    });
  });
  UTIL_T.forEach(function (t, i) {
    TAGS.push({ tagId: 700 + i + 1, folderId: 7, folderName: '공용설비', tagName: t[0], address: 'M' + (7000 + t[3]), plcId: 'PLC_UTIL', alarmMsg: t[1], level: t[2], enabled: 1, createdAt: REG, updatedAt: REG, _w: t[4], _kind: t[5] });
  });
  var TAG_BY_ID = {}; TAGS.forEach(function (t) { TAG_BY_ID[t.tagId] = t; });
  // 호기별 발생 빈도 — 4호기 많고 6호기(점검 예정) 적게
  var FOLDER_W = { 1: 1.0, 2: 1.15, 3: 1.05, 4: 1.6, 5: 0.95, 6: 0.7, 7: 0.55 };

  function valueText(kind, r) {
    switch (kind) {
      case 'qhi': return r.float(893, 948, 1).toFixed(1);
      case 'qlo': return r.float(812, 838, 1).toFixed(1);
      case 'tdev': return r.float(184, 196, 1).toFixed(1);
      case 'cp': return r.float(0.62, 0.74, 2).toFixed(2);
      case 'oil': return r.float(86, 92, 1).toFixed(1);
      case 'lvl': return r.float(58, 64, 1).toFixed(1);
      case 'belt': return r.float(21.5, 25.5, 1).toFixed(1);
      case 'rx': return r.float(7.2, 8.8, 1).toFixed(1);
      case 'cw': return r.float(1.2, 1.6, 2).toFixed(2);
      case 'wash': return r.float(46, 52, 1).toFixed(1);
      case 'rxg': return r.float(985, 1012, 1).toFixed(1);
      case 'ct': return r.float(34, 37.5, 1).toFixed(1);
      case 'air': return r.float(4.1, 4.6, 1).toFixed(1);
      case 'n2': return r.float(2.2, 2.7, 1).toFixed(1);
      default: return '1';
    }
  }
  var ACKERS = ['정용호', '오동석', '김태성', '박민재', '최현우'];

  // 6분 칸마다 최대 1건 — 칸 번호가 곧 historyId(시간순으로 커진다)
  var BUCKET = 6 * MIN;
  var ALL_EVENTS = null;
  function buildAlarms() {
    if (ALL_EVENTS) return ALL_EVENTS;
    var start = TODAY0 - 34 * 86400000;
    var end = TODAY0 + 86400000;
    var folders = [1, 2, 3, 4, 5, 6, 7];
    var fw = folders.map(function (f) { return FOLDER_W[f]; });
    var out = [];
    for (var b = Math.floor(start / BUCKET); b * BUCKET < end; b++) {
      var r = M.rng('y2-alarm-' + b);
      var t0 = b * BUCKET;
      var hr = new Date(t0).getHours();
      var p = (hr >= 8 && hr < 20) ? 0.36 : 0.26;
      if (r() >= p) continue;
      var fid = weighted(folders, fw, r);
      var cands = TAGS.filter(function (t) { return t.folderId === fid && t._w > 0; });
      var tag = weighted(cands, cands.map(function (t) { return t._w; }), r);
      var occur = t0 + Math.floor(r() * BUCKET);
      if (fid === 6 && occur >= MBF6_STOP) continue;                          // 6호기는 08시부터 정지
      if (fid === 4 && tag.tagName === 'MBF4_Q3_TEMP_HI' && occur > ALARM_ANCHOR - 3 * 3600000) continue;
      var dur = tag.level === 3 ? r.float(1.5, 14) : tag.level === 2 ? r.float(2, 32) : r.float(0.6, 18);
      if (r() < 0.07) dur = r.float(35, 95);
      var clear = occur + Math.round(dur * MIN);
      var ack = null, ackUser = null;
      if (tag.level >= 2 || r() < 0.5) {
        ack = occur + Math.round(Math.min(dur * 0.8, r.float(0.3, 4)) * MIN);
        ackUser = r.pick(ACKERS);
      }
      out.push(mkEvent(b - 4600000, tag, occur, clear, ack, ackUser, valueText(tag._kind, r)));
    }
    // 6호기 정기 점검 정지 (오늘 08:00)
    out.push(mkEvent(Math.floor(MBF6_STOP / BUCKET) - 4600000 + 0.5, TAG_BY_ID[616], MBF6_STOP + 12000, MBF6_STOP + 95000, MBF6_STOP + 40000, '정용호', '0'));
    // 4호기 3존 상한 초과 — 진행 중
    out.push(mkEvent(Math.floor(ALARM_ANCHOR / BUCKET) - 4600000 + 0.7, TAG_BY_ID[402], ALARM_ANCHOR, null, ALARM_ANCHOR + 95000, '정용호', '903.6'));
    out.sort(function (a, b) { return a._o - b._o; });
    out.forEach(function (e, i) { e.historyId = 48000 + i; });
    ALL_EVENTS = out;
    return out;
  }
  function weighted(list, ws, r) {
    var s = 0, i; for (i = 0; i < ws.length; i++) s += ws[i];
    var x = r() * s;
    for (i = 0; i < list.length; i++) { x -= ws[i]; if (x <= 0) return list[i]; }
    return list[list.length - 1];
  }
  function mkEvent(id, tag, occur, clear, ack, ackUser, val) {
    return { historyId: id, tagId: tag.tagId, tagName: tag.tagName, address: tag.address, alarmMsg: tag.alarmMsg, level: tag.level,
      plcId: tag.plcId, folderId: tag.folderId, folderName: tag.folderName, _o: occur, _c: clear, _a: ack, _au: ackUser, valueAtOccur: val };
  }
  // 지금 시각 기준으로 보이는 모습(해제 전이면 clearTime null)
  function view(e, now) {
    return {
      historyId: e.historyId, tagId: e.tagId, tagName: e.tagName, address: e.address, alarmMsg: e.alarmMsg, level: e.level,
      plcId: e.plcId, folderId: e.folderId, folderName: e.folderName,
      occurTime: iso(new Date(e._o)),
      clearTime: e._c != null && e._c <= now ? iso(new Date(e._c)) : null,
      ackTime: e._a != null && e._a <= now ? iso(new Date(e._a)) : null,
      ackUser: e._a != null && e._a <= now ? e._au : null,
      valueAtOccur: e.valueAtOccur
    };
  }
  /** 공용: 알람 이력 — opts {from, to, folderId, active(true/false), level} → 최신순 */
  D.alarms = function (opts) {
    opts = opts || {};
    var now = Date.now();
    var f = opts.from ? ms(opts.from) : -Infinity;
    var t = opts.to ? ms(opts.to) : Infinity;
    if (opts.to && /^\s*\d{4}-?\d{2}-?\d{2}\s*$/.test(String(opts.to))) t += 86400000 - 1;
    var res = [];
    var ev = buildAlarms();
    for (var i = ev.length - 1; i >= 0; i--) {
      var e = ev[i];
      if (e._o > now || e._o < f || e._o > t) continue;
      if (opts.folderId && String(e.folderId) !== String(opts.folderId)) continue;
      if (opts.level && String(e.level) !== String(opts.level)) continue;
      var v = view(e, now);
      if (opts.active === true && v.clearTime) continue;
      if (opts.active === false && !v.clearTime) continue;
      res.push(v);
    }
    return res;
  };
  D.alarmFolders = FOLDERS;
  D.alarmTags = TAGS;

  var folderDb = M.db('y2_alarmFolders', function () { return FOLDERS.map(function (f) { return Object.assign({}, f); }); }, 'folderId');
  var tagDb = M.db('y2_alarmTags', function () {
    return TAGS.filter(function (t) { return t._w > 0 || t.tagName.indexOf('RUN_STOP') > 0; }).map(function (t) {
      return { tagId: t.tagId, folderId: t.folderId, tagName: t.tagName, address: t.address, plcId: t.plcId, alarmMsg: t.alarmMsg, level: t.level, enabled: 1, createdAt: REG, updatedAt: REG };
    });
  }, 'tagId');
  var plcDb = M.db('y2_alarmPlcs', function () { return PLCS.map(function (p) { return Object.assign({}, p); }); }, 'plcId');

  function hoursBuckets(hours, fmtHour) {
    var now = new Date();
    var cur = new Date(now); cur.setMinutes(0, 0, 0);
    var first = cur.getTime() - (hours - 1) * 3600000;
    var list = [];
    for (var i = 0; i < hours; i++) {
      var d = new Date(first + i * 3600000);
      list.push({ key: M.fmt(d, 'YYYY-MM-DD HH:00:00'), start: d.getTime(), hour: fmtHour(d) });
    }
    return list;
  }
  function bucketOf(list, t) { for (var i = list.length - 1; i >= 0; i--) if (t >= list[i].start) return list[i]; return null; }

  M.get('/api/monitoring/alarm', function (req) {
    var q = req.params;
    var list = D.alarms({ from: q.from || q.startDate, to: q.to || q.endDate, folderId: q.folderId, level: q.level });
    if (q.keyword) list = list.filter(function (a) { return (a.tagName + a.alarmMsg + a.folderName).indexOf(q.keyword) >= 0; });
    if (q.state === 'active') list = list.filter(function (a) { return !a.clearTime; });
    if (q.page || q.size) return ok(D.page(list, q.page, q.size));
    return ok(list);
  });
  M.get('/api/monitoring/alarm/active', function (req) {
    return ok(D.alarms({ active: true }).slice(0, +req.params.limit || 50));
  });
  M.get('/api/monitoring/alarm/history', function (req) {
    return ok(D.alarms({ from: TODAY0 - 30 * 86400000 }).slice(0, +req.params.limit || 500));
  });
  M.get('/api/monitoring/alarm/historyRange', function (req) {
    return ok(D.alarms({ from: req.params.from, to: req.params.to }));
  });

  // 폴더 / 태그 / PLC 설정
  M.get('/api/monitoring/alarm/folders', function () { return ok(folderDb.all().sort(function (a, b) { return a.sortOrder - b.sortOrder; })); });
  M.post('/api/monitoring/alarm/folders', function (req) {
    var id = folderDb.nextId();
    return ok(folderDb.insert({ folderId: id, folderName: req.params.folderName, parentId: null, sortOrder: id, createdAt: iso(new Date()), updatedAt: iso(new Date()) }));
  });
  M.del('/api/monitoring/alarm/folders/:id', function (req) { folderDb.remove(+req.params.id); return ok(null); });
  M.get('/api/monitoring/alarm/tags', function (req) {
    var fid = req.params.folderId;
    return ok(tagDb.all().filter(function (t) { return !fid || String(t.folderId) === String(fid); }));
  });
  M.post('/api/monitoring/alarm/tags', function (req) {
    var b = req.body || {};
    var row = { tagId: tagDb.nextId(), folderId: +b.folderId, tagName: b.tagName, address: b.address, plcId: b.plcId, alarmMsg: b.alarmMsg, level: +b.level || 1, enabled: b.enabled == null ? 1 : +b.enabled, createdAt: iso(new Date()), updatedAt: iso(new Date()) };
    return ok(tagDb.insert(row));
  });
  M.put('/api/monitoring/alarm/tags/:id', function (req) {
    var b = req.body || {};
    return ok(tagDb.update(+req.params.id, { folderId: +b.folderId, tagName: b.tagName, address: b.address, plcId: b.plcId, alarmMsg: b.alarmMsg, level: +b.level || 1, enabled: +b.enabled, updatedAt: iso(new Date()) }));
  });
  M.del('/api/monitoring/alarm/tags/:id', function (req) { tagDb.remove(+req.params.id); return ok(null); });
  M.get('/api/monitoring/alarm/plcs', function () { return ok(plcDb.all()); });
  M.post('/api/monitoring/alarm/plcs', function (req) { var b = req.body || {}; plcDb.upsert({ plcId: b.plcId, ip: b.ip, port: +b.port || 5002, plcType: b.plcType, label: b.label, enabled: b.enabled == null ? 1 : +b.enabled }); return ok(null); });
  M.del('/api/monitoring/alarm/plcs/:id', function (req) { plcDb.remove(req.params.id); return ok(null); });

  // 대시보드 집계
  M.get('/api/monitoring/alarm/messagesByFolder', function (req) {
    var list = D.alarms({ from: req.params.from, to: req.params.to });
    var map = {};
    list.forEach(function (a) {
      var k = a.folderId + '|' + a.alarmMsg;
      var m = map[k] || (map[k] = { folderId: a.folderId, folderLabel: a.folderName, alarmMsg: a.alarmMsg, cnt: 0, lastOccurTime: a.occurTime });
      m.cnt++;
      if (a.occurTime > m.lastOccurTime) m.lastOccurTime = a.occurTime;
    });
    var out = Object.keys(map).map(function (k) { return map[k]; });
    out.sort(function (a, b) { return a.folderId - b.folderId || b.cnt - a.cnt; });
    return ok(out);
  });
  M.get('/api/monitoring/alarm/trend', function (req) {
    var hb = hoursBuckets(+req.params.hours || 24, function (d) { return pad(d.getHours()) + '시'; });
    var cnt = {};
    D.alarms({ from: hb[0].start }).forEach(function (a) { var b = bucketOf(hb, ms(a.occurTime)); if (b) cnt[b.key] = (cnt[b.key] || 0) + 1; });
    return ok(hb.map(function (b) { return { bucket: b.key, hour: b.hour, count: cnt[b.key] || 0 }; }));
  });
  M.get('/api/monitoring/alarm/trendBySeverity', function (req) {
    var hb = hoursBuckets(+req.params.hours || 24, function (d) { return pad(d.getHours()) + ':00'; });
    var cnt = {};
    D.alarms({ from: hb[0].start }).forEach(function (a) {
      var b = bucketOf(hb, ms(a.occurTime)); if (!b) return;
      var c = cnt[b.key] || (cnt[b.key] = [0, 0, 0, 0]);
      c[Math.min(3, Math.max(1, a.level))]++;
    });
    return ok(hb.map(function (b) { var c = cnt[b.key] || [0, 0, 0, 0]; return { bucket: b.key, hour: b.hour, level1: c[1], level2: c[2], level3: c[3], total: c[1] + c[2] + c[3] }; }));
  });
  M.get('/api/monitoring/alarm/countByFolderSeverity', function (req) {
    var from = Date.now() - (+req.params.hours || 24) * 3600000;
    var map = {};
    D.alarms({ from: from }).forEach(function (a) {
      var k = a.folderId + '|' + a.level;
      (map[k] || (map[k] = { folderId: a.folderId, folderLabel: a.folderName, level: a.level, cnt: 0 })).cnt++;
    });
    var out = Object.keys(map).map(function (k) { return map[k]; });
    out.sort(function (a, b) { return a.folderId - b.folderId || a.level - b.level; });
    return ok(out);
  });
  M.get('/api/monitoring/alarm/responseTimeTrend', function (req) {
    var hb = hoursBuckets(+req.params.hours || 24, function (d) { return pad(d.getHours()) + ':00'; });
    var sum = {}, n = {};
    D.alarms({ from: hb[0].start, active: false }).forEach(function (a) {
      var b = bucketOf(hb, ms(a.occurTime)); if (!b) return;
      var mins = Math.floor((ms(a.clearTime) - ms(a.occurTime)) / MIN);
      sum[b.key] = (sum[b.key] || 0) + mins; n[b.key] = (n[b.key] || 0) + 1;
    });
    return ok(hb.map(function (b) { return { bucket: b.key, hour: b.hour, avgMinutes: n[b.key] ? Math.round(sum[b.key] / n[b.key] * 10) / 10 : null, count: n[b.key] || 0 }; }));
  });
  M.get('/api/monitoring/alarmRank', function (req) {
    var q = req.params, by = q.groupBy || 'tag';
    var map = {};
    D.alarms({ from: q.from, to: q.to }).forEach(function (a) {
      var key = by === 'folder' ? a.folderId : by === 'plc' ? a.plcId : a.tagName;
      var label = by === 'folder' ? a.folderName : by === 'plc' ? (PLCS.filter(function (p) { return p.plcId === a.plcId; })[0] || {}).label || a.plcId : a.tagName;
      var m = map[key] || (map[key] = { groupKey: String(key), label: label, count: 0, lastOccurTime: a.occurTime });
      m.count++;
      if (a.occurTime > m.lastOccurTime) m.lastOccurTime = a.occurTime;
    });
    var out = Object.keys(map).map(function (k) { return map[k]; });
    out.sort(function (a, b) { return b.count - a.count; });
    return ok(out);
  });
  M.get('/api/monitoring/alarm/trendByFolder', function (req) {
    var q = req.params, hour = String(q.bucketUnit).toUpperCase() === 'HOUR';
    var map = {};
    D.alarms({ from: q.from, to: q.to }).forEach(function (a) {
      var d = M.toDate(a.occurTime);
      var bucket = hour ? M.fmt(d, 'YYYY-MM-DD HH:00:00') : ymd(d);
      var k = a.folderId + '|' + bucket;
      (map[k] || (map[k] = { folderId: a.folderId, folderLabel: a.folderName, bucket: bucket, cnt: 0 })).cnt++;
    });
    var out = Object.keys(map).map(function (k) { return map[k]; });
    out.sort(function (a, b) { return a.bucket < b.bucket ? -1 : a.bucket > b.bucket ? 1 : a.folderId - b.folderId; });
    return ok(out);
  });

  /* ═════════════════════════════ TREND (실데이터 경로) ═════════════════════════════ */

  var LOTS_BY_F = {};
  function lotsOf(code) {
    if (LOTS_BY_F[code]) return LOTS_BY_F[code];
    LOTS_BY_F[code] = D.lots().filter(function (l) { return l.furnaceCode === code; }).map(function (l) {
      return { s: ms(l.startDt), p: D.pattern(l.patternId), lot: l };
    });
    return LOTS_BY_F[code];
  }
  function lotIdxAt(code, ts) {
    var ls = lotsOf(code);
    for (var i = ls.length - 1; i >= 0; i--) if (ls[i].s <= ts) return i;
    return 0;
  }
  var TREND_KEYS = [];
  [1, 2, 3, 4, 5].forEach(function (z) { TREND_KEYS.push(['q' + z + '_pv', '퀜칭 ' + z + '존 PV', 'D' + (100 + z)]); });
  TREND_KEYS.push(['q3_sp', '퀜칭 3존 SP', 'D113']);
  [1, 2, 3, 4, 5].forEach(function (z) { TREND_KEYS.push(['t' + z + '_pv', '템퍼링 ' + z + '존 PV', 'D' + (200 + z)]); });
  TREND_KEYS.push(['cp_pv', 'CP PV', 'D301'], ['cp_sp', 'CP SP', 'D302'], ['oil_pv', '오일조 온도 PV', 'D310'], ['rx_flow', 'RX 가스 유량', 'D320'], ['c3h8_flow', 'C3H8 유량', 'D321']);

  function spOf(p, key) {
    var z = +(key.match(/\d/) || [3])[0];
    if (key.charAt(0) === 'q') return p['q' + z + 'Zone'];
    if (key.charAt(0) === 't') return p['t' + z + 'Zone'];
    if (key.indexOf('cp') === 0) return p.cp;
    return null;
  }
  function trendValue(code, key, ts) {
    var ls = lotsOf(code);
    if (!ls.length) return null;
    var i = lotIdxAt(code, ts);
    var cur = ls[i], prev = ls[Math.max(0, i - 1)];
    var since = (ts - cur.s) / MIN;
    var salt = code + key;
    var v;
    var isTemp = /^[qt]\d_pv$/.test(key);
    if (key === 'q3_sp') v = spOf(cur.p, 'q3');
    else if (key === 'cp_sp') v = cur.p.cp;
    else if (isTemp || key === 'cp_pv') {
      var sp = spOf(cur.p, key), psp = spOf(prev.p, key);
      var tau = key === 'cp_pv' ? 9 : key.charAt(0) === 'q' ? 14 : 18;
      v = sp + (psp - sp) * Math.exp(-Math.max(0, since) / tau);
      if (key === 'cp_pv') v += M.wave(salt, ts, 0, 0.006, 0.0015, 37);
      else v += M.wave(salt, ts, 0, key.charAt(0) === 'q' ? 1.4 : 0.9, 0.35, 41) - (key === 'q1_pv' || key === 't1_pv' ? 1.2 : 0);
    } else if (key === 'oil_pv') v = 80 + M.wave(salt, ts, 0, 1.6, 0.3, 75);
    else if (key === 'rx_flow') v = 12.4 + M.wave(salt, ts, 0, 0.25, 0.05, 33);
    else if (key === 'c3h8_flow') v = 0.32 + (cur.p.cp - 0.4) * 0.35 + M.wave(salt, ts, 0, 0.015, 0.004, 29);
    // 6호기 — 오늘 08시 정기 점검으로 정지, 서서히 냉각
    if (code === 'MBF6' && ts > MBF6_STOP) {
      var dt = (ts - MBF6_STOP) / MIN;
      var at = trendValue('MBF6_PRE', key, MBF6_STOP);
      if (at == null) at = v;
      if (key.charAt(0) === 'q' && key !== 'q3_sp') v = 260 + (at - 260) * Math.exp(-dt / 170) + M.wave(salt, ts, 0, 0.6, 0.2, 41);
      else if (key.charAt(0) === 't') v = 45 + (at - 45) * Math.exp(-dt / 140) + M.wave(salt, ts, 0, 0.4, 0.1, 41);
      else if (key === 'q3_sp') v = 0;
      else if (key === 'cp_pv') v = 0.18 + (at - 0.18) * Math.exp(-dt / 25);
      else if (key === 'cp_sp') v = 0;
      else if (key === 'rx_flow' || key === 'c3h8_flow') v = Math.max(0, at * Math.exp(-dt / 6));
      else if (key === 'oil_pv') v = 35 + (at - 35) * Math.exp(-dt / 300);
    }
    // 4호기 — 퀜칭로 3존 온도 상한 초과(알람 발생 5분 전부터 상승)
    if (code === 'MBF4' && key === 'q3_pv' && ts > ALARM_ANCHOR - 5 * MIN) {
      v += 24 * (1 - Math.exp(-(ts - (ALARM_ANCHOR - 5 * MIN)) / (5 * MIN)));
    }
    if (v == null) return null;
    return key.indexOf('cp') === 0 ? M.round(v, 3) : key.indexOf('flow') > 0 ? M.round(v, 2) : M.round(v, 1);
  }
  // MBF6 정지 직전 값 계산용 별칭 (정지 보정 없이)
  var _tv = trendValue;
  trendValue = function (code, key, ts) { return code === 'MBF6_PRE' ? _tvRaw('MBF6', key, ts) : _tv(code, key, ts); };
  function _tvRaw(code, key, ts) { var save = MBF6_STOP; MBF6_STOP = Infinity; var v = _tv(code, key, ts); MBF6_STOP = save; return v; }

  var trendTagDb = M.db('y2_trendTags', function () {
    var list = [], id = 1;
    D.furnaces.forEach(function (f) {
      TREND_KEYS.forEach(function (k) {
        list.push({ tempId: id++, tagName: f.code + '_' + k[0].toUpperCase(), address: k[2].replace(/^D/, 'D' + f.no), plcId: 'PLC_' + f.code,
          colName: f.code.toLowerCase() + '_' + k[0], trendName: k[1], equipId: f.code, scale: '*1', enabled: 1, regDt: REG, updDt: REG });
      });
    });
    return list;
  }, 'tempId');
  function snapRow(ts, tags) {
    var row = {};
    tags.forEach(function (t) {
      var m = /^(mbf\d)_(.+)$/.exec(t.colName || '');
      if (m) row[t.colName] = trendValue(m[1].toUpperCase(), m[2], ts);
    });
    row.record_time = sql(new Date(ts));
    return row;
  }

  M.get('/api/monitoring/trendSettings', function () { return ok(trendTagDb.all()); });
  M.post('/api/monitoring/trendSettings', function (req) {
    var b = req.body || {};
    return ok(trendTagDb.insert({ tempId: trendTagDb.nextId(), tagName: b.tagName, address: b.address, plcId: b.plcId, colName: b.colName, trendName: b.trendName, equipId: b.equipId, scale: b.scale, enabled: b.enabled == null ? 1 : +b.enabled, regDt: iso(new Date()), updDt: iso(new Date()) }));
  });
  M.put('/api/monitoring/trendSettings/:id', function (req) {
    var b = req.body || {}, patch = {};
    ['tagName', 'address', 'plcId', 'colName', 'trendName', 'equipId', 'scale'].forEach(function (k) { if (b[k] !== undefined) patch[k] = b[k]; });
    if (b.enabled !== undefined) patch.enabled = +b.enabled;
    patch.updDt = iso(new Date());
    return ok(trendTagDb.update(+req.params.id, patch));
  });
  M.del('/api/monitoring/trendSettings/:id', function (req) { trendTagDb.remove(+req.params.id); return ok(null); });
  M.get('/api/monitoring/trendSettings/snapshots', function (req) {
    var n = Math.min(+req.params.limit || 20, 200);
    var tags = trendTagDb.all().filter(function (t) { return t.enabled === 1; });
    var last = Math.floor(Date.now() / 15000) * 15000;
    var out = [];
    for (var i = 0; i < n; i++) {
      var ts = last - i * 15000;
      var row = { snapshot_id: Math.floor(ts / 15000) - 117000000 };
      var r = snapRow(ts, tags);
      for (var k in r) row[k] = r[k];
      out.push(row);
    }
    return ok(out);
  });
  M.get('/api/monitoring/trend/snapshotRange', function (req) {
    var a = ms(req.params.from), b = ms(req.params.to);
    if (!(b > a)) return ok([]);
    var step = Math.max(MIN, Math.ceil((b - a) / 400 / MIN) * MIN);
    var tags = trendTagDb.all().filter(function (t) { return t.enabled === 1; });
    var out = [];
    for (var ts = Math.ceil(a / step) * step; ts <= b; ts += step) out.push(snapRow(ts, tags));
    return ok(out);
  });
  var memoDb = M.db('y2_trendMemos', function () {
    var list = [], id = 1;
    lotsOf('MBF1').forEach(function (x) {
      list.push({ tcCnt: id++, tcName: '1호기 LOT ' + x.lot.lotNo.slice(5) + ' 장입', tcDesc: x.lot.productName + ' · ' + x.lot.vendorName + ' (' + x.lot.patternCode + ')', tcRegtime: x.lot.startDt, tcUserCode: 'tskim', tcUserName: '김태성' });
    });
    var y = M.addDays(new Date(TODAY0), -1);
    list.push({ tcCnt: id++, tcName: '통신 재연결', tcDesc: 'PLC 통신 자동 복구 (3호기)', tcRegtime: sql(new Date(y.getTime() + 15 * 3600000 + 26 * MIN)), tcUserCode: 'yhjung', tcUserName: '정용호', tone: 'alert' });
    list.push({ tcCnt: id++, tcName: '6호기 정기 점검 시작', tcDesc: '운전 정지 · 퀜칭로 강온', tcRegtime: sql(new Date(MBF6_STOP)), tcUserCode: 'yhjung', tcUserName: '정용호' });
    list.push({ tcCnt: id++, tcName: '4호기 3존 상한 알람', tcDesc: '퀜칭로 3존 온도 상한 초과 — 설비보전 확인 중', tcRegtime: sql(new Date(Math.floor(ALARM_ANCHOR / MIN) * MIN)), tcUserCode: 'yhjung', tcUserName: '정용호', tone: 'alert' });
    return list;
  }, 'tcCnt');
  M.get('/api/monitoring/trend/memos', function (req) {
    return ok(memoDb.all().filter(function (m) { return M.inRange(m.tcRegtime, req.params.from, req.params.to); })
      .sort(function (a, b) { return a.tcRegtime < b.tcRegtime ? -1 : 1; }));
  });
  M.post('/api/monitoring/trend/memos', function (req) {
    var b = req.body || {};
    return ok(memoDb.insert({ tcCnt: memoDb.nextId(), tcName: b.tcName, tcDesc: b.tcDesc, tcRegtime: b.tcRegtime, tcUserCode: b.tcUserCode, tcUserName: b.tcUserName }));
  });
  M.del('/api/monitoring/trend/memos/:id', function (req) { memoDb.remove(req.params.id); return ok(null); });

  /* ═══════════════ LOT 현황 / 트래킹 / 종합생산현황 / 통합 (화면은 내장 목업을 쓰지만 API도 같은 형식으로) ═══════════════ */

  function lotObj(l) {
    var p = D.pattern(l.patternId);
    var s = ms(l.startDt), e = ms(l.planEndDt);
    var now = Date.now();
    var prog = l.endDt ? 1 : Math.max(0, Math.min(0.99, (now - s) / (e - s)));
    return {
      code: l.furnaceCode, lotNo: l.lotNo, company: l.vendorName, partNo: l.partNo, productName: l.productName,
      patternCode: l.patternCode, patternName: l.patternName, trayCount: 4, qty: l.qty, weightKg: l.weightKg,
      startAt: s, endAt: l.endDt ? ms(l.endDt) : null, expectedEndAt: e, progress: M.round(prog, 3),
      zoneFrom: l.endDt ? null : Math.max(0, Math.floor(prog * 13) - 3), zoneTo: l.endDt ? null : Math.floor(prog * 13),
      result: !l.endDt ? 'run' : l.judge === '불합격' ? 'check' : 'ok', note: l.judge === '불합격' ? '경도 규격 이탈' : '',
      sp: { q: [p.q1Zone, p.q2Zone, p.q3Zone, p.q4Zone, p.q5Zone], t: [p.t1Zone, p.t2Zone, p.t3Zone, p.t4Zone, p.t5Zone], cp: p.cp, qs: p.quenchSpeed, ts: p.temperSpeed, unit: p.speedUnit }
    };
  }
  function furnaceDef(f) {
    var o = { code: f.code, name: f.name, status: f.status };
    if (f.status === 'alarm') o.alarm = { zone: 'q3', message: '퀜칭로 3존 온도 상한 초과' };
    if (f.status === 'idle') o.idleReason = '정기 점검';
    return o;
  }
  M.get('/api/monitoring/lotStatus/current', function () {
    var today = ymd(new Date());
    return ok({ updatedAt: Date.now(), furnaces: D.furnaces.map(function (f) {
      var ls = D.lots().filter(function (l) { return l.furnaceCode === f.code; });
      var o = furnaceDef(f);
      o.running = ls.filter(function (l) { return !l.endDt; }).map(lotObj);
      o.previous = ls.filter(function (l) { return l.endDt; }).slice(-3).reverse().map(lotObj);
      o.today = ls.filter(function (l) { return l.endDt && l.endDt.slice(0, 10) === today; }).length;
      return o;
    }) });
  });
  M.get('/api/monitoring/lotStatus/history', function (req) {
    var q = req.params;
    var list = D.lots().filter(function (l) {
      return l.endDt && M.inRange(l.endDt, q.from, q.to) && (!q.code || l.furnaceCode === q.code) &&
        (!q.keyword || (l.lotNo + l.partNo + l.productName + l.vendorName).indexOf(q.keyword) >= 0);
    }).map(lotObj).filter(function (o) { return !q.result || q.result === 'all' || o.result === q.result; });
    list.sort(function (a, b) { return b.endAt - a.endAt; });
    return ok(list);
  });
  M.get('/api/monitoring/lotStatus', function (req) { return ok(D.lotsIn(req.params.from, req.params.to, req.params.equipCode || req.params.code)); });
  M.get('/api/monitoring/lotTracking/snapshot', function () {
    var now = Date.now();
    return ok({ polledAt: now - 800, furnaces: D.furnaces.map(function (f) {
      var o = furnaceDef(f);
      var cur = D.currentLot(f.code);
      var pitch = 45 + f.no * 2;
      o.moveCount = Math.floor(now / 1000 / pitch) % 100000;
      o.lastMoveAt = Math.floor(now / 1000 / pitch) * pitch * 1000;
      o.pitchSec = pitch;
      var ls = D.lots().filter(function (l) { return l.furnaceCode === f.code; });
      var todayLs = ls.filter(function (l) { return l.startDt.slice(0, 10) === ymd(new Date()); });
      o.inToday = todayLs.length * 4; o.outToday = Math.max(0, todayLs.filter(function (l) { return l.endDt; }).length * 4);
      o.slots = []; o.lots = {};
      for (var s = 0; s < 14; s++) o.slots.push(null);
      if (cur) {
        o.pattern = { patternCode: cur.patternCode, partNo: cur.partNo, productName: cur.productName };
        o.patternChangedAt = ms(cur.startDt);
        var lo = lotObj(cur);
        for (var z = lo.zoneFrom; z <= lo.zoneTo; z++) o.slots[z] = cur.lotNo;
        o.lots[cur.lotNo] = { lotNo: cur.lotNo, seqText: cur.lotNo.slice(-3), company: cur.vendorName, partNo: cur.partNo, productName: cur.productName, patternCode: cur.patternCode, enterAt: ms(cur.startDt), alarmPass: f.status === 'alarm' };
      }
      return o;
    }) });
  });
  M.get('/api/monitoring/lotTracking', function (req) { return ok(D.lotsIn(req.params.from, req.params.to, req.params.equipCode)); });
  function liveZones(code) {
    var now = Date.now(), o = {};
    TREND_KEYS.forEach(function (k) { o[k[0]] = trendValue(code, k[0], now); });
    return o;
  }
  M.get('/api/monitoring/prodStatus', function () {
    var today = ymd(new Date());
    return ok(D.furnaces.map(function (f) {
      var ls = D.lots().filter(function (l) { return l.furnaceCode === f.code && l.startDt.slice(0, 10) === today; });
      var done = ls.filter(function (l) { return l.endDt; });
      var cur = D.currentLot(f.code);
      var o = furnaceDef(f);
      o.lotCount = done.length; o.qty = done.reduce(function (s, l) { return s + l.qty; }, 0);
      o.weightKg = M.round(done.reduce(function (s, l) { return s + l.weightKg; }, 0), 1);
      o.currentLot = cur; o.values = liveZones(f.code);
      return o;
    }));
  });
  M.get('/api/monitoring/integrated', function (req) {
    var list = D.furnaces.filter(function (f) { return !req.params.equipCode || f.code === req.params.equipCode; });
    return ok(list.map(function (f) { var o = furnaceDef(f); o.currentLot = D.currentLot(f.code); o.values = liveZones(f.code); o.updatedAt = iso(new Date()); return o; }));
  });

  /* ═══════════════ 생산관리 목록형 API (화면은 준비중이지만 호출되면 LOT 기준 데이터로) ═══════════════ */

  M.get('/api/production/workOrder', function (req) {
    var q = req.params;
    return ok(D.lotsIn(q.from || q.startDate, q.to || q.endDate, q.equipCode).map(function (l, i) {
      return { workOrderId: i + 1, workOrderNo: 'WO-' + l.lotNo.slice(5), lotNo: l.lotNo, workDate: l.workDate, equipCode: l.furnaceCode, equipName: l.furnaceName,
        vendorName: l.vendorName, partNo: l.partNo, productName: l.productName, patternCode: l.patternCode, planQty: l.qty, planWeightKg: l.weightKg,
        status: l.endDt ? '완료' : '진행중', workerName: l.workerName, startDt: l.startDt, endDt: l.endDt };
    }));
  });
  M.get('/api/production/byItem', function (req) {
    var q = req.params, map = {};
    D.lotsIn(q.from || q.startDate, q.to || q.endDate, q.equipCode).forEach(function (l) {
      var m = map[l.productId] || (map[l.productId] = { productId: l.productId, partNo: l.partNo, productName: l.productName, vendorName: l.vendorName, lotCount: 0, qty: 0, weightKg: 0, ngCount: 0 });
      m.lotCount++; m.qty += l.qty; m.weightKg = M.round(m.weightKg + l.weightKg, 1); if (l.judge === '불합격') m.ngCount++;
    });
    return ok(Object.keys(map).map(function (k) { return map[k]; }));
  });
  M.get('/api/production/equipEff', function (req) {
    var q = req.params, out = [];
    M.daysIn(q.from || q.startDate, q.to || q.endDate).forEach(function (d) {
      D.furnaces.forEach(function (f) {
        var ls = D.lotsIn(d, d, f.code);
        var runMin = ls.reduce(function (s, l) { return s + (ms(l.endDt || sql(new Date())) - ms(l.startDt)) / MIN; }, 0);
        var avail = d === ymd(new Date()) ? (Date.now() - TODAY0) / MIN : 1440;
        out.push({ workDate: d, equipCode: f.code, equipName: f.name, runMin: Math.round(runMin), availMin: Math.round(avail), lotCount: ls.length,
          rate: M.round(Math.min(100, runMin / avail * 100), 1), weightKg: M.round(ls.reduce(function (s, l) { return s + l.weightKg; }, 0), 1) });
      });
    });
    return ok(out);
  });
  M.get('/api/production/dailyReport', function (req) {
    var q = req.params, out = [];
    M.daysIn(q.from || q.date || q.startDate, q.to || q.date || q.endDate).forEach(function (d) {
      D.furnaces.forEach(function (f) {
        var ls = D.lotsIn(d, d, f.code);
        out.push({ workDate: d, equipCode: f.code, equipName: f.name, lotCount: ls.length, qty: ls.reduce(function (s, l) { return s + l.qty; }, 0),
          weightKg: M.round(ls.reduce(function (s, l) { return s + l.weightKg; }, 0), 1), ngCount: ls.filter(function (l) { return l.judge === '불합격'; }).length });
      });
    });
    return ok(out);
  });
  M.get('/api/production/lotReport', function (req) { var q = req.params; return ok(D.lotsIn(q.from || q.startDate, q.to || q.endDate, q.equipCode)); });

  /* ═════════════════════════════ CHECK SHEET ═════════════════════════════ */

  var CS_GROUPS = ['설비문제(기계)', '설비문제(전기)', '생산', '생산관리', '영업부문', '공통문제'];
  var FB_REASONS = [
    ['DR001', '히터 단선', '고장정지', '설비문제(기계)'], ['DR002', '메쉬벨트 사행', '고장정지', '설비문제(기계)'], ['DR003', '버너 점검', '계획정지', '설비문제(기계)'],
    ['DR004', 'PLC 통신 이상', '고장정지', '설비문제(전기)'], ['DR005', '인버터 트립', '고장정지', '설비문제(전기)'],
    ['DR006', '품종 교체', '계획정지', '생산'], ['DR007', '장입 대기', '대기', '생산'], ['DR008', '계획 정지', '계획정지', '생산관리'],
    ['DR009', '수주 대기', '대기', '영업부문'], ['DR010', '정전', '기타', '공통문제'], ['DR011', '정기 점검', '계획정지', '공통문제']
  ].map(function (a, i) { return { reasonId: i + 1, reasonCode: a[0], reasonName: a[1], reasonType: a[2], reasonGroup: a[3], sortOrder: i + 1, remark: '', useYn: 'Y', regUserName: '관리자', regDt: REG, updDt: REG, useCount: 0 }; });
  var FB_DEFECTS = [['DF01', '경도 불량'], ['DF02', '변형'], ['DF03', '산화·스케일'], ['DF04', '찍힘'], ['DF05', '균열']]
    .map(function (a, i) { return { defectId: i + 1, defectCode: a[0], defectName: a[1], sortOrder: i + 1, useYn: 'Y', useCount: 0 }; });

  // 다른 담당 API가 없을 때만 쓰는 대체 라우트 (y1은 이미 로드됨 → 있으면 건너뜀, y3은 나중에 로드되어 자동으로 덮어씀)
  if (!registered('/api/base/downtime-reason')) {
    M.get('/api/base/downtime-reason', function (req) { return ok(FB_REASONS.filter(function (r) { return !req.params.useYn || r.useYn === req.params.useYn; })); });
  }
  if (!registered('/api/base/auth/1')) {
    M.get('/api/base/auth/:userId', function () {
      var paths = ['/monitoring/prodStatus', '/monitoring/integrated', '/monitoring/alarm', '/monitoring/alarmRank', '/monitoring/trend', '/monitoring/trendSettings',
        '/monitoring/lotStatus', '/monitoring/lotTracking', '/production/workOrder', '/production/byItem', '/production/equipEff', '/production/dailyReport',
        '/production/checkSheet', '/production/lotReport'];
      return ok(paths.map(function (p, i) { return { menuId: i + 1, menuPath: p, canCreate: true, canRead: true, canUpdate: true, canDelete: true }; }));
    });
  }
  M.get('/api/quality/defect-type', function (req) { return ok(FB_DEFECTS.filter(function (r) { return !req.params.useYn || r.useYn === req.params.useYn; })); });
  M.get('/api/quality/hardness/spec', function (req) { return ok(fallbackSpecs(req.params.equipCode)); });

  function fallbackSpecs(equipCode) {
    var out = [], id = 1;
    D.furnaces.forEach(function (f) {
      D.products.forEach(function (p) {
        [['표면 경도', p.surfaceHardMin, p.surfaceHardMax], ['심부 경도', p.coreHardMin, p.coreHardMax]].forEach(function (it) {
          var row = { specId: id++, equipCode: f.code, equipName: f.name, productId: p.productId, vendorName: p.vendorName, material: p.material, partNo: p.partNo, productName: p.productName,
            itemName: it[0], unit: 'HRC', lsl: it[1], usl: it[2], target: M.round((it[1] + it[2]) / 2, 1), decimals: 1, sampleSize: 3, useYn: 'Y', remark: '', regUserName: '이서연', regDt: REG, updDt: REG };
          if (!equipCode || f.code === equipCode) out.push(row);
        });
      });
    });
    return out;
  }
  function reasonsNow() { var r = callApi('/api/base/downtime-reason', { useYn: 'Y' }); return r && r.length ? r : FB_REASONS; }
  function defectsNow() { var r = callApi('/api/quality/defect-type', { useYn: 'Y' }); return r && r.length ? r : FB_DEFECTS; }
  function specFor(equipCode, partNo, itemName) {
    var list = callApi('/api/quality/hardness/spec', { equipCode: equipCode, useYn: 'Y' }) || fallbackSpecs(equipCode);
    for (var i = 0; i < list.length; i++) if (list[i].partNo === partNo && String(list[i].itemName).replace(/\s/g, '') === String(itemName).replace(/\s/g, '') && (!list[i].equipCode || list[i].equipCode === equipCode)) return list[i];
    var p = null;
    D.products.forEach(function (x) { if (x.partNo === partNo) p = x; });
    if (!p) return null;
    return itemName === '표면 경도' ? { specId: null, lsl: p.surfaceHardMin, usl: p.surfaceHardMax, unit: 'HRC' } : { specId: null, lsl: p.coreHardMin, usl: p.coreHardMax, unit: 'HRC' };
  }
  function productByPart(partNo) { for (var i = 0; i < D.products.length; i++) if (D.products[i].partNo === partNo) return D.products[i]; return null; }
  function hardnessOf(rowId, equipCode, partNo, itemName, values, measDt) {
    var spec = specFor(equipCode, partNo, itemName);
    var vals = values.filter(function (v) { return v != null; });
    var ng = spec && vals.some(function (v) { return (spec.lsl != null && v < spec.lsl) || (spec.usl != null && v > spec.usl); });
    return { itemName: itemName, specId: spec ? spec.specId : null, measId: rowId * 10 + (itemName === '표면 경도' ? 1 : 2), judgement: ng ? '불합격' : '합격', values: values, measDt: measDt };
  }

  var SIGN_SLOTS = ['담당', '검토', '승인', '확인', '설비관리', '품질관리', '품질보증', '생산관리'];
  var SIGNER = { 담당: '김태성', 검토: '박민재', 승인: '관리자', 확인: '이서연', 설비관리: '오동석', 품질관리: '한지영', 품질보증: '이서연', 생산관리: '박민재' };
  var HEAT_PREFIX = { SCM440: 'SH', SCM420H: 'SH', SUJ2: 'SB', SCr420H: 'HY', SCM435: 'PC', S45C: 'DS', SCM415: 'SH' };

  var csSeeded = null;
  function seedCheckSheets() {
    if (csSeeded) return csSeeded;
    var now = Date.now();
    var reasons = reasonsNow().filter(function (r) { return r.reasonGroup && r.useYn !== 'N'; });
    var defects = defectsNow().filter(function (d) { return d.useYn !== 'N'; });
    var sheets = [], rows = [], signs = [], logs = [];
    var sheetId = 1, rowId = 1, signId = 1, auditId = 1;
    function log(sh, row, target, action, changes, user, at) {
      logs.push({ auditId: auditId++, sheetId: sh.sheetId, equipCode: sh.equipCode, equipName: sh.equipName, prodDate: sh.prodDate, rowId: row ? row.rowId : null, rowNo: row ? row.rowNo : null,
        partNo: row ? row.partNo : null, target: target, action: action, changes: JSON.stringify(changes), userId: user.loginId, userName: user.userName, clientIp: ipOf(user), regDt: iso(new Date(at)) });
    }
    M.days().forEach(function (day, di) {
      var d0 = ms(day);
      D.furnaces.forEach(function (f) {
        var lots = D.lots().filter(function (l) { return l.furnaceCode === f.code && l.endDt && l.endDt.slice(0, 10) === day; });
        if (!lots.length) return;
        var r = M.rng('y2-cs-' + f.code + '-' + day);
        var sh = { sheetId: sheetId++, equipCode: f.code, equipName: f.name, prodDate: day, workerDay: '김태성, 박민재', workerNight: '최현우', qcName: r.pick(['이서연', '한지영']),
          regUserId: 'tskim', regUserName: '김태성', regDt: iso(new Date(d0 + 6 * 3600000 + r.int(5, 40) * MIN)), updDt: null };
        sheets.push(sh);
        log(sh, null, '머리', '입력', [{ f: '주간 작업자', b: null, a: sh.workerDay }, { f: '야간 작업자', b: null, a: sh.workerNight }, { f: '공정QC 담당자', b: null, a: sh.qcName }], userByName('김태성'), ms(sh.regDt));
        var downLeft = r.int(1, 2);
        lots.forEach(function (l, i) {
          var p = productByPart(l.partNo);
          var out = ms(l.endDt);
          var night = new Date(out).getHours() < 8 || new Date(out).getHours() >= 20;
          var row = {
            rowId: rowId++, sheetId: sh.sheetId, rowNo: i + 1, outTime: hm(new Date(out)), vendor: l.vendorName, partNo: l.partNo, productName: l.productName, specText: p ? p.spec : '',
            lotNo: l.lotNo.slice(5, 11) + '-' + f.no + l.lotNo.slice(-3), qtyKg: l.weightKg, defectQty: null, defectCode: '', downCode: '', downStart: '', downEnd: '', material: l.material,
            heatLotNo: (HEAT_PREFIX[l.material] || 'SH') + M.fmt(M.addDays(new Date(d0), -r.int(12, 40)), 'MM') + '-' + r.int(11, 89),
            worker: l.workerName, leader: night ? '최현우' : '김태성', qc: sh.qcName, downtimeId: null, ncId: null, ncNo: null, ncStatus: null, hardness: [], updDt: iso(new Date(out))
          };
          // 경도: 출로 10~25분 후 측정 (아직이면 비어 있음)
          var measAt = out + r.int(10, 25) * MIN;
          if (measAt <= now) {
            var nS = r() < 0.25 ? 5 : 3, nC = r() < 0.3 ? 3 : 2;
            var sv = [], cv = [], k;
            for (k = 0; k < nS; k++) sv.push(M.round(r.normal(l.surfaceHard, 0.45), 1));
            for (k = 0; k < nC; k++) cv.push(M.round(r.normal(l.coreHard, 0.6), 1));
            if (l.judge === '불합격') {
              if (l.surfaceHard < l.surfaceHardMin || l.surfaceHard > l.surfaceHardMax) sv[1] = l.surfaceHard; else cv[0] = l.coreHard;
            }
            while (sv.length < 5) sv.push(null);
            while (cv.length < 5) cv.push(null);
            var mdt = iso(new Date(measAt));
            row.hardness = [hardnessOf(row.rowId, f.code, l.partNo, '표면 경도', sv, mdt), hardnessOf(row.rowId, f.code, l.partNo, '심부 경도', cv, mdt)];
          }
          // 불량
          if (defects.length && (l.judge === '불합격' || r() < 0.06)) {
            row.defectQty = l.judge === '불합격' ? r.int(8, 30) : r.int(1, 6);
            row.defectCode = l.judge === '불합격' ? defects[0].defectCode : r.pick(defects.slice(1).length ? defects.slice(1) : defects).defectCode;
          }
          // 비가동
          if (reasons.length && downLeft > 0 && i > 1 && r() < 0.18) {
            downLeft--;
            var rs = r.pick(reasons);
            var ds = out - r.int(40, 80) * MIN;
            row.downCode = rs.reasonCode; row.downStart = hm(new Date(ds)); row.downEnd = hm(new Date(ds + r.int(10, 35) * MIN));
          }
          rows.push(row);
          var wu = userByName(row.worker);
          log(sh, row, '통', '추가', [{ f: 'Part No', b: null, a: row.partNo }, { f: '작지 No', b: null, a: row.lotNo }, { f: '출로시간', b: null, a: row.outTime }], wu, out + 40000);
          log(sh, row, '통', '입력', [{ f: '생산량(Kg)', b: null, a: String(row.qtyKg) }, { f: '재질', b: null, a: row.material }, { f: '열처리 LOT', b: null, a: row.heatLotNo }], wu, out + 95000);
          if (row.downCode) log(sh, row, '통', '입력', [{ f: '비가동', b: null, a: row.downCode + ' ' + row.downStart + '~' + row.downEnd }], wu, out + 150000);
          if (row.defectCode) log(sh, row, '통', '입력', [{ f: '불량 수량', b: null, a: String(row.defectQty) }, { f: '불량 구분', b: null, a: row.defectCode }], userByName(sh.qcName), Math.min(now - MIN, measAt + 3 * MIN));
          if (row.hardness.length) {
            var qu = userByName(sh.qcName);
            row.hardness.forEach(function (h) {
              log(sh, row, '경도', '입력', [{ f: h.itemName, b: null, a: h.values.filter(function (v) { return v != null; }).join(', ') }], qu, measAt);
            });
            if (r() < 0.08) {
              var before = String(row.qtyKg);
              row.qtyKg = M.round(row.qtyKg - r.int(5, 20), 1);
              log(sh, row, '통', '수정', [{ f: '생산량(Kg)', b: before, a: String(row.qtyKg) }], userByName(row.leader), Math.min(now - MIN, measAt + r.int(5, 30) * MIN));
            }
          }
        });
        // 결재 서명 — 지난 시트는 다음날 아침에 결재, 오늘 시트는 담당만(오후)
        var slots = di === 0 ? SIGN_SLOTS.slice() : di === 1 ? (f.no <= 3 ? ['담당', '검토', '승인', '확인', '설비관리', '품질관리'] : ['담당', '검토', '확인', '품질관리']) : (new Date(now).getHours() >= 15 ? ['담당'] : []);
        var tBase = di < 2 ? ms(M.addDays(new Date(d0), 1)) + 8 * 3600000 + r.int(5, 30) * MIN : d0 + 15 * 3600000 + r.int(0, 20) * MIN;
        slots.forEach(function (s, k) {
          var at = Math.min(now - (8 - k) * 2 * MIN, tBase + k * r.int(6, 25) * MIN);
          var u = userByName(SIGNER[s]);
          signs.push({ signId: signId++, sheetId: sh.sheetId, slot: s, userId: u.loginId, signName: u.userName, signImg: null, signDt: iso(new Date(at)) });
          log(sh, null, '서명', '서명', [{ f: s, b: null, a: u.userName + ' (이름)' }], u, at);
        });
      });
    });
    csSeeded = { sheets: sheets, rows: rows, signs: signs, logs: logs };
    return csSeeded;
  }
  var csSheetDb = M.db('y2_csSheets', function () { return seedCheckSheets().sheets; }, 'sheetId');
  var csRowDb = M.db('y2_csRows', function () { return seedCheckSheets().rows; }, 'rowId');
  var csSignDb = M.db('y2_csSigns', function () { return seedCheckSheets().signs; }, 'signId');
  var csLogDb = M.db('y2_csLogs', function () { return seedCheckSheets().logs; }, 'auditId');
  var csSetDb = M.db('y2_csSettings', function () {
    return [{ id: 'subtitle', value: '연속 메쉬벨트로 · 소입/소려' }, { id: 'note', value: '· 4호기 퀜칭로 3존 히터 점검 요청 (설비보전팀 확인 중)\n· 6호기 정기 점검 — 버너 노즐 청소 및 메쉬벨트 장력 조정' }];
  }, 'id');
  function setting(k) { var s = csSetDb.find(k); return s ? s.value : ''; }

  function furnaceOf(code) { for (var i = 0; i < D.furnaces.length; i++) if (D.furnaces[i].code === code) return D.furnaces[i]; return null; }
  function sheetOf(code, date) { var s = csSheetDb.all().filter(function (x) { return x.equipCode === code && x.prodDate === date; }); return s[0] || null; }
  function rowsOf(sheetId) { return csRowDb.all().filter(function (r) { return r.sheetId === sheetId; }).sort(function (a, b) { return a.rowNo - b.rowNo; }); }
  function signsOf(sheetId) { return csSignDb.all().filter(function (s) { return s.sheetId === sheetId; }).sort(function (a, b) { return SIGN_SLOTS.indexOf(a.slot) - SIGN_SLOTS.indexOf(b.slot); }); }
  function whoOf(b) { var u = null; D.users.forEach(function (x) { if (x.loginId === b.userId) u = x; }); return { loginId: b.userId || (u && u.loginId) || 'ez', userName: b.userName || (u && u.userName) || '관리자', userId: u ? u.userId : 1 }; }
  function addLog(sh, row, target, action, changes, b) {
    if (!changes.length) return;
    var w = whoOf(b || {});
    csLogDb.insert({ auditId: csLogDb.nextId(), sheetId: sh.sheetId, equipCode: sh.equipCode, equipName: sh.equipName, prodDate: sh.prodDate, rowId: row ? row.rowId : null, rowNo: row ? row.rowNo : null,
      partNo: row ? row.partNo : null, target: target, action: action, changes: JSON.stringify(changes), userId: w.loginId, userName: w.userName, clientIp: ipOf(w), regDt: iso(new Date()) });
  }
  function diff(ch, f, b, a) { b = b == null ? '' : String(b); a = a == null ? '' : String(a); if (b !== a) ch.push({ f: f, b: b || null, a: a || null }); }
  function kindOf(ch) { if (ch.every(function (c) { return !c.b; })) return '입력'; if (ch.every(function (c) { return !c.a; })) return '삭제'; return '수정'; }
  function ensureSheet(code, date, b) {
    var sh = sheetOf(code, date);
    if (sh) return sh;
    var f = furnaceOf(code);
    var w = whoOf(b || {});
    return csSheetDb.insert({ sheetId: csSheetDb.nextId(), equipCode: code, equipName: f ? f.name : code, prodDate: date, workerDay: '', workerNight: '', qcName: '',
      regUserId: w.loginId, regUserName: w.userName, regDt: iso(new Date()), updDt: null });
  }
  function sheetSummary(sh) {
    var rs = rowsOf(sh.sheetId);
    var o = {}; for (var k in sh) o[k] = sh[k];
    o.rowCount = rs.length;
    o.qtySum = M.round(rs.reduce(function (s, r) { return s + (+r.qtyKg || 0); }, 0), 1);
    o.defectSum = rs.reduce(function (s, r) { return s + (+r.defectQty || 0); }, 0);
    o.downCount = rs.filter(function (r) { return r.downCode; }).length;
    o.signCount = signsOf(sh.sheetId).length;
    o.ngCount = rs.filter(function (r) { return (r.hardness || []).some(function (h) { return h.judgement === '불합격'; }); }).length;
    return o;
  }
  function locked(sh) { return signsOf(sh.sheetId).some(function (s) { return s.slot === '승인'; }); }
  var LOCK_MSG = '승인된 시트입니다. 고치려면 승인 서명을 취소하세요.';

  var CS = '/api/production/checkSheet';
  M.get(CS + '/equips', function (req) {
    var date = req.params.date || ymd(new Date());
    return ok(D.furnaces.map(function (f) {
      var sh = sheetOf(f.code, date);
      var rs = sh ? rowsOf(sh.sheetId) : [];
      var parts = {}; rs.forEach(function (r) { if (r.partNo) parts[r.partNo] = 1; });
      return { equipCode: f.code, equipName: f.name, rowCount: rs.length, partCount: Object.keys(parts).length };
    }));
  });
  M.get(CS + '/sheets', function (req) {
    var q = req.params;
    return ok(csSheetDb.all().filter(function (s) { return (!q.equipCode || s.equipCode === q.equipCode) && M.inRange(s.prodDate, q.from, q.to); })
      .sort(function (a, b) { return a.prodDate < b.prodDate ? 1 : -1; }).map(sheetSummary));
  });
  M.get(CS + '/board', function (req) {
    var code = req.params.equipCode, date = req.params.date || ymd(new Date());
    var f = furnaceOf(code);
    if (!f) return M.res(400, D.fail('설비를 찾을 수 없습니다.'));
    var sh = sheetOf(code, date);
    return ok({ equipCode: f.code, equipName: f.name, prodDate: date, today: ymd(new Date()), sheet: sh ? sheetSummary(sh) : null,
      rows: sh ? rowsOf(sh.sheetId) : [], signs: sh ? signsOf(sh.sheetId) : [], subtitle: setting('subtitle'), note: setting('note') });
  });
  M.get(CS + '/products', function () {
    return ok(D.products.map(function (p) {
      return { productId: p.productId, partNo: p.partNo, productName: p.productName, specText: p.spec, material: p.material, vendor: p.vendorName, chargeWeightKg: p.chargeWeightKg,
        specCount: 2, patternCount: D.patterns.filter(function (t) { return t.productId === p.productId; }).length };
    }));
  });
  M.post(CS + '/row', function (req) {
    var b = req.body || {};
    var sh = ensureSheet(b.equipCode, b.prodDate, b);
    if (locked(sh)) return M.res(400, D.fail(LOCK_MSG));
    var rs = rowsOf(sh.sheetId);
    var src = b.copyFromRowId ? csRowDb.find(b.copyFromRowId) : rs[rs.length - 1];
    var row = { rowId: csRowDb.nextId(), sheetId: sh.sheetId, rowNo: (rs.length ? rs[rs.length - 1].rowNo : 0) + 1, outTime: '', vendor: '', partNo: '', productName: '', specText: '', lotNo: '',
      qtyKg: null, defectQty: null, defectCode: '', downCode: '', downStart: '', downEnd: '', material: '', heatLotNo: '', worker: '', leader: '', qc: '',
      downtimeId: null, ncId: null, ncNo: null, ncStatus: null, hardness: [], updDt: iso(new Date()) };
    if (src) {
      ['vendor', 'partNo', 'productName', 'specText', 'material', 'heatLotNo', 'worker', 'leader', 'qc'].forEach(function (k) { row[k] = src[k]; });
      var lot = src.lotNo || '';
      if (lot.lastIndexOf('-') > 0) row.lotNo = lot.slice(0, lot.lastIndexOf('-') + 1);
    }
    if (b.prodDate === ymd(new Date())) row.outTime = hm(new Date());
    csRowDb.insert(row);
    var ch = []; diff(ch, 'Part No', null, row.partNo); diff(ch, '작지 No', null, row.lotNo); diff(ch, '출로시간', null, row.outTime);
    addLog(sh, row, '통', '추가', ch.length ? ch : [{ f: 'No', b: null, a: String(row.rowNo) }], b);
    return ok(row);
  });
  M.put(CS + '/row/:id', function (req) {
    var b = req.body || {};
    var old = csRowDb.find(+req.params.id);
    if (!old) return M.res(404, D.fail('행을 찾을 수 없습니다.'));
    var sh = csSheetDb.find(old.sheetId);
    if (locked(sh)) return M.res(400, D.fail(LOCK_MSG));
    if ((old.hardness || []).length && b.partNo !== undefined && (b.partNo || '') !== (old.partNo || '')) return M.res(400, D.fail('경도 값이 있어 품번을 바꿀 수 없습니다. 경도 값을 먼저 지워주세요.'));
    var t = /^([01]?\d|2[0-3]):[0-5]\d$/;
    var bad = ['outTime', 'downStart', 'downEnd'].filter(function (k) { return b[k] && !t.test(b[k]); });
    if (bad.length) return M.res(400, D.fail('시각은 00:00 형식으로 넣어주세요.'));
    var patch = {};
    ['outTime', 'vendor', 'partNo', 'productName', 'specText', 'lotNo', 'qtyKg', 'defectQty', 'defectCode', 'downCode', 'downStart', 'downEnd', 'material', 'heatLotNo', 'worker', 'leader', 'qc']
      .forEach(function (k) { if (b[k] !== undefined) patch[k] = b[k] == null ? (k === 'qtyKg' || k === 'defectQty' ? null : '') : b[k]; });
    var ch = [];
    diff(ch, '출로시간', old.outTime, patch.outTime); diff(ch, 'Part No', old.partNo, patch.partNo); diff(ch, '작지 No', old.lotNo, patch.lotNo);
    diff(ch, '생산량(Kg)', old.qtyKg, patch.qtyKg); diff(ch, '불량 수량', old.defectQty, patch.defectQty); diff(ch, '불량 구분', old.defectCode, patch.defectCode);
    var dt = function (r) { return r.downCode ? r.downCode + (r.downStart ? ' ' + r.downStart + '~' + (r.downEnd || '') : '') : ''; };
    var merged = {}; var k; for (k in old) merged[k] = old[k]; for (k in patch) merged[k] = patch[k];
    diff(ch, '비가동', dt(old), dt(merged)); diff(ch, '재질', old.material, patch.material); diff(ch, '열처리 LOT', old.heatLotNo, patch.heatLotNo);
    diff(ch, '작업자', old.worker, patch.worker); diff(ch, '조장', old.leader, patch.leader); diff(ch, '공정QC', old.qc, patch.qc);
    patch.updDt = iso(new Date());
    var row = csRowDb.update(old.rowId, patch);
    if (ch.length) addLog(sh, row, '통', kindOf(ch), ch, b);
    return ok(row);
  });
  M.post(CS + '/row/:id/delete', function (req) {
    var old = csRowDb.find(+req.params.id);
    if (!old) return ok(null);
    var sh = csSheetDb.find(old.sheetId);
    if (locked(sh)) return M.res(400, D.fail(LOCK_MSG));
    csRowDb.remove(old.rowId);
    addLog(sh, old, '통', '삭제', [{ f: 'Part No', b: old.partNo || null, a: null }, { f: '작지 No', b: old.lotNo || null, a: null }].filter(function (c) { return c.b; }).concat([{ f: 'No', b: String(old.rowNo), a: null }]), req.body);
    return ok(null);
  });
  M.put(CS + '/row/:id/hardness', function (req) {
    var b = req.body || {};
    var row = csRowDb.find(+req.params.id);
    if (!row) return M.res(404, D.fail('행을 찾을 수 없습니다.'));
    var sh = csSheetDb.find(row.sheetId);
    if (locked(sh)) return M.res(400, D.fail(LOCK_MSG));
    if (!row.partNo) return M.res(400, D.fail('Part No를 먼저 고르세요.'));
    var vals = (b.values || []).slice(0, 5).map(function (v) { return v == null || v === '' ? null : +v; });
    while (vals.length < 5) vals.push(null);
    var hs = (row.hardness || []).filter(function (h) { return h.itemName !== b.itemName; });
    var before = (row.hardness || []).filter(function (h) { return h.itemName === b.itemName; })[0];
    var bt = before ? before.values.filter(function (v) { return v != null; }).join(', ') : '';
    var at = vals.filter(function (v) { return v != null; }).join(', ');
    if (vals.some(function (v) { return v != null; })) hs.push(hardnessOf(row.rowId, sh.equipCode, row.partNo, b.itemName, vals, iso(new Date())));
    hs.sort(function (a, c) { return a.itemName === '표면 경도' ? -1 : c.itemName === '표면 경도' ? 1 : 0; });
    var upd = csRowDb.update(row.rowId, { hardness: hs, updDt: iso(new Date()) });
    var ch = []; diff(ch, b.itemName, bt, at);
    if (ch.length) addLog(sh, upd, '경도', kindOf(ch), ch, b);
    return ok(upd);
  });
  M.put(CS + '/head', function (req) {
    var b = req.body || {};
    var sh = ensureSheet(b.equipCode, b.prodDate, b);
    if (locked(sh)) return M.res(400, D.fail(LOCK_MSG));
    var ch = []; diff(ch, '주간 작업자', sh.workerDay, b.workerDay); diff(ch, '야간 작업자', sh.workerNight, b.workerNight); diff(ch, '공정QC 담당자', sh.qcName, b.qcName);
    var upd = csSheetDb.update(sh.sheetId, { workerDay: b.workerDay || '', workerNight: b.workerNight || '', qcName: b.qcName || '', updDt: iso(new Date()) });
    if (ch.length) addLog(sh, null, '머리', kindOf(ch), ch, b);
    return ok(sheetSummary(upd));
  });
  M.post(CS + '/sign', function (req) {
    var b = req.body || {};
    if (SIGN_SLOTS.indexOf(b.slot) < 0) return M.res(400, D.fail('서명 칸이 올바르지 않습니다.'));
    var sh = ensureSheet(b.equipCode, b.prodDate, b);
    var cur = signsOf(sh.sheetId).filter(function (s) { return s.slot === b.slot; })[0];
    var w = whoOf(b);
    if (b.on === false || b.on === 'false') {
      if (cur) {
        if (cur.userId && cur.userId !== w.loginId) return M.res(400, D.fail('서명한 본인(' + cur.signName + ')만 취소할 수 있습니다.'));
        csSignDb.remove(cur.signId);
        addLog(sh, null, '서명', '서명취소', [{ f: b.slot, b: cur.signName, a: null }], b);
      }
    } else {
      var name = (b.signName || w.userName || '').trim();
      if (!name && !b.signImg) return M.res(400, D.fail('서명하거나 이름을 입력해주세요.'));
      if (cur) csSignDb.remove(cur.signId);
      csSignDb.insert({ signId: csSignDb.nextId(), sheetId: sh.sheetId, slot: b.slot, userId: w.loginId, signName: name, signImg: b.signImg || null, signDt: iso(new Date()) });
      addLog(sh, null, '서명', '서명', [{ f: b.slot, b: null, a: name + (b.signImg ? ' (손 서명)' : ' (이름)') }], b);
    }
    return ok(signsOf(sh.sheetId));
  });
  M.put(CS + '/setting', function (req) {
    var b = req.body || {};
    if (b.subtitle != null) csSetDb.upsert({ id: 'subtitle', value: String(b.subtitle).slice(0, 100) });
    if (b.note != null) csSetDb.upsert({ id: 'note', value: String(b.note) });
    return ok({ subtitle: setting('subtitle'), note: setting('note') });
  });
  M.get(CS + '/audit', function (req) {
    var q = req.params;
    var to = q.to || ymd(new Date()), from = q.from || to;
    if (from > to) { var x = from; from = to; to = x; }
    var sheets = csSheetDb.all().filter(function (s) { return M.inRange(s.prodDate, from, to) && (!q.equipCode || s.equipCode === q.equipCode); })
      .sort(function (a, b) { return a.prodDate < b.prodDate ? 1 : a.prodDate > b.prodDate ? -1 : a.equipCode < b.equipCode ? -1 : 1; }).map(sheetSummary);
    var ids = {}; sheets.forEach(function (s) { ids[s.sheetId] = 1; });
    var signs = csSignDb.all().filter(function (s) { return ids[s.sheetId]; }).map(function (s) { return { sheetId: s.sheetId, slot: s.slot, userId: s.userId, signName: s.signName, signDt: s.signDt, hasImg: !!s.signImg }; });
    var logs = csLogDb.all().filter(function (l) { return ids[l.sheetId]; }).sort(function (a, b) { return a.regDt < b.regDt ? 1 : a.regDt > b.regDt ? -1 : b.auditId - a.auditId; });
    return ok({ from: from, to: to, sheets: sheets, signs: signs, logs: logs });
  });
})();
