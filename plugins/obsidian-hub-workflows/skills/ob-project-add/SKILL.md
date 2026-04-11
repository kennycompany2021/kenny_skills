---
name: ob-project-add
description: 새 프로젝트를 Obsidian-Hub Vault에 등록할 때 반드시 사용. 사용자가 "새 프로젝트 추가", "{이름} 프로젝트 등록", "프로젝트 만들어", "add project" 등을 말할 때 트리거. 100-projects/{번호}_{이름}.md 허브 노트 생성(templates/project-hub.md 기반), 160-tasks/{같은이름}/ 폴더 생성, 300-resources/memory/projects/{같은이름}/ + decisions/projects/{같은이름}/ 폴더 생성, frontmatter에 id/name/repos/gdrive 채움.
---

# ob-project-add

## When to Use
- 새 클라이언트 프로젝트 시작
- 기존 외부 프로젝트를 Vault에 등록
- 100-projects/에 새 허브 노트 + 관련 폴더 모두 설정

## Algorithm

```mermaid
flowchart TD
    A[새 프로젝트 등록] --> B[기본 정보 수집<br/>이름, 클라이언트, ID 번호]
    B --> C[기존 ID 충돌 체크<br/>Glob 100-projects/*.md]
    C --> D{ID 충돌?}
    D -->|YES| E[다음 번호 추천]
    D -->|NO| F[폴더명 결정<br/>{ID}_{이름}]
    E --> F
    F --> G[100-projects/{folder}.md 생성<br/>templates/project-hub.md 기반]
    G --> H[frontmatter 채우기<br/>id, name, client, repos, gdrive]
    H --> I[160-tasks/{folder}/ mkdir]
    I --> J[300-resources/memory/projects/<br/>{folder}/ mkdir + 빈 _PROJECT/_GOTCHAS/_PATTERNS]
    J --> K[300-resources/decisions/projects/<br/>{folder}/ mkdir]
    K --> L[memory INDEX.md에 신규 프로젝트 항목 추가]
    L --> M[사용자 보고]
```

## Steps

1. **사용자에게 정보 확인** (없는 정보는 물어봄):
   - 프로젝트 ID 번호 (1~99, 중복 X)
   - 프로젝트 이름 (한국어 OK)
   - 클라이언트
   - 코드 레포 경로 (`code/{repo}` 형식, 없으면 빈 배열)
   - GDrive 폴더 (`gdrive/11_프로젝트/{이름}` 형식, 없으면 빈 문자열)
   - 태그 (선택)

2. **ID 충돌 체크**:
   ```bash
   ls 100-projects/{ID}_*.md 2>/dev/null
   ```
   있으면 다음 번호 추천.

3. **폴더명 확정**: `{ID}_{한국어이름}` (예: `67_새프로젝트`)

4. **허브 노트 생성**: `100-projects/{folder}.md`
   - `templates/project-hub.md` 기반
   - frontmatter:
     ```yaml
     ---
     id: {ID}
     name: {한국어 이름}
     client: {클라이언트}
     status: active
     type: project
     started: {YYYY-MM-DD}
     due:
     tags: []
     gdrive: "gdrive/11_프로젝트/{folder}"
     repos:
       - name: {repo_name}
         path: "code/{repo_name}"
         role:
     ---
     ```
   - 본문에 `## 📋 태스크` Dataview 임베드 (`FROM "160-tasks/{folder}"`)

5. **태스크 폴더 생성**:
   ```bash
   mkdir -p "160-tasks/{folder}"
   ```
   `.gitkeep` 파일 추가 (빈 폴더 git 추적용)

6. **Memory 폴더 생성**:
   ```bash
   mkdir -p "300-resources/memory/projects/{folder}"
   ```
   빈 `_PROJECT.md`, `_GOTCHAS.md`, `_PATTERNS.md` 3개 생성 (frontmatter만)

7. **Decisions 폴더 생성**:
   ```bash
   mkdir -p "300-resources/decisions/projects/{folder}"
   ```
   `.gitkeep`

8. **Memory INDEX.md 갱신**:
   `300-resources/memory/INDEX.md`의 `## 🏗 Projects` 섹션에 추가:
   ```markdown
   ### {folder}
   @projects/{folder}/_PROJECT.md
   @projects/{folder}/_GOTCHAS.md
   @projects/{folder}/_PATTERNS.md
   ```

9. **사용자 보고**:
   - 생성된 파일·폴더 목록
   - 다음 단계 안내 ("코드 레포 경로 확정 시 frontmatter 갱신")

## Common Mistakes
- ❌ ID 충돌 (기존 100-projects/ 확인 누락)
- ❌ 폴더명에 영문만 사용 (다른 허브 노트들이 한국어 사용 중이면 일관성 깨짐)
- ❌ Memory INDEX.md 갱신 누락 → Claude가 새 프로젝트 memory를 자동 로드 못 함
- ❌ `.gitkeep` 누락 → 빈 폴더 git 추적 안 됨
- ❌ frontmatter `gdrive`/`repos`를 실제 경로 확인 없이 추측

## Files / Tools
- **Tools**: Bash (mkdir), Glob, Read, Write, Edit
- **Templates**: `templates/project-hub.md`
- **수정 대상**:
  - `100-projects/{folder}.md` 신규
  - `160-tasks/{folder}/.gitkeep`
  - `300-resources/memory/projects/{folder}/{_PROJECT,_GOTCHAS,_PATTERNS}.md`
  - `300-resources/decisions/projects/{folder}/.gitkeep`
  - `300-resources/memory/INDEX.md` Edit

## Related
- [[ob-project-archive]] — 종료 시
- ADR-0006 — 로컬 태스크 시스템
