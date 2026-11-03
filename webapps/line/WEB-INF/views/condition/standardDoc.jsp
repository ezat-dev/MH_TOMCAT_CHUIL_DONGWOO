<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리계획서 및 작업 표준서</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
<style>
:root {
  --bg:#f3f5f8; --surface:#ffffff; --surface2:#f8fafc; --border:#e3e8ef; --line2:#eef1f5;
  --text-p:#0f172a; --text-2:#334155; --text-s:#64748b; --text-m:#94a3b8;
  --accent:#2563eb; --red:#dc2626; --amber:#d97706; --teal:#0d9488;
}
*{ box-sizing:border-box; margin:0; padding:0; }
body { font-family:"Pretendard","Malgun Gothic","맑은 고딕",sans-serif; background:var(--bg); color:var(--text-p); font-size:13px; min-height:100vh; }
.num { font-variant-numeric:tabular-nums; }

/* ===== 상단 바 ===== */
.topbar { background:var(--surface); border-bottom:1px solid var(--border); }
.topbar-inner { padding:0 20px; height:52px; display:flex; align-items:center; gap:10px; }
.tb-title { font-size:16px; font-weight:700; letter-spacing:-.3px; margin-right:12px; white-space:nowrap; color:var(--text-p); }
.tb-label { font-size:12.5px; color:var(--text-s); white-space:nowrap; }
.ctrl, .ctrl-select, .ctrl-input { height:32px; padding:0 10px; border:1px solid var(--border); border-radius:6px; background:#fff;
  color:var(--text-p); font-size:13px; font-family:inherit; outline:none; }
.ctrl-select { min-width:110px; cursor:pointer; }
.ctrl:focus, .ctrl-select:focus, .ctrl-input:focus { border-color:var(--accent); }
.tb-sp { flex:1; }
.btn { height:32px; padding:0 14px; border-radius:6px; font-size:13px; font-family:inherit; font-weight:600;
  cursor:pointer; white-space:nowrap; border:1px solid var(--border); background:#fff; color:var(--text-2);
  display:inline-flex; align-items:center; gap:5px; }
