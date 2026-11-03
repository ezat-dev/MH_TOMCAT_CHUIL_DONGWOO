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
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">

  <style>
    /* ===================== Design System (통일) ===================== */
    :root {
      --bg:           #f0f2f7;
      --surface:      #ffffff;
      --surface2:     #f7f8fc;
      --surface3:     #eef1f8;
      --border:       #e2e6ef;
      --border-focus: #2563eb;
      --text-p:       #0f172a;
      --text-s:       #64748b;
      --text-m:       #94a3b8;
      --accent:       #2563eb;
      --accent-dk:    #1d4ed8;
      --accent-lt:    #eff6ff;
      --green:        #16a34a;
      --green-lt:     #f0fdf4;
      --green-dk:     #15803d;
      --red:          #dc2626;
      --red-lt:       #fff5f5;
      --amber:        #d97706;
      --amber-lt:     #fffbeb;
      --indigo:       #4f46e5;
      --indigo-lt:    #eef2ff;
      --indigo-dk:    #4338ca;
      --shadow-sm:    0 1px 4px rgba(0,0,0,.07);
      --shadow-lg:    0 18px 60px rgba(0,0,0,.20);
      --radius-sm:    8px;
      --radius:       12px;
      --topbar-h:     56px;
      --transition:   .15s cubic-bezier(.4,0,.2,1);
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Noto Sans KR', sans-serif; background: var(--bg); color: var(--text-p); min-height: 100vh; }

    /* ===== TOPBAR ===== */
    .topbar {
      position: sticky; top: 0; z-index: 200;
      background: rgba(255,255,255,.94);
      backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px);
      border-bottom: 1px solid var(--border); box-shadow: var(--shadow-sm);
    }
    .topbar-inner {
      max-width: 1600px; margin: 0 auto; height: var(--topbar-h);
      padding: 0 20px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
    }
    .topbar-title {
      font-size: 14px; font-weight: 900; letter-spacing: -.4px;
      color: var(--text-p); display: flex; align-items: center; gap: 8px;
      white-space: nowrap; margin-right: 4px;
    }
    .topbar-title .icon-wrap {
      width: 28px; height: 28px; border-radius: 8px;
      background: linear-gradient(135deg, var(--indigo), var(--indigo-dk));
      display: flex; align-items: center; justify-content: center;
      font-size: 14px; box-shadow: 0 2px 8px rgba(79,70,229,.32);
    }
    .divider { width: 1px; height: 20px; background: var(--border); flex-shrink: 0; }

    .btn {
      height: 34px; padding: 0 14px; border-radius: var(--radius-sm);
      font-size: 12px; font-weight: 900; font-family: inherit;
      display: inline-flex; align-items: center; gap: 6px;
      cursor: pointer; border: 1px solid transparent;
      transition: transform .08s, filter var(--transition), box-shadow var(--transition);
      white-space: nowrap; user-select: none; letter-spacing: -.1px;
    }
    .btn:active { transform: translateY(1px); }
    .btn:hover  { filter: brightness(1.06); }
    .btn svg    { width: 14px; height: 14px; flex-shrink: 0; }

    .btn-save   { background: linear-gradient(135deg,var(--indigo),var(--indigo-dk)); color:#fff; border-color:var(--indigo-dk); box-shadow:0 1px 4px rgba(79,70,229,.28); }
    .btn-allup  { background: linear-gradient(135deg,#16a34a,#15803d); color:#fff; border-color:#15803d; box-shadow:0 1px 4px rgba(22,163,74,.25); }
    .btn-allno  { background: var(--surface); color: var(--text-s); border-color: var(--border); }
    .btn-allno:hover { background: var(--surface2); }
    .btn-reset  { background: var(--surface); color: var(--red); border-color: var(--border); }
    .btn-reset:hover { background: var(--red-lt); }

    /* ===== PAGE ===== */
    .page-wrap {
      max-width: 1600px; margin: 0 auto;
      padding: 16px 20px 28px;
      display: flex; flex-direction: column; gap: 14px;
    }

    /* ===== CARD ===== */
    .card {
      background: var(--surface); border: 1px solid var(--border);
      border-radius: var(--radius); box-shadow: var(--shadow-sm); overflow: hidden;
    }
    .card-header {
      padding: 11px 16px; border-bottom: 1px solid var(--border); background: var(--surface2);
      display: flex; align-items: center; justify-content: space-between; gap: 10px;
    }
    .card-title {
      font-size: 12px; font-weight: 900; color: var(--text-p); letter-spacing: -.2px;
      display: flex; align-items: center; gap: 7px;
    }
    .card-title::before { content:''; display:inline-block; width:3px; height:13px; border-radius:3px; }
    .card-title.indigo::before { background: var(--indigo); }
    .card-title.green::before  { background: var(--green); }
    .card-meta { font-size: 11px; color: var(--text-m); font-family: 'JetBrains Mono',monospace; font-weight: 500; }

    /* ===== TABULATOR (사용자 목록) ===== */
    #dataList { padding: 10px; }
    .tabulator { border: none !important; font-size: 13px !important; font-family: 'Noto Sans KR',sans-serif !important; }
    .tabulator .tabulator-header { background: var(--surface2) !important; border-bottom: 1px solid var(--border) !important; }
    .tabulator .tabulator-header .tabulator-col {
      background: var(--surface2) !important; border-right: 1px solid var(--border) !important;
      color: var(--text-s) !important; font-size: 11px !important; font-weight: 800 !important;
    }
    .tabulator-row { border-bottom: 1px solid #f1f4fa !important; transition: background var(--transition) !important; }
    .tabulator-row:hover { background: #f5f3ff !important; }
    .tabulator-row.row_select { background: var(--indigo-lt) !important; border-left: 3px solid var(--indigo) !important; }
    .tabulator-cell { color: var(--text-p) !important; }

    /* ===== 선택된 사용자 배지 ===== */
    .user-badge {
      display: inline-flex; align-items: center; gap: 7px;
      padding: 5px 14px; border-radius: 20px;
      background: var(--indigo-lt); border: 1px solid #c7d2fe;
      font-size: 12px; font-weight: 800; color: var(--indigo);
    }
    .user-badge .badge-dot {
      width: 7px; height: 7px; border-radius: 50%;
      background: var(--indigo); animation: pulse 2s infinite;
    }
    @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.35} }

    /* ===== 권한 그리드 ===== */
    .perm-grid {
      display: grid;
      grid-template-columns: repeat(6, 1fr);
      gap: 12px;
      padding: 16px;
    }
    @media(max-width:1200px){ .perm-grid{ grid-template-columns:repeat(3,1fr); } }
    @media(max-width:800px) { .perm-grid{ grid-template-columns:repeat(2,1fr); } }

    /* 권한 섹션 카드 */
    .perm-section {
      background: var(--surface2); border: 1px solid var(--border);
      border-radius: var(--radius-sm); overflow: hidden;
    }
    .perm-section-head {
      padding: 9px 12px; border-bottom: 1px solid var(--border);
      font-size: 11px; font-weight: 900; color: var(--text-p);
      display: flex; align-items: center; gap: 6px;
      letter-spacing: -.1px;
    }
    .perm-section-head .dot {
      width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0;
    }
    /* 섹션별 색상 */
    .dot-a { background: var(--indigo); }
    .dot-b { background: var(--amber); }
    .dot-c { background: var(--green); }
    .dot-d { background: #0d9488; }
    .dot-e { background: #dc2626; }
    .dot-f { background: #7c3aed; }

    .perm-section-body { padding: 8px 10px; display: flex; flex-direction: column; gap: 6px; }

    .perm-row {
      display: flex; align-items: center; gap: 6px;
    }
    .perm-label {
      font-size: 11px; font-weight: 700; color: var(--text-s);
      flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .perm-select {
      height: 30px; padding: 0 6px;
      border: 1px solid var(--border); border-radius: 6px;
      background: var(--surface); color: var(--text-p);
      font-size: 11px; font-family: inherit; font-weight: 700;
      outline: none; cursor: pointer; min-width: 58px;
      transition: border-color var(--transition), box-shadow var(--transition);
      appearance: none; -webkit-appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 5px center;
      padding-right: 20px;
    }
    .perm-select:focus { border-color: var(--border-focus); box-shadow: 0 0 0 2px rgba(37,99,235,.12); }

    /* 권한 값에 따른 색상 */
    .perm-select[data-val="N"] { color: var(--text-m); }
    .perm-select[data-val="R"] { color: var(--accent); border-color: #bfdbfe; background-color: var(--accent-lt); }
    .perm-select[data-val="I"] { color: var(--green);  border-color: #bbf7d0; background-color: var(--green-lt); }
    .perm-select[data-val="U"] { color: var(--amber);  border-color: #fde68a; background-color: var(--amber-lt); }
    .perm-select[data-val="D"] { color: var(--red);    border-color: #fecaca; background-color: var(--red-lt); }

    /* footer badge */
    .footer-badge {
      display: inline-flex; align-items: center; gap: 5px; padding: 3px 10px;
      border-radius: 20px; background: var(--surface2); border: 1px solid var(--border);
      font-size: 11px; font-family: 'JetBrains Mono',monospace; color: var(--text-s); font-weight: 600;
    }
  </style>
</head>

<body>

  <!-- ===== TOPBAR ===== -->
  <div class="topbar">
    <div class="topbar-inner">

      <div class="topbar-title">
        <span class="icon-wrap">🔑</span>
        사용자 권한부여
      </div>
      <div class="divider"></div>

      <!-- 선택 사용자 표시 -->
      <span class="user-badge">
        <span class="badge-dot"></span>
        <span id="selectedUserName">사용자를 선택하세요</span>
      </span>

      <div style="margin-left:auto; display:flex; align-items:center; gap:8px;">
        <button class="btn btn-allno allNo">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/>
          </svg>전체없음
        </button>
        <button class="btn btn-allup allUpdate">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="20 6 9 17 4 12"/>
          </svg>최고권한
        </button>
        <button class="btn btn-reset clearAut">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/>
          </svg>초기화
        </button>
        <button class="btn btn-save saveAut">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
            <polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/>
          </svg>저장
        </button>
      </div>

    </div>
  </div>

  <!-- ===== PAGE ===== -->
  <div class="page-wrap">

    <!-- 사용자 목록 테이블 -->
    <div class="card">
      <div class="card-header">
        <div class="card-title indigo">사용자 목록</div>
        <div class="card-meta">클릭하여 사용자 선택 → 하단 권한 편집</div>
      </div>
      <div id="dataList"></div>
    </div>

    <!-- 권한 설정 카드 -->
    <div class="card">
      <div class="card-header">
        <div class="card-title green">메뉴 권한 설정</div>
        <div class="card-meta">없음(N) · 조회(R) · 저장(I) · 수정(U) · 삭제(D)</div>
      </div>

      <form id="permissionForm">
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
    </div>

  </div><!-- /.page-wrap -->

  <!-- ===== SCRIPT ===== -->
  <script>
    let now_page_code = "a05";

    /* select 값 변경 시 색상 갱신 */
    function refreshSelectColor(sel) {
      if (!sel) return;
      sel.setAttribute('data-val', sel.value);
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
          height: '220px',
          layout: 'fitColumns',
          reactiveData: true,
          ajaxConfig: { method: 'POST' },
          ajaxLoader: false,
          ajaxURL: '/line/user/userPermission/userSelect',
          ajaxResponse: function (url, params, response) { return response.data; },
          placeholder: '조회된 데이터가 없습니다.',
          headerHozAlign: 'center',
          columns: [
            { title: 'NO',       field: 'idx',       width: 60,  hozAlign: 'center' },
            { title: '아이디',   field: 'user_id',   width: 150, hozAlign: 'center' },
            { title: '성명',     field: 'user_name', width: 120, hozAlign: 'center' },
            { title: '부서',     field: 'user_busu', width: 150, hozAlign: 'center' },
            { title: '직책',     field: 'user_jick', width: 120, hozAlign: 'center' },
            { title: 'user_code',field: 'user_code', visible: false }
          ],
          rowClick: function (e, row) {
            var data = row.getData();
            $('#user_code').val(data.user_code);
            $('#selectedUserName').text(data.user_name + ' (' + (data.user_busu || '-') + ')');

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
