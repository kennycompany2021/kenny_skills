---
name: ob-task-create
description: Obsidian-Hub Vault의 160-tasks/{프로젝트}/ 폴더에 새 태스크를 생성할 때 반드시 사용. 사용자가 "태스크 등록", "버그 등록", "할 일 추가", "이거 해야해", "task create", "register issue", "카톡 분석해서 등록", "issue 추가" 등을 말할 때 트리거. B(Bug)/F(Feature)/M(Migration)/C(Config)/D(Doc) 카테고리 자동 판별, 프로젝트별 독립 ID 부여, frontmatter+body 템플릿 작성, daily 노트 ## 📥 접수 섹션에 append까지 자동 처리.
---

# ob-task-create

## When to Use
사용자가 새 태스크를 등록해달라고 명시하거나, 카톡·슬랙·메일에서 작업 요청을 분석할 때 사용.

## Algorithm

```mermaid
flowchart TD
    A[태스크 등록 트리거] --> B[프로젝트 식별]
    B -->|명시됨| C[160-tasks/{project}/]
    B -->|불명확| D[100-projects/ Glob<br/>또는 사용자 질문]
    C --> E[카테고리 판별<br/>B/F/M/C/D]
    D --> E
    E --> F[기존 ID Glob<br/>160-tasks/{proj}/{cat}-*.md]
    F --> G[새 ID = max + 1<br/>없으면 01]
    G --> H[templates/task.md 복제]
    H --> I[frontmatter 작성]
    I --> J[## 요청 내용 본문]
    J --> K[daily/{오늘}.md<br/>## 📥 접수 append]
    K --> L[사용자 보고]
```

## Steps

1. **프로젝트 식별**
   - 사용자 발화에서 프로젝트명 추출
   - 명확하지 않으면 `Glob 100-projects/*.md` → 후보 제시 또는 질문

2. **카테고리 판별**:
   - **B** (Bug): 동작 오류, 예외, 잘못된 결과
   - **F** (Feature): 신규 기능, 기능 개선
   - **M** (Migration): 데이터 이관, 연동, 마이그레이션
   - **C** (Config): 설정, 인프라, 권한
   - **D** (Doc): 문서, 매뉴얼

3. **ID 부여** (프로젝트별 독립):
   ```bash
   ls 160-tasks/{project}/{category}-*.md 2>/dev/null | sort -V | tail -1
   ```
   결과의 번호 + 1, 없으면 `01`부터.

4. **파일 생성**: `160-tasks/{project}/{category}-{NN}-{slug}.md`
   - slug: **영문 kebab-case**, 핵심 키워드 2~4개
   - 예: `B-09-status-cd-null.md`

5. **Frontmatter** (`templates/task.md` 기반):
   ```yaml
   ---
   id: {category}-{NN}
   title: {제목}
   project: {project_folder_name}
   type: {bug|feature|migration|config|doc}
   status: to-do
   priority: {urgent|high|normal|low}
   created: {YYYY-MM-DD}
   updated: {YYYY-MM-DD}
   tags: []
   ---
   ```

6. **본문**: `## 요청 내용` 섹션에 사용자 발화·분석 내용 작성. 다른 섹션(`## 원인 분석` 등)은 빈 상태로.

7. **daily 노트 append**:
   - `daily/{YYYY-MM-DD}.md`의 `## 📥 접수` 섹션 하단에 한 줄 추가
   - 형식: `- [{category}-{NN}] {제목} → [[{project}/{category}-{NN}-{slug}]]`

8. **사용자 보고**: 생성된 파일 경로 + ID + 카테고리 한 줄 요약

## Common Mistakes
- ❌ ID를 전 vault 단조 증가로 (프로젝트별 독립이어야 함, kwm/B-01과 alimi/B-01 공존)
- ❌ daily append 누락
- ❌ 카테고리 잘못 판별 (Migration vs Feature 헷갈림 주의)
- ❌ frontmatter `created`/`updated` 누락
- ❌ slug에 한글·공백·특수문자 포함
- ❌ priority를 상시 normal로 (urgent/high 기준 적용 필요)

## Files / Tools
- **Tools**: Glob, Read, Write, Edit
- **Templates**: `templates/task.md`
- **Daily**: `daily/{오늘}.md`

## Related
- [[ob-task-analyze]] — 다음 단계 (분석)
- [[ob-task-complete]] — 작업 완료
- ADR-0006 — ClickUp 제거 + 로컬 태스크 결정
