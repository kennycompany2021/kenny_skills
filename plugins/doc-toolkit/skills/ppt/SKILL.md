---
name: ppt
description: HTML로 PPT형 발표자료(슬라이드)를 생성할 때 반드시 사용. 슬라이드 형태의 발표자료, 프레젠테이션, 제안서 슬라이드, 교육자료 슬라이드를 만들어달라는 요청에 항상 적용. pptx/pdf/슬라이드/발표자료 키워드가 있을 때도 트리거.
---

# PPT형 발표자료 HTML 생성 스킬

## 목적

이 스킬의 핵심 목표는 **단 하나**다:

> 브라우저에서 보이는 화면과 인쇄(PDF 저장)했을 때 화면이 **완전히 동일**하게 보이고, 슬라이드 경계에서 내용이 잘리거나 넘치지 않는 안정적인 발표자료를 만드는 것.

디자인(색상, 폰트, 레이아웃 스타일)은 사용자의 요청에 따라 결정한다. 이 스킬은 구조적 안정성만 책임진다.

## Step 1: 요구사항 확인

사용자 요청에 명시되지 않은 항목은 반드시 먼저 질문한다. 한 번에 모아서 질문할 것.

```
확인이 필요한 항목:
- 슬라이드 비율: 16:9 (기본) / A4 가로 (297×210mm) / 4:3 / 직접 지정?
- 슬라이드 수: 대략 몇 장?
- 내용: 직접 제공 (md 파일, 텍스트) / 주제만 알려주면 내가 구성?
- 디자인 방향: 색상, 분위기, 참고 스타일이 있으면 알려주세요
```

비율이 지정되지 않으면 16:9를 기본으로 사용하되 명시한다.

## Step 2: 콘텐츠 확정 (HTML 작성 전)

HTML을 바로 생성하지 말고, **먼저 마크다운으로 슬라이드 구성을 확정**한다.

```markdown
# 슬라이드 구성안

## 슬라이드 1: 표지
- 제목, 부제목, 발표자/날짜

## 슬라이드 2: 목차
- 항목 목록

## 슬라이드 3: [내용]
- 핵심 메시지
- 세부 내용 (bullet 3~5개)
...
```

사용자가 구성안을 확인하고 승인한 뒤 HTML을 생성한다.
단, 사용자가 "바로 만들어줘"고 명시하거나 내용이 이미 완전히 제공된 경우는 이 단계를 생략해도 된다.

## Step 3: HTML 생성 — 레이아웃 안정성 규칙

아래 규칙은 **반드시** 지켜야 한다. 이 규칙이 화면=인쇄 일치를 보장한다.

### 3-1. 슬라이드 크기: 물리 단위(mm) 사용

픽셀(px) 대신 mm를 사용하면 화면과 인쇄가 동일한 비율을 유지한다.

| 비율 | width | height |
|------|-------|--------|
| 16:9 | 297mm | 167mm |
| A4 가로 | 297mm | 210mm |
| 4:3 | 267mm | 200mm |

```css
:root {
  --slide-w: 297mm;
  --slide-h: 167mm; /* 비율에 맞게 조정 */
}
```

### 3-2. @page 설정 — 인쇄 시 여백 제거

```css
@page {
  size: var(--slide-w) var(--slide-h);
  margin: 0;
}
```

이 설정이 없으면 인쇄 시 브라우저 기본 여백이 생겨서 슬라이드가 잘린다.

### 3-3. 슬라이드 요소 기본 구조

```css
.slide {
  width: var(--slide-w);
  height: var(--slide-h);
  overflow: hidden;          /* 내용이 슬라이드 밖으로 나가지 않음 */
  position: relative;
  box-sizing: border-box;
  page-break-after: always;  /* 구형 브라우저 호환 */
  break-after: page;         /* 표준 */
  flex-shrink: 0;
}
```

**`overflow: hidden` 은 필수다.** 이게 없으면 내용이 넘쳐서 다음 슬라이드를 침범한다.

### 3-4. 슬라이드 컨테이너 (화면 전용)

```css
.slide-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  padding: 32px;
  background: #e5e7eb; /* 슬라이드 사이 여백을 시각적으로 구분 */
}
```

### 3-5. 인쇄 미디어 쿼리 — 핵심

```css
@media print {
  html, body {
    width: var(--slide-w);
    height: var(--slide-h);
    overflow: hidden;
    background: white;
  }

  .slide-container {
    gap: 0;
    padding: 0;
    background: none;
    align-items: flex-start;
  }

  /* 화면 전용 요소 숨기기 */
  .nav-bar,
  .screen-only {
    display: none !important;
  }

  /* 슬라이드 그림자 제거 */
  .slide {
    box-shadow: none;
  }
}
```

### 3-6. 내용 안전성 — 넘침 방지

슬라이드 내부 콘텐츠가 고정 높이를 벗어나지 않도록:

```css
/* 슬라이드 내부 레이아웃은 flex로 관리 */
.slide-inner {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

/* 텍스트 잘림 방지: 폰트 크기를 적절히 설정 */
/* 슬라이드 높이가 167mm일 때 본문 14px 정도가 적당 */

/* 이미지 넘침 방지 */
img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}
```

### 3-7. 네비게이션 바 (선택사항)

화면에서 슬라이드 탐색이 필요하면 추가:

```html
<nav class="nav-bar screen-only">
  <button onclick="prevSlide()">◀</button>
  <span class="nav-indicator" id="nav-text">1 / N</span>
  <button onclick="nextSlide()">▶</button>
</nav>
```

```javascript
// 슬라이드 네비게이션 (화면 전용)
const slides = document.querySelectorAll('.slide');
let current = 0;

function showSlide(n) {
  slides.forEach((s, i) => s.style.display = i === n ? 'block' : 'none');
  document.getElementById('nav-text').textContent = `${n + 1} / ${slides.length}`;
  current = n;
}

function nextSlide() { if (current < slides.length - 1) showSlide(current + 1); }
function prevSlide() { if (current > 0) showSlide(current - 1); }

// 초기화: 인쇄 모드에서는 전체 표시, 화면에서는 첫 슬라이드만
if (!window.matchMedia('print').matches) {
  slides.forEach((s, i) => s.style.display = i === 0 ? 'block' : 'none');
}

window.addEventListener('beforeprint', () => {
  slides.forEach(s => s.style.display = 'block');
});
window.addEventListener('afterprint', () => {
  slides.forEach((s, i) => s.style.display = i === current ? 'block' : 'none');
});
```

> 네비게이션 없이 세로 스크롤로 모든 슬라이드를 보여주는 방식도 가능. 사용자 선호에 따라 결정.

## Step 4: 슬라이드당 콘텐츠 가이드

슬라이드가 꽉 차거나 잘리는 가장 큰 원인은 **너무 많은 내용**이다.

| 슬라이드 높이 | 권장 bullet 수 | 본문 폰트 크기 |
|--------------|---------------|--------------|
| 167mm (16:9) | 최대 6개 | 13~16px |
| 210mm (A4 가로) | 최대 8개 | 14~18px |

내용이 많으면 슬라이드를 분리하거나 폰트를 줄이는 방향을 사용자에게 제안한다.

## Step 5: 출력물 확인 안내

HTML 생성 후 사용자에게 안내:

```
✓ 브라우저에서 열어서 슬라이드가 잘 보이는지 확인하세요.
✓ PDF 저장: Ctrl+P → "PDF로 저장" → 여백 없음(None) 선택 → 저장
  (여백을 "없음"으로 설정해야 슬라이드가 정확히 맞습니다)
```
