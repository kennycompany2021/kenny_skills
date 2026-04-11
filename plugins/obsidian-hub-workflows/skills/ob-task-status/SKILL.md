---
name: ob-task-status
description: Obsidian-Hub의 태스크 현황을 조회할 때 반드시 사용. 사용자가 "현황 보여줘", "진행 중 뭐 있어", "이 프로젝트 태스크", "task status", "할 일 뭐 있어", "{프로젝트} 진행상황" 등을 말할 때 트리거. 160-tasks/ 전체 또는 특정 프로젝트 폴더를 Glob+grep으로 스캔, frontmatter status별 그룹핑, 사용자에게 마크다운 테이블로 보고.
---

# ob-task-status

## When to Use
사용자가 태스크 현황 조회를 요청. 전사 또는 특정 프로젝트 단위.

## Algorithm

```mermaid
flowchart TD
    A[현황 조회 요청] --> B{프로젝트<br/>지정됐나?}
    B -->|YES| C[160-tasks/{project}/<br/>Glob]
    B -->|NO| D[160-tasks/<br/>전체 Glob]
    C --> E[각 파일 frontmatter Read]
    D --> E
    E --> F[status별 그룹핑<br/>in-progress / to-do / complete]
    F --> G[priority 정렬<br/>urgent > high > normal > low]
    G --> H[마크다운 테이블 생성]
    H --> I[다음 추천 1~2개 제안]
    I --> J[사용자 보고]
```

## Steps

1. **범위 결정**:
   - 사용자가 프로젝트 명시 → `160-tasks/{project}/`
   - 명시 안 함 → `160-tasks/` 전체

2. **태스크 파일 수집**:
   ```bash
   Glob 160-tasks/{범위}/*.md
   ```
   `_dashboard.md`, `_template.md` 제외.

3. **frontmatter 추출** (Read 후 YAML 파싱):
   - id, title, project, type, status, priority, updated

4. **그룹핑 + 정렬**:
   - 1단계: status (in-progress → to-do → complete)
   - 2단계 (in-progress, to-do): priority (urgent → high → normal → low)
   - 2단계 (complete): updated DESC (최근순)

5. **마크다운 테이블 생성**:
   ```markdown
   ## 🔥 진행 중 (N개)
   | ID | 제목 | 우선순위 | 프로젝트 | 갱신 |
   |----|------|----------|---------|------|
   | B-09 | status_cd NULL | urgent | kwm | 04-11 |

   ## 📥 대기 (N개)
   ...

   ## ✅ 최근 완료 (7일, N개)
   ...
   ```

6. **다음 추천**:
   - urgent/high 진행 중 1~2개를 "다음 작업 권장"으로 표시
   - 또는 to-do 중 가장 오래된 high priority

7. **사용자 보고**

## Common Mistakes
- ❌ `_dashboard.md`, `_template.md`, `_system/.gitkeep` 등 제외 안 함
- ❌ 프로젝트 명시 했는데 전체 조회
- ❌ priority 순서 잘못 (urgent가 가장 우선)
- ❌ 완료 7일 초과 항목 포함
- ❌ Dataview 쿼리 결과 본 척 (Claude는 Dataview 못 읽음, 직접 파일 스캔 필수)

## Files / Tools
- **Tools**: Glob, Read
- **참조**: `160-tasks/**/*.md` (frontmatter만)

## Related
- [[ob-task-create]] — 등록
- [[ob-task-analyze]] — 분석
- [[ob-task-complete]] — 완료