.btn:hover { border-color:#cbd5e1; background:var(--surface2); }
.btn-search { background:var(--text-p); border-color:var(--text-p); color:#fff; }
.btn-search:hover { background:#1e293b; border-color:#1e293b; }
.btn-delete { color:var(--red); }

/* ===== 페이지 ===== */
.page { padding:14px 20px 18px; display:flex; flex-direction:column; gap:12px; }
.card { background:var(--surface); border:1px solid var(--border); border-radius:10px; }
.card-head { padding:12px 16px; display:flex; align-items:center; justify-content:space-between; gap:12px; border-bottom:1px solid var(--line2); }
.card-head-title { font-size:14px; font-weight:700; color:var(--text-2); }
.card-head small, .card-head .hint { font-size:12px; color:var(--text-m); }
.card-foot { padding:8px 16px; border-top:1px solid var(--line2); display:flex; justify-content:space-between; font-size:12px; color:var(--text-m); }
.card-foot strong { color:var(--text-2); font-variant-numeric:tabular-nums; }
.main-card { background:var(--surface); border:1px solid var(--border); border-radius:10px; overflow:hidden; display:flex; flex-direction:column; min-width:0; }

/* 요약 지표 */
.summary { display:grid; grid-template-columns:repeat(4, minmax(0,1fr)); }
.summary > div { padding:14px 18px; border-left:1px solid var(--line2); min-width:0; }
.summary > div:first-child { border-left:0; }
.s-lb { font-size:12.5px; color:var(--text-s); }
.s-v { margin-top:4px; font-size:22px; font-weight:700; letter-spacing:-.4px; color:var(--text-p); font-variant-numeric:tabular-nums; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.s-v u { text-decoration:none; font-size:13px; font-weight:500; color:var(--text-s); margin-left:2px; }
.s-sub { margin-top:2px; font-size:12px; color:var(--text-m); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }

/* ===== Tabulator ===== */
.flat-tab.tabulator { border:0; background:#fff; font-family:inherit; font-size:13px; }
.flat-tab .tabulator-header { background:#fff; border-bottom:1px solid var(--border); }
.flat-tab .tabulator-header .tabulator-col { background:#fff; border-right:0; color:var(--text-s); font-size:12px; font-weight:600; }
.flat-tab .tabulator-col .tabulator-col-content { padding:9px 10px; }
.flat-tab .tabulator-tableholder { background:#fff; }
.flat-tab .tabulator-row { background:#fff; border-bottom:1px solid var(--line2); min-height:40px; cursor:pointer; }
.flat-tab .tabulator-row.tabulator-row-even { background:#fff; }
.flat-tab .tabulator-row:hover { background:#f8fafc; }
.flat-tab .tabulator-row.row_select, .flat-tab .tabulator-row.tabulator-selected { background:#eef4ff !important; }
.flat-tab .tabulator-cell { border-right:0; padding:11px 10px; color:var(--text-2); }
.flat-tab .tabulator-placeholder span { color:var(--text-m); font-size:13px; font-weight:400; }
.flat-tab .tabulator-footer { background:#fff; border-top:1px solid var(--line2); }
.date-cell { color:var(--text-s); font-variant-numeric:tabular-nums; }
.st-ok { color:var(--teal); } .st-warn { color:var(--amber); } .st-over { color:var(--red); font-weight:600; }
.file-link { color:var(--accent); text-decoration:none; cursor:pointer; display:inline-block; max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; vertical-align:middle; }
.file-link:hover { text-decoration:underline; }
.muted { color:var(--text-m); }

/* ===== 모달 ===== */
.modal-overlay { display:none; position:fixed; inset:0; background:rgba(15,23,42,.4); z-index:500; align-items:center; justify-content:center; }
.modal-overlay.show { display:flex; }
.modal-box { background:#fff; border-radius:10px; width:460px; max-width:95vw; max-height:90vh; overflow-y:auto; box-shadow:0 16px 48px rgba(15,23,42,.18); padding:20px 22px; position:relative; }
.modal-head { display:flex; align-items:center; justify-content:space-between; margin:-20px -22px 16px; padding:16px 22px; border-bottom:1px solid var(--border); }
.modal-head h2 { font-size:16px; font-weight:700; color:var(--text-p); }
.modal-close { cursor:pointer; color:var(--text-s); font-size:16px; padding:4px 6px; background:none; border:0; }
.modal-close:hover { color:var(--text-p); }
.form-group { margin-bottom:12px; }
.form-label { font-size:12px; color:var(--text-s); margin-bottom:5px; display:block; }
.form-input, .form-textarea, .form-select { width:100%; border:1px solid var(--border); border-radius:6px; background:#fff; color:var(--text-p); font-size:13px; font-family:inherit; outline:none; }
.form-input, .form-select { height:34px; padding:0 10px; }
.form-textarea { padding:8px 10px; resize:vertical; min-height:80px; }
.form-input:focus, .form-textarea:focus, .form-select:focus { border-color:var(--accent); }
.form-input[readonly] { color:var(--text-m); background:var(--surface2); cursor:default; }
.modal-btn-row { display:flex; gap:8px; justify-content:flex-end; margin:18px -22px -20px; padding:12px 22px; border-top:1px solid var(--border); }
.modal-btn { height:34px; padding:0 18px; border-radius:6px; font-size:13px; font-weight:600; font-family:inherit; cursor:pointer; border:1px solid var(--border); background:#fff; color:var(--text-2); }
.modal-btn-save { background:var(--text-p); border-color:var(--text-p); color:#fff; }
.modal-btn-cancel { background:#fff; color:var(--text-2); }

/* 엑셀 로딩 */
#excelOverlay { display:none; position:fixed; inset:0; background:rgba(15,23,42,.4); z-index:9998; }
#excelLoading { display:none; position:fixed; top:50%; left:50%; transform:translate(-50%,-50%); background:#fff; padding:22px 40px; border-radius:10px; border:1px solid var(--border); z-index:9999; font-size:14px; font-weight:600; text-align:center; }

/* ===== HTML 테이블 ===== */
.ctrl.dayselect { width:120px; text-align:center; }
.tilde { color:var(--text-m); padding:0 2px; }
.table-wrap { overflow-y:auto; max-height:620px; }
.table-wrap table { width:100%; border-collapse:collapse; font-size:13px; }
.table-wrap thead tr { position:sticky; top:0; z-index:2; }
.table-wrap thead th { text-align:center; padding:10px 12px; background:#fff; border-bottom:1px solid var(--border);
  font-size:12px; font-weight:600; color:var(--text-s); white-space:nowrap; user-select:none; }
.table-wrap thead th.th-left { text-align:left; padding-left:16px; }
.table-wrap tbody tr { border-bottom:1px solid var(--line2); cursor:pointer; background:#fff; }
.table-wrap tbody tr:hover { background:#f8fafc; }
.table-wrap tbody tr.row_select { background:#eef4ff !important; }
.table-wrap tbody td { padding:11px 12px; color:var(--text-2); vertical-align:middle; text-align:center; }
.table-wrap tbody td.td-left { text-align:left; padding-left:16px; }
.empty-row td { padding:40px; text-align:center; color:var(--text-m) !important; font-size:13px; cursor:default; }
.no-cell { color:var(--text-m); font-variant-numeric:tabular-nums; }
.pdf-link { color:var(--accent); text-decoration:none; cursor:pointer; display:inline-block; max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; vertical-align:middle; }
.pdf-link:hover { text-decoration:underline; }
.pdf-empty { color:var(--text-m); }
.memo-text { color:var(--text-s); }

/* 모달 파일 */
.file-group { border:1px solid var(--border); border-radius:6px; padding:10px 12px; margin-bottom:10px; }
.file-group-label { font-size:12px; color:var(--text-s); margin-bottom:6px; }
.file-group-label span { display:none; }
.file-input { width:100%; font-size:12px; font-family:inherit; }
.file-exist { font-size:12px; color:var(--text-m); margin-top:4px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }

/* PDF 뷰어 */
#pdfViewerModal { display:none; position:fixed; inset:0; background:rgba(15,23,42,.6); z-index:600; align-items:center; justify-content:center; }
#pdfViewerModal.show { display:flex; }
#startDate, #endDate { width:120px; text-align:center; }
</style>
</head>
<body>

<div class="topbar">
  <div class="topbar-inner">
    <div class="tb-title">관리계획서 및 작업표준서</div>
    <span class="tb-label">조회일자</span>
    <input type="text" id="startDate" class="ctrl" placeholder="시작일" autocomplete="off"/>
    <span class="tilde">~</span>
    <input type="text" id="endDate" class="ctrl" placeholder="종료일" autocomplete="off"/>
    <span class="tb-label" style="margin-left:6px;">설비명</span>
    <select id="mch_name" class="ctrl-select">
      <option value="열처리 연속로">열처리 연속로</option>
    </select>
    <button class="btn btn-search select-button">조회</button>
    <div class="tb-sp"></div>
    <button class="btn btn-insert insert-button">추가</button>
    <button class="btn btn-delete delete-button">삭제</button>
  </div>
</div>

<div class="page">

  <div class="card summary">
    <div><div class="s-lb">전체 문서</div><div class="s-v" id="kpi-total">0</div><div class="s-sub">등록된 총 건수</div></div>
    <div><div class="s-lb">관리계획서</div><div class="s-v" id="kpi-box1">0</div><div class="s-sub">파일 등록 건수</div></div>
    <div><div class="s-lb">작업표준서</div><div class="s-v" id="kpi-box2">0</div><div class="s-sub">파일 등록 건수</div></div>
    <div><div class="s-lb">조회 기간</div><div class="s-v" id="kpi-period" style="font-size:15px; font-weight:600; line-height:26px;">-</div><div class="s-sub" id="kpi-period-sub">-</div></div>
  </div>

  <div class="main-card">
    <div class="card-head">
      <span class="card-head-title">문서 목록</span>
      <small>더블클릭 시 수정 · 파일명 클릭 시 PDF 보기</small>
    </div>

    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th style="width:60px;">No</th>
            <th style="width:120px;">저장 날짜</th>
            <th style="width:140px;">설비</th>
            <th style="width:220px;">관리계획서</th>
            <th style="width:220px;">작업표준서</th>
            <th style="width:220px;">설비점검일지</th>
            <th class="th-left">비고</th>
          </tr>
        </thead>
        <tbody id="docTbody">
          <tr class="empty-row"><td colspan="7">조회 버튼을 눌러 데이터를 불러오세요</td></tr>
        </tbody>
      </table>
    </div>

    <div class="card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회 <strong id="footer-time">-</strong></span>
    </div>
  </div>

</div>

<div id="modalContainer" class="modal-overlay">
  <div class="modal-box">
    <div class="modal-head">
      <h2>관리계획서 및 작업표준서</h2>
      <span class="modal-close" id="closeModal">✕</span>
    </div>
    <form id="corrForm" autocomplete="off" enctype="multipart/form-data">
      <input type="hidden" id="idx" name="idx"/>

      <div class="form-group">
        <label class="form-label">저장 날짜</label>
        <input type="text" name="cr_date" id="cr_date" class="form-input" placeholder="날짜 선택" autocomplete="off"/>
      </div>

      <div class="form-group">
        <label class="form-label">설비</label>
        <select name="mch_name" class="form-select">
          <option value="열처리 연속로">열처리 연속로</option>
        </select>
      </div>

      <div class="file-group">
        <div class="file-group-label">관리계획서 (PDF)</div>
        <input type="file" name="box1" class="file-input" accept=".pdf"/>
        <div class="file-exist" id="box1FileName"></div>
      </div>

      <div class="file-group">
        <div class="file-group-label">작업표준서 (PDF)</div>
        <input type="file" name="box2" class="file-input" accept=".pdf"/>
        <div class="file-exist" id="box2FileName"></div>
      </div>

      <div class="file-group">
        <div class="file-group-label">설비점검일지 (PDF)</div>
        <input type="file" name="box3" class="file-input" accept=".pdf"/>
        <div class="file-exist" id="box3FileName"></div>
      </div>

      <div class="form-group">
        <label class="form-label">비고</label>
        <input type="text" name="memo" class="form-input" placeholder="비고 입력"/>
      </div>

      <div class="modal-btn-row">
        <button type="button" id="cancelModal" class="modal-btn modal-btn-cancel">닫기</button>
        <button type="submit" id="saveCorrStatus" class="modal-btn modal-btn-save">저장</button>
      </div>
    </form>
  </div>
</div>

<div id="pdfViewerModal">
  <div style="position:relative; width:82%; height:92%; background:#fff; border-radius:10px; overflow:hidden; border:1px solid #e3e8ef;">
    <button id="closePdfModal"
            style="position:absolute; top:10px; right:10px; z-index:10; height:30px; padding:0 12px; border-radius:6px;
                   background:#fff; color:#334155; border:1px solid #e3e8ef; cursor:pointer; font-size:12px; font-weight:600; font-family:inherit;">
      닫기
    </button>
    <iframe id="pdfFrame" style="width:100%; height:100%; border:none;" src=""></iframe>
  </div>
</div>

<script>
let now_page_code = "d05";
let selectedRow = null;
let allData = [];

/* ─── 날짜 유틸 ─── */
function pad2(n){ return String(n).padStart(2,'0'); }

function formatDate(date){
  return date.getFullYear() + '-' + pad2(date.getMonth()+1) + '-' + pad2(date.getDate());
}

/* ─── 기본 날짜: 오늘 기준 2년 전 ~ 오늘 ─── */
(function initDates(){
  const today = new Date();
  const twoYearsAgo = new Date(today);
  twoYearsAgo.setFullYear(today.getFullYear() - 2);

  document.getElementById('startDate').value = formatDate(twoYearsAgo);
  document.getElementById('endDate').value   = formatDate(today);
})();

/* ─── PDF 열기 ─── */
function openPdf(encodedName){
  if(!encodedName){ alert('파일명이 없습니다!'); return; }
  document.getElementById('pdfFrame').src = '/line/download_standardDoc?filename=' + encodedName;
  document.getElementById('pdfViewerModal').classList.add('show');
  document.getElementById('pdfViewerModal').style.display = 'flex';
}

/* ─── PDF 링크 셀 생성 ─── */
function makePdfCell(fn){
  if(!fn) return '<span class="pdf-empty">-</span>';
  var enc = encodeURIComponent(fn).replace(/\(/g,'%28').replace(/\)/g,'%29');
  return '<a class="pdf-link" title="' + fn + '" onclick="openPdf(\'' + enc + '\')">' + fn + '</a>';
}

/* ─── 테이블 렌더 ─── */
function renderTable(data){
  var tbody = document.getElementById('docTbody');
  tbody.innerHTML = '';

  if(!data || data.length === 0){
    tbody.innerHTML = '<tr class="empty-row"><td colspan="7">조회된 데이터가 없습니다.</td></tr>';
    return;
  }

  data.forEach(function(r, i){
    var tr = document.createElement('tr');
    tr.innerHTML =
      '<td class="no-cell">' + (i+1) + '</td>' +
      '<td class="date-cell">' + (r.cr_date || '-') + '</td>' +
      '<td>' + (r.mch_name || '-') + '</td>' +
      '<td>' + makePdfCell(r.box1) + '</td>' +
      '<td>' + makePdfCell(r.box2) + '</td>' +
      '<td>' + makePdfCell(r.box3) + '</td>' +
      '<td class="td-left"><span class="memo-text">' + (r.memo || '') + '</span></td>';

    tr.addEventListener('click', function(){
      document.querySelectorAll('#docTbody tr').forEach(function(el){ el.classList.remove('row_select'); });
      tr.classList.add('row_select');
      selectedRow = r;
    });

    tr.addEventListener('dblclick', function(){
      openEditModal(r);
    });

    tbody.appendChild(tr);
  });
}

/* ─── KPI 업데이트 ─── */
function updateKpi(data){
  var total  = data.length;
  var box1Cnt = data.filter(function(r){ return r.box1; }).length;
  var box2Cnt = data.filter(function(r){ return r.box2; }).length;

  document.getElementById('kpi-total').textContent = total.toLocaleString();
  document.getElementById('kpi-box1').textContent  = box1Cnt.toLocaleString();
  document.getElementById('kpi-box2').textContent  = box2Cnt.toLocaleString();

  var s = document.getElementById('startDate').value || '-';
  var e = document.getElementById('endDate').value   || '-';
  document.getElementById('kpi-period').textContent     = s.substring(0,10);
  document.getElementById('kpi-period-sub').textContent = '~ ' + e.substring(0,10);
}

/* ─── Footer ─── */
function updateFooter(){
  var now = new Date();
  document.getElementById('footer-time').textContent =
    pad2(now.getHours()) + ':' + pad2(now.getMinutes()) + ':' + pad2(now.getSeconds());
  document.getElementById('footer-info').innerHTML =
    '총 <strong>' + allData.length + '</strong>건';
}

/* ─── 데이터 조회 ─── */
function fetchList(){
  $.ajax({
    url: '/line/condition/standardDoc/list',
    type: 'POST',
    dataType: 'json',
    data: {
      mch_name:  $('#mch_name').val() || '',
      startDate: $('#startDate').val() || '',
      endDate:   $('#endDate').val() || ''
    },
    success: function(res){
      allData = Array.isArray(res) ? res : (res.data || res.rows || []);
      renderTable(allData);
      updateKpi(allData);
      updateFooter();
    },
    error: function(){
      console.error('list fetch error');
    }
  });
}

/* ─── 모달 열기 (수정) ─── */
function openEditModal(d){
  document.getElementById('corrForm').reset();
  document.getElementById('idx').value = d.idx || '';
  document.querySelector('input[name="cr_date"]').value = d.cr_date || '';
  document.querySelector('select[name="mch_name"]').value = d.mch_name || '';
  document.querySelector('input[name="memo"]').value = d.memo || '';
  document.getElementById('box1FileName').textContent = d.box1 ? '기존: ' + d.box1 : '';
  document.getElementById('box2FileName').textContent = d.box2 ? '기존: ' + d.box2 : '';
  document.getElementById('box3FileName').textContent = d.box3 ? '기존: ' + d.box3 : '';
  showModal();
}

/* ─── 모달 show/hide ─── */
function showModal(){
  var ov = document.getElementById('modalContainer');
  ov.style.display = 'flex';
  setTimeout(function(){ ov.classList.add('show'); }, 10);
}
function hideModal(){
  var ov = document.getElementById('modalContainer');
  ov.classList.remove('show');
  setTimeout(function(){ ov.style.display = 'none'; }, 220);
}

/* ─── DOM Ready ─── */
document.addEventListener('DOMContentLoaded', function(){

  // 조회
  document.querySelector('.select-button').addEventListener('click', fetchList);

  // 추가
  document.querySelector('.insert-button').addEventListener('click', function(){
    document.getElementById('corrForm').reset();
    document.getElementById('idx').value = '';
    var today = new Date();
    document.querySelector('input[name="cr_date"]').value = formatDate(today);
    document.getElementById('box1FileName').textContent = '';
    document.getElementById('box2FileName').textContent = '';
    document.getElementById('box3FileName').textContent = '';
    showModal();
  });

  // 닫기
  document.getElementById('closeModal').addEventListener('click', hideModal);
  document.getElementById('cancelModal').addEventListener('click', hideModal);

  // PDF 뷰어 닫기
  document.getElementById('closePdfModal').addEventListener('click', function(){
    document.getElementById('pdfViewerModal').style.display = 'none';
    document.getElementById('pdfViewerModal').classList.remove('show');
    document.getElementById('pdfFrame').src = '';
  });

  // 저장
  document.getElementById('saveCorrStatus').addEventListener('click', function(e){
    e.preventDefault();
    var formEl = document.getElementById('corrForm');
    var formData = new FormData(formEl);

    if(!formData.get('idx') || !formData.get('idx').trim()) formData.delete('idx');

    for(var field of ['box1','box2','box3','box4']){
      var f = formData.get(field);
      if(f && f.size > 0 && !f.name.toLowerCase().endsWith('.pdf')){
        alert('[' + field + '] PDF 형식만 업로드 가능합니다.'); return;
      }
    }

    $.ajax({
      url: '/line/condition/standardDoc/insert',
      type: 'POST',
      data: formData,
      dataType: 'json',
      processData: false,
      contentType: false,
      success: function(res){
        if(res.result === 'success'){
          alert('저장 완료');
          hideModal();
          fetchList();
        } else {
          alert('저장 실패: ' + (res.message || '알 수 없는 오류'));
        }
      },
      error: function(){ alert('서버 오류 발생!'); }
    });
  });

  // 삭제
  document.querySelector('.delete-button').addEventListener('click', function(e){
    e.preventDefault();
    if(!selectedRow){ alert('삭제할 행을 선택하세요.'); return; }
    if(!confirm('정말 삭제하시겠습니까?')) return;

    $.ajax({
      url: '/line/condition/standardDoc/del',
      type: 'POST',
      contentType: 'application/json',
      data: JSON.stringify({ idx: selectedRow.idx }),
      dataType: 'json',
      success: function(){ alert('삭제 완료'); selectedRow = null; fetchList(); },
      error: function(_,__,err){ alert('삭제 중 오류: ' + err); }
    });
  });

  // 초기 조회
  fetchList();
});
</script>

</body>
</html>
