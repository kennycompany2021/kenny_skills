---
name: ob-memory-save-feedback
description: Obsidian-Hub의 사용자 교정 피드백을 영구 저장할 때 반드시 사용. 사용자가 Claude의 작업 방식을 교정할 때 자발적으로 제안 — "그거 하지 마", "이거 잘못했네", "앞으로 X 하지 마", "왜 그렇게 했어", "save feedback", "feedback 저장" 등의 발언 직후 트리거. 300-resources/memory/feedback/{slug}.md 파일 생성. Why(이유)와 How to apply(언제 적용)를 명시하여 다중 기기 git 동기화로 다른 세션에서도 자동 반영되게 함.
---

# ob-memory-save-feedback

## When to Use
사용자가 Claude의 작업 결과·방향에 대해 교정·부정·재지시할 때. 예:
- "그거 하지 마"
- "이거 잘못 이해했네"
- "앞으로 X 할 때 Y 하지 마"
- "이런 식으로 처리해"
- "저번에도 같은 실수 했어"

## Algorithm

```mermaid
flowchart TD
    A[사용자 교정 발언 감지] --> B[기존 feedback grep<br/>같은 내용 있나?]
    B -->|있음| C[기존 파일 보강 or skip]
    B -->|없음| D[feedback slug 결정<br/>kebab-case]
    D --> E[300-resources/memory/feedback/<br/>{slug}.md 생성]
    E --> F[frontmatter 작성<br/>name, description, type:<br/>feedback, created]
    F --> G[Why 섹션 작성<br/>왜 이 피드백이 중요한지]
    G --> H[How to apply 섹션<br/>언제 어디에 적용]
    H --> I[적용 범위 명시<br/>특정 프로젝트 or 전역]
    I --> J[사용자에게 저장 알림<br/>'feedback 저장됨']
```

## Steps

1. **교정 의도 확인**: 단순 정정이 아니라 **재발 방지가 필요한 패턴**인지 판단

2. **중복 확인**:
   ```bash
   grep -l -r "{핵심 키워드}" 300-resources/memory/feedback/
   ```
   - 있으면 기존 파일 Read → 보강할지 사용자 확인
   - 없으면 새 파일

3. **slug 결정**: 영문 kebab-case, 3~5단어
   - 예: `no-filter-users`, `prefer-relative-paths`, `commit-message-detail`

4. **파일 생성**: `300-resources/memory/feedback/{slug}.md`

5. **Frontmatter**:
   ```yaml
   ---
   type: memory
   scope: feedback
   name: {한국어 한 줄 제목}
   description: {WHAT을 한 줄로}
   created: {YYYY-MM}
   ---
   ```

6. **본문 구조**:
   ```markdown
   # {제목}

   {무엇을 하면 안 되는지/해야 하는지 1~3 문장}

   **Why**: {왜 이 규칙이 필요한지. 과거 사례, 사용자 의도, 비즈니스 이유}

   **How to apply**: {언제·어디에 적용. 트리거 조건. 예외 케이스}

   **적용 범위**: {특정 프로젝트명 or 전역}
   ```

7. **사용자 보고**: `"feedback/{slug}.md에 저장됨. 다른 기기에서도 git sync로 자동 반영"`

## Common Mistakes
- ❌ 일회성 정정을 모두 feedback으로 (재발 가능성 있는 것만)
- ❌ Why 누락 (이유 없으면 6개월 뒤 무의미)
- ❌ How to apply 누락 (언제 적용할지 모호)
- ❌ slug에 한글·공백
- ❌ 중복 검색 없이 새 파일 생성
- ❌ 시크릿(API 키 등) 포함 (이 폴더는 git 공유)
- ❌ 사용자가 단순히 결과만 정정한 경우인데 feedback으로 저장 (패턴 vs 사건 구분)

## Files / Tools
- **Tools**: Grep, Glob, Write, Read
- **저장 위치**: `300-resources/memory/feedback/{slug}.md`

## Related
- [[ob-memory-add-gotcha]] — 프로젝트 함정 (vs 사용자 피드백)
- [[ob-user-profile-update]] — 사용자 선호 (vs 교정 피드백)
- [[13_memory-architecture]] — 3-Layer Memory 배경
