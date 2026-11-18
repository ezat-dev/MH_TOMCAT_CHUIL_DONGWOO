<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>트렌드</title>
   <%@include file="../include/pluginpage.jsp" %>    
    <jsp:include page="../include/tabBar.jsp"/>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap" rel="stylesheet">

<style>
/* ===================== 데모: 온도경향감시 — 고밀도 운영 화면 ===================== */
:root {
  --imx-fg:  oklch(24% 0.012 255);
  --imx-fg2: oklch(46% 0.012 255);
  --imx-fg3: oklch(64% 0.01 255);
  --imx-line:  oklch(91.5% 0.006 255);
  --imx-line2: oklch(95.5% 0.004 255);
  --imx-hover: oklch(97.5% 0.003 255);
  --imx-bg:    oklch(98.6% 0.002 255);
  --imx-accent: oklch(55% 0.13 255);
  --imx-accent-tint: oklch(55% 0.13 255 / 0.07);
  --imx-warn:   oklch(64% 0.13 75);
  --imx-danger: oklch(56% 0.15 25);
  --imx-sans: "IBM Plex Sans KR", "Pretendard", "Malgun Gothic", "맑은 고딕", sans-serif;
  --imx-mono: "IBM Plex Mono", Consolas, "Malgun Gothic", monospace;

  /* 아래 이름은 스크립트 안 인라인 스타일이 참조 */
  --bg:       var(--imx-bg);
  --surface:  #fff;
  --surface2: var(--imx-bg);
  --border:   var(--imx-line);
  --text-p:   var(--imx-fg);
  --text-s:   var(--imx-fg2);
  --text-m:   var(--imx-fg3);
  --accent:   var(--imx-accent);
  --shadow-md: 0 8px 24px oklch(24% 0.012 255 / 0.12);
  --topbar-h: 56px;
  --chart-bg:   #ffffff;
  --chart-grid: #eef0f3;
  --chart-text: #6b7280;
}
[data-theme="dark"] {
  --imx-fg:  oklch(92% 0.006 255);
  --imx-fg2: oklch(72% 0.01 255);
  --imx-fg3: oklch(56% 0.01 255);
  --imx-line:  oklch(30% 0.01 255);
  --imx-line2: oklch(26% 0.01 255);
  --imx-hover: oklch(24% 0.008 255);
  --imx-bg:    oklch(18% 0.006 255);
  --surface:   oklch(21% 0.007 255);
  --chart-bg:   #1b1e23;
  --chart-grid: #2a2e35;
  --chart-text: #9aa1ab;
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html, body { height: 100%; overflow: hidden; }
body {
  font-family: var(--imx-sans); font-size: 13px; color: var(--imx-fg); background: var(--imx-bg);
  display: flex; flex-direction: column;
}
.mono, .s-val, .chart-meta, .ctrl { font-family: var(--imx-mono); font-variant-numeric: tabular-nums slashed-zero; }

/* ===================== 헤더 + 조회 툴바 ===================== */
.topbar { flex: none; background: var(--surface); border-bottom: 1px solid var(--imx-line); }
.topbar-inner {
  height: var(--topbar-h); padding: 0 24px;
  display: flex; align-items: center; gap: 8px; flex-wrap: nowrap;
}
.topbar-title { font-size: 18px; font-weight: 600; color: var(--imx-fg); white-space: nowrap; margin-right: 16px; }
.divider { width: 1px; height: 20px; background: var(--imx-line); flex-shrink: 0; margin: 0 4px; }
.label { font-size: 12px; color: var(--imx-fg2); white-space: nowrap; }
.tilde { color: var(--imx-fg3); padding: 0 2px; }
.ctrl {
  height: 32px; padding: 0 8px; min-width: 150px;
  border: 1px solid var(--imx-line); border-radius: 6px;
  background: var(--surface); color: var(--imx-fg); font-size: 13px; outline: none;
}
.ctrl:focus { border-color: var(--imx-accent); box-shadow: 0 0 0 2px var(--imx-accent-tint); }

.btn {
  height: 32px; padding: 0 12px; border-radius: 6px;
  display: inline-flex; align-items: center; gap: 8px; white-space: nowrap; cursor: pointer;
  font-family: var(--imx-sans); font-size: 13px; font-weight: 500;
  border: 1px solid var(--imx-line); background: var(--surface); color: var(--imx-fg);
  transition: background-color 80ms, border-color 80ms;
}
.btn:hover { background: var(--imx-hover); border-color: oklch(86% 0.008 255); }
.btn svg { width: 14px; height: 14px; flex-shrink: 0; }
.btn-search { background: var(--imx-accent); border-color: var(--imx-accent); color: #fff; }
.btn-search:hover { background: oklch(50% 0.13 255); border-color: oklch(50% 0.13 255); }
.btn-insert, .btn-excel, .btn-print, .btn-save, .btn-close-modal { background: var(--surface); color: var(--imx-fg); }
.btn-theme { width: 32px; padding: 0; justify-content: center; margin-left: auto; color: var(--imx-fg2); }
.btn-sm { height: 24px; padding: 0 8px; font-size: 12px; gap: 4px; border-radius: 4px; }
.btn-sm svg { width: 12px; height: 12px; }

/* ===================== 페이지 ===================== */
.page-wrap {
  flex: 1 1 auto; min-height: 0;
  padding: 16px 24px;
  display: flex; flex-direction: column; gap: 8px;
}

/* 컨트롤 + 통계: 테두리 1px 띠 */
.control-panel, .stats-bar {
  flex: none; background: var(--surface);
  border: 1px solid var(--imx-line); border-radius: 8px;
  display: flex; align-items: center; flex-wrap: wrap;
}
.control-panel { padding: 8px 12px; gap: 12px; }
.ctrl-section { display: flex; align-items: center; gap: 4px; }
.ctrl-section-label { font-size: 12px; color: var(--imx-fg3); white-space: nowrap; margin-right: 4px; }
.ctrl-divider { width: 1px; height: 20px; background: var(--imx-line); }

/* 그룹 칩: 테두리만, 색은 점 하나 */
.group-chip {
  height: 24px; padding: 0 8px; border-radius: 4px;
  font-family: var(--imx-sans); font-size: 12px; font-weight: 500;
  border: 1px solid var(--imx-line); background: var(--surface); color: var(--imx-fg3);
  cursor: pointer; display: inline-flex; align-items: center; gap: 4px; user-select: none;
  transition: border-color 80ms, color 80ms;
}
.group-chip::before {
  content: ""; width: 8px; height: 8px; border-radius: 2px; flex-shrink: 0;
  border: 1px solid var(--g, var(--imx-fg3)); background: transparent;
}
.group-chip.active { color: var(--imx-fg); border-color: oklch(84% 0.008 255); }
.group-chip.active::before { background: var(--g, var(--imx-fg3)); }
.group-chip:hover { border-color: oklch(80% 0.008 255); }
.chip-all    { --g: var(--imx-fg2); }
.chip-all::before { display: none; }
.chip-quench { --g: #3f74a8; }
.chip-temper { --g: #9c4627; }
.chip-cp     { --g: #4f3f80; }
.chip-wash   { --g: #4b6584; }

/* 차트 타입 */
.type-btn {
  height: 24px; width: 28px; border-radius: 4px;
  border: 1px solid var(--imx-line); background: var(--surface); color: var(--imx-fg3);
  cursor: pointer; display: inline-flex; align-items: center; justify-content: center;
}
.type-btn svg { width: 16px; height: 16px; fill: none; stroke: currentColor; stroke-width: 1.75; stroke-linecap: round; stroke-linejoin: round; }
.type-btn:hover { color: var(--imx-fg); }
.type-btn.active { border-color: var(--imx-accent); color: var(--imx-accent); background: var(--imx-accent-tint); }

/* 단축키 안내 */
.hint { font-size: 12px; color: var(--imx-fg2); display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; }
kbd {
  font-family: var(--imx-mono); font-size: 11px; color: var(--imx-fg);
  border: 1px solid var(--imx-line); border-bottom-width: 2px; border-radius: 4px;
  padding: 0 4px; background: var(--imx-bg); line-height: 16px;
}

/* 통계 띠 */
.stats-bar { padding: 0; gap: 0; }
.stats-bar-title { font-size: 12px; color: var(--imx-fg3); padding: 0 12px; white-space: nowrap; }
.stats-item {
  display: flex; align-items: baseline; gap: 8px;
  padding: 8px 16px; border-left: 1px solid var(--imx-line2);
  font-size: 12px; white-space: nowrap;
}
.stats-item .s-label { color: var(--imx-fg2); display: inline-flex; align-items: center; gap: 4px; }
.stats-item .s-val   { font-size: 15px; font-weight: 500; color: var(--imx-fg); }
.stats-dot { width: 8px; height: 8px; border-radius: 2px; flex-shrink: 0; align-self: center; }
.stats-meta { margin-left: auto; display: flex; }
.stats-meta .s-val { font-size: 13px; color: var(--imx-fg2); }

/* ===================== 차트 ===================== */
.main-grid { flex: 1 1 auto; min-height: 0; display: flex !important; flex-direction: column; }
.chart-wrap {
  flex: 1 1 auto; min-height: 0;
  background: var(--surface); border: 1px solid var(--imx-line); border-radius: 8px;
  display: flex; flex-direction: column; overflow: hidden;
}
.chart-toolbar {
  flex: none; padding: 8px 16px; border-bottom: 1px solid var(--imx-line2);
  display: flex; align-items: center; justify-content: space-between; gap: 8px;
}
.chart-title { font-size: 14px; font-weight: 500; color: var(--imx-fg); }
.chart-meta  { font-size: 12px; color: var(--imx-fg3); }
#container { flex: 1 1 auto; min-height: 0; width: 100%; }

/* ===================== 구간 통계 팝업 ===================== */
.range-popup {
  display: none; position: fixed; z-index: 9999;
  background: var(--surface); border: 1px solid var(--imx-line); border-radius: 8px;
  padding: 12px 16px; box-shadow: var(--shadow-md); min-width: 260px; pointer-events: none;
}
.range-popup.show { display: block; }
.range-popup-title { font-size: 12px; font-weight: 600; margin-bottom: 8px; padding-bottom: 4px; border-bottom: 1px solid var(--imx-line); }
.range-stat-row { display: flex; justify-content: space-between; font-size: 12px; padding: 4px 0; }
.range-stat-row .rk { color: var(--imx-fg2); }
.range-stat-row .rv { font-family: var(--imx-mono); font-variant-numeric: tabular-nums; }

/* ===================== 현재값 사이드 패널 (숨김) ===================== */
.live-panel { background: var(--surface); border: 1px solid var(--imx-line); border-radius: 8px; overflow: hidden; }
.live-panel-header {
  padding: 8px 12px; border-bottom: 1px solid var(--imx-line);
  font-size: 12px; font-weight: 600; display: flex; align-items: center; justify-content: space-between;
}
.live-time { font-size: 11px; font-family: var(--imx-mono); color: var(--imx-fg3); font-weight: 400; }

/* ===================== 모달 ===================== */
.modal {
  display: none; position: fixed; inset: 0; z-index: 20010;
  background: oklch(20% 0.01 255 / 0.4); align-items: center; justify-content: center;
}
.modal.show { display: flex; }
.modal-content {
  background: var(--surface); width: 560px; max-width: 95vw; max-height: 90vh; overflow-y: auto;
  border: 1px solid var(--imx-line); border-radius: 8px; padding: 16px 24px 24px; position: relative;
  box-shadow: var(--shadow-md);
}
.modal-title { font-size: 15px; font-weight: 600; margin-bottom: 12px; }
.modal-content hr { border: none; border-top: 1px solid var(--imx-line); margin: 12px 0; }
.close-btn {
  position: absolute; right: 16px; top: 12px;
  width: 28px; height: 28px; border-radius: 6px;
  background: var(--surface); border: 1px solid var(--imx-line); color: var(--imx-fg2);
  cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px;
}
.close-btn:hover { background: var(--imx-hover); }
.form-group { margin-bottom: 12px; }
.form-label { font-size: 12px; color: var(--imx-fg2); margin-bottom: 4px; display: block; }
.form-input {
  width: 100%; height: 32px; padding: 0 8px;
  border: 1px solid var(--imx-line); border-radius: 6px; background: var(--surface); color: var(--imx-fg);
  font-size: 13px; font-family: var(--imx-sans); outline: none;
}
.form-input:focus { border-color: var(--imx-accent); box-shadow: 0 0 0 2px var(--imx-accent-tint); }
#saveCorrStatus { background: var(--imx-accent); border-color: var(--imx-accent); color: #fff; justify-content: center; }

/* ===================== 엑셀 로딩 ===================== */
#excelOverlay { display: none; position: fixed; inset: 0; background: oklch(20% 0.01 255 / 0.4); z-index: 9998; }
#excelLoading {
  display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
  background: var(--surface); padding: 16px 32px; border-radius: 8px; border: 1px solid var(--imx-line);
  box-shadow: var(--shadow-md); z-index: 9999; font-size: 13px; text-align: center;
}

::-webkit-scrollbar { width: 6px; height: 6px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--imx-line); border-radius: 3px; }

@media (max-width: 1400px) {
  .topbar-inner { padding: 0 16px; }
  .page-wrap { padding: 12px 16px; }
  .hint-group { display: none !important; }
}
</style>
</head>
<body>

<!-- ===================== 로딩 오버레이 ===================== -->
<div id="excelOverlay"></div>
<div id="excelLoading">엑셀 생성 중…</div>

<!-- ===================== 구간 통계 팝업 ===================== -->
<div class="range-popup" id="rangePopup">
  <div class="range-popup-title" id="rangeTitle">선택 구간 통계</div>
  <div id="rangeStats"></div>
</div>

<!-- ===================== 등록 모달 ===================== -->
<div id="modalContainer" class="modal">
  <div class="modal-content">
    <button class="close-btn" id="closeModalBtn">&times;</button>
    <div class="modal-title">트렌드 데이터 등록</div>
    <hr/>
    <div id="signDataTable"></div>
    <hr/>
    <form id="corrForm" autocomplete="off">
      <input type="hidden" name="tc_cnt" value="0">
      <input type="hidden" name="tc_user_code">
      <div class="form-group">
        <label class="form-label">작업자</label>
        <input type="text" name="tc_user_name" class="form-input" readonly>
      </div>
      <div class="form-group">
        <label class="form-label">등록시간</label>
        <input type="text" name="tc_regtime" class="form-input">
      </div>
      <div class="form-group">
        <label class="form-label">등록내용</label>
        <input type="text" name="tc_name" class="form-input">
      </div>
      <div class="form-group">
        <label class="form-label">비고</label>
        <input type="text" name="tc_desc" class="form-input">
      </div>
      <hr/>
      <div style="display:flex; gap:8px; margin-top:4px;">
        <button type="submit" id="saveCorrStatus" class="btn btn-save" style="flex:1; justify-content:center;">저장</button>
        <button type="button" id="closeModal" class="btn btn-close-modal" style="flex:1; justify-content:center;">닫기</button>
      </div>
    </form>
  </div>
</div>

<!-- ===================== TOPBAR ===================== -->
<div class="topbar">
  <div class="topbar-inner">
    <span class="topbar-title">온도 트렌드</span>
    <span class="label">검색 기간</span>
    <input type="text" autocomplete="off" class="datetimeSet ctrl" id="startDate">
    <span class="tilde">~</span>
    <input type="text" autocomplete="off" class="datetimeSet ctrl" id="endDate">
    <button class="btn btn-search select-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>조회
    </button>
    <div class="divider"></div>
    <button class="btn btn-insert insert-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>메모 추가
    </button>
    <button class="btn btn-print" id="printBtn">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>인쇄
    </button>
    <button class="btn btn-excel excel-button">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>엑셀
    </button>
    <button class="btn btn-theme" id="themeToggle" title="테마 전환"></button>
  </div>
</div>

<!-- ===================== PAGE ===================== -->
<div class="page-wrap">

  <!-- 컨트롤 패널 -->
  <div class="control-panel">
    <div class="ctrl-section">
      <span class="ctrl-section-label">그룹</span>
      <button class="group-chip chip-all active"    id="chip-all"    onclick="toggleGroup('all')">전체</button>
      <button class="group-chip chip-quench active" id="chip-quench" onclick="toggleGroup('quench')">소입로</button>
      <button class="group-chip chip-temper active" id="chip-temper" onclick="toggleGroup('temper')">소려로</button>
      <button class="group-chip chip-cp active"     id="chip-cp"     onclick="toggleGroup('cp')">CP</button>
      <button class="group-chip chip-wash active"   id="chip-wash"   onclick="toggleGroup('wash')">세정/기타</button>
    </div>
    <div class="ctrl-divider"></div>
    <div class="ctrl-section">
      <span class="ctrl-section-label">타입</span>
      <button class="type-btn active" data-type="line"   onclick="setChartType('line')"   title="라인"><svg viewBox="0 0 24 24"><polyline points="3 17 9 11 13 15 21 7"/></svg></button>
      <button class="type-btn"        data-type="spline" onclick="setChartType('spline')" title="스플라인"><svg viewBox="0 0 24 24"><path d="M3 17c4 0 4-10 9-10s5 10 9 10"/></svg></button>
      <button class="type-btn"        data-type="area"   onclick="setChartType('area')"   title="영역"><svg viewBox="0 0 24 24"><path d="M3 20V14l6-6 4 4 8-8v16z" fill="currentColor" fill-opacity=".15"/></svg></button>
    </div>
    <div class="ctrl-divider"></div>
    <div class="ctrl-section">
      <button class="btn btn-sm" onclick="chart && chart.zoomOut()">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 3 21 3 21 9"/><polyline points="9 21 3 21 3 15"/><line x1="21" y1="3" x2="14" y2="10"/><line x1="3" y1="21" x2="10" y2="14"/></svg>전체 보기
      </button>
    </div>
    <div class="ctrl-section hint-group" style="gap:16px; margin-left:auto;">
      <span class="hint"><kbd>드래그</kbd> 구간 줌</span>
      <span class="hint"><kbd>Shift</kbd>+<kbd>드래그</kbd> 좌우 이동</span>
      <span class="hint"><kbd>Alt</kbd>+<kbd>드래그</kbd> 구간 통계</span>
    </div>
  </div>

  <!-- 통계 바 -->
  <div class="stats-bar" id="statsBar">
    <span class="stats-bar-title">기간 평균</span>
    <div class="stats-item"><span class="s-label"><span class="stats-dot" style="background:#3f74a8"></span>소입로</span><span class="s-val" id="stat-quench">--</span></div>
    <div class="stats-item"><span class="s-label"><span class="stats-dot" style="background:#9c4627"></span>소려로</span><span class="s-val" id="stat-temper">--</span></div>
    <div class="stats-item"><span class="s-label"><span class="stats-dot" style="background:#4b6584"></span>세정</span><span class="s-val" id="stat-wash">--</span></div>
    <div class="stats-item"><span class="s-label"><span class="stats-dot" style="background:#4f3f80"></span>CP-A</span><span class="s-val" id="stat-cp-a">--</span></div>
    <div class="stats-item"><span class="s-label"><span class="stats-dot" style="background:#8f80bd"></span>CP-B</span><span class="s-val" id="stat-cp-b">--</span></div>
    <div class="stats-meta">
      <div class="stats-item">
        <span class="s-label">데이터</span>
        <span class="s-val" id="stat-count">--</span>
      </div>
      <div class="stats-item">
        <span class="s-label">범위</span>
        <span class="s-val" id="stat-range">--</span>
      </div>
    </div>
  </div>

  <!-- 메인 그리드: 차트 + 사이드 -->
  <div class="main-grid">

    <!-- 차트 카드 -->
    <div class="chart-wrap">
      <div class="chart-toolbar">
        <div class="chart-title">열처리 연속로 온도 트렌드</div>
        <div class="chart-meta" id="chartMeta">-</div>
      </div>
      <div id="container"></div>
    </div>

    <!-- 현재값 사이드 패널 -->
    <div class="live-panel" style="display:none">
      <div class="live-panel-header">
        실시간 커서 값
        <span class="live-time" id="liveTime">-</span>
      </div>
      <div id="liveGrid" style="overflow-y:auto; max-height:560px;">
        <div style="padding:24px 16px; text-align:center; color:var(--text-m); font-size:12px;">차트에서 포인트를 선택하세요</div>
      </div>
    </div>

  </div>
</div>

<!-- ===================== 구간 통계 모달 ===================== -->
<div id="rangeStatsModal" style="display:none; position:fixed; inset:0; background:oklch(20% 0.01 255 / 0.4); z-index:20020; align-items:center; justify-content:center;">
  <div style="background:var(--surface); border:1px solid var(--border); border-radius:8px; padding:16px 24px 24px; min-width:420px; max-width:95vw; max-height:80vh; overflow-y:auto; box-shadow:var(--shadow-md);">
    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:14px;">
      <span style="font-size:15px; font-weight:600; color:var(--text-p);">선택 구간 통계</span>
      <button onclick="document.getElementById('rangeStatsModal').style.display='none'" class="close-btn" style="position:static;">&times;</button>
    </div>
    <div id="rangeStatsContent"></div>
  </div>
</div>


<script>
let now_page_code = "b04";

let categories;
let q_pv_1,q_pv_2,q_pv_3,q_pv_4,q_pv_5;
let t_pv_1,t_pv_2,t_pv_3,t_pv_4,t_pv_5;
let cp_pv_1,cp_pv_2,f_wash_pv,m_wash_pv,oil_pv,bc_pv;
let memoSeries = [];
var trendInterval;
var chart;
var currentChartType = 'line';
var selectedRowData = null;

// Alt키 추적 (구간통계용)
window._altPressed = false;
document.addEventListener('keydown', function(e){ if(e.key==='Alt') window._altPressed=true; });
document.addEventListener('keyup',   function(e){ if(e.key==='Alt') window._altPressed=false; });

// 시리즈 그룹 매핑 (SERIES_DEF 인덱스 기준)
const GROUP_MAP = {
  wash:   [0, 6, 7, 8],      // 전세정기, 소입유조, 중간세정기, 방청조
  quench: [1,2,3,4,5],       // 소입로 1~5존
  temper: [9,10,11,12,13],   // 소려로 1~5존
  cp:     [14,15]
};

// 데모: 패널(세로로 쌓은 yAxis) — 그룹마다 자체 스케일. 인덱스 = yAxis 번호
const PANELS = [
  { key:'quench', label:'소입로',      unit:'°C', dec:1, weight:1.25, minRange:30,  tol:5    },
  { key:'temper', label:'소려로',      unit:'°C', dec:1, weight:1.25, minRange:30,  tol:5    },
  { key:'wash',   label:'세정 · 기타', unit:'°C', dec:1, weight:1,    minRange:20,  tol:null },
  { key:'cp',     label:'CP',          unit:'%',  dec:2, weight:0.85, minRange:0.1, tol:0.02 }
];
const MEMO_AXIS = PANELS.length;

// 시리즈 정의 (원래 인덱스 순서 유지 — 통계/엑셀/사이드패널이 이 순서를 씀)
const SERIES_DEF = [
  { name:'전세정기',   p:2 },
  { name:'소입로1존', p:0 }, { name:'소입로2존', p:0 }, { name:'소입로3존', p:0 }, { name:'소입로4존', p:0 }, { name:'소입로5존', p:0 },
  { name:'소입유조',   p:2 },
  { name:'중간세정기', p:2 },
  { name:'방청조',     p:2 },
  { name:'소려로1존', p:1 }, { name:'소려로2존', p:1 }, { name:'소려로3존', p:1 }, { name:'소려로4존', p:1 }, { name:'소려로5존', p:1 },
  { name:'CP-A', p:3 }, { name:'CP-B', p:3, dash:'ShortDash' }
];

// 데모: 같은 패널 안에서는 한 색 계열의 명도 단계, 세정·기타 패널만 차분한 범주색
const SERIES_COLORS = [
  '#4b6584',                                         // 전세정기
  '#173f66','#2a5a8a','#3f74a8','#6693c2','#93b4d8', // 소입로 1~5존
  '#8c6d46',                                         // 소입유조
  '#3f7f78',                                         // 중간세정기
  '#8a8f98',                                         // 방청조
  '#7a2f17','#9c4627','#bb6340','#cf8866','#e0ae95', // 소려로 1~5존
  '#4f3f80','#8f80bd',                               // CP-A, CP-B
  '#475569'                                          // 메모
];
var spBands = {};   // { quench:{lo:[],w:[]}, ... } — 데이터에 SP가 있을 때만

const THEME_ICON = {
  moon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>',
  sun:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/></svg>'
};
document.getElementById('themeToggle').innerHTML = THEME_ICON.moon;

// ===================== 테마 =====================
let isDark = false;
document.getElementById('themeToggle').addEventListener('click', function(){
  isDark = !isDark;
  document.documentElement.setAttribute('data-theme', isDark ? 'dark' : '');
  this.innerHTML = isDark ? THEME_ICON.sun : THEME_ICON.moon;
  if(chart) { applyChartTheme(); chart.redraw(); }
});

function applyChartTheme(){
  const grid  = getComputedStyle(document.documentElement).getPropertyValue('--chart-grid').trim();
  const text  = getComputedStyle(document.documentElement).getPropertyValue('--chart-text').trim();
  const bg    = getComputedStyle(document.documentElement).getPropertyValue('--chart-bg').trim();
  chart.update({
    chart:  { backgroundColor: bg },
    xAxis:  { gridLineColor: grid, lineColor: grid, tickColor: grid, labels:{ style:{color:text} } },
    legend: { itemStyle:{color:text}, itemHoverStyle:{color:text} }
  }, false);
  chart.yAxis.forEach(function(ax){ ax.update({ gridLineColor: grid, labels:{ style:{color:text} } }, false); });
}

// ===================== 차트 타입 =====================
function setChartType(type){
  currentChartType = type;
  document.querySelectorAll('.type-btn').forEach(b => b.classList.toggle('active', b.dataset.type===type));
  if(!chart) return;
  chart.series.forEach(function(s){
    if(!/^s\d+$/.test(s.options.id || '')) return;   // 메모·SP 띠 제외
    if(type === 'area') s.update({ type:'area', fillOpacity:.025, threshold:null }, false);
    else s.update({ type }, false);
  });
  chart.redraw();
}

// ===================== 그룹 토글 =====================
function toggleGroup(group){
  var groupIds = ['quench','temper','cp','wash'];

  if(group === 'all'){
    var chips = groupIds.map(function(g){ return document.getElementById('chip-'+g); }).filter(Boolean);
    var allActive = chips.every(function(c){ return c.classList.contains('active'); });
    var newState = !allActive;
    chips.forEach(function(c){
      var g = c.id.replace('chip-','');
      c.classList.toggle('active',   newState);
      c.classList.toggle('inactive', !newState);
      applyGroupVisibility(g, newState, false);
    });
    var allChip = document.getElementById('chip-all');
    if(allChip){
      allChip.classList.toggle('active',   newState);
      allChip.classList.toggle('inactive', !newState);
    }
    layoutPanels();
    return;
  }

  var chip = document.getElementById('chip-'+group);
  if(!chip) return;
  var isActive = chip.classList.contains('active');
  chip.classList.toggle('active',   !isActive);
  chip.classList.toggle('inactive',  isActive);
  applyGroupVisibility(group, !isActive);

  // 전체 칩 상태 동기화
  var chips2 = groupIds.map(function(g){ return document.getElementById('chip-'+g); }).filter(Boolean);
  var allActive2 = chips2.every(function(c){ return c.classList.contains('active'); });
  var allChip2 = document.getElementById('chip-all');
  if(allChip2){
    allChip2.classList.toggle('active',   allActive2);
    allChip2.classList.toggle('inactive', !allActive2);
  }
}

function panelOn(key){
  var c = document.getElementById('chip-'+key);
  return !c || c.classList.contains('active');
}

function applyGroupVisibility(group, visible, relayout){
  if(!chart) return;
  (GROUP_MAP[group] || []).forEach(function(i){
    var s = chart.get('s'+i);
    if(s) s.setVisible(visible, false);
  });
  if(relayout !== false) layoutPanels();
}

// 데모: SP 허용범위 띠 — 축 범위에 영향 없게 렌더러로 직접 그림 (패널 영역으로 잘라냄)
function drawSpBands(){
  var c = this;
  c._spBand = c._spBand || {};
  var xa = c.xAxis[0], ex = xa.getExtremes();
  PANELS.forEach(function(p, i){
    var ax = c.yAxis[i], b = spBands[p.key], el = c._spBand[p.key];
    if(!b || !ax.visible || !panelOn(p.key)){ if(el) el.g.hide(); return; }
    if(!el){
      var clip = c.renderer.clipRect(0, 0, 0, 0);
      el = c._spBand[p.key] = {
        clip: clip,
        g: c.renderer.path([]).attr({ fill:'rgba(100,116,139,.10)', zIndex:1 }).clip(clip).add()
      };
    }
    el.clip.attr({ x: c.plotLeft, y: ax.top, width: c.plotWidth, height: ax.len });
    var from = Math.max(0, Math.floor(ex.min)), to = Math.min(b.lo.length - 1, Math.ceil(ex.max));
    var top = [], bot = [];
    for(var k = from; k <= to; k++){
      if(b.lo[k] === null) continue;
      var x = xa.toPixels(k);
      top.push([x, ax.toPixels(b.hi[k])]);
      bot.push([x, ax.toPixels(b.lo[k])]);
    }
    if(top.length < 2){ el.g.hide(); return; }
    var d = [['M', top[0][0], top[0][1]]];
    for(var j = 1; j < top.length; j++) d.push(['L', top[j][0], top[j][1]]);
    for(var j2 = bot.length - 1; j2 >= 0; j2--) d.push(['L', bot[j2][0], bot[j2][1]]);
    d.push(['Z']);
    el.g.attr({ d: d }).show();
  });
}

// 데모: 켜진 패널만 세로로 나눠 갖는다 (top/height %)
function layoutPanels(redraw){
  if(!chart) return;
  var TOP = 9, GAP = 5;
  var vis = PANELS.filter(function(p){ return panelOn(p.key); });
  var sum = vis.reduce(function(a,p){ return a + p.weight; }, 0) || 1;
  var avail = 100 - TOP - GAP * Math.max(0, vis.length - 1);
  var y = TOP;
  PANELS.forEach(function(p, i){
    var ax = chart.yAxis[i];
    if(panelOn(p.key)){
      var h = avail * p.weight / sum;
      ax.update({ top: y + '%', height: h + '%', visible: true }, false);
      y += h + GAP;
    } else {
      ax.update({ visible: false }, false);
    }
  });
  if(redraw !== false) chart.redraw();
}

// 패널 왼쪽 위 작은 라벨
function drawPanelLabels(){
  var c = this;
  c._panelLbl = c._panelLbl || [];
  PANELS.forEach(function(p, i){
    var ax = c.yAxis[i], lbl = c._panelLbl[i];
    if(!lbl){
      lbl = c._panelLbl[i] = c.renderer.text(p.label + ' <tspan style="fill:#9aa1ab">' + p.unit + '</tspan>', 0, 0)
        .css({ fontSize:'11px', fontWeight:'500', color:'#4b5563' }).attr({ zIndex: 6 }).add();
    }
    if(ax.visible && panelOn(p.key)){
      lbl.attr({ x: c.plotLeft, y: ax.top - 6 }).show();
    } else {
      lbl.hide();
    }
  });
}

// ===================== 유틸 =====================
function escapeHtml(str){ if(!str) return ""; return String(str).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;"); }
function safeNum(v){ return (v===null||v===undefined||v==="")?null:(isNaN(Number(v))?null:Number(v)); }
function paddingZero(v){ return v<10?"0"+v:v; }
function dataLabelFormat(val){
  var d = new Date(val);
  if(isNaN(d.getTime())) return val;
  return paddingZero(d.getMonth()+1)+"-"+paddingZero(d.getDate())+"<br/>"+
         paddingZero(d.getHours())+":"+paddingZero(d.getMinutes());
}
function avg(arr){ const v=arr.filter(x=>x!==null&&x!==undefined); return v.length?v.reduce((a,b)=>a+b,0)/v.length:null; }
function calcStats(arr){
  const v=arr.filter(x=>x!==null&&x!==undefined);
  if(!v.length) return null;
  return { min:Math.min(...v), max:Math.max(...v), avg:(v.reduce((a,b)=>a+b,0)/v.length).toFixed(1) };
}

// ===================== 초기화 =====================
$(document).ready(function(){
  $(".datetimeSet").datepicker({ language:'ko', timepicker:true, dateFormat:'yyyy-mm-dd', timeFormat:'hh:ii', autoClose:true });
  $("#startDate").val(trendStime());
  $("#endDate").val(trendEtime());
  fetchData();
  trendInterval = setInterval(function(){ $("#startDate").val(trendStime()); $("#endDate").val(trendEtime()); fetchData(); }, 1000*60*5);
});

$(".select-button").on("click", fetchData);

$(".insert-button").on("click", function(){
  $("input[name='tc_user_code']").val("${loginUser.user_code}");
  $("input[name='tc_user_name']").val("${loginUser.user_name}");
  $("input[name='tc_regtime']").val(trendEtime());
  $('#modalContainer').addClass('show');
  getSignDataList();
  signData();
});

$('.close-btn, #closeModal, #closeModalBtn').click(function(){
  $('#corrForm')[0].reset();
  $('#modalContainer').removeClass('show');
});

$('#saveCorrStatus').click(function(e){
  e.preventDefault();
  var formData = new FormData($('#corrForm')[0]);
  $.ajax({ url:"/line/monitoring/trend/sign/save", type:"POST", data:formData, processData:false, contentType:false,
    success:function(){ alert("저장되었습니다!"); signData(); getTrend(); selectedRowData=null; },
    error:function(){ alert('저장 중 오류가 발생했습니다.'); }
  });
});

$(".excel-button").click(function(){ downloadExcel(); });

document.getElementById('printBtn').addEventListener('click', function(){
  const style = document.createElement('style');
  style.innerHTML = `@page{size:A4 landscape;margin:10mm}@media print{body{zoom:67%}#container{width:1700px!important;max-width:1700px!important;height:660px!important}}`;
  document.head.appendChild(style);
  if(chart) chart.reflow();
  window.print();
  setTimeout(() => document.head.removeChild(style), 1000);
});

// ===================== signData =====================
var signDataTable;
function signData(){
  $.ajax({ url:"/line/monitoring/trend/sign/list", type:"post", dataType:"json", data:{},
    success:function(result){ if(signDataTable) signDataTable.setData(result.data); }
  });
}

function getSignDataList(){
  if($("#signDataSearch").length===0){
    $("#signDataTable").before(`<div style="margin-bottom:8px;display:flex;justify-content:flex-end;">
      <input type="text" id="signDataSearch" placeholder="검색어 입력..." class="form-input" style="width:200px;">
    </div>`);
  }
  signDataTable = new Tabulator('#signDataTable',{
    height:'200px', layout:'fitColumns', reactiveData:true,
    columnHeaderVertAlign:"middle", headerHozAlign:'center', renderHorizontal:"virtual",
    placeholder:"조회된 데이터가 없습니다.",
    columns:[
      {title:"tc_cnt",field:"tc_cnt",visible:false},
      {title:"작업자",field:"tc_user_name",hozAlign:"center"},
      {title:"작업내용",field:"tc_name",hozAlign:"center"},
      {title:"작업시간",field:"tc_regtime",hozAlign:"center"},
      {title:"비고",field:"tc_desc",hozAlign:"center",headerSort:false}
    ],
    rowClick:function(e,row){
      $('#signDataTable .tabulator-row').removeClass('row_select');
      row.getElement().classList.add('row_select');
      selectedRowData=row.getData();
    }
  });
  $("#signDataSearch").on("keyup", function(){
    const kw=$(this).val();
    if(!kw) signDataTable.clearFilter();
    else signDataTable.setFilter([[
      {field:"tc_user_name",type:"like",value:kw},
      {field:"tc_name",type:"like",value:kw},
      {field:"tc_regtime",type:"like",value:kw},
      {field:"tc_desc",type:"like",value:kw}
    ]]);
  });
}

// ===================== fetchData =====================
var signListObj = {};
function fetchData(){
  const startDate=$("#startDate").val(), endDate=$("#endDate").val();
  $.ajax({
    type:"POST", url:"/line/monitoring/trend/list",
    data:{ startDate, endDate },
    success:function(result){
      if(!result||result.length===0){ alert("데이터가 없습니다."); return; }

      const grouped={}, uniqueOrder=[];
      result.forEach(r=>{
        const key=r.regtime;
        if(!grouped.hasOwnProperty(key)){ grouped[key]=r; uniqueOrder.push(key); }
      });
      categories=uniqueOrder.slice();

      signListObj = {};
      memoSeries = [];

      uniqueOrder.forEach(rt => {
        const r = grouped[rt];
        if (r.tc_name || r.tc_desc || r.item_name || r.cust_name || r.lot_name || r.tc_val !== null) {
          // 데모: 차트 위 메모는 한 줄로 짧게 (LOT 시작 = LOT 번호, 일반 메모 = 내용만)
          const parts = [];
          if (r.lot_name && r.lot_name.trim() !== "") parts.push(escapeHtml(r.lot_name));
          else if (r.tc_name && r.tc_name.trim() !== "") parts.push(escapeHtml(r.tc_name));

          memoSeries.push({
            x: uniqueOrder.indexOf(rt),
            y: 950,
            desc: parts.join("")
          });
        }
      });

      q_pv_1=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_1));
      q_pv_2=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_2));
      q_pv_3=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_3));
      q_pv_4=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_4));
      q_pv_5=uniqueOrder.map(rt=>safeNum(grouped[rt].q_pv_5));
      t_pv_1=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_1));
      t_pv_2=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_2));
      t_pv_3=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_3));
      t_pv_4=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_4));
      t_pv_5=uniqueOrder.map(rt=>safeNum(grouped[rt].t_pv_5));
      f_wash_pv=uniqueOrder.map(rt=>safeNum(grouped[rt].f_wash_pv));
      m_wash_pv=uniqueOrder.map(rt=>safeNum(grouped[rt].m_wash_pv));
      oil_pv=uniqueOrder.map(rt=>safeNum(grouped[rt].oil_pv));
      bc_pv=uniqueOrder.map(rt=>safeNum(grouped[rt].bc_pv));
      cp_pv_1=uniqueOrder.map(rt=>grouped[rt].cp_pv_1?Number(grouped[rt].cp_pv_1)/1000:null);
      cp_pv_2=uniqueOrder.map(rt=>grouped[rt].cp_pv_2?Number(grouped[rt].cp_pv_2)/1000:null);

      // 통계 바 업데이트
      const qArr=[...q_pv_1,...q_pv_2,...q_pv_3,...q_pv_4,...q_pv_5];
      const tArr=[...t_pv_1,...t_pv_2,...t_pv_3,...t_pv_4,...t_pv_5];
      const wArr=[...f_wash_pv,...m_wash_pv,...bc_pv];
      const qAvg=avg(qArr), tAvg=avg(tArr), wAvg=avg(wArr);
      const cpAArr=cp_pv_1.filter(x=>x!==null), cpBArr=cp_pv_2.filter(x=>x!==null);
      $("#stat-quench").text(qAvg!==null ? qAvg.toFixed(1)+"°C" : "--");
      $("#stat-temper").text(tAvg!==null ? tAvg.toFixed(1)+"°C" : "--");
      $("#stat-wash").text(wAvg!==null ? wAvg.toFixed(1)+"°C" : "--");
      $("#stat-cp-a").text(cpAArr.length ? (cpAArr.reduce((a,b)=>a+b,0)/cpAArr.length).toFixed(3) : "--");
      $("#stat-cp-b").text(cpBArr.length ? (cpBArr.reduce((a,b)=>a+b,0)/cpBArr.length).toFixed(3) : "--");
      $("#stat-count").text(uniqueOrder.length.toLocaleString()+" pt");
      $("#stat-range").text(startDate.substring(5,16)+" ~ "+endDate.substring(5,16));
      $("#chartMeta").text(uniqueOrder.length.toLocaleString()+" points | "+startDate.substring(0,16)+" ~ "+endDate.substring(0,16));

      // 데모: SP 허용범위 띠 (SP 값이 있는 그룹만) — 하한(투명) + 폭(옅은 회색) 누적 영역
      spBands = {};
      const spKeys = {
        quench: ['q_sp_1','q_sp_2','q_sp_3','q_sp_4','q_sp_5'],
        temper: ['t_sp_1','t_sp_2','t_sp_3','t_sp_4','t_sp_5'],
        cp:     ['cp_sp_1','cp_sp_2']
      };
      PANELS.forEach(function(p){
        const keys = spKeys[p.key];
        if(!keys || p.tol === null) return;
        const div = p.key === 'cp' ? 1000 : 1;
        const lo = [], hi = [];
        let any = false;
        uniqueOrder.forEach(function(rt){
          const vals = keys.map(function(k){ return safeNum(grouped[rt][k]); })
                           .filter(function(v){ return v !== null && v !== 0; })
                           .map(function(v){ return v / div; });
          if(!vals.length){ lo.push(null); hi.push(null); return; }
          any = true;
          lo.push(Math.min.apply(null, vals) - p.tol);
          hi.push(Math.max.apply(null, vals) + p.tol);
        });
        if(any) spBands[p.key] = { lo: lo, hi: hi };
      });

      if(!chart){ getTrend(); }
      else{
        chart.xAxis[0].setCategories(categories,false);
        const newData=seriesData();
        newData.forEach(function(d,i){ const s=chart.get('s'+i); if(s) s.setData(d,false); });
        const memo=chart.get('memo'); if(memo) memo.setData(memoPoints(),false);
        chart.redraw();
      }
    },
    error:function(xhr,status,error){ console.error("❌",error); alert("데이터 조회 중 오류가 발생했습니다."); }
  });
}

