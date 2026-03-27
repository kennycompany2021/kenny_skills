---
name: report
description: HTML로 보고서형 문서(A4 문서)를 생성할 때 반드시 사용. 보고서, 제안서, 기획서, 분석서, 결과보고서 등 문서(docs/docx) 형태로 만들어달라는 요청에 항상 적용. 페이지 나눔이 있는 긴 문서, 목차가 있는 공식 문서 키워드에도 트리거.
---

# 보고서형 문서 HTML 생성 스킬

## 목적

이 스킬의 핵심 목표는 **단 하나**다:

> 브라우저에서 보이는 화면과 인쇄(PDF 저장)했을 때 화면이 **완전히 동일**하게 보이고, 표·제목·단락이 페이지 경계에서 어색하게 잘리지 않는 안정적인 보고서를 만드는 것.

디자인(색상, 폰트, 스타일)은 사용자의 요청에 따라 결정한다. 이 스킬은 구조적 안정성만 책임진다.

## Step 1: 요구사항 확인

사용자 요청에 명시되지 않은 항목은 반드시 먼저 질문한다.

```
확인이 필요한 항목:
- 용지 방향: A4 세로 (기본) / A4 가로?
- 목차 필요 여부: 자동 생성? / 직접 구성?
- 내용: 직접 제공 (md 파일, 텍스트) / 주제만 알려주면 내가 구성?
- 디자인 방향: 색상, 분위기, 참고 스타일이 있으면 알려주세요
```

## Step 2: 콘텐츠 확정 (HTML 작성 전)

HTML을 바로 생성하지 말고, **먼저 목차/구조를 확정**한다.

```markdown
# 문서 구조안

## 1장: 요약 (Executive Summary)
- 핵심 내용 1~2줄

## 2장: 배경 및 목적

## 3장: 본문 내용

## 4장: 결론 및 제언

## 부록 (필요 시)
```

사용자가 구조안을 확인하고 승인한 뒤 HTML을 생성한다.
단, 사용자가 "바로 만들어줘"고 명시하거나 내용이 이미 완전히 제공된 경우는 생략 가능.

## Step 3: HTML 생성 — 레이아웃 안정성 규칙

아래 규칙은 **반드시** 지켜야 한다.

### 3-1. @page 설정 — 인쇄 여백 정의

```css
@page {
  size: A4;           /* A4 세로 기본. 가로면: size: A4 landscape */
  margin: 20mm 20mm 25mm 20mm; /* 상 우 하 좌 */
}
```

페이지 번호를 바닥글에 넣으려면:
```css
@page {
  size: A4;
  margin: 20mm 20mm 30mm 20mm;

  @bottom-center {
    content: counter(page) " / " counter(pages);
    font-size: 10px;
    color: #666;
  }
}
```

> `@bottom-center` 등 named page margin boxes는 Chrome/Edge 인쇄에서 지원된다.

### 3-2. 페이지 시뮬레이션 (화면에서 A4처럼 보이기)

화면에서도 실제 A4 용지처럼 보이게 한다. 이렇게 하면 "내가 보는 화면 = 인쇄 결과"가 직관적으로 맞는다.

```css
body {
  background: #e5e7eb;
  margin: 0;
  padding: 32px 0;
  font-family: /* 사용자 지정 */;
}

.page {
  width: 210mm;
  min-height: 297mm;
  margin: 0 auto 24px;
  padding: 20mm;
  background: white;
  box-shadow: 0 4px 24px rgba(0,0,0,0.12);
  box-sizing: border-box;
}
```

```css
@media print {
  body {
    background: none;
    padding: 0;
    margin: 0;
  }

  .page {
    width: 100%;
    min-height: unset;
    margin: 0;
    padding: 0;          /* @page margin이 여백을 담당 */
    box-shadow: none;
    page-break-after: always;
    break-after: page;
  }

  /* 마지막 페이지는 page-break 없음 */
  .page:last-child {
    page-break-after: avoid;
    break-after: avoid;
  }
}
```

### 3-3. 페이지 경계에서 잘림 방지

가장 흔한 인쇄 불안정 원인: 표, 제목, 이미지가 페이지 경계에서 반쪽 잘림.

