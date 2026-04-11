---
name: ob-task-complete
description: Obsidian-Hub 태스크 작업 완료 후 코드 commit + 태스크 파일 finalize + daily 완료 append를 처리할 때 반드시 사용. 사용자가 "B-09 수정해줘", "B-09 작업해", "작업 끝", "commit", "task done", "{ID} 완료", "끝났어" 등을 말할 때 트리거. 코드 수정 → [{프로젝트}/{ID}] 포맷 commit → 태스크 frontmatter status: complete → ## 수정 결과·관련 소스 파일 작성 → daily ## ✅ 완료 append. 비자명한 trade-off가 있으면 ob-adr-create 호출 제안.
---

# ob-task-complete

## When to Use
태스크 분석 후 실제 코드 작업 + 완료 처리할 때.

## Algorithm

```mermaid
flowchart TD
    A[작업 트리거<br/>'B-09 수정해줘'] --> B[태스크 Read<br/>해결 방안 확인]
    B --> C{status<br/>in-progress?}
    C -->|아니오| D[ob-task-analyze 먼저]
    C -->|예| E[코드 수정]
    E --> F[git add + commit<br/>'[{proj}/{ID}] 제목']
    F --> G[수정 결과 작성]
    G --> H[관련 소스 파일 기록<br/>file:line]
    H --> I[frontmatter status:<br/>in-progress → complete<br/>updated 갱신]
    I --> J[daily/{오늘}.md<br/>## ✅ 완료 append]
    J --> K{trade-off<br/>or 비자명?}
    K -->|YES| L[ob-adr-create 제안]
    K -->|NO| M[사용자 보고]
    L --> M
```

## Steps

1. **태스크 Read**: `160-tasks/{project}/{ID}-*.md`
   - status가 `in-progress` 아니면 `ob-task-analyze` 먼저 권장

2. **해결 방안 확인** (`## 해결 방안` 섹션)

3. **코드 수정 실행**: Edit/Write로 실제 변경

4. **git commit**:
   ```bash
   cd code/{project} && git add . && git commit -m "[{project}/{ID}] {제목}"
   ```
   포맷: `[{프로젝트 폴더명}/{ID}] 제목`

5. **태스크 파일 갱신**:
   - `## 수정 결과`: 구현 요약 (3줄 이내)
   - `## 관련 소스 파일`: `code/{project}/path/file.java:142` 형식
   - frontmatter `status: complete`, `updated: {오늘}`

6. **daily append**:
   - `daily/{오늘}.md`의 `## ✅ 완료` 섹션
   - 형식: `- [{ID}] {한 줄 요약} → [[{project}/{ID}-{slug}]]`

7. **ADR 승격 판단**:
   - 비자명한 설계 선택? → `ob-adr-create` 호출 제안

8. **사용자 보고**: 수정 파일 목록 + commit hash + 결과 요약

## Common Mistakes
- ❌ commit 메시지에 프로젝트 prefix 누락 (`[B-09]` ← bad, `[34_케이팝머치/B-09]` ← good)
- ❌ frontmatter status 갱신 누락
- ❌ daily append 누락
- ❌ `## 관련 소스 파일`에 line 번호 없이 파일명만
- ❌ 분석 없이 바로 수정 (status가 to-do인데 작업 시작)

## Files / Tools
- **Tools**: Read, Edit, Write, Bash (git)
- **수정 대상**: `160-tasks/{project}/{ID}-*.md`, `daily/{오늘}.md`, `code/{project}/...`

## Related
- [[ob-task-analyze]] — 이전 단계
- [[ob-adr-create]] — trade-off 있을 때
- ADR-0006 — 태스크 시스템 설계
