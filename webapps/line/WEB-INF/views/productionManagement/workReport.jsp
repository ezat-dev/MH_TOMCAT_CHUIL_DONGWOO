<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>작업일보</title>
	<%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/>
</head>
    <style>
:root {
  --bg:#f3f5f8; --line:#e3e8ef; --line2:#eef1f5;
  --ink:#0f172a; --ink2:#334155; --mute:#64748b; --mute2:#94a3b8; --accent:#2563eb;
}
html, body { height:100%; margin:0; background:var(--bg); overflow:hidden; }
body { font-family:"Pretendard","Malgun Gothic","맑은 고딕",sans-serif; color:var(--ink); font-size:13px; }
.num { font-variant-numeric:tabular-nums; }

/* 상단 바 */
.topbar { background:#fff; border-bottom:1px solid var(--line); }
.topbar-inner { height:52px; padding:0 20px; display:flex; align-items:center; gap:10px; }
.tb-title { font-size:16px; font-weight:700; letter-spacing:-.3px; margin-right:12px; }
.tb-label { font-size:12.5px; color:var(--mute); }
.monthSet { width:100px; height:32px; box-sizing:border-box; padding:0 10px; border:1px solid var(--line); border-radius:6px;
  text-align:center; font-size:13px; font-family:inherit; color:var(--ink); outline:none; }
.monthSet:focus { border-color:var(--accent); }
.select-button { height:32px; padding:0 16px; border-radius:6px; border:1px solid var(--ink); background:var(--ink);
  color:#fff; font-size:13px; font-weight:600; font-family:inherit; cursor:pointer; }
.select-button:hover { background:#1e293b; }
.tb-sp { flex:1; }
.tb-hint { font-size:12px; color:var(--mute2); }

/* 페이지 */
.main { height:calc(100% - 53px); box-sizing:border-box; padding:14px 20px 18px; display:flex; flex-direction:column; gap:12px; }
.card { background:#fff; border:1px solid var(--line); border-radius:10px; }

.summary { display:grid; grid-template-columns:repeat(4, minmax(0,1fr)); flex:none; }
.summary > div { padding:14px 18px; border-left:1px solid var(--line2); }
.summary > div:first-child { border-left:0; }
.s-lb { font-size:12.5px; color:var(--mute); }
.s-v { margin-top:4px; font-size:22px; font-weight:700; letter-spacing:-.4px; white-space:nowrap; }
.s-v u { text-decoration:none; font-size:13px; font-weight:500; color:var(--mute); margin-left:2px; }
.s-sub { margin-top:2px; font-size:12px; color:var(--mute2); }

.list-card { flex:1; min-height:0; display:flex; flex-direction:column; }
.card-head { padding:12px 16px; border-bottom:1px solid var(--line2); display:flex; justify-content:space-between; align-items:center; }
.card-head b { font-size:14px; color:var(--ink2); }
.card-head small { font-size:12px; color:var(--mute2); }
#tablelot_reportWrapper { flex:1; min-height:0; overflow:auto; }

table { width:100%; border-collapse:collapse; font-size:13px; }
thead th { position:sticky; top:0; background:#fff; z-index:1; text-align:left; padding:10px 16px; font-size:12px;
  font-weight:600; color:var(--mute); border-bottom:1px solid var(--line); white-space:nowrap; }
tbody td { padding:0 16px; height:48px; border-bottom:1px solid var(--line2); color:var(--ink2); white-space:nowrap; }
tbody tr:hover td { background:#f8fafc; }
tbody tr.sel td { background:#eef4ff; }
th.r, td.r { text-align:right; }
td.day { font-weight:600; color:var(--ink); }
td.day small { font-weight:400; color:var(--mute2); margin-left:8px; }
td.day .today { display:inline-block; margin-left:8px; font-size:11px; font-weight:600; color:var(--accent); }
.cnt { display:flex; align-items:center; gap:10px; }
.cnt b { width:28px; text-align:right; font-weight:700; color:var(--ink); }
.cnt .tr { width:120px; height:6px; background:var(--line2); border-radius:3px; overflow:hidden; }
.cnt .tr i { display:block; height:100%; background:#94a3b8; border-radius:3px; }
.lot { color:var(--mute); }
.lot em { font-style:normal; color:var(--mute2); margin:0 6px; }
td.act { text-align:right; }
.preview-btn, .save-btn { height:30px; padding:0 12px; border-radius:6px; font-size:12.5px; font-weight:600; font-family:inherit;
  cursor:pointer; border:1px solid var(--line); background:#fff; color:var(--ink2); margin-left:6px; }
.preview-btn:hover, .save-btn:hover { border-color:#cbd5e1; background:#f8fafc; }
.save-btn { color:var(--accent); }
.empty td { text-align:center; color:var(--mute2); height:120px; }

/* PDF 미리보기 */
#pdfPreviewModal { position:fixed; z-index:9999; inset:0; background:rgba(15,23,42,.55); }
#pdfPreviewModal .modal-content { background:#fff; width:100%; height:100%; }
.pv-head { display:flex; justify-content:space-between; align-items:center; height:56px; box-sizing:border-box; padding:0 20px;
  border-bottom:1px solid var(--line); background:#fff; }
.pv-head h2 { margin:0; font-size:16px; font-weight:700; color:var(--ink); }
.btn-download, .btn-close { height:34px; padding:0 16px; margin-left:8px; border-radius:6px; font-size:13px; font-weight:600;
  font-family:inherit; cursor:pointer; border:1px solid var(--line); background:#fff; color:var(--ink2); }
.btn-download { background:var(--ink); border-color:var(--ink); color:#fff; }
    </style>

<body>
<div class="topbar">
  <div class="topbar-inner">
    <div class="tb-title">작업일보</div>
    <span class="tb-label">조회 월</span>
    <input type="text" id="s_sdate" class="monthSet num" autocomplete="off"/>
    <button class="select-button">조회</button>
    <div class="tb-sp"></div>
    <span class="tb-hint">일자별 작업일보를 PDF로 미리보고 내려받습니다</span>
  </div>
</div>

<main class="main">
  <div class="card summary">
    <div><div class="s-lb">작업일수</div><div class="s-v num" id="sumDays">-</div><div class="s-sub" id="sumMonth">-</div></div>
    <div><div class="s-lb">총 LOT</div><div class="s-v num" id="sumLots">-</div><div class="s-sub">월 누적 투입 LOT</div></div>
    <div><div class="s-lb">일평균 LOT</div><div class="s-v num" id="sumAvg">-</div><div class="s-sub" id="sumMax">-</div></div>
    <div><div class="s-lb">최근 작업일</div><div class="s-v num" id="sumLast">-</div><div class="s-sub" id="sumLastSub">-</div></div>
  </div>

  <div class="card list-card">
    <div class="card-head"><b>일자별 작업일보</b><small id="listSub"></small></div>
    <div id="tablelot_reportWrapper">
      <table id="tablelot_report">
        <thead>
          <tr>
            <th style="width:60px">No</th>
            <th>작업일</th>
            <th>LOT 수</th>
            <th>LOT 범위</th>
            <th class="r">작업일보</th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  </div>
</main>

<div id="pdfPreviewModal" class="modal" style="display:none;">
    <div class="modal-content">
        <div class="pv-head">
            <h2 id="pdfTitle">작업일보 미리보기</h2>
            <div>
                <button id="downloadPdfBtn" class="btn-download">PDF 다운로드</button>
                <button id="closePdfPreview" class="btn-close">닫기</button>
            </div>
        </div>
        <iframe id="pdfViewer" style="width:100%; height:calc(100% - 56px); border:none;"></iframe>
    </div>
</div>

<script>
let now_page_code = "c06";

var dataTable;
var selectedRowData = null;

$(function() {
    let today = new Date();
    let year = today.getFullYear();
    let month = today.getMonth() + 1;
    if(month < 10) month = '0' + month;

    let currentYearMonth = year + '-' + month;

    $("#s_sdate").val(currentYearMonth);

    fetchlot_report();
    
    // ✅ 모달 닫기 이벤트
    $("#closePdfPreview").click(function(){
        $("#pdfPreviewModal").hide();
        $("#pdfViewer").attr("src", ""); // iframe 초기화
    });
});

// ✅ 전역 변수로 현재 PDF 데이터 저장
let currentPdfBlob = null;
let currentPdfFileName = "";

$('.select-button').click(function() {
    fetchlot_report();
});

function renderSummary(arr){
    var ym = $("#s_sdate").val() || "";
    var tot = arr.reduce(function(a, x){ return a + (+x.work_count || 0); }, 0);
    var max = arr.reduce(function(m, x){ return (+x.work_count || 0) > (+m.work_count || 0) ? x : m; }, {});
    var last = arr.slice().sort(function(a, b){ return a.w_date < b.w_date ? 1 : -1; })[0];
    $("#sumDays").html(arr.length + "<u>일</u>");
    $("#sumMonth").text(ym.replace("-", "년 ") + "월");
    $("#sumLots").html(tot.toLocaleString() + "<u>LOT</u>");
    $("#sumAvg").html((arr.length ? (tot / arr.length).toFixed(1) : "0") + "<u>LOT</u>");
    $("#sumMax").text(max.w_date ? "최다 " + max.w_date.substr(5) + " · " + max.work_count + " LOT" : "-");
    $("#sumLast").text(last ? last.w_date : "-");
    $("#sumLastSub").text(last ? (last.work_count || 0) + " LOT · " + (last.max_w_ci_lot || "") : "-");
    $("#listSub").text(arr.length ? "총 " + arr.length + "일" : "");
}

function fetchlot_report(){
    $.ajax({
        url: "/line/productionManagement/work_report/list",
        method: "POST",
        data: {
            s_sdate: $("#s_sdate").val()
        },
        dataType: "json",
        success: function(resp){
            var arr = Array.isArray(resp) ? resp : (resp.data || resp.rows || (resp ? [resp] : []));
            var $tbody = $("#tablelot_report tbody").empty();
            renderSummary(arr || []);
            if(!arr || arr.length === 0){
                $tbody.append('<tr class="empty"><td colspan="5">조회된 데이터가 없습니다.</td></tr>');
                return;
            }

            var maxCnt = Math.max.apply(null, arr.map(function(x){ return +x.work_count || 0; }).concat([1]));
            var todayStr = new Date().toISOString().substr(0, 10);
            var WD = ['일','월','화','수','목','금','토'];

            arr.forEach(function(r, idx){
                var tr = $("<tr></tr>");
                var cnt = +r.work_count || 0;
                var wd = r.w_date ? WD[new Date(r.w_date + 'T00:00:00').getDay()] : '';

                tr.append("<td class='num' style='color:#94a3b8'>"+ (r.idx || "") +"</td>");
                tr.append("<td class='day num'>"+ (r.w_date || "") + "<small>(" + wd + ")</small>" +
                          (r.w_date === todayStr ? "<span class='today'>작업중</span>" : "") + "</td>");
                tr.append("<td><div class='cnt'><b class='num'>"+ cnt +"</b><span class='tr'><i style='width:" +
                          Math.max(3, cnt / maxCnt * 100) + "%'></i></span></div></td>");
                tr.append("<td class='lot num'>"+ (r.min_w_ci_lot || "") + "<em>~</em>" + (r.max_w_ci_lot || "") +"</td>");

                var previewBtn = $("<button class='preview-btn' title='미리보기'>미리보기</button>");
                var saveBtn = $("<button class='save-btn' title='다운로드'>PDF 다운로드</button>");
                tr.append($("<td class='act'></td>").append(previewBtn).append(saveBtn));

                // 클릭 이벤트: 선택 색상
                tr.click(function() {
                    $("#tablelot_report tbody tr").removeClass("sel");
                    $(this).addClass("sel");
                    selectedRowData = $(this).data("rowdata");
                });

                // ✅ 미리보기 버튼 클릭 이벤트
                previewBtn.click(function(e){
                    e.stopPropagation();
                    var rowData = tr.data("rowdata");
                    
                    if(rowData){
                        console.log("미리보기:", rowData.w_date);
                        
                        $.ajax({
                            url: "/line/productionManagement/work_report/dayPrint",
                            type: "POST",
                            data: JSON.stringify({ w_date: rowData.w_date }),
                            contentType: "application/json",
                            xhrFields: { responseType: 'blob' },
                            success: function(blob){
                                // PDF Blob을 전역 변수에 저장
                                currentPdfBlob = blob;
                                currentPdfFileName = "work_report_" + rowData.w_date + ".pdf";
                                $("#pdfTitle").text("작업일보 미리보기 · " + rowData.w_date);
                                
                                // Blob을 URL로 변환하여 iframe에 표시
                                var blobUrl = window.URL.createObjectURL(blob);
                                $("#pdfViewer").attr("src", blobUrl);
                                $("#pdfPreviewModal").show();
                            },
                            error: function(xhr){
                                console.error("미리보기 실패", xhr);
                                alert("PDF 미리보기에 실패했습니다.");
                            }
                        });
                    }
                });

                // ✅ 다운로드 버튼 클릭 이벤트
                saveBtn.click(function(e){
                    e.stopPropagation();
                    var rowData = tr.data("rowdata");

                    if(rowData){
                        console.log("다운로드:", rowData.w_date);

                        $.ajax({
                            url: "/line/productionManagement/work_report/dayPrint",
                            type: "POST",
                            data: JSON.stringify({ w_date: rowData.w_date }),
                            contentType: "application/json",
                            xhrFields: { responseType: 'blob' },
                            success: function(blob){
                                var link = document.createElement('a');
                                link.href = window.URL.createObjectURL(blob);
                                link.download = "work_report_" + rowData.w_date + ".pdf";
                                document.body.appendChild(link);
                                link.click();
                                document.body.removeChild(link);
                                window.URL.revokeObjectURL(link.href);
                            },
                            error: function(xhr){
                                console.error("다운로드 실패", xhr);
                                alert("PDF 다운로드에 실패했습니다.");
                            }
                        });
                    }
                });

                tr.data("rowdata", r);
                $tbody.append(tr);
            });
        },
        error: function(xhr){
            console.error("fetchlot_report error", xhr);
        }
    });
}

// ✅ 미리보기 모달에서 다운로드 버튼 클릭 시
$(document).on('click', '#downloadPdfBtn', function(){
    if(currentPdfBlob){
        var link = document.createElement('a');
        link.href = window.URL.createObjectURL(currentPdfBlob);
        link.download = currentPdfFileName;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        window.URL.revokeObjectURL(link.href);
        
        
    }
});

</script>

</body>
</html>