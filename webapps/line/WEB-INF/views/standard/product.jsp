<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<script src="/line/mock/mock-loader.js"></script>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>제품 관리</title>

  <%@include file="../include/pluginpage.jsp" %>
  <jsp:include page="../include/tabBar.jsp"/>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+KR:wght@400;500;600&display=swap">
  <link rel="stylesheet" href="/line/css/opsList/ops-list.css">

  <style>
    /* ===== 데모: 제품 관리 — ops-list 공통 위에 페이지 전용 규칙 ===== */
    html, body.ops { height: 100%; }
    body.ops { display: flex; flex-direction: column; overflow: hidden; }
    body.ops h1, body.ops h2, body.ops p { margin: 0; }
    .ops-input.sans { font-family: var(--ops-sans); }
    .ops-input::placeholder { color: var(--ops-fg3); font-family: var(--ops-sans); }

    /* 페이지: 남는 높이를 표 카드가 모두 차지 → 페이지 스크롤 없음, 표 안에서만 스크롤 */
    .ops-page { flex: 1; min-height: 0; }
    .ops-card.fill { flex: 1; min-height: 0; display: flex; flex-direction: column; }
    .ops-card.fill #dataList { flex: 1; min-height: 0; }

    /* Tabulator 4 보정 */
    #dataList.tabulator { border: 0; background: #fff; }
    #dataList .tabulator-header .tabulator-col { text-align: center; }
    #dataList .tabulator-header-filter { margin-top: 4px; }
    #dataList .tabulator-col.tabulator-sortable .tabulator-col-title { padding-right: 14px !important; }
    #dataList .tabulator-col .tabulator-col-content .tabulator-arrow { right: 6px; }
    #dataList .tabulator-header-filter input {
      height: 24px !important; padding: 0 6px !important; border: 1px solid var(--ops-line) !important; border-radius: 4px !important;
      background: #fff !important; font-family: var(--ops-sans) !important; font-size: 12px !important; color: var(--ops-fg) !important;
    }
    #dataList .tabulator-header-filter input:focus { border-color: var(--ops-accent) !important; outline: none !important; }
    #dataList .tabulator-header-filter input::placeholder { color: var(--ops-fg3); }
    #dataList .tabulator-cell.c-code { font-family: var(--ops-mono); font-size: 12px; font-variant-numeric: tabular-nums slashed-zero; color: var(--ops-fg2); }
    #dataList .tabulator-cell.c-key { font-family: var(--ops-mono); font-size: 12px; font-weight: 500; font-variant-numeric: tabular-nums slashed-zero; }
    #dataList .tabulator-cell.c-num { font-family: var(--ops-mono); font-variant-numeric: tabular-nums; }
    #dataList .tabulator-cell.c-num.zero { color: var(--ops-fg3); }
    #dataList .tabulator-cell.c-img { padding: 3px 8px !important; line-height: normal !important; }

    /* 이미지 썸네일 */
    .img-thumb { width: 28px; height: 28px; object-fit: cover; border-radius: 4px; border: 1px solid var(--ops-line); cursor: zoom-in; display: block; margin: 0 auto; }
    .img-thumb:hover { border-color: var(--ops-accent); }
    .img-placeholder { width: 28px; height: 28px; margin: 0 auto; border: 1px dashed var(--ops-line); border-radius: 4px; }

    /* ===== 등록/수정 모달: 머리·바닥 고정, 본문만 스크롤 ===== */
    .modal { display: none; position: fixed; inset: 0; z-index: 9999; align-items: center; justify-content: center; padding: 16px; background: oklch(20% 0.01 255 / 0.4); }
    .modal.show { display: flex; }
    .modal-content {
      width: 720px; max-width: 95vw; max-height: 92vh; display: flex; flex-direction: column; overflow: hidden;
      background: #fff; border: 1px solid var(--ops-line); border-radius: 8px; box-shadow: 0 12px 32px oklch(20% 0.01 255 / 0.16);
      font-family: var(--ops-sans); color: var(--ops-fg);
    }
    .modal-content .modal-head { flex-shrink: 0; gap: 12px; }
    .modal-head .modal-title { font-size: 15px; font-weight: 600; }
    .modal-head .modal-subtitle { font-size: 12px; color: var(--ops-fg3); margin-top: 2px; }
    .modal-content .close {
      width: 28px; height: 28px; flex-shrink: 0; display: flex; align-items: center; justify-content: center;
      border: 0; border-radius: 6px; background: transparent; color: var(--ops-fg2); font-size: 18px; line-height: 1; cursor: pointer; opacity: 1; text-shadow: none; float: none;
    }
    .modal-content .close:hover { background: var(--ops-hover); color: var(--ops-fg); }
    #corrForm { flex: 1; min-height: 0; display: flex; flex-direction: column; }
    #corrForm .modal-body { flex: 1; min-height: 0; overflow-y: auto; display: flex; flex-direction: column; gap: 16px; }
    #corrForm .modal-btn-row { flex-shrink: 0; }

    .form-section-title { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; font-size: 12px; font-weight: 600; color: var(--ops-fg); }
    .form-section-title::after { content: ""; flex: 1; height: 1px; background: var(--ops-line2); }
    .form-section-title .hint { font-weight: 400; color: var(--ops-fg3); }
    .form-label .required { color: var(--ops-bad); margin-left: 2px; }
    .form-label .auto { color: var(--ops-fg3); font-weight: 400; }
    .form-input[readonly] { background: var(--ops-bg); color: var(--ops-fg3); cursor: not-allowed; }
    .form-input.mono, .form-input[type="number"] { font-variant-numeric: tabular-nums; }
    .form-input[type="number"] { text-align: right; }
    .form-input::placeholder { color: var(--ops-fg3); }
    .range-row { display: grid; grid-template-columns: 1fr auto 1fr; align-items: center; gap: 8px; }
    .range-row .tilde { color: var(--ops-fg3); }

    /* 이미지 슬롯 5칸 */
    .img-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 8px; }
    .img-slot { display: flex; flex-direction: column; gap: 4px; min-width: 0; }
    .img-slot-label { font-size: 12px; color: var(--ops-fg2); }
    .img-preview-box {
      aspect-ratio: 1; display: flex; align-items: center; justify-content: center; overflow: hidden; cursor: pointer;
      border: 1px dashed var(--ops-line); border-radius: 6px; background: var(--ops-bg); transition: border-color 80ms;
    }
    .img-preview-box:hover { border-color: var(--ops-accent); }
    .img-preview-box img { width: 100%; height: 100%; object-fit: cover; }
    .img-preview-box .img-empty { display: flex; flex-direction: column; align-items: center; gap: 4px; color: var(--ops-fg3); font-size: 12px; }
    .img-preview-box .img-empty svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 1.5; }
    .img-slot input[type="file"] { display: none; }
    .img-slot-name { font-family: var(--ops-mono); font-size: 11px; color: var(--ops-fg3); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    /* 이미지 크게 보기 */
    .img-preview-modal { display: none; position: fixed; inset: 0; z-index: 10000; align-items: center; justify-content: center; background: oklch(15% 0.01 255 / 0.82); }
    .img-preview-modal.show { display: flex; }
    .img-preview-modal img { max-width: 88vw; max-height: 88vh; border-radius: 6px; background: #fff; }
    .img-preview-close {
      position: absolute; top: 16px; right: 24px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;
      border: 1px solid oklch(100% 0 0 / 0.25); border-radius: 6px; background: transparent; color: #fff; font-size: 18px; cursor: pointer;
    }
    .img-preview-close:hover { background: oklch(100% 0 0 / 0.12); }

    /* 엑셀 생성 중 */
    #excelOverlay { display: none; position: fixed; inset: 0; z-index: 9998; background: oklch(20% 0.01 255 / 0.3); }
    #excelLoading {
      display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 9999;
      padding: 16px 24px; background: #fff; border: 1px solid var(--ops-line); border-radius: 8px; font-family: var(--ops-sans); font-size: 13px; color: var(--ops-fg);
    }

    @media (max-width: 900px) {
      .form-grid { grid-template-columns: 1fr; }
      .img-grid { grid-template-columns: repeat(3, 1fr); }
    }
  </style>
</head>

<body class="ops">

  <!-- ===== 헤더 + 툴바 ===== -->
  <header class="ops-head">
    <div class="ops-head-in">
      <h1 class="ops-title">제품 관리</h1>

      <span class="ops-label">품번</span>
      <input type="text" id="search_item_no" class="ops-input" style="width:140px;" placeholder="품번">
      <span class="ops-label">품명</span>
      <input type="text" id="search_item_name" class="ops-input sans" style="width:160px;" placeholder="품명">
      <span class="ops-label">거래처명</span>
      <input type="text" id="search_cust_name" class="ops-input sans" style="width:140px;" placeholder="거래처명">
      <button class="ops-btn select-button">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16" y2="16"/></svg>조회
      </button>

      <span class="ops-spacer"></span>

      <button class="ops-btn excel-button">
        <svg viewBox="0 0 24 24"><path d="M12 4v11"/><polyline points="7 10 12 15 17 10"/><line x1="5" y1="20" x2="19" y2="20"/></svg>Download
      </button>
      <button class="ops-btn danger delete-button">
        <svg viewBox="0 0 24 24"><polyline points="4 7 20 7"/><path d="M18 7l-1 13H7L6 7"/><path d="M9 7V4h6v3"/></svg>삭제
      </button>
      <button class="ops-btn primary insert-button">
        <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>제품 추가
      </button>
    </div>
  </header>

  <main class="ops-page">

    <!-- 지표: 등록 제품 수가 첫 시선 -->
    <section class="ops-kpi" aria-label="요약">
      <div class="hero">
        <span class="kpi-label">등록 제품</span>
        <span class="kpi-value" id="kpi-prod">0</span>
        <span class="kpi-sub">조회 결과 기준</span>
      </div>
      <div>
        <span class="kpi-label">거래처</span>
        <span class="kpi-value" id="kpi-cust">0</span>
        <span class="kpi-sub">제품이 있는 거래처 수</span>
      </div>
      <div>
        <span class="kpi-label">경도 기준 미설정</span>
        <span class="kpi-value" id="kpi-nohrc">0</span>
        <span class="kpi-sub">퀜칭·심부 상하한 모두 0</span>
      </div>
      <div>
        <span class="kpi-label">제품 사진 미등록</span>
        <span class="kpi-value" id="kpi-noimg">0</span>
        <span class="kpi-sub">제품 사진 1·2 모두 없음</span>
      </div>
      <div>
        <span class="kpi-label">최근 등록일</span>
        <span class="kpi-value" id="kpi-last">-</span>
        <span class="kpi-sub" id="kpi-last-sub">&nbsp;</span>
      </div>
    </section>

    <!-- 제품 목록 -->
    <section class="ops-card fill">
      <div class="ops-card-head">
        <h2>제품 목록</h2>
        <span class="note">행을 두 번 눌러 수정 · 사진을 눌러 크게 보기</span>
      </div>
      <div id="dataList" class="ops-table"></div>
      <div class="ops-card-foot">
        <span>헤더 아래 입력칸으로 열별 필터</span>
        <span id="footer-info">0 rows</span>
      </div>
    </section>
  </main>

  <!-- ===== 등록/수정 모달 ===== -->
  <div id="modalContainer" class="modal">
    <div class="modal-content" role="dialog" aria-modal="true" aria-labelledby="modalTitleText">
      <div class="modal-head">
        <div>
          <div class="modal-title" id="modalTitleText">제품 등록</div>
          <div class="modal-subtitle" id="modalSubtitle">신규 제품을 등록합니다</div>
        </div>
        <button class="close" type="button" aria-label="닫기">&times;</button>
      </div>

      <form id="corrForm" method="post" enctype="multipart/form-data" autocomplete="off">
        <input type="hidden" name="prod_id">

        <div class="modal-body">
          <!-- 기본 정보 -->
          <div class="form-section">
            <div class="form-section-title">기본 정보</div>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label" for="prod_code">제품코드 <span class="auto">자동 생성</span></label>
                <input type="text" id="prod_code" name="prod_code" class="form-input mono" placeholder="자동 생성" readonly>
              </div>
              <div class="form-group">
                <label class="form-label" for="cust_name">거래처명 <span class="required">*</span></label>
                <select id="cust_name" name="cust_name" class="form-select">
                  <option value="">선택하세요</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label" for="cust_code">거래처코드 <span class="auto">자동 생성</span></label>
                <input type="text" id="cust_code" name="cust_code" class="form-input mono" placeholder="자동 생성" readonly>
              </div>
              <div class="form-group">
                <label class="form-label" for="item_no">품번 <span class="required">*</span></label>
                <input type="text" id="item_no" name="item_no" class="form-input mono" placeholder="예: ITEM001">
              </div>
              <div class="form-group full">
                <label class="form-label" for="item_name">품명 <span class="required">*</span></label>
                <input type="text" id="item_name" name="item_name" class="form-input" placeholder="제품명을 입력하세요">
              </div>
            </div>
          </div>

          <!-- 상세 스펙 -->
          <div class="form-section">
            <div class="form-section-title">상세 스펙</div>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label" for="spec">규격</label>
                <input type="text" id="spec" name="spec" class="form-input mono" placeholder="규격">
              </div>
              <div class="form-group">
                <label class="form-label" for="texture">재질</label>
                <input type="text" id="texture" name="texture" class="form-input mono" placeholder="재질">
              </div>
              <div class="form-group">
                <label class="form-label" for="material">장입량 (kg)</label>
                <input type="number" id="material" name="material" class="form-input" placeholder="0" value="0" min="0">
              </div>
              <div class="form-group">
                <label class="form-label" for="unit_price">단가 (원)</label>
                <input type="number" id="unit_price" name="unit_price" class="form-input" placeholder="0">
              </div>
              <div class="form-group">
                <label class="form-label" for="weight">중량 (g)</label>
                <input type="number" id="weight" name="weight" class="form-input" placeholder="0">
              </div>
            </div>
          </div>

          <!-- 경도 기준: 하한 ~ 상한을 한 줄로 -->
          <div class="form-section">
            <div class="form-section-title">경도 기준</div>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label" for="quench_low">퀜칭 경도 <span class="auto">하한 ~ 상한</span></label>
                <div class="range-row">
                  <input type="number" id="quench_low" name="quench_low" class="form-input" placeholder="예: 20" value="0" aria-label="퀜칭 경도 하한">
                  <span class="tilde">~</span>
                  <input type="number" id="quench_high" name="quench_high" class="form-input" placeholder="예: 30" value="0" aria-label="퀜칭 경도 상한">
                </div>
              </div>
              <div class="form-group">
                <label class="form-label" for="temper_low">심부 경도 <span class="auto">하한 ~ 상한</span></label>
                <div class="range-row">
                  <input type="number" id="temper_low" name="temper_low" class="form-input" placeholder="예: 15" value="0" aria-label="심부 경도 하한">
                  <span class="tilde">~</span>
                  <input type="number" id="temper_high" name="temper_high" class="form-input" placeholder="예: 25" value="0" aria-label="심부 경도 상한">
                </div>
              </div>
            </div>
          </div>

          <!-- 이미지 -->
          <div class="form-section">
            <div class="form-section-title">이미지 <span class="hint">칸을 눌러 파일 선택 · 두 번 눌러 크게 보기</span></div>
            <div class="img-grid">
              <div class="img-slot">
                <div class="img-slot-label">제품 사진 1</div>
                <div class="img-preview-box" onclick="document.getElementById('prod_img1').click()">
                  <img id="preview1" src="" style="display:none;" alt="">
                  <span class="img-empty" id="empty1"><svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>선택</span>
                </div>
                <input type="file" id="prod_img1" name="prod_img1" accept="image/*">
                <input type="hidden" id="prod_img1_name" name="prod_img1_name">
                <div class="img-slot-name" id="name1">미선택</div>
              </div>
              <div class="img-slot">
                <div class="img-slot-label">제품 사진 2</div>
                <div class="img-preview-box" onclick="document.getElementById('prod_img2').click()">
                  <img id="preview2" src="" style="display:none;" alt="">
                  <span class="img-empty" id="empty2"><svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>선택</span>
                </div>
                <input type="file" id="prod_img2" name="prod_img2" accept="image/*">
                <input type="hidden" id="prod_img2_name" name="prod_img2_name">
                <div class="img-slot-name" id="name2">미선택</div>
              </div>
              <div class="img-slot">
                <div class="img-slot-label">경도 사진 3</div>
                <div class="img-preview-box" onclick="document.getElementById('prod_img3').click()">
                  <img id="preview3" src="" style="display:none;" alt="">
                  <span class="img-empty" id="empty3"><svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>선택</span>
                </div>
                <input type="file" id="prod_img3" name="prod_img3" accept="image/*">
                <input type="hidden" id="prod_img3_name" name="prod_img3_name">
                <div class="img-slot-name" id="name3">미선택</div>
              </div>
              <div class="img-slot">
                <div class="img-slot-label">경도 사진 4</div>
                <div class="img-preview-box" onclick="document.getElementById('prod_img4').click()">
                  <img id="preview4" src="" style="display:none;" alt="">
                  <span class="img-empty" id="empty4"><svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>선택</span>
                </div>
                <input type="file" id="prod_img4" name="prod_img4" accept="image/*">
                <input type="hidden" id="prod_img4_name" name="prod_img4_name">
                <div class="img-slot-name" id="name4">미선택</div>
              </div>
              <div class="img-slot">
                <div class="img-slot-label">경도 사진 5</div>
                <div class="img-preview-box" onclick="document.getElementById('prod_img5').click()">
                  <img id="preview5" src="" style="display:none;" alt="">
                  <span class="img-empty" id="empty5"><svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>선택</span>
                </div>
                <input type="file" id="prod_img5" name="prod_img5" accept="image/*">
                <input type="hidden" id="prod_img5_name" name="prod_img5_name">
                <div class="img-slot-name" id="name5">미선택</div>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-btn-row">
          <button type="button" id="closeModal" class="ops-btn">닫기</button>
          <button type="submit" id="saveCorrStatus" class="ops-btn primary">저장</button>
        </div>
      </form>
    </div>
  </div>

  <!-- 이미지 미리보기 모달 -->
  <div id="imagePreviewModal" class="img-preview-modal">
    <button class="img-preview-close" id="closePreview" aria-label="닫기">&times;</button>
    <img id="previewImg" src="" alt="미리보기">
  </div>

  <!-- 엑셀 로딩 -->
  <div id="excelOverlay"></div>
  <div id="excelLoading">엑셀 생성 중...</div>

  <!-- ===================== SCRIPT ===================== -->
  <script>
  let now_page_code = "a03";
  let dataTable;
  let selectedRow = null;

  // =========================
  // Helpers
  // =========================
  function isBlank(v){
    return v === null || v === undefined || String(v).trim() === "";
  }

  function toNumOrZero(v){
    if (v === null || v === undefined) return "0";
    const s = String(v).trim();
    if (s === "") return "0";
    const n = Number(s);
    return Number.isFinite(n) ? String(n) : "0";
  }

  function fixNumberEmptyToZero($form){
    const fields = ["unit_price", "weight"];
    fields.forEach(name => {
      const $el = $form.find(`[name="${name}"]`);
      if ($el.length) $el.val(toNumOrZero($el.val()));
    });
  }

  // DB에 파일명만 저장된 경우 이미지 조회 URL로 변환
  function buildImgSrc(v){
    if (isBlank(v)) return "";
    const s = String(v).trim();

    if (s.startsWith("http://") || s.startsWith("https://")) return s;
    if (s.startsWith("/line/standard/product/image?filename=")) return s;

    // /uploads/xxx 같은 절대경로면 그대로
    if (s.startsWith("/")) return s;

    return "/line/standard/product/image?filename=" + encodeURIComponent(s);
  }

  function fileNameFromValue(v){
    if (isBlank(v)) return "";
    const s = String(v);
    return s.split("/").pop().split("\\").pop();
  }

  // =========================
  // Image preview UI
  // =========================
  function setSlotUI(n, src, displayName){
    const preview = document.getElementById("preview" + n);
    const empty   = document.getElementById("empty" + n);
    const nameEl  = document.getElementById("name" + n);

    if (preview && empty){
      if (src){
        preview.src = src;
        preview.style.display = "block";
        empty.style.display = "none";
      } else {
        preview.src = "";
        preview.style.display = "none";
        empty.style.display = "";
      }
    }

    if (nameEl){
      if (isBlank(displayName)){
        nameEl.textContent = "미선택";
      } else {
        nameEl.textContent = displayName.length > 14 ? displayName.substring(0, 14) + "..." : displayName;
      }
    }
  }

  function clearSlot(n){
    const fileInput = document.getElementById("prod_img" + n);
    const hiddenOld = document.getElementById("prod_img" + n + "_name");

    if (fileInput){
      fileInput.value = "";
      fileInput.dataset.old = "";
      fileInput.dataset.changed = "N";
    }
    if (hiddenOld) hiddenOld.value = "";

    setSlotUI(n, "", "");
  }

  function applyOldToSlot(n, oldValue){
    const fileInput = document.getElementById("prod_img" + n);
    const hiddenOld = document.getElementById("prod_img" + n + "_name");

    const old = oldValue || "";

    if (fileInput){
      fileInput.value = "";
      fileInput.dataset.old = old;
      fileInput.dataset.changed = "N";
    }
    if (hiddenOld) hiddenOld.value = old;

    const src = buildImgSrc(old);
    const nm  = fileNameFromValue(old);

    setSlotUI(n, src, nm);
  }

  function bindFileChange(n){
    const fileInput = document.getElementById("prod_img" + n);
    if (!fileInput) return;

    fileInput.addEventListener("change", function(){
      const file = this.files && this.files[0];
      const hiddenOld = document.getElementById("prod_img" + n + "_name");

      if (file && file.size > 0 && file.name){
        this.dataset.changed = "Y";

        // 기존값(hidden)은 유지해야 서버에서 파일 없을 때 fallback 가능
        if (hiddenOld && isBlank(hiddenOld.value) && !isBlank(this.dataset.old)){
          hiddenOld.value = this.dataset.old;
        }

        const reader = new FileReader();
        reader.onload = function(e){
          setSlotUI(n, e.target.result, file.name);
        };
        reader.readAsDataURL(file);
      } else {
        this.dataset.changed = "N";
        const old = this.dataset.old || (hiddenOld ? hiddenOld.value : "");
        applyOldToSlot(n, old);
      }
    });
  }

  // =========================
  // Preview modal
  // =========================
  function previewImage(url){
    if (isBlank(url)) return;
    document.getElementById("previewImg").src = url;
    document.getElementById("imagePreviewModal").classList.add("show");
  }

  document.getElementById("closePreview").addEventListener("click", function(){
    document.getElementById("imagePreviewModal").classList.remove("show");
  });

  document.getElementById("imagePreviewModal").addEventListener("click", function(e){
    if (e.target === this) this.classList.remove("show");
  });

  function bindSlotClick(n){
    const box = document.querySelectorAll(".img-preview-box")[n - 1];
    if (!box) return;

    box.addEventListener("dblclick", function(){
      const img = document.getElementById("preview" + n);
      if (img && img.src) previewImage(img.src);
    });
  }

  // =========================
  // Multipart sanitize
  // =========================
  function sanitizeMultipart(fd){
    [1,2,3,4,5].forEach(n => {
      const key = "prod_img" + n;
      const f = fd.get(key);

      if (f instanceof File){
        if (!f.name || f.size === 0){
          fd.delete(key);
        }
      } else if (f == null){
        // nothing
      } else {
        fd.delete(key);
      }
    });
  }

  // FormData 만들기 전에 hidden old값 보정
  function syncOldImageHiddenValuesBeforeSubmit(){
    [1,2,3,4,5].forEach(n => {
      const fileInput = document.getElementById("prod_img" + n);
      const hiddenOld = document.getElementById("prod_img" + n + "_name");

      if (!fileInput || !hiddenOld) return;

      // 파일 선택 안 했으면 기존값 유지
      if (!(fileInput.files && fileInput.files[0] && fileInput.files[0].size > 0)){
        if (isBlank(hiddenOld.value) && !isBlank(fileInput.dataset.old)){
          hiddenOld.value = fileInput.dataset.old;
        }
      }
    });
  }

  // =========================
  // Modal
  // =========================
  function openModal(){
    $("#modalContainer").addClass("show");
  }

  function closeModal(){
    $("#modalContainer").removeClass("show");
  }

  function setModalMode(mode, name){
    if (mode === "edit"){
      $("#modalTitleText").text("제품 수정");
      $("#modalSubtitle").text((name || "") + " 정보를 수정합니다");
    } else {
      $("#modalTitleText").text("제품 등록");
      $("#modalSubtitle").text("신규 제품을 등록합니다");
    }
  }

  function resetModalForInsert(){
    const $f = $("#corrForm");
    $f[0].reset();
    $f.find('[name="prod_id"]').val("");
    $f.find('[name="prod_code"]').val("");
    $f.find('[name="cust_code"]').val("");

    [1,2,3,4,5].forEach(clearSlot);
  }

  function fillModalForEdit(d){
    const $f = $("#corrForm");
    $f[0].reset();

    $f.find('[name="prod_id"]').val(d.prod_id || "");
    $f.find('[name="prod_code"]').val(d.prod_code || "");
    $f.find('[name="item_no"]').val(d.item_no || "");
    $f.find('[name="item_name"]').val(d.item_name || "");
    $f.find('[name="spec"]').val(d.spec || "");
    $f.find('[name="texture"]').val(d.texture || "");
    $f.find('[name="material"]').val(d.material || "0");
    $f.find('[name="unit_price"]').val(toNumOrZero(d.unit_price));
    $f.find('[name="weight"]').val(toNumOrZero(d.weight));
    $f.find('[name="quench_low"]').val(d.quench_low || "0");
    $f.find('[name="quench_high"]').val(d.quench_high || "0");
    $f.find('[name="temper_low"]').val(d.temper_low || "0");
    $f.find('[name="temper_high"]').val(d.temper_high || "0");
    $f.find('[name="cust_code"]').val(d.cust_code || "");

    // ✅ 여기서 미리보기까지 반드시 세팅
    [1,2,3,4,5].forEach(function(n){
      applyOldToSlot(n, d["img_url_" + n] || "");
    });
  }

  // =========================
  // Tabulator
  // =========================
  function imgFormatter(cell){
    const v = cell.getValue();
    if (isBlank(v)) return '<div class="img-placeholder" title="사진 없음"></div>';

    const src = buildImgSrc(v);
    return '<img class="img-thumb" src="' + src + '" onclick="previewImage(\'' + src.replace(/'/g, "\\'") + '\')">';
  }

  // 표시 전용: 숫자 열은 0/빈값을 흐리게
  function numFormatter(cell){
    const v = cell.getValue();
    const el = cell.getElement();
    const z = isBlank(v) || Number(v) === 0;
    el.classList.toggle("zero", z);
    return isBlank(v) ? "-" : v;
  }

  function initDataTable(){
    dataTable = new Tabulator("#dataList", {
      height: "100%",
      layout: "fitColumns",
      selectable: 1,
      placeholder: "조회된 데이터가 없습니다.",
      headerFilterPlaceholder: "",
      headerHozAlign: "center",
      columns: [
        { title:"NO", formatter:"rownum", width:48, hozAlign:"right", cssClass:"c-code", headerSort:false },
        { title:"제품ID", field:"prod_id", width:72, hozAlign:"right", cssClass:"c-code", headerFilter:"input" },
        { title:"제품코드", field:"prod_code", width:92, hozAlign:"left", cssClass:"c-code", headerFilter:"input" },
        { title:"거래처코드", field:"cust_code", width:92, hozAlign:"left", cssClass:"c-code", headerFilter:"input" },
        { title:"거래처명", field:"cust_name", width:108, hozAlign:"left", headerFilter:"input" },
        { title:"품번", field:"item_no", width:136, hozAlign:"left", cssClass:"c-key", headerFilter:"input" },
        { title:"품명", field:"item_name", minWidth:150, widthGrow:2, hozAlign:"left", headerFilter:"input" },

        { title:"제품 사진", columns:[
          { title:"1", field:"img_url_1", width:48, hozAlign:"center", cssClass:"c-img", headerSort:false, formatter:imgFormatter },
          { title:"2", field:"img_url_2", width:48, hozAlign:"center", cssClass:"c-img", headerSort:false, formatter:imgFormatter }
        ]},

        { title:"규격", field:"spec", width:104, hozAlign:"left", cssClass:"c-code", headerFilter:"input" },
        { title:"재질", field:"texture", width:88, hozAlign:"left", cssClass:"c-code", headerFilter:"input" },
        { title:"장입량(kg)", field:"material", width:96, hozAlign:"right", cssClass:"c-num", headerFilter:"input", formatter:numFormatter },

        {
          title:"단가",
          field:"unit_price",
          width:92,
          hozAlign:"right",
          cssClass:"c-num",
          headerFilter:"input",
          formatter:"money",
          formatterParams:{ symbol:"원", symbolAfter:true, precision:0, thousand:"," }
        },

        { title:"중량(g)", field:"weight", width:84, hozAlign:"right", cssClass:"c-num", headerFilter:"input", formatter:numFormatter },
        { title:"퀜칭 경도", columns:[
          { title:"하한", field:"quench_low", width:64, hozAlign:"right", cssClass:"c-num", headerFilter:"input", formatter:numFormatter },
          { title:"상한", field:"quench_high", width:64, hozAlign:"right", cssClass:"c-num", headerFilter:"input", formatter:numFormatter }
        ]},
        { title:"심부 경도", columns:[
          { title:"하한", field:"temper_low", width:64, hozAlign:"right", cssClass:"c-num", headerFilter:"input", formatter:numFormatter },
          { title:"상한", field:"temper_high", width:64, hozAlign:"right", cssClass:"c-num", headerFilter:"input", formatter:numFormatter }
        ]},
        { title:"등록일", field:"reg_date", width:156, hozAlign:"left", cssClass:"c-code", headerFilter:"input" },

        { title:"경도 사진", columns:[
          { title:"3", field:"img_url_3", width:48, hozAlign:"center", cssClass:"c-img", headerSort:false, formatter:imgFormatter },
          { title:"4", field:"img_url_4", width:48, hozAlign:"center", cssClass:"c-img", headerSort:false, formatter:imgFormatter },
          { title:"5", field:"img_url_5", width:48, hozAlign:"center", cssClass:"c-img", headerSort:false, formatter:imgFormatter }
        ]}
      ],
      rowClick: function(e, row){
        $("#dataList .tabulator-row").removeClass("row_select");
        row.getElement().classList.add("row_select");
        selectedRow = row;
      },
      rowDblClick: function(e, row){
        const d = row.getData();
        selectedRow = row;

        setModalMode("edit", d.item_name);
        fillModalForEdit(d);
        loadCustomerList(d.cust_code, function(){
          openModal();
        });
      }
    });
  }

  // =========================
  // Ajax
  // =========================
  function loadData(){
    $.ajax({
      url: "/line/standard/product/list",
      type: "POST",
      dataType: "json",
      data: {
        item_no: $("#search_item_no").val(),
        item_name: $("#search_item_name").val(),
        cust_name: $("#search_cust_name").val()
      },
      success: function(res){
        if (res.status === "success"){
          const pure = JSON.parse(JSON.stringify(res.data));
          dataTable.replaceData(pure);
          $("#footer-info").text((pure.length || 0) + " rows");
          updateSummary(pure);
        }
      },
      error: function(){
        alert("데이터 조회 실패");
      }
    });
  }

  // 상단 요약 띠 (조회 결과 기준, 표시 전용)
  function updateSummary(rows){
    rows = rows || [];
    const zero = v => isBlank(v) || Number(v) === 0;
    const custs = new Set(rows.map(r => r.cust_code || r.cust_name).filter(v => !isBlank(v)));
    const noHrc = rows.filter(r => zero(r.quench_low) && zero(r.quench_high) && zero(r.temper_low) && zero(r.temper_high)).length;
    const noImg = rows.filter(r => isBlank(r.img_url_1) && isBlank(r.img_url_2)).length;
    const last = rows.map(r => String(r.reg_date || "")).filter(Boolean).sort().pop() || "";

    $("#kpi-prod").text(rows.length);
    $("#kpi-cust").text(custs.size);
    $("#kpi-nohrc").text(noHrc).toggleClass("bad", noHrc > 0);
    $("#kpi-noimg").text(noImg);
    $("#kpi-last").text(last ? last.substring(0, 10) : "-");
    $("#kpi-last-sub").html(last.length > 10 ? last.substring(11, 16) : "&nbsp;");
  }

  function loadCustomerList(selectedCode, callback){
    $.ajax({
      url: "/line/standard/customer/list",
      type: "POST",
      dataType: "json",
      success: function(resp){
        if (resp.status === "success"){
          const sel = $("#cust_name");
          sel.empty().append('<option value="">선택하세요</option>');

          resp.data.forEach(function(c){
            const code = c.cust_code || "";
            const name = c.cust_name || "";
            const opt = $("<option></option>").val(code).text(name);
            if (code === (selectedCode || "")) opt.prop("selected", true);
            sel.append(opt);
          });

          if (selectedCode) $("#cust_code").val(selectedCode);
          if (typeof callback === "function") callback();
        } else {
          alert("거래처 조회 실패: " + (resp.message || ""));
        }
      },
      error: function(){
        alert("거래처 조회 실패");
      }
    });
  }

  // =========================
  // Excel
  // =========================
  function downloadExcel(){
    const tableData = dataTable.getData();
    if (!tableData || !tableData.length){
      alert("다운로드할 데이터가 없습니다.");
      return;
    }

    $("#excelOverlay").show();
    $("#excelLoading").show();

    try{
      const excelData = tableData.map(function(row, idx){
        return {
          "NO": idx + 1,
          "제품코드": row.prod_code || "",
          "거래처코드": row.cust_code || "",
          "거래처명": row.cust_name || "",
          "품번": row.item_no || "",
          "품명": row.item_name || "",
          "제품이미지1": row.img_url_1 || "",
          "제품이미지2": row.img_url_2 || "",
          "규격": row.spec || "",
          "재질": row.texture || "",
          "장입량(kg)": row.material || "",
          "단가": row.unit_price || "",
          "중량(g)": row.weight || "",
          "퀜칭경도_하한": row.quench_low || "",
          "퀜칭경도_상한": row.quench_high || "",
          "심부경도_하한": row.temper_low || "",
          "심부경도_상한": row.temper_high || "",
          "등록일": row.reg_date || ""
        };
      });

      const ws = XLSX.utils.json_to_sheet(excelData);
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "제품목록");

      const now = new Date();
      const ds = now.getFullYear() +
        String(now.getMonth() + 1).padStart(2, "0") +
        String(now.getDate()).padStart(2, "0");
      const ts = String(now.getHours()).padStart(2, "0") +
        String(now.getMinutes()).padStart(2, "0");

      XLSX.writeFile(wb, "제품리스트_" + ds + "_" + ts + ".xlsx");

      setTimeout(function(){
        $("#excelOverlay").hide();
        $("#excelLoading").hide();
      }, 400);
    } catch(e){
      console.error(e);
      alert("엑셀 다운로드에 실패했습니다.");
      $("#excelOverlay").hide();
      $("#excelLoading").hide();
    }
  }

  // =========================
  // Ready
  // =========================
  $(document).ready(function(){
    [1,2,3,4,5].forEach(bindFileChange);
    [1,2,3,4,5].forEach(bindSlotClick);

    initDataTable();
    loadData();
    loadCustomerList();
    $(window).on("resize", function(){ if (dataTable) dataTable.redraw(); });

    $(".select-button").on("click", loadData);
    $(".excel-button").on("click", downloadExcel);

    $(".insert-button").on("click", function(){
      selectedRow = null;
      setModalMode("insert");
      resetModalForInsert();
      loadCustomerList();
      openModal();
    });

    $(".delete-button").on("click", function(){
      if (!selectedRow){
        alert("삭제할 행을 먼저 클릭해 주세요.");
        return;
      }

      const prodId = selectedRow.getData().prod_id;
      if (!prodId){
        alert("삭제할 제품이 없습니다.");
        return;
      }

      if (!confirm("선택된 제품을 정말 삭제하시겠습니까?")) return;

      $.ajax({
        url: "/line/standard/product/delete",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify({ prod_id: prodId }),
        dataType: "json",
        success: function(){
          alert("제품 정보가 삭제되었습니다!");
          selectedRow = null;
          loadData();
        },
        error: function(){
          alert("삭제 실패");
        }
      });
    });

    $(".close, #closeModal").on("click", closeModal);

    document.addEventListener("keydown", function(e){
      if (e.key === "Escape") closeModal();
    });

    $("#cust_name").on("change", function(){
      $("#cust_code").val($(this).val());
    });

    $("#saveCorrStatus").off("click").on("click", function(e){
    	  e.preventDefault();

    	  const $form = $("#corrForm");
    	  fixNumberEmptyToZero($form);
    	  syncOldImageHiddenValuesBeforeSubmit();

    	  const prodId = $form.find('[name="prod_id"]').val();
    	  const url = prodId ? "/line/standard/product/update" : "/line/standard/product/save";

    	  const fd = new FormData($form[0]);

    	  if (!prodId) {
    	    fd.delete("prod_id");
    	  }

    	  sanitizeMultipart(fd);

    	  $.ajax({
    	    url: url,
    	    type: "POST",
    	    data: fd,
    	    processData: false,
    	    contentType: false,
    	    dataType: "json",
    	    success: function(res){
    	      alert("제품 정보가 성공적으로 저장되었습니다!");
    	      closeModal();
    	      loadData();
    	    },
    	    error: function(xhr){
    	      console.log("status", xhr.status);
    	      console.log("responseText", xhr.responseText);
    	      alert("저장 실패");
    	    }
    	  });
    	});
  });
</script>
</body>
</html>
