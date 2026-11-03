<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>열처리 작업이력</title>

  <%@include file="../include/pluginpage.jsp" %>
  <jsp:include page="../include/tabBar.jsp"/>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">

  <style>
    /* ── 기본 리셋 ── */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --bg:        #eaecf0;
      --surface:   #ffffff;
      --surface2:  #f4f5f7;
      --border:    #d0d4dc;
      --border-dk: #b0b6c2;
      --text-p:    #1a1e27;
      --text-s:    #4a5060;
      --text-m:    #8a919e;

      /* 포인트: 네이비/짙은 청색 — 공장/산업 현장의 신뢰감 */
      --navy:      #1e3a5f;
      --navy-md:   #2c5282;
      --navy-lt:   #ebf0f8;
      --accent:    #2b5ea7;

      /* 상태 색상 — 튀지 않게 */
      --green:     #2d6a4f;
      --green-lt:  #edf7f1;
      --red:       #9b2335;
      --red-lt:    #fdf1f2;
      --amber:     #7d5a1a;
      --amber-lt:  #fdf6e7;
      --slate:     #3d4a5c;

      --shadow-sm: 0 1px 4px rgba(0,0,0,.10);
      --shadow-md: 0 3px 12px rgba(0,0,0,.13);
      --shadow-lg: 0 8px 32px rgba(0,0,0,.18);

      --r:    6px;
      --r-lg: 8px;
      --ease: .13s ease;
    }

    body {
      font-family: 'Noto Sans KR', sans-serif;
      background: var(--bg);
      color: var(--text-p);
      font-size: 13px;
      line-height: 1.5;
      min-height: 100vh;
    }

    /* ─────────── TOPBAR ─────────── */
    .topbar {
      position: sticky; top: 0; z-index: 200;
      background: var(--navy);
      border-bottom: 2px solid var(--navy-md);
      box-shadow: 0 2px 8px rgba(0,0,0,.25);
    }
    .topbar-inner {
      max-width: 1820px; margin: 0 auto;
      height: 52px; padding: 0 20px;
      display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
    }

    .tb-title {
      font-size: 13px; font-weight: 800; letter-spacing: -.2px;
      color: #ffffff; white-space: nowrap;
      display: flex; align-items: center; gap: 8px; margin-right: 8px;
    }
    .tb-title-icon {
      width: 26px; height: 26px; border-radius: 4px;
      background: rgba(255,255,255,.15);
      border: 1px solid rgba(255,255,255,.25);
      display: flex; align-items: center; justify-content: center;
      font-size: 13px;
    }

    .tb-div { width:1px; height:18px; background:rgba(255,255,255,.2); flex-shrink:0; }

    .tb-label {
      font-size: 11px; font-weight: 700;
      color: rgba(255,255,255,.7); white-space: nowrap;
    }

    /* 날짜 입력 */
    .ctrl {
      height: 32px; padding: 0 10px;
      border: 1px solid rgba(255,255,255,.25);
      border-radius: var(--r);
      background: rgba(255,255,255,.12);
      color: #ffffff;
      font-size: 12px; font-family: inherit; font-weight: 600;
      outline: none; letter-spacing: .3px;
      transition: border-color var(--ease), background var(--ease);
    }
    .ctrl:focus { border-color: rgba(255,255,255,.6); background: rgba(255,255,255,.20); }
    .ctrl::placeholder { color: rgba(255,255,255,.4); font-weight: 400; }

    /* 버튼 */
    .btn {
      height: 32px; padding: 0 13px; border-radius: var(--r);
      font-size: 12px; font-weight: 700; font-family: inherit;
      display: inline-flex; align-items: center; gap: 5px;
      cursor: pointer; border: 1px solid transparent;
      transition: filter var(--ease), background var(--ease), box-shadow var(--ease);
      white-space: nowrap; user-select: none;
    }
    .btn:active  { filter: brightness(.92); }
    .btn:hover   { filter: brightness(1.08); }
    .btn img     { width: 14px; height: 14px; opacity: .9; }
    .btn svg     { width: 13px; height: 13px; flex-shrink: 0; }

    .btn-search { background: #3d6494;    color: #fff; border-color: #2e5280; }
    .btn-insert { background: #2d6a4f;    color: #fff; border-color: #235a40; }
    .btn-delete { background: rgba(255,255,255,.08); color: #ffb3ba; border-color: rgba(255,100,100,.35); }
    .btn-delete:hover { background: rgba(155,35,53,.35); }
    .btn-re     { background: #6b4e1a;    color: #fde8b0; border-color: #5a3f12; }
    .btn-pdf    { background: #4a3580;    color: #e0d4ff; border-color: #3a2a6a; }
    .btn-excel  { background: #1f5c3a;    color: #b8f0d0; border-color: #174d30; }

    /* 행수 배지 */
    .row-badge {
      display: inline-flex; align-items: center; gap: 5px;
      padding: 3px 10px; border-radius: 3px;
      background: rgba(255,255,255,.10);
      border: 1px solid rgba(255,255,255,.18);
      font-size: 11px; font-weight: 700;
      color: rgba(255,255,255,.75);
      font-variant-numeric: tabular-nums;
    }
    .badge-dot {
      width: 5px; height: 5px; border-radius: 50%;
      background: #7ecca0;
      animation: blink 2.5s infinite;
    }
    @keyframes blink { 0%,100%{opacity:1} 50%{opacity:.3} }

    /* ─────────── PAGE ─────────── */
    .page-wrap { max-width: 1820px; margin: 0 auto; padding: 16px 20px 28px; }

    /* ─────────── CARD ─────────── */
    .card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--r-lg);
      box-shadow: var(--shadow-sm);
      overflow: hidden;
    }
    .card-header {
      padding: 10px 16px;
      background: var(--surface2);
      border-bottom: 1px solid var(--border);
      display: flex; align-items: center; justify-content: space-between;
    }
    .card-title {
      font-size: 12px; font-weight: 800; color: var(--text-p);
      display: flex; align-items: center; gap: 7px;
    }
    .card-title::before {
      content:''; width: 3px; height: 13px; border-radius: 2px;
      background: var(--navy-md); display: inline-block;
    }
    .card-hint { font-size: 11px; color: var(--text-m); }

    /* ─────────── TABULATOR ─────────── */
    #dataTable { padding: 10px; }
    .tabulator { border: none !important; font-size: 13px !important; font-family: 'Noto Sans KR', sans-serif !important; }
    .tabulator .tabulator-header { background: #f0f2f6 !important; border-bottom: 2px solid #c8cdd8 !important; }
    .tabulator .tabulator-header .tabulator-col {
      background: #f0f2f6 !important;
      border-right: 1px solid #d8dce6 !important;
      color: var(--text-s) !important;
      font-size: 11px !important; font-weight: 800 !important;
    }
    .tabulator .tabulator-header .tabulator-col:last-child { border-right: none !important; }
    .tabulator-row { border-bottom: 1px solid #ebeef4 !important; }
    .tabulator-row:hover { background: #f5f7fb !important; }
    .tabulator-row.row_select {
      background: var(--navy-lt) !important;
      border-left: 3px solid var(--navy-md) !important;
    }
    .tabulator-cell { color: var(--text-p) !important; }
    .tabulator .tabulator-header-filter input {
      height: 25px !important; font-size: 12px !important; border-radius: 4px !important;
      border: 1px solid var(--border) !important; padding: 0 7px !important; background: #fff !important;
    }
    .tabulator .tabulator-header-filter input:focus {
      border-color: var(--navy-md) !important; outline: none !important;
    }

    /* LOT 태그 — 단정하게 */
    .tag-lot {
      display: inline-block; padding: 1px 8px; border-radius: 3px;
      font-size: 11px; font-weight: 700; letter-spacing: .3px;
      font-family: 'Courier New', monospace;
    }
    .tag-ci { background: #eaf0f9; color: var(--navy-md); border: 1px solid #c0d0e8; }
    .tag-ri { background: var(--amber-lt); color: var(--amber); border: 1px solid #e8d4a0; }

    /* ─────────── 모달 공통 ─────────── */
    .modal-ov {
      display: none; position: fixed; inset: 0;
      background: rgba(10,18,30,.60);
      z-index: 9000; align-items: center; justify-content: center; padding: 20px;
    }
    .modal-ov.show { display: flex; }

    .modal-box {
      background: var(--surface);
      border: 1px solid var(--border-dk);
      border-radius: var(--r-lg);
      box-shadow: var(--shadow-lg);
      padding: 0;
      position: relative; overflow: hidden;
      animation: slideIn .18s ease;
    }
    @keyframes slideIn { from{opacity:0;transform:translateY(12px)} to{opacity:1;transform:none} }

    /* 모달 상단 헤더 바 */
    .modal-titlebar {
      background: var(--navy);
      padding: 12px 48px 12px 18px;
      display: flex; align-items: center; gap: 10px;
    }
    .modal-titlebar-icon {
      width: 28px; height: 28px; border-radius: 4px;
      background: rgba(255,255,255,.15);
      border: 1px solid rgba(255,255,255,.2);
      display: flex; align-items: center; justify-content: center;
      font-size: 14px; flex-shrink: 0;
    }
    .modal-titlebar-text { flex: 1; }
    .modal-titlebar-title {
      font-size: 13px; font-weight: 800; color: #ffffff; letter-spacing: -.2px;
    }
    .modal-titlebar-sub { font-size: 10px; color: rgba(255,255,255,.55); margin-top: 1px; }
    .modal-titlebar.re-bar { background: #5a3f12; }

    .modal-body { padding: 20px 20px 18px; }

    /* 닫기 */
    .mclose {
      position: absolute; right: 12px; top: 10px;
      width: 28px; height: 28px; border-radius: 4px;
      border: 1px solid rgba(255,255,255,.2);
      background: rgba(255,255,255,.10);
      color: rgba(255,255,255,.8); cursor: pointer;
      font-size: 16px; font-weight: 700; line-height: 1;
      display: flex; align-items: center; justify-content: center;
      transition: background var(--ease), color var(--ease);
    }
    .mclose:hover { background: rgba(155,35,53,.5); color: #fff; }

    /* 폼 레이아웃 */
    .form-section { margin-bottom: 14px; }
    .sec-label {
      font-size: 10px; font-weight: 800; letter-spacing: .7px; text-transform: uppercase;
      color: var(--text-m); margin-bottom: 9px;
      display: flex; align-items: center; gap: 6px;
    }
    .sec-label::after { content:''; flex:1; height:1px; background:var(--border); }
    .sec-label.amber-sec { color: var(--amber); }
    .sec-label.amber-sec::after { background: linear-gradient(90deg, #e8d4a0, var(--border)); }

    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px 12px; }
    .form-group { display: flex; flex-direction: column; gap: 4px; }
    .form-group.full { grid-column: 1 / -1; }

    .f-label { font-size: 11px; font-weight: 700; color: var(--text-s); }
    .f-label .req  { color: var(--red); margin-left: 2px; }
    .f-label .hint { color: var(--accent); font-weight: 700; }


    .f-input {
      height: 36px; padding: 0 10px;
      border: 1px solid var(--border);
      border-radius: var(--r);
      background: var(--surface2);
      font-size: 12px; font-family: inherit; color: var(--text-p);
      outline: none;
      transition: border-color var(--ease), box-shadow var(--ease);
    }
    .f-input:focus { border-color: var(--navy-md); box-shadow: 0 0 0 2px rgba(44,82,130,.15); background: #fff; }
    .f-input::placeholder { color: var(--text-m); }
    .f-input[readonly] { background: #f0f2f5; color: var(--text-s); cursor: not-allowed; }

    /* 품번 클릭 */
    .f-input.clickable {
      cursor: pointer !important;
      border-color: #a0b8d8;
      background: #f0f5fb !important;
      color: var(--text-p) !important;
    }
    .f-input.clickable:hover {
      border-color: var(--navy-md);
      background: var(--navy-lt) !important;
    }

    /* 모달 버튼 */
    .modal-footer { display: flex; gap: 8px; padding-top: 0px; border-top: 1px solid var(--border); margin-top: 16px; }
    .modal-footer .mbtn { flex:1; height: 38px; justify-content: center; font-size: 12px; border-radius: var(--r); }
    .mbtn-save {
      background: var(--navy); color: #fff; border-color: #162e4d;
      box-shadow: 0 2px 6px rgba(30,58,95,.30);
    }
    .mbtn-save:hover { background: var(--navy-md); }
    .mbtn-save-re {
      background: #6b4e1a; color: #fde8b0; border-color: #5a3f12;
      box-shadow: 0 2px 6px rgba(107,78,26,.30);
    }
    .mbtn-cancel {
      background: var(--surface2); color: var(--text-s); border-color: var(--border);
    }
    .mbtn-cancel:hover { background: #e8eaef; }

    /* ─── 제품 선택 모달 ─── */
    #pcodeModal { z-index: 10000; align-items: flex-start; overflow-y: auto; }
    .pcode-box { width: 98vw; max-width: 1780px; margin: 20px auto; }
    .pcode-search {
      display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
      padding: 12px 0 13px; border-bottom: 1px solid var(--border); margin-bottom: 12px;
    }
    .pcode-search .ctrl-body {
      height: 32px; padding: 0 10px;
      border: 1px solid var(--border); border-radius: var(--r);
      background: var(--surface2); color: var(--text-p);
      font-size: 12px; font-family: inherit; outline: none; width: 190px;
    }
    .pcode-search .ctrl-body:focus { border-color: var(--navy-md); }
    .pcode-lbl { font-size: 11px; font-weight: 700; color: var(--text-s); white-space: nowrap; }

    /* pcodeTabu 탭 오버라이드 */
    #pcodeTabu .tabulator-row:hover { background: #f2f6fc !important; }
    #pcodeTabu .tabulator-row.row_select { background: var(--navy-lt) !important; border-left: 3px solid var(--navy-md) !important; }

    /* 엑셀 로딩 */
    #excelOverlay { display:none; position:fixed; inset:0; background:rgba(10,18,30,.50); z-index:19998; }
    #excelLoading {
      display:none; position:fixed; top:50%; left:50%; transform:translate(-50%,-50%);
      background:var(--surface); padding:26px 44px;
      border: 1px solid var(--border-dk); border-radius: var(--r-lg);
      box-shadow:var(--shadow-lg); font-size:13px; font-weight:700; color:var(--text-p);
      z-index:19999; text-align:center;
    }
    #excelLoading::before {
      content:''; display:block; margin:0 auto 12px; width:26px; height:26px;
      border:3px solid var(--border); border-top:3px solid var(--navy-md);
      border-radius:50%; animation:spin 1s linear infinite;
    }
    @keyframes spin { to{ transform:rotate(360deg); } }

    @media(max-width:960px){
      .topbar-inner { height:auto; padding:10px 16px; gap:7px; }
      .page-wrap    { padding:12px 14px 24px; }
      .form-grid    { grid-template-columns:1fr; }
    }
  </style>
</head>
<body>

<!-- ═══════════ TOPBAR ═══════════ -->
<div class="topbar">
  <div class="topbar-inner">

    <div class="tb-title">
      <span class="tb-title-icon">🔥</span>
      열처리 작업이력
    </div>
    <div class="tb-div"></div>

    <!-- ★ 날짜 단일→범위로 변경 -->
    <span class="tb-label">작업일자</span>
    <input type="text" class="ctrl dayselect daySet" id="w_date"
           style="width:130px;" placeholder="YYYY-MM-DD">
    <span class="tb-range">~</span>
    <input type="text" class="ctrl dayselect daySet" id="w_date_end"
           style="width:130px;" placeholder="YYYY-MM-DD">

    <div class="tb-div"></div>

    <button class="btn btn-search select-button">
      <img src="/line/css/tabBar/search-icon.png" alt="">조회
    </button>
    <button class="btn btn-insert insert-button">
      <img src="/line/css/tabBar/add-outline.png" alt="">추가
    </button>
    <button class="btn btn-delete delete-button">
      <img src="/line/css/tabBar/xDel3.png" alt="">삭제
    </button>

    <div class="tb-div"></div>

    <button class="btn btn-re re_re">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
           stroke-linecap="round" stroke-linejoin="round">
        <polyline points="1 4 1 10 7 10"/>
        <path d="M3.51 15a9 9 0 1 0 .49-3.51"/>
      </svg>재처리
    </button>

    <button class="btn btn-pdf" id="lot_pdf">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
           stroke-linecap="round" stroke-linejoin="round">
        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
        <polyline points="14 2 14 8 20 8"/>
        <line x1="12" y1="18" x2="12" y2="12"/>
        <line x1="9"  y1="15" x2="15" y2="15"/>
      </svg>작업지시 PDF
    </button>

    <button class="btn btn-excel excel-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
           stroke-linecap="round" stroke-linejoin="round">
        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
        <polyline points="14 2 14 8 20 8"/>
        <line x1="12" y1="12" x2="12" y2="18"/>
        <line x1="9"  y1="15" x2="15" y2="15"/>
      </svg>Download
    </button>

    <div style="margin-left:auto;">
      <span class="row-badge">
        <span class="badge-dot"></span>
        <span id="rowCount">0 rows</span>
      </span>
    </div>

  </div>
</div>

<!-- ═══════════ PAGE ═══════════ -->
<div class="page-wrap">
  <div class="card">
    <div class="card-header">
      <div class="card-title">작업 이력 목록</div>
      <div class="card-hint">행 클릭 → 선택 &nbsp;|&nbsp; 더블클릭 → 수정</div>
    </div>
    <div id="dataTable"></div>
  </div>
</div>

<!-- ═══════════ 작업 지시서 모달 ═══════════ -->
<div id="modalContainer" class="modal-ov">
  <div class="modal-box" id="mainModalBox" style="width:480px; max-width:95vw;">

    <button class="mclose close" type="button">&times;</button>

    <div class="modal-titlebar" id="mainTitleBar">
      <div class="modal-titlebar-icon" id="mainModalIcon">🔥</div>
      <div class="modal-titlebar-text">
        <div class="modal-titlebar-title" id="mainModalTitle">작업 지시서 등록</div>
        <div class="modal-titlebar-sub"   id="mainModalSub">신규 열처리 작업을 등록합니다</div>
      </div>
    </div>

    <div class="modal-body">
      <form id="corrForm" autocomplete="off">

        <div class="form-section">
          <div class="sec-label">기본 정보</div>
          <div class="form-grid">

            <div class="form-group">
              <label class="f-label">작업일 <span class="req">*</span></label>
              <input type="text" name="w_date" class="f-input daySet" placeholder="YYYY-MM-DD">
            </div>

            <div class="form-group">
              <label class="f-label">ERP 작지번호</label>
              <input type="text" name="erp_jack_no" class="f-input" placeholder="ERP 작지번호">
            </div>

            <div class="form-group full">
              <label class="f-label">품번 <span class="req">*</span>
                <span class="hint">&nbsp;▸ 클릭하여 선택</span>
              </label>
              <input type="text" name="w_pnum" class="f-input clickable"
                     readonly onclick="pcodeSelect();" placeholder="클릭하여 제품을 선택하세요">
            </div>

            <div class="form-group full">
              <label class="f-label">품명</label>
              <input type="text" name="w_pname" class="f-input" readonly
                     placeholder="품번 선택 시 자동 입력">
            </div>

            <div class="form-group full">
              <label class="f-label">투입계획통수</label>
              <input type="text" name="w_plan_cnt" class="f-input" placeholder="통 수 입력">
            </div>

          </div>
        </div>

        <div class="form-section" id="reSection" style="display:none;">
          <div class="sec-label amber-sec">재처리 정보</div>
          <div class="form-grid">
            <div class="form-group">
              <label class="f-label re_text">재처리 LOT (RI)</label>
              <input type="text" name="w_ci_lot" class="f-input" style="display:none;" placeholder="재처리 LOT">
            </div>
            <div class="form-group">
              <label class="f-label">원본 LOT (CI)</label>
              <input type="text" name="w_old_lot" class="f-input" style="display:none;" placeholder="원본 CI LOT" readonly>
            </div>
          </div>
        </div>

        <input type="text" name="w_rcode" style="display:none;">

        <div class="modal-footer">
          <button type="button" id="saveCorrStatus" class="btn mbtn-save modal-footer mbtn">저장</button>
          <button type="button" id="closeModal" class="btn mbtn-cancel modal-footer mbtn">닫기</button>
        </div>

      </form>
    </div>
  </div>
</div>

<!-- ═══════════ 제품 선택 모달 ═══════════ -->
<div id="pcodeModal" class="modal-ov" style="z-index:10000; align-items:flex-start; overflow-y:auto;">
  <div class="modal-box pcode-box">

    <button class="mclose closePcodeModal" type="button">&times;</button>

    <div class="modal-titlebar" style="background:#1a3a60;">
      <div class="modal-titlebar-icon">📋</div>
      <div class="modal-titlebar-text">
        <div class="modal-titlebar-title">제품 선택</div>
        <div class="modal-titlebar-sub">더블클릭하여 제품을 선택합니다</div>
      </div>
    </div>

    <div class="modal-body">
       <div class="pcode-search">
        <span class="pcode-lbl">거래처명</span>
        <input type="text" id="s_cname" class="ctrl-body pcodeModalEnter" placeholder="하단 검색 이용해 주세요" >
        <span class="pcode-lbl">품번</span>
        <input type="text" id="s_pnum"  class="ctrl-body pcodeModalEnter" placeholder="품번">
        <span class="pcode-lbl">품명</span>
        <input type="text" id="s_pname" class="ctrl-body pcodeModalEnter" placeholder="품명">
        <button type="button" class="btn btn-search" style="height:32px;" onclick="getPcodeData();">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
               stroke-linecap="round" stroke-linejoin="round" style="width:12px;height:12px;">
            <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
          </svg>조회
        </button> 
      </div>

      <div id="pcodeTabu"></div>

      <div style="display:flex; justify-content:flex-end; margin-top:12px;">
        <button type="button" class="btn mbtn-cancel closePcodeModal"
                style="height:34px; width:90px; justify-content:center; border:1px solid var(--border); background:var(--surface2); color:var(--text-s);">닫기</button>
      </div>
    </div>
  </div>
</div>

<a style="display:none;" id="downLoadLink" href="#" download="#"></a>
<div id="excelOverlay"></div>
<div id="excelLoading">엑셀 파일 생성 중...</div>

<script>
  let now_page_code = "c01";
  var heatListTable;
  var pcodeTabu;
  var selectedRowData = null;

  /* ── 초기 실행 ── */
  $(function () {
    // ★ 시작일 = 오늘, 종료일 = 오늘
    $('#w_date').val(todayDate());
    $('#w_date_end').val(todayDate());
    getHeatList();
    getHeatData();
  });

  /* 엔터 차단 */
  $(document).ready(function () {
    $('#corrForm').on('submit', function (e) { e.preventDefault(); e.stopPropagation(); return false; });
    $('#corrForm').on('keydown keypress', 'input', function (e) {
      if (e.which === 13) { e.preventDefault(); return false; }
    });
    $(document).on('keydown keypress', '#pcodeModal input', function (e) {
      if (e.which === 13) { e.preventDefault(); return false; }
    });
  });

  /* ── 모달 유틸 ── */
  function openMainModal() { $('#modalContainer').addClass('show'); }

  function resetModal() {
    $('#modalContainer').removeClass('show');
    $('#corrForm')[0].reset();
    $('#reSection').hide();
    $('input[name="w_ci_lot"]').hide();
    $('input[name="w_old_lot"]').hide();
    $('.re_text').hide();
    $('#mainTitleBar').removeClass('re-bar');
    $('#mainModalIcon').text('🔥');
    $('#mainModalTitle').text('작업 지시서 등록');
    $('#mainModalSub').text('신규 열처리 작업을 등록합니다');
    $('#saveCorrStatus').removeClass('mbtn-save-re').addClass('mbtn-save');
  }

  $(document).on('click', '.close, #closeModal', resetModal);

  $(document).on('click', '.closePcodeModal', function () { $('#pcodeModal').removeClass('show'); });
  $(document).on('click', '#pcodeModal', function (e) { if (e.target === this) $('#pcodeModal').removeClass('show'); });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') { $('#pcodeModal').removeClass('show'); resetModal(); }
  });

  /* ── ★ 조회: w_date + w_date_end 전송 ── */
  $('.select-button').on('click', getHeatData);

  /* ── 추가 ── */
  $('.insert-button').on('click', function () {
    selectedRowData = null;
    resetModal();
    $('input[name="w_date"]').val(todayDate());
    openMainModal();
  });

  /* ── 삭제 ── */
  $('.delete-button').on('click', function () {
    if (!selectedRowData) { alert('삭제할 행을 먼저 클릭해 주세요.'); return; }
    if (!confirm('선택된 항목을 정말 삭제하시겠습니까?')) return;
    $.ajax({
      url: '/line/productionManagement/heatTreatment/delete',
      type: 'POST', dataType: 'json',
      data: { w_lot: selectedRowData.w_ci_lot },
      success: function () { alert('삭제되었습니다.'); selectedRowData = null; getHeatData(); },
      error:   function () { alert('삭제 중 오류가 발생했습니다.'); getHeatData(); }
    });
  });

  /* ── 재처리 ── */
  $('.re_re').on('click', function () {
    if (!selectedRowData) { alert('재처리할 행을 먼저 클릭해주세요.'); return; }
    var d = selectedRowData;
    resetModal();
    $('#mainTitleBar').addClass('re-bar');
    $('#mainModalIcon').text('🔄');
    $('#mainModalTitle').text('재처리 등록');
    $('#mainModalSub').text('CI → RI 재처리 작업을 등록합니다');
    $('#saveCorrStatus').removeClass('mbtn-save').addClass('mbtn-save-re');
    $('#reSection').show();
    $('input[name="w_ci_lot"]').show();
    $('input[name="w_old_lot"]').show();
    $('.re_text').show();
    var riLot = (d.w_ci_lot || '').replace('CI', 'RI');
    $('input[name="w_date"]').val(d.w_date);
    $('input[name="w_pnum"]').val(d.item_no);
    $('input[name="w_pname"]').val(d.item_name);
    $('input[name="w_plan_cnt"]').val(d.w_plan_cnt);
    $('input[name="erp_jack_no"]').val(d.erp_jack_no);
    $('input[name="w_ci_lot"]').val(riLot);
    $('input[name="w_old_lot"]').val(d.w_ci_lot);
    $('input[name="w_rcode"]').val(d.w_rcode);
    openMainModal();
  });

  /* ── 저장 ── */
  $('#saveCorrStatus').on('click', function (e) {
    e.preventDefault();
    var formData = new FormData($('#corrForm')[0]);
    $.ajax({
      url: '/line/productionManagement/heatTreatment/save',
      type: 'POST', data: formData, processData: false, contentType: false,
      success: function () { alert('저장되었습니다!'); resetModal(); getHeatData(); selectedRowData = null; },
      error:   function () { alert('저장 중 오류가 발생했습니다.'); }
    });
  });

  /* ── PDF ── */
  $('#lot_pdf').on('click', function () {
    var selectedData = heatListTable.getSelectedData();
    if (!selectedData.length) { alert('선택된 데이터가 없습니다.'); return; }
    $.ajax({
      url: '/line/productionManagement/heatTreatment/workHeatListPrint',
      type: 'POST', contentType: 'application/json',
      data: JSON.stringify(selectedData),
      xhrFields: { responseType: 'blob' },
      success: function (blob) {
        selectedData.forEach(function (item) {
          var link = document.createElement('a');
          link.href = window.URL.createObjectURL(blob);
          link.download = (item.w_ci_lot || 'work') + '.pdf';
          document.body.appendChild(link); link.click();
          document.body.removeChild(link);
          window.URL.revokeObjectURL(link.href);
        });
      }
    });
  });

  /* ── 엑셀 ── */
  $('.excel-button').on('click', downloadExcel);
  function downloadExcel() {
    var tableData = heatListTable.getData();
    if (!tableData || !tableData.length) { alert('다운로드할 데이터가 없습니다.'); return; }
    $('#excelOverlay').show(); $('#excelLoading').show();
    try {
      var excelData = tableData.map(function (row, idx) {
        return {
          'NO': idx + 1,
          '작업일자': row.w_date || '', '작업LOT': row.w_ci_lot || '',
          'ERP작지번호': row.erp_jack_no || '', '재처리': row.w_old_lot || '',
          '회사명': row.cust_name || '', '품번': row.item_no || '',
          '품명': row.item_name || '', '바코드스캔시간': row.w_sdatetime || '',
          '투입시간': row.d370 || '', '투입종료시간': row.x111 || '',
          '계획통수(통)': row.w_plan_cnt || '', '기준장입량': row.charge_weight || '',
          '제품이미지1': row.img_url_1 || '', '제품이미지2': row.img_url_2 || '',
          '작업완료시간': row.l20 || ''
        };
      });
      var ws = XLSX.utils.json_to_sheet(excelData);
      ws['!cols'] = [
        {wch:5},{wch:12},{wch:18},{wch:18},{wch:18},{wch:15},
        {wch:25},{wch:30},{wch:20},{wch:20},{wch:20},{wch:15},
        {wch:15},{wch:25},{wch:25},{wch:20}
      ];
      var wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, '열처리 작업이력');
      var s = ($('#w_date').val() || '').replace(/-/g, '');
      var e = ($('#w_date_end').val() || '').replace(/-/g, '');
      var now = new Date();
      var ts = String(now.getHours()).padStart(2,'0') + String(now.getMinutes()).padStart(2,'0');
      XLSX.writeFile(wb, '열처리작업이력_' + s + '_' + e + '_' + ts + '.xlsx');
      setTimeout(function () { $('#excelOverlay').hide(); $('#excelLoading').hide(); }, 600);
    } catch (err) {
      console.error(err); alert('엑셀 다운로드에 실패했습니다.');
      $('#excelOverlay').hide(); $('#excelLoading').hide();
    }
  }

  /* ── LOT 포매터 ── */
  function lotFormatter(cell) {
    var v = cell.getValue() || '';
    if (!v) return '<span style="color:#aaa">-</span>';
    var isRI = v.indexOf('RI') !== -1;
    return '<span class="tag-lot ' + (isRI ? 'tag-ri' : 'tag-ci') + '">' + v + '</span>';
  }

  /* ── 메인 Tabulator ── */
  function getHeatList() {
    heatListTable = new Tabulator('#dataTable', {
      height: '700px',
      layout: 'fitDataFill',
      headerSort: false,
      reactiveData: true,
      columnHeaderVertAlign: 'middle',
      rowVertAlign: 'middle',
      headerHozAlign: 'center',
      renderHorizontal: 'virtual',
      selectable: true,
      selectableRangeMode: 'click',
      placeholder: '조회된 데이터가 없습니다.',
      columns: [
        { title:'작업일자',       field:'w_date',        width:120, hozAlign:'center' },
        { title:'작업LOT',        field:'w_ci_lot',      width:158, hozAlign:'center',
          headerFilter:'input', headerFilterPlaceholder:'LOT 검색', formatter:lotFormatter },
        { title:'ERP_작지번호',   field:'erp_jack_no',   width:150, hozAlign:'center',
          headerFilter:'input', headerFilterPlaceholder:'작지번호' },
        { title:'회사명',         field:'cust_name',     width:120, hozAlign:'center',
          headerFilter:'input', headerFilterPlaceholder:'회사명' },
        { title:'품번',           field:'item_no',       width:215, hozAlign:'left',
          headerFilter:'input', headerFilterPlaceholder:'품번 검색' },
        { title:'품명',           field:'item_name',     width:215, hozAlign:'left',
          headerFilter:'input', headerFilterPlaceholder:'품명 검색' },
        { title:'바코드 스캔 시간', field:'w_sdatetime', width:185, hozAlign:'center' },
        { title:'투입시간',       field:'d370',          width:185, hozAlign:'center' },
        { title:'투입종료시간',   field:'x111',          width:185, hozAlign:'center' },
        { title:'계획통수(통)',   field:'w_plan_cnt',    width:110, hozAlign:'center' },
        { title:'기준장입량',     field:'charge_weight', width:115, hozAlign:'center' },
        { title:'제품.PNG',       field:'img_url_1',     width:100, hozAlign:'center' },
        { title:'제품.PNG',       field:'img_url_2',     width:100, hozAlign:'center' },
        { title:'작업완료시간',   field:'l20',           width:185, hozAlign:'center' }
      ],
      rowClick: function (e, row) {
        $('#dataTable .tabulator-row').removeClass('row_select');
        row.getElement().classList.add('row_select');
        selectedRowData = row.getData();
      },
      rowDblClick: function (e, row) {
        var d = row.getData();
        selectedRowData = d;
        resetModal();
        $('input[name="w_date"]').val(d.w_date);
        $('input[name="w_pnum"]').val(d.item_no);
        $('input[name="w_pname"]').val(d.item_name);
        $('input[name="w_plan_cnt"]').val(d.w_plan_cnt);
        $('input[name="erp_jack_no"]').val(d.erp_jack_no);
        $('input[name="w_ci_lot"]').val(d.w_ci_lot);
        $('input[name="w_rcode"]').val(d.w_rcode);
        $('#mainModalTitle').text('작업 지시서 수정');
        $('#mainModalSub').text((d.item_name || '') + ' 작업을 수정합니다');
        openMainModal();
      }
    });
  }

  /* ── ★ 데이터 로드: w_date_end 추가 ── */
  function getHeatData() {
    $.ajax({
      url: '/line/productionManagement/heatTreatment/list',
      type: 'POST', dataType: 'json',
      data: {
        w_date:     $('#w_date').val(),       // 시작일
        w_date_end: $('#w_date_end').val()    // 종료일 ★
      },
      success: function (result) {
        var rows = result.data || [];
        heatListTable.setData(rows);
        $('#rowCount').text(rows.length + ' rows');
      }
    });
  }

  /* ── 제품 선택 ── */
  function pcodeSelect() {
    $('#pcodeModal').addClass('show');
    getPcodeList();
    getPcodeData();
  }

  function getPcodeData() {
    $.ajax({
      url: '/line/productionManagement/heatTreatment/pcode/list',
      type: 'POST', dataType: 'json',
      data: { w_cname: $('#s_cname').val(), w_pnum: $('#s_pnum').val(), w_pname: $('#s_pname').val() },
      success: function (result) { pcodeTabu.setData(result.data); }
    });
  }

  function getPcodeList() {
    pcodeTabu = new Tabulator('#pcodeTabu', {
      height: '500px',
      layout: 'fitDataFill',
      headerSort: false,
      reactiveData: true,
      columnHeaderVertAlign: 'middle',
      rowVertAlign: 'middle',
      headerHozAlign: 'center',
      placeholder: '조회된 데이터가 없습니다.',
      columns: [
        { title:'패턴ID',       field:'recipe_id',     width:100, hozAlign:'center' },
        { 
        	  title:'거래처명', 
        	  field:'cust_name', 
        	  width:130, 
        	  hozAlign:'center',
        	  headerFilter:"input",
        	  headerFilterPlaceholder:"검색",
        	  headerFilterFunc:"like"
        	},
        	{ 
        	  title:'품번', 
        	  field:'item_no', 
        	  width:215, 
        	  hozAlign:'left',
        	  headerFilter:"input",
        	  headerFilterPlaceholder:"검색",
        	  headerFilterFunc:"like"
        	},
        	{ 
        	  title:'품명', 
        	  field:'item_name', 
        	  width:240, 
        	  hozAlign:'left',
        	  headerFilter:"input",
        	  headerFilterPlaceholder:"검색",
        	  headerFilterFunc:"like"
        	},
        { title:'퀜칭1존(℃)', field:'q1_zone',       width:90,  hozAlign:'center' },
        { title:'퀜칭2존(℃)', field:'q2_zone',       width:90,  hozAlign:'center' },
        { title:'퀜칭3존(℃)', field:'q3_zone',       width:95,  hozAlign:'center' },
        { title:'퀜칭4존(℃)', field:'q4_zone',       width:95,  hozAlign:'center' },
        { title:'퀜칭5존(℃)', field:'q5_zone',       width:90,  hozAlign:'center' },
        { title:'퀜칭속도(Hz)',field:'q_speed',       width:95,  hozAlign:'center' },
        { title:'템퍼1존(℃)', field:'t1_zone',       width:90,  hozAlign:'center' },
        { title:'템퍼2존(℃)', field:'t2_zone',       width:90,  hozAlign:'center' },
        { title:'템퍼3존(℃)', field:'t3_zone',       width:90,  hozAlign:'center' },
        { title:'템퍼4존(℃)', field:'t4_zone',       width:90,  hozAlign:'center' },
        { title:'템퍼5존(℃)', field:'t5_zone',       width:90,  hozAlign:'center' },
        { title:'템퍼속도(Hz)',field:'t_speed',       width:100, hozAlign:'center' },
        { title:'CP(%)',        field:'cp',            width:78,  hozAlign:'center' },
        { title:'장입기준(kg)',field:'charge_weight', width:105, hozAlign:'center' },
        { title:'퀜칭요구경도',field:'quench_high',   width:105, hozAlign:'center' },
        { title:'레시피코드',  field:'recipe_code',   width:110, hozAlign:'center', visible:false }
      ],
      rowClick: function (e, row) {
        $('#pcodeTabu .tabulator-row').removeClass('row_select');
        row.getElement().classList.add('row_select');
      },
      rowDblClick: function (e, row) {
        var d = row.getData();
        $('input[name="w_rcode"]').val(d.recipe_code);
        $('input[name="w_pnum"]').val(d.item_no);
        $('input[name="w_pname"]').val(d.item_name);
        $('#pcodeModal').removeClass('show');
      }
    });
  }
</script>

</body>
</html>
