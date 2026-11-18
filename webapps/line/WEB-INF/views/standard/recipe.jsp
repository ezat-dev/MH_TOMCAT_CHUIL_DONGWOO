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
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
  <link rel="stylesheet" href="/line/css/opsList/ops-list.css">
  <link rel="stylesheet" href="/line/css/standard/master.css">
  <style>
    /* 패턴 표: 소입/소려 그룹 머리 */
    .mst .ops-table .tabulator-col.tabulator-col-group > .tabulator-col-content { padding: 4px 8px !important; }
    .mst .ops-table .tabulator-col-group .tabulator-col-title { text-align: center; }
  </style>
</head>
<body class="ops mst">

  <!-- ===== 헤더 + 툴바 ===== -->
  <header class="ops-head">
    <div class="ops-head-in">
      <h1 class="ops-title">패턴 관리</h1>
      <span class="ops-label">품번</span>
      <input type="text" id="search_item_no"   class="ops-input mono" style="width:140px;" placeholder="품번">
      <span class="ops-label">품명</span>
      <input type="text" id="search_item_name" class="ops-input" style="width:160px;" placeholder="품명">
      <span class="ops-label">거래처명</span>
      <input type="text" id="search_cust_name" class="ops-input" style="width:140px;" placeholder="거래처명">
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
        <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>패턴 등록
      </button>
    </div>
  </header>

  <!-- ===== 목록 ===== -->
  <main class="ops-page">
    <section class="ops-card">
      <div class="ops-card-head">
        <h2>패턴 목록</h2>
        <span class="note">온도 ℃ · 속도 · CP · 장입량 kg · 행을 두 번 눌러 수정</span>
      </div>
      <div id="dataList" class="ops-table"></div>
      <div class="ops-card-foot">
        <span>총 <strong id="footer-info">0</strong>건</span>
        <span class="hint">Esc 로 입력창 닫기</span>
      </div>
    </section>
  </main>

  <!-- ===== 패턴 등록/수정 모달 ===== -->
  <div id="modalContainer" class="modal-overlay">
    <div class="modal-box" role="dialog" aria-labelledby="modalTitleText" style="width:720px;">
      <div class="modal-head">
        <div class="ttl">
          <h2 id="modalTitleText">패턴 등록</h2>
          <span class="sub" id="modalSubtitle">신규 레시피 패턴을 추가합니다</span>
        </div>
        <button class="modal-close close" type="button" aria-label="닫기">&times;</button>
      </div>

      <form id="corrForm" autocomplete="off">
        <input type="hidden" name="recipe_id">

        <div class="modal-body">
          <!-- 기본 정보 -->
          <div class="form-sec">
            <h3 class="form-sec-title">기본 정보</h3>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label" for="recipe_code">패턴 코드 <small>자동 생성</small></label>
                <input type="text" id="recipe_code" name="recipe_code" class="form-input mono" placeholder="자동 생성" readonly>
              </div>
              <div class="form-group">
                <label class="form-label" for="charge_weight">장입량<span class="req">*</span> <small>kg</small></label>
                <input type="number" id="charge_weight" name="charge_weight" class="form-input" value="0">
              </div>
              <div class="form-group">
                <label class="form-label" for="item_name">품번<span class="req">*</span></label>
                <select id="item_name" name="item_name" class="form-select">
                  <option value="">선택하세요</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label" for="prod_code">제품코드 <small>품번 선택 시 자동 입력</small></label>
                <input type="text" id="prod_code" name="prod_code" class="form-input mono" placeholder="—" readonly>
              </div>
            </div>
          </div>

          <!-- 소입로 (퀜칭) -->
          <div class="form-sec">
            <h3 class="form-sec-title">퀜칭로 <small>온도 ℃</small></h3>
            <div class="zone-grid">
              <div class="form-group"><label class="form-label">1존</label><input type="number" name="q1_temp" class="form-input q-input" value="0"></div>
              <div class="form-group"><label class="form-label">2존</label><input type="number" name="q2_temp" class="form-input q-input" value="0"></div>
              <div class="form-group"><label class="form-label">3존</label><input type="number" name="q3_temp" class="form-input q-input" value="0"></div>
              <div class="form-group"><label class="form-label">4존</label><input type="number" name="q4_temp" class="form-input q-input" value="0"></div>
              <div class="form-group"><label class="form-label">5존</label><input type="number" name="q5_temp" class="form-input q-input" value="0"></div>
              <div class="form-group"><label class="form-label">속도</label><input type="number" name="q_speed" class="form-input q-input" value="0"></div>
              <div class="form-group"><label class="form-label">CP</label><input type="number" name="cp" class="form-input q-input" value="0"></div>
            </div>
          </div>

          <!-- 템퍼링 -->
          <div class="form-sec">
            <h3 class="form-sec-title">템퍼링 <small>온도 ℃</small></h3>
            <div class="zone-grid">
              <div class="form-group"><label class="form-label">1존</label><input type="number" name="t1_zone" class="form-input t-input" value="0"></div>
              <div class="form-group"><label class="form-label">2존</label><input type="number" name="t2_zone" class="form-input t-input" value="0"></div>
              <div class="form-group"><label class="form-label">3존</label><input type="number" name="t3_zone" class="form-input t-input" value="0"></div>
              <div class="form-group"><label class="form-label">4존</label><input type="number" name="t4_zone" class="form-input t-input" value="0"></div>
              <div class="form-group"><label class="form-label">5존</label><input type="number" name="t5_zone" class="form-input t-input" value="0"></div>
              <div class="form-group"><label class="form-label">속도</label><input type="number" name="c_speed" class="form-input t-input" value="0"></div>
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
      if (v === null || v === undefined || v === '') return '<span class="temp-none">—</span>';
      return '<span class="temp-val">' + v + '</span>';
    }

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
        placeholder: '조회된 데이터가 없습니다.', headerHozAlign: 'left', headerFilterPlaceholder: '필터',
        columns: [
          { title:'NO',        formatter:'rownum', width:52, hozAlign:'right', headerHozAlign:'right', headerSort:false, cssClass:'c-mono c-dim' },
          { title:'레시피ID',  field:'recipe_id',  width:90, hozAlign:'center', cssClass:'hidden-column', headerFilter:'input' },
          { title:'거래처코드',field:'cust_code',  width:110,hozAlign:'center', cssClass:'hidden-column' },
          { title:'레시피코드',field:'recipe_code',width:110,hozAlign:'center', cssClass:'hidden-column' },
          { title:'제품코드',  field:'prod_code',  width:110,hozAlign:'center', cssClass:'hidden-column' },
          { title:'거래처명',  field:'cust_name',  width:140,hozAlign:'left',  headerFilter:'input' },
          { title:'품번',      field:'item_no',    width:160,hozAlign:'left',  headerFilter:'input', cssClass:'c-mono' },
          { title:'품명',      field:'item_name',  minWidth:190,hozAlign:'left',  headerFilter:'input', cssClass:'c-strong' },
          { title:'규격',      field:'spec',       width:120,hozAlign:'left',  headerFilter:'input', cssClass:'c-mono' },
          { title:'재질',      field:'texture',    width:110,hozAlign:'left',  headerFilter:'input', cssClass:'c-mono' },
          {
            title:'심부경도', field:'temper_low', width:100, hozAlign:'right', headerHozAlign:'right', headerFilter:'input',
            formatter: function(cell) {
              const d = cell.getRow().getData();
              const lo = d.temper_low ?? '', hi = d.temper_high ?? '';
              if (lo==='' && hi==='') return '<span class="temp-none">—</span>';
              return '<span class="temp-val">' + lo + '–' + hi + '</span>';
            }
          },
          { title:'장입량', field:'charge_weight', width:84, hozAlign:'right', headerHozAlign:'right', headerFilter:'input', cssClass:'c-mono' },
          {
            title:'퀜칭로',
            columns: [
              { title:'1존', field:'q1_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'2존', field:'q2_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'3존', field:'q3_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'4존', field:'q4_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'5존', field:'q5_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'속도', field:'q_speed', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter }
            ]
          },
          { title:'CP', field:'cp', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
          {
            title:'템퍼링',
            columns: [
              { title:'1존', field:'t1_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'2존', field:'t2_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'3존', field:'t3_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'4존', field:'t4_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'5존', field:'t5_zone', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter },
              { title:'속도', field:'t_speed', width:58, hozAlign:'right', headerHozAlign:'right', headerSort:false, formatter:tempFormatter }
            ]
          },
          { title:'등록일', field:'reg_date', width:160, hozAlign:'left', headerFilter:'input', cssClass:'c-mono c-dim' }
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
            $('#footer-info').text(data.data.length || 0);
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
