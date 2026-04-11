---
name: ob-adr-supersede
description: Obsidian-Hub의 기존 accepted ADR을 새로운 결정으로 대체할 때 반드시 사용. accepted ADR은 수정 금지이므로 새 ADR을 생성하고 양방향 supersedes/superseded-by 링크를 거는 작업. 사용자가 "이전 ADR 갈아엎자", "supersede", "이 결정 폐기", "ADR 대체" 등을 말할 때 트리거. 대상 ADR의 status를 superseded로 변경, 새 ADR에 supersedes 추가, 양방향 링크 정합성 검증.
---

# ob-adr-supersede

## When to Use
기존 결정을 뒤집거나 더 나은 결정으로 대체할 때. 단순 보완은 새 ADR + Related만으로 충분, **명시적 폐기**일 때만 supersede.

## Algorithm

```mermaid
flowchart TD
    A[supersede 트리거] --> B[대상 ADR 확인<br/>ID 명시 or grep]
    B --> C[대상 ADR Read]
    C --> D{status<br/>accepted?}
    D -->|아니오| E[경고: superseded나<br/>proposed는 supersede 불가]
    D -->|예| F[ob-adr-create로<br/>새 ADR 생성<br/>supersedes에 대상 ID]
    F --> G[대상 ADR frontmatter Edit<br/>status: superseded<br/>superseded-by: [새 ID]]
    G --> H[양방향 링크 검증]
    H --> I[INDEX.md에<br/>대상 ADR을 Superseded 섹션으로 이동]
    I --> J[사용자 보고]
```

## Steps

1. **대상 ADR 확인**:
   - 사용자가 ID 명시: `300-resources/decisions/**/ADR-NNNN-*.md` Glob
   - 키워드만: `grep -l -r "{keyword}" 300-resources/decisions/`

2. **대상 ADR Read**:
   - status가 `accepted`인지 확인 (다른 status면 superseed 불필요/불가)

3. **새 ADR 작성**: `ob-adr-create` 호출
   - 새 ADR의 frontmatter `supersedes: [ADR-{대상 ID}]` 명시
   - 본문 `## Context`에 "기존 ADR-NNNN을 왜 폐기하는지" 명시

4. **대상 ADR Edit** (frontmatter만 수정):
   ```yaml
   status: superseded
   superseded-by: [ADR-{새 ID}]
   ```
   본문은 절대 수정 금지 (immutability 유지).

5. **양방향 검증**:
   ```bash
   grep "superseded-by" 300-resources/decisions/**/ADR-{대상}*.md
   grep "supersedes" 300-resources/decisions/**/ADR-{새}*.md
   ```
   양쪽에 ID가 있어야 함.

6. **INDEX.md 갱신**:
   - 대상 ADR을 "Manual Index"의 원래 위치에서 제거 또는 strikethrough
   - Dataview 쿼리는 자동으로 Superseded 섹션으로 분류됨

7. **사용자 보고**: `"ADR-{대상} → ADR-{새}로 supersede 완료"`

## Common Mistakes
- ❌ 대상 ADR 본문 수정 (immutable 위반 — 오직 frontmatter status만)
- ❌ 양방향 링크 빠뜨림 (supersedes만 적고 superseded-by 누락)
- ❌ proposed/superseded ADR을 supersede 시도
- ❌ 단순 보완(추가 정보)인데 supersede 사용 (이 경우 새 ADR + Related로 충분)
- ❌ INDEX.md 정리 안 함

## Files / Tools
- **Tools**: Glob, Grep, Read, Edit
- **호출 skill**: `ob-adr-create` (새 ADR 생성)
- **수정 대상**:
  - 새 ADR: 신규 작성
  - 대상 ADR: frontmatter만 Edit
  - INDEX.md: Manual Index 정리

## Related
- [[ob-adr-create]] — 새 ADR 생성 (선행)
- ADR-0005 — sitemap+tag+MADR 결정
- [[12_adr-decision-records]] — Immutability 규칙 배경
