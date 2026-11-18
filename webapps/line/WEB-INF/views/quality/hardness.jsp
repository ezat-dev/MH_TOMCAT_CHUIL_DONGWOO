<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>경도 관리</title>
	<%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/>
</head>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
<style>
/* ===== 데모: 경도 관리 재설계 — 고밀도 운영 화면 (기능·ID·컬럼 동일) ===== */
:root {
  --imx-fg: oklch(24% 0.012 255); --imx-fg2: oklch(46% 0.012 255); --imx-fg3: oklch(64% 0.01 255);
  --imx-line: oklch(91.5% 0.006 255); --imx-line2: oklch(95.5% 0.004 255); --imx-hover: oklch(97.5% 0.003 255);
  --imx-bg: oklch(98.6% 0.002 255);
  --imx-accent: oklch(55% 0.13 255); --imx-accent-bg: oklch(55% 0.13 255 / 0.07);
  --imx-ok: oklch(60% 0.12 150); --imx-warn: oklch(64% 0.13 75); --imx-bad: oklch(56% 0.15 25); --imx-info: oklch(62% 0.12 240);
  --imx-sans: "IBM Plex Sans KR", "Pretendard", "Malgun Gothic", "맑은 고딕", sans-serif;
  --imx-mono: "IBM Plex Mono", Consolas, "Malgun Gothic", monospace;
}
body { background: var(--imx-bg); }
.hd, .modal, .pumbunModal { font-family: var(--imx-sans); font-size: 13px; color: var(--imx-fg); }
.hd *, .modal * { box-sizing: border-box; }
.mono { font-family: var(--imx-mono); font-variant-numeric: tabular-nums slashed-zero; }

/* 헤더 + 툴바 */
.hd { padding: 16px 24px 24px; }
/* 화면 높이에 맞춤: 페이지 스크롤 없이 표 카드가 남은 높이를 채움 */
html, body { height: 100%; margin: 0; overflow: hidden; }
main.hd { height: 100%; box-sizing: border-box; display: flex; flex-direction: column; }
main.hd > .view { flex: 1; min-height: 0; display: flex; flex-direction: column; }
main.hd > .view > #dataTable { flex: 1; min-height: 0; }
.hd-head { display: flex; align-items: center; gap: 16px; margin-bottom: 12px; }
.hd-title { display: flex; align-items: baseline; gap: 12px; min-width: 0; }
.hd-title h1 { margin: 0; font-size: 18px; font-weight: 600; white-space: nowrap; }
.hd-sub { color: var(--imx-fg3); font-size: 12px; white-space: nowrap; }
.button-container { display: flex; align-items: center; gap: 8px; margin-left: auto; }
.box1 { display: flex; align-items: center; gap: 8px; height: 36px; padding: 0 8px 0 12px; background: #fff;
  border: 1px solid var(--imx-line); border-radius: 6px; }
.daylabel { margin: 0; font-size: 12px; color: var(--imx-fg2); white-space: nowrap; }
.daySet, .dayselect { width: 104px; height: 28px; margin: 0; padding: 0 4px; border: 0; border-radius: 4px; background: transparent;
  font-family: var(--imx-mono); font-size: 13px; color: var(--imx-fg); text-align: center; cursor: pointer; }
.daySet:hover { background: var(--imx-hover); }
.daySet:focus { outline: 2px solid var(--imx-accent-bg); }
.hd-tilde { color: var(--imx-fg3); }

.hd .select-button, .hd .barcode-button, .hd .excel-button {
  display: inline-flex; align-items: center; gap: 8px; height: 36px; padding: 0 12px; margin: 0;
  border: 1px solid var(--imx-line); border-radius: 6px; background: #fff; color: var(--imx-fg);
  font-family: var(--imx-sans); font-size: 13px; font-weight: 500; cursor: pointer; transition: background-color 80ms; }
