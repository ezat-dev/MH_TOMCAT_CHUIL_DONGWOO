<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>사용자 권한부여</title>

  <%@include file="../include/pluginpage.jsp" %>
  <jsp:include page="../include/tabBar.jsp"/>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
  <link rel="stylesheet" href="/line/css/opsList/ops-list.css">
  <link rel="stylesheet" href="/line/css/opsList/ops-user.css">
</head>

<body class="ops fit">

  <!-- ===== 헤더 + 툴바 ===== -->
  <header class="ops-head">
    <div class="ops-head-in">
      <h1 class="ops-title">사용자 권한부여</h1>

      <!-- 선택 사용자 표시 -->
      <span class="ops-sel" id="selectedUserBox"><i></i><span id="selectedUserName">사용자를 선택하세요</span></span>

      <span class="ops-spacer"></span>

      <button class="ops-btn allNo">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><line x1="5.6" y1="5.6" x2="18.4" y2="18.4"/></svg>전체없음
      </button>
      <button class="ops-btn allUpdate" title="모든 메뉴를 최고 권한으로 바꾸고 바로 저장합니다">
        <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>최고권한 적용
      </button>
      <button class="ops-btn danger clearAut">
        <svg viewBox="0 0 24 24"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>초기화
      </button>
      <button class="ops-btn primary saveAut">
        <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/></svg>저장
      </button>
    </div>
  </header>

  <!-- ===== PAGE ===== -->
  <main class="ops-page">
    <div class="perm-layout">

      <!-- 사용자 목록 -->
      <section class="ops-card grow">
        <div class="ops-card-head">
          <h2>사용자 목록</h2>
          <span class="note">행을 눌러 사용자 선택</span>
        </div>
        <div id="dataList" class="ops-table"></div>
        <div class="ops-card-foot">
          <span id="perm-user-count">-</span>
          <span>선택 <strong id="perm-user-id">-</strong></span>
        </div>
      </section>

      <!-- 권한 설정 -->
      <section class="ops-card grow">
        <div class="ops-card-head">
          <h2>메뉴 권한 설정</h2>
          <span class="perm-legend">
            <span class="n"><i></i>N 없음</span><span class="r"><i></i>R 조회</span><span class="i"><i></i>I 저장</span>
            <span class="u"><i></i>U 수정</span><span class="d"><i></i>D 삭제</span>
          </span>
        </div>

        <form id="permissionForm" class="perm-scroll">
          <input type="hidden" id="user_code" name="user_code">

          <div class="perm-grid">

          <!-- ① 기준정보 -->
          <div class="perm-section">
            <div class="perm-section-head"><span class="dot dot-a"></span>기준정보</div>
            <div class="perm-section-body">
              <div class="perm-row"><span class="perm-label">사용자관리</span>
                <select id="a01" name="a01" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">거래처관리</span>
                <select id="a02" name="a02" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">제품관리</span>
                <select id="a03" name="a03" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">패턴관리</span>
                <select id="a04" name="a04" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">사용자권한</span>
                <select id="a05" name="a05" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">로그인 이력</span>
                <select id="a06" name="a06" class="perm-select"><option value="N">없음</option><option value="R">조회</option></select>
              </div>
            </div>
          </div>

          <!-- ② 모니터링 -->
          <div class="perm-section">
            <div class="perm-section-head"><span class="dot dot-b"></span>모니터링</div>
            <div class="perm-section-body">
              <div class="perm-row"><span class="perm-label">통합모니터링</span>
                <select id="b01" name="b01" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">알람이력</span>
                <select id="b02" name="b02" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">알람랭킹</span>
                <select id="b03" name="b03" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">온도경향감시</span>
                <select id="b04" name="b04" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">LOT현황</span>
                <select id="b05" name="b05" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">LOT트레킹</span>
                <select id="b06" name="b06" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
            </div>
          </div>

          <!-- ③ 생산관리 -->
          <div class="perm-section">
            <div class="perm-section-head"><span class="dot dot-c"></span>생산관리</div>
            <div class="perm-section-body">
              <div class="perm-row"><span class="perm-label">작업지시관리</span>
                <select id="c01" name="c01" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">종합생산현황</span>
                <select id="c02" name="c02" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">설비효율현황</span>
                <select id="c03" name="c03" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">제품별작업관리</span>
                <select id="c04" name="c04" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">수리이력관리</span>
                <select id="c05" name="c05" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">작업일보</span>
                <select id="c06" name="c06" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">LOT보고서</span>
                <select id="c07" name="c07" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
            </div>
          </div>

          <!-- ④ 조건관리 -->
          <div class="perm-section">
            <div class="perm-section-head"><span class="dot dot-d"></span>조건관리</div>
            <div class="perm-section-body">
              <div class="perm-row"><span class="perm-label">열전대교체이력</span>
                <select id="d01" name="d01" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">온도조절계보정</span>
                <select id="d02" name="d02" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">열처리유성상분석</span>
                <select id="d03" name="d03" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">일상점검일지</span>
                <select id="d04" name="d04" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">관리계획서</span>
                <select id="d05" name="d05" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
            </div>
          </div>

          <!-- ⑤ 품질관리 -->
          <div class="perm-section">
            <div class="perm-section-head"><span class="dot dot-e"></span>품질관리</div>
            <div class="perm-section-body">
              <div class="perm-row"><span class="perm-label">Cpk 분석</span>
                <select id="e01" name="e01" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">Ppk 분석</span>
                <select id="e02" name="e02" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">E/PROOF</span>
                <select id="e03" name="e03" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">온도균일성조사</span>
                <select id="e04" name="e04" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">낙하품 관리</span>
                <select id="e05" name="e05" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">경도 관리</span>
                <select id="e06" name="e06" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">부적합품 관리</span>
                <select id="e07" name="e07" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
            </div>
          </div>

          <!-- ⑥ 설비관리 -->
          <div class="perm-section">
            <div class="perm-section-head"><span class="dot dot-f"></span>설비관리</div>
            <div class="perm-section-body">
              <div class="perm-row"><span class="perm-label">설비비가동현황</span>
                <select id="f01" name="f01" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">SPARE부품관리</span>
                <select id="f02" name="f02" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">설비이력관리</span>
                <select id="f03" name="f03" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
              <div class="perm-row"><span class="perm-label">설비 가동률 분석</span>
                <select id="f04" name="f04" class="perm-select"><option value="N">없음</option><option value="R">조회</option><option value="I">저장</option><option value="U">수정</option><option value="D">삭제</option></select>
              </div>
            </div>
          </div>

          </div><!-- /.perm-grid -->
        </form>
        <div class="ops-card-foot">
          <span>메뉴 <strong id="perm-menu-count">-</strong>개 · 권한 있음 <strong id="perm-on-count">-</strong>개</span>
          <span>최고권한 적용은 즉시 저장됩니다</span>
        </div>
      </section>

    </div>
  </main>

  <!-- ===== SCRIPT ===== -->
  <script>
    let now_page_code = "a05";

    /* select 값 변경 시 색상 갱신 */
    function refreshSelectColor(sel) {
      if (!sel) return;
      sel.setAttribute('data-val', sel.value);
      updatePermCount();
    }

    /* 데모: 권한 있음 개수 (표시 전용) */
    function updatePermCount() {
      var all = document.querySelectorAll('.perm-select'), on = 0;
      all.forEach(function (s) { if (s.value !== 'N') on++; });
      var m = document.getElementById('perm-menu-count'), o = document.getElementById('perm-on-count');
      if (m) m.textContent = all.length;
      if (o) o.textContent = on;
    }

    document.querySelectorAll('.perm-select').forEach(function(sel) {
      refreshSelectColor(sel);
      sel.addEventListener('change', function() { refreshSelectColor(this); });
    });

    $(function () {
      var userTable;

      getAllUserList();

      /* ── 전체없음 ── */
      $(document).on('click', '.allNo', function () {
        $('.perm-select').val('N').each(function(){ refreshSelectColor(this); });
      });

      /* ── 최고권한 ── */
      $(document).on('click', '.allUpdate', function () {
        if (!$('#user_code').val()) { alert('사용자를 먼저 선택하세요.'); return; }

        $('.perm-select').each(function () {
          const hasD = $(this).find('option[value="D"]').length > 0;
          $(this).val(hasD ? 'D' : 'R');
          refreshSelectColor(this);
        });

        var formData = new FormData($('#permissionForm')[0]);
        $.ajax({
          url: '/line/user/userPermission/update',
          type: 'POST', data: formData, processData: false, contentType: false,
          success: function () { alert('최고권한이 적용되었습니다.'); },
          error: function (xhr) { alert('수정 중 오류가 발생했습니다.'); console.error(xhr.responseText); }
        });
      });

      /* ── 저장 ── */
      $(document).on('click', '.saveAut', function () {
        if (!$('#user_code').val()) { alert('사용자를 먼저 선택하세요.'); return; }

        var formData = new FormData($('#permissionForm')[0]);
        $.ajax({
          url: '/line/user/userPermission/update',
          type: 'POST', data: formData, processData: false, contentType: false,
          success: function () { alert('권한이 수정되었습니다.'); },
          error: function (xhr) { alert('수정 중 오류가 발생했습니다.'); console.error(xhr.responseText); }
        });
      });

      /* ── 초기화 ── */
      $(document).on('click', '.clearAut', function () {
        $('#permissionForm')[0].reset();
        $('.perm-select').each(function(){ refreshSelectColor(this); });
      });

      /* ── 사용자 목록 Tabulator ── */
      function getAllUserList() {
        userTable = new Tabulator('#dataList', {
          height: '100%',
          layout: 'fitColumns',
          reactiveData: true,
          ajaxConfig: { method: 'POST' },
          ajaxLoader: false,
          ajaxURL: '/line/user/userPermission/userSelect',
          ajaxResponse: function (url, params, response) {
            $('#perm-user-count').html('총 <strong>' + ((response.data || []).length) + '</strong>명');
            return response.data;
          },
          placeholder: '조회된 데이터가 없습니다.',
          headerHozAlign: 'left',
          columns: [
            { title: '#',        field: 'idx',      width: 64,  hozAlign: 'right', headerHozAlign: 'right', cssClass: 'c-mono' },
            { title: '아이디',   field: 'user_id',   widthGrow: 3, hozAlign: 'left', cssClass: 'c-mono c-strong' },
            { title: '성명',     field: 'user_name', widthGrow: 2, hozAlign: 'left', cssClass: 'c-strong' },
            { title: '부서',     field: 'user_busu', widthGrow: 2, hozAlign: 'left' },
            { title: '직책',     field: 'user_jick', widthGrow: 2, hozAlign: 'left' },
            { title: 'user_code',field: 'user_code', visible: false }
          ],
          rowClick: function (e, row) {
            var data = row.getData();
            $('#user_code').val(data.user_code);
            $('#selectedUserName').text(data.user_name + ' (' + (data.user_busu || '-') + ')');
            $('#selectedUserBox').addClass('on');
            $('#perm-user-id').text(data.user_id || '-');

            userTable.getRows().forEach(function(r){ r.getElement().classList.remove('row_select'); });
            row.getElement().classList.add('row_select');

            getPermissionUserSelectPermission(data.user_code);
          }
        });
      }

      /* ── 권한 로드 ── */
      function getPermissionUserSelectPermission(code) {
        if (!code) code = $('#user_code').val();
        $.post(
          '/line/user/userPermission/userSelectPermission',
          { user_code: code },
          function (result) {
            var data = result.data || {};
            for (var key in data) {
              var val = data[key];
              var $sel = $('[name="' + key + '"]');
              if (!$sel.length) continue;
              if (val === "D" && $sel.find("option[value=\"D\"]").length === 0) val = "R";
              $sel.val(val);
              if ($sel[0]) refreshSelectColor($sel[0]);
            }
          },
          'json'
        );
      }
    });
  </script>
</body>
</html>
