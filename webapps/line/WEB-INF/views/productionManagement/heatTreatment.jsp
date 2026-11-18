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
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
  <link rel="stylesheet" href="/line/css/opsList/ops-list.css">

  <style>
    /* ===== 데모: 작업지시관리 — 고밀도 운영 화면 (공통 ops-list.css + 이 화면 전용 규칙) ===== */
    html, body.ops { height: 100%; }
    body.ops { display: flex; flex-direction: column; overflow: hidden; line-height: 1.5; }
    .ops-head { flex-shrink: 0; }
    .ops-page { flex: 1; min-height: 0; }
    .ops-input.dayselect { width: 120px; min-width: 0; }
    .tb-range { color: var(--ops-fg3); }

    /* 표 카드: 남은 높이를 채우고 표 안에서만 스크롤 */
    .ht-card { flex: 1; min-height: 0; display: flex; flex-direction: column; }
    .ht-card #dataTable { flex: 1; min-height: 0; }
    .ops-table .tabulator-header-filter input {
      height: 24px !important; padding: 0 8px !important; margin-top: 4px;
      border: 1px solid var(--ops-line) !important; border-radius: 4px !important; background: #fff !important;
      font-family: var(--ops-sans) !important; font-size: 12px !important; font-weight: 400 !important; color: var(--ops-fg) !important;
    }
    .ops-table .tabulator-header-filter input:focus { border-color: var(--ops-accent) !important; outline: none !important; }
    .ops-table .tabulator-header-filter input::placeholder { color: var(--ops-fg3); }
    .ops-table .tabulator-cell.ht-num { text-align: right !important; }
    .ops .c-lot.ri { color: var(--ops-warn); }
    .ops .ht-sub { margin-left: 6px; font-size: 11px; color: var(--ops-fg3); }
    .ops .st.run { color: var(--ops-accent); }
    .ops .st.pend { color: var(--ops-fg3); }
    .ops .st.pend i { background: transparent; box-shadow: inset 0 0 0 1.5px var(--ops-fg3); }

    /* ── 모달 공통 (작업 지시서 · 제품 선택) ── */
    .modal-ov {
      display: none; position: fixed; inset: 0; z-index: 9000; padding: 24px;
      align-items: center; justify-content: center; background: oklch(20% 0.01 255 / 0.4);
    }
    .modal-ov.show { display: flex; }
    .ops .modal-box {
      width: 560px; max-width: 95vw; max-height: 90vh; padding: 0; overflow: hidden;
      display: flex; flex-direction: column;
      background: #fff; border: 1px solid var(--ops-line); border-radius: 8px; box-shadow: 0 12px 32px oklch(20% 0.01 255 / 0.16);
    }
    .modal-titlebar { flex-shrink: 0; display: flex; align-items: center; gap: 12px; padding: 12px 12px 12px 16px; border-bottom: 1px solid var(--ops-line); }
    .modal-titlebar-icon { display: none; }
    .modal-titlebar-text { flex: 1; min-width: 0; }
    .modal-titlebar-title { font-size: 15px; font-weight: 600; color: var(--ops-fg); display: flex; align-items: center; gap: 8px; }
    .modal-titlebar-sub { font-size: 12px; color: var(--ops-fg3); margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .modal-titlebar.re-bar .modal-titlebar-title::before { content: ""; width: 8px; height: 8px; border-radius: 50%; background: var(--ops-warn); }
    .mclose {
      width: 28px; height: 28px; flex-shrink: 0; display: flex; align-items: center; justify-content: center;
      border: 0; border-radius: 6px; background: transparent; color: var(--ops-fg2); font-size: 18px; line-height: 1; cursor: pointer;
    }
    .mclose:hover { background: var(--ops-hover); color: var(--ops-fg); }
    #corrForm { flex: 1; min-height: 0; display: flex; flex-direction: column; }
    .ops .modal-body { flex: 1; min-height: 0; overflow-y: auto; padding: 16px; }
    .modal-footer { flex-shrink: 0; display: flex; justify-content: flex-end; gap: 8px; padding: 12px 16px; border-top: 1px solid var(--ops-line); }
    .modal-footer .ops-btn { min-width: 80px; justify-content: center; }

    .form-section + .form-section { margin-top: 16px; padding-top: 16px; border-top: 1px solid var(--ops-line2); }
    .sec-label { margin-bottom: 8px; font-size: 12px; font-weight: 600; color: var(--ops-fg2); display: flex; align-items: center; gap: 6px; }
    .sec-label.amber-sec::before { content: ""; width: 6px; height: 6px; border-radius: 50%; background: var(--ops-warn); }
    .f-label { font-size: 12px; font-weight: 500; color: var(--ops-fg2); }
    .f-label .req { color: var(--ops-bad); margin-left: 2px; }
    .f-label .hint { color: var(--ops-fg3); font-weight: 400; margin-left: 4px; }
    .f-input {
      width: 100%; height: 32px; padding: 0 8px; border: 1px solid var(--ops-line); border-radius: 6px; background: #fff;
      color: var(--ops-fg); font-family: var(--ops-sans); font-size: 13px; outline: none;
    }
    .f-input.mono { font-family: var(--ops-mono); font-variant-numeric: tabular-nums slashed-zero; }
    .f-input.num { text-align: right; }
    .f-input:focus { border-color: var(--ops-accent); box-shadow: 0 0 0 2px var(--ops-accent-tint); }
    .f-input::placeholder { color: var(--ops-fg3); }
    .f-input[readonly] { background: var(--ops-bg); color: var(--ops-fg2); cursor: default; }
    .f-input.clickable { cursor: pointer; background: #fff; color: var(--ops-fg); padding-right: 56px;
      background-image: linear-gradient(var(--ops-line), var(--ops-line)); background-size: 1px 20px; background-position: calc(100% - 48px) center; background-repeat: no-repeat; }
    .f-input.clickable:hover { border-color: oklch(80% 0.03 255); }
    .pick-wrap { position: relative; }
    .pick-wrap::after { content: "선택"; position: absolute; right: 12px; top: 50%; transform: translateY(-50%); font-size: 12px; font-weight: 500; color: var(--ops-accent); pointer-events: none; }
    .mbtn-save-re { background: var(--ops-accent); border-color: var(--ops-accent); color: #fff; }

    /* 제품 선택 모달 */
    #pcodeModal { z-index: 10000; }
    .ops .pcode-box { width: 98vw; max-width: 1780px; }
    .pcode-search { flex-shrink: 0; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; padding: 12px 16px; border-bottom: 1px solid var(--ops-line); }
    .pcode-lbl { font-size: 12px; color: var(--ops-fg2); white-space: nowrap; }
    .pcode-search .ctrl-body { width: 180px; min-width: 0; font-family: var(--ops-sans); }
    .pcode-search .ctrl-body + .pcode-lbl { margin-left: 8px; }
    .pcode-body { flex: 1; min-height: 0; padding: 0; overflow: hidden; }
    #pcodeTabu .tabulator-col-title { white-space: normal !important; text-overflow: clip !important; line-height: 1.3; }

    /* 엑셀 로딩 */
    #excelOverlay { display: none; position: fixed; inset: 0; background: oklch(20% 0.01 255 / 0.3); z-index: 19998; }
    #excelLoading {
      display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 19999;
      padding: 16px 24px; background: #fff; border: 1px solid var(--ops-line); border-radius: 8px;
      box-shadow: 0 12px 32px oklch(20% 0.01 255 / 0.16); font-family: var(--ops-sans); font-size: 13px; color: var(--ops-fg);
    }
  </style>
</head>
<body class="ops">

<!-- ═══════════ 헤더 + 툴바 ═══════════ -->
<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">작업지시관리</h1>

    <span class="ops-label">작업일자</span>
    <input type="text" class="ops-input ctrl dayselect daySet" id="w_date" placeholder="YYYY-MM-DD">
    <span class="tb-range">~</span>
    <input type="text" class="ops-input ctrl dayselect daySet" id="w_date_end" placeholder="YYYY-MM-DD">
    <button class="ops-btn btn select-button" type="button">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16.5" y2="16.5"/></svg>조회
    </button>

    <span class="ops-spacer"></span>

    <button class="ops-btn btn re_re" type="button" title="선택한 LOT를 RI 재처리로 등록">
      <svg viewBox="0 0 24 24"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>재처리
    </button>
    <button class="ops-btn btn" id="lot_pdf" type="button" title="선택한 행의 작업지시서 PDF">
      <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>작업지시 PDF
    </button>
    <button class="ops-btn btn excel-button" type="button">
      <svg viewBox="0 0 24 24"><path d="M12 3v12"/><polyline points="7 10 12 15 17 10"/><line x1="5" y1="20" x2="19" y2="20"/></svg>엑셀
    </button>
    <span class="ops-sep"></span>
    <button class="ops-btn btn danger delete-button" type="button">삭제</button>
    <button class="ops-btn btn primary insert-button" type="button">
      <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>작업지시 등록
    </button>
  </div>
</header>

<!-- ═══════════ 페이지 ═══════════ -->
<main class="ops-page">
  <!-- 요약: 첫 칸이 핵심 지표 (조회 결과로 계산, 표시 전용) -->
  <section class="ops-kpi" aria-label="작업지시 요약">
    <div class="hero">
      <span class="kpi-label">진행중</span>
      <span class="kpi-value" id="kRun">—</span>
      <span class="kpi-sub">바코드 스캔 후 투입 종료 전</span>
    </div>
    <div>
      <span class="kpi-label">대기</span>
      <span class="kpi-value" id="kWait">—</span>
      <span class="kpi-sub">스캔 전 작업지시</span>
    </div>
    <div>
      <span class="kpi-label">완료</span>
      <span class="kpi-value" id="kDone">—</span>
      <span class="kpi-sub">투입 종료</span>
    </div>
    <div>
      <span class="kpi-label">재처리 (RI)</span>
      <span class="kpi-value" id="kRe">—</span>
      <span class="kpi-sub">조회 기간 내</span>
    </div>
    <div>
      <span class="kpi-label">계획 통수 합계</span>
      <span class="kpi-value" id="kPlan">—</span>
      <span class="kpi-sub">통</span>
    </div>
  </section>

  <section class="ops-card ht-card">
    <div class="ops-card-head">
      <h2>작업지시 목록</h2>
      <span class="note">클릭: 선택 · 더블클릭: 수정 · 재처리와 PDF는 선택한 행 기준</span>
    </div>
    <div id="dataTable" class="ops-table"></div>
    <div class="ops-card-foot">
      <span>총 <strong id="rowCount">0</strong>건</span>
      <span>상태: <span class="st pend"><i></i>대기</span> · <span class="st run"><i></i>진행중</span> · <span class="st ok"><i></i>완료</span></span>
    </div>
  </section>
</main>

<!-- ═══════════ 작업 지시서 모달 ═══════════ -->
<div id="modalContainer" class="modal-ov">
  <div class="modal-box" id="mainModalBox">

    <div class="modal-titlebar" id="mainTitleBar">
      <div class="modal-titlebar-icon" id="mainModalIcon"></div>
      <div class="modal-titlebar-text">
        <div class="modal-titlebar-title" id="mainModalTitle">작업 지시서 등록</div>
        <div class="modal-titlebar-sub"   id="mainModalSub">신규 열처리 작업을 등록합니다</div>
      </div>
      <button class="mclose close" type="button" aria-label="닫기">&times;</button>
    </div>

    <form id="corrForm" autocomplete="off">
      <div class="modal-body">

        <div class="form-section">
          <div class="sec-label">기본 정보</div>
          <div class="form-grid">

            <div class="form-group">
              <label class="f-label">작업일 <span class="req">*</span></label>
              <input type="text" name="w_date" class="f-input mono daySet" placeholder="YYYY-MM-DD">
            </div>

            <div class="form-group">
              <label class="f-label">ERP 작지번호</label>
              <input type="text" name="erp_jack_no" class="f-input mono" placeholder="ERP 작지번호">
            </div>

            <div class="form-group">
              <label class="f-label">품번 <span class="req">*</span><span class="hint">클릭하여 제품 선택</span></label>
              <div class="pick-wrap">
                <input type="text" name="w_pnum" class="f-input mono clickable"
                       readonly onclick="pcodeSelect();" placeholder="제품 선택">
              </div>
            </div>

            <div class="form-group">
              <label class="f-label">투입계획통수</label>
              <input type="text" name="w_plan_cnt" class="f-input mono num" placeholder="통">
            </div>

            <div class="form-group full">
              <label class="f-label">품명</label>
              <input type="text" name="w_pname" class="f-input" readonly
                     placeholder="품번 선택 시 자동 입력">
            </div>

          </div>
        </div>

        <div class="form-section" id="reSection" style="display:none;">
          <div class="sec-label amber-sec">재처리 정보</div>
          <div class="form-grid">
            <div class="form-group">
              <label class="f-label re_text">재처리 LOT (RI)</label>
              <input type="text" name="w_ci_lot" class="f-input mono" style="display:none;" placeholder="재처리 LOT">
            </div>
            <div class="form-group">
              <label class="f-label">원본 LOT (CI)</label>
              <input type="text" name="w_old_lot" class="f-input mono" style="display:none;" placeholder="원본 CI LOT" readonly>
            </div>
          </div>
        </div>

        <input type="text" name="w_rcode" style="display:none;">
      </div>

      <div class="modal-footer">
        <button type="button" id="closeModal" class="ops-btn btn mbtn-cancel">닫기</button>
        <button type="button" id="saveCorrStatus" class="ops-btn btn primary mbtn-save">저장</button>
      </div>
    </form>
  </div>
</div>

<!-- ═══════════ 제품 선택 모달 ═══════════ -->
<div id="pcodeModal" class="modal-ov">
  <div class="modal-box pcode-box">

    <div class="modal-titlebar">
      <div class="modal-titlebar-text">
        <div class="modal-titlebar-title">제품 선택</div>
        <div class="modal-titlebar-sub">더블클릭하여 제품을 선택합니다</div>
      </div>
      <button class="mclose closePcodeModal" type="button" aria-label="닫기">&times;</button>
    </div>

    <div class="pcode-search">
      <span class="pcode-lbl">거래처명</span>
      <input type="text" id="s_cname" class="ops-input ctrl-body pcodeModalEnter" placeholder="아래 표 필터 이용">
      <span class="pcode-lbl">품번</span>
      <input type="text" id="s_pnum"  class="ops-input ctrl-body pcodeModalEnter" placeholder="품번">
      <span class="pcode-lbl">품명</span>
      <input type="text" id="s_pname" class="ops-input ctrl-body pcodeModalEnter" placeholder="품명">
      <button type="button" class="ops-btn btn" onclick="getPcodeData();">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16.5" y2="16.5"/></svg>조회
      </button>
    </div>

    <div class="modal-body pcode-body">
      <div id="pcodeTabu" class="ops-table"></div>
    </div>

    <div class="modal-footer">
      <button type="button" class="ops-btn btn mbtn-cancel closePcodeModal">닫기</button>
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
    $('#mainModalIcon').text('');
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
    $('#mainModalIcon').text('');
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
    if (!v) return '<span class="c-none">—</span>';
    var isRI = v.indexOf('RI') !== -1;
    return '<span class="c-lot' + (isRI ? ' ri' : '') + '">' + v + '</span>' + (isRI ? '<span class="ht-sub">재처리</span>' : '');
  }

  /* ── 진행 상태 (표시 전용): 스캔 전 = 대기, 스캔 후 투입 종료 전 = 진행중, 투입 종료 = 완료 ── */
  function workState(d) {
    if (d.x111 || d.l20) return 'done';
    return d.w_sdatetime ? 'run' : 'wait';
  }
  var WORK_STATE = { wait: ['pend', '대기'], run: ['run', '진행중'], done: ['ok', '완료'] };
  function stateFormatter(cell) {
    var s = WORK_STATE[workState(cell.getRow().getData())];
    return '<span class="st ' + s[0] + '"><i></i>' + s[1] + '</span>';
  }
  function timeFormatter(cell) {
    var v = cell.getValue();
    return v ? '<span class="c-time">' + v + '</span>' : '<span class="c-none">—</span>';
  }
  /* 시각: 작업일자와 같은 날이면 HH:mm, 다른 날이면 MM-DD HH:mm (전체 값은 툴팁, 엑셀은 원본 그대로) */
  function clockFormatter(cell) {
    var v = String(cell.getValue() || '');
    if (!v) return '<span class="c-none">—</span>';
    var m = v.match(/^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})/);
    if (!m) return '<span class="c-time">' + v + '</span>';
    var sameDay = (cell.getRow().getData().w_date || '') === m[1] + '-' + m[2] + '-' + m[3];
    return '<span class="c-time" title="' + v + '">' + (sameDay ? '' : m[2] + '-' + m[3] + ' ') + m[4] + ':' + m[5] + '</span>';
  }
  function numFormatter(cell) {
    var v = cell.getValue();
    return (v === null || v === undefined || v === '') ? '<span class="c-none">—</span>' : '<span class="c-num">' + v + '</span>';
  }
  function plainFormatter(cell) {
    var v = cell.getValue();
    return v ? $('<span>').text(v).html() : '<span class="c-none">—</span>';
  }

  /* ── 메인 Tabulator ── */
  function getHeatList() {
    heatListTable = new Tabulator('#dataTable', {
      height: '100%',
      layout: 'fitColumns',
      headerSort: false,
      reactiveData: true,
      columnHeaderVertAlign: 'middle',
      rowVertAlign: 'middle',
      headerHozAlign: 'left',
      renderHorizontal: 'virtual',
      selectable: true,
      selectableRangeMode: 'click',
      placeholder: '조회된 데이터가 없습니다.',
      columns: [
        { title:'상태',           field:'w_state_view',  width:80,  formatter:stateFormatter, download:false },
        { title:'작업일자',       field:'w_date',        width:100, formatter:timeFormatter },
        { title:'작업 LOT',       field:'w_ci_lot',      width:176,
          headerFilter:'input', headerFilterPlaceholder:'필터', formatter:lotFormatter },
        { title:'ERP 작지번호',   field:'erp_jack_no',   width:136, cssClass:'c-lot',
          headerFilter:'input', headerFilterPlaceholder:'필터' },
        { title:'회사명',         field:'cust_name',     width:104,
          headerFilter:'input', headerFilterPlaceholder:'필터' },
        { title:'품번',           field:'item_no',       width:136, cssClass:'c-lot',
          headerFilter:'input', headerFilterPlaceholder:'필터' },
        { title:'품명',           field:'item_name',     minWidth:150,
          headerFilter:'input', headerFilterPlaceholder:'필터' },
        { title:'바코드 스캔',    field:'w_sdatetime',   width:104, formatter:clockFormatter },
        { title:'투입 시작',      field:'d370',          width:104, formatter:clockFormatter },
        { title:'투입 종료',      field:'x111',          width:104, formatter:clockFormatter },
        { title:'계획 통수',      field:'w_plan_cnt',    width:80,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num', formatter:numFormatter },
        { title:'기준 장입량',    field:'charge_weight', width:88,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num', formatter:numFormatter },
        { title:'제품 이미지 1',  field:'img_url_1',     width:120, formatter:plainFormatter, tooltip:true },
        { title:'제품 이미지 2',  field:'img_url_2',     width:120, formatter:plainFormatter, tooltip:true },
        { title:'작업 완료',      field:'l20',           width:104, formatter:clockFormatter }
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
        $('#rowCount').text(rows.length);
        updateSummary(rows);
      }
    });
  }

  /* ── 요약 띠 (표시 전용) ── */
  function updateSummary(rows) {
    var c = { wait: 0, run: 0, done: 0 }, re = 0, plan = 0;
    rows.forEach(function (d) {
      c[workState(d)]++;
      if ((d.w_ci_lot || '').indexOf('RI') !== -1) re++;
      plan += Number(d.w_plan_cnt) || 0;
    });
    $('#kRun').text(c.run); $('#kWait').text(c.wait); $('#kDone').text(c.done);
    $('#kRe').text(re); $('#kPlan').text(plan.toLocaleString());
  }

  /* 창 크기 변경 시 표 높이 다시 맞춤 */
  $(window).on('resize', function () { if (heatListTable) heatListTable.redraw(); });

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
      height: '60vh',
      layout: 'fitDataFill',
      headerSort: false,
      reactiveData: true,
      columnHeaderVertAlign: 'middle',
      rowVertAlign: 'middle',
      headerHozAlign: 'left',
      placeholder: '조회된 데이터가 없습니다.',
      columns: [
        { title:'패턴ID',       field:'recipe_id',     width:100, cssClass:'c-lot' },
        { 
        	  title:'거래처명', 
        	  field:'cust_name', 
        	  width:130, 
        	  hozAlign:'left',
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
        { title:'퀜칭1존(℃)', field:'q1_zone',       width:90,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'퀜칭2존(℃)', field:'q2_zone',       width:90,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'퀜칭3존(℃)', field:'q3_zone',       width:95,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'퀜칭4존(℃)', field:'q4_zone',       width:95,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'퀜칭5존(℃)', field:'q5_zone',       width:90,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'퀜칭속도(Hz)',field:'q_speed',       width:95,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'템퍼1존(℃)', field:'t1_zone',       width:90,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'템퍼2존(℃)', field:'t2_zone',       width:90,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'템퍼3존(℃)', field:'t3_zone',       width:90,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'템퍼4존(℃)', field:'t4_zone',       width:90,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'템퍼5존(℃)', field:'t5_zone',       width:90,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'템퍼속도(Hz)',field:'t_speed',       width:100, hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'CP(%)',        field:'cp',            width:78,  hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'장입기준(kg)',field:'charge_weight', width:105, hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
        { title:'퀜칭요구경도',field:'quench_high',   width:105, hozAlign:'right', headerHozAlign:'right', cssClass:'ht-num c-num' },
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
