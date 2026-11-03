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
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">

  <style>
    /* ===================== Design System ===================== */
    :root{
      --bg:#f0f2f7;
      --surface:#ffffff;
      --surface2:#f7f8fc;
      --border:#e2e6ef;
      --text-p:#0f172a;
      --text-s:#64748b;
      --text-m:#94a3b8;
      --accent:#2563eb;
      --green:#16a34a;
      --red:#dc2626;
      --shadow-sm:0 1px 3px rgba(0,0,0,.06);
      --shadow-md:0 18px 60px rgba(0,0,0,.22);
      --radius:12px;
      --topbar-h:56px;
    }

    *{ box-sizing:border-box; margin:0; padding:0; }
    body{
      font-family:'Noto Sans KR',sans-serif;
      background:var(--bg);
      color:var(--text-p);
    }

    /* ===================== TOPBAR ===================== */
    .topbar{
      position:sticky; top:0; z-index:200;
      background:rgba(255,255,255,.92);
      backdrop-filter: blur(12px);
      border-bottom:1px solid var(--border);
      box-shadow:var(--shadow-sm);
    }
    .topbar-inner{
      max-width:1600px;
      margin:0 auto;
      height:var(--topbar-h);
      padding:0 20px;
      display:flex;
      align-items:center;
      gap:10px;
      flex-wrap:wrap;
    }
    .topbar-title{
      font-size:14px;
      font-weight:900;
      letter-spacing:-.3px;
      display:flex;
      align-items:center;
      gap:8px;
      white-space:nowrap;
      margin-right:6px;
    }
    .divider{ width:1px; height:20px; background:var(--border); flex-shrink:0; }
    .label{
      font-size:12px;
      font-weight:800;
      color:var(--text-s);
      white-space:nowrap;
    }

    .ctrl{
      height:34px;
      padding:0 10px;
      border:1px solid var(--border);
      border-radius:10px;
      background:var(--surface2);
      color:var(--text-p);
      font-size:13px;
      outline:none;
      transition:border-color .15s, box-shadow .15s, background .15s;
    }
    .ctrl:focus{
      border-color:var(--accent);
      box-shadow:0 0 0 3px rgba(37,99,235,.14);
      background:#fff;
    }

    .btn{
      height:34px;
      padding:0 14px;
      border-radius:10px;
      font-size:12px;
      font-weight:900;
      display:inline-flex;
      align-items:center;
      gap:7px;
      cursor:pointer;
      border:1px solid transparent;
      transition: transform .08s, filter .15s;
      white-space:nowrap;
      user-select:none;
    }
    .btn:active{ transform:translateY(1px); }
    .btn:hover{ filter:brightness(1.06); }
    .btn img{ width:16px; height:16px; }

    .btn-search{ background:linear-gradient(135deg,#64748b,#475569); color:#fff; border-color:#475569; }
    .btn-insert{ background:linear-gradient(135deg,#2563eb,#1d4ed8); color:#fff; border-color:#1d4ed8; }
    .btn-delete{ background:var(--surface); color:var(--red); border-color:var(--border); }
    .btn-delete:hover{ background:#fff5f5; }

    /* ===================== PAGE WRAP ===================== */
    .page-wrap{
      max-width:1600px;
      margin:0 auto;
      padding:16px 20px 24px;
      display:flex;
      flex-direction:column;
      gap:12px;
    }

    .card{
      background:var(--surface);
      border:1px solid var(--border);
      border-radius:var(--radius);
      box-shadow:var(--shadow-sm);
      overflow:hidden;
    }
    .card-header{
      padding:12px 16px;
      border-bottom:1px solid var(--border);
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:10px;
    }
    .card-title{
      font-size:13px;
      font-weight:900;
      color:var(--text-p);
      letter-spacing:-.2px;
    }
    .card-meta{
      font-size:12px;
      color:var(--text-m);
      font-family:'JetBrains Mono', monospace;
    }

    /* ===================== TABULATOR OVERRIDE ===================== */
    #dataTable{ padding:10px; }
    .tabulator{ border:none !important; font-size:13px !important; }
    .tabulator .tabulator-header{
      background:var(--surface2) !important;
      border-bottom:1px solid var(--border) !important;
      color:var(--text-s) !important;
      font-weight:800 !important;
    }
    .tabulator-row:hover{ background:#f8faff !important; }
    .row_select{
      background:#eff6ff !important;
      border-left:4px solid var(--accent) !important;
    }

    /* ===================== MODAL ===================== */
    .modal{
      display:none;
      position:fixed;
      inset:0;
      background:rgba(15,23,42,.55);
      backdrop-filter: blur(5px);
      z-index:9999;
      align-items:center;
      justify-content:center;
      padding:18px;
    }
    .modal.show{ display:flex; }

    .modal-content{
      width:520px;
      max-width:95vw;
      max-height:90vh;
      overflow:auto;
      background:var(--surface);
      border:1px solid var(--border);
      border-radius:16px;
      box-shadow:var(--shadow-md);
      padding:22px 20px 18px;
      position:relative;
      animation: pop .18s ease;
    }
    @keyframes pop{
      from{ opacity:0; transform:translateY(10px) scale(.98); }
      to{ opacity:1; transform:none; }
    }

    .modal-title{
      font-size:16px;
      font-weight:900;
      color:var(--text-p);
      margin-bottom:14px;
      display:flex;
      align-items:center;
      gap:10px;
    }
    .modal-title:before{
      content:"";
      width:4px; height:18px;
      border-radius:4px;
      background:var(--accent);
      display:inline-block;
    }

    .close{
      position:absolute;
      right:14px; top:12px;
      width:32px; height:32px;
      border-radius:10px;
      border:1px solid var(--border);
      background:var(--surface2);
      color:var(--text-s);
      cursor:pointer;
      display:flex;
      align-items:center;
      justify-content:center;
      font-size:18px;
      font-weight:900;
      transition:filter .15s;
    }
    .close:hover{ filter:brightness(1.05); }

    .form-grid{
      display:grid;
      grid-template-columns: 1fr 1fr;
      gap:12px 12px;
    }
    .form-group{ display:flex; flex-direction:column; gap:6px; }
    .form-group.full{ grid-column:1 / -1; }

    .form-label{
      font-size:12px;
      font-weight:800;
      color:var(--text-s);
    }
    .form-input, .form-select{
      height:38px;
      padding:0 12px;
      border:1px solid var(--border);
      border-radius:10px;
      background:var(--surface2);
      font-size:13px;
      outline:none;
      transition:border-color .15s, box-shadow .15s, background .15s;
    }
    .form-input:focus, .form-select:focus{
      border-color:var(--accent);
      box-shadow:0 0 0 3px rgba(37,99,235,.14);
      background:#fff;
    }

    .modal-btns{
      display:flex;
      gap:10px;
      margin-top:16px;
    }
    .modal-btns .btn{
      flex:1;
      height:40px;
      justify-content:center;
      border-radius:12px;
      font-size:13px;
    }
    .btn-save{ background:linear-gradient(135deg,#2563eb,#1d4ed8); color:#fff; border-color:#1d4ed8; }
    .btn-close{ background:var(--surface2); color:var(--text-p); border-color:var(--border); }

    /* ===================== Responsive ===================== */
    @media (max-width: 900px){
      .topbar-inner{ height:auto; padding:10px 14px; }
      .page-wrap{ padding:12px 14px 18px; }
      .form-grid{ grid-template-columns: 1fr; }
    }
  </style>
</head>

<body>

  <!-- ===================== TOPBAR ===================== -->
  <div class="topbar">
    <div class="topbar-inner">
      <div class="topbar-title">👤 사용자 등록/관리</div>
      <div class="divider"></div>

      <span class="label">입사 연도</span>
      <input type="text" autocomplete="off" class="ctrl yearSet" id="startDate" style="width:140px; text-align:center;" placeholder="YYYY">

      <span class="label" style="margin-left:6px;">성명</span>
      <input type="text" id="user_name" class="ctrl" style="width:180px; text-align:center;" placeholder="이름 입력">

      <div class="divider"></div>

      <button class="btn btn-search select-button">
        <img src="/line/css/tabBar/search-icon.png" alt="select">조회
      </button>
      <button class="btn btn-insert insert-button">
        <img src="/line/css/tabBar/add-outline.png" alt="insert">추가
      </button>
      <button class="btn btn-delete delete-button">
        <img src="/line/css/tabBar/xDel3.png" alt="delete">삭제
      </button>

      <div style="margin-left:auto; display:flex; align-items:center; gap:10px;">
        <span class="label" id="footer-info" style="font-family:'JetBrains Mono',monospace; color:var(--text-m);">-</span>
      </div>
    </div>
  </div>

  <!-- ===================== PAGE ===================== -->
  <div class="page-wrap">
    <div class="card">
      <div class="card-header">
        <div class="card-title">사용자 목록</div>
        <div class="card-meta">Double Click : 수정</div>
      </div>
      <div id="dataTable"></div>
    </div>
  </div>

  <!-- ===================== MODAL ===================== -->
  <div id="modalContainer" class="modal">
    <div class="modal-content">
      <button class="close" type="button" aria-label="닫기">&times;</button>

      <div class="modal-title">사용자 등록/수정</div>

      <form id="corrForm" autocomplete="off">
        <input type="hidden" name="user_code">

        <div class="form-grid">
          <div class="form-group">
            <label class="form-label">ID</label>
            <input type="text" name="user_id" class="form-input" placeholder="아이디">
          </div>

          <div class="form-group">
            <label class="form-label">PassWord</label>
            <input type="text" name="user_pw" class="form-input" placeholder="비밀번호">
          </div>

          <div class="form-group">
            <label class="form-label">성명</label>
            <input type="text" name="user_name" class="form-input" placeholder="이름">
          </div>

          <div class="form-group">
            <label class="form-label">입사일</label>
            <input type="text" name="st_day" class="form-input daySet" placeholder="YYYY-MM-DD" style="text-align:left;">
          </div>

          <div class="form-group">
            <label class="form-label">전화번호</label>
            <input type="text" name="user_phone" class="form-input" placeholder="010-0000-0000">
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

        <div class="modal-btns">
          <button type="submit" id="saveCorrStatus" class="btn btn-save">저장</button>
          <button type="button" id="closeModal" class="btn btn-close">닫기</button>
        </div>
      </form>
    </div>
  </div>

  <!-- ===================== SCRIPT ===================== -->
  <script>
    let now_page_code = "a01";
    var dataTable;
    var selectedRowData = null;

    $(function () {

      // ✅ Tabulator
      dataTable = new Tabulator('#dataTable', {
        height: "705px",
        layout: "fitColumns",
        headerHozAlign: "center",
        ajaxConfig: { method: 'POST' },
        ajaxLoader: false,
        ajaxURL: "/line/user/userInsert/select",
        ajaxParams: {},
        placeholder: "조회된 데이터가 없습니다.",
        ajaxResponse: function (url, params, response) {
          // footer count
          try{
            const cnt = Array.isArray(response) ? response.length : (response?.data?.length || 0);
            $("#footer-info").text((cnt || 0) + " rows");
          }catch(e){}
          return response;
        },
        columns: [
          { title: "NO", formatter: "rownum", hozAlign: "center", width: 70 },

          { title: "user_code", field: "user_code", width: 240, hozAlign: "center", visible: false },

          { title: "아이디", field: "user_id", width: 170, hozAlign: "center", headerFilter: "input" },
          { title: "비밀번호", field: "user_pw", width: 170, hozAlign: "center", visible: false },
          { title: "성명", field: "user_name", width: 170, hozAlign: "center", headerFilter: "input" },
          { title: "입사일", field: "st_day", width: 200, hozAlign: "center", headerFilter: "input" },
          { title: "전화번호", field: "user_phone", width: 170, hozAlign: "center", headerFilter: "input" },
          { title: "등급", field: "user_level", width: 150, hozAlign: "center", headerFilter: "input" },
          { title: "부서", field: "user_busu", width: 300, hozAlign: "left", headerFilter: "input" },
          { title: "직책", field: "user_jick", width: 300, hozAlign: "left", headerFilter: "input" }
        ],

        rowClick: function (e, row) {
          $('#dataTable .tabulator-row').removeClass('row_select');
          row.getElement().classList.add('row_select');
          selectedRowData = row.getData();
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