.hd .barcode-button:hover, .hd .excel-button:hover { background: var(--imx-hover); }
.hd .select-button { background: var(--imx-accent); border-color: var(--imx-accent); color: #fff; }
.hd .select-button:hover { background: oklch(50% 0.13 255); }
.hd .select-button .button-image { filter: brightness(0) invert(1); }
.button-image { width: 14px; height: 14px; opacity: .8; }
.hd kbd { font-family: var(--imx-mono); font-size: 11px; color: var(--imx-fg3); border: 1px solid var(--imx-line); border-radius: 4px; padding: 0 4px; }
.hd .select-button kbd { color: #fff; border-color: oklch(100% 0 0 / .4); }

/* 요약 줄 */
.hd-summary { display: flex; align-items: baseline; gap: 0; margin-bottom: 12px; padding: 0 4px; min-height: 24px; }
.hd-summary > div { display: flex; align-items: baseline; gap: 8px; padding: 0 16px; border-left: 1px solid var(--imx-line); }
.hd-summary > div:first-child { padding-left: 0; border-left: 0; }
.hd-summary dt { color: var(--imx-fg2); white-space: nowrap; }
.hd-summary dd { margin: 0; font-family: var(--imx-mono); font-size: 16px; font-weight: 500; font-variant-numeric: tabular-nums; }
.hd-summary dd.bad { color: var(--imx-bad); } .hd-summary dd.ok { color: var(--imx-ok); }
.hd-summary .hint { margin-left: auto; padding-right: 0; border: 0; color: var(--imx-fg3); font-size: 12px; }

/* 표 카드 */
.view { display: block; margin: 0; background: #fff; border: 1px solid var(--imx-line); border-radius: 8px; overflow: hidden; }
#dataTable.tabulator { border: 0; background: #fff; font-family: var(--imx-sans); font-size: 13px; }
#dataTable .tabulator-header { background: #fff; border-bottom: 1px solid var(--imx-line); color: var(--imx-fg2); font-weight: 500; }
#dataTable .tabulator-header .tabulator-col { background: #fff; border-right: 1px solid var(--imx-line2); }
#dataTable .tabulator-header .tabulator-col .tabulator-col-content { padding: 6px 8px; }
#dataTable .tabulator-col-title { font-size: 12px; font-weight: 500; color: var(--imx-fg2); }
#dataTable .tabulator-col-group > .tabulator-col-content .tabulator-col-title { color: var(--imx-fg); font-weight: 600; }
#dataTable .tabulator-col.tabulator-col-group > .tabulator-col-content { border-bottom: 1px solid var(--imx-line2); }
#dataTable .tabulator-header-filter input, #dataTable .tabulator-header-filter select {
  height: 26px; padding: 0 8px !important; border: 1px solid var(--imx-line); border-radius: 4px; background: var(--imx-bg);
  font-family: var(--imx-sans); font-size: 12px; color: var(--imx-fg); }
#dataTable .tabulator-header-filter input:focus { outline: 0; border-color: var(--imx-accent); background: #fff; }
#dataTable .tabulator-row { min-height: 32px; border-bottom: 1px solid var(--imx-line2); background: #fff; color: var(--imx-fg); }
#dataTable .tabulator-row .tabulator-cell { padding: 0 8px; height: 32px; line-height: 32px; border-right: 1px solid var(--imx-line2); }
#dataTable .tabulator-row.row-lot-1 { background: oklch(98.4% 0.004 255); }
#dataTable .tabulator-row.tabulator-selectable:hover, #dataTable .tabulator-row:hover { background: var(--imx-hover); cursor: default; }
#dataTable .tabulator-row.row_select { background: var(--imx-accent-bg) !important; box-shadow: inset 2px 0 0 var(--imx-accent); }
#dataTable .tabulator-cell[tabulator-field="w_ci_lot"], #dataTable .tabulator-cell[tabulator-field="item_no"],
#dataTable .tabulator-cell[tabulator-field^="quench_"], #dataTable .tabulator-cell[tabulator-field^="temper_"],
#dataTable .tabulator-cell[tabulator-field^="h_val"], #dataTable .tabulator-cell[tabulator-field^="img_url"] {
  font-family: var(--imx-mono); font-variant-numeric: tabular-nums slashed-zero; }
#dataTable .tabulator-cell[tabulator-field^="img_url"] { color: var(--imx-fg3); font-size: 12px; }
#dataTable .tabulator-placeholder span { color: var(--imx-fg3) !important; font-size: 13px; font-weight: 400; }

/* 판정: 셀 배경은 중립, 글자색 + 점만 */
.h-bad { color: var(--imx-bad); font-weight: 500; }
.hd-dot { display: inline-block; width: 6px; height: 6px; border-radius: 50%; margin-right: 6px; vertical-align: 1px; background: var(--imx-fg3); }
.hd-dot.q { background: var(--imx-bad); } .hd-dot.t { background: var(--imx-info); }
.q-red, .q-blue { font-weight: 600; } .q-red { color: var(--imx-bad); } .q-blue { color: var(--imx-info); }
.row_select { background-color: var(--imx-accent-bg) !important; }
.row-lot-0 { background-color: #fff; }

/* 모달 */
.modal { display: none; position: fixed; inset: 0; width: 100%; height: 100%; background: oklch(20% 0.01 255 / .45); z-index: 1000; }
.modal.show { display: block; opacity: 1; }
.modal-content { background: #fff; width: 100%; max-width: 1040px; max-height: calc(100vh - 32px); overflow-y: auto; margin: 16px auto 0;
  padding: 0; border: 1px solid var(--imx-line); border-radius: 8px; position: relative; box-shadow: none;
  transform: scale(.98); transition: transform 150ms ease-out; }
.modal.show .modal-content { transform: scale(1); }
.close { position: absolute; right: 12px; top: 10px; width: 28px; height: 28px; line-height: 26px; text-align: center; border-radius: 6px;
  background: transparent; color: var(--imx-fg3); font-size: 20px; font-weight: 400; cursor: pointer; z-index: 2; }
.close:hover { background: var(--imx-hover); color: var(--imx-fg); }
.hd-mhead { position: sticky; top: 0; z-index: 1; background: #fff; padding: 12px 56px 12px 20px; border-bottom: 1px solid var(--imx-line); }
#hardnessTitle { margin: 0; font-size: 16px !important; font-weight: 600; }
.hd-mhead p { margin: 4px 0 0; font-size: 12px; color: var(--imx-fg3); }
.modal-content hr { display: none; }
.modal-content form { display: flex; flex-direction: column; padding: 16px 20px 0; }
.hd-sec { margin-bottom: 16px; }
.hd-sec > h3, .zone-box > .hd-zt { display: flex; align-items: baseline; gap: 8px; margin: 0 0 8px; font-size: 13px; font-weight: 600; color: var(--imx-fg); }
.hd-sec > h3 small, .zone-box > .hd-zt small { font-size: 12px; font-weight: 400; color: var(--imx-fg3); }

.form-grid-4 { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 0; border: 1px solid var(--imx-line); border-radius: 6px; overflow: hidden; }
.form-grid-4 .grid-item { padding: 8px 12px; border-right: 1px solid var(--imx-line2); border-bottom: 1px solid var(--imx-line2); }
.form-grid-4 .grid-item:nth-child(4n) { border-right: 0; }
.form-grid-4 .grid-item:nth-last-child(-n+4) { border-bottom: 0; }
.grid-item { display: flex; flex-direction: column; min-width: 0; }
.modal-content .grid-item label { margin: 0 0 4px; font-size: 12px; font-weight: 500; color: var(--imx-fg2); }
.modal-content .form-grid-4 input { width: 100%; height: 24px; margin: 0; padding: 0; border: 0; background: transparent;
  font-size: 13px; color: var(--imx-fg); text-align: left; }
.modal-content .form-grid-4 input[name="w_ci_lot"], .modal-content .form-grid-4 input[name="regtime"], .modal-content .form-grid-4 input[name="item_no"],
.modal-content .form-grid-4 input[type="number"], .modal-content .form-grid-4 input[name="w_plan_cnt"] { font-family: var(--imx-mono); font-variant-numeric: tabular-nums; }

.image-preview-area { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; margin: 0; }
.image-box { display: flex; flex-direction: column; gap: 4px; padding: 8px; border: 1px solid var(--imx-line); border-radius: 6px; min-width: 0; }
.img-title { font-size: 12px; font-weight: 500; color: var(--imx-fg2); margin: 0; }
.preview-img { width: 100%; height: 180px; object-fit: contain; border-radius: 4px; border: 0; background: var(--imx-bg); cursor: zoom-in; display: none; transition: none; }
.preview-img:hover { transform: none; outline: 1px solid var(--imx-line); }

.scroll-area { overflow: visible; padding: 0; }
.form-grid.vertical { display: flex; flex-direction: column; gap: 0; border: 1px solid var(--imx-line); border-radius: 6px; overflow: hidden; }
.zone-box { display: grid; grid-template-columns: 168px minmax(0, 1fr); align-items: center; gap: 12px; padding: 8px 12px;
  border: 0; border-top: 1px solid var(--imx-line2); border-radius: 0; box-shadow: none; background: #fff; }
.zone-box:first-child { border-top: 0; }
.zone-box > .hd-zt { flex-direction: column; gap: 0; margin: 0; }
.zone-cho, .zone-jung, .zone-jong, .zone-test, .zone-surface, .zone-twist { background: #fff; border-left: 0; }
.zone-grid { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 8px; }
.zone-grid .grid-item label { margin: 0 0 2px; font-size: 11px; font-weight: 400; color: var(--imx-fg3); }
.zone-grid input, .zone-grid select { width: 100%; height: 32px; margin: 0; padding: 0 8px; border: 1px solid var(--imx-line); border-radius: 4px;
  background: #fff; font-family: var(--imx-mono); font-size: 14px; font-variant-numeric: tabular-nums; color: var(--imx-fg); text-align: right; }
.zone-grid select { font-family: var(--imx-sans); text-align: left; }
.zone-grid input:focus, .zone-grid select:focus { outline: 0; border-color: var(--imx-accent); box-shadow: 0 0 0 2px var(--imx-accent-bg); }
.zone-grid .h-out { color: var(--imx-bad); border-color: var(--imx-bad); font-weight: 500; }
.h-in { color: var(--imx-fg); }

.hd-mfoot { position: sticky; bottom: 0; display: flex; align-items: center; justify-content: flex-end; gap: 8px; margin: 16px -20px 0; padding: 12px 20px;
  background: #fff; border-top: 1px solid var(--imx-line); }
.hd-mfoot .note { margin-right: auto; font-size: 12px; color: var(--imx-fg3); }
.modal-content .hd-mfoot button { height: 36px; margin: 0; padding: 0 16px; border: 1px solid var(--imx-line); border-radius: 6px; background: #fff;
  color: var(--imx-fg); font-family: var(--imx-sans); font-size: 13px; font-weight: 500; cursor: pointer; transition: background-color 80ms; }
.modal-content .hd-mfoot button:hover { background: var(--imx-hover); }
.modal-content .hd-mfoot #saveCorrStatus { background: var(--imx-accent); border-color: var(--imx-accent); color: #fff; }
.modal-content .hd-mfoot #saveCorrStatus:hover { background: oklch(50% 0.13 255); }

/* 품번 모달 (현재 미사용, 기존 규칙 유지) */
.pumbunModal { display: none; position: fixed; inset: 0; background: oklch(20% 0.01 255 / .45); }
.pumbunModal.show { display: block; }
.pumbun-modal-content { background: #fff; width: 60%; max-width: 1200px; height: 80vh; overflow-y: auto; margin: 6% auto 0; padding: 20px;
  border: 1px solid var(--imx-line); border-radius: 8px; }
.closePumbun { position: absolute; right: 12px; top: 10px; font-size: 20px; cursor: pointer; }
</style>


<body>
    <main class="main hd">
        <header class="hd-head">
            <div class="hd-title">
                <h1>경도 관리</h1>
                <span class="hd-sub">행을 더블클릭하면 측정값을 입력합니다</span>
            </div>

            <div class="button-container">
               <div class="box1">
	            <label class="daylabel" for="m_sdate">등록일자</label>
	            <input type="text" id="m_sdate" class="dayselect daySet"/>
	            <span class="hd-tilde">~</span>
	            <input type="text" id="m_edate" class="dayselect daySet"/>
			</div>
                <button class="select-button">
                    <img src="/line/css/tabBar/search-icon.png" alt="" class="button-image">조회
                </button>
                    <button class="barcode-button">
			        <img src="/line/css/tabBar/barcode-icon.png" alt="" class="button-image">스캔
			    </button>
               <!--  <button class="insert-button">
                    <img src="/line/css/tabBar/add-outline.png" alt="insert" class="button-image">추가
                </button>
                <button class="delete-button">
				    <img src="/line/css/tabBar/xDel3.png" alt="delete" class="button-image"> 삭제
				</button>


                <button class="excel-download-button">
                    <img src="/line/css/tabBar/excel-icon.png" alt="excel" class="button-image">엑셀다운로드
                </button>
                 -->
                 <button class="excel-button">
                    <img src="/line/css/tabBar/excel-icon.png" alt="" class="button-image" >Download
                </button>
            </div>
        </header>

        <dl class="hd-summary" id="hdSummary">
            <div><dt>LOT</dt><dd id="hdLot">—</dd></div>
            <div><dt>측정 행</dt><dd id="hdRows">—</dd></div>
            <div><dt>규격 이탈 행</dt><dd id="hdOut">—</dd></div>
            <div><dt>이탈 측정값</dt><dd id="hdOutVal">—</dd></div>
            <div class="hint">규격: Quenching 행은 퀜칭 하한~상한, Tempering 행은 템퍼 하한~상한 · 이탈값은 빨간 글자</div>
        </dl>

        <div class="view">
            <div id="dataTable"></div>
        </div>
    </main>

<div id="modalContainer" class="modal">
  <div class="modal-content">
    <span class="close" title="닫기">&times;</span>
    <!-- 추가, 수정 -->
<div class="hd-mhead">
<h2 id="hardnessTitle">
    <span id="hardnessType"></span> 경도 측정값 등록
</h2>
<p>규격을 벗어난 값은 입력 즉시 빨간색으로 표시됩니다 · Enter 로 다음 칸 이동</p>
</div>

<hr />

<form id="corrForm" autocomplete="off">

<!--   <label>LOT 번호</label>
  <input type="text" name="w_ci_lot">

  <label>등록시간</label>
  <input type="text" name="regtime" class="daySet" style="text-align:left;">

 -->

<section class="hd-sec">
<h3>LOT 정보</h3>
<div class="form-grid-4">

  <div class="grid-item">
    <label>LOT 번호</label>
    <input type="text" name="w_ci_lot" readonly>
  </div>

  <div class="grid-item">
    <label>등록시간</label>
    <input type="text" name="regtime" readonly>
  </div>

  <div class="grid-item">
    <label>거래처</label>
    <input type="text" name="cust_name" readonly>
  </div>

  <div class="grid-item">
    <label>품명</label>
    <input type="text" name="item_name" readonly>
  </div>

  <div class="grid-item">
    <label>품번</label>
    <input type="text" name="item_no" readonly>
  </div>

  <div class="grid-item">
    <label>규격</label>
    <input type="text" name="spec" readonly>
  </div>

  <div class="grid-item">
    <label>재질</label>
    <input type="text" name="texture" readonly>
  </div>

  <div class="grid-item">
    <label>계획수량</label>
    <input type="text" name="w_plan_cnt" readonly>
  </div>

  <div class="grid-item">
    <label>퀜칭 하한</label>
    <input type="number" name="quench_low" readonly>
  </div>

  <div class="grid-item">
    <label>퀜칭 상한</label>
    <input type="number" name="quench_high" readonly>
  </div>

  <div class="grid-item">
    <label>템퍼 하한</label>
    <input type="number" name="temper_low" readonly>
  </div>

  <div class="grid-item">
    <label>템퍼 상한</label>
    <input type="number" name="temper_high" readonly>
  </div>
</div>
</section>

<section class="hd-sec">
<h3>검사품 사진 <small>클릭하면 새 창에서 원본</small></h3>
<div class="image-preview-area">
    <div class="image-box">
        <div class="img-title">검사품 사진3</div>
        <img id="preview_img_3" class="preview-img" />
    </div>

    <div class="image-box">
        <div class="img-title">검사품 사진4</div>
        <img id="preview_img_4" class="preview-img" />
    </div>

    <div class="image-box">
        <div class="img-title">검사품 사진5</div>
        <img id="preview_img_5" class="preview-img" />
    </div>
</div>
</section>

<!-- 경도 입력 영역 -->
<section class="hd-sec">
<h3>경도 측정값 <small>HRC</small></h3>
<div class="scroll-area">

  <div class="form-grid vertical">

    <!-- 초몰 -->
    <div class="zone-box zone-cho">
      <div class="hd-zt">초몰<small>경도 1–5</small></div>
      <div class="zone-grid">
        <div class="grid-item"><label>경도1</label><input type="number" step="0.01" name="h_val1"></div>
        <div class="grid-item"><label>경도2</label><input type="number" step="0.01" name="h_val2"></div>
        <div class="grid-item"><label>경도3</label><input type="number" step="0.01" name="h_val3"></div>
        <div class="grid-item"><label>경도4</label><input type="number" step="0.01" name="h_val4"></div>
        <div class="grid-item"><label>경도5</label><input type="number" step="0.01" name="h_val5"></div>
      </div>
    </div>

    <div class="zone-box zone-jung">
      <div class="hd-zt">중몰<small>경도 6–10</small></div>
      <div class="zone-grid">
        <div class="grid-item"><label>경도6</label><input type="number" step="0.01" name="h_val6"></div>
        <div class="grid-item"><label>경도7</label><input type="number" step="0.01" name="h_val7"></div>
        <div class="grid-item"><label>경도8</label><input type="number" step="0.01" name="h_val8"></div>
        <div class="grid-item"><label>경도9</label><input type="number" step="0.01" name="h_val9"></div>
        <div class="grid-item"><label>경도10</label><input type="number" step="0.01" name="h_val10"></div>
      </div>
    </div>

    <div class="zone-box zone-jong">
      <div class="hd-zt">종몰<small>경도 11–15</small></div>
      <div class="zone-grid">
        <div class="grid-item"><label>경도11</label><input type="number" step="0.01" name="h_val11"></div>
        <div class="grid-item"><label>경도12</label><input type="number" step="0.01" name="h_val12"></div>
        <div class="grid-item"><label>경도13</label><input type="number" step="0.01" name="h_val13"></div>
        <div class="grid-item"><label>경도14</label><input type="number" step="0.01" name="h_val14"></div>
        <div class="grid-item"><label>경도15</label><input type="number" step="0.01" name="h_val15"></div>
      </div>
    </div>

    <div class="zone-box zone-test">
      <div class="hd-zt">검사실<small>경도 16–20</small></div>
      <div class="zone-grid">
        <div class="grid-item"><label>경도16</label><input type="number" step="0.01" name="h_val16"></div>
        <div class="grid-item"><label>경도17</label><input type="number" step="0.01" name="h_val17"></div>
        <div class="grid-item"><label>경도18</label><input type="number" step="0.01" name="h_val18"></div>
        <div class="grid-item"><label>경도19</label><input type="number" step="0.01" name="h_val19"></div>
        <div class="grid-item"><label>경도20</label><input type="number" step="0.01" name="h_val20"></div>
      </div>
    </div>

    <!-- Tempering 전용: 표면경도 / 비틀림 시험 -->
    <div class="zone-box zone-surface" id="zoneSurface" style="display:none;">
      <div class="hd-zt">표면경도<small>HRC 40~46 · 깊이 0.05</small></div>
      <div class="zone-grid">
        <div class="grid-item"><label>표면경도1</label><input type="number" step="0.01" name="h_val21"></div>
        <div class="grid-item"><label>표면경도2</label><input type="number" step="0.01" name="h_val22"></div>
        <div class="grid-item"><label>표면경도3</label><input type="number" step="0.01" name="h_val23"></div>
        <div class="grid-item"><label>표면경도4</label><input type="number" step="0.01" name="h_val24"></div>
        <div class="grid-item"><label>표면경도5</label><input type="number" step="0.01" name="h_val25"></div>
      </div>
    </div>

    <div class="zone-box zone-twist" id="zoneTwist" style="display:none;">
      <div class="hd-zt">비틀림 시험<small>90&deg; 미만에서 파단 않을 것</small></div>
      <div class="zone-grid">
        <div class="grid-item"><label>비틀림1</label>
          <select name="h_val26_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
        <div class="grid-item"><label>비틀림2</label>
          <select name="h_val27_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
        <div class="grid-item"><label>비틀림3</label>
          <select name="h_val28_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
        <div class="grid-item"><label>비틀림4</label>
          <select name="h_val29_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
        <div class="grid-item"><label>비틀림5</label>
          <select name="h_val30_s"><option value="">선택</option><option value="OK">OK</option><option value="NG">NG</option></select>
        </div>
      </div>
    </div>

  </div>
</div>
</section>

  <input type="hidden" name="idx" value="0" />
  <hr />
  <div class="hd-mfoot">
    <span class="note">저장하면 목록이 다시 조회됩니다</span>
    <button type="button" id="closeModal">닫기</button>
    <button type="submit" id="saveCorrStatus">저장</button>
  </div>
</form>


  </div>
</div>



  <script>
let now_page_code = "e06";

var dataTable;
var selectedRowData = null;

$(function() {
    // 기본 날짜 세팅
    $("#m_sdate").val(todayDate()); // 어제
    $("#m_edate").val(todayDate());   // 오늘

    // Tabulator 초기화
    initDataTable();

    // 초기 데이터 로드
    gethardnessList();
});


$(document).on('input change', 'input[name^="h_val"], select[name^="h_val"]', function () {
    validateHardnessRange();
});


$(document).on('keydown', '#corrForm input', function (e) {
    if (e.key === 'Enter') {
        e.preventDefault(); // submit 차단

        const inputs = $('#corrForm')
            .find('input:visible:not([readonly]):not([disabled])');

        const idx = inputs.index(this);

        if (idx > -1 && idx < inputs.length - 1) {
            inputs.eq(idx + 1).focus();
        }
    }
});



// =====================
// 이벤트 바인딩
// =====================
$('.select-button').click(function() {
    gethardnessList();
});

$('.insert-button').click(function() {
    selectedRowData = null;
    $('#corrForm')[0].reset();
    $("input[name='m_date']").val(todayDate());
    $('#modalContainer').show().addClass('show');
});

$('.close, #closeModal').click(function() {
    $('#corrForm')[0].reset();
    $('#modalContainer').removeClass('show').hide();
});

$('#saveCorrStatus').click(function(event) {
    event.preventDefault();
    var formData = new FormData($('#corrForm')[0]);

    $.ajax({
        url: "/line/quality/hardness/update",
        type: "POST",
        data: formData,
        processData: false,
        contentType: false,
        success: function(result) {
            if(result.status === "success"){
                alert("저장되었습니다!");
                $('#modalContainer').hide();
                gethardnessList();
                selectedRowData = null;
            } else {
                alert("저장 실패: " + result.message);
            }
        },
        error: function() {
            alert('저장 중 오류가 발생했습니다.');
        }
    });
});

// =====================
// 함수 정의
// =====================
     let lastLot = null;
        let colorToggle = 0;

// 데모: 행의 구분(Quenching/Tempering)에 맞는 규격으로 이탈값 판정 — 표시 전용
function hdSpec(d) { return d.q_or_tp === 'Tempering 경도' ? [d.temper_low, d.temper_high] : [d.quench_low, d.quench_high]; }
function hdOut(d, f) {
    var v = d[f], s = hdSpec(d);
    if (v === '' || v == null || s[0] == null || s[1] == null || s[0] === '' || s[1] === '') return false;
    var n = Number(v);
    return !isNaN(n) && (n < Number(s[0]) || n > Number(s[1]));
}
function hFmt(cell) {
    var v = cell.getValue();
    if (v === '' || v == null) return '';
    var t = isNaN(Number(v)) ? v : Number(v).toFixed(1);   // 표시만 소수 1자리 고정 (다운로드는 원값)
    return hdOut(cell.getRow().getData(), cell.getField()) ? '<span class="h-bad">' + t + '</span>' : t;
}
function qFmt(cell) {
    var v = cell.getValue() || '';
    return '<i class="hd-dot ' + (v.indexOf('Quenching') === 0 ? 'q' : v.indexOf('Tempering') === 0 ? 't' : '') + '"></i>' + v;
}
function hdSummary(rows) {
    var lots = {}, out = 0, outVal = 0;
    rows.forEach(function (d) {
        lots[d.w_ci_lot] = 1;
        var c = 0;
        for (var i = 1; i <= 20; i++) if (hdOut(d, 'h_val' + i)) c++;
        if (c) { out++; outVal += c; }
    });
    $('#hdLot').text(Object.keys(lots).length);
    $('#hdRows').text(rows.length);
    $('#hdOut').text(out).toggleClass('bad', out > 0);
    $('#hdOutVal').text(outVal).toggleClass('bad', outVal > 0);
}

// Tabulator 초기화
function initDataTable(){
    dataTable = new Tabulator('#dataTable', {
        height: '100%',
        dataLoaded: function (data) { hdSummary(data || []); },
        layout: 'fitDataFill',
        headerSort: false,
        reactiveData: true,
        columnHeaderVertAlign: "middle",
        rowVertAlign: "middle",
        headerHozAlign: 'center',
        placeholder: "조회된 데이터가 없습니다.",
        columns: [
/*             { 
                title: "No", 
                field: "no", 
                hozAlign: "center", 
                headerHozAlign: "center",
                formatter: "rownum", 
                width: 100
            }, */
            { 
                title: "idx", 
                field: "idx", 
                visible: false,      // 화면에는 안 보임
                headerSort: true     // 정렬 기능은 활성화
            },
            { 
                title: "LOT 번호",
                field: "w_ci_lot",
                width: 150,
                hozAlign: "left",
                headerHozAlign: "center",
                headerFilter: "input",
                headerFilterPlaceholder: "검색..."
            },
            { 
                title: "고객명",
                field: "cust_name",
                width: 120,
                hozAlign: "left",
                headerHozAlign: "center",
                headerFilter: "input",
                headerFilterPlaceholder: "검색..."
            },
            { 
                title: "품명",
                field: "item_name",
                width: 250,
                hozAlign: "left",
                headerHozAlign: "center",
                headerFilter: "input",
                headerFilterPlaceholder: "검색..."
            },
            { 
                title: "품번",
                field: "item_no",
                width: 120,
                hozAlign: "left",
                headerHozAlign: "center",
                headerFilter: "input",
                headerFilterPlaceholder: "검색..."
            },
            { 
                title: "구분",
                field: "q_or_tp",
                width: 140,
                hozAlign: "left",
                formatter: qFmt,
                headerHozAlign: "center",
                headerFilter: "select",
                headerFilterPlaceholder: "전체",
                headerFilterParams: {
                    values: {
                        "": "전체",
                        "Quenching 경도": "Quenching 경도",
                        "Tempering 경도": "Tempering 경도"
                    }
                }
            },

            { title: "퀜칭 하한", field: "quench_low", width: 90, hozAlign: "right" },
            { title: "퀜칭 상한", field: "quench_high", width: 90, hozAlign: "right" },
            { title: "템퍼 하한", field: "temper_low", width: 90, hozAlign: "right" },
            { title: "템퍼 상한", field: "temper_high", width: 90, hozAlign: "right" },
            {
                title: "초몰",
                headerHozAlign: "center",
                columns: [
                  { title: "경도1", field: "h_val1", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도2", field: "h_val2", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도3", field: "h_val3", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도4", field: "h_val4", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도5", field: "h_val5", width: 90, hozAlign: "right", formatter: hFmt }
                ]
              },

              {
                title: "중몰",
                headerHozAlign: "center",
                columns: [
                  { title: "경도6", field: "h_val6", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도7", field: "h_val7", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도8", field: "h_val8", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도9", field: "h_val9", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도10", field: "h_val10", width: 90, hozAlign: "right", formatter: hFmt }
                ]
              },

              {
                title: "종몰",
                headerHozAlign: "center",
                columns: [
                  { title: "경도11", field: "h_val11", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도12", field: "h_val12", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도13", field: "h_val13", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도14", field: "h_val14", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도15", field: "h_val15", width: 90, hozAlign: "right", formatter: hFmt }
                ]
              },

              {
                title: "검사실",
                headerHozAlign: "center",
                columns: [
                  { title: "경도16", field: "h_val16", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도17", field: "h_val17", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도18", field: "h_val18", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도19", field: "h_val19", width: 90, hozAlign: "right", formatter: hFmt },
                  { title: "경도20", field: "h_val20", width: 90, hozAlign: "right", formatter: hFmt }
                ]
              },
/*               { title: "거래처", field: "cust_name", width: 90, hozAlign: "center" },
              { title: "품명", field: "item_name", width: 120, hozAlign: "center" },
              { title: "품번", field: "item_no", width: 120, hozAlign: "center" },
              { title: "규격", field: "spec", width: 120, hozAlign: "center" },
              { title: "재질", field: "texture", width: 80, hozAlign: "center" }, */
              { title: "경도_이미지3", field: "img_url_3", width: 90, hozAlign: "right" },
              { title: "경도_이미지4", field: "img_url_4", width: 90, hozAlign: "right" },
              { title: "경도_이미지5", field: "img_url_5", width: 90, hozAlign: "right" },

            
        ],
   

        rowFormatter: function(row) {
            const data = row.getData();
            const el = row.getElement();

            // 재렌더 대비 초기화
            el.classList.remove("row-lot-0", "row-lot-1");

            // LOT가 바뀌는 시점에만 색 전환
            if (data.w_ci_lot !== lastLot) {
                colorToggle = (colorToggle + 1) % 2;
                lastLot = data.w_ci_lot;
            }

            el.classList.add("row-lot-" + colorToggle);
        },


        rowClick: function(e, row) {
            $('#dataTable .tabulator-row').removeClass('row_select');
            row.getElement().classList.add('row_select');
            selectedRowData = row.getData();
        },
        rowDblClick: function(e, row) {
            const d = row.getData();
            selectedRowData = d;

            const $type = $('#hardnessType');

            if (d.q_or_tp === 'Quenching 경도') {
                $type
                    .text('Quenching')
                    .removeClass('q-blue')
                    .addClass('q-red');
                $('#zoneSurface, #zoneTwist').hide();
            } else if (d.q_or_tp === 'Tempering 경도') {
                $type
                    .text('Tempering')
                    .removeClass('q-red')
                    .addClass('q-blue');
                $('#zoneSurface, #zoneTwist').show();
            } else {
                // 예외 대비
                $type.text(d.q_or_tp).removeClass('q-red q-blue');
                $('#zoneSurface, #zoneTwist').hide();
            }






            
            $('#corrForm')[0].reset();

            $('input[name="idx"]').val(d.idx);
            $('input[name="w_ci_lot"]').val(d.w_ci_lot);
            $('input[name="regtime"]').val(d.regtime);
            $('input[name="cust_name"]').val(d.cust_name);
            $('input[name="item_name"]').val(d.item_name);
            $('input[name="item_no"]').val(d.item_no);
            $('input[name="spec"]').val(d.spec);
            $('input[name="texture"]').val(d.texture);
            $('input[name="w_plan_cnt"]').val(d.w_plan_cnt);
            $('input[name="quench_low"]').val(d.quench_low);
            $('input[name="quench_high"]').val(d.quench_high);
            $('input[name="temper_low"]').val(d.temper_low);
            $('input[name="temper_high"]').val(d.temper_high);

            setPreviewImage("preview_img_3", d.img_url_3);
            setPreviewImage("preview_img_4", d.img_url_4);
            setPreviewImage("preview_img_5", d.img_url_5);
            // 경도 자동 매핑
            for (let i = 1; i <= 25; i++) {
                $('input[name="h_val' + i + '"]').val(d['h_val' + i]);
            }
            for (let i = 26; i <= 30; i++) {
                $('select[name="h_val' + i + '_s"]').val(d['h_val' + i + '_s'] || '');
            }

            $('#modalContainer').show().addClass('show');
            validateHardnessRange();

        }

    });
}

// Hardness 조회
function gethardnessList(){
    if(!dataTable) return;

    $.ajax({
        url: "/line/quality/hardness/list",
        type: "POST",
        dataType: "json",
        data:{
            "m_sdate": $("#m_sdate").val(),
            "m_edate": $("#m_edate").val()
        },
        success:function(result){
            if(result.status === "success"){
                dataTable.setData(result.data || []);
            } else {
                alert("조회 실패: " + result.message);
            }
        },
        error:function(xhr, status, error){
            console.error(xhr.responseText);
            alert("조회 중 오류 발생");
        }
    });
}

// 날짜 관련 함수
function todayDate() {
    var d = new Date();
    return d.getFullYear() + "-" + pad(d.getMonth()+1) + "-" + pad(d.getDate());
}

function yesterDate() {
    var d = new Date();
    d.setDate(d.getDate()-1);
    return d.getFullYear() + "-" + pad(d.getMonth()+1) + "-" + pad(d.getDate());
}

function pad(n){ return n<10 ? "0"+n : n; }




$('.barcode-button').click(function() {
    var lotNo = prompt("스캔된 LOT 번호를 입력하세요:");
    if(!lotNo) return;

    $.ajax({
        url: "/line/quality/hardness/list", // 기존 조회 컨트롤러 재사용
        type: "POST",
        dataType: "json",
        data: {
            "m_sdate": "",   // 전체 조회 가능
            "m_edate": "",
            "w_ci_lot": lotNo // Lot 번호 기준 필터
        },
        success:function(result){
            if(result.status === "success"){
                dataTable.setData(result.data || []);
                if(result.data && result.data.length > 0){
                    var d = result.data[0];
                    selectedRowData = d;

                    $('#corrForm')[0].reset();

                    var $type = $('#hardnessType');
                    if (d.q_or_tp === 'Quenching 경도') {
                        $type.text('Quenching').removeClass('q-blue').addClass('q-red');
                        $('#zoneSurface, #zoneTwist').hide();
                    } else if (d.q_or_tp === 'Tempering 경도') {
                        $type.text('Tempering').removeClass('q-red').addClass('q-blue');
                        $('#zoneSurface, #zoneTwist').show();
                    } else {
                        $type.text(d.q_or_tp).removeClass('q-red q-blue');
                        $('#zoneSurface, #zoneTwist').hide();
                    }

                    $('input[name="idx"]').val(d.idx);
                    $('input[name="w_ci_lot"]').val(d.w_ci_lot);
                    $('input[name="regtime"]').val(d.regtime);

                    $('input[name="cust_name"]').val(d.cust_name);
                    $('input[name="item_name"]').val(d.item_name);
                    $('input[name="item_no"]').val(d.item_no);
                    $('input[name="spec"]').val(d.spec);
                    $('input[name="texture"]').val(d.texture);
                    $('input[name="w_plan_cnt"]').val(d.w_plan_cnt);
                    $('input[name="quench_low"]').val(d.quench_low);
                    $('input[name="quench_high"]').val(d.quench_high);
                    $('input[name="temper_low"]').val(d.temper_low);
                    $('input[name="temper_high"]').val(d.temper_high);

                    for (let i = 1; i <= 25; i++) {
                        $('input[name="h_val' + i + '"]').val(d['h_val' + i]);
                    }
                    for (let i = 26; i <= 30; i++) {
                        $('select[name="h_val' + i + '_s"]').val(d['h_val' + i + '_s'] || '');
                    }

                    setPreviewImage("preview_img_3", d.img_url_3);
                    setPreviewImage("preview_img_4", d.img_url_4);
                    setPreviewImage("preview_img_5", d.img_url_5);

                    $('#modalContainer').show().addClass('show');
                    validateHardnessRange();
                } else {
                    alert("해당 LOT 번호 데이터가 없습니다.");
                }
            } else {
                alert("조회 실패: " + result.message);
            }
        },

        error:function(xhr, status, error){
            console.error(xhr.responseText);
            alert("조회 중 오류 발생");
        }
    });
});


//=====================
//경도 합격/불합격 판정
//=====================
function validateHardnessRange() {

 const type = $('#hardnessType').text(); // Quenching / Tempering
 let low, high;

 if (type === 'Quenching') {
     low  = Number($('input[name="quench_low"]').val());
     high = Number($('input[name="quench_high"]').val());
 } else if (type === 'Tempering') {
     low  = Number($('input[name="temper_low"]').val());
     high = Number($('input[name="temper_high"]').val());
 } else {
     return;
 }

 let isPass = true;

 for (let i = 1; i <= 20; i++) {
     const $input = $('input[name="h_val' + i + '"]');
     const val = Number($input.val());

     if (isNaN(val)) {
         $input.removeClass('h-out');
         continue;
     }

     if (val < low || val > high) {
         $input.addClass('h-out');
         isPass = false;
     } else {
         $input.removeClass('h-out');
     }
 }

 // 표면경도 (HRC 40~46, 깊이 0.05) - Tempering 전용, 고정 판정범위
 const SURFACE_LOW = 40, SURFACE_HIGH = 46;
 for (let i = 21; i <= 25; i++) {
     const $input = $('input[name="h_val' + i + '"]');
     const raw = $input.val();
     const val = Number(raw);

     if (raw === '' || isNaN(val)) {
         $input.removeClass('h-out');
         continue;
     }

     if (val < SURFACE_LOW || val > SURFACE_HIGH) {
         $input.addClass('h-out');
         isPass = false;
     } else {
         $input.removeClass('h-out');
     }
 }

 // 비틀림 시험 (90° 미만 파단 없을 것) - NG면 불합격
 for (let i = 26; i <= 30; i++) {
     const $select = $('select[name="h_val' + i + '_s"]');

     if ($select.val() === 'NG') {
         $select.addClass('h-out');
         isPass = false;
     } else {
         $select.removeClass('h-out');
     }
 }

 // 결과 저장
 $('input[name="pass_yn"]').val(isPass ? 'Y' : 'N');
}


$('.excel-button').on('click', function () {
    if (!dataTable) return;

    dataTable.download("xlsx", "경도측정결과.xlsx", {
        sheetName: "Hardness",

        documentProcessing: function (workbook) {
            const sheet = workbook.Sheets["Hardness"];

            sheet["!cols"] = [
                { wch: 14 }, // LOT
                { wch: 14 }, // 고객명
                { wch: 14 }, // 품명
                { wch: 14 }, // 품번
                { wch: 14 }, // 구분

                // 경도 1~20
                { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 },
                { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 },
                { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 },
                { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 }, { wch: 6 },

                { wch: 9 }, // 퀜칭 하한
                { wch: 9 }, // 퀜칭 상한
                { wch: 9 }, // 템퍼 하한
                { wch: 9 }, // 템퍼 상한
            ];

            return workbook;
        }
    });
});

function setPreviewImage(imgId, fileName) {

    const img = document.getElementById(imgId);

    let finalFileName = fileName;

    // 🔥 파일이 없으면 기본 이미지 사용
    if (!fileName || fileName.trim() === "") {
        finalFileName = "null_img.png";
    }

    const encoded = encodeURIComponent(finalFileName);
    const imgUrl = "/line/standard/product/image?filename=" + encoded;

    img.src = imgUrl;
    img.style.display = "block";

    img.onclick = function () {
        window.open(imgUrl, "_blank");
    };
}
</script>

</body>
</html>