// ===================== getTrend (차트 생성) =====================
function seriesData(){
  return [f_wash_pv,q_pv_1,q_pv_2,q_pv_3,q_pv_4,q_pv_5,oil_pv,m_wash_pv,bc_pv,t_pv_1,t_pv_2,t_pv_3,t_pv_4,t_pv_5,cp_pv_1,cp_pv_2];
}
// LOT/메모 마커는 전용 축(0~1) 맨 위 여백에 표시
function memoPoints(){
  return memoSeries.map(function(m){ return { x:m.x, y:0.975, desc:m.desc }; });
}

function getTrend(){
  const bg    = isDark ? '#1b1e23' : '#ffffff';
  const grid  = isDark ? '#2a2e35' : '#eef0f3';
  const textC = isDark ? '#9aa1ab' : '#6b7280';
  const MONO  = 'IBM Plex Mono, Consolas, monospace';

  const yAxes = PANELS.map(function(p){
    return {
      id:'ax-'+p.key,
      title:{ text:null },
      offset:0, lineWidth:0, opposite:false,
      labels:{ align:'right', x:-8, y:3, style:{ color:textC, fontSize:'11px', fontFamily:MONO },
        formatter:function(){ return p.key==='cp' ? this.value.toFixed(2) : this.value + '°'; } },
      startOnTick:false, endOnTick:false, minPadding:0.12, maxPadding:0.12,
      minRange:p.minRange, tickPixelInterval:40, showLastLabel:true,
      gridLineColor:grid, gridLineDashStyle:'Solid'
    };
  });
  yAxes.push({ id:'ax-memo', top:'0%', height:'100%', min:0, max:1, visible:false });

  const series = [];
  const data = seriesData();
  SERIES_DEF.forEach(function(d, i){
    series.push({
      id:'s'+i, name:d.name, data:data[i], yAxis:d.p, color:SERIES_COLORS[i],
      dashStyle:d.dash || 'Solid', legendIndex:d.p*100 + i, zIndex:2
    });
  });
  series.push({
    id:'memo', name:'메모', type:'scatter', data:memoPoints(), yAxis:MEMO_AXIS,
    color:SERIES_COLORS[16], marker:{ symbol:'circle', radius:3 }, legendIndex:999, zIndex:3,
    states:{ inactive:{ opacity:1 } },
    dataLabels:{
      enabled:true, useHTML:true, y:-6,
      style:{ fontFamily:MONO, fontSize:'11px', fontWeight:'500', color:'#475569', textOutline:'none' },
      formatter:function(){ return this.point.desc || ""; }
    },
    tooltip:{
      pointFormatter:function(){ return this.desc ? ('<span style="color:var(--imx-fg)">'+this.desc+'</span>') : ""; }
    }
  });

  chart = Highcharts.chart('container',{
    chart:{
      type: currentChartType,
      backgroundColor: bg,
      zoomType:'x',
      style:{ fontFamily:'IBM Plex Sans KR, Malgun Gothic, sans-serif' },
      spacing:[8,32,4,8],
      panning:true, panKey:'shift',
      animation:{ duration:300 },
      resetZoomButton:{
        position:{ align:'right', verticalAlign:'top', x:-44, y:0 },
        theme:{
          fill:'#ffffff', stroke:'#d9dde3', r:4, padding:6,
          style:{ color:'#374151', fontSize:'12px', fontWeight:'500' },
          states:{ hover:{ fill:'#f5f6f8', stroke:'#c4c9d1' } }
        },
        relativeTo:'chart'
      },
      events:{
        render: function(){ drawSpBands.call(this); drawPanelLabels.call(this); },
    	  selection: function (e) {
    		  const oe = e.originalEvent || {};
    		  const alt = !!oe.altKey;   // 드래그 이벤트 당시 Alt 상태

    		  if (e.xAxis && alt) {
    		    const xMin = Math.round(e.xAxis[0].min);
    		    const xMax = Math.round(e.xAxis[0].max);
    		    setTimeout(() => showRangeStats(xMin, xMax), 100);
    		  }
    		}
      }
    },
    title:{ text:null },
    credits:{ enabled:false },
    xAxis:{
      categories:categories,
      title:{ text:null },
      labels:{
        formatter:function(){ return dataLabelFormat(this.value); },
        step:40, style:{ color:textC, fontSize:'11px', fontFamily:MONO, textAlign:'center' }, useHTML:true
      },
      lineColor:grid, tickColor:grid, gridLineColor:grid,
      crosshair:{ width:1, color:'rgba(100,116,139,.45)', dashStyle:'Solid' }
    },
    yAxis: yAxes,
    legend:{
      enabled:true, layout:'horizontal', align:'center', verticalAlign:'bottom',
      borderWidth:0, backgroundColor:'transparent',
      itemStyle:{ fontSize:'11px', fontWeight:'400', color:textC },
      itemHoverStyle:{ color:'#111827' },
      itemHiddenStyle:{ color:isDark?'#484f58':'#c9ced6' },
      symbolRadius:0, symbolHeight:2, symbolWidth:14, itemDistance:16, margin:4, padding:4
    },
    tooltip:{
      shared:true,
      backgroundColor: isDark?'rgba(22,27,34,.95)':'rgba(255,255,255,.97)',
      borderColor: grid, borderRadius:6, borderWidth:1,
      shadow:{ color:'rgba(0,0,0,.08)', offsetX:0, offsetY:4, opacity:.6, width:8 }, padding:8,
      useHTML:true,
      formatter:function(){
        if(!this.points || !this.points.length) return '';

        var s = '<div style="font-family:var(--imx-mono);font-size:11px;color:var(--imx-fg2);margin-bottom:4px;">' + (this.x || '') + '</div>';
        var lastP = null;
        this.points.slice().sort(function(a,b){ return (a.series.options.legendIndex||0) - (b.series.options.legendIndex||0); })
        .forEach(function(pt){
          if(!pt || !pt.series || pt.series.name==='메모') return;
          var p = pt.series.options.yAxis;
          var isCP = p === 3;
          if(lastP !== null && p !== lastP) s += '<div style="height:1px;background:var(--imx-line);margin:4px 0;"></div>';
          lastP = p;
          var color = (typeof pt.series.color === 'object') ? '#aaa' : pt.series.color;
          var val = (pt.y===null||pt.y===undefined) ? '<span style="color:#94a3b8">-</span>'
                  : (isCP ? pt.y.toFixed(3) : pt.y.toFixed(1));
          var unit = isCP ? '' : ' °C';
          var valStyle='font-weight:500;';
          if(pt.y!==null && pt.y!==undefined && !isCP){
            if(pt.y>=960) valStyle+='color:var(--imx-danger);';
            else if((p===0) && (pt.y>=920||pt.y<=800)) valStyle+='color:var(--imx-warn);';
          }
          s+='<div style="display:flex;align-items:center;gap:8px;padding:1px 0;">'
            +'<span style="display:inline-block;width:10px;height:2px;background:'+color+';flex-shrink:0;"></span>'
            +'<span style="font-size:12px;flex:1;color:var(--imx-fg2);min-width:72px;">'+pt.series.name+'</span>'
            +'<span style="font-family:var(--imx-mono);font-variant-numeric:tabular-nums;font-size:12px;'+valStyle+'">'+val+unit+'</span>'
            +'</div>';
        });

        // 메모
        var regtime = categories[this.points[0].point.x];
        var labelHtml = signListObj[regtime] || "";
        if(labelHtml) s += '<hr/>' + labelHtml;

        return s;
      }
    },
    plotOptions:{
      line:  { lineWidth:1.25, marker:{enabled:false,radius:2} },
      spline:{ lineWidth:1.25, marker:{enabled:false,radius:2} },
      area:  { lineWidth:1.25, marker:{enabled:false,radius:2} },
      series:{
        animation:{ duration:300 },
        states:{ hover:{ lineWidth:2, lineWidthPlus:0, halo:false }, inactive:{ opacity:0.25 } },
        point:{
          events:{
            mouseOver:function(){
              updateLivePanel(this.x);
            }
          }
        }
      }
    },
    exporting:{ buttons:{ contextButton:{ y:-4, symbolStroke:'#9aa1ab', theme:{ fill:'transparent', states:{ hover:{ fill:'#f1f3f5' } } } } } },
    series: series
  });

  layoutPanels();
  if(currentChartType !== 'line') setChartType(currentChartType);

    // 임계값 플롯라인 초기 추가
    if(typeof showThreshold !== 'undefined' && showThreshold) addPlotLines();

    // 데모: 차트 영역 크기가 바뀌면(창 크기, 사이드바 접기) 다시 맞춤
    if(window.ResizeObserver && !window._trendRO){
      window._trendRO = new ResizeObserver(function(){ if(chart) chart.reflow(); });
      window._trendRO.observe(document.getElementById('container'));
    }
  }  // ← 함수 닫기

