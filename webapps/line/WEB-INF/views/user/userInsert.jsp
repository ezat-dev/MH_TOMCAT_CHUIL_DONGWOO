<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>사용자 등록</title>

  <%@include file="../include/pluginpage.jsp" %>
  <jsp:include page="../include/tabBar.jsp"/>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
  <link rel="stylesheet" href="/line/css/opsList/ops-list.css">
  <link rel="stylesheet" href="/line/css/opsList/ops-user.css">
</head>

<body class="ops fit">

  <!-- ===================== 헤더 + 툴바 ===================== -->
  <header class="ops-head">
    <div class="ops-head-in">
      <h1 class="ops-title">사용자 관리</h1>

      <span class="ops-label">입사 연도</span>
      <input type="text" autocomplete="off" class="ops-input yearSet" id="startDate" style="width:96px; min-width:0;" placeholder="YYYY">

      <span class="ops-label">성명</span>
      <input type="text" id="user_name" class="ops-input" style="font-family:var(--ops-sans);" placeholder="이름 입력">

      <button class="ops-btn select-button">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16" y2="16"/></svg>조회
      </button>

      <span class="ops-spacer"></span>

      <button class="ops-btn danger delete-button">
        <svg viewBox="0 0 24 24"><polyline points="4 7 20 7"/><path d="M9 7V4h6v3"/><path d="M6 7l1 13h10l1-13"/></svg>삭제
      </button>
      <button class="ops-btn primary insert-button">
        <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>사용자 추가
      </button>
    </div>
  </header>

  <!-- ===================== PAGE ===================== -->
  <main class="ops-page">

    <section class="ops-kpi k4" aria-label="요약">
      <div class="hero">
        <span class="kpi-label">등록 사용자</span>
        <span class="kpi-value" id="kpi-total">-</span>
        <span class="kpi-sub">조회 조건 기준</span>
      </div>
      <div>
        <span class="kpi-label">부서</span>
        <span class="kpi-value" id="kpi-busu">-</span>
        <span class="kpi-sub">고유 부서 수</span>
      </div>
      <div>
        <span class="kpi-label">올해 입사</span>
        <span class="kpi-value" id="kpi-year">-</span>
        <span class="kpi-sub" id="kpi-year-sub">입사일 기준</span>
      </div>
      <div>
        <span class="kpi-label">최근 입사일</span>
        <span class="kpi-value" id="kpi-last">-</span>
        <span class="kpi-sub" id="kpi-last-sub">&nbsp;</span>
      </div>
    </section>

    <section class="ops-card grow">
      <div class="ops-card-head">
        <h2>사용자 목록</h2>
        <span class="note">행 클릭 선택 · 더블클릭 수정 · 열 머리 입력칸으로 필터</span>
      </div>
      <div id="dataTable" class="ops-table"></div>
      <div class="ops-card-foot">
        <span id="footer-info">-</span>
        <span>선택 <strong id="footer-sel">-</strong></span>
      </div>
    </section>

  </main>

  <!-- ===================== MODAL ===================== -->
  <div id="modalContainer" class="modal">
    <div class="modal-content" role="dialog" aria-modal="true" aria-labelledby="userModalTitle">
      <button class="close" type="button" aria-label="닫기">&times;</button>

      <div class="modal-title" id="userModalTitle">사용자 등록/수정</div>

      <form id="corrForm" autocomplete="off">
        <input type="hidden" name="user_code">

        <div class="modal-body">
          <div class="form-grid">
            <div class="form-group">
              <label class="form-label">아이디</label>
              <input type="text" name="user_id" class="form-input mono" placeholder="아이디">
            </div>

            <div class="form-group">
              <label class="form-label">비밀번호</label>
              <input type="text" name="user_pw" class="form-input mono" placeholder="비밀번호">
            </div>

            <div class="form-group">
              <label class="form-label">성명</label>
              <input type="text" name="user_name" class="form-input" placeholder="이름">
            </div>

            <div class="form-group">
              <label class="form-label">입사일</label>
              <input type="text" name="st_day" class="form-input mono daySet" placeholder="YYYY-MM-DD" style="text-align:left;">
            </div>

            <div class="form-group">
              <label class="form-label">전화번호</label>
              <input type="text" name="user_phone" class="form-input mono" placeholder="010-0000-0000">
            </div>

            <div class="form-group">
              <label class="form-label">등급</label>
              <select name="user_level" class="form-select">
                <option value="기본">기본</option>
                <!-- 필요하면 추가 -->
                <!-- <option value="관리자">관리자</option> -->
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">부서</label>
              <input type="text" name="user_busu" class="form-input" placeholder="부서">
            </div>

            <div class="form-group">
              <label class="form-label">직책</label>
              <input type="text" name="user_jick" class="form-input" placeholder="직책">
            </div>
          </div>
        </div>

        <div class="modal-btns">
          <button type="button" id="closeModal" class="ops-btn">닫기</button>
          <button type="submit" id="saveCorrStatus" class="ops-btn primary">저장</button>
        </div>
      </form>
    </div>
  </div>

  <!-- ===================== SCRIPT ===================== -->
  <script>
    let now_page_code = "a01";
    var dataTable;
    var selectedRowData = null;

    // 데모: 상단 요약 (표시 전용)
    function renderUserSummary(rows) {
      rows = Array.isArray(rows) ? rows : [];
      var year = String(new Date().getFullYear()), busu = {}, thisYear = 0, last = "";
      rows.forEach(function (r) {
        if (r.user_busu) busu[r.user_busu] = 1;
        var d = String(r.st_day || "");
        if (d.indexOf(year) === 0) thisYear++;
        if (d > last) last = d;
      });
      $("#kpi-total").text(rows.length);
      $("#kpi-busu").text(Object.keys(busu).length);
      $("#kpi-year").text(thisYear);
      $("#kpi-year-sub").text(year + "년 입사일 기준");
      $("#kpi-last").text(last ? last.substr(0, 10) : "-");
      var who = rows.filter(function (r) { return String(r.st_day || "") === last && last; })[0];
      $("#kpi-last-sub").text(who ? who.user_name + " · " + (who.user_busu || "-") : " ");
    }

    $(function () {

      // ✅ Tabulator
      dataTable = new Tabulator('#dataTable', {
        height: "100%",
        layout: "fitColumns",
        headerHozAlign: "left",
        ajaxConfig: { method: 'POST' },
        ajaxLoader: false,
        ajaxURL: "/line/user/userInsert/select",
        ajaxParams: {},
        placeholder: "조회된 데이터가 없습니다.",
        ajaxResponse: function (url, params, response) {
          // footer count
          try{
            const rows = Array.isArray(response) ? response : (response?.data || []);
            $("#footer-info").html("총 <strong>" + (rows.length || 0) + "</strong>명");
            renderUserSummary(rows);
          }catch(e){}
          return response;
        },
        columns: [
          { title: "#", formatter: "rownum", hozAlign: "right", headerHozAlign: "right", width: 56, headerSort: false, cssClass: "c-mono" },

          { title: "user_code", field: "user_code", width: 240, hozAlign: "center", visible: false },

          { title: "아이디", field: "user_id", widthGrow: 2, hozAlign: "left", headerFilter: "input", headerFilterPlaceholder: "필터", cssClass: "c-mono c-strong" },
          { title: "비밀번호", field: "user_pw", width: 170, hozAlign: "center", visible: false },
          { title: "성명", field: "user_name", widthGrow: 2, hozAlign: "left", headerFilter: "input", headerFilterPlaceholder: "필터", cssClass: "c-strong" },
          { title: "입사일", field: "st_day", widthGrow: 2, hozAlign: "left", headerFilter: "input", headerFilterPlaceholder: "필터", cssClass: "c-mono" },
          { title: "전화번호", field: "user_phone", widthGrow: 2, hozAlign: "left", headerFilter: "input", headerFilterPlaceholder: "필터", cssClass: "c-mono" },
          { title: "등급", field: "user_level", widthGrow: 1, hozAlign: "left", headerFilter: "input", headerFilterPlaceholder: "필터" },
          { title: "부서", field: "user_busu", widthGrow: 3, hozAlign: "left", headerFilter: "input", headerFilterPlaceholder: "필터" },
          { title: "직책", field: "user_jick", widthGrow: 3, hozAlign: "left", headerFilter: "input", headerFilterPlaceholder: "필터" }
        ],

        rowClick: function (e, row) {
          $('#dataTable .tabulator-row').removeClass('row_select');
          row.getElement().classList.add('row_select');
          selectedRowData = row.getData();
          $("#footer-sel").text((selectedRowData.user_name || "-") + " (" + (selectedRowData.user_id || "-") + ")");
        },

        rowDblClick: function (e, row) {
          var d = row.getData();
          selectedRowData = d;

          $('#corrForm')[0].reset();
          $('input[name="user_code"]').val(d.user_code || "");
          $('input[name="user_id"]').val(d.user_id || "");
          $('input[name="user_pw"]').val(d.user_pw || "");
          $('input[name="st_day"]').val(d.st_day || "");
          $('input[name="user_phone"]').val(d.user_phone || "");
          $('input[name="user_name"]').val(d.user_name || "");
          $('select[name="user_level"]').val(d.user_level || "기본");
          $('input[name="user_busu"]').val(d.user_busu || "");
          $('input[name="user_jick"]').val(d.user_jick || "");

          openModal();
        }
      });

      // ✅ 조회
      $('.select-button').click(function () {
        var user_name = $('#user_name').val();
        var startDate = $('#startDate').val();

        dataTable.setData("/line/user/userInsert/select", {
          user_name: user_name,
          startDate: startDate
        });
      });

      // ✅ 추가 (Insert 모드)
      $('.insert-button').click(function () {
        selectedRowData = null;
        $('#corrForm')[0].reset();
        $('input[name="user_code"]').val("");
        openModal();
      });

      // ✅ 삭제
      $('.delete-button').click(function () {
        if (!selectedRowData) {
          alert('삭제할 행을 먼저 클릭해 주세요.');
          return;
        }
        if (!confirm('선택된 항목을 정말 삭제하시겠습니까?')) return;

        const deleteData = { user_code: selectedRowData.user_code };

        $.ajax({
          url: "/line/user/userInsert/delete",
          type: "POST",
          contentType: "application/json",
          data: JSON.stringify(deleteData),
          success: function () {
            alert('삭제되었습니다.');
            dataTable.setData("/line/user/userInsert/select", {});
            selectedRowData = null;
            $("#footer-sel").text("-");
          },
          error: function () {
            alert('삭제 중 오류가 발생했습니다.');
          }
        });
      });

      // ✅ 모달 닫기
      $('.close, #closeModal').click(function () {
        closeModal();
      });

      // ✅ 모달 바깥 클릭 닫기


      // ✅ ESC 닫기
      document.addEventListener('keydown', function(e){
        if(e.key === 'Escape') closeModal();
      });

      // ✅ 저장 (insert/update 겸용)
      $('#saveCorrStatus').click(function (event) {
        event.preventDefault();

        var formElement = $('#corrForm')[0];
        var formData = new FormData(formElement);

        var userCode = $('input[name="user_code"]').val();

        // insert 모드: user_code 제거
        if (!selectedRowData || !userCode) {
          formData.delete("user_code");
        } else {
          formData.set("user_code", userCode);
        }

        $.ajax({
          url: "/line/user/userInsert/insert",
          type: "POST",
          data: formData,
          processData: false,
          contentType: false,
          success: function () {
            alert("저장되었습니다!");
            closeModal();
            dataTable.setData("/line/user/userInsert/select", {});
            selectedRowData = null;
          },
          error: function () {
            alert('저장 중 오류가 발생했습니다.');
          }
        });
      });

      function openModal(){
        $('#modalContainer').addClass('show');
      }
      function closeModal(){
        $('#modalContainer').removeClass('show');
      }

    });
  </script>
</body>
</html>
