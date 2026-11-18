<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common_style.jsp" %>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap" rel="stylesheet">
<style>
/* ===== 데모: 일상점검일지 — 고밀도 운영 화면 (무채색 + 파랑 1색, 이상(X)만 빨강 글자) ===== */
:root {
  --di-fg: oklch(24% 0.012 255); --di-fg2: oklch(46% 0.012 255); --di-fg3: oklch(64% 0.01 255);
  --di-line: oklch(91.5% 0.006 255); --di-line2: oklch(95.5% 0.004 255); --di-hover: oklch(97.5% 0.003 255);
  --di-bg: oklch(98.6% 0.002 255); --di-night: oklch(98.2% 0.002 255);
  --di-accent: var(--primary); --di-accent-tint: oklch(58% 0.13 250 / 0.06); --di-accent-tint2: oklch(58% 0.13 250 / 0.12);
  --di-ok: oklch(60% 0.12 150); --di-warn: oklch(64% 0.13 75); --di-bad: oklch(56% 0.15 25);
  --di-sans: "IBM Plex Sans KR", "Pretendard", "Malgun Gothic", "맑은 고딕", sans-serif;
  --di-mono: "IBM Plex Mono", Consolas, "Malgun Gothic", monospace;
}
html, body { background: var(--di-bg); color: var(--di-fg); font-family: var(--di-sans); font-size: 13px; }
.page-wrap { height: 100vh; overflow: hidden; padding: 0; display: flex; flex-direction: column; }