// ===================== 사이드 패널 업데이트 =====================
function updateLivePanel(xIndex){
  if(xIndex===undefined||xIndex===null) return;
  var time = categories && categories[xIndex] ? categories[xIndex] : '-';
  document.getElementById('liveTime').textContent = time.length>16 ? time.substring(5,16) : time;

  var groups = [
    { label:'소입로', color:'var(--text-s)', items:[
      {name:'소입로1존',color:SERIES_COLORS[1],data:q_pv_1},
      {name:'소입로2존',color:SERIES_COLORS[2],data:q_pv_2},
      {name:'소입로3존',color:SERIES_COLORS[3],data:q_pv_3},
      {name:'소입로4존',color:SERIES_COLORS[4],data:q_pv_4},
      {name:'소입로5존',color:SERIES_COLORS[5],data:q_pv_5},
      {name:'소입유조', color:SERIES_COLORS[6],data:oil_pv}
    ]},
    { label:'소려로', color:'var(--text-s)', items:[
      {name:'소려로1존',color:SERIES_COLORS[9], data:t_pv_1},
      {name:'소려로2존',color:SERIES_COLORS[10],data:t_pv_2},
      {name:'소려로3존',color:SERIES_COLORS[11],data:t_pv_3},
      {name:'소려로4존',color:SERIES_COLORS[12],data:t_pv_4},
      {name:'소려로5존',color:SERIES_COLORS[13],data:t_pv_5}
    ]},
    { label:'세정 / 기타', color:'var(--text-s)', items:[
      {name:'전세정기', color:SERIES_COLORS[0],data:f_wash_pv},
      {name:'중간세정기',color:SERIES_COLORS[7],data:m_wash_pv},
      {name:'방청조',   color:SERIES_COLORS[8],data:bc_pv}
    ]},
    { label:'CP', color:'var(--text-s)', items:[
      {name:'CP-A',color:SERIES_COLORS[14],data:cp_pv_1,isCP:true},
      {name:'CP-B',color:SERIES_COLORS[15],data:cp_pv_2,isCP:true}
    ]}
  ];

  var html = '';
  groups.forEach(function(grp){
    html += '<div style="padding:6px 12px 3px;font-size:10px;font-weight:800;letter-spacing:.5px;text-transform:uppercase;'
          + 'color:'+grp.color+';border-bottom:1px solid var(--border);background:var(--surface2);">'+grp.label+'</div>';
    grp.items.forEach(function(s){
      var val = s.data ? s.data[xIndex] : null;
      var dispVal, cls='';
      if(val===null||val===undefined){
        dispVal='--';
      } else {
        dispVal = s.isCP ? val.toFixed(3) : val.toFixed(1);
        if(!s.isCP){
          if(val>=960) cls='alarm';
          else if(val>=920||val<=800) cls='warn';
        }
      }
      var unit = (val!==null&&val!==undefined&&!s.isCP) ? ' °C' : '';
      var valColor = cls==='alarm'?'var(--imx-danger)':(cls==='warn'?'var(--imx-warn)':'var(--text-p)');
      html += '<div style="display:flex;align-items:center;justify-content:space-between;'
            + 'padding:7px 12px;border-bottom:1px solid var(--border);">'
            + '<div style="display:flex;align-items:center;gap:7px;">'
            + '<span style="display:inline-block;width:7px;height:7px;border-radius:50%;background:'+s.color+';flex-shrink:0;"></span>'
            + '<span style="font-size:12px;font-weight:600;color:var(--text-s);">'+s.name+'</span>'
            + '</div>'
            + '<span style="font-size:13px;font-weight:500;font-family:var(--imx-mono);font-variant-numeric:tabular-nums;color:'+valColor+';">'+dispVal+unit+'</span>'
            + '</div>';
    });
  });

  // 메모가 있으면 하단에 표시 (signListObj 기준)
  var regtime = categories && categories[xIndex] ? categories[xIndex] : null;
  var memoHtml = regtime ? (signListObj[regtime] || '') : '';
  if(memoHtml){
    html += '<div style="padding:10px 12px;background:var(--imx-bg);border-top:1px solid var(--border);">'
          + '<div style="font-size:10px;font-weight:600;color:var(--text-s);margin-bottom:4px;">메모</div>'
          + '<div style="font-size:12px;color:#374151;line-height:1.6;">'+memoHtml+'</div>'
          + '</div>';
  }

  document.getElementById('liveGrid').innerHTML = html;
}

