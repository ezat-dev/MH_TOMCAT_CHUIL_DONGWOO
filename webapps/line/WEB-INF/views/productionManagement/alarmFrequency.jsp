<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>알람발생 빈도</title>
    <%@include file="../include/pluginpage.jsp" %>
    <jsp:include page="../include/tabBar.jsp"/>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
    <link rel="stylesheet" href="/line/css/opsList/ops-list.css">
<style>
/* 데모: 한 화면 고정 — 페이지 스크롤 없이 표만 스크롤 */
html, body.ops { height: 100%; }
body.ops { display: flex; flex-direction: column; overflow: hidden; min-height: 0; }
.ops-head { flex: 0 0 auto; }
.ops-page { flex: 1 1 auto; min-height: 0; }
.ops-card { flex: 1 1 auto; min-height: 0; display: flex; flex-direction: column; }

.ops-input { text-align: center; min-width: 156px; }
.tilde { color: var(--ops-fg3); }

/* 지표: 최다 발생(핵심) / 총 발생 / 알람 종류 / 기간 */
.ops-kpi.k4 { grid-template-columns: 1.4fr repeat(3, 1fr); }
.ops-kpi .hero .kpi-sub { color: var(--ops-fg2); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

.ops-card-head { align-items: center; padding: 8px 16px; }
.search-input {
  height: 28px; width: 220px; padding: 0 8px 0 28px;
  border: 1px solid var(--ops-line); border-radius: 6px; background: #fff; color: var(--ops-fg);
  font-family: var(--ops-sans); font-size: 12px; outline: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%239aa1ad' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E");
  background-repeat: no-repeat; background-position: 8px center;
}
.search-input:focus { border-color: var(--ops-accent); box-shadow: 0 0 0 2px var(--ops-accent-tint); }

/* 표 */
.table-wrap { flex: 1 1 auto; min-height: 0; overflow-y: auto; }
#tableAlarm { width: 100%; border-collapse: collapse; table-layout: fixed; font-size: 13px; }
#tableAlarm thead th {
  position: sticky; top: 0; z-index: 2;
  height: 36px; padding: 0 12px; background: #fff;
  border-bottom: 1px solid var(--ops-line); border-right: 1px solid var(--ops-line2);
  font-size: 12px; font-weight: 500; color: var(--ops-fg2); text-align: left; white-space: nowrap;
}
#tableAlarm thead th:last-child { border-right: 0; }
#tableAlarm thead th.num { text-align: right; }
#tableAlarm tbody tr { border-bottom: 1px solid var(--ops-line2); transition: background-color 80ms; }
#tableAlarm tbody tr:hover { background: var(--ops-hover); }
#tableAlarm tbody td { height: 36px; padding: 0 12px; color: var(--ops-fg); border-right: 1px solid var(--ops-line2); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
#tableAlarm tbody td:last-child { border-right: 0; }
.td-center { text-align: center; }
.td-left { text-align: left; }

/* 순위 — 숫자만, 상위 3개는 진하게 */
.rank-badge { font-family: var(--ops-mono); font-size: 12px; font-variant-numeric: tabular-nums; color: var(--ops-fg3); }
.rank-1, .rank-2, .rank-3 { color: var(--ops-fg); font-weight: 600; }

.addr-tag { font-family: var(--ops-mono); font-size: 12px; color: var(--ops-fg); font-variant-numeric: tabular-nums slashed-zero; }
.desc-text { color: var(--ops-fg); }

/* 발생 수 — 단색 가로 막대 + 값 */
.cnt-cell { display: flex; align-items: center; gap: 12px; }
.cnt-bar-wrap { flex: 1; height: 8px; background: var(--ops-line2); border-radius: 2px; overflow: hidden; }
.cnt-bar { height: 100%; border-radius: 2px; background: var(--ops-accent); transition: width 150ms ease-out; }
.cnt-bar.bar-n { background: oklch(55% 0.13 255 / 0.45); }
.cnt-val { font-family: var(--ops-mono); font-size: 13px; font-weight: 500; font-variant-numeric: tabular-nums; min-width: 48px; text-align: right; color: var(--ops-fg); }
.cnt-share { font-family: var(--ops-mono); font-size: 12px; font-variant-numeric: tabular-nums; min-width: 48px; text-align: right; color: var(--ops-fg3); }

