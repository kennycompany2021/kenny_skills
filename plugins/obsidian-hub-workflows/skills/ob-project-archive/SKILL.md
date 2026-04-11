---
name: ob-project-archive
description: Obsidian-Hub의 종료된 프로젝트를 100-projects/에서 400-archive/로 이동할 때 반드시 사용. 사용자가 "프로젝트 종료", "{프로젝트} archive", "보관 처리", "끝났어 정리해" 등을 말할 때 트리거. 허브 노트 + 관련 160-tasks/{프로젝트}/ + memory + decisions/projects/{프로젝트}/ 모두 400-archive/projects/{프로젝트}/ 하위로 이동. frontmatter status: archived 갱신.
---

# ob-project-archive

## When to Use
프로젝트 완료·종료·중단 시 정리. 일시 중단(paused)은 status만 변경, archive는 진짜 끝.

## Algorithm

```mermaid
flowchart TD
    A[archive 트리거] --> B[프로젝트 확인]
    B --> C[관련 파일/폴더 수집]
    C --> D[허브 노트<br/>100-projects/{folder}.md]
    C --> E[태스크<br/>160-tasks/{folder}/]
    C --> F[메모리<br/>300-resources/memory/projects/{folder}/]
    C --> G[ADR<br/>300-resources/decisions/projects/{folder}/]
    D --> H[400-archive/projects/<br/>{folder}/ mkdir]
    E --> H
    F --> H
    G --> H
    H --> I[git mv 전부 이동]
    I --> J[허브 노트 frontmatter<br/>status: archived<br/>archived_date: 오늘]
    J --> K[300-resources/memory/INDEX.md<br/>해당 프로젝트 항목 제거]
    K --> L[사용자 보고]
```

## Steps

1. **프로젝트 식별** (사용자 명시 또는 100-projects/ 확인)

2. **관련 자산 수집**:
   - `100-projects/{folder}.md` (허브 노트)
   - `160-tasks/{folder}/` (태스크 폴더 전체)
   - `300-resources/memory/projects/{folder}/` (메모리)
   - `300-resources/decisions/projects/{folder}/` (ADR)

3. **목적지 폴더 생성**:
   ```bash
   mkdir -p "400-archive/projects/{folder}"
   ```

4. **git mv로 이동** (히스토리 보존):
   ```bash
   git mv "100-projects/{folder}.md" "400-archive/projects/{folder}/{folder}.md"
   git mv "160-tasks/{folder}" "400-archive/projects/{folder}/tasks"
   git mv "300-resources/memory/projects/{folder}" "400-archive/projects/{folder}/memory"
   git mv "300-resources/decisions/projects/{folder}" "400-archive/projects/{folder}/decisions"
   ```

5. **허브 노트 frontmatter 갱신**:
   ```yaml
   status: archived
   archived_date: {YYYY-MM-DD}
   archived_reason: {사용자 입력}
   ```

6. **Memory INDEX.md 정리**:
   `300-resources/memory/INDEX.md`의 `## 🏗 Projects` 섹션에서 해당 프로젝트 블록 제거

7. **사용자 보고**: 이동된 파일 목록 + git status

## Common Mistakes
- ❌ `mv` 사용 (git mv 써야 히스토리 보존)
- ❌ memory INDEX.md 정리 누락 → 존재하지 않는 파일 @import
- ❌ git commit 안 함 (이동 후 커밋해야 git이 추적)
- ❌ ADR은 immutable이므로 status는 그대로 (archive 폴더로만 이동)
- ❌ 일시 중단(paused)인데 archive 처리 (status만 paused로 바꾸면 됨)
- ❌ archived_reason 누락

## Files / Tools
- **Tools**: Bash (git mv, mkdir), Read, Edit
- **이동 대상**: 4개 폴더 (hub note + tasks + memory + decisions)
- **수정 대상**: `300-resources/memory/INDEX.md`

## Related
- [[ob-project-add]] — 신규 등록 (반대 작업)
- ADR-0006 — 프로젝트별 폴더 구조 결정
