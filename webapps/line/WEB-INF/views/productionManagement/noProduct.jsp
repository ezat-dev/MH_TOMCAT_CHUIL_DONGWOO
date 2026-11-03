<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>부적합품</title>
<%@include file="../include/pluginpage.jsp" %>
<jsp:include page="../include/tabBar.jsp"/>
<link href="/vendor/tabulator/5.5.0/tabulator.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
<style>
:root {
  --bg:        #f0f2f7;
  --surface:   #ffffff;
  --surface2:  #f7f8fc;
  --border:    #e2e6ef;
  --text-p:    #0f172a;
  --text-s:    #64748b;
  --text-m:    #94a3b8;
  --red:       #dc2626;
  --red-lt:    #fee2e2;
  --orange:    #ea580c;
  --org-lt:    #ffedd5;
  --green:     #16a34a;
  --grn-lt:    #dcfce7;
  --accent:    #2563eb;
  --acc-lt:    #dbeafe;
  --yellow:    #d97706;
  --yel-lt:    #fef3c7;
  --purple:    #7c3aed;
  --pur-lt:    #ede9fe;
  --teal:      #0d9488;
  --teal-lt:   #ccfbf1;
  --shadow:    0 1px 3px rgba(0,0,0,.06);
  --shadow-md: 0 4px 16px rgba(0,0,0,.08);
  --radius:    12px;
}

*{ box-sizing:border-box; margin:0; padding:0; }
body {
  font-family:'Noto Sans KR', sans-serif;
  background:var(--bg); color:var(--text-p); min-height:100vh;
}

