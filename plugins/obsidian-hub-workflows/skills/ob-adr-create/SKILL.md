---
name: ob-adr-create
description: Obsidian-Hub의 새 Architecture Decision Record(MADR 포맷)를 작성할 때 반드시 사용. 사용자가 "ADR 작성", "decision 남겨", "이거 결정 기록", "create adr", "왜 이렇게 했는지 남겨" 등을 말하거나, Claude가 비자명한 trade-off 있는 설계 선택 직후 자발적으로 사용. 300-resources/decisions/ 하위 sitemap 폴더(system/workflows/projects)에 ADR-NNNN-slug.md 파일 생성. 기존 ADR grep으로 supersede 후보 확인, scope 결정 트리, frontmatter(tags+keywords+supersedes) 작성, INDEX.md 갱신.
---

# ob-adr-create

## When to Use
- 비자명한 trade-off 있는 설계 선택 직후
- 아키텍처·인프라·규약 변경
- Body 3줄 이상 사유 필요한 결정
- 사용자가 명시적 ADR 작성 요청

## Algorithm

```mermaid
flowchart TD
    A[ADR 작성 트리거] --> B[기존 ADR grep<br/>'관련 결정 있나?']
    B -->|있음| C[supersedes 후보로 표시]
    B -->|없음| D[Scope 결정]
    C --> D
    D --> E{어느 scope?}
    E -->|Vault 인프라| F[system/]
    E -->|운영 방법론| G[workflows/]
    E -->|특정 프로젝트| H[projects/{name}/]
    F --> I[ID 부여<br/>max ADR-NNNN + 1]
    G --> I
    H --> I
    I --> J[templates/adr.md 복제]
    J --> K[frontmatter 작성<br/>id, title, status: accepted,<br/>date, tags, keywords,<br/>supersedes]
    K --> L[Context/Drivers/Options/<br/>Outcome/Consequences 작성]
    L --> M[INDEX.md 수동 인덱스 갱신]
    M --> N{supersede<br/>대상?}
    N -->|YES| O[ob-adr-supersede 호출]
    N -->|NO| P[사용자 보고]
    O --> P
```

## Steps

1. **기존 ADR 검색**:
   ```bash
   grep -l -r "{핵심 키워드}" 300-resources/decisions/
   ```
   매칭 있으면 후보로 메모 (supersedes 또는 related 후보).

2. **Scope 결정 트리**:
   - **system/**: Vault 자체 인프라 (경로, 동기화, 메모리 구조, CLAUDE.md 정책)
   - **workflows/**: 운영 방법론 (커밋·태스크·ADR·메모리 워크플로우)
   - **projects/{name}/**: 특정 프로젝트의 코드·DB·아키텍처 결정
   - **애매하면**: "다른 프로젝트에 재사용되나?" YES → system/workflows, NO → projects/

3. **ID 부여** (전 Vault 단조 증가):
   ```bash
   ls 300-resources/decisions/**/ADR-*.md 2>/dev/null | grep -oE 'ADR-[0-9]+' | sort -V | tail -1
   ```
   결과 + 1.

4. **파일 생성**: `300-resources/decisions/{scope}/ADR-NNNN-{slug}.md`
   - slug: 영문 kebab-case, 핵심 키워드 2~5개
   - 예: `ADR-0007-redis-vs-app-cache.md`

5. **Frontmatter** (`templates/adr.md` 기반):
   ```yaml
   ---
   id: ADR-NNNN
   title: {짧은 제목}
   status: accepted        # 보통 처음부터 accepted
   date: {YYYY-MM-DD}
   deciders: [kenny]
   tags: []                # [infra, path, data-model, ...]
   keywords: []            # 동의어 포함, grep 친화적
   supersedes: []          # [ADR-NNNN]
   superseded-by: []
   ---
   ```

6. **본문 (MADR 섹션)**:
   - `## Context and Problem Statement`: 배경, 해결할 문제
   - `## Decision Drivers`: 의사결정 요인
   - `## Considered Options`: 옵션 A/B/C
   - `## Decision Outcome`: 선택 + 이유
   - `### Consequences`: ✅/❌/⚠️
   - `## Pros and Cons of the Options`: 옵션별 상세
   - `## 🔗 Related`: 다른 ADR wiki 링크

7. **INDEX.md 갱신**:
   - `300-resources/decisions/INDEX.md`의 "Manual Index" 섹션
   - 해당 scope 하위에 한 줄 추가:
     `- [[ADR-NNNN-slug]] — 짧은 요약`

8. **Supersedes 처리**:
   - 만약 기존 ADR을 대체한다면 → `ob-adr-supersede` 호출
   - 단순 관련은 `## 🔗 Related`에 wiki 링크만

9. **사용자 보고**: 생성된 ADR 경로 + 핵심 결정 1줄

## Common Mistakes
- ❌ ID 충돌 (전 Vault 단조 증가 무시, scope별 카운트로 착각)
- ❌ Scope 잘못 분류 (system인데 projects에 둠)
- ❌ INDEX.md 갱신 누락
- ❌ frontmatter `tags` 비움 (검색 어려워짐)
- ❌ keywords 누락 (grep 검색 약화)
- ❌ status를 처음부터 `accepted` 대신 `proposed`로 (대부분 결정 직후 accepted)
- ❌ 기존 ADR grep 없이 중복 작성

## Files / Tools
- **Tools**: Glob, Grep, Read, Write, Edit
- **Templates**: `templates/adr.md`
- **참조**: `300-resources/decisions/INDEX.md`

## Related
- [[ob-adr-supersede]] — 기존 ADR 대체 시
- [[12_adr-decision-records]] — MADR 포맷 배경
- ADR-0005 — sitemap+tag+MADR 결정