// ===================== 구간 통계 =====================
function showRangeStats(xMin, xMax){
  if(!categories) return;
  const from = Math.max(0, xMin), to = Math.min(categories.length-1, xMax);
  const cnt = to - from + 1;

  const seriesList = [
    { name:'전세정기',  data:f_wash_pv, unit:'°C' },
    { name:'소입로1~5존', data:[...q_pv_1,...q_pv_2,...q_pv_3,...q_pv_4,...q_pv_5].slice(from*(5)-from, to*(5)-from), unit:'°C' },
    { name:'소입로1존', data:q_pv_1, unit:'°C' },
    { name:'소입로2존', data:q_pv_2, unit:'°C' },
    { name:'소입로3존', data:q_pv_3, unit:'°C' },
    { name:'소려로1존', data:t_pv_1, unit:'°C' },
    { name:'소려로2존', data:t_pv_2, unit:'°C' },
    { name:'소려로3존', data:t_pv_3, unit:'°C' },
    { name:'CP-A',      data:cp_pv_1, unit:'' },
    { name:'CP-B',      data:cp_pv_2, unit:'' },
  ];

  let html = '<div style="font-size:12px;color:var(--text-s);margin-bottom:12px;">'
           + '구간: <strong style="color:var(--text-p)">'+categories[from]+'</strong> ~ <strong style="color:var(--text-p)">'+categories[to]+'</strong>'
           + '<span style="margin-left:8px;background:var(--surface2);padding:2px 8px;border-radius:6px;font-family:var(--imx-mono);font-variant-numeric:tabular-nums;">'+cnt+'pt</span>'
           + '</div>';

  html += '<table style="width:100%;border-collapse:collapse;font-size:12px;">'
        + '<thead><tr style="border-bottom:1px solid var(--border);">'
        + '<th style="text-align:left;padding:6px 8px;color:var(--text-s);font-weight:500;">시리즈</th>'
        + '<th style="text-align:right;padding:6px 8px;color:var(--text-s);font-weight:500;">최소</th>'
        + '<th style="text-align:right;padding:6px 8px;color:var(--text-s);font-weight:500;">최대</th>'
        + '<th style="text-align:right;padding:6px 8px;color:var(--text-s);font-weight:500;">평균</th>'
        + '</tr></thead><tbody>';

  const allSeriesForStats = [
    {name:'전세정기',data:f_wash_pv,unit:'°C'},
    {name:'소입로1존',data:q_pv_1,unit:'°C'},{name:'소입로2존',data:q_pv_2,unit:'°C'},
    {name:'소입로3존',data:q_pv_3,unit:'°C'},{name:'소입로4존',data:q_pv_4,unit:'°C'},
    {name:'소입로5존',data:q_pv_5,unit:'°C'},{name:'소입유조',data:oil_pv,unit:'°C'},
    {name:'중간세정기',data:m_wash_pv,unit:'°C'},{name:'방청조',data:bc_pv,unit:'°C'},
    {name:'소려로1존',data:t_pv_1,unit:'°C'},{name:'소려로2존',data:t_pv_2,unit:'°C'},
    {name:'소려로3존',data:t_pv_3,unit:'°C'},{name:'소려로4존',data:t_pv_4,unit:'°C'},
    {name:'소려로5존',data:t_pv_5,unit:'°C'},
    {name:'CP-A',data:cp_pv_1,unit:''},{name:'CP-B',data:cp_pv_2,unit:''},
  ];

  allSeriesForStats.forEach((s,i) => {
    if(!s.data) return;
    const slice = s.data.slice(from, to+1);
    const st = calcStats(slice);
    if(!st) return;
    const rowBg = i%2===0?'background:var(--surface2);':'';
    const dec = s.unit ? 1 : 3;
    html += '<tr style="'+rowBg+'">'
          + '<td style="padding:5px 8px;font-weight:600;color:var(--text-p);">'
          + '<span style="display:inline-block;width:6px;height:6px;border-radius:50%;background:'+SERIES_COLORS[i]+';margin-right:5px;"></span>'+s.name
          + '</td>'
          + '<td style="padding:5px 8px;text-align:right;font-family:var(--imx-mono);font-variant-numeric:tabular-nums;color:var(--text-s);">'+st.min.toFixed(dec)+s.unit+'</td>'
          + '<td style="padding:5px 8px;text-align:right;font-family:var(--imx-mono);font-variant-numeric:tabular-nums;color:var(--text-s);">'+st.max.toFixed(dec)+s.unit+'</td>'
          + '<td style="padding:5px 8px;text-align:right;font-family:var(--imx-mono);font-variant-numeric:tabular-nums;font-weight:500;color:var(--text-p);">'+st.avg+s.unit+'</td>'
          + '</tr>';
  });

  html += '</tbody></table>';

  document.getElementById('rangeStatsContent').innerHTML = html;
  const modal = document.getElementById('rangeStatsModal');
  modal.style.display = 'flex';
}