/* 헤더 + 툴바 */
.di-head { display: flex; align-items: center; gap: 8px; min-height: 56px; padding: 8px 24px; background: #fff; border-bottom: 1px solid var(--di-line); flex-shrink: 0; flex-wrap: wrap; }
.di-title { font-size: 18px; font-weight: 600; white-space: nowrap; }
.di-sub { font-size: 12px; color: var(--di-fg3); font-family: var(--di-mono); white-space: nowrap; margin-right: 8px; }
.di-sep { width: 1px; height: 20px; background: var(--di-line); margin: 0 4px; }
.di-label { font-size: 12px; color: var(--di-fg2); white-space: nowrap; }
.di-spacer { flex: 1; }
.form-input, .form-select {
  height: 32px; padding: 0 8px; border: 1px solid var(--di-line); border-radius: 6px; background: #fff;
  color: var(--di-fg); font-family: var(--di-mono); font-size: 13px; font-variant-numeric: tabular-nums;
}
.form-select { font-family: var(--di-sans); }
.form-input:focus, .form-select:focus { border-color: var(--di-accent); box-shadow: 0 0 0 2px var(--di-accent-tint2); outline: none; }
.btn-outline, .btn-primary {
  height: 32px; padding: 0 12px; display: inline-flex; align-items: center; gap: 8px; border-radius: 6px;
  font-family: var(--di-sans); font-size: 13px; font-weight: 500; white-space: nowrap; cursor: pointer;
  transition: background-color 80ms, border-color 80ms;
}
.btn-outline { border: 1px solid var(--di-line); background: #fff; color: var(--di-fg); }
.btn-outline:hover { background: var(--di-hover); border-color: oklch(86% 0.008 255); color: var(--di-fg); }
.btn-primary { border: 1px solid var(--di-accent); background: var(--di-accent); color: #fff; }
.btn-primary:hover { background: var(--primary-d); }
.btn-sm { height: 28px; padding: 0 10px; font-size: 12px; }
.btn-outline svg, .btn-primary svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }
.btn-outline.on { border-color: var(--di-accent); color: var(--di-accent); background: var(--di-accent-tint); }

/* 상태: 점 + 글자 */
.status-badge { display: inline-flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 500; color: var(--di-fg2); white-space: nowrap; }
.status-badge::before { content: ''; width: 6px; height: 6px; border-radius: 50%; background: var(--di-fg3); }
.status-DONE { color: var(--di-ok); }
.status-DONE::before { background: var(--di-ok); }
.status-TEMP { color: var(--di-warn); }
.status-TEMP::before { background: var(--di-warn); }

/* 본문 */
.di-body { flex: 1; min-height: 0; padding: 16px 24px 24px; display: flex; flex-direction: column; }
#inspCard { flex: 1; min-height: 0; display: flex; flex-direction: column; background: #fff; border: 1px solid var(--di-line); border-radius: 8px; overflow: hidden; }
.matrix-wrap { flex: 1; min-height: 0; overflow: auto; }
.matrix-table { border-collapse: separate; border-spacing: 0; font-size: 13px; white-space: nowrap; min-width: 100%; }
.matrix-table th {
  background: #fff; padding: 0 4px; height: 28px; text-align: center;
  font-size: 12px; font-weight: 500; color: var(--di-fg2);
  border-right: 1px solid var(--di-line2); border-bottom: 1px solid var(--di-line);
  white-space: nowrap; position: sticky; top: 0; z-index: 2;
}
.matrix-table thead tr:nth-child(2) th { top: 28px; }
.matrix-table th.item-col { text-align: left; padding: 0 12px; min-width: 150px; left: 0; z-index: 4; }
.matrix-table th.std-col  { text-align: left; padding: 0 12px; min-width: 150px; }
.matrix-table th.img-col  { min-width: 48px; width: 48px; }
.matrix-table th.day-hd   { min-width: 104px; font-family: var(--di-mono); font-variant-numeric: tabular-nums; color: var(--di-fg); border-bottom-color: var(--di-line2); }
.matrix-table th.sh-hd    { min-width: 52px; width: 52px; font-size: 11px; font-weight: 400; color: var(--di-fg3); }
.matrix-table th.sh-hd:nth-child(even) { background: var(--di-night); }
.matrix-table th.today-col { color: var(--di-accent); background: oklch(97% 0.012 250) !important; }
.matrix-table th.day-hd.today-col { box-shadow: inset 0 2px 0 var(--di-accent); font-weight: 600; }

.matrix-table td { padding: 0; height: 32px; border-right: 1px solid var(--di-line2); border-bottom: 1px solid var(--di-line2); vertical-align: middle; background: #fff; }
.matrix-table td.item-name {
  padding: 0 12px; font-weight: 500; font-size: 13px; color: var(--di-fg);
  position: sticky; left: 0; z-index: 1; border-right: 1px solid var(--di-line);
}
.matrix-table td.item-std { padding: 0 12px; color: var(--di-fg3); font-size: 12px; }
.matrix-table td.img-cell { padding: 2px 4px; text-align: center; }
.matrix-table td.sh-cell  { padding: 0 !important; }
.matrix-table td.sh-cell:nth-child(odd) { background: var(--di-night); }
.matrix-table td.today-col { background: var(--di-accent-tint) !important; }
.matrix-table tbody tr { transition: background-color 80ms; }
.matrix-table tbody tr:hover td { background: var(--di-hover); }
.matrix-table tbody tr:hover td.today-col { background: var(--di-accent-tint2) !important; }

/* 수치 입력 */
.val-input {
  width: 100%; height: 31px; border: none; background: transparent; text-align: center;
  font-family: var(--di-mono); font-size: 13px; font-weight: 400; font-variant-numeric: tabular-nums;
  color: var(--di-fg3); outline: none;
}
.val-input::placeholder { color: oklch(85% 0.006 255); }
.val-input:focus { background: #fff; box-shadow: inset 0 0 0 1.5px var(--di-accent); border-radius: 2px; }
.val-input.has-val { color: var(--di-fg); }
.val-input.is-check { font-family: var(--di-sans); font-weight: 500 !important; color: var(--di-fg2) !important; }

/* 편집 모드 */
.edit-item-btns { display: none; gap: 4px; padding: 2px 0 4px; }
.edit-item-btns.show { display: flex; }
.eib { height: 22px; padding: 0 6px; font-size: 11px; border-radius: 4px; border: 1px solid var(--di-line); background: #fff; color: var(--di-fg2); cursor: pointer; font-family: var(--di-sans); }
.eib-edit:hover { border-color: var(--di-accent); color: var(--di-accent); }
.eib-del { color: var(--di-bad); }
.eib-del:hover { border-color: var(--di-bad); }
.eib-type:hover { background: var(--di-hover); }
.eib-type.active { border-color: var(--di-accent); color: var(--di-accent); background: var(--di-accent-tint); }

/* 수치 행 / OX 행 — 배경색 구분 없음 (원래 보라색 강조 제거) */
.row-ox td { }

/* OX · 점검자 드롭다운 */
.ox-select {
  width: 100%; height: 31px; border: none; background: transparent; text-align: center; text-align-last: center;
  font-family: var(--di-sans); font-size: 13px; font-weight: 400; color: var(--di-fg3); outline: none; cursor: pointer;
  -webkit-appearance: none; appearance: none;
}
.ox-select:focus { box-shadow: inset 0 0 0 1.5px var(--di-accent); border-radius: 2px; }
.ox-select.has-o { color: var(--di-fg2) !important; font-family: var(--di-mono); }
.ox-select.has-x { color: var(--di-bad) !important; font-family: var(--di-mono); font-weight: 600; }
.ox-select option { color: var(--di-fg); }

.action-row { display: flex; gap: 8px; align-items: center; height: 40px; padding: 0 16px; border-top: 1px solid var(--di-line2); flex-shrink: 0; }
.legend { display: flex; gap: 16px; font-size: 12px; color: var(--di-fg3); align-items: center; flex-wrap: wrap; }
.legend b { font-family: var(--di-mono); font-weight: 500; color: var(--di-fg2); margin-right: 4px; }
.legend b.bad { color: var(--di-bad); }
#savedMsg { font-size: 12px; color: var(--di-ok); margin-left: auto; font-family: var(--di-mono); }

/* 모달 */
.modal-overlay { display: none; position: fixed; inset: 0; background: oklch(20% 0.01 255 / 0.4); z-index: 200; align-items: center; justify-content: center; }
.modal-overlay.show { display: flex; }
.modal-box { background: #fff; border: 1px solid var(--di-line); border-radius: 8px; padding: 20px 24px; width: 420px; max-width: 96vw; box-shadow: 0 8px 32px rgba(0,0,0,.14); }
.modal-title { font-size: 15px; font-weight: 600; margin-bottom: 16px; }
.modal-notice { font-size: 12px; color: var(--di-fg2); margin-bottom: 12px; padding: 8px 12px; background: var(--di-bg); border: 1px solid var(--di-line2); border-left: 2px solid var(--di-warn); border-radius: 4px; }
.modal-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 20px; }
.form-field { display: flex; flex-direction: column; gap: 4px; }
.form-label { font-size: 12px; color: var(--di-fg2); font-weight: 500; }

/* 이미지 */
.img-thumb { width: 40px; height: 26px; object-fit: cover; border-radius: 3px; cursor: zoom-in; border: 1px solid var(--di-line); display: block; margin: 0 auto; }
.img-thumb:hover { opacity: .85; }
.img-upload-btn { font-size: 11px; height: 20px; padding: 0 6px; border: 1px dashed var(--di-line); border-radius: 4px; background: none; cursor: pointer; color: var(--di-fg3); display: none; margin: 2px auto 0; }
.img-upload-btn:hover { border-color: var(--di-accent); color: var(--di-accent); }
.edit-mode .img-upload-btn { display: block; }
#imgPreviewModal .modal-box { width: min(960px, 92vw); text-align: center; }
#imgPreviewModal img { max-width: 100%; max-height: 82vh; border-radius: 4px; }

@media (max-width: 640px) {
  .hide-mobile { display: none !important; }
  .matrix-table th.std-col, .matrix-table td.item-std { display: none; }
  .val-input { height: 40px; }
  .matrix-table th.sh-hd { min-width: 42px; width: 42px; }
}
</style>
<body>
<div class="page-wrap">
  <!-- 헤더 + 툴바 -->
  <div class="di-head">
    <div class="di-title">일상점검일지</div>
    <div class="di-sub" id="pageSubTitle">설비를 선택하세요</div>
    <div class="di-sep"></div>
    <span class="di-label">점검월</span>
    <input class="form-input" type="month" id="selYm" style="width:140px">
    <span class="di-label" style="margin-left:8px">설비</span>
    <select class="form-select" id="selEquip" style="width:104px" onchange="loadData()">
      <option>BCF_1</option><option>BCF_2</option><option>BCF_3</option>
      <option>BCF_4</option><option>BCF_5</option><option>BCF_6</option>
      <option>BCF_7</option><option>BCF_8</option><option>BCF_9</option>
      <option>BCF_10</option><option>BCF_11</option><option>BCF_12</option>
    </select>
    <button class="btn-outline" onclick="loadData()"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>조회</button>
    <span id="statusBadge" class="status-badge status-TEMP" style="margin-left:8px">임시저장</span>
    <div class="di-spacer"></div>
    <button class="btn-outline" onclick="openTabletMode()"><svg viewBox="0 0 24 24"><rect x="5" y="2" width="14" height="20" rx="2"/><path d="M12 18h.01"/></svg>태블릿 모드</button>
    <button class="btn-outline" onclick="toggleEditMode()" id="editModeBtn"><svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg><span>항목 편집</span></button>
    <button class="btn-outline" onclick="doExport()"><svg viewBox="0 0 24 24"><path d="M12 4v11"/><path d="m7 10 5 5 5-5"/><path d="M5 20h14"/></svg>엑셀 출력</button>
    <label class="btn-outline" style="cursor:pointer;margin:0">
      <svg viewBox="0 0 24 24"><path d="M12 15V4"/><path d="m7 9 5-5 5 5"/><path d="M5 20h14"/></svg>엑셀 가져오기<input type="file" id="importFile" accept=".xlsx" style="display:none" onchange="doImport(this)">
    </label>
    <button class="btn-outline" onclick="openInspectorMgr()"><svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></svg>점검자 관리</button>
    <div class="di-sep"></div>
    <button class="btn-primary" onclick="saveDone()"><svg viewBox="0 0 24 24"><path d="M20 6 9 17l-5-5"/></svg>점검완료</button>
  </div>

  <div class="di-body">
    <div id="inspCard">
      <div class="matrix-wrap">
        <table class="matrix-table" id="matrixTable">
          <thead id="matrixHead"></thead>
          <tbody id="matrixBody">
            <tr><td colspan="3" style="text-align:center;height:64px;color:var(--di-fg3)">
              조회 버튼을 눌러 데이터를 불러오세요
            </td></tr>
          </tbody>
        </table>
      </div>

      <div class="action-row">
        <button class="btn-outline btn-sm edit-col" style="display:none" onclick="openItemModal(null)">+ 항목 추가</button>
        <div class="legend">
          <span><b>O</b>정상</span><span><b class="bad">X</b>이상</span><span><b>√</b>작동 확인 (99 입력)</span>
          <span>회색 칸 = 야간 · 파란 칸 = 오늘</span>
        </div>
        <span id="savedMsg"></span>
      </div>
    </div>
  </div>
</div>

<!-- 이미지 미리보기 모달 -->
<div class="modal-overlay" id="imgPreviewModal">
  <div class="modal-box">
    <div class="modal-title" id="imgPreviewTitle">이미지 미리보기</div>
    <img id="imgPreviewSrc" src="" alt="미리보기">
    <div class="modal-actions">
      <button class="btn-outline" onclick="document.getElementById('imgPreviewModal').classList.remove('show')">닫기</button>
    </div>
  </div>
</div>

<!-- 사용자 관리 모달 -->
<div id="inspectorModal" style="display:none;position:fixed;inset:0;background:oklch(20% 0.01 255 / 0.4);z-index:2000;justify-content:center;align-items:center">
  <div style="background:#fff;border:1px solid var(--di-line);border-radius:8px;padding:20px 24px;width:360px;max-height:80vh;display:flex;flex-direction:column;gap:12px;box-shadow:0 8px 32px rgba(0,0,0,.14)">
    <div style="font-size:15px;font-weight:600">점검자 관리</div>
    <div style="display:flex;gap:8px">
      <input class="form-input" type="text" id="newInspectorName" placeholder="점검자 이름" style="flex:1;font-family:var(--di-sans)"
             onkeydown="if(event.key==='Enter')addInspector()">
      <button class="btn-primary btn-sm" style="height:32px" onclick="addInspector()">추가</button>
    </div>
    <div id="inspectorListBox" style="overflow-y:auto;flex:1;min-height:80px;border:1px solid var(--di-line);border-radius:6px"></div>
    <button class="btn-outline" onclick="closeInspectorMgr()" style="align-self:flex-end">닫기</button>
  </div>
</div>

<!-- 항목 추가/수정 모달 -->
<div class="modal-overlay" id="itemModal">
  <div class="modal-box">
    <div class="modal-title" id="itemModalTitle">항목 추가</div>
    <div class="modal-notice" id="itemModalNotice" style="display:none"></div>
    <input type="hidden" id="mItemId">
    <div class="form-field" style="margin-bottom:12px">
      <label class="form-label">점검 항목 *</label>
      <input class="form-input" type="text" id="mItemName" placeholder="예) 외관 점검" style="width:100%">
    </div>
    <div class="form-field">
      <label class="form-label">점검 기준</label>
      <input class="form-input" type="text" id="mItemStd" placeholder="예) 균열·변형 없음" style="width:100%">
    </div>
    <div class="modal-actions">
      <button class="btn-outline" onclick="closeItemModal()">취소</button>
      <button class="btn-primary" onclick="saveItem()">저장</button>
    </div>
  </div>
</div>

<script src="/bcf/mock/mock-loader.js"></script>
<script src="/vendor/xlsx/0.18.5/xlsx.full.min.js"></script>
<script>
var base         ='${pageContext.request.contextPath}';
var editMode     = false;
var curData      = null;
var selYm        = '';
var selEquip     = '';
var today        = new Date();
var inputTypeMap    = {};
var inspectorList   = [];
var inspectorItemIds = {};

(function(){
  var d = new Date();
  document.getElementById('selYm').value =
    d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0');
  loadData();
})();

function openTabletMode(){
  selYm    = document.getElementById('selYm').value.replace('-','');
  selEquip = document.getElementById('selEquip').value;
  var q = selEquip ? '?equipId=' + encodeURIComponent(selEquip) + '&ym=' + selYm : '';
  location.href = base + '/main_1/inspect/daily/tablet' + q;
}

function loadData(){
  selYm    = document.getElementById('selYm').value.replace('-','');
  selEquip = document.getElementById('selEquip').value;
  if(!selYm || !selEquip) return;

  fetch(base + '/inspect/load?equipId=' + selEquip + '&ym=' + selYm)
    .then(function(r){ return r.json(); })
    .then(function(d){
      curData = d;
      if (d.inspectors) inspectorList = d.inspectors;
      setStatusBadge(d.status || 'TEMP');
      var ymFmt = selYm.substring(0,4) + '년 ' + parseInt(selYm.substring(4)) + '월';
      document.getElementById('pageSubTitle').textContent = selEquip + ' · ' + ymFmt;
      renderMatrix(d);
    })
    .catch(function(){ alert('데이터 로드 실패'); });
}

function renderMatrix(d){
  var days    = d.daysInMonth || 30;
  var items   = d.items || [];
  var todayYm = String(today.getFullYear()) + String(today.getMonth()+1).padStart(2,'0');
  var todayDay = (selYm === todayYm) ? today.getDate() : -1;

  /* 헤더 1행: 날짜 그룹 */
  var h1 = '<tr>'
    + '<th class="item-col" rowspan="2">점검 항목</th>'
    + '<th class="std-col" rowspan="2">점검 기준</th>'
    + '<th class="img-col" rowspan="2">IMG</th>';
  for(var day=1; day<=days; day++){
    var tc = (day===todayDay) ? ' today-col' : '';
    h1 += '<th class="day-hd' + tc + '" colspan="2">' + day + '일</th>';
  }
  h1 += '</tr>';

  /* 헤더 2행: 주간/야간 */
  var h2 = '<tr>';
  for(var day=1; day<=days; day++){
    var tc = (day===todayDay) ? ' today-col' : '';
    h2 += '<th class="sh-hd' + tc + '">주간</th><th class="sh-hd' + tc + '">야간</th>';
  }
  h2 += '</tr>';
  document.getElementById('matrixHead').innerHTML = h1 + h2;

  if(!items.length){
    document.getElementById('matrixBody').innerHTML =
      '<tr><td colspan="' + (days*2+3) + '" style="text-align:center;padding:40px;color:var(--muted)">'
      + '오른쪽 위 <strong>항목 편집</strong> → 아래 <strong>+ 항목 추가</strong>로 항목을 등록하세요.'
      + '</td></tr>';
    return;
  }

  // 서버 데이터로 inputTypeMap 갱신 + inspector 행 분리
  inspectorItemIds = {};
  var normalItems = [], inspRows = [];
  items.forEach(function(item){
    inputTypeMap[item.itemId] = item.inputType || 'NUM';
    if (item.itemName && (item.itemName.indexOf('점검자') >= 0 || item.itemName.indexOf('확인자') >= 0)) {
      inspectorItemIds[item.itemId] = true;
      inspRows.push(item);
    } else {
      normalItems.push(item);
    }
  });
  var orderedItems = normalItems.concat(inspRows);

  var html = '';
  orderedItems.forEach(function(item){
    var isOX    = inputTypeMap[item.itemId] === 'OX';
    var isInsp  = inspectorItemIds[item.itemId];
    var results = item.results || {};
    var imgCell = '';
    if(item.imgFile){
      imgCell = '<img src="' + base + '/inspect/item/image/' + esc(item.imgFile) + '" '
              + 'class="img-thumb" onclick="previewImg(\'' + esc(item.imgFile) + '\',\'' + esc(item.itemName) + '\')" '
              + 'title="' + esc(item.itemName) + '" alt="미리보기">';
    }
    if (!isInsp) imgCell += '<button class="img-upload-btn" onclick="openImgUpload(' + item.itemId + ')">+</button>';

    var editBtns = isInsp ? '' :
        '<button class="eib eib-edit" onclick="openItemModal(' + item.itemId + ')">수정</button>'
      + '<button class="eib eib-del"  onclick="delItem(' + item.itemId + ')">삭제</button>'
      + '<button class="eib eib-type' + (!isOX?' active':'') + '" id="eib_type_' + item.itemId + '" onclick="toggleInputType(' + item.itemId + ')">' + (isOX ? '수치값' : 'O/X') + '</button>';

    html += '<tr' + (!isOX ? ' class="row-ox"' : '') + '>'
      + '<td class="item-name">'
      +   '<span>' + esc(item.itemName) + '</span>'
      +   '<div class="edit-item-btns' + (editMode?' show':'') + '" id="eib_' + item.itemId + '">'
      +     editBtns
      +   '</div>'
      + '</td>'
      + '<td class="item-std">' + esc(item.itemStd || '') + '</td>'
      + '<td class="img-cell">' + imgCell + '</td>';

    for(var day=1; day<=days; day++){
      var dayRes = results[day] || results[String(day)] || {};
      var dVal   = dayRes.D != null ? dayRes.D : '';
      var nVal   = dayRes.N != null ? dayRes.N : '';
      var tc     = (day===todayDay) ? ' today-col' : '';
      html += mkCell(item.itemId, day, 'D', dVal, tc);
      html += mkCell(item.itemId, day, 'N', nVal, tc);
    }
    html += '</tr>';
  });
  document.getElementById('matrixBody').innerHTML = html;
}

function mkCell(itemId, day, shift, val, extraCls){
  if (inspectorItemIds[itemId]) {
    var opts = '<option value="">—</option>';
    inspectorList.forEach(function(ins){
      var n = ins.name || ins.NAME || '';
      opts += '<option value="' + esc(n) + '"' + (val === n ? ' selected' : '') + '>' + esc(n) + '</option>';
    });
    return '<td class="sh-cell' + extraCls + '">'
      + '<select class="ox-select" data-item="' + itemId + '" data-day="' + day + '" data-shift="' + shift + '"'
      + ' onchange="saveCell(this)">' + opts + '</select></td>';
  }
  if (inputTypeMap[itemId] === 'OX') {
    var oxVal  = (val === 'O' || val === 'X') ? val : '';
    var selCls = 'ox-select' + (oxVal==='O' ? ' has-o' : oxVal==='X' ? ' has-x' : '');
    return '<td class="sh-cell' + extraCls + '">'
      + '<select class="' + selCls + '"'
      + ' data-item="' + itemId + '" data-day="' + day + '" data-shift="' + shift + '"'
      + ' onchange="saveCell(this)">'
      + '<option value="">—</option>'
      + '<option value="O"' + (oxVal==='O'?' selected':'') + '>O</option>'
      + '<option value="X"' + (oxVal==='X'?' selected':'') + '>X</option>'
      + '</select>'
      + '</td>';
  }
  var disp    = (val === 99 || val === '99') ? '√' : (val !== '' && val != null ? String(val) : '');
  var hasCls  = disp !== '' ? ' has-val' : '';
  var chkCls  = disp === '√' ? ' is-check' : '';
  return '<td class="sh-cell' + extraCls + '">'
    + '<input type="text" inputmode="numeric" class="val-input' + hasCls + chkCls + '"'
    + ' data-item="' + itemId + '" data-day="' + day + '" data-shift="' + shift + '"'
    + ' value="' + esc(disp) + '" placeholder="—"'
    + ' onfocus="onInspFocus(this)" oninput="onInspInput(this)" onblur="saveCell(this)">'
    + '</td>';
}

function onInspFocus(input){
  if(input.value === '√'){ input.value = '99'; input.select(); }
}
function onInspInput(input){
  var v = input.value;
  if(v === '99'){
    input.value = '√';
    input.classList.add('is-check', 'has-val');
    input.classList.remove('is-check'); /* force repaint */
    input.classList.add('is-check');
  } else {
    input.classList.remove('is-check');
    input.classList.toggle('has-val', v !== '');
  }
}
function saveCell(el){
  var rawVal;
  if (el.tagName === 'SELECT') {
    rawVal = el.value;
    el.className = 'ox-select' + (el.value==='O' ? ' has-o' : el.value==='X' ? ' has-x' : '');
  } else {
    if(el.value === '99'){ el.value='√'; el.classList.add('is-check','has-val'); }
    rawVal = el.value === '√' ? '99' : el.value;
  }
  fetch(base + '/inspect/result/cell', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({
      equipId: selEquip, ym: selYm,
      day:     parseInt(el.dataset.day),
      itemId:  parseInt(el.dataset.item),
      shift:   el.dataset.shift,
      val:     rawVal
    })
  }).then(function(r){ return r.json(); })
    .then(function(d){ if(d.success){ showSavedMsg(); setStatusBadge('TEMP'); } });
}

function saveDone(){
  if(!confirm('점검 완료로 저장하시겠습니까?')) return;
  fetch(base + '/inspect/header/save', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({
      equipId: selEquip, ym: selYm,
      inspector: document.getElementById('inspector').value,
      confirmer: document.getElementById('confirmer').value,
      status: 'DONE'
    })
  }).then(function(r){ return r.json(); })
    .then(function(d){
      if(d.success){ setStatusBadge('DONE'); alert('점검 완료 저장되었습니다.'); }
      else alert(d.error||'저장 실패');
    });
}

function autoSaveHeader(){ /* inspector/confirmer 항목으로 이동 — 미사용 */ }

function openInspectorMgr(){
  document.getElementById('inspectorModal').style.display = 'flex';
  fetchInspectors();
}
function closeInspectorMgr(){
  document.getElementById('inspectorModal').style.display = 'none';
}
function fetchInspectors(){
  fetch(base + '/inspect/inspector/list').then(function(r){ return r.json(); })
    .then(function(d){
      if (d.inspectors) { inspectorList = d.inspectors; renderInspectorModal(); }
    });
}
function renderInspectorModal(){
  var html = '';
  inspectorList.forEach(function(ins){
    var n = ins.name || ins.NAME || '';
    var idx = ins.idx || ins.IDX;
    html += '<div style="display:flex;align-items:center;gap:8px;padding:6px 8px;border-bottom:1px solid var(--border)">'
      + '<span style="flex:1;font-size:13px">' + esc(n) + '</span>'
      + '<button class="btn-outline btn-sm" onclick="deleteInspector(' + idx + ')">삭제</button>'
      + '</div>';
  });
  if(!html) html = '<div style="color:var(--muted);text-align:center;padding:16px;font-size:13px">등록된 점검자가 없습니다</div>';
  document.getElementById('inspectorListBox').innerHTML = html;
}
function addInspector(){
  var name = document.getElementById('newInspectorName').value.trim();
  if(!name) return;
  fetch(base + '/inspect/inspector/add', {
    method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({name: name})
  }).then(function(r){ return r.json(); })
    .then(function(d){
      if(d.success){ document.getElementById('newInspectorName').value = ''; fetchInspectors(); }
      else alert(d.error || '추가 실패');
    });
}
function deleteInspector(idx){
  if(!confirm('삭제하시겠습니까?')) return;
  fetch(base + '/inspect/inspector/delete', {
    method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({idx: idx})
  }).then(function(r){ return r.json(); })
    .then(function(d){
      if(d.success) fetchInspectors();
      else alert(d.error || '삭제 실패');
    });
}

function toggleInputType(itemId) {
  var cur  = inputTypeMap[itemId] || 'NUM';
  var next = (cur === 'OX') ? 'NUM' : 'OX';
  fetch(base + '/inspect/item/inputtype', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({itemId: itemId, inputType: next})
  }).then(function(r){ return r.json(); })
    .then(function(d){
      if (d.success) {
        /* curData도 갱신해야 renderMatrix 내부의 inputTypeMap 덮어쓰기를 막음 */
        if (curData && curData.items) {
          curData.items.forEach(function(it) {
            if (it.itemId == itemId) it.inputType = next;
          });
        }
        renderMatrix(curData);
      } else {
        alert(d.error || '저장 실패');
      }
    });
}

function toggleEditMode(){
  editMode = !editMode;
  var btn = document.getElementById('editModeBtn');
  btn.querySelector('span').textContent = editMode ? '편집 완료' : '항목 편집';
  btn.classList.toggle('on', editMode);
  document.querySelectorAll('.edit-col').forEach(function(el){ el.style.display = editMode?'':'none'; });
  document.querySelectorAll('.edit-item-btns').forEach(function(el){ el.classList.toggle('show', editMode); });
  var wrap = document.querySelector('.matrix-wrap');
  if(wrap) wrap.classList.toggle('edit-mode', editMode);
}

var imgUploadInput = document.createElement('input');
imgUploadInput.type = 'file'; imgUploadInput.accept = 'image/*';
var _imgUploadItemId = 0;
imgUploadInput.addEventListener('change', function(){
  var file = this.files[0];
  if(!file || !_imgUploadItemId) return;
  var fd = new FormData();
  fd.append('file', file); fd.append('itemId', _imgUploadItemId);
  fetch(base + '/inspect/item/image/upload', { method:'POST', body:fd })
    .then(function(r){ return r.json(); })
    .then(function(d){ imgUploadInput.value=''; if(d.success) loadData(); else alert(d.error||'업로드 실패'); })
    .catch(function(){ imgUploadInput.value=''; alert('업로드 실패'); });
});
function openImgUpload(itemId){ _imgUploadItemId = itemId; imgUploadInput.click(); }

function previewImg(filename, itemName){
  document.getElementById('imgPreviewTitle').textContent = itemName;
  document.getElementById('imgPreviewSrc').src = base + '/inspect/item/image/' + filename;
  document.getElementById('imgPreviewModal').classList.add('show');
}

function openItemModal(itemId){
  document.getElementById('mItemId').value = itemId || '';
  var notice = document.getElementById('itemModalNotice');
  if(!itemId){
    document.getElementById('itemModalTitle').textContent = '항목 추가';
    document.getElementById('mItemName').value = '';
    document.getElementById('mItemStd').value  = '';
    notice.textContent = '추가된 항목은 이번 달부터 적용됩니다.';
  } else {
    document.getElementById('itemModalTitle').textContent = '항목 수정';
    var item = curData && curData.items ? curData.items.find(function(i){ return i.itemId==itemId; }) : null;
    document.getElementById('mItemName').value = item ? item.itemName : '';
    document.getElementById('mItemStd').value  = item ? (item.itemStd||'') : '';
    notice.textContent = '수정 내용은 ' + nextYmLabel() + '부터 반영됩니다.';
  }
  notice.style.display = 'block';
  document.getElementById('itemModal').classList.add('show');
}
function closeItemModal(){ document.getElementById('itemModal').classList.remove('show'); }

function saveItem(){
  var itemId   = document.getElementById('mItemId').value;
  var itemName = document.getElementById('mItemName').value.trim();
  var itemStd  = document.getElementById('mItemStd').value.trim();
  if(!itemName){ alert('점검 항목을 입력하세요.'); return; }
  var url  = itemId ? '/inspect/item/edit' : '/inspect/item/add';
  var body = { equipId:selEquip, itemName:itemName, itemStd:itemStd };
  if(itemId) body.itemId = parseInt(itemId);
  fetch(base + url, {
    method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body)
  }).then(function(r){ return r.json(); })
    .then(function(d){ if(d.success){ closeItemModal(); loadData(); } else alert(d.error||'저장 실패'); });
}

function delItem(itemId){
  if(!confirm('삭제하시겠습니까?\n수정/삭제는 ' + nextYmLabel() + '부터 반영됩니다.')) return;
  fetch(base + '/inspect/item/delete', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ itemId:itemId })
  }).then(function(r){ return r.json(); })
    .then(function(d){
      if(d.success) alert('처리되었습니다. ' + nextYmLabel() + '부터 반영됩니다.');
      else alert(d.error||'삭제 실패');
    });
}

