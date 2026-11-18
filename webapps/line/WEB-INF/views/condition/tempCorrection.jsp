<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>온도조절계 보정현황</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
<style>
:root {
  --bg:#f3f5f8; --surface:#ffffff; --surface2:#f8fafc; --border:#e3e8ef; --line2:#eef1f5;
  --text-p:#0f172a; --text-2:#334155; --text-s:#64748b; --text-m:#94a3b8;
  --accent:#2563eb; --red:#dc2626; --amber:#d97706; --teal:#0d9488;
}
*{ box-sizing:border-box; margin:0; padding:0; }
body { font-family:"Pretendard","Malgun Gothic","맑은 고딕",sans-serif; background:var(--bg); color:var(--text-p); font-size:13px; min-height:100vh; }
.num { font-variant-numeric:tabular-nums; }

/* ===== 상단 바 ===== */
.topbar { background:var(--surface); border-bottom:1px solid var(--border); }
.topbar-inner { padding:0 20px; height:52px; display:flex; align-items:center; gap:10px; }
.tb-title { font-size:16px; font-weight:700; letter-spacing:-.3px; margin-right:12px; white-space:nowrap; color:var(--text-p); }
.tb-label { font-size:12.5px; color:var(--text-s); white-space:nowrap; }
.ctrl, .ctrl-select, .ctrl-input { height:32px; padding:0 10px; border:1px solid var(--border); border-radius:6px; background:#fff;
  color:var(--text-p); font-size:13px; font-family:inherit; outline:none; }
.ctrl-select { min-width:110px; cursor:pointer; }
.ctrl:focus, .ctrl-select:focus, .ctrl-input:focus { border-color:var(--accent); }
.tb-sp { flex:1; }
.btn { height:32px; padding:0 14px; border-radius:6px; font-size:13px; font-family:inherit; font-weight:600;
  cursor:pointer; white-space:nowrap; border:1px solid var(--border); background:#fff; color:var(--text-2);
  display:inline-flex; align-items:center; gap:5px; }