.empty-row td { height: 120px !important; text-align: center; color: var(--ops-fg3); border-right: 0 !important; }

/* 엑셀 생성 중 */
#excelOverlay { background: oklch(20% 0.01 255 / 0.3) !important; }
#excelLoading { padding: 16px 24px !important; border: 1px solid var(--ops-line); border-radius: 8px !important; box-shadow: 0 12px 32px oklch(20% 0.01 255 / 0.16) !important; font-size: 13px !important; font-weight: 500 !important; color: var(--ops-fg); font-family: var(--ops-sans); }
</style>
</head>
<body class="ops">

<!-- ===== 헤더 + 툴바 ===== -->
<header class="ops-head">
  <div class="ops-head-in">
    <h1 class="ops-title">알람 발생 랭킹</h1>
    <span class="ops-label">조회일자</span>
    <input type="text" id="s_sdate" class="ops-input dayselect daySet" placeholder="시작일"/>
    <span class="tilde">~</span>
    <input type="text" id="s_edate" class="ops-input dayselect daySet" placeholder="종료일"/>
    <button class="ops-btn primary select-button">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>조회
    </button>
    <span class="ops-spacer"></span>
    <button class="ops-btn excel-button">
      <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>엑셀
    </button>
  </div>
</header>

<!-- ===== 본문 ===== -->
<main class="ops-page">

  <!-- 지표 띠: 첫 칸이 핵심 -->
  <section class="ops-kpi k4">
    <div class="hero">
      <span class="kpi-label">최다 발생</span>
      <span class="kpi-value" id="kpi-top">0</span>
      <span class="kpi-sub" id="kpi-top-sub">1위 발생 횟수</span>
    </div>
    <div>
      <span class="kpi-label">총 발생 수</span>
      <span class="kpi-value" id="kpi-sum">0</span>
      <span class="kpi-sub">전체 알람 합계</span>
    </div>
    <div>
      <span class="kpi-label">알람 종류</span>
      <span class="kpi-value" id="kpi-total">0</span>
      <span class="kpi-sub">고유 알람 수</span>
    </div>
    <div>
      <span class="kpi-label">조회 기간</span>
      <span class="kpi-value" style="font-size:16px;" id="kpi-period">-</span>
      <span class="kpi-sub mono" id="kpi-period-sub">-</span>
    </div>
  </section>

  <!-- 랭킹 표 -->
  <section class="ops-card">
    <div class="ops-card-head">
      <h2>알람 발생 랭킹</h2>
      <input type="text" class="search-input" id="tableSearch" placeholder="주소 · 알람 내용 검색">
    </div>

    <div class="table-wrap">
      <table id="tableAlarm">
        <colgroup>
          <col style="width:64px"><col style="width:140px"><col><col style="width:44%">
        </colgroup>
        <thead>
          <tr>
            <th class="num">순위</th>
            <th>PLC 주소</th>
            <th>알람 내용</th>
            <th>발생 횟수 · 비중</th>
          </tr>
        </thead>
        <tbody id="alarmTbody">
          <tr class="empty-row"><td colspan="4">조회 버튼을 눌러 데이터를 불러오세요</td></tr>
        </tbody>
      </table>
    </div>

    <div class="ops-card-foot">
      <span id="footer-info">데이터를 조회하세요</span>
      <span>마지막 조회 <strong id="footer-time">-</strong></span>
    </div>
  </section>

</main>

<!-- 엑셀 로딩 오버레이 -->
<div id="excelOverlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:9998;"></div>
<div id="excelLoading" style="display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background:#fff;padding:30px 50px;border-radius:12px;box-shadow:0 8px 30px rgba(0,0,0,.2);z-index:9999;font-size:15px;font-weight:700;text-align:center;">엑셀 생성 중...</div>

<script>
let now_page_code = "b03";
var allData = [];

