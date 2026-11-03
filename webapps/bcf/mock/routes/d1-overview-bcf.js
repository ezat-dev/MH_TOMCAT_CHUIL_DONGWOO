/* routes/d1-overview-bcf.js
 * 포털(main) / 로그인 / OVERVIEW-1·2 / BCF 1~12호기 상세 작화 화면용 목업.
 *
 * 핵심: GET /monitor/snapshot — 서버 PLC 캐시(MonitorCacheService) 스냅샷 대체.
 *   원본 화면들은 DOM 클래스(bcfN_주소, BCFN_주소, bcfN_s_주소, data-tag …)를 스캔해 키를 만들고
 *   스냅샷 맵에서 값을 꺼내 쓴다. 화면마다 키/스케일 규칙이 제각각이라, 여기서는 요청한 화면의
 *   DOM을 똑같이 스캔해 "그 화면이 쓰는 키"만 골라, 주변 라벨(행 제목·열 제목·항목명·클래스명)로
 *   의미(온도/CP/시간/가스/DT/비트 역할)를 추정한 뒤 호기별 공정 모델(MOCK.D.currentCharge 레시피)
 *   에서 값을 만든다.
 *   - 워드 값은 화면 포맷터(×0.001 CP 스케일 등)를 우회하도록 "표시 문자열 + U+200B"로 보낸다
 *     (Number() → NaN → 원본 코드가 문자열을 그대로 표시). DT(정수, 로직에서 Number 사용)는 숫자.
 *   - 비트 값은 클래스 역할(open/close/alarm/fan/motor/fire/tray/auto/manual …)과 호기 상태
 *     (가동/대기/정지)로 정한다.
 */