```css
/* 표: 페이지 경계에서 잘리지 않도록 */
table {
  page-break-inside: avoid;
  break-inside: avoid;
  width: 100%;
  border-collapse: collapse;
}

/* 표 헤더: 여러 페이지에 걸쳐도 헤더가 반복됨 */
thead {
  display: table-header-group;
}

/* 제목 뒤에서 페이지 나눔 방지 (제목만 남고 본문이 다음 페이지로 넘어가는 현상) */
h1, h2, h3 {
  page-break-after: avoid;
  break-after: avoid;
}

/* 제목 앞에서 페이지 나눔 (새 섹션은 새 페이지에서 시작할 때) */
/* h1 { page-break-before: always; break-before: page; } */
/* → 필요한 경우에만 선택적으로 적용 */

/* 그림/이미지 블록 */
figure, .figure-block {
  page-break-inside: avoid;
  break-inside: avoid;
}

/* 코드 블록 */
pre, code {
  page-break-inside: avoid;
  break-inside: avoid;
}

/* 고아/과부 줄 방지: 단락의 첫 줄/마지막 줄이 홀로 남는 현상 */
p {
  orphans: 3;
  widows: 3;
}
```

### 3-4. 단일 파일 구조 vs 다중 .page 구조

**방식 A — 자연 흐름 방식 (권장, 단순한 문서)**

```html
<body>
  <div class="document">
    <!-- 내용을 그냥 작성, 페이지 나눔은 CSS가 자동 처리 -->
    <h1>제목</h1>
    <p>본문...</p>
    <table>...</table>
  </div>
</body>
```

인쇄 시 브라우저가 자동으로 페이지를 나눈다. `page-break-inside: avoid` 규칙으로 잘림을 방지한다.

**방식 B — 명시적 페이지 구조 (권장, 페이지 레이아웃이 중요한 문서)**

```html
<body>
  <div class="page">  <!-- 1페이지 -->
    <h1>표지</h1>
  </div>
  <div class="page">  <!-- 2페이지: 목차 -->
    <h2>목차</h2>
  </div>
  <div class="page">  <!-- 3페이지~: 본문 -->
    <h2>1장. 개요</h2>
    <p>...</p>
  </div>
</body>
```

표지·목차처럼 **정확히 한 페이지를 차지해야 하는** 섹션이 있을 때 방식 B를 사용한다.
본문이 길어서 자연스럽게 여러 페이지에 걸쳐야 하는 섹션은 방식 A처럼 처리한다.

혼합 사용도 가능하다.

### 3-5. 화면에서 페이지 번호 표시 (선택)

`@page` CSS로 인쇄 시 자동 페이지 번호가 생기지만, 화면에서도 보이게 하려면:

```html
<div class="page">
  <!-- 내용 -->
  <div class="page-number screen-only">1</div>
</div>
```

```css
.page-number.screen-only {
  position: absolute;
  bottom: 8mm;
  right: 10mm;
  font-size: 10px;
  color: #999;
}

@media print {
  .screen-only { display: none; }
}
```

## Step 4: 표 안정성 체크리스트

표는 보고서에서 가장 잘림이 많은 요소다.

- [ ] `border-collapse: collapse` 적용됨
- [ ] `thead { display: table-header-group }` 적용됨 (여러 페이지 걸칠 때 헤더 반복)
- [ ] `page-break-inside: avoid` 적용됨 (짧은 표)
- [ ] 매우 긴 표는 방식 A(자연 흐름)로 두고 `thead` 반복에 의존

## Step 5: 출력물 확인 안내

HTML 생성 후 사용자에게 안내:

```
✓ 브라우저에서 열어서 문서가 잘 보이는지 확인하세요.
✓ PDF 저장: Ctrl+P → "PDF로 저장" → 여백 설정 "없음(None)" → 저장
  (여백은 CSS @page에서 이미 설정되어 있으므로 브라우저 여백은 없음으로 해야 합니다)
✓ 표나 그림이 페이지 경계에서 잘리면 알려주세요 — 해당 블록에 break-inside: avoid를 추가하면 됩니다.
```