document.addEventListener("DOMContentLoaded", function () {
  // ✅ 올해 1/1 08:00 ~ 현재로 기본 세팅
  const now = new Date();
  const start = new Date(now.getFullYear(), 0, 1, 8, 0, 0, 0);
  const end = now;

  const sEl = document.getElementById("s_sdate");
  const eEl = document.getElementById("s_edate");
  if (sEl) sEl.value = formatDateTime(start);
  if (eEl) eEl.value = formatDateTime(end);

  // 버튼 이벤트 (jQuery 없이)
  const btnSelect = document.querySelector(".select-button");
  const btnExcel  = document.querySelector(".excel-button");
  if (btnSelect) btnSelect.addEventListener("click", fetchAlarm);
  if (btnExcel)  btnExcel.addEventListener("click", downloadExcel);

  // 실시간 검색 (jQuery 없이)
  const searchEl = document.getElementById("tableSearch");
  if (searchEl) {
    searchEl.addEventListener("keyup", function () {
      const kw = (searchEl.value || "").toLowerCase().trim();
      if (!kw) {
        renderTable(allData);
        updateFooter();
        return;
      }
      const filtered = (allData || []).filter(function (r) {
        const desc = (r.a_desc || "").toLowerCase();
        const addr = (r.a_addr || "").toLowerCase();
        return desc.indexOf(kw) > -1 || addr.indexOf(kw) > -1;
      });
      renderTable(filtered);
      const footerInfo = document.getElementById("footer-info");
      if (footerInfo) footerInfo.innerHTML = '총 <strong>' + filtered.length + "</strong>건 표시 중";
    });
  }

  fetchAlarm();
});

function pad2(n) { return String(n).padStart(2, "0"); }

// YYYY-MM-DD HH:mm
function formatDateTime(date) {
  const y  = date.getFullYear();
  const m  = pad2(date.getMonth() + 1);
  const d  = pad2(date.getDate());
  const h  = pad2(date.getHours());
  const mi = pad2(date.getMinutes());
  return y + "-" + m + "-" + d + " " + h + ":" + mi;
}

function fetchAlarm() {
  const sVal = document.getElementById("s_sdate")?.value || "";
  const eVal = document.getElementById("s_edate")?.value || "";

  // ✅ 기존과 동일하게 POST 폼 방식으로 전송 (Content-Type 자동)
  $.ajax({
    url: "/line/productionManagement/alarmRanking/list",
    method: "POST",
    dataType: "json",
    data: { s_sdate: sVal, s_edate: eVal },
    success: function (resp) {
      var arr = Array.isArray(resp) ? resp : (resp.data || resp.rows || (resp ? [resp] : []));
      allData = arr || [];
      renderTable(allData);
      updateKpi();
      updateFooter();
    },
    error: function (xhr) {
      console.error("fetchAlarm error", xhr);
    }
  });
}

function getRankClass(idx) {
  if (idx === 0) return "rank-1";
  if (idx === 1) return "rank-2";
  if (idx === 2) return "rank-3";
  return "rank-n";
}
// 상위 3개만 진한 단색, 나머지는 같은 색을 옅게
function getBarClass(idx) {
  return idx < 3 ? "bar-top" : "bar-n";
}

function renderTable(data) {
  var tbody = document.getElementById("alarmTbody");
  if (!tbody) return;
  tbody.innerHTML = "";

  if (!data || data.length === 0) {
    tbody.innerHTML = '<tr class="empty-row"><td colspan="4">조회된 데이터가 없습니다.</td></tr>';
    return;
  }

  // 최대값 (바 너비 계산용) · 합계 (비중 계산용)
  var maxCnt = 0, sumCnt = 0;
  for (var i = 0; i < data.length; i++) {
    var c = Number(data[i].cnt) || 0;
    if (c > maxCnt) maxCnt = c;
    sumCnt += c;
  }

  data.forEach(function (r, i) {
    var cnt = Number(r.cnt) || 0;
    var barWidth = maxCnt > 0 ? Math.round((cnt / maxCnt) * 100) : 0;
    var share = sumCnt > 0 ? (cnt / sumCnt * 100).toFixed(1) + "%" : "—";

    var tr = document.createElement("tr");

    // td 1
    var td1 = document.createElement("td");
    td1.style.textAlign = "right";
    td1.innerHTML = '<span class="rank-badge ' + getRankClass(i) + '">' + (i + 1) + "</span>";
    tr.appendChild(td1);

    // td 2
    var td2 = document.createElement("td");
    td2.className = "td-left";
    td2.innerHTML = '<span class="addr-tag">' + (r.a_addr || "-") + "</span>";
    tr.appendChild(td2);

    // td 3
    var td3 = document.createElement("td");
    td3.className = "td-left";
    td3.title = r.a_desc || "";
    td3.innerHTML = '<span class="desc-text">' + (r.a_desc || "") + "</span>";
    tr.appendChild(td3);

    // td 4
    var td4 = document.createElement("td");
    td4.innerHTML =
      '<div class="cnt-cell">' +
        '<div class="cnt-bar-wrap">' +
          '<div class="cnt-bar ' + getBarClass(i) + '" style="width:0%" data-w="' + barWidth + '%"></div>' +
        "</div>" +
        '<span class="cnt-val">' + cnt.toLocaleString() + "</span>" +
        '<span class="cnt-share">' + share + "</span>" +
      "</div>";
    tr.appendChild(td4);

    tbody.appendChild(tr);
  });

  // 바 너비 적용 (렌더 후)
  setTimeout(function () {
    var bars = tbody.querySelectorAll(".cnt-bar");
    bars.forEach(function (el) {
      el.style.width = el.getAttribute("data-w") || "0%";
    });
  }, 60);
}

