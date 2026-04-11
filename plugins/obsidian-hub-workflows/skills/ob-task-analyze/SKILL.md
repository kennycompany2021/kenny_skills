---
name: ob-task-analyze
description: Obsidian-Hub의 기존 태스크 파일을 분석하고 status를 in-progress로 변경할 때 반드시 사용. 사용자가 "B-09 분석해줘", "이 태스크 분석", "원인 찾아줘", "analyze task", "{ID} 봐줘", "왜 이래" 등을 말할 때 트리거. 프로젝트 허브 노트·Vault memory(_GOTCHAS/_PATTERNS)·관련 ADR을 자동 로드, 코드베이스 grep 탐색, frontmatter status 갱신, body의 ## 원인 분석/## 발생 시나리오/## 해결 방안 섹션 작성.
---

# ob-task-analyze

## When to Use
사용자가 특정 태스크 ID를 언급하며 분석/원인/해결 방안 작성을 요청할 때.

## Algorithm

```mermaid
flowchart TD
    A[분석 요청<br/>'B-09 분석해줘'] --> B[Glob 160-tasks/**/B-09-*.md]
    B --> C[태스크 파일 Read]
    C --> D[frontmatter project 확인]
    D --> E[100-projects/{project}.md 허브 로드]
    E --> F[300-resources/memory/projects/{project}/<br/>_PROJECT/_GOTCHAS/_PATTERNS Read]
    F --> G[관련 ADR grep<br/>300-resources/decisions/]
    G --> H[code/{project}/ 코드베이스 Grep]
    H --> I[원인 분석 작성]
    I --> J[발생 시나리오 작성]
    J --> K[해결 방안 작성<br/>대안+선택 이유]
    K --> L[frontmatter status:<br/>to-do → in-progress<br/>updated 갱신]
    L --> M[사용자 요약 보고]
    M --> N{trade-off<br/>있나?}
    N -->|YES| O[ob-adr-create 제안]
    N -->|NO| P[종료]
```

## Steps

1. **태스크 파일 찾기**:
   ```bash
   Glob 160-tasks/**/{ID}-*.md
   ```

2. **태스크 Read** → frontmatter `project` 확인

3. **컨텍스트 로드 (병렬)**:
   - 프로젝트 허브: `100-projects/{project}.md`
   - Vault memory: `300-resources/memory/projects/{project}/_PROJECT.md`, `_GOTCHAS.md`, `_PATTERNS.md`
   - 관련 ADR: `grep -l -r "{핵심 키워드}" 300-resources/decisions/`

4. **코드베이스 탐색**: `Grep` 또는 `Glob`으로 관련 파일 찾기 (Read는 필요한 부분만)

5. **본문 작성** (기존 내용 보존, 빈 섹션만 채움):
   - `## 원인 분석`: 루트 코즈 2~5줄
   - `## 발생 시나리오`: 어떤 조건에서 터지나
   - `## 해결 방안`: 선택한 방법 + 대안 1~2개 기각 이유

6. **frontmatter 갱신**:
   - `status: to-do` → `in-progress`
   - `updated: {오늘}`

7. **사용자 보고**: 원인 + 방안 요약 (3~5줄)

8. **ADR 승격 판단**:
   - body가 3줄 이상 trade-off 설명 필요?
   - 비자명한 설계 선택?
   - YES → `"ob-adr-create로 ADR 남길까요?"` 제안

## Common Mistakes
- ❌ 컨텍스트 로드 없이 추측으로 분석
- ❌ Vault memory의 _GOTCHAS 무시 (이미 알려진 함정 재발견)
- ❌ 기존 본문(특히 `## 요청 내용`) 덮어쓰기
- ❌ status 갱신 누락
- ❌ trade-off 있는데 ADR 제안 안 함

## Files / Tools
- **Tools**: Glob, Grep, Read, Edit
- **참조 파일**:
  - `100-projects/{project}.md`
  - `300-resources/memory/projects/{project}/*`
  - `300-resources/decisions/`
  - `code/{project}/`

## Related
- [[ob-task-create]] — 이전 단계
- [[ob-task-complete]] — 다음 단계
- [[ob-adr-create]] — ADR 승격 시