(function () {
  var M = window.MOCK, D = M.D;
  var ZW = '​';

  /* ───────────────────── 호기별 공정 모델 ───────────────────── */

  // 공정 구간 비율 (진행률 기준)
  var STAGES = [
    { type: 'heat',   from: 0.00, to: 0.15 },
    { type: 'carb',   from: 0.15, to: 0.58 },
    { type: 'diff',   from: 0.58, to: 0.84 },
    { type: 'cool',   from: 0.84, to: 0.95 },
    { type: 'quench', from: 0.95, to: 1.00 }
  ];

  function lastCharge(no) {
    var cs = D.charges(), last = null;
    for (var i = 0; i < cs.length; i++) if (cs[i].furnace_no === +no) last = cs[i];
    return last;
  }

  // 시각 t 기준 호기 상태 모델
  function model(no, t) {
    t = t || new Date();
    no = +no;
    var state = D.furnaceState(no);
    var ch = D.currentCharge(no);
    var ref = ch || lastCharge(no) || { temp: 920, cp: 0.85, recipe: 'CQ-920-08', hours: 7.5 };
    var T = ref.temp, CP = ref.cp;
    var m = { no: no, state: state, charge: ch, T: T, CP: CP, total: 0, elapsed: 0, progress: 0, stage: 'idle', continuous: no === 6 || no === 11 };
    var k = 'bcf' + no;
    if (state === '가동' && ch) {
      var st = M.toDate(ch.start_time), en = M.toDate(ch.plan_end_time);
      m.total = Math.max(60, Math.round((en - st) / 60000));
      m.elapsed = Math.max(0, Math.min(m.total, (t - st) / 60000));
      m.progress = m.elapsed / m.total;
      m.remain = Math.max(0, Math.round(m.total - m.elapsed));
      for (var i = 0; i < STAGES.length; i++) if (m.progress >= STAGES[i].from && m.progress < STAGES[i].to) { m.stage = STAGES[i].type; m.stageFrac = (m.progress - STAGES[i].from) / (STAGES[i].to - STAGES[i].from); }
      if (m.stage === 'idle') { m.stage = 'quench'; m.stageFrac = 0.99; }
      // 온도 SP/PV
      var stg = m.stage === 'quench' ? 'cool' : m.stage;
      if (m.continuous) stg = 'carb';
      var sp = stageTempSP(stg, T, 1);
      var pv;
      if (m.stage === 'heat' && !m.continuous) pv = 830 + (T - 830) * Math.min(1, m.stageFrac * 1.15) + M.wave(k + 'tH', t, 0, 1.2, 0.4, 7);
      else pv = sp + M.wave(k + 'tp', t, 0.3, 1.6, 0.5, 23);
      m.tempSP = sp; m.tempPV = pv;
      m.cpSP = stg === 'heat' ? M.round(CP - 0.1, 2) : m.continuous ? M.round(CP + 0.2, 2) : stageCpSP(stg, CP, 1);
      m.cpPV = (m.stage === 'heat' && !m.continuous) ? 0.55 + (m.cpSP - 0.55) * m.stageFrac + M.wave(k + 'cH', t, 0, 0.006, 0.002, 9)
                                  : m.cpSP + M.wave(k + 'cp', t, -0.002, 0.008, 0.002, 17);
      m.oilSP = 80;
      m.oilPV = (m.stage === 'quench' ? 92 : 80) + M.wave(k + 'oil', t, 0.4, 1.4, 0.3, 41);
      // 활성 알람과 일치: 2호기 유조 온도 상승, 5호기 CP 편차 이탈
      if (no === 2) m.oilPV = 93.5 + M.wave(k + 'oilA', t, 0, 0.8, 0.2, 29);
      if (no === 5 && m.cpSP > 0) m.cpPV = m.cpSP - 0.16 + M.wave(k + 'cpA', t, 0, 0.006, 0.002, 11);
    } else if (state !== '정지') {   // 대기, 또는 가동 호기의 배치 교체(장입 대기) 구간 — 850℃ 보온
      m.stage = 'hold';
      m.tempSP = 850; m.tempPV = 850 + M.wave(k + 'tp', t, 0.2, 1.2, 0.4, 31);
      m.cpSP = 0.80; m.cpPV = 0.80 + M.wave(k + 'cp', t, -0.004, 0.006, 0.002, 19);
      m.oilSP = 80; m.oilPV = 78 + M.wave(k + 'oil', t, 0, 1.0, 0.2, 47);
      m.remain = 0;
    } else { // 정지 — 열전대 단선으로 정지, 마지막 배치 종료 후 자연 냉각
      m.stage = 'stop';
      var lc = lastCharge(no), endT = lc && lc.end_time ? M.toDate(lc.end_time) : M.addMinutes(t, -600);
      var hrs = Math.max(0, (t - endT) / 3600000);
      m.tempSP = 0; m.tempPV = 24 + (850 - 24) * Math.exp(-hrs / 5.5) + M.wave(k + 'tp', t, 0, 0.6, 0.2, 120);
      m.cpSP = 0; m.cpPV = 0;
      m.oilSP = 0; m.oilPV = 27 + M.wave(k + 'oil', t, 0, 0.5, 0.1, 120);
      m.remain = 0;
    }
    // 활성 알람 일치 (상태 무관): 2호기 유조 온도 상승
    if (no === 2 && state !== '정지') m.oilPV = 93.5 + M.wave(k + 'oilA', t, 0, 0.8, 0.2, 29);
    return m;
  }

  function stageTempSP(type, T, idx) {
    if (type === 'heat') return idx === 0 && T > 880 ? 880 : T;
    if (type === 'cool') return T >= 900 ? 850 : 830;
    if (type === 'quench') return 80;
    return T;
  }
  function stageCpSP(type, CP, idx) {
    if (type === 'heat') return 0;
    if (type === 'carb') return M.round(CP + (idx === 0 ? 0.30 : 0.22), 2);
    if (type === 'diff') return M.round(CP + (idx === 0 ? 0.05 : 0), 2);
    if (type === 'cool') return M.round(CP - 0.05, 2);
    return 0;
  }
  function zoneType(name) {
    name = String(name || '');
    if (/승온|예열|가열/.test(name)) return 'heat';
    if (/침탄/.test(name)) return 'carb';
    if (/확산|균열/.test(name)) return 'diff';
    if (/강온/.test(name)) return 'cool';
    if (/소입|소인|유조|로냉|냉각|드레|드랍|드롭|퀜칭/.test(name)) return 'quench';
    return 'carb';
  }

  /* ───────────────────── DOM 스캔 → 키/의미 ───────────────────── */

  var TAGRE = /^(bcf|BCF)(\d+)_([A-Za-z0-9_]+)$/;
  var cache = null;

  function pageInfo() {
    var p = location.pathname;
    var bm = p.match(/\/BCF\/BCF_(\d+)/);
    return { path: p, bcf: bm ? +bm[1] : 0, monitor: /\/main\/monitor2?$/.test(p) };
  }

  function txt(el) { return el ? String(el.textContent || '').replace(/\s+/g, ' ').trim() : ''; }

  // 표시용(워드) 요소인지
  function isDisplayEl(el) {
    if (el.tagName === 'IMG') return false;
    var c = typeof el.className === 'string' ? el.className : '';
    if (/zbox|tp-val|tpi-val|tm-cell/.test(c)) return true;
    var t = txt(el);
    return el.children.length === 0 && (t === '--' || t === 'DT' || /^bcf/i.test(t));
  }

  // 워드 요소의 의미 판정 → {kind, sp, zone, zidx, zcount}
  function classifyWord(el) {
    var c = typeof el.className === 'string' ? el.className : '';
    var tr = el.closest && el.closest('tr');
    if (tr && tr.closest('tbody')) {
      var label = txt(tr.children[0]);
      var td = el.closest('td');
      var idx = td ? Array.prototype.indexOf.call(tr.children, td) : -1;
      var tbl = tr.closest('table');
      var ths = tbl ? tbl.querySelectorAll('thead tr:first-child th') : [];
      var zname = ths[idx] ? txt(ths[idx]) : '';
      var kind = /시간/.test(label) ? 'time' : /온도/.test(label) ? 'temp' : /^CP/i.test(label) ? 'cp'
        : /NH3|암모니아/i.test(label) ? 'nh3' : /C3H8|프로판|RX|가스/i.test(label) ? 'c3h8' : /AIR|공기/i.test(label) ? 'air' : 'temp';
      // 같은 타입 구간이 여러 개면 순번
      var ztype = zoneType(zname), zi = 0, zc = 0;
      for (var j = 1; j < ths.length; j++) {
        if (zoneType(txt(ths[j])) === ztype) { if (j < idx) zi++; zc++; }
      }
      return { kind: kind, sp: /SP/.test(label), zone: ztype, zidx: zi, zcount: zc || 1, zname: zname, table: true, oil: kind === 'temp' && ztype === 'quench' };
    }
    // 메인 모니터 tm-cell
    if (/tm-cell/.test(c)) {
      var name = '';
      var item = el.closest('.tm-item');
      if (item) name = txt(item.querySelector('.tm-item-name'));
      else {
        var row = el.closest('.tm-row'), grp = el.closest('.tm-group');
        var hdr = grp && grp.querySelector('.tm-ch-header');
        var i2 = row ? Array.prototype.indexOf.call(row.children, el) : -1;
        if (hdr && hdr.children[i2]) name = txt(hdr.children[i2]);
      }
      var isSet = /tm-set/.test(c) || !!(el.closest('.tm-set'));
      return wordFromName(name, isSet);
    }
    // 온도CP 그리드 (BCF1~5,10: tp-grid)
    var dc = el.closest('.tp-dc');
    if (dc && dc.parentNode) {
      var kids = dc.parentNode.children, pos = Array.prototype.indexOf.call(kids, dc), cols = 4;
      var head = kids[pos % cols], rowLbl = kids[pos - (pos % cols)];
      return wordFromName(txt(head), /SP/.test(txt(rowLbl)));
    }
    if (/(^|[\s-])dt([\s-]|$)/.test(c) && !/tpi-val|tp-val/.test(c)) return { kind: 'dt', dtRole: /belt/.test(c) ? 'belt' : (c.match(/dt-(\d)/) || [])[1] || 'main' };
    // 한 줄형 (라벨 span → 값 div 가 형제로 반복)
    var sib = el.previousElementSibling;
    for (var s = 0; s < 3 && sib; s++, sib = sib.previousElementSibling) {
      if (/lbl|label/.test(sib.className || '')) return wordFromName(txt(sib), /SP|설정/.test(txt(sib)));
      if (/val/.test(sib.className || '')) break;
    }
    if (!sib && el.parentNode && /lbl|label/.test((el.parentNode.previousElementSibling || {}).className || '')) {
      var pl = el.parentNode.previousElementSibling; return wordFromName(txt(pl), /SP|설정/.test(txt(pl)));
    }
    // 항목형 (라벨 + 값)
    var it = el.parentNode;
    for (var up = 0; up < 2 && it; up++) {
      var lbl = it.querySelector && it.querySelector('[class*="lbl"], [class*="name"]');
      if (lbl && lbl !== el) return wordFromName(txt(lbl), /SP|설정/.test(txt(lbl)));
      it = it.parentNode;
    }
    if (/dt/.test(c)) return { kind: 'dt', dtRole: /belt/.test(c) ? 'belt' : (c.match(/dt-(\d)/) || [])[1] || 'main' };
    // BCF12 tp-val (data-tag)
    var dtag = el.getAttribute && el.getAttribute('data-tag');
    if (dtag) {
      var pc = el.parentNode && el.parentNode.parentNode ? Array.prototype.indexOf.call(el.parentNode.parentNode.children, el.parentNode) : -1;
      var grid = el.closest('.tp-grid');
      if (grid) { var kk = grid.children, pp = Array.prototype.indexOf.call(kk, el.closest('.tp-dc') || el.parentNode); return wordFromName(txt(kk[pp % 4]), false); }
    }
    return { kind: 'temp', sp: false };
  }
  // 패널 항목명 → 의미. zone 은 연속로(6·11호기)의 실(室)별 고정값에만 사용
  function nameZone(name) {
    return /예열/.test(name) ? 'pre' : /가열/.test(name) ? 'heat' : /강온/.test(name) ? 'cool'
      : /2실|확산|^침탄2$|^CP2$/.test(name) ? 'diff' : /1실|침탄|^CP1$/.test(name) ? 'carb' : null;
  }
  function wordFromName(name, isSet) {
    var sp = isSet || /SP/.test(name);
    if (/CP/i.test(name)) return { kind: 'cp', sp: sp, zone: nameZone(name) };
    if (/유조|냉각|오일/.test(name) && !/CP/.test(name)) return { kind: 'temp', sp: sp, oil: true };
    return { kind: 'temp', sp: sp, zone: nameZone(name), zname: name };
  }
  // 연속로 실별 설정값
  function contZone(mm, kind, zone) {
    if (mm.no === 6 && zone === 'diff') zone = 'carb';   // 6호기는 침탄1~3실 구성
    var T = mm.T, CP = mm.CP, idle = mm.state === '대기';
    if (kind === 'cp') return idle ? 0.8 : ({ heat: CP + 0.1, carb: CP + 0.25, diff: CP, cool: CP - 0.05 })[zone] || CP;
    if (idle) return zone === 'pre' ? 600 : 850;
    return ({ pre: 650, heat: T - 20, carb: T, diff: T - 30, cool: 850 })[zone] || T;
  }

  // 비트 역할 수집
  function rolesOf(el) {
    var c = typeof el.className === 'string' ? el.className : '';
    return c.split(/\s+/).filter(function (x) { return x && !TAGRE.test(x); }).map(function (x) {
      return x.replace(/^bcf\d*-?\d*-?/, '').replace(/^bcf\d+/, '');
    }).join(' ') + (el.tagName === 'IMG' ? ' img' : '');
  }

  function scan() {
    if (cache) return cache;
    var pg = pageInfo();
    var words = {}, bits = {}, status = {}, modes = {};
    function addWord(key, no, el, pref) {
      var w = words[key];
      var cl = classifyWord(el);
      // 같은 키가 여러 곳에 쓰이면 패널(온도·CP 요약) 라벨을 표 맥락보다 우선
      var rank = function (x) { return x.table ? ({ carb: 3, diff: 2, cool: 1, heat: 0, quench: -1 })[x.zone] || 0 : 9; };
      if (!w || rank(cl) > rank(w.cls)) words[key] = { no: no, cls: cl };
    }
    function addBit(key, no, el) {
      (bits[key] = bits[key] || { no: no, roles: [] }).roles.push(rolesOf(el));
    }
    var all = document.querySelectorAll('[class],[data-tag],[data-mode-tag]');
    for (var i = 0; i < all.length; i++) {
      var el = all[i];
      var cn = typeof el.className === 'string' ? el.className.split(/\s+/) : [];
      var disp = isDisplayEl(el);
      for (var j = 0; j < cn.length; j++) {
        var m = cn[j].match(TAGRE);
        if (!m) continue;
        var upper = m[1] === 'BCF', no = +m[2], addr = m[3];
        if (pg.bcf && upper) no = pg.bcf;              // BCF8 화면의 BCF6_xx 클래스 → bcf8_s_xx
        if (/^s_/.test(addr) || /^dt_/.test(addr)) { addWord('bcf' + no + '_' + addr, no, el); continue; }
        if (m[2] === '12' && !upper) {
          if (/^d\d+$/i.test(addr) && disp) { addWord('bcf12_s_D' + addr.slice(1), 12, el); addWord(cn[j], 12, el); continue; }
          if (/^[xym][0-9a-f]+h?$/.test(addr) && disp) { addWord(cn[j], 12, el); continue; }
          if (/^[XYM]/.test(addr)) { addBit(cn[j], 12, el); continue; }
        }
        if (upper) { addWord('bcf' + no + '_s_' + addr, no, el); continue; }
        if (/^\d+$/.test(addr)) {
          if (disp || (+addr >= 40000 && el.tagName !== 'IMG')) addWord('bcf' + no + '_s_' + addr, no, el);
          if (disp && no === 12) addWord(cn[j], 12, el);   // BCF12 화면은 클래스명 그대로 키로 읽음
          if (!disp) addBit('bcf' + no + '_' + addr, no, el);
          else if (+addr >= 40000) addBit('bcf' + no + '_' + addr, no, el);
        }
      }
      var dt = el.getAttribute('data-tag');
      if (dt) {
        dt.trim().split(/\s+/).forEach(function (tg) {
          var mm = tg.match(/^bcf(\d+)_(\d+)$/);
          if (/^bcf12_d\d+$/i.test(tg)) { addWord('bcf12_s_D' + tg.slice(7), 12, el); return; }
          if (mm) (status[tg] = status[tg] || { no: +mm[1], els: [] }).els.push(el);
        });
      }
      var md = el.getAttribute('data-mode-tag');
      if (md) { var m2 = md.match(/^bcf(\d+)_/); if (m2) modes[md] = { no: +m2[1], inv: el.getAttribute('data-mode-inv') === 'true' }; }
    }
    cache = { pg: pg, words: words, bits: bits, status: status, modes: modes };
    return cache;
  }

  /* ───────────────────── 값 생성 ───────────────────── */

  function fmtNum(v, dec) { return (Math.round(v * Math.pow(10, dec)) / Math.pow(10, dec)).toFixed(dec); }

  function wordValue(key, w, mdl, pg, t) {
    var c = w.cls, mm = mdl, k = key;
    var tdec = pg.monitor ? 1 : 0;
    if (c.kind === 'dt') {
      if (mm.state !== '가동') return 0;
      if (c.dtRole === 'belt') return Math.max(1, Math.round(mm.elapsed % 45 + 3));
      if (c.dtRole === 'main') return mm.remain;
      return Math.round(M.wave(k, t, 60, 25, 0, 240) + (+c.dtRole || 1) * 7);
    }
    if (c.table && mm.continuous && mm.state !== '정지' && c.kind !== 'c3h8' && c.kind !== 'nh3' && c.kind !== 'air') {
      // 연속로: 실마다 트레이가 체류 중 — 실별 고정 설정값, 체류시간은 실마다 위상이 다르게 순환
      var nz = c.oil ? 'oil' : (nameZone(c.zname) || (c.zone === 'heat' ? 'heat' : c.zone));
      if (c.kind === 'time') {
        var tsp = ({ pre: 32, heat: 48, carb: 62, diff: 55, cool: 48, oil: 22 })[nz] || 45;
        if (c.sp) return tsp + ZW;
        var ph = (M.hash(k + c.zidx) % 100) / 100;
        return Math.floor(tsp * ((t.getTime() / 60000 / tsp + ph) % 1)) + ZW;
      }
      if (c.kind === 'temp') {
        if (nz === 'oil') return fmtNum(c.sp ? mm.oilSP : mm.oilPV, 0) + ZW;
        var zt = contZone(mm, 'temp', nz);
        return fmtNum(c.sp ? zt : zt + M.wave(k + c.zidx, t, 0.2, 1.5, 0.4, 27), 0) + ZW;
      }
      if (c.kind === 'cp') {
        var zc = M.round(contZone(mm, 'cp', nz), 2);
        return fmtNum(c.sp ? zc : zc + M.wave(k + c.zidx, t, -0.002, 0.007, 0.002, 13), 3) + ZW;
      }
    }
    if (c.table) {
      var zf = zoneFrame(mm, c.zone, c.zidx, c.zcount);
      if (c.kind === 'time') {
        if (mm.state === '정지') return '0' + ZW;
        var spMin = Math.round(zf.len * (mm.total || (D.product((lastCharge(mm.no) || {}).prod_code).hours * 60) || 420));
        if (c.sp) return spMin + ZW;
        if (mm.state !== '가동') return '0' + ZW;
        return Math.max(0, Math.min(spMin, Math.floor(mm.elapsed - zf.start * mm.total))) + ZW;
      }
      if (c.kind === 'temp') {
        if (c.sp) return mm.state === '정지' ? '0' + ZW : fmtNum(mm.state === '대기' ? (c.zone === 'quench' ? 80 : 850) : stageTempSP(c.zone, mm.T, c.zidx), 0) + ZW;
        return fmtNum(c.zone === 'quench' ? mm.oilPV : mm.tempPV, 0) + ZW;
      }
      if (c.kind === 'cp') {
        if (c.sp) return fmtNum(mm.state === '정지' ? 0 : mm.state === '대기' ? 0.8 : (stageCpSP(c.zone, mm.CP, c.zidx) || mm.CP), 3) + ZW;
        return fmtNum(mm.cpPV, 3) + ZW;
      }
      return gasValue(c.kind, c.sp, c.zone, mm, k, t) + ZW;
    }
    var cont = mm.continuous && c.zone && mm.state !== '정지';
    if (c.kind === 'cp') {
      if (cont) { var cz = M.round(contZone(mm, 'cp', c.zone), 2); return fmtNum(c.sp ? cz : cz + M.wave(k, t, -0.002, 0.007, 0.002, 13), 3) + ZW; }
      return fmtNum(c.sp ? mm.cpSP : mm.cpPV, 3) + ZW;
    }
    if (c.oil) return fmtNum(c.sp ? mm.oilSP : mm.oilPV, tdec) + ZW;
    if (cont) {
      var zsp = contZone(mm, 'temp', c.zone);
      return fmtNum(c.sp ? zsp : zsp + M.wave(k, t, 0.2, 1.5, 0.4, 27), tdec) + ZW;
    }
    return fmtNum(c.sp ? mm.tempSP : mm.tempPV, tdec) + ZW;
  }

  function zoneFrame(mm, ztype, zidx, zcount) {
    for (var i = 0; i < STAGES.length; i++) if (STAGES[i].type === ztype) {
      var len = (STAGES[i].to - STAGES[i].from) / zcount;
      return { start: STAGES[i].from + len * zidx, len: len };
    }
    return { start: 0, len: 0.1 };
  }

  function gasValue(kind, sp, zone, mm, k, t) {
    if (mm.state === '정지') return '0.0';
    var base = 0;
    if (kind === 'c3h8') base = zone === 'carb' ? 3.5 : zone === 'diff' ? 1.2 : zone === 'heat' ? 0.8 : 0.5;
    if (kind === 'nh3') base = zone === 'diff' ? 2.0 : zone === 'cool' ? 3.0 : 0;
    if (kind === 'air') base = zone === 'diff' ? 0.4 : zone === 'cool' ? 0.6 : 0.2;
    if (sp) return fmtNum(base, 1);
    var cur = { heat: 0.8, carb: 3.5, diff: 1.2, cool: 0.5, quench: 0.5, hold: 0.6 }[mm.stage] || 0.5;
    if (kind === 'nh3') cur = mm.stage === 'diff' ? 2.0 : mm.stage === 'cool' ? 3.0 : 0;
    if (kind === 'air') cur = mm.stage === 'diff' ? 0.4 : 0.2;
    return fmtNum(Math.max(0, cur + (cur ? M.wave(k, t, 0, cur * 0.04, cur * 0.01, 15) : 0)), 1);
  }

  // 비트 역할 → 값
  function bitValue(key, b, mm, t) {
    var r = ' ' + b.roles.join(' ') + ' ';
    var run = mm.state === '가동', idle = mm.state === '대기', stop = mm.state === '정지';
    if (/alarm/.test(r)) return 0;
    if (/jog/.test(r)) return 0;
    if (/manual/.test(r)) return stop ? 1 : 0;
    if (/stop-box/.test(r)) return stop ? 1 : 0;
    if (/close/.test(r)) return 1;
    if (/open|down|arrow|motor-yellow|-off\b|off-box|off-\d/.test(r) && !/-on\b|on-box|on-\d/.test(r)) return 0;
    if (/\bup\b|\bup-/.test(r)) return 1;
    if (/tray/.test(r)) {
      if (!run) return 0;
      var n = +(r.match(/tray-(\d+)/) || [0, 1])[1];
      return (n === 1 || (n + mm.no) % 3 === 0) ? 1 : 0;
    }
    if (/dt/.test(r)) return run ? 1 : 0;
    if (/auto|straight|sok|sensor|photo|sw-|green|bong|stick|ro-on|obj|phone|pump|cool-on|mainair|bypas|alrblow|bcf-oil|oil/.test(r)) return stop ? 0 : 1;
    if (/fire|flame|pilot|heat|enrich|amm|gas|ngas/.test(r)) return stop ? 0 : 1;
    if (/pen|fan|pan|propel|rotate|cycle|air|moter|motor|circle/.test(r)) return stop ? 0 : 1;
    return stop ? 0 : 1;
  }

  // BCF12 (미쓰비시) 비트 — 이름 기반
  function bcf12Bit(key, mm) {
    var run = mm.state !== '정지';
    var fixed = {
      bcf12_X097H: 0, bcf12_X095H: 0, bcf12_X090H: 0,   // 도어 신호 0 = 닫힘
      bcf12_X092H: 0,                                     // 0 = 상승
      bcf12_M0925: run ? 1 : 0, bcf12_Y119H: run ? 1 : 0, bcf12_Y119: run ? 1 : 0, bcf12_X092: 0,
      bcf12_Y0F4H: run ? 1 : 0, bcf12_Y0F8H: run ? 1 : 0, bcf12_M6824: 0,
      bcf12_Y0F0H: run ? 1 : 0, bcf12_Y0F1H: run ? 1 : 0, bcf12_Y112H: run ? 1 : 0,
      bcf12_Y0E4H: 0, bcf12_Y101H: run ? 1 : 0
    };
    return fixed.hasOwnProperty(key) ? fixed[key] : null;
  }

  function snapshot() {
    var t = new Date();
    var sc = scan(), pg = sc.pg;
    var models = {};
    function mdl(no) { return models[no] || (models[no] = model(no, t)); }
    var out = {};
    var k;
    for (k in sc.words) out[k] = wordValue(k, sc.words[k], mdl(sc.words[k].no), pg, t);
    for (k in sc.bits) {
      if (out[k] != null) continue;
      var b = sc.bits[k], v12 = b.no === 12 ? bcf12Bit(k, mdl(12)) : null;
      out[k] = v12 != null ? v12 : bitValue(k, b, mdl(b.no), t);
    }
    for (k in sc.status) {
      var s = sc.status[k], mm = mdl(s.no);
      var inv = s.els.some(function (e) { return e.getAttribute('data-invert') === 'true'; });
      var good = inv ? 0 : 1;
      var e0 = s.els.filter(function (e) { return e.getAttribute('data-side') === 'right'; })[0] || s.els[0];
      var lbl0 = (e0.getAttribute('data-text-1') || txt(e0)).trim();
      if (!inv && /(OFF|수동)$/.test(lbl0)) good = 0;   // ON/OFF·자동/수동 쌍 항목 중 OFF·수동 쪽은 꺼짐
      if (mm.state === '정지') {
        var tx = s.els.map(function (e) { return (e.getAttribute('data-text-1') || '') + txt(e); }).join(' ');
        if (/자동|팬|구동|파이로트|ON|켜짐|커튼/.test(tx)) good = inv ? 1 : 0;
      }
      out[k] = good;  // 준비조건 표시가 우선 (같은 주소의 작화 비트보다)
    }
    for (k in sc.modes) out[k] = (mdl(sc.modes[k].no).state === '정지') ? (sc.modes[k].inv ? 1 : 0) : (sc.modes[k].inv ? 0 : 1);
    // BCF12 고정 비트 (상세화면 트레이 로직용)
    ['bcf12_Y119H', 'bcf12_X092H', 'bcf12_M0925', 'bcf12_Y0F4H'].forEach(function (x) { if (out[x] == null) out[x] = bcf12Bit(x, mdl(12)); });
    // 메인 모니터 belt-dt 보조 키
    if (pg.monitor) [1, 2, 3, 4, 5, 10].forEach(function (n) {
      ['_s_40002', '_s_40004'].forEach(function (s) { var kk = 'bcf' + n + s; if (out[kk] == null) out[kk] = 0; });
    });
    // 통신 시각 (60초 이내 → 연결)
    for (var n = 1; n <= 12; n++) out['bcf' + n + '_conn'] = t.getTime() - 800 - n * 37;
    return out;
  }

  M.get('/monitor/snapshot', function () { return snapshot(); });
  M.get('/monitor/comm-errors', function () { return { success: true, errors: [] }; });

  /* ───────────────────── 현재 경보 (BCF 상세) ─────────────────────
   * 알람 데이터는 master.js D.activeAlarms()(D2 담당)를 기준으로 한다. d2-monitor.js 가 같은 경로를
   * 나중에 등록하면 그쪽이 우선 — 여기 것은 기본값.
   */
  M.get('/alarm/active/list', function (req) {
    var lim = +req.params.limit || 200;
    return (D.activeAlarms ? D.activeAlarms() : []).slice(0, lim);
  });

  /* /monitor/snapshot 은 d2(공정현황 화면)도 등록한다. 나중에 등록된 라우트가 이기므로,
   * 이후 등록되는 snapshot 핸들러를 감싸 "이 파일 담당 화면(OVERVIEW-1/2, BCF 상세)"에서는
   * 여기 스냅샷을, 그 외 화면에서는 원래 핸들러 결과를 돌려준다. */
  function isMyPage() { var p = location.pathname; return /\/main_1\/main\/monitor2?$/.test(p) || /\/main_1\/BCF\/BCF_\d+$/.test(p); }
  var _origGet = M.get;
  M.get = function (p, h) {
    if (p === '/monitor/snapshot') {
      var theirs = h;
      h = function (req) { return isMyPage() ? snapshot() : theirs(req); };
    }
    return _origGet.call(M, p, h);
  };

  /* ───────────────────── 포털 / 로그인 / 권한 ───────────────────── */
  M.get('/emp/me', function () {
    var w = D.workers[0];
    return { success: true, data: { emp_id: 1, emp_code: w.emp_code, id: w.id, user_id: w.id, emp_name: w.emp_name, dept: w.dept, position: w.position, role: 'ADMIN', use_yn: 'Y' } };
  });
  // common_style.jsp: <ctx>/<page>/sample_pro/perm/my 형태로 호출됨 — 빈 객체 = 전체 허용
  M.get(/\/perm\/my$/, function () { return {}; });

  // 로그인 화면 PLC 통신 상태 / 일반 PLC 워드 읽기
  M.get('/plc/read/:id', function (req) {
    var id = req.params.id, no = +(String(id).match(/(\d+)$/) || [0, 1])[1];
    var start = +req.params.start || 0, count = Math.max(1, Math.min(960, +req.params.count || 1));
    var mm = model(no), vals = [];
    for (var i = 0; i < count; i++) {
      var a = start + i;
      vals.push(a === 0 ? (mm.state === '정지' ? 0 : 1) : Math.round(M.wave(id + a, new Date(), 0, 0, 0, 60) + (M.hash(id + ':' + a) % 1000)));
    }
    return { success: true, plcId: id, start: start, count: count, values: vals };
  });
  M.get('/plc/status-all', function () {
    var list = [];
    for (var n = 1; n <= 12; n++) list.push({ plcId: 'bcf_' + M.pad(n), name: 'BCF ' + n + '호기', connected: true, status: '정상', lastTime: M.fmt(new Date()) });
    return { success: true, data: list, list: list };
  });

  // 다른 화면에서도 공정 모델을 쓰도록 노출
  D.furnaceModel = D.furnaceModel || model;
})();