function updateKpi() {
  var total = (allData || []).length;
  var sum = (allData || []).reduce(function (acc, r) {
    return acc + (Number(r.cnt) || 0);
  }, 0);

  var top = total ? (Number(allData[0].cnt) || 0) : 0;
  var topAddr = total ? (allData[0].a_addr || "-") : "-";
  var topDesc = total ? (allData[0].a_desc || "") : "";

  var elTotal = document.getElementById("kpi-total");
  var elTop   = document.getElementById("kpi-top");
  var elTopS  = document.getElementById("kpi-top-sub");
  var elSum   = document.getElementById("kpi-sum");

  if (elTotal) elTotal.textContent = total.toLocaleString();
  if (elTop)   elTop.textContent   = top.toLocaleString();
  if (elTopS)  elTopS.textContent  = "1위 " + topAddr + (topDesc ? " · " + topDesc : "");
  if (elSum)   elSum.textContent   = sum.toLocaleString();

  var s = document.getElementById("s_sdate")?.value || "-";
  var e = document.getElementById("s_edate")?.value || "-";

  var elP  = document.getElementById("kpi-period");
  var elPS = document.getElementById("kpi-period-sub");
  if (elP)  elP.textContent  = s.substring(0, 10);
  if (elPS) elPS.textContent = "~ " + e.substring(0, 10);
}

function updateFooter() {
  var now = new Date();
  var hh = pad2(now.getHours());
  var mm = pad2(now.getMinutes());
  var ss = pad2(now.getSeconds());

  var ft = document.getElementById("footer-time");
  var fi = document.getElementById("footer-info");
  if (ft) ft.textContent = hh + ":" + mm + ":" + ss;
  if (fi) fi.innerHTML = '총 <strong>' + (allData ? allData.length : 0) + "</strong>건";
}

function downloadExcel() {
  if (!allData || allData.length === 0) {
    alert("다운로드할 데이터가 없습니다.");
    return;
  }

  $("#excelOverlay").show();
  $("#excelLoading").show();

  try {
    var excelData = allData.map(function (r, i) {
      return {
        "순위": i + 1,
        "No": r.idx || "",
        "PLC주소": r.a_addr || "",
        "알람내용": r.a_desc || "",
        "발생 수": r.cnt || ""
      };
    });

    var ws = XLSX.utils.json_to_sheet(excelData);
    ws["!cols"] = [{ wch: 6 }, { wch: 8 }, { wch: 15 }, { wch: 50 }, { wch: 12 }];

    var wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "알람랭킹");

    var sdate = (document.getElementById("s_sdate")?.value || "").replace(/-/g, "");
    var edate = (document.getElementById("s_edate")?.value || "").replace(/-/g, "");

    XLSX.writeFile(wb, "알람랭킹_" + sdate + "_" + edate + ".xlsx");
    setTimeout(function () {
      $("#excelOverlay").hide();
      $("#excelLoading").hide();
    }, 500);
  } catch (e) {
    console.error(e);
    alert("엑셀 다운로드에 실패했습니다.");
    $("#excelOverlay").hide();
    $("#excelLoading").hide();
  }
}
</script>
</body>
</html>