/* ===== TOPBAR ===== */
.topbar {
  position:sticky; top:0; z-index:100;
  background:rgba(255,255,255,.96);
  backdrop-filter:blur(12px);
  border-bottom:1px solid var(--border);
  box-shadow:var(--shadow);
}
.topbar-inner {
  max-width:1700px; margin:0 auto;
  padding:0 24px; height:54px;
  display:flex; align-items:center; gap:10px; flex-wrap:wrap;
}
.tb-title {
  font-size:14px; font-weight:800; color:var(--text-p);
  letter-spacing:-.3px; white-space:nowrap; margin-right:6px;
  display:flex; align-items:center; gap:7px;
}
.tb-title .icon {
  width:22px; height:22px; border-radius:7px;
  background:linear-gradient(135deg,#7c3aed,#dc2626);
  display:flex; align-items:center; justify-content:center; flex-shrink:0;
}
.tb-title .icon svg { width:12px; height:12px; stroke:#fff; }
.tb-div { width:1px; height:20px; background:var(--border); flex-shrink:0; }
.tb-label { font-size:12px; font-weight:700; color:var(--text-s); white-space:nowrap; }

.ctrl {
  height:32px; padding:0 10px;
  border:1px solid var(--border); border-radius:8px;
  background:var(--surface2); color:var(--text-p);
  font-size:13px; font-family:'Noto Sans KR',sans-serif;
  outline:none; transition:border-color .15s, box-shadow .15s;
  min-width:148px; text-align:center;
}
.ctrl:focus { border-color:var(--accent); box-shadow:0 0 0 3px rgba(37,99,235,.12); }

.btn {
  height:32px; padding:0 13px; border-radius:8px;
  font-size:12px; font-family:'Noto Sans KR',sans-serif; font-weight:700;
  display:inline-flex; align-items:center; gap:5px;
  cursor:pointer; transition:filter .15s, transform .08s;
  white-space:nowrap; border:1px solid transparent;
}
.btn:active { transform:translateY(1px); }
.btn svg { width:13px; height:13px; flex-shrink:0; }
.btn-search { background:linear-gradient(135deg,#64748b,#475569); color:#fff; border-color:#475569; box-shadow:0 2px 6px rgba(71,85,105,.3); }
.btn-insert { background:linear-gradient(135deg,#2563eb,#1d4ed8); color:#fff; border-color:#1d4ed8; box-shadow:0 2px 6px rgba(37,99,235,.3); }
.btn-delete { background:linear-gradient(135deg,#dc2626,#b91c1c); color:#fff; border-color:#b91c1c; box-shadow:0 2px 6px rgba(220,38,38,.3); }
.btn-excel  { background:linear-gradient(135deg,#16a34a,#15803d); color:#fff; border-color:#15803d; }
.btn:hover  { filter:brightness(1.08); }

/* ===== PAGE ===== */
.page {
  max-width:1700px; margin:0 auto;
  padding:16px 24px 28px;
  display:flex; flex-direction:column; gap:14px;
}

/* ===== KPI ===== */
.kpi-row {
  display:grid; grid-template-columns:repeat(5,1fr); gap:12px;
}
@media(max-width:1100px){ .kpi-row{ grid-template-columns:repeat(3,1fr); } }
@media(max-width:700px) { .kpi-row{ grid-template-columns:repeat(2,1fr); } }

.kpi-card {
  background:var(--surface); border:1px solid var(--border);
  border-radius:var(--radius); padding:14px 18px;
  box-shadow:var(--shadow); display:flex; align-items:center; gap:14px;
  position:relative; overflow:hidden; animation:fadeUp .3s ease both;
}
.kpi-card::before {
  content:''; position:absolute; top:0; left:0; right:0; height:3px;
  border-radius:var(--radius) var(--radius) 0 0;
}
.kpi-card:nth-child(1){ animation-delay:.04s; }
.kpi-card:nth-child(2){ animation-delay:.08s; }
.kpi-card:nth-child(3){ animation-delay:.12s; }
.kpi-card:nth-child(4){ animation-delay:.16s; }
.kpi-card:nth-child(5){ animation-delay:.20s; }

.kpi-card.k-total::before  { background:linear-gradient(90deg,#64748b,#94a3b8); }
.kpi-card.k-defect::before { background:linear-gradient(90deg,#dc2626,#f87171); }
.kpi-card.k-cnt::before    { background:linear-gradient(90deg,#ea580c,#fb923c); }
.kpi-card.k-type::before   { background:linear-gradient(90deg,#7c3aed,#a78bfa); }
.kpi-card.k-ok::before     { background:linear-gradient(90deg,#16a34a,#4ade80); }

@keyframes fadeUp {
  from{ opacity:0; transform:translateY(10px); }
  to  { opacity:1; transform:none; }
}

.kpi-icon { width:38px; height:38px; border-radius:10px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.kpi-icon svg { width:18px; height:18px; }
.k-total  .kpi-icon { background:#f1f5f9; color:#64748b; }
.k-defect .kpi-icon { background:var(--red-lt); color:var(--red); }
.k-cnt    .kpi-icon { background:var(--org-lt); color:var(--orange); }
.k-type   .kpi-icon { background:var(--pur-lt); color:var(--purple); }
.k-ok     .kpi-icon { background:var(--grn-lt); color:var(--green); }

.kpi-info  { display:flex; flex-direction:column; gap:2px; }
.kpi-label { font-size:11px; font-weight:700; color:var(--text-m); text-transform:uppercase; letter-spacing:.5px; }
.kpi-value { font-size:26px; font-weight:800; font-family:'JetBrains Mono',monospace; color:var(--text-p); line-height:1; letter-spacing:-1px; }
.kpi-sub   { font-size:11px; color:var(--text-m); margin-top:2px; }

/* ===== MAIN CARD ===== */
.main-card {
  background:var(--surface); border:1px solid var(--border);
  border-radius:var(--radius); box-shadow:var(--shadow);
  overflow:hidden; animation:fadeUp .35s .2s ease both;
}
.card-head {
  padding:14px 20px; border-bottom:1px solid var(--border);
  display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap;
}
.card-head-title { font-size:13px; font-weight:800; color:var(--text-p); }
.card-foot {
  padding:8px 16px; border-top:1px solid var(--border);
  background:var(--surface2);
  display:flex; align-items:center; justify-content:space-between;
  font-size:12px; color:var(--text-m);
}
.card-foot strong { color:var(--text-p); font-family:'JetBrains Mono',monospace; }

/* ===== TABULATOR OVERRIDES ===== */
#tab1 .tabulator {
  border:none !important; border-radius:0 !important;
  font-family:'Noto Sans KR',sans-serif !important; font-size:13px !important; box-shadow:none !important;
}
#tab1 .tabulator-header { background:var(--surface2) !important; border-bottom:2px solid var(--border) !important; }
#tab1 .tabulator-col {
  background:var(--surface2) !important; border-right:1px solid var(--border) !important;
  font-size:11px !important; font-weight:800 !important;
  color:var(--text-s) !important; text-transform:uppercase !important; letter-spacing:.3px !important;
}
#tab1 .tabulator-col-title { padding:8px 6px !important; }
#tab1 .tabulator-row { border-bottom:1px solid var(--border) !important; transition:background .1s !important; }
#tab1 .tabulator-row:hover { background:#f8faff !important; }
#tab1 .tabulator-row.row_select { background:#dbeafe !important; }
#tab1 .tabulator-cell { padding:7px 10px !important; border-right:1px solid #f1f5f9 !important; }
#tab1 .tabulator-placeholder { color:var(--text-m) !important; font-size:13px !important; }

/* 셀 뱃지 */
.lot-tag  { font-family:'JetBrains Mono',monospace; font-size:12px; font-weight:700; color:var(--accent); }
.date-tag { display:inline-block; padding:2px 8px; border-radius:5px; background:var(--pur-lt); border:1px solid #ddd6fe; font-family:'JetBrains Mono',monospace; font-size:11px; font-weight:600; color:var(--purple); }
.type-tag { display:inline-block; padding:2px 8px; border-radius:12px; background:var(--red-lt); border:1px solid #fca5a5; font-size:11px; font-weight:700; color:var(--red); }
.cnt-tag  { font-family:'JetBrains Mono',monospace; font-size:13px; font-weight:800; color:var(--orange); }
.cell-o   { display:inline-flex; align-items:center; justify-content:center; width:24px; height:24px; border-radius:50%; background:var(--grn-lt); color:var(--green); font-size:13px; font-weight:800; border:1.5px solid #86efac; }
.cell-x   { display:inline-flex; align-items:center; justify-content:center; width:24px; height:24px; border-radius:50%; background:var(--red-lt); color:var(--red); font-size:12px; font-weight:800; border:1.5px solid #fca5a5; }
.cell-empty { display:inline-flex; align-items:center; justify-content:center; width:24px; height:24px; border-radius:50%; background:var(--surface2); color:var(--text-m); font-size:11px; border:1px solid var(--border); }

/* ===== MODAL OVERLAY ===== */
.modal-overlay {
  display:none; position:fixed; inset:0;
  background:rgba(0,0,0,.45); backdrop-filter:blur(4px);
  z-index:500; align-items:center; justify-content:center;
  opacity:0; transition:opacity .2s;
}
.modal-overlay.show { display:flex; opacity:1; }

.modal-box {
  background:var(--surface); border-radius:16px;
  width:480px; max-width:95vw; max-height:90vh; overflow-y:auto;
  box-shadow:0 20px 60px rgba(0,0,0,.2); padding:28px; position:relative;
  transform:scale(.94) translateY(10px); transition:transform .2s, opacity .2s; opacity:0;
}
.modal-overlay.show .modal-box { transform:scale(1) translateY(0); opacity:1; }

.modal-head { display:flex; align-items:center; justify-content:space-between; margin-bottom:20px; }
.modal-head h2 { font-size:16px; font-weight:800; color:var(--text-p); }
.modal-close {
  width:28px; height:28px; border-radius:8px;
  background:var(--surface2); border:1px solid var(--border);
  display:flex; align-items:center; justify-content:center;
  cursor:pointer; transition:background .15s; font-size:14px; color:var(--text-s);
}
.modal-close:hover { background:var(--border); }

.form-group { margin-bottom:14px; }
.form-label { font-size:12px; font-weight:700; color:var(--text-s); margin-bottom:5px; display:block; letter-spacing:.3px; }
.form-input {
  width:100%; height:36px; padding:0 12px;
  border:1px solid var(--border); border-radius:8px;
  background:var(--surface2); color:var(--text-p);
  font-size:13px; font-family:'Noto Sans KR',sans-serif;
  outline:none; transition:border-color .15s, box-shadow .15s;
}
.form-input:focus { border-color:var(--accent); box-shadow:0 0 0 3px rgba(37,99,235,.12); background:#fff; }
.form-input[type="number"]{ -moz-appearance:textfield; }
.form-select {
  width:100%; height:36px; padding:0 12px;
  border:1px solid var(--border); border-radius:8px;
  background:var(--surface2); color:var(--text-p);
  font-size:13px; font-family:'Noto Sans KR',sans-serif; outline:none; cursor:pointer;
}

.radio-row { display:flex; gap:12px; align-items:center; }
.radio-item { display:flex; align-items:center; gap:5px; padding:5px 10px; border:1px solid var(--border); border-radius:8px; cursor:pointer; transition:all .15s; font-size:13px; }
.radio-item:has(input:checked) { border-color:var(--accent); background:var(--acc-lt); color:var(--accent); font-weight:700; }
.radio-item input { accent-color:var(--accent); }

.input-with-btn { display:flex; gap:8px; }
.input-with-btn .form-input { flex:1; }
.btn-search-sm {
  height:36px; padding:0 12px; border-radius:8px;
  font-size:12px; font-weight:700; font-family:'Noto Sans KR',sans-serif;
  background:var(--surface2); color:var(--text-s); border:1px solid var(--border);
  cursor:pointer; white-space:nowrap; transition:background .15s;
}
.btn-search-sm:hover { background:var(--border); }

.modal-btn-row { display:flex; gap:8px; margin-top:20px; }
.modal-btn { flex:1; height:38px; border-radius:8px; font-size:13px; font-weight:700; font-family:'Noto Sans KR',sans-serif; border:none; cursor:pointer; transition:filter .15s, transform .08s; }
.modal-btn:active { transform:translateY(1px); }
.modal-btn-save   { background:linear-gradient(135deg,#7c3aed,#6d28d9); color:#fff; }
.modal-btn-cancel { background:var(--surface2); color:var(--text-s); border:1px solid var(--border); }
.modal-btn:hover  { filter:brightness(1.07); }

/* 품번 검색 모달 */
.pumbun-overlay {
  display:none; position:fixed; inset:0;
  background:rgba(0,0,0,.5); backdrop-filter:blur(4px);
  z-index:600; align-items:center; justify-content:center;
  opacity:0; transition:opacity .2s;
}
.pumbun-overlay.show { display:flex; opacity:1; }
.pumbun-box {
  background:var(--surface); border-radius:16px;
  width:680px; max-width:96vw; max-height:88vh; overflow-y:auto;
  box-shadow:0 20px 60px rgba(0,0,0,.25); padding:24px; position:relative;
  transform:scale(.94); transition:transform .2s, opacity .2s; opacity:0;
}
.pumbun-overlay.show .pumbun-box { transform:scale(1); opacity:1; }
.pumbun-search-row { display:flex; gap:10px; align-items:center; margin-bottom:14px; flex-wrap:wrap; }
.pumbun-search-row .form-input { height:30px; min-width:110px; flex:1; }
.pumbun-search-row .btn { height:30px; }

/* 품번 tabulator */
#pumbunTabu .tabulator { border:none !important; font-size:13px !important; }
#pumbunTabu .tabulator-header { background:var(--surface2) !important; border-bottom:2px solid var(--border) !important; }
#pumbunTabu .tabulator-col { background:var(--surface2) !important; font-size:11px !important; font-weight:800 !important; color:var(--text-s) !important; }
#pumbunTabu .tabulator-row { border-bottom:1px solid var(--border) !important; cursor:pointer; }
#pumbunTabu .tabulator-row:hover { background:#f8faff !important; }
#pumbunTabu .tabulator-row.row_select { background:#dbeafe !important; }
</style>
</head>
<body>

<!-- ===== TOPBAR ===== -->
<div class="topbar">
  <div class="topbar-inner">
    <div class="tb-title">
      <span class="icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
      </span>
      부적합품 관리
    </div>
    <div class="tb-div"></div>
    <span class="tb-label">작업일자</span>
    <input type="text" class="ctrl dayselect daySet" placeholder="YYYY-MM" autocomplete="off"/>
    <div class="tb-div"></div>
    <button class="btn btn-search select-button" onclick="getnoProductList();">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
      </svg>조회
    </button>
    <button class="btn btn-insert insert-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/>
      </svg>추가
    </button>
    <button class="btn btn-delete delete-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/>
        <path d="M10 11v6"/><path d="M14 11v6"/>
      </svg>삭제
    </button>
    <button class="btn btn-excel excel-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
        <line x1="12" y1="12" x2="12" y2="18"/><line x1="9" y1="15" x2="15" y2="15"/>
      </svg>Download
    </button>
    <input type="file" id="fileInput" style="display:none;">
  </div>
</div>

<!-- ===== PAGE ===== -->
<div class="page">

  <!-- KPI 카드 -->
  <div class="kpi-row">
    <div class="kpi-card k-total">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/>
          <line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">전체 건수</div>
        <div class="kpi-value" id="kpi-total">0</div>
        <div class="kpi-sub">조회된 총 건수</div>
      </div>
    </div>
    <div class="kpi-card k-defect">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
          <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">최다 불량유형</div>
        <div class="kpi-value" id="kpi-defect" style="font-size:14px; margin-top:3px;">-</div>
        <div class="kpi-sub" id="kpi-defect-sub">유형별 1위</div>
      </div>
    </div>
    <div class="kpi-card k-cnt">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/>
          <line x1="6" y1="20" x2="6" y2="14"/><line x1="2" y1="20" x2="22" y2="20"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">총 불량수량</div>
        <div class="kpi-value" id="kpi-cnt">0</div>
        <div class="kpi-sub">EA 합계</div>
      </div>
    </div>
    <div class="kpi-card k-type">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/>
          <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">불량 유형 수</div>
        <div class="kpi-value" id="kpi-type">0</div>
        <div class="kpi-sub">고유 유형 수</div>
      </div>
    </div>
    <div class="kpi-card k-ok">
      <div class="kpi-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
      </div>
      <div class="kpi-info">
        <div class="kpi-label">조치 완료</div>
        <div class="kpi-value" id="kpi-ok">0</div>
        <div class="kpi-sub">대상+실시 O 건수</div>
      </div>
    </div>
  </div>

  <!-- 메인 테이블 카드 -->
  <div class="main-card">
    <div class="card-head">
      <span class="card-head-title">🚫 부적합품 현황</span>
      <span style="font-size:11px; color:var(--text-m);" id="card-date-label">-</span>
    </div>
    <div id="tab1"></div>
    <div class="card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회: <strong id="footer-time">-</strong></span>
    </div>
  </div>

</div>

<!-- ===== 부적합품 등록/수정 모달 ===== -->
<div id="modalContainer" class="modal-overlay">
  <div class="modal-box">
    <div class="modal-head">
      <h2>🚫 부적합품 등록</h2>
      <span class="modal-close" id="mainClose">✕</span>
    </div>
    <form id="corrForm" autocomplete="off">
      <input type="hidden" name="idx"/>

      <div class="form-group">
        <label class="form-label">발생일</label>
        <input type="text" name="d_date" class="form-input" placeholder="YYYY-MM-DD"/>
      </div>
      <div class="form-group">
        <label class="form-label">작업 LOT</label>
        <div class="input-with-btn">
          <input type="text" name="d_lot" class="form-input" placeholder="작업 LOT 입력"/>
          <button type="button" class="btn-search-sm" id="btnPumbunOpen">🔍 제품 검색</button>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">품번</label>
        <input type="text" name="d_pum_bun" class="form-input" placeholder="품번"/>
      </div>
      <div class="form-group">
        <label class="form-label">품명</label>
        <input type="text" name="d_pum_name" class="form-input" placeholder="품명"/>
      </div>
      <div class="form-group">
        <label class="form-label">불량유형</label>
        <select name="d_way" class="form-select">
          <option value="액고임">액고임</option>
          <option value="이종혼입">이종혼입</option>
          <option value="녹 발생">녹 발생</option>
          <option value="코팅 문제">코팅 문제</option>
          <option value="이물질">이물질</option>
          <option value="색상 이상">색상 이상</option>
          <option value="크랙">크랙</option>
          <option value="찍힘">찍힘</option>
          <option value="기타">기타</option>
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">종료시간</label>
        <input type="text" name="d_end_time" class="form-input" placeholder="HH:MM"/>
      </div>
      <div class="form-group">
        <label class="form-label">불량수량 (EA)</label>
        <input type="number" name="no_pro_cnt" class="form-input" placeholder="불량수량 입력"/>
      </div>
      <div class="form-group">
        <label class="form-label">발생원인</label>
        <input type="text" name="d_cause" class="form-input" placeholder="발생원인 입력"/>
      </div>
      <div class="form-group">
        <label class="form-label">조치내용</label>
        <input type="text" name="d_after" class="form-input" placeholder="조치내용 입력"/>
      </div>
      <div class="form-group">
        <label class="form-label">대상유무</label>
        <div class="radio-row">
          <label class="radio-item"><input type="radio" name="d_yn_1" value="O"> O</label>
          <label class="radio-item"><input type="radio" name="d_yn_1" value="X"> X</label>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">실시유무</label>
        <div class="radio-row">
          <label class="radio-item"><input type="radio" name="d_yn_2" value="O"> O</label>
          <label class="radio-item"><input type="radio" name="d_yn_2" value="X"> X</label>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">작성자</label>
        <input type="text" name="d_name" class="form-input" placeholder="작성자 입력"/>
      </div>
      <div class="form-group">
        <label class="form-label">특이사항</label>
        <input type="text" name="d_bigo" class="form-input" placeholder="특이사항 입력"/>
      </div>
      <div class="modal-btn-row">
        <button type="submit" id="saveCorrStatus" class="modal-btn modal-btn-save">저장</button>
        <button type="button" id="closeModal" class="modal-btn modal-btn-cancel">닫기</button>
      </div>
    </form>
  </div>
</div>

<!-- ===== 품번 검색 모달 ===== -->
<div id="pumbunModal" class="pumbun-overlay">
  <div class="pumbun-box">
    <div class="modal-head" style="margin-bottom:16px;">
      <h2>🔍 품번 검색</h2>
      <span class="modal-close" id="pumbunClose">✕</span>
    </div>
    <div class="pumbun-search-row">
      <span class="tb-label">품번</span>
      <input type="text" id="s_pnum" class="form-input pumModalEnter" placeholder="품번 입력"/>
      <span class="tb-label">품명</span>
      <input type="text" id="s_gang" class="form-input pumModalEnter" placeholder="품명 입력"/>
      <button class="btn btn-search" type="button" onclick="initPumbunTabu();">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>조회
      </button>
    </div>
    <div id="pumbunTabu"></div>
  </div>
</div>

<script>
let now_page_code = "e07";
let userTable   = null;
let pumbunTabu  = null;

/* ─── 날짜 유틸 ─── */
function pad2(n){ return String(n).padStart(2,'0'); }
function todayDate(){
  var d = new Date();
  return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate());
}
function todayMonth(){
  var d = new Date();
  return d.getFullYear()+'-'+pad2(d.getMonth()+1);
}

/* ─── O/X 포매터 ─── */
function oxFormatter(cell){
  var v = (cell.getValue()||'').toString().trim().toUpperCase();
  if(v==='O') return '<div style="display:flex;justify-content:center;"><span class="cell-o">O</span></div>';
  if(v==='X') return '<div style="display:flex;justify-content:center;"><span class="cell-x">✕</span></div>';
  return '<div style="display:flex;justify-content:center;"><span class="cell-empty">-</span></div>';
}

/* ─── KPI 업데이트 ─── */
function updateKpi(data){
  var total  = data.length;
  var cntSum = data.reduce(function(a,r){ return a+(Number(r.no_pro_cnt)||0); }, 0);

  // 불량유형 집계
  var typeMap = {};
  data.forEach(function(r){ var t=r.d_way||'기타'; typeMap[t]=(typeMap[t]||0)+1; });
  var topType='-', topCnt=0;
  Object.keys(typeMap).forEach(function(k){ if(typeMap[k]>topCnt){ topCnt=typeMap[k]; topType=k; } });
  var typeCount = Object.keys(typeMap).length;

  // 조치완료 (d_yn_1, d_yn_2 모두 O)
  var okCnt = data.filter(function(r){ return (r.d_yn_1||'').toUpperCase()==='O' && (r.d_yn_2||'').toUpperCase()==='O'; }).length;

  document.getElementById('kpi-total').textContent  = total.toLocaleString();
  document.getElementById('kpi-cnt').textContent    = cntSum.toLocaleString();
  document.getElementById('kpi-type').textContent   = typeCount.toLocaleString();
  document.getElementById('kpi-ok').textContent     = okCnt.toLocaleString();

  var defEl = document.getElementById('kpi-defect');
  defEl.textContent = topType.length > 8 ? topType.substring(0,8)+'…' : topType;
  defEl.title = topType;
  document.getElementById('kpi-defect-sub').textContent = topCnt + '건 발생';

  var dateVal = document.querySelector('.dayselect').value || '-';
  document.getElementById('card-date-label').textContent = dateVal + ' 기준';
  document.getElementById('footer-info').innerHTML = '총 <strong>'+total+'</strong>건';

  var now = new Date();
  document.getElementById('footer-time').textContent =
    pad2(now.getHours())+':'+pad2(now.getMinutes())+':'+pad2(now.getSeconds());
}

/* ─── 부적합 리스트 조회 ─── */
function getnoProductList(){
  userTable = new Tabulator("#tab1", {
    height: "600px",
    layout: "fitColumns",
    selectable: true,
    reactiveData: true,
    headerHozAlign: "center",
    ajaxConfig: "POST",
    ajaxLoader: false,
    ajaxURL: "/line/productionManagement/noProduct/getNoProductList",
    ajaxParams: { w_date: document.querySelector('.dayselect').value },
    ajaxResponse: function(url, params, response){
      var data = response.data || [];
      updateKpi(data);
      return data;
    },
    placeholder: "조회된 데이터가 없습니다.",
    columns: [
      { title:"IDX",       field:"idx",        visible:false },
      { title:"발생일",    field:"d_date",     hozAlign:"center", width:120,
        formatter:function(c){ return c.getValue()?'<span class="date-tag">'+c.getValue()+'</span>':'-'; }
      },
      { title:"작업 LOT",  field:"d_lot",      hozAlign:"center", width:130,
        formatter:function(c){ return c.getValue()?'<span class="lot-tag">'+c.getValue()+'</span>':'-'; }
      },
      { title:"품번",      field:"d_pum_bun",  hozAlign:"center", width:150 },
      { title:"품명",      field:"d_pum_name", hozAlign:"left",   width:150 },
      { title:"불량유형",  field:"d_way",      hozAlign:"center", width:120,
        formatter:function(c){ return c.getValue()?'<span class="type-tag">'+c.getValue()+'</span>':'-'; }
      },
      { title:"종료시간",  field:"d_end_time", hozAlign:"center", width:100 },
      { title:"불량수량",  field:"no_pro_cnt", hozAlign:"center", width:100,
        formatter:function(c){ return c.getValue()?'<span class="cnt-tag">'+Number(c.getValue()).toLocaleString()+'</span>':'-'; }
      },
      { title:"발생원인",  field:"d_cause",    hozAlign:"left",   width:220 },
      { title:"조치내용",  field:"d_after",    hozAlign:"left",   width:220 },
      { title:"대상유무",  field:"d_yn_1",     hozAlign:"center", width:90,  formatter:oxFormatter },
      { title:"실시유무",  field:"d_yn_2",     hozAlign:"center", width:90,  formatter:oxFormatter },
      { title:"작성자",    field:"d_name",     hozAlign:"center", width:90 },
      { title:"특이사항",  field:"d_bigo",     hozAlign:"left",   width:180 }
    ],
    rowFormatter: function(row){
      var d = row.getData();
      var hasDefect = (d.d_yn_1||'').toUpperCase()==='O' || (d.d_yn_2||'').toUpperCase()==='O';
      if(hasDefect){
        row.getElement().style.background = '#fff7f7';
        row.getElement().style.borderLeft = '3px solid #dc2626';
      } else {
        row.getElement().style.background = '#fff';
        row.getElement().style.borderLeft = 'none';
      }
    },
    rowClick: function(e, row){
      document.querySelectorAll('#tab1 .tabulator-row').forEach(function(el){ el.classList.remove('row_select'); });
      row.getElement().classList.add('row_select');
    },
    rowDblClick: function(e, row){
      var d = row.getData();
      document.getElementById('corrForm').reset();
      $("input[name='idx']").val(d.idx);
      $("input[name='d_date']").val(d.d_date);
      $("input[name='d_lot']").val(d.d_lot);
      $("input[name='d_pum_bun']").val(d.d_pum_bun);
      $("input[name='d_pum_name']").val(d.d_pum_name);
      $("select[name='d_way']").val(d.d_way);
      $("input[name='d_end_time']").val(d.d_end_time);
      $("input[name='no_pro_cnt']").val(d.no_pro_cnt);
      $("input[name='d_cause']").val(d.d_cause);
      $("input[name='d_after']").val(d.d_after);
      $("input[name='d_yn_1'][value='"+d.d_yn_1+"']").prop('checked',true);
      $("input[name='d_yn_2'][value='"+d.d_yn_2+"']").prop('checked',true);
      $("input[name='d_name']").val(d.d_name);
      $("input[name='d_bigo']").val(d.d_bigo);
      showModal('modalContainer');
    }
  });
}

/* ─── 품번 Tabulator 초기화 ─── */
function initPumbunTabu(){
  pumbunTabu = new Tabulator("#pumbunTabu", {
    height: "520px",
    layout: "fitDataFill",
    headerSort: false,
    reactiveData: true,
    headerHozAlign: "center",
    ajaxConfig: { method:"POST" },
    ajaxURL: "/line/productionManagement/heatTreatment/pumbun/list",
    ajaxProgressiveLoad: "scroll",
    ajaxParams: {
      item_no:   document.getElementById('s_pnum').value,
      item_name: document.getElementById('s_gang').value,
      cust_name: ""
    },
    ajaxResponse: function(url, params, res){ return res; },
    placeholder: "조회된 데이터가 없습니다.",
    columns: [
      { title:"품번", field:"item_no",   width:260 },
      { title:"품명", field:"item_name", width:300 }
    ],
    rowClick: function(e, row){
      document.querySelectorAll('#pumbunTabu .tabulator-row').forEach(function(el){ el.classList.remove('row_select'); });
      row.getElement().classList.add('row_select');
    },
    rowDblClick: function(e, row){
      var d = row.getData();
      $("input[name='d_pum_bun']").val(d.item_no);
      $("input[name='d_pum_name']").val(d.item_name);
      hideModal('pumbunModal');
    }
  });
}

/* ─── 모달 show/hide ─── */
function showModal(id){
  var ov = document.getElementById(id);
  ov.style.display = 'flex';
  setTimeout(function(){ ov.classList.add('show'); }, 10);
}
function hideModal(id){
  var ov = document.getElementById(id);
  ov.classList.remove('show');
  setTimeout(function(){ ov.style.display = 'none'; }, 220);
}

/* ─── 저장 ─── */
$('#corrForm').on('submit', function(e){
  e.preventDefault();
  var formData = {
    idx:       $("input[name='idx']").val(),
    d_date:    $("input[name='d_date']").val(),
    d_lot:     $("input[name='d_lot']").val(),
    d_pum_bun: $("input[name='d_pum_bun']").val(),
    d_pum_name:$("input[name='d_pum_name']").val(),
    d_way:     $("select[name='d_way']").val(),
    d_end_time:$("input[name='d_end_time']").val(),
    no_pro_cnt:$("input[name='no_pro_cnt']").val(),
    d_cause:   $("input[name='d_cause']").val(),
    d_after:   $("input[name='d_after']").val(),
    d_yn_1:    $("input[name='d_yn_1']:checked").val(),
    d_yn_2:    $("input[name='d_yn_2']:checked").val(),
    d_name:    $("input[name='d_name']").val(),
    d_bigo:    $("input[name='d_bigo']").val()
  };
  var url = formData.idx
    ? '/line/productionManagement/noProduct/updateNoProduct'
    : '/line/productionManagement/noProduct/insertNoProduct';

  $.ajax({
    url: url, type:'POST', contentType:'application/json',
    data: JSON.stringify(formData),
    success: function(res){
      if(res.result==='success'){ alert('저장 완료되었습니다.'); userTable.replaceData(); hideModal('modalContainer'); }
      else { alert('저장 실패: '+res.message); }
    },
    error: function(){ alert('서버 통신 오류 발생'); }
  });
});

/* ─── 삭제 ─── */
document.querySelector('.delete-button').addEventListener('click', function(){
  var selectedRows = userTable.getSelectedData();
  if(!selectedRows.length){ alert('삭제할 항목을 선택하세요.'); return; }
  if(!confirm('정말 삭제하시겠습니까?')) return;
  var idxList = selectedRows.map(function(r){ return r.idx; });
  $.ajax({
    url:'/line/productionManagement/noProduct/deleteNoProduct',
    type:'POST', contentType:'application/json',
    data: JSON.stringify({idx:idxList}),
    success: function(res){
      if(res.result==='success'){ alert('삭제 완료되었습니다.'); userTable.replaceData(); }
      else { alert('삭제 실패: '+res.message); }
    },
    error: function(){ alert('서버 통신 오류 발생'); }
  });
});

/* ─── 엑셀 ─── */
$('.excel-button').on('click', function(){
  if(!userTable) return;
  userTable.download('xlsx','부적합품_현황.xlsx',{
    sheetName:'NoProduct',
    documentProcessing: function(wb){
      var sheet = wb.Sheets['NoProduct'];
      sheet['!cols'] = [
        {wch:14},{wch:18},{wch:20},{wch:28},{wch:18},{wch:14},{wch:14},
        {wch:35},{wch:35},{wch:12},{wch:12},{wch:14},{wch:30}
      ];
      return wb;
    }
  });
});

/* ─── 이벤트 바인딩 ─── */
$(function(){
  document.querySelector('.dayselect').value = todayMonth();
  getnoProductList();
  initPumbunTabu();

  // 추가 버튼
  document.querySelector('.insert-button').addEventListener('click', function(){
    document.getElementById('corrForm').reset();
    $("input[name='idx']").val('');
    $("input[name='d_date']").val(todayDate());
    showModal('modalContainer');
  });

  // 모달 닫기
  document.getElementById('mainClose').addEventListener('click', function(){ hideModal('modalContainer'); });
  document.getElementById('closeModal').addEventListener('click', function(){ hideModal('modalContainer'); });
  document.getElementById('modalContainer').addEventListener('click', function(e){ if(e.target===this) hideModal('modalContainer'); });

  // 품번 모달
  document.getElementById('btnPumbunOpen').addEventListener('click', function(){
    showModal('pumbunModal');
    if(pumbunTabu) pumbunTabu.replaceData();
  });
  document.getElementById('pumbunClose').addEventListener('click', function(){ hideModal('pumbunModal'); });
  document.getElementById('pumbunModal').addEventListener('click', function(e){ if(e.target===this) hideModal('pumbunModal'); });
});
</script>

</body>
</html>
