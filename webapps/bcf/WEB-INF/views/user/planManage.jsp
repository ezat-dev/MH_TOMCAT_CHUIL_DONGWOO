<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/bcf/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>자격인증관리</title>
<%@include file="../include/pluginpage.jsp" %>    
		<jsp:include page="../include/tabBar.jsp"/>
  <style>
        .container {
            display: flex;
            justify-content: space-between;
            padding: 20px;
            margin-left: 1008px;
            margin-top: 200px;
        }
        .view {
            display: flex;
            justify-content: center;
            margin-top: 1%;
        }
        .tab {
            width: 95%;
            margin-bottom: 37px;
            margin-top: 5px;
            height: 45px;
            border-radius: 6px 6px 0px 0px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .modal {
            display: none;
            position: fixed;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            transition: opacity 0.3s ease-in-out;
        }
	    .modal-content {
	        background: white;
	        width: 24%;
	        max-width: 500px;
	        height: 80vh; 
	        overflow-y: auto; 
	        margin: 6% auto 0;
	        padding: 20px;
	        border-radius: 10px;
	        position: relative;
	        box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.3);
	        transform: scale(0.8);
	        transition: transform 0.3s ease-in-out, opacity 0.3s ease-in-out;
	        opacity: 0;
	    }
  .modal.show {
            display: block;
            opacity: 1;
        }
        .modal.show .modal-content {
            transform: scale(1);
            opacity: 1;
        }

        .close {
            background-color:white;
            position: absolute;
            right: 15px;
            top: 10px;
            font-size: 24px;
            font-weight: bold;
            cursor: pointer;
        }
        .modal-content form {
            display: flex;
            flex-direction: column;
        }
        .modal-content label {
            font-weight: bold;
            margin: 10px 0 5px;
        }
        .modal-content input, .modal-content textarea {
            width: 97%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        select {
            width: 100%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        .modal-content button {
            background-color: #d3d3d3;
            color: black;
            padding: 10px;
            border: none;
            border-radius: 5px;
            margin-top: 10px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .modal-content button:hover {
            background-color: #a9a9a9;
        }
        .button-container {
    		display: flex;
		    gap: 10px;
		    margin-left: auto;
		    margin-right: 10px;
		    margin-top: 40px;
		}
		.box1 {
		    display: flex;
		    justify-content: right;
		    align-items: center;
		    width: 900px;
		    margin-right: 20px;
		    margin-top:4px;
		}
        .dayselect {
            width: 20%;
            text-align: center;
            font-size: 15px;
        }
        .daySet {
        	width: 20%;
      		text-align: center;
            height: 16px;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 15px;
        }
        .daylabel {
            margin-right: 10px;
            margin-bottom: 13px;
            font-size: 18px;
            margin-left: 20px;
        }
        button-container.button{
        height: 16px;
        }
         .mid{
        margin-right: 9px;
	    font-size: 20px;
	    font-weight: bold;
	
	    height: 42px;
	    margin-left: 9px;
        }
        .row_select {
	    background-color: #ffeeba !important;
	    }
    </style>
</head>

<body>

  <main class="main">
    <div class="tab">
      <div class="button-container">
        <div class="box1">
          <p class="tabP" style="font-size: 20px; margin-left: 40px; color: white; font-weight: 800;"></p>

          <label class="daylabel">이름 :</label>
          <input type="text" autocomplete="off" id="name" placeholder="이름 입력" style="font-size:16px;margin-bottom:10px;height:34px;border-radius:5px;border:1px solid #ccc;padding:0 12px;box-sizing:border-box;">

          <label class="daylabel">검색일자 :</label>
          <input type="text" autocomplete="off" class="daySet" id="startDate" style="font-size: 16px; margin-bottom:10px;" placeholder="시작 날짜 선택">

          <span class="mid" style="font-size: 20px; font-weight: bold; margin-bottom:10px;"> ~ </span>

          <input type="text" autocomplete="off" class="daySet" id="endDate" style="font-size: 16px; margin-bottom:10px;" placeholder="종료 날짜 선택">
        </div>

        <button class="select-button">
          <img src="/line/css/tabBar/search-icon.png" alt="select" class="button-image">조회
        </button>
        <button class="insert-button">
          <img src="/line/css/tabBar/add-outline.png" alt="insert" class="button-image">추가
        </button>
        <button class="delete-button">
          <img src="/line/css/tabBar/xDel3.png" alt="delete" class="button-image">삭제
        </button>
        <button class="excel-button">
          <img src="/line/css/tabBar/excel-icon.png" alt="excel" class="button-image">엑셀
        </button>
      </div>
    </div>

    <div class="view">
      <div id="dataTable"></div>
    </div>
  </main>

  <div id="modalContainer" class="modal">
    <div class="modal-content">
      <span class="close">&times;</span>
      <h2>자격인증 관리</h2>
      <form id="corrForm" enctype="multipart/form-data" autocomplete="off">
        <label>자격분류</label>
        <input type="text" name="u_code">

        <label>담당업무</label>
        <input type="text" name="duty" autocomplete="off">

        <label>사번</label>
        <input type="text" name="employee_no">

        <label>성명</label>
        <input type="text" name="name">

        <label>학력</label>
        <input type="text" name="education">
        
        <label>입사일자</label>
        <input type="text" name="start_day"class="datetimeSet">

        <label>경력(년/개월)</label>
        <input type="text" name="career">
        
 

        <label>교육</label>
        <input type="text" name="training">

        <label>자격인정 신청명</label>
        <input type="text" name="cert_name">

        <label>취득일</label>
        <input type="text" name="acquisition_date" class="datetimeSet">

        <label>차기 갱신일</label>
        <input type="text" name="next_date" class="datetimeSet">

        <label>자격인증 평가표 (PDF)</label>
      	<input type="file" id="file_url" name="file_url" accept="application/pdf" multiple>
 		<input type="text" name="file_name" readonly>

        <label>비고</label>
        <textarea name="note" rows="4"></textarea>

        <button type="submit" id="saveCorrStatus">저장</button>
        <button type="button" id="closeModal">닫기</button>
      </form>
    </div>
  </div>

  <script>

  	let now_page_code = "e01";
  
    var dataTable, selectedRowData = null;

    $(function() {



        
  	  $('#file_url').on('change', function() {
		    const fileInput = this;
		    const fileNameInput = $('input[name="file_name"]');

		    if (fileInput.files.length > 0) {
		      const fileName = fileInput.files[0].name;
		      fileNameInput.val(fileName);
		    } else {
		      fileNameInput.val('');
		    }
		  });



        
      // 1) 초기 날짜 세팅 (현재 연도)
      var now = new Date(), year = now.getFullYear();
      $('#startDate').val(year + '-01-01');
      $('#endDate').val(year + '-12-31');

      // 2) Tabulator 초기화
      dataTable = new Tabulator('#dataTable', {
        height: '790px',
        layout: 'fitDataFill',
        headerSort: false,
        reactiveData: true,
        headerHozAlign: 'center',
        ajaxConfig: { method: 'POST' },
        ajaxURL: '/line/user/planManage/list',
        ajaxParams: function() {
        	  const params = {
        	    name: $('#name').val(),
        	    startDate: $('#startDate').val(),
        	    endDate: $('#endDate').val()
        	  };
        	  console.log("📤 Tabulator Ajax Params:", params);
        	  return params;
        	},

        
        placeholder: '조회된 데이터가 없습니다.',
        columns: [
          { title: 'no', field: 'no', visible: false },
          { title: 'NO', formatter: 'rownum', width: 60, hozAlign: 'center' },
          { title: '자격분류(CODE)', field: 'u_code', sorter: 'string', width: 120, hozAlign: 'center' },
          { title: '담당업무', field: 'duty', sorter: 'string', width: 120, hozAlign: 'center' },
          { title: '사번', field: 'employee_no', sorter: 'string', width: 120, hozAlign: 'center' },
          { title: '성명', field: 'name', sorter: 'string', width: 90, hozAlign: 'center' },
          { title: '학력', field: 'education', sorter: 'string', width: 120, hozAlign: 'center' },
          { title: '입사일자', field: 'start_day', sorter: 'string', width: 120, hozAlign: 'center' },
          { title: '경력(년/개월)', field: 'career', sorter: 'string', width: 120, hozAlign: 'center' },
          { title: '교육', field: 'training', sorter: 'string', width: 140, hozAlign: 'center' },
          { title: '자격인정 신청명', field: 'cert_name', sorter: 'string', width: 120, hozAlign: 'center' },
          { title: '취득일', field: 'acquisition_date', sorter: 'string', width: 120, hozAlign: 'center' },
          { 
            title: '차기갱신일', 
            field: 'next_date', 
            sorter: 'string', 
            width: 120, 
            hozAlign: 'center' 
          },
          {
            title: '자격인증평가표',
            field: 'file_name',
            hozAlign: 'center',
            width: 200,
            formatter: function(cell) {
            	  var file = cell.getValue();
            	  var basePath = 'D:\\chunil양식\\자격인증관리\\';
            	  return file
            	    ? '<a href="/line/download?filename=' + encodeURIComponent(basePath + file) + '" target="_blank">' + file + '</a>'
            	    : '';
            	}

          },
          { title: '비고', field: 'note', sorter: 'string', width: 140, hozAlign: 'center' },
        ],

        rowClick: function(e, row) {
          $('#dataTable .tabulator-row').removeClass('row_select');
          row.getElement().classList.add('row_select');
          selectedRowData = row.getData();
        },

        rowDblClick: function(e, row) {
          var d = row.getData();
          selectedRowData = d;
          $('#corrForm')[0].reset();

          // 기존값 세팅
          $('input[name="u_code"]').val(d.u_code);
          $('input[name="duty"]').val(d.duty);
          $('input[name="employee_no"]').val(d.employee_no);
          $('input[name="name"]').val(d.name);
          $('input[name="education"]').val(d.education);
          $('input[name="start_day"]').val(d.start_day);
    
          $('input[name="career"]').val(d.career);
          $('input[name="training"]').val(d.training);
          $('input[name="cert_name"]').val(d.cert_name);
          $('input[name="acquisition_date"]').val(d.acquisition_date);
          $('input[name="next_date"]').val(d.next_date);
          $('textarea[name="note"]').val(d.note);
          // file 파일명만 표시 (input[type=file] 은 초기화 되므로 텍스트로)
         $('input[name="file_name"]').val(d.file_name);
          $('#modalContainer').show();
        },
      });

      // 3) 검색 버튼
      $('.select-button').click(function() {
        dataTable.setData('/line/user/planManage/list', {
          name: $('#name').val(),
          startDate: $('#startDate').val(),
          endDate: $('#endDate').val()
        });
      });

      // 추가 버튼
      $('.insert-button').click(function() {
        selectedRowData = null;
        $('#corrForm')[0].reset();
        $('.existing-file').remove();
        $('#modalContainer').show().addClass('show');
      });

      // 삭제 버튼
      $('.delete-button').click(function() {
        if (!selectedRowData) {
          alert('삭제할 행을 먼저 선택하세요.');
          return;
        }
        if (!confirm('정말 삭제하시겠습니까?')) return;
        $.ajax({
          url: '/line/user/planManage/delete',
          type: 'POST',
          contentType: 'application/json',
          data: JSON.stringify({ no: selectedRowData.no }),
          success: function() {
            alert('삭제되었습니다.');
            dataTable.replaceData(); 
            selectedRowData = null;
          },
          error: function() {
            alert('삭제 중 오류가 발생했습니다.');
          }
        });
      });

      // 모달 닫기
      $('.close, #closeModal').click(function() {
        $('#modalContainer').hide();
      });

      // 파일 업로드 체크 (PDF만)
      $('#files').on('change', function() {
        var file = this.files[0];
        if (file && file.name.split('.').pop().toLowerCase() !== 'pdf') {
          alert('PDF 파일만 업로드 가능합니다.');
          $(this).val('');
        }
      });


   // 저장 (추가/수정)
      $('#saveCorrStatus').click(function(e) {
        e.preventDefault();

        var form = $('#corrForm')[0],
            formData = new FormData(form);

        if (selectedRowData && selectedRowData.no) {
          formData.append('no', selectedRowData.no);
        }

        console.log(" 저장 요청 전송 중... FormData 내용:");
        for (var pair of formData.entries()) {
          console.log(pair[0] + ':', pair[1]);
        }

        $.ajax({
          url: '/line/user/planManage/insert',
          type: 'POST',
          data: formData,
          processData: false,
          contentType: false,
          success: function() {
            alert('저장되었습니다!');
            $('#modalContainer').hide();
            dataTable.replaceData();
            selectedRowData = null;
          },
          error: function(xhr, status, error) {
            console.error("❌ 저장 요청 실패:");
            console.error("상태 코드:", xhr.status);
            console.error("응답 텍스트:", xhr.responseText);
            console.error("오류 내용:", error);
            alert('저장 중 오류가 발생했습니다. 콘솔을 확인해주세요.');
          }
        });
      });

    });
  </script>

</body>


</html>