.btn:hover { border-color:#cbd5e1; background:var(--surface2); }
.btn-search { background:var(--text-p); border-color:var(--text-p); color:#fff; }
.btn-search:hover { background:#1e293b; border-color:#1e293b; }
.btn-delete { color:var(--red); }

/* ===== 페이지 ===== */
.page { padding:14px 20px 18px; display:flex; flex-direction:column; gap:12px; }
/* 큰 화면 대응: 페이지를 창 높이에 맞추고 목록 카드가 남은 높이를 채움 (페이지 스크롤 없음) */
html, body { height:100%; overflow:hidden; }
body { display:flex; flex-direction:column; min-height:0; }
body > .page { flex:1; min-height:0; }
.page > .main-card, .page > .table-card { flex:1; min-height:0; display:flex; flex-direction:column; }
.page > .main-card > .flat-tab, .page > .table-card > .flat-tab { flex:1; min-height:0; }
.page > .main-card > .table-wrap { flex:1; min-height:0; max-height:none; }
.card { background:var(--surface); border:1px solid var(--border); border-radius:10px; }
.card-head { padding:12px 16px; display:flex; align-items:center; justify-content:space-between; gap:12px; border-bottom:1px solid var(--line2); }
.card-head-title { font-size:14px; font-weight:700; color:var(--text-2); }
.card-head small, .card-head .hint { font-size:12px; color:var(--text-m); }
.card-foot { padding:8px 16px; border-top:1px solid var(--line2); display:flex; justify-content:space-between; font-size:12px; color:var(--text-m); }
.card-foot strong { color:var(--text-2); font-variant-numeric:tabular-nums; }
.main-card { background:var(--surface); border:1px solid var(--border); border-radius:10px; overflow:hidden; display:flex; flex-direction:column; min-width:0; }

/* 요약 지표 */
.summary { display:grid; grid-template-columns:repeat(4, minmax(0,1fr)); }
.summary > div { padding:14px 18px; border-left:1px solid var(--line2); min-width:0; }
.summary > div:first-child { border-left:0; }
.s-lb { font-size:12.5px; color:var(--text-s); }
.s-v { margin-top:4px; font-size:22px; font-weight:700; letter-spacing:-.4px; color:var(--text-p); font-variant-numeric:tabular-nums; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.s-v u { text-decoration:none; font-size:13px; font-weight:500; color:var(--text-s); margin-left:2px; }
.s-sub { margin-top:2px; font-size:12px; color:var(--text-m); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }

/* ===== Tabulator ===== */
.flat-tab.tabulator { border:0; background:#fff; font-family:inherit; font-size:13px; }
.flat-tab .tabulator-header { background:#fff; border-bottom:1px solid var(--border); }
.flat-tab .tabulator-header .tabulator-col { background:#fff; border-right:0; color:var(--text-s); font-size:12px; font-weight:600; }
.flat-tab .tabulator-col .tabulator-col-content { padding:9px 10px; }
.flat-tab .tabulator-tableholder { background:#fff; }
.flat-tab .tabulator-row { background:#fff; border-bottom:1px solid var(--line2); min-height:40px; cursor:pointer; }
.flat-tab .tabulator-row.tabulator-row-even { background:#fff; }
.flat-tab .tabulator-row:hover { background:#f8fafc; }
.flat-tab .tabulator-row.row_select, .flat-tab .tabulator-row.tabulator-selected { background:#eef4ff !important; }
.flat-tab .tabulator-cell { border-right:0; padding:11px 10px; color:var(--text-2); }
.flat-tab .tabulator-placeholder span { color:var(--text-m); font-size:13px; font-weight:400; }
.flat-tab .tabulator-footer { background:#fff; border-top:1px solid var(--line2); }
.date-cell { color:var(--text-s); font-variant-numeric:tabular-nums; }
.st-ok { color:var(--teal); } .st-warn { color:var(--amber); } .st-over { color:var(--red); font-weight:600; }
.file-link { color:var(--accent); text-decoration:none; cursor:pointer; display:inline-block; max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; vertical-align:middle; }
.file-link:hover { text-decoration:underline; }
.muted { color:var(--text-m); }

/* ===== 모달 ===== */
.modal-overlay { display:none; position:fixed; inset:0; background:rgba(15,23,42,.4); z-index:500; align-items:center; justify-content:center; }
.modal-overlay.show { display:flex; }
.modal-box { background:#fff; border-radius:10px; width:460px; max-width:95vw; max-height:90vh; overflow-y:auto; box-shadow:0 16px 48px rgba(15,23,42,.18); padding:20px 22px; position:relative; }
.modal-head { display:flex; align-items:center; justify-content:space-between; margin:-20px -22px 16px; padding:16px 22px; border-bottom:1px solid var(--border); }
.modal-head h2 { font-size:16px; font-weight:700; color:var(--text-p); }
.modal-close { cursor:pointer; color:var(--text-s); font-size:16px; padding:4px 6px; background:none; border:0; }
.modal-close:hover { color:var(--text-p); }
.form-group { margin-bottom:12px; }
.form-label { font-size:12px; color:var(--text-s); margin-bottom:5px; display:block; }
.form-input, .form-textarea, .form-select { width:100%; border:1px solid var(--border); border-radius:6px; background:#fff; color:var(--text-p); font-size:13px; font-family:inherit; outline:none; }
.form-input, .form-select { height:34px; padding:0 10px; }
.form-textarea { padding:8px 10px; resize:vertical; min-height:80px; }
.form-input:focus, .form-textarea:focus, .form-select:focus { border-color:var(--accent); }
.form-input[readonly] { color:var(--text-m); background:var(--surface2); cursor:default; }
.modal-btn-row { display:flex; gap:8px; justify-content:flex-end; margin:18px -22px -20px; padding:12px 22px; border-top:1px solid var(--border); }
.modal-btn { height:34px; padding:0 18px; border-radius:6px; font-size:13px; font-weight:600; font-family:inherit; cursor:pointer; border:1px solid var(--border); background:#fff; color:var(--text-2); }
.modal-btn-save { background:var(--text-p); border-color:var(--text-p); color:#fff; }
.modal-btn-cancel { background:#fff; color:var(--text-2); }

/* 엑셀 로딩 */
#excelOverlay { display:none; position:fixed; inset:0; background:rgba(15,23,42,.4); z-index:9998; }
#excelLoading { display:none; position:fixed; top:50%; left:50%; transform:translate(-50%,-50%); background:#fff; padding:22px 40px; border-radius:10px; border:1px solid var(--border); z-index:9999; font-size:14px; font-weight:600; text-align:center; }

/* ===== 페이지 전용 (온도조절계) ===== */
.tb-div { display:none; }
.ctrl { width:auto; }
.table-card { background:var(--surface); border:1px solid var(--border); border-radius:10px; overflow:hidden; }
.table-head { padding:12px 16px; display:flex; align-items:center; justify-content:space-between; gap:12px; border-bottom:1px solid var(--line2); }
.table-head-title { font-size:14px; font-weight:700; color:var(--text-2); }
.table-head-hint { font-size:12px; color:var(--text-m); }

/* 모달 */
.modal-ov { display:none; position:fixed; inset:0; background:rgba(15,23,42,.4); z-index:500; align-items:center; justify-content:center; }
.modal-ov.show { display:flex; }
.modal-ov .modal-box { width:720px; padding:0; display:flex; flex-direction:column; }
.modal-file-box { background:#fff; border-radius:10px; width:480px; max-width:95vw; max-height:90vh; overflow-y:auto; box-shadow:0 16px 48px rgba(15,23,42,.18); }
.mbox-head { padding:16px 22px; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; background:#fff; border-radius:10px 10px 0 0; }
.mbox-head h3 { font-size:16px; font-weight:700; color:var(--text-p); }
.mbox-close { cursor:pointer; color:var(--text-s); font-size:16px; padding:4px 6px; background:none; border:0; font-family:inherit; }
.mbox-close:hover { color:var(--text-p); }
.mbox-body { padding:16px 22px; overflow-y:auto; }
.m-section { margin-bottom:16px; }
.m-section:last-child { margin-bottom:0; }
.m-sec-label { font-size:13px; font-weight:700; color:var(--text-2); padding-bottom:8px; margin-bottom:10px; border-bottom:1px solid var(--line2); }
.m-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.m-grid.cols3 { grid-template-columns:1fr 1fr 1fr; }
.m-grid .full { grid-column:1/-1; }
.m-group { display:flex; flex-direction:column; gap:5px; }
.m-label { font-size:12px; color:var(--text-s); }
.m-input, .m-select { width:100%; height:34px; padding:0 10px; border:1px solid var(--border); border-radius:6px; background:#fff; color:var(--text-p); font-size:13px; font-family:inherit; outline:none; }
.m-input:focus, .m-select:focus { border-color:var(--accent); }
.m-input[readonly] { color:var(--text-m); background:var(--surface2); }
.file-drop { border:1px dashed #cbd5e1; border-radius:6px; padding:14px 10px; text-align:center; cursor:pointer; background:#fff; }
.file-drop:hover, .file-drop.dragover { border-color:var(--accent); background:var(--surface2); }
.file-drop-icon { display:none; }
.file-drop-text { font-size:13px; color:var(--text-2); }
.file-drop-sub { font-size:12px; color:var(--text-m); margin-top:2px; }
.file-list { display:flex; flex-direction:column; margin-top:6px; }
.file-item { display:flex; align-items:center; justify-content:space-between; gap:8px; padding:6px 2px; border-bottom:1px solid var(--line2); font-size:12.5px; }
.file-item-name { color:var(--text-2); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.file-item-name span { color:var(--text-m) !important; }
.file-item-del { cursor:pointer; color:var(--text-m); padding:0 4px; }
.file-item-del:hover { color:var(--red); }
.mbox-foot { padding:12px 22px; border-top:1px solid var(--border); display:flex; gap:8px; justify-content:flex-end; }
.mbtn { height:34px; padding:0 18px; border-radius:6px; font-size:13px; font-weight:600; font-family:inherit; cursor:pointer; border:1px solid var(--border); background:#fff; color:var(--text-2); }
.mbtn-save { background:var(--text-p); border-color:var(--text-p); color:#fff; }
.file-preview-list { padding:8px 22px; }
.file-preview-item { display:flex; align-items:center; gap:10px; padding:10px 0; border-bottom:1px solid var(--line2); }
.file-preview-item:last-child { border-bottom:0; }
.file-icon:empty { display:none; }
.file-info { flex:1; min-width:0; }
.file-info-name { font-size:13px; color:var(--text-p); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.file-info-size { font-size:12px; color:var(--text-m); }
.file-dl-btn { height:28px; padding:0 12px; border-radius:6px; border:1px solid var(--border); background:#fff; color:var(--text-2); font-size:12px; font-weight:600; font-family:inherit; cursor:pointer; }
.file-dl-btn:hover { background:var(--surface2); }
</style>
</head>
<body>

<!-- ════════════ TOPBAR ════════════ -->
<div class="topbar">
  <div class="topbar-inner">
    <div class="tb-title">
      온도조절계 보정현황
    </div>
    <div class="tb-div"></div>
    <span class="tb-label">년도</span>
    <select id="searchYear" class="ctrl" style="width:100px;">
    </select>
    <div class="tb-div"></div>
    <span class="tb-label">설비명</span>
    <select id="searchMch" class="ctrl" style="min-width:160px;">
      <option value="">전체</option>
    </select>
    <div class="tb-div"></div>
    <button class="btn btn-search" onclick="loadData()">
      조회
    </button>
    <div class="tb-sp"></div>
    <button class="btn btn-insert" id="btnAdd">
      추가
    </button>
    <button class="btn btn-delete" id="btnDel">
      삭제
    </button>
    <button class="btn btn-excel" id="btnExcel">
      엑셀
    </button>
  </div>
</div>

<!-- ════════════ PAGE ════════════ -->
<div class="page">
  <div class="table-card">
    <div class="table-head">
      <span class="table-head-title">온도조절계 보정 이력</span>
      <span class="table-head-hint">행 더블클릭 수정 · 체크박스 선택 후 삭제 · 파일명 클릭 시 첨부 확인</span>
    </div>
    <div id="mainTable" class="flat-tab"></div>
  </div>
</div>

<!-- ════════════ 입력/수정 모달 ════════════ -->
<div id="modalMain" class="modal-ov">
  <div class="modal-box">
    <div class="mbox-head">
      <h3 id="modalTitle">온도조절계 보정 등록</h3>
      <button class="mbox-close" id="btnModalClose">✕</button>
    </div>
    <div class="mbox-body">
      <form id="mainForm" autocomplete="off">
        <input type="hidden" name="id" id="formId"/>

        <div class="m-section">
          <div class="m-sec-label">기본 정보</div>
          <div class="m-grid">
            <div class="m-group">
              <label class="m-label">설비명 <span style="color:#dc2626">*</span></label>
              <input type="text" name="mch_name" id="formMchName" class="m-input" placeholder="설비명 입력"/>
            </div>
            <div class="m-group">
              <label class="m-label">구분 (존) <span style="color:#dc2626">*</span></label>
              <select name="zone" id="formZone" class="m-select">
                <option value="">-- 선택 --</option>
                <option value="1">1존</option>
                <option value="2">2존</option>
                <option value="3">3존</option>
                <option value="4">4존</option>
                <option value="5">5존</option>
              </select>
            </div>
          </div>
        </div>

        <div class="m-section">
          <div class="m-sec-label">보정 데이터</div>
          <div class="m-grid cols3">
            <div class="m-group">
              <label class="m-label">보정 전</label>
              <input type="text" name="before_val" id="formBefore" class="m-input" placeholder="보정 전 값"/>
            </div>
            <div class="m-group">
              <label class="m-label">상반기 보정</label>
              <input type="text" name="first_half" id="formFirstHalf" class="m-input" placeholder="상반기 보정값"/>
            </div>
            <div class="m-group">
              <label class="m-label">하반기 보정</label>
              <input type="text" name="second_half" id="formSecondHalf" class="m-input" placeholder="하반기 보정값"/>
            </div>
          </div>
        </div>

        <div class="m-section">
          <div class="m-sec-label">파일 첨부</div>

          <div style="display:grid; grid-template-columns:1fr 1fr; gap:14px;">
            <!-- 상반기 파일 -->
            <div class="m-group">
              <label class="m-label">상반기 첨부파일</label>
              <div class="file-drop" id="dropFirst" onclick="document.getElementById('fileFirst').click()">
                <div class="file-drop-text">클릭 또는 드래그</div>
                <div class="file-drop-sub">PDF, Excel, 이미지 등</div>
              </div>
              <input type="file" id="fileFirst" multiple style="display:none;" onchange="handleFiles('first', this.files)"/>
              <div class="file-list" id="fileListFirst"></div>
            </div>

            <!-- 하반기 파일 -->
            <div class="m-group">
              <label class="m-label">하반기 첨부파일</label>
              <div class="file-drop" id="dropSecond" onclick="document.getElementById('fileSecond').click()">
                <div class="file-drop-text">클릭 또는 드래그</div>
                <div class="file-drop-sub">PDF, Excel, 이미지 등</div>
              </div>
              <input type="file" id="fileSecond" multiple style="display:none;" onchange="handleFiles('second', this.files)"/>
              <div class="file-list" id="fileListSecond"></div>
            </div>
          </div>
        </div>

      </form>
    </div>
    <div class="mbox-foot">
      <button type="button" class="mbtn mbtn-cancel" id="btnModalCancel">닫기</button>
      <button type="button" class="mbtn mbtn-save"   id="btnSave">저장</button>
    </div>
  </div>
</div>

<!-- ════════════ 파일 목록 모달 ════════════ -->
<div id="modalFile" class="modal-ov">
  <div class="modal-file-box">
    <div class="mbox-head">
      <h3 id="fileModalTitle">첨부파일</h3>
      <button class="mbox-close" id="btnFileModalClose">✕</button>
    </div>
    <div class="file-preview-list" id="filePreviewList"></div>
    <div class="mbox-foot">
      <button type="button" class="mbtn mbtn-cancel" id="btnFileModalCancel">닫기</button>
    </div>
  </div>
</div>

<div id="excelOverlay"></div>
<div id="excelLoading">엑셀 파일 생성 중...</div>

<script>
  var mainTable;

  /* 파일 상태 저장 (추가/수정 모달용) */
  var attachedFiles = { first: [], second: [] };
  /* 기존 첨부 파일 정보 (수정 시 서버에서 받아온 것) */
  var existingFiles = { first: [], second: [] };

  /* ── 년도 셀렉트 초기화 ── */
  (function initYear() {
    var sel = document.getElementById('searchYear');
    var now = new Date().getFullYear();
    for (var y = now; y >= now - 5; y--) {
      var opt = document.createElement('option');
      opt.value = y;
      opt.textContent = y + '년';
      if (y === now) opt.selected = true;
      sel.appendChild(opt);
    }
  })();

  /* ── 파일 아이콘 ── */
  function getFileIcon(name) {
    return '';
  }

  /* ── 파일 크기 포맷 ── */
  function fmtSize(bytes) {
    if (!bytes) return '';
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  }

  /* ── 파일 핸들러 ── */
  function handleFiles(which, files) {
    for (var i = 0; i < files.length; i++) {
      attachedFiles[which].push(files[i]);
    }
    renderFileList(which);
    /* input 초기화 (같은 파일 재선택 허용) */
    document.getElementById(which === 'first' ? 'fileFirst' : 'fileSecond').value = '';
  }

  function renderFileList(which) {
    var listEl = document.getElementById(which === 'first' ? 'fileListFirst' : 'fileListSecond');
    listEl.innerHTML = '';

    /* 기존 파일 (수정 시) */
    existingFiles[which].forEach(function(f, idx) {
      var div = document.createElement('div');
      div.className = 'file-item';
      div.innerHTML =
        '<span class="file-item-name">' + getFileIcon(f.file_name) + ' ' + f.file_name + '</span>' +
        '<span class="file-item-del" onclick="removeExistingFile(\'' + which + '\',' + idx + ')" title="삭제">✕</span>';
      listEl.appendChild(div);
    });

    /* 새로 추가한 파일 */
    attachedFiles[which].forEach(function(f, idx) {
      var div = document.createElement('div');
      div.className = 'file-item';
      div.innerHTML =
        '<span class="file-item-name">' + getFileIcon(f.name) + ' ' + f.name + ' <span>(' + fmtSize(f.size) + ')</span></span>' +
        '<span class="file-item-del" onclick="removeNewFile(\'' + which + '\',' + idx + ')" title="삭제">✕</span>';
      listEl.appendChild(div);
    });
  }

  function removeExistingFile(which, idx) {
    existingFiles[which].splice(idx, 1);
    renderFileList(which);
  }

  function removeNewFile(which, idx) {
    attachedFiles[which].splice(idx, 1);
    renderFileList(which);
  }

  /* ── 드래그 앤 드롭 ── */
  ['dropFirst', 'dropSecond'].forEach(function(id) {
    var el = document.getElementById(id);
    var which = id === 'dropFirst' ? 'first' : 'second';
    el.addEventListener('dragover',  function(e) { e.preventDefault(); el.classList.add('dragover'); });
    el.addEventListener('dragleave', function()  { el.classList.remove('dragover'); });
    el.addEventListener('drop', function(e) {
      e.preventDefault();
      el.classList.remove('dragover');
      handleFiles(which, e.dataTransfer.files);
    });
  });

  /* ── 모달 표시/숨김 ── */
  function showModal(id) {
    var ov = document.getElementById(id);
    ov.style.display = 'flex';
    setTimeout(function() { ov.classList.add('show'); }, 10);
  }
  function hideModal(id) {
    var ov = document.getElementById(id);
    ov.classList.remove('show');
    setTimeout(function() { ov.style.display = 'none'; }, 230);
  }

  document.getElementById('btnModalClose').addEventListener('click',  function() { hideModal('modalMain'); });
  document.getElementById('btnModalCancel').addEventListener('click', function() { hideModal('modalMain'); });
  document.getElementById('btnFileModalClose').addEventListener('click',  function() { hideModal('modalFile'); });
  document.getElementById('btnFileModalCancel').addEventListener('click', function() { hideModal('modalFile'); });
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') { hideModal('modalMain'); hideModal('modalFile'); }
  });

  /* ── 폼 리셋 ── */
  function resetForm() {
    document.getElementById('mainForm').reset();
    document.getElementById('formId').value = '';
    attachedFiles  = { first: [], second: [] };
    existingFiles  = { first: [], second: [] };
    document.getElementById('fileListFirst').innerHTML  = '';
    document.getElementById('fileListSecond').innerHTML = '';
  }

  /* ── 추가 버튼 ── */
  document.getElementById('btnAdd').addEventListener('click', function() {
    resetForm();
    document.getElementById('modalTitle').textContent = '온도조절계 보정 등록';
    showModal('modalMain');
  });

  /* ── 삭제 버튼 ── */
  document.getElementById('btnDel').addEventListener('click', function() {
    var selected = mainTable.getSelectedData();
    if (!selected.length) { alert('삭제할 행을 선택해주세요.'); return; }
    if (!confirm('선택한 ' + selected.length + '건을 삭제하시겠습니까?')) return;

    var ids = selected.map(function(r) { return r.id; });
    $.ajax({
      url: '/line/condition/tempCalibration/del',
      type: 'POST',
      contentType: 'application/json',
      data: JSON.stringify({ ids: ids }),
      success: function(res) {
        if (res.success) { loadData(); }
        else { alert('삭제 실패: ' + (res.message || '')); }
      },
      error: function() { alert('삭제 중 오류가 발생했습니다.'); }
    });
  });

  /* ── 저장 버튼 ── */
  document.getElementById('btnSave').addEventListener('click', function() {
    var mchName = document.getElementById('formMchName').value.trim();
    var zone    = document.getElementById('formZone').value;
    if (!mchName) { alert('설비명을 입력해주세요.'); document.getElementById('formMchName').focus(); return; }
    if (!zone)    { alert('구분(존)을 선택해주세요.'); document.getElementById('formZone').focus(); return; }

    var formData = new FormData();
    var id = document.getElementById('formId').value;
    if (id) formData.append('id', id);
    formData.append('mch_name',    mchName);
    formData.append('zone',        zone);
    formData.append('before_val',  document.getElementById('formBefore').value.trim());
    formData.append('first_half',  document.getElementById('formFirstHalf').value.trim());
    formData.append('second_half', document.getElementById('formSecondHalf').value.trim());

    /* 새 파일 */
    attachedFiles.first.forEach(function(f)  { formData.append('file_first',  f); });
    attachedFiles.second.forEach(function(f) { formData.append('file_second', f); });

    /* 기존 파일 유지 목록 */
    formData.append('keep_first',  JSON.stringify(existingFiles.first.map(function(f){ return f.file_id; })));
    formData.append('keep_second', JSON.stringify(existingFiles.second.map(function(f){ return f.file_id; })));

    var url = id
      ? '/line/condition/tempCalibration/update'
      : '/line/condition/tempCalibration/insert';

    $.ajax({
      url: url,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      success: function(res) {
        if (res.success) {
          alert('저장되었습니다.');
          hideModal('modalMain');
          loadData();
        } else {
          alert('저장 실패: ' + (res.message || ''));
        }
      },
      error: function(xhr) {
        alert('저장 중 오류: ' + xhr.status);
      }
    });
  });

  /* ── 엑셀 버튼 ── */
  document.getElementById('btnExcel').addEventListener('click', function() {
    $('#excelOverlay,#excelLoading').show();
    $.ajax({
      url: '/line/condition/tempCalibration/excel',
      method: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({
        year:     document.getElementById('searchYear').value,
        mch_name: document.getElementById('searchMch').value
      }),
      success: function(result) {
        if (result && result.downloadPath) {
          var a = document.createElement('a');
          a.href = result.downloadPath;
          a.style.display = 'none';
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
        } else {
          alert('엑셀 생성 오류');
        }
      },
      error: function() { alert('엑셀 처리 중 오류가 발생했습니다.'); },
      complete: function() { $('#excelOverlay,#excelLoading').hide(); }
    });
  });

  /* ── 파일 셀 클릭 → 파일 미리보기 모달 ── */
function showFileModal(files, label) {
    var listEl = document.getElementById('filePreviewList');
    listEl.innerHTML = '';
    document.getElementById('fileModalTitle').textContent = label + ' 첨부파일';

    if (!files || !files.length) {
        listEl.innerHTML = '<div style="text-align:center; padding:20px; color:var(--text-m); font-size:13px;">첨부된 파일이 없습니다.</div>';
    } else {
    	files.forEach(function(f) {
    	    var div = document.createElement('div');
    	    div.className = 'file-preview-item';
    	    div.innerHTML =
    	        '<span class="file-icon">' + getFileIcon(f.file_name) + '</span>' +
    	        '<div class="file-info">' +
    	            '<div class="file-info-name">' + f.file_name + '</div>' +
    	            '<div class="file-info-size">' + fmtSize(f.file_size) + '</div>' +
    	        '</div>' +
    	        '<button class="file-dl-btn">다운로드</button>';

    	    // div 클릭 막기
    	    div.style.cursor = 'default';

    	    // 버튼에만 클릭 이벤트 등록
    	    var btn = div.querySelector('.file-dl-btn');
    	    btn.addEventListener('click', function(e) {
    	        e.stopPropagation();  // 부모로 이벤트 전파 차단
    	        location.href = f.file_path;
    	    });

    	    listEl.appendChild(div);
    	});
    }
    showModal('modalFile');
}

  function downloadFile(path, name) {
    var a = document.createElement('a');
    a.href = path;
    a.download = name;
    a.style.display = 'none';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }

  /* ── 파일 카운트 뱃지 렌더 ── */
/* ── 파일 카운트 뱃지 렌더 ── */
function renderFileBadge(files, label) {
    if (!files || !files.length) {
        return '<span class="muted">-</span>';
    }
    var nm = files[0].file_name || '첨부파일';
    var more = files.length > 1 ? ' <span class="muted">외 ' + (files.length - 1) + '</span>' : '';
    return '<span class="file-link" style="max-width:180px;" title="' + nm + '">' + nm + '</span>' + more;
}

  function escapeJson(str) {
    return str.replace(/'/g, "\\'");
  }

  /* ── Tabulator 초기화 ── */
  function initTable() {
    mainTable = new Tabulator('#mainTable', {
      height: '100%',
      layout: 'fitDataFill',
      layoutColumnsOnNewData: true,
      selectable: true,
      columnHeaderVertAlign: 'middle',
      rowVertAlign: 'middle',
      headerHozAlign: 'center',
      placeholder: '조회된 데이터가 없습니다.',
      columnDefaults: { hozAlign: 'center', headerTooltip: false },
      columns: [
        { formatter: 'rowSelection', titleFormatter: 'rowSelection', hozAlign: 'center', headerSort: false, width: 50 },
        { title: 'No',     formatter: 'rownum', hozAlign: 'center', width: 50,  headerSort: false },
        { title: 'ID',     field: 'id',        visible: false },
        {
          title: '설비명',
          field: 'mch_name',
          width: 240,
          hozAlign: 'center',
          formatter: function(cell) {
            var v = cell.getValue() || '';
            return v;
          }
        },
        {
          title: '구분 (존)',
          field: 'zone',
          width: 90,
          hozAlign: 'center',
          headerSort: false,
          formatter: function(cell) {
            var v = cell.getValue();
            if (!v) return '-';
            return v + '존';
          }
        },
        {
          title: '보정 전',
          field: 'before_val',
          width: 120,
          hozAlign: 'center',
          headerSort: false,
          formatter: function(cell) {
            var v = cell.getValue();
            return v != null && v !== '' ? v : '<span style="color:var(--text-m);">-</span>';
          }
        },
        {
          title: '상반기 보정',
          field: 'first_half',
          width: 120,
          hozAlign: 'center',
          headerSort: false,
          formatter: function(cell) {
            var v = cell.getValue();
            if (v == null || v === '') return '<span class="muted">미보정</span>';
            return '<span class="num">' + v + '</span>';
          }
        },
        {
          title: '하반기 보정',
          field: 'second_half',
          width: 120,
          hozAlign: 'center',
          headerSort: false,
          formatter: function(cell) {
            var v = cell.getValue();
            if (v == null || v === '') return '<span class="muted">미보정</span>';
            return '<span class="num">' + v + '</span>';
          }
        },
        {
            title: '상반기 파일',
            field: 'files_first',
            width: 210,
            hozAlign: 'center',
            headerSort: false,
            formatter: function(cell) {
                return renderFileBadge(cell.getValue(), '상반기');
            },
            cellClick: function(e, cell) {
                e.stopPropagation();
                var files = cell.getValue();
                if (files && files.length) {
                    showFileModal(files, '상반기');
                }
            }
        },
        {
            title: '하반기 파일',
            field: 'files_second',
            width: 210,
            hozAlign: 'center',
            headerSort: false,
            formatter: function(cell) {
                return renderFileBadge(cell.getValue(), '하반기');
            },
            cellClick: function(e, cell) {
                e.stopPropagation();
                var files = cell.getValue();
                if (files && files.length) {
                    showFileModal(files, '하반기');
                }
            }
        },
        {
          title: '등록일',
          field: 'reg_date',
          width: 110,
          hozAlign: 'center',
          formatter: function(cell) {
            var v = cell.getValue();
            return v ? v.substring(0, 10) : '-';
          }
        },
        {
          title: '등록자',
          field: 'reg_user',
          width: 90,
          hozAlign: 'center',
          headerSort: false
        }
      ],

      rowDblClick: function(e, row) {
        var d = row.getData();
        resetForm();
        document.getElementById('modalTitle').textContent = '온도조절계 보정 수정';
        document.getElementById('formId').value           = d.id        || '';
        document.getElementById('formMchName').value      = d.mch_name  || '';
        document.getElementById('formZone').value         = d.zone      || '';
        document.getElementById('formBefore').value       = d.before_val  || '';
        document.getElementById('formFirstHalf').value    = d.first_half  || '';
        document.getElementById('formSecondHalf').value   = d.second_half || '';

        /* 기존 첨부 파일 복원 */
        existingFiles.first  = (d.files_first  || []).slice();
        existingFiles.second = (d.files_second || []).slice();
        renderFileList('first');
        renderFileList('second');

        showModal('modalMain');
      }
    });
  }

  /* ── 데이터 조회 ── */
  function loadData() {
    $.ajax({
      type: 'POST',
      url: '/line/condition/tempCalibration/list',
      contentType: 'application/json',
      data: JSON.stringify({
        year:     document.getElementById('searchYear').value,
        mch_name: document.getElementById('searchMch').value
      }),
      success: function(res) {
        var rows = res.list || [];
        mainTable.setData(rows);

        /* 설비 셀렉트 동적 업데이트 */
        var mchSet = {};
        rows.forEach(function(r) { if (r.mch_name) mchSet[r.mch_name] = true; });
        var sel = document.getElementById('searchMch');
        var cur = sel.value;
        sel.innerHTML = '<option value="">전체</option>';
        Object.keys(mchSet).sort().forEach(function(m) {
          var opt = document.createElement('option');
          opt.value = m; opt.textContent = m;
          if (m === cur) opt.selected = true;
          sel.appendChild(opt);
        });
      },
      error: function() {
        alert('조회에 실패했습니다.');
      }
    });
  }

  /* ── 초기 실행 ── */
  $(function() {
    initTable();
    loadData();
  });
</script>

</body>
</html>
