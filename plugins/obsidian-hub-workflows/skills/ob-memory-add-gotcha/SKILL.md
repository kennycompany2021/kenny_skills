---
name: ob-memory-add-gotcha
description: Obsidian-Hub의 프로젝트별 함정·금지사항·실수 방지 규칙을 _GOTCHAS.md에 추가할 때 반드시 사용. 사용자가 "이거 하면 안 돼", "주의해야 함", "DELETE 금지", "조심해" 등을 말하거나 Claude가 작업 중 함정을 인지했을 때 자발적으로 제안. 300-resources/memory/projects/{프로젝트}/_GOTCHAS.md에 append-only로 추가 (기존 항목 수정/삭제 절대 금지). 다중 기기에서 자동 공유되어 같은 실수 반복 방지.
---

# ob-memory-add-gotcha

## When to Use
- 작업 중 "이건 하면 안 되는 거"를 발견
- 사용자가 함정·금지·주의사항을 알려줌
- FK violation, 데이터 무결성 위반 등의 실수 패턴

## Algorithm

```mermaid
flowchart TD
    A[함정 인지] --> B[프로젝트 확인]
    B --> C[300-resources/memory/projects/<br/>{project}/_GOTCHAS.md Read]
    C --> D{이미 있나?}
    D -->|YES| E[skip 또는 보강]
    D -->|NO| F[append 위치 결정<br/>파일 맨 끝]
    F --> G[항목 작성<br/>제목 + 이유 + 대응]
    G --> H[Edit으로 append<br/>기존 내용 변경 금지]
    H --> I[사용자 알림]
```

## Steps

1. **프로젝트 식별**: 어떤 프로젝트의 함정인지 (작업 중인 컨텍스트 또는 사용자 명시)

2. **기존 _GOTCHAS.md Read**:
   ```bash
   Read 300-resources/memory/projects/{project}/_GOTCHAS.md
   ```
   - 파일이 없으면 skip → ob-project-add 권장 (또는 새로 생성)
   - 같은 함정이 있으면 skip

3. **항목 작성** (한국어, 표준 포맷):
   ```markdown
   ## 🚨 {함정 제목}
   - {규칙·금지 한 줄}
   - **이유**: {왜 이게 함정인지}
   - **결과**: {위반 시 무슨 일이 생기나}
   - **원칙**: {준수해야 할 핵심}
   - **대응**: {올바른 방법}
   - 사례: [{날짜}] {실제 발생 사례 한 줄}
   ```

4. **append 실행**:
   - **반드시 Edit**으로 파일 맨 끝에 추가
   - 기존 항목 수정·삭제 절대 금지 (append-only)
   - 빈 줄 1개로 구분

5. **사용자 보고**: `"{project}/_GOTCHAS.md에 추가됨"`

## Common Mistakes
- ❌ 기존 _GOTCHAS 항목 수정·재정렬·삭제 (append-only 위반)
- ❌ 일반적이지 않은 1회성 케이스를 함정으로 기록
- ❌ "이유"·"결과" 없이 "X 하지 마"만 적기
- ❌ 다른 프로젝트의 _GOTCHAS와 혼동
- ❌ 같은 함정 중복 추가 (Read 누락)
- ❌ "Why·How to apply" 패턴(feedback 형식) 사용 → 이건 ob-memory-save-feedback의 영역

## Difference from ob-memory-save-feedback

| 항목 | ob-memory-add-gotcha | ob-memory-save-feedback |
|------|---------------------|----------------------|
| **대상** | 특정 프로젝트의 코드/DB/시스템 함정 | 사용자가 Claude에게 주는 작업 방식 교정 |
| **저장** | `projects/{proj}/_GOTCHAS.md` | `feedback/{slug}.md` |
| **방식** | append-only (한 파일 누적) | 파일 분리 (1개씩) |
| **예** | "*_hists DELETE 금지" | "users 조회 시 status_cd 필터 금지" |

## Files / Tools
- **Tools**: Read, Edit
- **수정 대상**: `300-resources/memory/projects/{project}/_GOTCHAS.md` (오직 append)

## Related
- [[ob-memory-save-feedback]] — 사용자 교정 피드백 (다른 영역)
- [[ob-memory-update-pattern]] — 재사용 패턴 (다른 영역)
- [[13_memory-architecture]] — 3-Layer Memory 배경