function setStatusBadge(st){
  var badge = document.getElementById('statusBadge');
  badge.textContent = st==='DONE' ? '완료' : '임시저장';
  badge.className   = 'status-badge status-' + st;
}
var savedTimer = null;
function showSavedMsg(){
  var el = document.getElementById('savedMsg');
  el.textContent = '✓ 저장됨 ' + new Date().toLocaleTimeString();
  clearTimeout(savedTimer);
  savedTimer = setTimeout(function(){ el.textContent=''; }, 3000);
}
function doExport(){
  if(!selEquip || !selYm){ alert('설비와 점검월을 선택하세요.'); return; }
  // 데모: 서버 엑셀 생성 대신 화면의 점검표를 그대로 xlsx 로 내려받는다
  var tbl = document.getElementById('matrixTable');
  var c = tbl.cloneNode(true);
  var src = tbl.querySelectorAll('input,select,textarea'), dst = c.querySelectorAll('input,select,textarea');
  for (var i = 0; i < dst.length; i++) {
    var s = src[i];
    var v = (s.type === 'checkbox' || s.type === 'radio') ? (s.checked ? 'V' : '')
          : (s.tagName === 'SELECT' ? ((s.options[s.selectedIndex] || {}).text || '') : s.value);
    dst[i].parentNode.replaceChild(document.createTextNode(v), dst[i]);
  }
  var wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, XLSX.utils.table_to_sheet(c, { raw: true }), '일상점검일지');
  XLSX.writeFile(wb, '일상점검일지_' + selEquip + '_' + selYm + '.xlsx');
}
function doImport(input){
  var file = input.files[0];
  if(!file) return;
  if(!selEquip || !selYm){ alert('설비와 점검월을 선택하세요.'); input.value=''; return; }
  var fd = new FormData();
  fd.append('file', file); fd.append('equipId', selEquip); fd.append('ym', selYm);
  fetch(base + '/inspect/excel/import', { method:'POST', body:fd })
    .then(function(r){ return r.json(); })
    .then(function(d){ input.value=''; if(d.success){ alert('가져오기 완료 ('+d.count+'셀)'); loadData(); } else alert(d.error||'임포트 실패'); })
    .catch(function(){ input.value=''; alert('임포트 실패'); });
}
function nextYmLabel(){
  var d = new Date(); d.setMonth(d.getMonth()+1);
  return d.getFullYear()+'년 '+(d.getMonth()+1)+'월';
}
function esc(s){
  return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
</script>
</body>
</html>