// ===================== Excel 다운로드 =====================
function downloadExcel(){
  if(!chart||!categories||!categories.length){ alert("다운로드할 데이터가 없습니다."); return; }
  $("#excelOverlay").show(); $("#excelLoading").show();
  try{
    const excelData = categories.map((time,idx)=>({
      "시간": time||"",
      "전세정기":  f_wash_pv[idx]!==null?f_wash_pv[idx]:"",
      "소입로1존": q_pv_1[idx]!==null?q_pv_1[idx]:"",
      "소입로2존": q_pv_2[idx]!==null?q_pv_2[idx]:"",
      "소입로3존": q_pv_3[idx]!==null?q_pv_3[idx]:"",
      "소입로4존": q_pv_4[idx]!==null?q_pv_4[idx]:"",
      "소입로5존": q_pv_5[idx]!==null?q_pv_5[idx]:"",
      "소입유조":  oil_pv[idx]!==null?oil_pv[idx]:"",
      "중간세정기":m_wash_pv[idx]!==null?m_wash_pv[idx]:"",
      "방청조":    bc_pv[idx]!==null?bc_pv[idx]:"",
      "소려로1존": t_pv_1[idx]!==null?t_pv_1[idx]:"",
      "소려로2존": t_pv_2[idx]!==null?t_pv_2[idx]:"",
      "소려로3존": t_pv_3[idx]!==null?t_pv_3[idx]:"",
      "소려로4존": t_pv_4[idx]!==null?t_pv_4[idx]:"",
      "소려로5존": t_pv_5[idx]!==null?t_pv_5[idx]:"",
      "CP-A":      cp_pv_1[idx]!==null?cp_pv_1[idx]:"",
      "CP-B":      cp_pv_2[idx]!==null?cp_pv_2[idx]:"",
      "메모":      (memoSeries.find(m=>m.x===idx)||{desc:""}).desc.replace(/<br\/>/g," | ")
    }));
    const ws=XLSX.utils.json_to_sheet(excelData);
    ws['!cols']=[{wch:20},...Array(16).fill({wch:12}),{wch:50}];
    const wb=XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb,ws,"온도트렌드");
    const fn="온도트렌드_"+$("#startDate").val().replace(/[-:\s]/g,'').substring(0,12)+"_"+$("#endDate").val().replace(/[-:\s]/g,'').substring(0,12)+".xlsx";
    XLSX.writeFile(wb,fn);
    setTimeout(()=>{ $("#excelOverlay").hide(); $("#excelLoading").hide(); },500);
  } catch(e){
    console.error(e); alert("엑셀 다운로드에 실패했습니다.");
    $("#excelOverlay").hide(); $("#excelLoading").hide();
  }
}
</script>

</body>
</html>
