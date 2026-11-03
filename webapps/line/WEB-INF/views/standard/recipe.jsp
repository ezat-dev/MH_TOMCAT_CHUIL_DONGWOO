<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>레시피 관리</title>

  <%@include file="../include/pluginpage.jsp" %>
  <jsp:include page="../include/tabBar.jsp"/>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">

  <style>
    /* ===================== Design System (통일) ===================== */
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
      --teal:         #0d9488;
      --teal-lt:      #f0fdfa;
      --teal-dk:      #0f766e;
      --orange:       #ea580c;
      --orange-lt:    #fff7ed;
      --shadow-sm:    0 1px 4px rgba(0,0,0,.07);
      --shadow-lg:    0 18px 60px rgba(0,0,0,.20);
      --radius-sm:    8px;
      --radius:       12px;
      --radius-lg:    16px;
      --topbar-h:     56px;
      --transition:   .15s cubic-bezier(.4,0,.2,1);
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Noto Sans KR', sans-serif; background: var(--bg); color: var(--text-p); min-height: 100vh; }

    /* ===== TOPBAR ===== */
    .topbar {
      position: sticky; top: 0; z-index: 200;
      background: rgba(255,255,255,.94);
      backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px);
      border-bottom: 1px solid var(--border); box-shadow: var(--shadow-sm);
    }
    .topbar-inner {
      max-width: 1600px; margin: 0 auto; height: var(--topbar-h);
      padding: 0 20px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
    }
    .topbar-title {
      font-size: 14px; font-weight: 900; letter-spacing: -.4px;
      color: var(--text-p); display: flex; align-items: center; gap: 8px;
      white-space: nowrap; margin-right: 4px;
    }
    .topbar-title .icon-wrap {
      width: 28px; height: 28px; border-radius: 8px;
      background: linear-gradient(135deg, var(--teal), var(--teal-dk));
      display: flex; align-items: center; justify-content: center;
      font-size: 14px; box-shadow: 0 2px 8px rgba(13,148,136,.32);
    }
    .divider { width: 1px; height: 20px; background: var(--border); flex-shrink: 0; }
    .label { font-size: 11px; font-weight: 800; color: var(--text-s); white-space: nowrap; letter-spacing: .1px; }

    .ctrl {
      height: 34px; padding: 0 11px;
      border: 1px solid var(--border); border-radius: var(--radius-sm);
      background: var(--surface2); color: var(--text-p);
      font-size: 13px; font-family: inherit; outline: none;
      transition: border-color var(--transition), box-shadow var(--transition), background var(--transition);
    }
    .ctrl:focus { border-color: var(--border-focus); box-shadow: 0 0 0 3px rgba(37,99,235,.13); background: #fff; }
    .ctrl::placeholder { color: var(--text-m); }

    .btn {
      height: 34px; padding: 0 14px; border-radius: var(--radius-sm);
      font-size: 12px; font-weight: 900; font-family: inherit;
      display: inline-flex; align-items: center; gap: 6px;
      cursor: pointer; border: 1px solid transparent;
      transition: transform .08s, filter var(--transition), box-shadow var(--transition);
      white-space: nowrap; user-select: none; letter-spacing: -.1px;
    }
    .btn:active { transform: translateY(1px); }
    .btn:hover  { filter: brightness(1.06); }
    .btn img    { width: 15px; height: 15px; opacity: .92; }
    .btn svg    { width: 14px; height: 14px; flex-shrink: 0; }

    .btn-search { background: linear-gradient(135deg,#475569,#334155); color:#fff; border-color:#334155; box-shadow:0 1px 4px rgba(51,65,85,.20); }
    .btn-insert { background: linear-gradient(135deg,#2563eb,#1d4ed8); color:#fff; border-color:#1d4ed8; box-shadow:0 1px 4px rgba(37,99,235,.25); }
    .btn-delete { background: var(--surface); color: var(--red); border-color: var(--border); }
    .btn-delete:hover { background: var(--red-lt); }
    .btn-excel  { background: linear-gradient(135deg,#16a34a,#15803d); color:#fff; border-color:#15803d; box-shadow:0 1px 4px rgba(22,163,74,.25); }

    /* ===== PAGE ===== */
    .page-wrap { max-width: 1600px; margin: 0 auto; padding: 16px 20px 28px; display: flex; flex-direction: column; gap: 14px; }

    .card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); box-shadow: var(--shadow-sm); overflow: hidden; }
    .card-header {
      padding: 11px 16px; border-bottom: 1px solid var(--border); background: var(--surface2);
      display: flex; align-items: center; justify-content: space-between; gap: 10px;
    }
    .card-title {
      font-size: 12px; font-weight: 900; color: var(--text-p); letter-spacing: -.2px;
      display: flex; align-items: center; gap: 7px;
    }
    .card-title::before { content:''; display:inline-block; width:3px; height:13px; border-radius:3px; background:var(--teal); }
    .card-meta { font-size: 11px; color: var(--text-m); font-family: 'JetBrains Mono',monospace; font-weight: 500; }

    /* ===== TABULATOR ===== */
    #dataList { padding: 10px; }
    .tabulator { border: none !important; font-size: 13px !important; font-family: 'Noto Sans KR',sans-serif !important; }
    .tabulator .tabulator-header { background: var(--surface2) !important; border-bottom: 1px solid var(--border) !important; }
    .tabulator .tabulator-header .tabulator-col {
      background: var(--surface2) !important; border-right: 1px solid var(--border) !important;
      color: var(--text-s) !important; font-size: 11px !important; font-weight: 800 !important;
    }
    .tabulator .tabulator-header .tabulator-col:last-child { border-right: none !important; }
    .tabulator-row { border-bottom: 1px solid #f1f4fa !important; transition: background var(--transition) !important; }
    .tabulator-row:hover { background: #f0fefa !important; }
    .tabulator-row.row_select { background: var(--teal-lt) !important; border-left: 3px solid var(--teal) !important; }
    .tabulator-cell { color: var(--text-p) !important; }
    .tabulator .tabulator-header-filter input {
      height: 26px !important; font-size: 12px !important; border-radius: 6px !important;
      border: 1px solid var(--border) !important; padding: 0 8px !important; background: #fff !important;
    }
    .tabulator .tabulator-header-filter input:focus { border-color: var(--accent) !important; outline: none !important; }

    /* 숨겨진 컬럼 */
    .tabulator-col.hidden-column,
    .tabulator-cell.hidden-column { display: none !important; }

    /* 온도 수치 셀 강조 */
    .temp-val {
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px; font-weight: 600; color: var(--teal);
    }

    /* ===== MODAL ===== */
    .modal {
      display: none; position: fixed; inset: 0;
      background: rgba(15,23,42,.52);
      backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px);
      z-index: 9999; align-items: center; justify-content: center; padding: 18px;
    }
    .modal.show { display: flex; }
    .modal-content {
      width: 640px; max-width: 95vw; max-height: 92vh; overflow-y: auto;
      background: var(--surface); border: 1px solid var(--border);
      border-radius: var(--radius-lg); box-shadow: var(--shadow-lg);
      padding: 24px 22px 20px; position: relative;
      animation: pop .20s cubic-bezier(.34,1.36,.64,1);
    }
    @keyframes pop { from{opacity:0;transform:translateY(14px) scale(.97)} to{opacity:1;transform:none} }

    .modal-header {
      display: flex; align-items: center; gap: 12px;
      margin-bottom: 18px; padding-bottom: 14px; border-bottom: 1px solid var(--border);
    }
    .modal-header-icon {
      width: 36px; height: 36px; border-radius: 10px;
      background: linear-gradient(135deg, var(--teal), var(--teal-dk));
      display: flex; align-items: center; justify-content: center;
      font-size: 17px; box-shadow: 0 2px 8px rgba(13,148,136,.28); flex-shrink: 0;
    }
    .modal-title-group { flex: 1; }
    .modal-title { font-size: 15px; font-weight: 900; color: var(--text-p); letter-spacing: -.3px; }
    .modal-subtitle { font-size: 11px; color: var(--text-m); font-family: 'JetBrains Mono',monospace; margin-top: 2px; }

    .close {
      position: absolute; right: 16px; top: 16px;
      width: 30px; height: 30px; border-radius: var(--radius-sm);
      border: 1px solid var(--border); background: var(--surface2);
      color: var(--text-s); cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      font-size: 17px; font-weight: 700; line-height: 1;
      transition: background var(--transition), color var(--transition);
    }
    .close:hover { background: var(--red-lt); color: var(--red); border-color: #fca5a5; }

    /* 섹션 */
    .form-section { margin-bottom: 16px; }
    .form-section-title {
      font-size: 10px; font-weight: 900; color: var(--text-m);
      letter-spacing: .8px; text-transform: uppercase;
      margin-bottom: 10px; display: flex; align-items: center; gap: 6px;
    }
    .form-section-title::after { content:''; flex:1; height:1px; background:var(--border); }

    /* 섹션 색상 변형 */
    .form-section-title.q-section { color: var(--orange); }
    .form-section-title.q-section::after { background: linear-gradient(90deg, #fed7aa, var(--border)); }
    .form-section-title.t-section { color: var(--teal); }
    .form-section-title.t-section::after { background: linear-gradient(90deg, #99f6e4, var(--border)); }

    /* 그리드 */
    .form-grid   { display: grid; grid-template-columns: 1fr 1fr; gap: 10px 12px; }
    .form-grid-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px 12px; }
    .form-grid-6 { display: grid; grid-template-columns: repeat(6,1fr); gap: 8px; }
    .form-group  { display: flex; flex-direction: column; gap: 5px; }
    .form-group.full { grid-column: 1 / -1; }

    .form-label { font-size: 11px; font-weight: 800; color: var(--text-s); letter-spacing: .1px; }
    .form-label .required { color: var(--red); margin-left: 2px; }

    .form-input, .form-select {
      height: 38px; padding: 0 12px;
      border: 1px solid var(--border); border-radius: var(--radius-sm);
      background: var(--surface2); font-size: 13px; font-family: inherit;
      color: var(--text-p); outline: none;
      transition: border-color var(--transition), box-shadow var(--transition), background var(--transition);
    }
    .form-input:focus, .form-select:focus {
      border-color: var(--border-focus); box-shadow: 0 0 0 3px rgba(37,99,235,.12); background: #fff;
    }
    .form-input::placeholder { color: var(--text-m); font-size: 12px; }
    .form-input[readonly] { background: var(--surface3); color: var(--text-m); cursor: not-allowed; }

    /* 온도 입력 강조 */
    .form-input.q-input:focus { border-color: var(--orange); box-shadow: 0 0 0 3px rgba(234,88,12,.12); }
    .form-input.t-input:focus { border-color: var(--teal);   box-shadow: 0 0 0 3px rgba(13,148,136,.12); }

    /* 온도 존 레이블 */
    .zone-label {
      font-size: 10px; font-weight: 900; color: var(--text-m); letter-spacing: .5px;
      text-align: center; padding: 3px 0;
    }

    /* 저장 버튼 */
    .modal-btns { display: flex; gap: 10px; margin-top: 18px; }
    .modal-btns .btn { flex:1; height:42px; justify-content:center; border-radius:var(--radius-sm); font-size:13px; }
    .btn-save {
      background: linear-gradient(135deg, var(--teal), var(--teal-dk));
      color: #fff; border-color: var(--teal-dk); box-shadow: 0 2px 10px rgba(13,148,136,.28);
    }
    .btn-save:hover { box-shadow: 0 4px 16px rgba(13,148,136,.38); }
    .btn-close-modal { background: var(--surface2); color: var(--text-s); border-color: var(--border); }
    .btn-close-modal:hover { background: var(--surface3); }

    /* footer badge */
    .footer-badge {
      display: inline-flex; align-items: center; gap: 5px; padding: 3px 10px;
      border-radius: 20px; background: var(--surface2); border: 1px solid var(--border);
      font-size: 11px; font-family: 'JetBrains Mono',monospace; color: var(--text-s); font-weight: 600;
    }
    .footer-dot { width:6px; height:6px; border-radius:50%; background:var(--teal); animation:pulse 2s infinite; }
    @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.35} }

    /* 엑셀 로딩 */
    #excelOverlay { display:none; position:fixed; inset:0; background:rgba(15,23,42,.45); z-index:9998; }
    #excelLoading {
      display:none; position:fixed; top:50%; left:50%; transform:translate(-50%,-50%);
      background:var(--surface); padding:28px 44px; border-radius:var(--radius);
      box-shadow:var(--shadow-lg); font-size:14px; font-weight:800; z-index:9999; text-align:center; color:var(--text-p);
    }
    #excelLoading::before {
      content:''; display:block; margin:0 auto 12px; width:28px; height:28px;
      border:3px solid var(--border); border-top:3px solid var(--teal);
      border-radius:50%; animation:spin 1s linear infinite;
    }
    @keyframes spin { to{transform:rotate(360deg)} }

    @media(max-width:900px){
      .topbar-inner { height:auto; padding:10px 14px; gap:8px; }
      .page-wrap    { padding:12px 14px 20px; }
      .form-grid, .form-grid-3, .form-grid-6 { grid-template-columns:1fr 1fr; }
    }
  </style>
</head>
<body>

  <!-- ===== TOPBAR ===== -->
  <div class="topbar">
    <div class="topbar-inner">

      <div class="topbar-title">
        <span class="icon-wrap">🔬</span>
        레시피(패턴) 관리
      </div>
      <div class="divider"></div>

      <span class="label">품번</span>
      <input type="text" id="search_item_no"   class="ctrl" style="width:130px;" placeholder="품번 입력">
      <span class="label">품명</span>
      <input type="text" id="search_item_name" class="ctrl" style="width:150px;" placeholder="품명 입력">
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
          <line x1="12" y1="12" x2="12" y2="18"/><line x1="9" y1="15" x2="15" y2="15"/>
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

  <!-- ===== PAGE ===== -->
  <div class="page-wrap">
    <div class="card">
      <div class="card-header">
        <div class="card-title">패턴 목록</div>
        <div class="card-meta">Double Click → 수정 모드</div>
      </div>
      <div id="dataList"></div>
    </div>
  </div>

  <!-- ===== MODAL ===== -->
  <div id="modalContainer" class="modal">
    <div class="modal-content">
      <button class="close" type="button" aria-label="닫기">&times;</button>

      <div class="modal-header">
        <div class="modal-header-icon">🔬</div>
        <div class="modal-title-group">
          <div class="modal-title" id="modalTitleText">패턴 등록</div>
          <div class="modal-subtitle" id="modalSubtitle">신규 레시피 패턴을 추가합니다</div>
        </div>
      </div>

      <form id="corrForm" autocomplete="off">
        <input type="hidden" name="recipe_id">

        <!-- 기본 정보 -->
        <div class="form-section">
          <div class="form-section-title">기본 정보</div>
          <div class="form-grid">
            <div class="form-group">
              <label class="form-label">패턴 코드 <span style="color:var(--text-m);font-weight:500;">(자동생성)</span></label>
              <input type="text" id="recipe_code" name="recipe_code" class="form-input" placeholder="자동 생성" readonly>
            </div>
            <div class="form-group">
              <label class="form-label">장입량 <span class="required">*</span></label>
              <input type="number" id="charge_weight" name="charge_weight" class="form-input" value="0">
            </div>
            <div class="form-group">
              <label class="form-label">품번 <span class="required">*</span></label>
              <select id="item_name" name="item_name" class="form-select">
                <option value="">선택하세요</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">제품코드 <span style="color:var(--text-m);font-weight:500;">(자동생성)</span></label>
              <input type="text" id="prod_code" name="prod_code" class="form-input" placeholder="품번 선택 시 자동 입력" readonly>
            </div>
          </div>
        </div>

        <!-- 퀜칭로 -->
        <div class="form-section">
          <div class="form-section-title q-section">🔥 퀜칭로 설정</div>
          <div class="form-grid-6">
            <div class="form-group">
              <div class="zone-label">1존 온도</div>
              <input type="number" name="q1_temp" class="form-input q-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">2존 온도</div>
              <input type="number" name="q2_temp" class="form-input q-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">3존 온도</div>
              <input type="number" name="q3_temp" class="form-input q-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">4존 온도</div>
              <input type="number" name="q4_temp" class="form-input q-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">5존 온도</div>
              <input type="number" name="q5_temp" class="form-input q-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">속도</div>
              <input type="number" name="q_speed" class="form-input q-input" value="0">
            </div>
          </div>
          <div style="margin-top:10px;">
            <div class="form-group" style="max-width:160px;">
              <label class="form-label">CP</label>
              <input type="number" name="cp" class="form-input q-input" value="0">
            </div>
          </div>
        </div>

        <!-- 템퍼링 -->
        <div class="form-section">
          <div class="form-section-title t-section">🌡 템퍼링 설정</div>
          <div class="form-grid-6">
            <div class="form-group">
              <div class="zone-label">1존</div>
              <input type="number" name="t1_zone" class="form-input t-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">2존</div>
              <input type="number" name="t2_zone" class="form-input t-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">3존</div>
              <input type="number" name="t3_zone" class="form-input t-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">4존</div>
              <input type="number" name="t4_zone" class="form-input t-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">5존</div>
              <input type="number" name="t5_zone" class="form-input t-input" value="0">
            </div>
            <div class="form-group">
              <div class="zone-label">속도</div>
              <input type="number" name="c_speed" class="form-input t-input" value="0">
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

  <div id="excelOverlay"></div>
  <div id="excelLoading">엑셀 생성 중...</div>

  <!-- ===== SCRIPT ===== -->
  <script>
    let now_page_code = "a04";
    let dataTable;
    let selectedRow = null;

    /* 온도 셀 포매터 */
    function tempFormatter(cell) {
      const v = cell.getValue();
      if (v === null || v === undefined || v === '') return '<span style="color:var(--text-m)">-</span>';
      return '<span class="temp-val">' + v + '</span>';
    }

    $(document).ready(function () {
      initDataTable();
      loadData();
      loadItemNameList();

      /* 조회 */
      $('.select-button').on('click', loadData);

      /* 엑셀 */
      $('.excel-button').on('click', downloadExcel);

      /* 추가 */
      $('.insert-button').on('click', function () {
        selectedRow = null;
        setModalMode('insert');
        $('#corrForm')[0].reset();
        $('input[name="recipe_id"]').val('');
        loadItemNameList();
        openModal();
      });

      /* 삭제 */
      $('.delete-button').on('click', function () {
        if (!selectedRow) { alert('삭제할 행을 먼저 클릭해 주세요.'); return; }
        const recipeId = selectedRow.getData().recipe_id;
        if (!recipeId) { alert('삭제할 레시피가 없습니다.'); return; }
        if (!confirm('선택된 패턴을 정말 삭제하시겠습니까?')) return;

        $.ajax({
          url: '/line/standard/recipe/delete', type: 'POST',
          contentType: 'application/json', data: JSON.stringify({ recipe_id: recipeId }), dataType: 'json',
          success: function () { alert('삭제되었습니다!'); selectedRow = null; loadData(); },
          error: function () { alert('삭제 실패'); }
        });
      });

      /* 모달 닫기 */
      $('.close, #closeModal').on('click', closeModal);
   
      document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeModal(); });

      /* 저장 */
      $('#saveCorrStatus').on('click', function (e) {
        e.preventDefault();
        const $f = $('#corrForm');
        const formData = {
          recipe_id:     $f.find('[name="recipe_id"]').val()     || undefined,
          recipe_code:   $f.find('[name="recipe_code"]').val(),
          item_name:     $f.find('[name="item_name"]').val(),
          prod_code:     $f.find('[name="prod_code"]').val(),
          charge_weight: $f.find('[name="charge_weight"]').val(),
          q1_zone:       $f.find('[name="q1_temp"]').val(),
          q2_zone:       $f.find('[name="q2_temp"]').val(),
          q3_zone:       $f.find('[name="q3_temp"]').val(),
          q4_zone:       $f.find('[name="q4_temp"]').val(),
          q5_zone:       $f.find('[name="q5_temp"]').val(),
          q_speed:       $f.find('[name="q_speed"]').val(),
          cp:            $f.find('[name="cp"]').val(),
          t1_zone:       $f.find('[name="t1_zone"]').val(),
          t2_zone:       $f.find('[name="t2_zone"]').val(),
          t3_zone:       $f.find('[name="t3_zone"]').val(),
          t4_zone:       $f.find('[name="t4_zone"]').val(),
          t5_zone:       $f.find('[name="t5_zone"]').val(),
          t_speed:       $f.find('[name="c_speed"]').val()
        };

        const url = formData.recipe_id
          ? '/line/standard/recipe/update'
          : '/line/standard/recipe/save';

        $.ajax({
          url: url, type: 'POST',
          contentType: 'application/json', data: JSON.stringify(formData), dataType: 'json',
          success: function () { alert('레시피 정보가 성공적으로 저장되었습니다!'); closeModal(); loadData(); },
          error: function () { alert('저장 실패'); }
        });
      });

      /* 품번 선택 → 제품코드 자동 입력 */
      $('#item_name').on('change', function () {
        const prodCode = $(this).find('option:selected').data('prod-code') || '';
        $('#prod_code').val(prodCode);
      });

      function openModal()  { $('#modalContainer').addClass('show'); }
      function closeModal() { $('#modalContainer').removeClass('show'); }
      window._openModal  = openModal;
      window._closeModal = closeModal;
    });

    function setModalMode(mode, name) {
      if (mode === 'edit') {
        $('#modalTitleText').text('패턴 수정');
        $('#modalSubtitle').text((name || '') + ' 패턴을 수정합니다');
      } else {
        $('#modalTitleText').text('패턴 등록');
        $('#modalSubtitle').text('신규 레시피 패턴을 추가합니다');
      }
    }

    /* ── Tabulator ── */
    function initDataTable() {
      dataTable = new Tabulator('#dataList', {
        height: '700px', layout: 'fitColumns',
        reactiveData: true, selectable: 1, ajaxLoader: false,
        placeholder: '조회된 데이터가 없습니다.', headerHozAlign: 'center',
        columns: [
          { title:'NO',        formatter:'rownum', width:60, hozAlign:'center' },
          { title:'레시피ID',  field:'recipe_id',  width:90, hozAlign:'center', cssClass:'hidden-column', headerFilter:'input' },
          { title:'거래처코드',field:'cust_code',  width:110,hozAlign:'center', cssClass:'hidden-column' },
          { title:'레시피코드',field:'recipe_code',width:110,hozAlign:'center', cssClass:'hidden-column' },
          { title:'제품코드',  field:'prod_code',  width:110,hozAlign:'center', cssClass:'hidden-column' },
          { title:'거래처명',  field:'cust_name',  width:150,hozAlign:'left',  headerFilter:'input' },
          { title:'품번',      field:'item_no',    width:200,hozAlign:'left',  headerFilter:'input' },
          { title:'품명',      field:'item_name',  width:260,hozAlign:'left',  headerFilter:'input' },
          { title:'규격',      field:'spec',       width:120,hozAlign:'left',  headerFilter:'input' },
          { title:'재질',      field:'texture',    width:110,hozAlign:'left',  headerFilter:'input' },
          {
            title:'심부경도 규격', field:'temper_low', width:140, hozAlign:'center', headerFilter:'input',
            formatter: function(cell) {
              const d = cell.getRow().getData();
              const lo = d.temper_low ?? '', hi = d.temper_high ?? '';
              if (lo==='' && hi==='') return '<span style="color:var(--text-m)">-</span>';
              return '<span class="temp-val">' + lo + ' ~ ' + hi + '</span>';
            }
          },
          { title:'장입량', field:'charge_weight', width:90, hozAlign:'right', headerFilter:'input' },
          {
            title:'퀜칭로 온도',
            columns: [
              { title:'1존', field:'q1_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'2존', field:'q2_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'3존', field:'q3_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'4존', field:'q4_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'5존', field:'q5_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'속도', field:'q_speed', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter }
            ]
          },
          { title:'CP', field:'cp', width:70, hozAlign:'center', headerSort:false, formatter:tempFormatter },
          {
            title:'템퍼링 온도',
            columns: [
              { title:'1존', field:'t1_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'2존', field:'t2_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'3존', field:'t3_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'4존', field:'t4_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'5존', field:'t5_zone', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter },
              { title:'속도', field:'t_speed', width:68, hozAlign:'center', headerSort:false, formatter:tempFormatter }
            ]
          },
          { title:'등록일', field:'reg_date', width:170, hozAlign:'center', headerFilter:'input' }
        ],
        rowClick: function (e, row) {
          $('#dataList .tabulator-row').removeClass('row_select');
          row.getElement().classList.add('row_select');
          selectedRow = row;
        },
        rowDblClick: function (e, row) {
          const d = row.getData();
          selectedRow = row;
          setModalMode('edit', d.item_name);
          const $f = $('#corrForm');
          $f[0].reset();
          $f.find('[name="recipe_id"]').val(d.recipe_id      || '');
          $f.find('[name="recipe_code"]').val(d.recipe_code  || '');
          $f.find('[name="prod_code"]').val(d.prod_code      || '');
          $f.find('[name="charge_weight"]').val(d.charge_weight || '');
          $f.find('[name="q1_temp"]').val(d.q1_zone || '');
          $f.find('[name="q2_temp"]').val(d.q2_zone || '');
          $f.find('[name="q3_temp"]').val(d.q3_zone || '');
          $f.find('[name="q4_temp"]').val(d.q4_zone || '');
          $f.find('[name="q5_temp"]').val(d.q5_zone || '');
          $f.find('[name="q_speed"]').val(d.q_speed  || '');
          $f.find('[name="cp"]').val(d.cp             || '');
          $f.find('[name="t1_zone"]').val(d.t1_zone  || '');
          $f.find('[name="t2_zone"]').val(d.t2_zone  || '');
          $f.find('[name="t3_zone"]').val(d.t3_zone  || '');
          $f.find('[name="t4_zone"]').val(d.t4_zone  || '');
          $f.find('[name="t5_zone"]').val(d.t5_zone  || '');
          $f.find('[name="c_speed"]').val(d.t_speed  || '');

          loadItemNameList(d.item_no);
          window._openModal();
        }
      });
    }

    /* ── 데이터 로드 ── */
    function loadData() {
      $.ajax({
        url: '/line/standard/recipe/list', type: 'POST', dataType: 'json',
        data: {
          item_no:   $('#search_item_no').val(),
          item_name: $('#search_item_name').val(),
          cust_name: $('#search_cust_name').val()
        },
        success: function (data) {
          if (data.status === 'success') {
            dataTable.replaceData(data.data);
            $('#footer-info').text((data.data.length || 0) + ' rows');
          } else { alert('데이터 조회 실패: ' + data.message); }
        },
        error: function () { alert('데이터 조회 실패'); }
      });
    }

    /* ── 품번 목록 ── */
    function loadItemNameList(selectedItemNo) {
      $.ajax({
        url: '/line/standard/recipe/getRecipeProduct', type: 'POST', dataType: 'json',
        success: function (resp) {
          if (resp.status === 'success') {
            const sel = $('#item_name');
            sel.empty().append('<option value="">선택하세요</option>');
            resp.data.forEach(function (item) {
              const name = item.item_no || '';
              const code = item.prod_code || '';
              const opt  = $('<option></option>').val(name).text(name).attr('data-prod-code', code);
              if (name === selectedItemNo) { opt.prop('selected', true); $('#prod_code').val(code); }
              sel.append(opt);
            });
          } else { alert('제품 조회 실패: ' + resp.message); }
        },
        error: function () { alert('제품 조회 실패'); }
      });
    }

    /* ── 엑셀 ── */
    function downloadExcel() {
      $('#excelOverlay').show(); $('#excelLoading').show();
      try {
        const today = new Date();
        const ds = today.getFullYear() + String(today.getMonth()+1).padStart(2,'0') + String(today.getDate()).padStart(2,'0');
        dataTable.download('xlsx', '패턴관리_' + ds + '.xlsx', { sheetName:'패턴관리 목록' });
        setTimeout(function () { $('#excelOverlay').hide(); $('#excelLoading').hide(); }, 500);
      } catch(e) {
        console.error(e); alert('엑셀 다운로드에 실패했습니다.');
        $('#excelOverlay').hide(); $('#excelLoading').hide();
      }
    }
  </script>
</body>
</html>
