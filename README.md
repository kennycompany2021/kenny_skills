# Kenny Skills

Claude Code marketplace (Kenny Company 내부용).

## 📦 포함된 Plugins

### `doc-toolkit`
HTML 기반 PPT/보고서 생성 스킬.
- `ppt` — HTML 슬라이드 발표자료 생성
- `report` — A4 보고서형 HTML 문서 생성

> **참고**: 과거 이 레포에 있던 `obsidian-hub-workflows` plugin(14개 `ob-*` skill)은
> [Obsidian-Hub 레포](https://github.com/kennycompany2021/Obsidian-Hub)의 **project-level skill**
> (`.claude/skills/`)로 이관됐습니다. Vault 전용이라 git clone만으로 즉시 활성화되는
> 구조가 더 적합해서 marketplace/plugin 메커니즘에서 분리.

---

## 🚀 설치 (공식 슬래시 명령)

Claude Code에서 다음 명령만 실행하면 됩니다:

### 1. Marketplace 등록 (1회)
```
/plugin marketplace add kennycompany2021/kenny_skills
```

### 2. Plugin 설치
```
/plugin install doc-toolkit@kenny-skills
```

설치 시 scope를 물어봅니다:
- **user** — 기기 전역 (기본)
- **project** — 현재 프로젝트의 `.claude/settings.json`에 저장 (git 동기화 → 다중 기기 자동 공유 권장)

### 3. 재시작 또는 reload
```
/reload-plugins
```

---

## 🔄 업데이트

Skills를 수정한 후 Claude Code에 반영:

```
/plugin marketplace update kenny-skills
/plugin update <plugin>@kenny-skills
```

⚠️ **알려진 버그** ([claude-code #29071](https://github.com/anthropics/claude-code/issues/29071)): `/plugin marketplace update`가 marketplace clone을 git pull하지 않을 수 있음. 증상이 보이면 수동 갱신:

```bash
cd ~/.claude/plugins/marketplaces/kenny-skills && git pull
```

그 후 `/reload-plugins`.

---

## 🏗 구조

```
kenny_skills/
├── README.md
├── .claude-plugin/
│   └── marketplace.json             # marketplace 메타 (plugin 목록)
└── plugins/
    └── doc-toolkit/
        ├── .claude-plugin/
        │   └── plugin.json
        └── skills/
            ├── ppt/SKILL.md
            └── report/SKILL.md
```

---

## 🛠 새 Plugin 추가하는 방법

1. `plugins/{plugin-name}/.claude-plugin/plugin.json` 생성
2. `plugins/{plugin-name}/skills/{skill-name}/SKILL.md` 작성 (MADR-like frontmatter + 본문)
3. 루트 `.claude-plugin/marketplace.json`의 `plugins[]` 배열에 entry 추가
4. commit + push
5. 사용자는 `/plugin marketplace update kenny-skills` + `/plugin install {plugin}@kenny-skills`

---

## 📝 Skill 작성 지침

### Naming
- **kebab-case** (lowercase + hyphens)
- 도메인 prefix 권장 (예: `ob-*` for Obsidian-Hub workflows)
- 슬래시 명령으로 자동 노출: `/{plugin}:{skill}`

### SKILL.md 구조
```markdown
---
name: skill-name
description: {WHAT 한 문장} + {WHEN: trigger 상황·키워드}. 한국어+영어 병기.
---

# Skill Title

## When to Use
(description의 본문 버전)

## Algorithm
\`\`\`mermaid
flowchart TD
    A[트리거] --> B[단계1] --> C[단계2]
\`\`\`

## Steps
1. ...
2. ...

## Common Mistakes
- ❌ ...

## Files / Tools
- ...

## Related
- ...
```

### Description 작성 원칙
- **Third person** (시스템 프롬프트에 주입됨)
- **WHAT + WHEN** 모두 포함
- **약간 pushy** ("반드시 사용", "트리거" 같은 강한 표현)
- **Trigger 키워드** 다국어 병기
- **150자 이상** 권장 (Claude가 정확히 매칭하도록)
- 500줄 이하 유지 ([공식 권장](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices))

---

## 🔗 참고

- [Claude Code Plugin Marketplaces (공식)](https://code.claude.com/docs/en/plugin-marketplaces)
- [Discover and install prebuilt plugins](https://code.claude.com/docs/en/discover-plugins)
- [Agent Skills Spec - anthropics/skills](https://github.com/anthropics/skills)
- [MADR (Markdown ADR)](https://github.com/adr/madr) — ADR 포맷 표준

---

## 📜 라이선스

Private — Kenny Company 내부용.
