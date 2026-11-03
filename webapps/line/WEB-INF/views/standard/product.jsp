<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>제품 관리</title>

  <%@include file="../include/pluginpage.jsp" %>
  <jsp:include page="../include/tabBar.jsp"/>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">

  <style>
    /* ===================== Design System (알람/사용자/거래처 통일) ===================== */
    :root {
      --bg:           #f0f2f7;
      --surface:      #ffffff;
      --surface2:     #f7f8fc;
      --surface3:     #eef1f8;
      --border:       #e2e6ef;
      --border-focus: #2563eb;
      --text-p:       #0f172a;
      --text-s:       #64748b;
      --text-m:       #94a3b8;
      --accent:       #2563eb;
      --accent-dk:    #1d4ed8;
      --accent-lt:    #eff6ff;
      --green:        #16a34a;
      --green-lt:     #f0fdf4;
      --green-dk:     #15803d;
      --red:          #dc2626;
      --red-lt:       #fff5f5;
      --orange:       #ea580c;
      --orange-lt:    #ffedd5;
      --violet:       #7c3aed;
      --violet-lt:    #f5f3ff;
      --violet-dk:    #6d28d9;
      --shadow-xs:    0 1px 2px rgba(0,0,0,.04);
      --shadow-sm:    0 1px 4px rgba(0,0,0,.07);
      --shadow-md:    0 4px 20px rgba(0,0,0,.10);
      --shadow-lg:    0 18px 60px rgba(0,0,0,.20);
      --radius-sm:    8px;
      --radius:       12px;
      --radius-lg:    16px;
      --topbar-h:     56px;
      --transition:   .15s cubic-bezier(.4,0,.2,1);
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'Noto Sans KR', sans-serif;
      background: var(--bg);
      color: var(--text-p);
      min-height: 100vh;
    }

    /* ===================== TOPBAR ===================== */
    .topbar {
      position: sticky; top: 0; z-index: 200;
      background: rgba(255,255,255,.94);
      backdrop-filter: blur(14px);
      -webkit-backdrop-filter: blur(14px);
      border-bottom: 1px solid var(--border);
      box-shadow: var(--shadow-sm);
    }
    .topbar-inner {
      max-width: 1600px; margin: 0 auto;
      height: var(--topbar-h); padding: 0 20px;
      display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
    }
    .topbar-title {
      font-size: 14px; font-weight: 900; letter-spacing: -.4px;
      color: var(--text-p); display: flex; align-items: center; gap: 8px;
      white-space: nowrap; margin-right: 4px;
    }
    .topbar-title .icon-wrap {
      width: 28px; height: 28px; border-radius: 8px;
      background: linear-gradient(135deg, var(--violet), var(--violet-dk));
      display: flex; align-items: center; justify-content: center;
      font-size: 14px; box-shadow: 0 2px 8px rgba(124,58,237,.30);
    }
    .divider { width: 1px; height: 20px; background: var(--border); flex-shrink: 0; }
    .label {
      font-size: 11px; font-weight: 800; color: var(--text-s);
      white-space: nowrap; letter-spacing: .1px;
    }

    /* 입력 컨트롤 */
    .ctrl {
      height: 34px; padding: 0 11px;
      border: 1px solid var(--border); border-radius: var(--radius-sm);
      background: var(--surface2); color: var(--text-p);
      font-size: 13px; font-family: inherit; outline: none;
      transition: border-color var(--transition), box-shadow var(--transition), background var(--transition);
    }
    .ctrl:focus {
      border-color: var(--border-focus);
      box-shadow: 0 0 0 3px rgba(37,99,235,.13);
      background: #fff;
    }
    .ctrl::placeholder { color: var(--text-m); }

    /* 버튼 공통 */
    .btn {
      height: 34px; padding: 0 14px; border-radius: var(--radius-sm);
      font-size: 12px; font-weight: 900; font-family: inherit;
      display: inline-flex; align-items: center; gap: 6px;
      cursor: pointer; border: 1px solid transparent;
      transition: transform .08s, filter var(--transition), box-shadow var(--transition);
      white-space: nowrap; user-select: none; letter-spacing: -.1px;
    }
    .btn:active  { transform: translateY(1px); }
    .btn:hover   { filter: brightness(1.06); }
    .btn img     { width: 15px; height: 15px; opacity: .92; }
    .btn svg     { width: 14px; height: 14px; flex-shrink: 0; }

    .btn-search  { background: linear-gradient(135deg,#475569,#334155); color:#fff; border-color:#334155; box-shadow:0 1px 4px rgba(51,65,85,.20); }
    .btn-insert  { background: linear-gradient(135deg,#2563eb,#1d4ed8); color:#fff; border-color:#1d4ed8; box-shadow:0 1px 4px rgba(37,99,235,.25); }
    .btn-delete  { background: var(--surface); color: var(--red); border-color: var(--border); }
    .btn-delete:hover { background: var(--red-lt); }
    .btn-excel   { background: linear-gradient(135deg,#16a34a,#15803d); color:#fff; border-color:#15803d; box-shadow:0 1px 4px rgba(22,163,74,.25); }

    /* ===================== PAGE WRAP ===================== */
    .page-wrap {
      max-width: 1600px; margin: 0 auto;
      padding: 16px 20px 28px;
      display: flex; flex-direction: column; gap: 14px;
    }

    /* ===================== CARD ===================== */
    .card {
      background: var(--surface); border: 1px solid var(--border);
      border-radius: var(--radius); box-shadow: var(--shadow-sm); overflow: hidden;
    }
    .card-header {
      padding: 11px 16px; border-bottom: 1px solid var(--border);
      background: var(--surface2); display: flex;
      align-items: center; justify-content: space-between; gap: 10px;
    }
    .card-title {
      font-size: 12px; font-weight: 900; color: var(--text-p);
      letter-spacing: -.2px; display: flex; align-items: center; gap: 7px;
    }
    .card-title::before {
      content: ''; display: inline-block; width: 3px; height: 13px;
      border-radius: 3px; background: var(--violet);
    }
    .card-meta { font-size: 11px; color: var(--text-m); font-family: 'JetBrains Mono',monospace; font-weight: 500; }

    /* ===================== TABULATOR OVERRIDE ===================== */
    #dataList { padding: 10px; }
    .tabulator { border: none !important; font-size: 13px !important; font-family: 'Noto Sans KR',sans-serif !important; }
    .tabulator .tabulator-header { background: var(--surface2) !important; border-bottom: 1px solid var(--border) !important; }
    .tabulator .tabulator-header .tabulator-col {
      background: var(--surface2) !important; border-right: 1px solid var(--border) !important;
      color: var(--text-s) !important; font-size: 11px !important; font-weight: 800 !important;
    }
    .tabulator .tabulator-header .tabulator-col:last-child { border-right: none !important; }
    .tabulator-row { border-bottom: 1px solid #f1f4fa !important; transition: background var(--transition) !important; }
    .tabulator-row:hover { background: #f8f5ff !important; }
    .tabulator-row.row_select { background: var(--violet-lt) !important; border-left: 3px solid var(--violet) !important; }
    .tabulator-cell { color: var(--text-p) !important; }
    .tabulator .tabulator-header-filter input {
      height: 26px !important; font-size: 12px !important; border-radius: 6px !important;
      border: 1px solid var(--border) !important; padding: 0 8px !important; background: #fff !important;
    }
    .tabulator .tabulator-header-filter input:focus { border-color: var(--accent) !important; outline: none !important; }

    /* 이미지 썸네일 */
    .img-thumb {
      width: 36px; height: 36px; object-fit: cover;
      border-radius: 6px; border: 1px solid var(--border);
      cursor: pointer; transition: transform var(--transition), box-shadow var(--transition);
      display: block; margin: 0 auto;
    }
    .img-thumb:hover { transform: scale(1.08); box-shadow: var(--shadow-md); }
    .img-placeholder {
      width: 36px; height: 36px; border-radius: 6px;
      background: var(--surface2); border: 1px dashed var(--border);
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto; color: var(--text-m); font-size: 16px;
    }

    /* ===================== MODAL ===================== */
    .modal {
      display: none; position: fixed; inset: 0;
      background: rgba(15,23,42,.52);
      backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px);
      z-index: 9999; align-items: center; justify-content: center; padding: 18px;
    }
    .modal.show { display: flex; }
    .modal-content {
      width: 700px; max-width: 95vw; max-height: 92vh; overflow-y: auto;
      background: var(--surface); border: 1px solid var(--border);
      border-radius: var(--radius-lg); box-shadow: var(--shadow-lg);
      padding: 24px 22px 20px; position: relative;
      animation: pop .20s cubic-bezier(.34,1.36,.64,1);
    }
    @keyframes pop {
      from { opacity: 0; transform: translateY(14px) scale(.97); }
      to   { opacity: 1; transform: none; }
    }

    /* 모달 헤더 */
    .modal-header {
      display: flex; align-items: center; gap: 12px;
      margin-bottom: 18px; padding-bottom: 14px; border-bottom: 1px solid var(--border);
    }
    .modal-header-icon {
      width: 36px; height: 36px; border-radius: 10px;
      background: linear-gradient(135deg, var(--violet), var(--violet-dk));
      display: flex; align-items: center; justify-content: center;
      font-size: 17px; box-shadow: 0 2px 8px rgba(124,58,237,.28); flex-shrink: 0;
    }
    .modal-title-group { flex: 1; }
    .modal-title { font-size: 15px; font-weight: 900; color: var(--text-p); letter-spacing: -.3px; }
    .modal-subtitle { font-size: 11px; color: var(--text-m); font-family: 'JetBrains Mono',monospace; margin-top: 2px; }

    /* 닫기 버튼 */
    .close {
      position: absolute; right: 16px; top: 16px;
      width: 30px; height: 30px; border-radius: var(--radius-sm);
      border: 1px solid var(--border); background: var(--surface2);
      color: var(--text-s); cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      font-size: 17px; font-weight: 700;
      transition: background var(--transition), color var(--transition); line-height: 1;
    }
    .close:hover { background: var(--red-lt); color: var(--red); border-color: #fca5a5; }

    /* 폼 섹션 */
    .form-section { margin-bottom: 14px; }
    .form-section-title {
      font-size: 10px; font-weight: 900; color: var(--text-m);
      letter-spacing: .8px; text-transform: uppercase;
      margin-bottom: 10px; display: flex; align-items: center; gap: 6px;
    }
    .form-section-title::after { content:''; flex:1; height:1px; background:var(--border); }

    /* 폼 그리드 */
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px 12px; }
    .form-grid-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px 12px; }
    .form-group { display: flex; flex-direction: column; gap: 5px; }
    .form-group.full { grid-column: 1 / -1; }

    .form-label { font-size: 11px; font-weight: 800; color: var(--text-s); letter-spacing: .1px; }
    .form-label .required { color: var(--red); margin-left: 2px; }

    .form-input, .form-select {
      height: 38px; padding: 0 12px;
      border: 1px solid var(--border); border-radius: var(--radius-sm);
      background: var(--surface2); font-size: 13px;
      font-family: inherit; color: var(--text-p); outline: none;
      transition: border-color var(--transition), box-shadow var(--transition), background var(--transition);
    }
    .form-input:focus, .form-select:focus {
      border-color: var(--border-focus);
      box-shadow: 0 0 0 3px rgba(37,99,235,.12); background: #fff;
    }
    .form-input::placeholder { color: var(--text-m); font-size: 12px; }
    .form-input[readonly] {
      background: var(--surface3); color: var(--text-m); cursor: not-allowed;
    }

    /* 파일 업로드 */
    .file-group {
      display: flex; flex-direction: column; gap: 5px;
    }
    .file-label-row {
      display: flex; align-items: center; justify-content: space-between;
    }
    .file-input-wrap {
      position: relative; display: flex; align-items: center; gap: 8px;
    }
    .file-input-real { display: none; }
    .file-btn {
      height: 34px; padding: 0 12px;
      background: var(--surface2); border: 1px solid var(--border);
      border-radius: var(--radius-sm); font-size: 12px; font-weight: 700;
      color: var(--text-s); cursor: pointer; white-space: nowrap;
      transition: background var(--transition);
      display: flex; align-items: center; gap: 5px; font-family: inherit;
    }
    .file-btn:hover { background: var(--surface3); }
    .file-name-display {
      font-size: 12px; color: var(--text-m); font-family: 'JetBrains Mono',monospace;
      overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
      max-width: 180px;
    }

    /* 이미지 그리드 */
    .img-grid { display: grid; grid-template-columns: repeat(5,1fr); gap: 8px; }
    .img-slot {
      display: flex; flex-direction: column; gap: 4px; align-items: center;
    }
    .img-slot-label { font-size: 10px; font-weight: 700; color: var(--text-m); text-align: center; }
    .img-preview-box {
      width: 100%; aspect-ratio: 1;
      border: 1px dashed var(--border); border-radius: var(--radius-sm);
      background: var(--surface2); display: flex; align-items: center;
      justify-content: center; overflow: hidden; position: relative;
      cursor: pointer; transition: border-color var(--transition);
    }
    .img-preview-box:hover { border-color: var(--violet); }
    .img-preview-box img { width: 100%; height: 100%; object-fit: cover; }
    .img-preview-box .img-empty { font-size: 20px; color: var(--text-m); }
    .img-slot input[type="file"] { display: none; }
    .img-slot-name {
      font-size: 10px; color: var(--text-m); font-family: 'JetBrains Mono',monospace;
      text-align: center; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
      width: 100%;
    }

    /* 저장/닫기 버튼 */
    .modal-btns { display: flex; gap: 10px; margin-top: 18px; }
    .modal-btns .btn { flex: 1; height: 42px; justify-content: center; border-radius: var(--radius-sm); font-size: 13px; }
    .btn-save {
      background: linear-gradient(135deg, var(--violet), var(--violet-dk));
      color: #fff; border-color: var(--violet-dk);
      box-shadow: 0 2px 10px rgba(124,58,237,.28);
    }
    .btn-save:hover { box-shadow: 0 4px 16px rgba(124,58,237,.38); }
    .btn-close-modal { background: var(--surface2); color: var(--text-s); border-color: var(--border); }
    .btn-close-modal:hover { background: var(--surface3); }

    /* footer badge */
    .footer-badge {
      display: inline-flex; align-items: center; gap: 5px;
      padding: 3px 10px; border-radius: 20px;
      background: var(--surface2); border: 1px solid var(--border);
      font-size: 11px; font-family: 'JetBrains Mono',monospace;
      color: var(--text-s); font-weight: 600;
    }
    .footer-dot {
      width: 6px; height: 6px; border-radius: 50%;
      background: var(--violet); animation: pulse 2s infinite;
    }
    @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.35} }

    /* 이미지 미리보기 모달 */
    .img-preview-modal {
      display: none; position: fixed; inset: 0;
      background: rgba(0,0,0,.80); backdrop-filter: blur(8px);
      z-index: 10000; align-items: center; justify-content: center;
    }
    .img-preview-modal.show { display: flex; }
    .img-preview-modal img {
      max-width: 88vw; max-height: 88vh;
      border-radius: var(--radius); border: 2px solid rgba(255,255,255,.15);
      box-shadow: 0 24px 80px rgba(0,0,0,.5);
    }
    .img-preview-close {
      position: absolute; top: 20px; right: 24px;
      width: 36px; height: 36px; border-radius: 10px;
      background: rgba(255,255,255,.12); border: 1px solid rgba(255,255,255,.2);
      color: #fff; font-size: 20px; font-weight: 700;
      display: flex; align-items: center; justify-content: center;
      cursor: pointer; transition: background var(--transition);
    }
    .img-preview-close:hover { background: rgba(255,255,255,.22); }

    /* 엑셀 로딩 */
    #excelOverlay { display:none; position:fixed; inset:0; background:rgba(15,23,42,.45); z-index:9998; }
    #excelLoading {
      display:none; position:fixed; top:50%; left:50%;
      transform:translate(-50%,-50%);
      background:var(--surface); padding:28px 44px;
      border-radius:var(--radius); box-shadow:var(--shadow-lg);
      font-size:14px; font-weight:800; z-index:9999;
      text-align:center; color:var(--text-p);
    }
    #excelLoading::before {
      content:''; display:block; margin:0 auto 12px;
      width:28px; height:28px;
      border:3px solid var(--border); border-top:3px solid var(--violet);
      border-radius:50%; animation:spin 1s linear infinite;
    }
    @keyframes spin { to{transform:rotate(360deg)} }

    @media (max-width:900px){
      .topbar-inner { height:auto; padding:10px 14px; gap:8px; }
      .page-wrap    { padding:12px 14px 20px; }
      .form-grid, .form-grid-3 { grid-template-columns:1fr; }
      .img-grid { grid-template-columns:repeat(3,1fr); }
    }
  </style>
</head>

<body>

  <!-- ===================== TOPBAR ===================== -->
  <div class="topbar">
    <div class="topbar-inner">

      <div class="topbar-title">
        <span class="icon-wrap">📦</span>
        제품 관리
      </div>
      <div class="divider"></div>

      <span class="label">품번</span>
      <input type="text" id="search_item_no" class="ctrl" style="width:130px;" placeholder="품번 입력">

      <span class="label">품명</span>
      <input type="text" id="search_item_name" class="ctrl" style="width:160px;" placeholder="품명 입력">

      <span class="label">거래처명</span>
      <input type="text" id="search_cust_name" class="ctrl" style="width:140px;" placeholder="거래처명 입력">

      <div class="divider"></div>

      <button class="btn btn-search select-button">
        <img src="/line/css/tabBar/search-icon.png" alt="">조회
      </button>
      <button class="btn btn-insert insert-button">
        <img src="/line/css/tabBar/add-outline.png" alt="">추가
      </button>
      <button class="btn btn-delete delete-button">
        <img src="/line/css/tabBar/xDel3.png" alt="">삭제
      </button>
      <button class="btn btn-excel excel-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
          <polyline points="14 2 14 8 20 8"/>
          <line x1="12" y1="12" x2="12" y2="18"/>
          <line x1="9" y1="15" x2="15" y2="15"/>
        </svg>Download
      </button>

      <div style="margin-left:auto; display:flex; align-items:center;">
        <span class="footer-badge">
          <span class="footer-dot"></span>
          <span id="footer-info">0 rows</span>
        </span>
      </div>

    </div>
  </div>

  <!-- ===================== PAGE ===================== -->
  <div class="page-wrap">
    <div class="card">
      <div class="card-header">
        <div class="card-title">제품 목록</div>
        <div class="card-meta">Double Click → 수정 모드</div>
      </div>
      <div id="dataList"></div>
    </div>
  </div>

  <!-- ===================== MODAL ===================== -->
  <div id="modalContainer" class="modal">
    <div class="modal-content">
      <button class="close" type="button" aria-label="닫기">&times;</button>

      <div class="modal-header">
        <div class="modal-header-icon">📦</div>
        <div class="modal-title-group">
          <div class="modal-title" id="modalTitleText">제품 등록</div>
          <div class="modal-subtitle" id="modalSubtitle">신규 제품을 등록합니다</div>
        </div>
      </div>

      <form id="corrForm" method="post" enctype="multipart/form-data" autocomplete="off">
        <input type="hidden" name="prod_id">

        <!-- 기본 정보 -->
        <div class="form-section">
          <div class="form-section-title">기본 정보</div>
          <div class="form-grid">
            <div class="form-group">
              <label class="form-label">제품코드 <span style="color:var(--text-m);font-weight:500;">(자동생성)</span></label>
              <input type="text" id="prod_code" name="prod_code" class="form-input" placeholder="자동 생성" readonly>
            </div>
            <div class="form-group">
              <label class="form-label">거래처명 <span class="required">*</span></label>
              <select id="cust_name" name="cust_name" class="form-select">
                <option value="">선택하세요</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">거래처코드 <span style="color:var(--text-m);font-weight:500;">(자동생성)</span></label>
              <input type="text" id="cust_code" name="cust_code" class="form-input" placeholder="자동 생성" readonly>
            </div>
            <div class="form-group">
              <label class="form-label">품번 <span class="required">*</span></label>
              <input type="text" id="item_no" name="item_no" class="form-input" placeholder="예: ITEM001">
            </div>
            <div class="form-group full">
              <label class="form-label">품명 <span class="required">*</span></label>
              <input type="text" id="item_name" name="item_name" class="form-input" placeholder="제품명을 입력하세요">
            </div>
          </div>
        </div>

        <!-- 상세 스펙 -->
        <div class="form-section">
          <div class="form-section-title">상세 스펙</div>
          <div class="form-grid-3">
            <div class="form-group">
              <label class="form-label">규격</label>
              <input type="text" id="spec" name="spec" class="form-input" placeholder="규격">
            </div>
            <div class="form-group">
              <label class="form-label">재질</label>
              <input type="text" id="texture" name="texture" class="form-input" placeholder="재질">
            </div>
            <div class="form-group">
              <label class="form-label">장입량 (kg)</label>
              <input type="number" id="material" name="material" class="form-input" placeholder="0" value="0" min="0">
            </div>
            <div class="form-group">
              <label class="form-label">단가</label>
              <input type="number" id="unit_price" name="unit_price" class="form-input" placeholder="단가">
            </div>
            <div class="form-group">
              <label class="form-label">중량 (g)</label>
              <input type="number" id="weight" name="weight" class="form-input" placeholder="중량">
            </div>
          </div>
        </div>

        <!-- 경도 기준 -->
        <div class="form-section">
          <div class="form-section-title">경도 기준</div>
          <div class="form-grid">
            <div class="form-group">
              <label class="form-label">퀜칭 경도 하한</label>
              <input type="number" id="quench_low" name="quench_low" class="form-input" placeholder="예: 20" value="0">
            </div>
            <div class="form-group">
              <label class="form-label">퀜칭 경도 상한</label>
              <input type="number" id="quench_high" name="quench_high" class="form-input" placeholder="예: 30" value="0">
            </div>
            <div class="form-group">
              <label class="form-label">심부 경도 하한</label>
              <input type="number" id="temper_low" name="temper_low" class="form-input" placeholder="예: 15" value="0">
            </div>
            <div class="form-group">
              <label class="form-label">심부 경도 상한</label>
              <input type="number" id="temper_high" name="temper_high" class="form-input" placeholder="예: 25" value="0">
            </div>
          </div>
        </div>

        <!-- 이미지 -->
        <div class="form-section">
          <div class="form-section-title">이미지 등록 <span style="font-size:9px;color:var(--text-m);letter-spacing:.3px;text-transform:none;font-weight:600;">(클릭하여 선택)</span></div>
          <div class="img-grid">
            <!-- 슬롯 1 -->
            <div class="img-slot">
              <div class="img-slot-label">제품 사진 1</div>
              <div class="img-preview-box" onclick="document.getElementById('prod_img1').click()">
                <img id="preview1" src="" style="display:none;">
                <span class="img-empty" id="empty1">🖼</span>
              </div>
              <input type="file" id="prod_img1" name="prod_img1" accept="image/*">
              <input type="hidden" id="prod_img1_name" name="prod_img1_name">
              <div class="img-slot-name" id="name1">미선택</div>
            </div>
            <!-- 슬롯 2 -->
            <div class="img-slot">
              <div class="img-slot-label">제품 사진 2</div>
              <div class="img-preview-box" onclick="document.getElementById('prod_img2').click()">
                <img id="preview2" src="" style="display:none;">
                <span class="img-empty" id="empty2">🖼</span>
              </div>
              <input type="file" id="prod_img2" name="prod_img2" accept="image/*">
              <input type="hidden" id="prod_img2_name" name="prod_img2_name">
              <div class="img-slot-name" id="name2">미선택</div>
            </div>
            <!-- 슬롯 3 -->
            <div class="img-slot">
              <div class="img-slot-label">경도 사진 3</div>
              <div class="img-preview-box" onclick="document.getElementById('prod_img3').click()">
                <img id="preview3" src="" style="display:none;">
                <span class="img-empty" id="empty3">🖼</span>
              </div>
              <input type="file" id="prod_img3" name="prod_img3" accept="image/*">
              <input type="hidden" id="prod_img3_name" name="prod_img3_name">
              <div class="img-slot-name" id="name3">미선택</div>
            </div>
            <!-- 슬롯 4 -->
            <div class="img-slot">
              <div class="img-slot-label">경도 사진 4</div>
              <div class="img-preview-box" onclick="document.getElementById('prod_img4').click()">
                <img id="preview4" src="" style="display:none;">
                <span class="img-empty" id="empty4">🖼</span>
              </div>
              <input type="file" id="prod_img4" name="prod_img4" accept="image/*">
              <input type="hidden" id="prod_img4_name" name="prod_img4_name">
              <div class="img-slot-name" id="name4">미선택</div>
            </div>
            <!-- 슬롯 5 -->
            <div class="img-slot">
              <div class="img-slot-label">경도 사진 5</div>
              <div class="img-preview-box" onclick="document.getElementById('prod_img5').click()">
                <img id="preview5" src="" style="display:none;">
                <span class="img-empty" id="empty5">🖼</span>
              </div>
              <input type="file" id="prod_img5" name="prod_img5" accept="image/*">
              <input type="hidden" id="prod_img5_name" name="prod_img5_name">
              <div class="img-slot-name" id="name5">미선택</div>
            </div>
          </div>
        </div>

        <div class="modal-btns">
          <button type="submit" id="saveCorrStatus" class="btn btn-save">저장</button>
          <button type="button" id="closeModal" class="btn btn-close-modal">닫기</button>
        </div>
      </form>
    </div>
  </div>

  <!-- 이미지 미리보기 모달 -->
  <div id="imagePreviewModal" class="img-preview-modal">
    <button class="img-preview-close" id="closePreview">&times;</button>
    <img id="previewImg" src="" alt="미리보기">
  </div>

  <!-- 엑셀 로딩 -->
  <div id="excelOverlay"></div>
  <div id="excelLoading">엑셀 생성 중...</div>

  <!-- ===================== SCRIPT ===================== -->
  <script>
  let now_page_code = "a03";
  let dataTable;
  let selectedRow = null;

  // =========================
  // Helpers
  // =========================
  function isBlank(v){
    return v === null || v === undefined || String(v).trim() === "";
  }

  function toNumOrZero(v){
    if (v === null || v === undefined) return "0";
    const s = String(v).trim();
    if (s === "") return "0";
    const n = Number(s);
    return Number.isFinite(n) ? String(n) : "0";
  }

  function fixNumberEmptyToZero($form){
    const fields = ["unit_price", "weight"];
    fields.forEach(name => {
      const $el = $form.find(`[name="${name}"]`);
      if ($el.length) $el.val(toNumOrZero($el.val()));
    });
  }

  // DB에 파일명만 저장된 경우 이미지 조회 URL로 변환
  function buildImgSrc(v){
    if (isBlank(v)) return "";
    const s = String(v).trim();

    if (s.startsWith("http://") || s.startsWith("https://")) return s;
    if (s.startsWith("/line/standard/product/image?filename=")) return s;

    // /uploads/xxx 같은 절대경로면 그대로
    if (s.startsWith("/")) return s;

    return "/line/standard/product/image?filename=" + encodeURIComponent(s);
  }

  function fileNameFromValue(v){
    if (isBlank(v)) return "";
    const s = String(v);
    return s.split("/").pop().split("\\").pop();
  }

  // =========================
  // Image preview UI
  // =========================
  function setSlotUI(n, src, displayName){
    const preview = document.getElementById("preview" + n);
    const empty   = document.getElementById("empty" + n);
    const nameEl  = document.getElementById("name" + n);

    if (preview && empty){
      if (src){
        preview.src = src;
        preview.style.display = "block";
        empty.style.display = "none";
      } else {
        preview.src = "";
        preview.style.display = "none";
        empty.style.display = "";
      }
    }

    if (nameEl){
      if (isBlank(displayName)){
        nameEl.textContent = "미선택";
      } else {
        nameEl.textContent = displayName.length > 14 ? displayName.substring(0, 14) + "..." : displayName;
      }
    }
  }

  function clearSlot(n){
    const fileInput = document.getElementById("prod_img" + n);
    const hiddenOld = document.getElementById("prod_img" + n + "_name");

    if (fileInput){
      fileInput.value = "";
      fileInput.dataset.old = "";
      fileInput.dataset.changed = "N";
    }
    if (hiddenOld) hiddenOld.value = "";

    setSlotUI(n, "", "");
  }

  function applyOldToSlot(n, oldValue){
    const fileInput = document.getElementById("prod_img" + n);
    const hiddenOld = document.getElementById("prod_img" + n + "_name");

    const old = oldValue || "";

    if (fileInput){
      fileInput.value = "";
      fileInput.dataset.old = old;
      fileInput.dataset.changed = "N";
    }
    if (hiddenOld) hiddenOld.value = old;

    const src = buildImgSrc(old);
    const nm  = fileNameFromValue(old);

    setSlotUI(n, src, nm);
  }

  function bindFileChange(n){
    const fileInput = document.getElementById("prod_img" + n);
    if (!fileInput) return;

    fileInput.addEventListener("change", function(){
      const file = this.files && this.files[0];
      const hiddenOld = document.getElementById("prod_img" + n + "_name");

      if (file && file.size > 0 && file.name){
        this.dataset.changed = "Y";

        // 기존값(hidden)은 유지해야 서버에서 파일 없을 때 fallback 가능
        if (hiddenOld && isBlank(hiddenOld.value) && !isBlank(this.dataset.old)){
          hiddenOld.value = this.dataset.old;
        }

        const reader = new FileReader();
        reader.onload = function(e){
          setSlotUI(n, e.target.result, file.name);
        };
        reader.readAsDataURL(file);
      } else {
        this.dataset.changed = "N";
        const old = this.dataset.old || (hiddenOld ? hiddenOld.value : "");
        applyOldToSlot(n, old);
      }
    });
  }

  // =========================
  // Preview modal
  // =========================
  function previewImage(url){
    if (isBlank(url)) return;
    document.getElementById("previewImg").src = url;
    document.getElementById("imagePreviewModal").classList.add("show");
  }

  document.getElementById("closePreview").addEventListener("click", function(){
    document.getElementById("imagePreviewModal").classList.remove("show");
  });

  document.getElementById("imagePreviewModal").addEventListener("click", function(e){
    if (e.target === this) this.classList.remove("show");
  });

  function bindSlotClick(n){
    const box = document.querySelectorAll(".img-preview-box")[n - 1];
    if (!box) return;

    box.addEventListener("dblclick", function(){
      const img = document.getElementById("preview" + n);
      if (img && img.src) previewImage(img.src);
    });
  }

  // =========================
  // Multipart sanitize
  // =========================
  function sanitizeMultipart(fd){
    [1,2,3,4,5].forEach(n => {
      const key = "prod_img" + n;
      const f = fd.get(key);

      if (f instanceof File){
        if (!f.name || f.size === 0){
          fd.delete(key);
        }
      } else if (f == null){
        // nothing
      } else {
        fd.delete(key);
      }
    });
  }

  // FormData 만들기 전에 hidden old값 보정
  function syncOldImageHiddenValuesBeforeSubmit(){
    [1,2,3,4,5].forEach(n => {
      const fileInput = document.getElementById("prod_img" + n);
      const hiddenOld = document.getElementById("prod_img" + n + "_name");

      if (!fileInput || !hiddenOld) return;

      // 파일 선택 안 했으면 기존값 유지
      if (!(fileInput.files && fileInput.files[0] && fileInput.files[0].size > 0)){
        if (isBlank(hiddenOld.value) && !isBlank(fileInput.dataset.old)){
          hiddenOld.value = fileInput.dataset.old;
        }
      }
    });
  }

  // =========================
  // Modal
  // =========================
  function openModal(){
    $("#modalContainer").addClass("show");
  }

  function closeModal(){
    $("#modalContainer").removeClass("show");
  }

  function setModalMode(mode, name){
    if (mode === "edit"){
      $("#modalTitleText").text("제품 수정");
      $("#modalSubtitle").text((name || "") + " 정보를 수정합니다");
    } else {
      $("#modalTitleText").text("제품 등록");
      $("#modalSubtitle").text("신규 제품을 등록합니다");
    }
  }

  function resetModalForInsert(){
    const $f = $("#corrForm");
    $f[0].reset();
    $f.find('[name="prod_id"]').val("");
    $f.find('[name="prod_code"]').val("");
    $f.find('[name="cust_code"]').val("");

    [1,2,3,4,5].forEach(clearSlot);
  }

  function fillModalForEdit(d){
    const $f = $("#corrForm");
    $f[0].reset();

    $f.find('[name="prod_id"]').val(d.prod_id || "");
    $f.find('[name="prod_code"]').val(d.prod_code || "");
    $f.find('[name="item_no"]').val(d.item_no || "");
    $f.find('[name="item_name"]').val(d.item_name || "");
    $f.find('[name="spec"]').val(d.spec || "");
    $f.find('[name="texture"]').val(d.texture || "");
    $f.find('[name="material"]').val(d.material || "0");
    $f.find('[name="unit_price"]').val(toNumOrZero(d.unit_price));
    $f.find('[name="weight"]').val(toNumOrZero(d.weight));
    $f.find('[name="quench_low"]').val(d.quench_low || "0");
    $f.find('[name="quench_high"]').val(d.quench_high || "0");
    $f.find('[name="temper_low"]').val(d.temper_low || "0");
    $f.find('[name="temper_high"]').val(d.temper_high || "0");
    $f.find('[name="cust_code"]').val(d.cust_code || "");

    // ✅ 여기서 미리보기까지 반드시 세팅
    [1,2,3,4,5].forEach(function(n){
      applyOldToSlot(n, d["img_url_" + n] || "");
    });
  }

  // =========================
  // Tabulator
  // =========================
  function imgFormatter(cell){
    const v = cell.getValue();
    if (isBlank(v)) return '<div class="img-placeholder">📷</div>';

    const src = buildImgSrc(v);
    return '<img class="img-thumb" src="' + src + '" onclick="previewImage(\'' + src.replace(/'/g, "\\'") + '\')">';
  }

  function initDataTable(){
    dataTable = new Tabulator("#dataList", {
      height: "700px",
      layout: "fitColumns",
      selectable: 1,
      placeholder: "조회된 데이터가 없습니다.",
      headerHozAlign: "center",
      columns: [
        { title:"NO", formatter:"rownum", width:60, hozAlign:"center" },
        { title:"제품ID", field:"prod_id", width:80, hozAlign:"center", headerFilter:"input" },
        { title:"제품코드", field:"prod_code", width:120, hozAlign:"center", headerFilter:"input" },
        { title:"거래처코드", field:"cust_code", width:120, hozAlign:"center", headerFilter:"input" },
        { title:"거래처명", field:"cust_name", width:130, hozAlign:"center", headerFilter:"input" },
        { title:"품번", field:"item_no", width:230, hozAlign:"left", headerFilter:"input" },
        { title:"품명", field:"item_name", width:260, hozAlign:"left", headerFilter:"input" },

        { title:"제품 이미지1", field:"img_url_1", width:90, hozAlign:"center", headerSort:false, formatter:imgFormatter },
        { title:"제품 이미지2", field:"img_url_2", width:90, hozAlign:"center", headerSort:false, formatter:imgFormatter },

        { title:"규격", field:"spec", width:140, hozAlign:"left", headerFilter:"input" },
        { title:"재질", field:"texture", width:120, hozAlign:"left", headerFilter:"input" },
        { title:"장입량(kg)", field:"material", width:100, hozAlign:"center", headerFilter:"input" },

        {
          title:"단가",
          field:"unit_price",
          width:100,
          hozAlign:"right",
          headerFilter:"input",
          formatter:"money",
          formatterParams:{ symbol:"원", symbolAfter:true, precision:0, thousand:"," }
        },

        { title:"중량(g)", field:"weight", width:100, hozAlign:"right", headerFilter:"input" },
        { title:"퀜칭 하한", field:"quench_low", width:100, hozAlign:"center", headerFilter:"input" },
        { title:"퀜칭 상한", field:"quench_high", width:100, hozAlign:"center", headerFilter:"input" },
        { title:"심부 하한", field:"temper_low", width:100, hozAlign:"center", headerFilter:"input" },
        { title:"심부 상한", field:"temper_high", width:100, hozAlign:"center", headerFilter:"input" },
        { title:"등록일", field:"reg_date", width:160, hozAlign:"center", headerFilter:"input" },

        { title:"사진3", field:"img_url_3", width:80, hozAlign:"center", headerSort:false, formatter:imgFormatter },
        { title:"사진4", field:"img_url_4", width:80, hozAlign:"center", headerSort:false, formatter:imgFormatter },
        { title:"사진5", field:"img_url_5", width:80, hozAlign:"center", headerSort:false, formatter:imgFormatter }
      ],
      rowClick: function(e, row){
        $("#dataList .tabulator-row").removeClass("row_select");
        row.getElement().classList.add("row_select");
        selectedRow = row;
      },
      rowDblClick: function(e, row){
        const d = row.getData();
        selectedRow = row;

        setModalMode("edit", d.item_name);
        fillModalForEdit(d);
        loadCustomerList(d.cust_code, function(){
          openModal();
        });
      }
    });
  }

  // =========================
  // Ajax
  // =========================
  function loadData(){
    $.ajax({
      url: "/line/standard/product/list",
      type: "POST",
      dataType: "json",
      data: {
        item_no: $("#search_item_no").val(),
        item_name: $("#search_item_name").val(),
        cust_name: $("#search_cust_name").val()
      },
      success: function(res){
        if (res.status === "success"){
          const pure = JSON.parse(JSON.stringify(res.data));
          dataTable.replaceData(pure);
          $("#footer-info").text((pure.length || 0) + " rows");
        }
      },
      error: function(){
        alert("데이터 조회 실패");
      }
    });
  }

  function loadCustomerList(selectedCode, callback){
    $.ajax({
      url: "/line/standard/customer/list",
      type: "POST",
      dataType: "json",
      success: function(resp){
        if (resp.status === "success"){
          const sel = $("#cust_name");
          sel.empty().append('<option value="">선택하세요</option>');

          resp.data.forEach(function(c){
            const code = c.cust_code || "";
            const name = c.cust_name || "";
            const opt = $("<option></option>").val(code).text(name);
            if (code === (selectedCode || "")) opt.prop("selected", true);
            sel.append(opt);
          });

          if (selectedCode) $("#cust_code").val(selectedCode);
          if (typeof callback === "function") callback();
        } else {
          alert("거래처 조회 실패: " + (resp.message || ""));
        }
      },
      error: function(){
        alert("거래처 조회 실패");
      }
    });
  }

  // =========================
  // Excel
  // =========================
  function downloadExcel(){
    const tableData = dataTable.getData();
    if (!tableData || !tableData.length){
      alert("다운로드할 데이터가 없습니다.");
      return;
    }

    $("#excelOverlay").show();
    $("#excelLoading").show();

    try{
      const excelData = tableData.map(function(row, idx){
        return {
          "NO": idx + 1,
          "제품코드": row.prod_code || "",
          "거래처코드": row.cust_code || "",
          "거래처명": row.cust_name || "",
          "품번": row.item_no || "",
          "품명": row.item_name || "",
          "제품이미지1": row.img_url_1 || "",
          "제품이미지2": row.img_url_2 || "",
          "규격": row.spec || "",
          "재질": row.texture || "",
          "장입량(kg)": row.material || "",
          "단가": row.unit_price || "",
          "중량(g)": row.weight || "",
          "퀜칭경도_하한": row.quench_low || "",
          "퀜칭경도_상한": row.quench_high || "",
          "심부경도_하한": row.temper_low || "",
          "심부경도_상한": row.temper_high || "",
          "등록일": row.reg_date || ""
        };
      });

      const ws = XLSX.utils.json_to_sheet(excelData);
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "제품목록");

      const now = new Date();
      const ds = now.getFullYear() +
        String(now.getMonth() + 1).padStart(2, "0") +
        String(now.getDate()).padStart(2, "0");
      const ts = String(now.getHours()).padStart(2, "0") +
        String(now.getMinutes()).padStart(2, "0");

      XLSX.writeFile(wb, "제품리스트_" + ds + "_" + ts + ".xlsx");

      setTimeout(function(){
        $("#excelOverlay").hide();
        $("#excelLoading").hide();
      }, 400);
    } catch(e){
      console.error(e);
      alert("엑셀 다운로드에 실패했습니다.");
      $("#excelOverlay").hide();
      $("#excelLoading").hide();
    }
  }

  // =========================
  // Ready
  // =========================
  $(document).ready(function(){
    [1,2,3,4,5].forEach(bindFileChange);
    [1,2,3,4,5].forEach(bindSlotClick);

    initDataTable();
    loadData();
    loadCustomerList();

    $(".select-button").on("click", loadData);
    $(".excel-button").on("click", downloadExcel);

    $(".insert-button").on("click", function(){
      selectedRow = null;
      setModalMode("insert");
      resetModalForInsert();
      loadCustomerList();
      openModal();
    });

    $(".delete-button").on("click", function(){
      if (!selectedRow){
        alert("삭제할 행을 먼저 클릭해 주세요.");
        return;
      }

      const prodId = selectedRow.getData().prod_id;
      if (!prodId){
        alert("삭제할 제품이 없습니다.");
        return;
      }

      if (!confirm("선택된 제품을 정말 삭제하시겠습니까?")) return;

      $.ajax({
        url: "/line/standard/product/delete",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({ prod_id: prodId }),
        dataType: "json",
        success: function(){
          alert("제품 정보가 삭제되었습니다!");
          selectedRow = null;
          loadData();
        },
        error: function(){
          alert("삭제 실패");
        }
      });
    });

    $(".close, #closeModal").on("click", closeModal);

    document.addEventListener("keydown", function(e){
      if (e.key === "Escape") closeModal();
    });

    $("#cust_name").on("change", function(){
      $("#cust_code").val($(this).val());
    });

    $("#saveCorrStatus").off("click").on("click", function(e){
    	  e.preventDefault();

    	  const $form = $("#corrForm");
    	  fixNumberEmptyToZero($form);
    	  syncOldImageHiddenValuesBeforeSubmit();

    	  const prodId = $form.find('[name="prod_id"]').val();
    	  const url = prodId ? "/line/standard/product/update" : "/line/standard/product/save";

    	  const fd = new FormData($form[0]);

    	  if (!prodId) {
    	    fd.delete("prod_id");
    	  }

    	  sanitizeMultipart(fd);

    	  $.ajax({
    	    url: url,
    	    type: "POST",
    	    data: fd,
    	    processData: false,
    	    contentType: false,
    	    dataType: "json",
    	    success: function(res){
    	      alert("제품 정보가 성공적으로 저장되었습니다!");
    	      closeModal();
    	      loadData();
    	    },
    	    error: function(xhr){
    	      console.log("status", xhr.status);
    	      console.log("responseText", xhr.responseText);
    	      alert("저장 실패");
    	    }
    	  });
    	});
  });
</script>
</body>
</html>
