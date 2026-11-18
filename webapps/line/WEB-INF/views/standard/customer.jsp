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
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
  <link rel="stylesheet" href="/line/css/opsList/ops-list.css">
  <link rel="stylesheet" href="/line/css/standard/master.css">
</head>

<body class="ops mst">

  <!-- ===== 헤더 + 툴바 ===== -->
  <header class="ops-head">
    <div class="ops-head-in">
      <h1 class="ops-title">거래처 관리</h1>
      <button class="ops-btn select-button">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16" y2="16"/></svg>조회
      </button>
      <span class="ops-spacer"></span>
      <button class="ops-btn excel-button">
        <svg viewBox="0 0 24 24"><path d="M12 4v11"/><polyline points="7 10 12 15 17 10"/><line x1="5" y1="20" x2="19" y2="20"/></svg>엑셀 다운로드
      </button>
      <button class="ops-btn danger delete-button">
        <svg viewBox="0 0 24 24"><polyline points="4 7 20 7"/><path d="M18 7l-1 13H7L6 7"/><path d="M9 7V4h6v3"/></svg>삭제
      </button>
      <button class="ops-btn primary insert-button">
        <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>거래처 등록
      </button>
    </div>
  </header>

  <!-- ===== 목록 ===== -->
  <main class="ops-page">
    <section class="ops-card">
      <div class="ops-card-head">
        <h2>거래처 목록</h2>
        <span class="note">행을 눌러 선택 · 두 번 눌러 수정 · 열 머리의 입력칸으로 필터</span>
      </div>
      <div id="dataList" class="ops-table"></div>
      <div class="ops-card-foot">
        <span>총 <strong id="footer-info">0</strong>건</span>
        <span class="hint">Esc 로 입력창 닫기</span>
      </div>
    </section>
  </main>

  <!-- ===== 거래처 등록/수정 모달 ===== -->
  <div id="modalContainer" class="modal-overlay">
    <div class="modal-box" role="dialog" aria-labelledby="modalTitleText">
      <div class="modal-head">
        <div class="ttl">
          <h2 id="modalTitleText">거래처 등록</h2>
          <span class="sub" id="modalSubtitle">신규 거래처를 추가합니다</span>
        </div>
        <button class="modal-close close" type="button" aria-label="닫기">&times;</button>
      </div>

      <form id="corrForm" autocomplete="off">
        <input type="hidden" name="cust_id">

        <div class="modal-body">
          <!-- 기본 정보 -->
          <div class="form-sec">
            <h3 class="form-sec-title">기본 정보</h3>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label" for="cust_name">거래처명<span class="req">*</span></label>
                <input type="text" id="cust_name" name="cust_name" class="form-input" placeholder="거래처명">
              </div>
              <div class="form-group">
                <label class="form-label" for="ceo_name">대표이사</label>
                <input type="text" id="ceo_name" name="ceo_name" class="form-input" placeholder="대표이사명">
              </div>
              <div class="form-group">
                <label class="form-label" for="biz_no">사업자등록번호</label>
                <input type="text" id="biz_no" name="biz_no" class="form-input mono" placeholder="000-00-00000">
              </div>
              <div class="form-group">
                <label class="form-label" for="biz_type">거래처 번호</label>
                <input type="text" id="biz_type" name="biz_type" class="form-input mono" placeholder="010-0000-0000">
              </div>
            </div>
          </div>

          <!-- 상세 정보 -->
          <div class="form-sec">
            <h3 class="form-sec-title">상세 정보</h3>
            <div class="form-grid">
              <div class="form-group full">
                <label class="form-label" for="address">주소</label>
                <input type="text" id="address" name="address" class="form-input" placeholder="서울시 강남구 ...">
              </div>
              <div class="form-group">
                <label class="form-label" for="biz_item">종목</label>
                <input type="text" id="biz_item" name="biz_item" class="form-input" placeholder="예: 자동차 부품">
              </div>
              <div class="form-group">
                <label class="form-label" for="manager_name">담당자명</label>
                <input type="text" id="manager_name" name="manager_name" class="form-input" placeholder="담당자 이름">
              </div>
            </div>
          </div>
        </div>

        <div class="modal-btn-row">
          <button type="button" id="closeModal" class="ops-btn">닫기</button>
          <button type="submit" id="saveCorrStatus" class="ops-btn primary">저장</button>
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

    /* 표 높이를 창 아래 끝까지 맞춤 → 페이지 세로 스크롤 없음, 표 안에서만 스크롤 */
    function fitTable() {
      const el = document.getElementById('dataList');
      if (!dataTable || !el) return;
      const foot = el.nextElementSibling ? el.nextElementSibling.offsetHeight : 0;
      dataTable.setHeight(Math.max(240, Math.floor(window.innerHeight - el.getBoundingClientRect().top - foot - 17)));
    }

    $(document).ready(function () {
      initDataTable();
      fitTable();
      $(window).on('resize', fitTable);
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
        headerHozAlign: 'left',
        headerFilterPlaceholder: '필터',
        columns: [
          { title: 'NO',         formatter: 'rownum',   width: 56,  hozAlign: 'right',  headerHozAlign: 'right', headerSort: false, cssClass: 'c-mono c-dim' },
          { title: '거래처ID',   field: 'cust_id',      width: 88,  hozAlign: 'right',  headerHozAlign: 'right', headerFilter: 'input', cssClass: 'c-mono c-dim' },
          { title: '거래처코드', field: 'cust_code',    width: 120, hozAlign: 'left',   headerFilter: 'input', cssClass: 'c-mono' },
          { title: '거래처명',   field: 'cust_name',    width: 200, hozAlign: 'left',   headerFilter: 'input', cssClass: 'c-strong' },
          { title: '대표이사',   field: 'ceo_name',     width: 120, hozAlign: 'left',   headerFilter: 'input' },
          { title: '사업자번호', field: 'biz_no',       width: 150, hozAlign: 'left',   headerFilter: 'input', cssClass: 'c-mono' },
          { title: '주소',       field: 'address',      minWidth: 250, hozAlign: 'left',   headerFilter: 'input' },
          { title: '거래처번호', field: 'biz_type',     width: 140, hozAlign: 'left',   headerFilter: 'input', cssClass: 'c-mono' },
          { title: '종목',       field: 'biz_item',     width: 110, hozAlign: 'left',   headerFilter: 'input' },
          { title: '담당자',     field: 'manager_name', width: 120, hozAlign: 'left',   headerFilter: 'input' },
          { title: '등록일',     field: 'reg_date',     width: 168, hozAlign: 'left',   headerFilter: 'input', cssClass: 'c-mono c-dim' }
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
            $('#footer-info').text(data.data.length || 0);
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
