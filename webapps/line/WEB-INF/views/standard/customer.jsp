<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>거래처 관리</title>

  <%@include file="../include/pluginpage.jsp" %>
  <jsp:include page="../include/tabBar.jsp"/>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">

  <style>
    /* ===================== Design System (알람/사용자 통일) ===================== */
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
      position: sticky;
      top: 0;
      z-index: 200;
      background: rgba(255,255,255,.94);
      backdrop-filter: blur(14px);
      -webkit-backdrop-filter: blur(14px);
      border-bottom: 1px solid var(--border);
      box-shadow: var(--shadow-sm);
    }
    .topbar-inner {
      max-width: 1600px;
      margin: 0 auto;
      height: var(--topbar-h);
      padding: 0 20px;
      display: flex;
      align-items: center;
      gap: 10px;
      flex-wrap: wrap;
    }

    .topbar-title {
      font-size: 14px;
      font-weight: 900;
      letter-spacing: -.4px;
      color: var(--text-p);
      display: flex;
      align-items: center;
      gap: 8px;
      white-space: nowrap;
      margin-right: 4px;
    }
    .topbar-title .icon-wrap {
      width: 28px;
      height: 28px;
      border-radius: 8px;
      background: linear-gradient(135deg, #16a34a, #15803d);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 14px;
      box-shadow: 0 2px 8px rgba(22,163,74,.30);
    }

    .divider { width: 1px; height: 20px; background: var(--border); flex-shrink: 0; }

    .label {
      font-size: 11px;
      font-weight: 800;
      color: var(--text-s);
      white-space: nowrap;
      letter-spacing: .1px;
    }

    /* 입력 컨트롤 */
    .ctrl {
      height: 34px;
      padding: 0 11px;
      border: 1px solid var(--border);
      border-radius: var(--radius-sm);
      background: var(--surface2);
      color: var(--text-p);
      font-size: 13px;
      font-family: inherit;
      outline: none;
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
      height: 34px;
      padding: 0 14px;
      border-radius: var(--radius-sm);
      font-size: 12px;
      font-weight: 900;
      font-family: inherit;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      cursor: pointer;
      border: 1px solid transparent;
      transition: transform .08s, filter var(--transition), box-shadow var(--transition);
      white-space: nowrap;
      user-select: none;
      letter-spacing: -.1px;
    }
    .btn:active  { transform: translateY(1px); }
    .btn:hover   { filter: brightness(1.06); }
    .btn img     { width: 15px; height: 15px; opacity: .92; }
    .btn svg     { width: 14px; height: 14px; flex-shrink: 0; }

    .btn-search {
      background: linear-gradient(135deg, #475569, #334155);
      color: #fff;
      border-color: #334155;
      box-shadow: 0 1px 4px rgba(51,65,85,.20);
    }
    .btn-insert {
      background: linear-gradient(135deg, #2563eb, #1d4ed8);
      color: #fff;
      border-color: #1d4ed8;
      box-shadow: 0 1px 4px rgba(37,99,235,.25);
    }
    .btn-delete {
      background: var(--surface);
      color: var(--red);
      border-color: var(--border);
    }
    .btn-delete:hover { background: var(--red-lt); }

    .btn-excel {
      background: linear-gradient(135deg, #16a34a, #15803d);
      color: #fff;
      border-color: #15803d;
      box-shadow: 0 1px 4px rgba(22,163,74,.25);
    }

    /* ===================== PAGE WRAP ===================== */
    .page-wrap {
      max-width: 1600px;
      margin: 0 auto;
      padding: 16px 20px 28px;
      display: flex;
      flex-direction: column;
      gap: 14px;
    }

    /* ===================== CARD ===================== */
    .card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      box-shadow: var(--shadow-sm);
      overflow: hidden;
    }
    .card-header {
      padding: 11px 16px;
      border-bottom: 1px solid var(--border);
      background: var(--surface2);
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }
    .card-title {
      font-size: 12px;
      font-weight: 900;
      color: var(--text-p);
      letter-spacing: -.2px;
      display: flex;
      align-items: center;
      gap: 7px;
    }
    .card-title::before {
      content: '';
      display: inline-block;
      width: 3px;
      height: 13px;
      border-radius: 3px;
      background: var(--green);
    }
    .card-meta {
      font-size: 11px;
      color: var(--text-m);
      font-family: 'JetBrains Mono', monospace;
      font-weight: 500;
    }

    /* ===================== TABULATOR OVERRIDE ===================== */
    #dataList { padding: 10px; }

    .tabulator {
      border: none !important;
      font-size: 13px !important;
      font-family: 'Noto Sans KR', sans-serif !important;
    }
    .tabulator .tabulator-header {
      background: var(--surface2) !important;
      border-bottom: 1px solid var(--border) !important;
    }
    .tabulator .tabulator-header .tabulator-col {
      background: var(--surface2) !important;
      border-right: 1px solid var(--border) !important;
      color: var(--text-s) !important;
      font-size: 11px !important;
      font-weight: 800 !important;
      letter-spacing: .1px;
    }
    .tabulator .tabulator-header .tabulator-col:last-child { border-right: none !important; }
    .tabulator-row {
      border-bottom: 1px solid #f1f4fa !important;
      transition: background var(--transition) !important;
    }
    .tabulator-row:hover    { background: #f5f8ff !important; }
    .tabulator-row.row_select {
      background: #f0fdf4 !important;
      border-left: 3px solid var(--green) !important;
    }
    .tabulator-cell { color: var(--text-p) !important; }

    /* 헤더 필터 */
    .tabulator .tabulator-header-filter input {
      height: 26px !important;
      font-size: 12px !important;
      border-radius: 6px !important;
      border: 1px solid var(--border) !important;
      padding: 0 8px !important;
      background: #fff !important;
    }
    .tabulator .tabulator-header-filter input:focus {
      border-color: var(--accent) !important;
      outline: none !important;
    }

    /* ===================== MODAL ===================== */
    .modal {
      display: none;
      position: fixed;
      inset: 0;
      background: rgba(15,23,42,.52);
      backdrop-filter: blur(6px);
      -webkit-backdrop-filter: blur(6px);
      z-index: 9999;
      align-items: center;
      justify-content: center;
      padding: 18px;
    }
    .modal.show { display: flex; }

    .modal-content {
      width: 560px;
      max-width: 95vw;
      max-height: 90vh;
      overflow: auto;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      box-shadow: var(--shadow-lg);
      padding: 24px 22px 20px;
      position: relative;
      animation: pop .20s cubic-bezier(.34,1.36,.64,1);
    }
    @keyframes pop {
      from { opacity: 0; transform: translateY(14px) scale(.97); }
      to   { opacity: 1; transform: none; }
    }

    /* 모달 헤더 */
    .modal-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 18px;
      padding-bottom: 14px;
      border-bottom: 1px solid var(--border);
    }
    .modal-header-icon {
      width: 36px;
      height: 36px;
      border-radius: 10px;
      background: linear-gradient(135deg, var(--green), var(--green-dk));
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 17px;
      box-shadow: 0 2px 8px rgba(22,163,74,.28);
      flex-shrink: 0;
    }
    .modal-title-group { flex: 1; }
    .modal-title {
      font-size: 15px;
      font-weight: 900;
      color: var(--text-p);
      letter-spacing: -.3px;
    }
    .modal-subtitle {
      font-size: 11px;
      color: var(--text-m);
      font-family: 'JetBrains Mono', monospace;
      margin-top: 2px;
    }

    /* 닫기 버튼 */
    .close {
      position: absolute;
      right: 16px;
      top: 16px;
      width: 30px;
      height: 30px;
      border-radius: var(--radius-sm);
      border: 1px solid var(--border);
      background: var(--surface2);
      color: var(--text-s);
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 17px;
      font-weight: 700;
      transition: background var(--transition), color var(--transition);
      line-height: 1;
    }
    .close:hover { background: var(--red-lt); color: var(--red); border-color: #fca5a5; }

    /* 폼 섹션 */
    .form-section { margin-bottom: 14px; }
    .form-section-title {
      font-size: 10px;
      font-weight: 900;
      color: var(--text-m);
      letter-spacing: .8px;
      text-transform: uppercase;
      margin-bottom: 10px;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .form-section-title::after {
      content: '';
      flex: 1;
      height: 1px;
      background: var(--border);
    }

    /* 폼 그리드 */
    .form-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px 12px;
    }
    .form-group { display: flex; flex-direction: column; gap: 5px; }
    .form-group.full { grid-column: 1 / -1; }

    .form-label {
      font-size: 11px;
      font-weight: 800;
      color: var(--text-s);
      letter-spacing: .1px;
    }
    .form-label .required { color: var(--red); margin-left: 2px; }

    .form-input, .form-select {
      height: 38px;
      padding: 0 12px;
      border: 1px solid var(--border);
      border-radius: var(--radius-sm);
      background: var(--surface2);
      font-size: 13px;
      font-family: inherit;
      color: var(--text-p);
      outline: none;
      transition: border-color var(--transition), box-shadow var(--transition), background var(--transition);
    }
    .form-input:focus, .form-select:focus {
      border-color: var(--border-focus);
      box-shadow: 0 0 0 3px rgba(37,99,235,.12);
      background: #fff;
    }
    .form-input::placeholder { color: var(--text-m); font-size: 12px; }

    /* 저장/닫기 버튼 */
    .modal-btns {
      display: flex;
      gap: 10px;
      margin-top: 18px;
    }
    .modal-btns .btn {
      flex: 1;
      height: 42px;
      justify-content: center;
      border-radius: var(--radius-sm);
      font-size: 13px;
    }
    .btn-save {
      background: linear-gradient(135deg, #16a34a, #15803d);
      color: #fff;
      border-color: #15803d;
      box-shadow: 0 2px 10px rgba(22,163,74,.28);
    }
    .btn-save:hover { box-shadow: 0 4px 16px rgba(22,163,74,.38); }
    .btn-close-modal {
      background: var(--surface2);
      color: var(--text-s);
      border-color: var(--border);
    }
    .btn-close-modal:hover { background: var(--surface3); }

    /* ===================== footer badge ===================== */
    .footer-badge {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      padding: 3px 10px;
      border-radius: 20px;
      background: var(--surface2);
      border: 1px solid var(--border);
      font-size: 11px;
      font-family: 'JetBrains Mono', monospace;
      color: var(--text-s);
      font-weight: 600;
    }
    .footer-dot {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: var(--green);
      animation: pulse 2s infinite;
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50%       { opacity: .35; }
    }

    /* ===================== 엑셀 로딩 ===================== */
    #excelOverlay {
      display: none;
      position: fixed;
      inset: 0;
      background: rgba(15,23,42,.45);
      z-index: 9998;
    }
    #excelLoading {
      display: none;
      position: fixed;
      top: 50%; left: 50%;
      transform: translate(-50%,-50%);
      background: var(--surface);
      padding: 28px 44px;
      border-radius: var(--radius);
      box-shadow: var(--shadow-lg);
      font-size: 14px;
      font-weight: 800;
      z-index: 9999;
      text-align: center;
      color: var(--text-p);
    }
    #excelLoading::before {
      content: '';
      display: block;
      margin: 0 auto 12px;
      width: 28px; height: 28px;
      border: 3px solid var(--border);
      border-top: 3px solid var(--green);
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    /* ===================== Responsive ===================== */
    @media (max-width: 900px) {
      .topbar-inner { height: auto; padding: 10px 14px; gap: 8px; }
      .page-wrap    { padding: 12px 14px 20px; }
      .form-grid    { grid-template-columns: 1fr; }
    }
  </style>
</head>

<body>

  <!-- ===================== TOPBAR ===================== -->
  <div class="topbar">
    <div class="topbar-inner">

      <div class="topbar-title">
        <span class="icon-wrap">🏢</span>
        거래처 관리
      </div>
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
        <div class="card-title">거래처 목록</div>
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
        <div class="modal-header-icon">🏢</div>
        <div class="modal-title-group">
          <div class="modal-title" id="modalTitleText">거래처 등록</div>
          <div class="modal-subtitle" id="modalSubtitle">신규 거래처를 추가합니다</div>
        </div>
      </div>

      <form id="corrForm" autocomplete="off">
        <input type="hidden" name="cust_id">

        <!-- 기본 정보 -->
        <div class="form-section">
          <div class="form-section-title">기본 정보</div>
          <div class="form-grid">
            <div class="form-group">
              <label class="form-label">거래처명 <span class="required">*</span></label>
              <input type="text" id="cust_name" name="cust_name" class="form-input" placeholder="거래처명을 입력하세요">
            </div>
            <div class="form-group">
              <label class="form-label">대표이사</label>
              <input type="text" id="ceo_name" name="ceo_name" class="form-input" placeholder="대표이사명">
            </div>
            <div class="form-group">
              <label class="form-label">사업자등록번호</label>
              <input type="text" id="biz_no" name="biz_no" class="form-input" placeholder="000-00-00000">
            </div>
            <div class="form-group">
              <label class="form-label">거래처 번호</label>
              <input type="text" id="biz_type" name="biz_type" class="form-input" placeholder="010-0000-0000">
            </div>
          </div>
        </div>

        <!-- 상세 정보 -->
        <div class="form-section">
          <div class="form-section-title">상세 정보</div>
          <div class="form-grid">
            <div class="form-group full">
              <label class="form-label">주소</label>
              <input type="text" id="address" name="address" class="form-input" placeholder="서울시 강남구 ...">
            </div>
            <div class="form-group">
              <label class="form-label">종목</label>
              <input type="text" id="biz_item" name="biz_item" class="form-input" placeholder="예: 자동차 부품">
            </div>
            <div class="form-group">
              <label class="form-label">담당자명</label>
              <input type="text" id="manager_name" name="manager_name" class="form-input" placeholder="담당자 이름">
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

  <!-- 엑셀 로딩 -->
  <div id="excelOverlay"></div>
  <div id="excelLoading">엑셀 생성 중...</div>

  <!-- ===================== SCRIPT ===================== -->
  <script>
    let now_page_code = "a02";
    let dataTable;
    let selectedRow = null;

    $(document).ready(function () {
      initDataTable();
      loadData();

      // 조회
      $('.select-button').on('click', function () { loadData(); });

      // 추가
      $('.insert-button').on('click', function () {
        selectedRow = null;
        setModalMode('insert');
        $('#corrForm')[0].reset();
        $('input[name="cust_id"]').val('');
        openModal();
      });

      // 삭제
      $('.delete-button').on('click', function () {
        if (!selectedRow) { alert('삭제할 행을 먼저 클릭해 주세요.'); return; }
        const custId = selectedRow.getData().cust_id;
        if (!custId) { alert('삭제할 거래처가 없습니다.'); return; }
        if (!confirm('선택된 거래처를 정말 삭제하시겠습니까?')) return;

        $.ajax({
          url: '/line/standard/customer/delete',
          type: 'POST',
          contentType: 'application/json',
          data: JSON.stringify({ cust_id: custId }),
          dataType: 'json',
          success: function () {
            alert('거래처 정보가 삭제되었습니다!');
            selectedRow = null;
            loadData();
          }
        });
      });

      // 엑셀
      $('.excel-button').on('click', downloadExcel);

      // 모달 닫기
      $('.close, #closeModal').on('click', closeModal);
   
      document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeModal(); });

      // 저장
      $('#saveCorrStatus').on('click', function (event) {
        event.preventDefault();
        const fd = new FormData($('#corrForm')[0]);
        const custId = $('input[name="cust_id"]').val();

        if (!custId) fd.delete('cust_id');

        const url = custId
          ? '/line/standard/customer/update'
          : '/line/standard/customer/save';

        $.ajax({
          url: url,
          type: 'POST',
          data: fd,
          dataType: 'json',
          processData: false,
          contentType: false,
          success: function () {
            alert('거래처 정보가 성공적으로 저장되었습니다!');
            closeModal();
            loadData();
          },
          error: function () { alert('저장 중 오류가 발생했습니다.'); }
        });
      });

      function openModal()  { $('#modalContainer').addClass('show'); }
      function closeModal() { $('#modalContainer').removeClass('show'); }

      function setModalMode(mode, name) {
        if (mode === 'edit') {
          $('#modalTitleText').text('거래처 수정');
          $('#modalSubtitle').text((name || '') + ' 정보를 수정합니다');
        } else {
          $('#modalTitleText').text('거래처 등록');
          $('#modalSubtitle').text('신규 거래처를 추가합니다');
        }
      }

      window._openModal  = openModal;
      window._closeModal = closeModal;
      window._setModalMode = setModalMode;
    });

    /* ── Tabulator 초기화 ── */
    function initDataTable() {
      dataTable = new Tabulator('#dataList', {
        height: '700px',
        layout: 'fitColumns',
        reactiveData: true,
        selectable: 1,
        ajaxLoader: false,
        placeholder: '조회된 데이터가 없습니다.',
        headerHozAlign: 'center',
        columns: [
          { title: 'NO',         formatter: 'rownum',   width: 60,  hozAlign: 'center' },
          { title: '거래처ID',   field: 'cust_id',      width: 80,  hozAlign: 'center', headerFilter: 'input' },
          { title: '거래처코드', field: 'cust_code',    width: 120, hozAlign: 'center', headerFilter: 'input' },
          { title: '거래처명',   field: 'cust_name',    width: 200, hozAlign: 'left',   headerFilter: 'input' },
          { title: '대표이사',   field: 'ceo_name',     width: 120, hozAlign: 'left',   headerFilter: 'input' },
          { title: '사업자번호', field: 'biz_no',       width: 150, hozAlign: 'center', headerFilter: 'input' },
          { title: '주소',       field: 'address',      width: 250, hozAlign: 'left',   headerFilter: 'input' },
          { title: '거래처번호', field: 'biz_type',     width: 130, hozAlign: 'center', headerFilter: 'input' },
          { title: '종목',       field: 'biz_item',     width: 110, hozAlign: 'center', headerFilter: 'input' },
          { title: '담당자',     field: 'manager_name', width: 140, hozAlign: 'center', headerFilter: 'input' },
          { title: '등록일',     field: 'reg_date',     width: 140, hozAlign: 'center', headerFilter: 'input' }
        ],

        rowClick: function (e, row) {
          $('#dataList .tabulator-row').removeClass('row_select');
          row.getElement().classList.add('row_select');
          selectedRow = row;
        },

        rowDblClick: function (e, row) {
          const d = row.getData();
          selectedRow = row;
          window._setModalMode('edit', d.cust_name);

          const $f = $('#corrForm');
          $f[0].reset();
          $f.find('[name="cust_id"]').val(d.cust_id       || '');
          $f.find('[name="cust_name"]').val(d.cust_name   || '');
          $f.find('[name="ceo_name"]').val(d.ceo_name     || '');
          $f.find('[name="biz_no"]').val(d.biz_no         || '');
          $f.find('[name="address"]').val(d.address       || '');
          $f.find('[name="biz_type"]').val(d.biz_type     || '');
          $f.find('[name="biz_item"]').val(d.biz_item     || '');
          $f.find('[name="manager_name"]').val(d.manager_name || '');
          window._openModal();
        }
      });
    }

    /* ── 데이터 로드 ── */
    function loadData() {
      $.ajax({
        url: '/line/standard/customer/list',
        type: 'POST',
        dataType: 'json',
        data: {},
        success: function (data) {
          if (data.status === 'success') {
            dataTable.replaceData(data.data);
            $('#footer-info').text((data.data.length || 0) + ' rows');
          } else {
            alert('데이터 조회 실패: ' + data.message);
          }
        },
        error: function () { alert('데이터 조회 실패'); }
      });
    }

    /* ── 엑셀 다운로드 ── */
    function downloadExcel() {
      const tableData = dataTable.getData();
      if (!tableData || tableData.length === 0) { alert('다운로드할 데이터가 없습니다.'); return; }

      $('#excelOverlay').show();
      $('#excelLoading').show();

      try {
        const excelData = tableData.map((row, idx) => ({
          'NO':           idx + 1,
          '거래처코드':   row.cust_code     || '',
          '거래처명':     row.cust_name     || '',
          '대표이사':     row.ceo_name      || '',
          '사업자번호':   row.biz_no        || '',
          '주소':         row.address       || '',
          '거래처번호':   row.biz_type      || '',
          '종목':         row.biz_item      || '',
          '담당자명':     row.manager_name  || '',
          '등록일':       row.reg_date      || ''
        }));

        const ws = XLSX.utils.json_to_sheet(excelData);
        ws['!cols'] = [
          {wch:5},{wch:15},{wch:25},{wch:12},
          {wch:18},{wch:40},{wch:15},{wch:15},{wch:12},{wch:18}
        ];
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, '거래처목록');

        const now = new Date();
        const ds  = now.getFullYear()
          + String(now.getMonth()+1).padStart(2,'0')
          + String(now.getDate()).padStart(2,'0');
        XLSX.writeFile(wb, '거래처목록_' + ds + '.xlsx');

        setTimeout(function () {
          $('#excelOverlay').hide();
          $('#excelLoading').hide();
        }, 500);
      } catch (e) {
        console.error(e);
        alert('엑셀 다운로드에 실패했습니다.');
        $('#excelOverlay').hide();
        $('#excelLoading').hide();
      }
    }
  </script>
</body>
</html>
