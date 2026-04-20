# Global AI Harness

Claude Code 전역 에이전트 하네스. 프롬프트 기교가 아니라 **역할 분리 · 경계 · 오케스트레이션 규율**로 반복 품질을 만든다.

## 설치 대상

- `~/.claude/agents/*.md` — 에이전트 정의 (flat 복사)
- `~/.claude/CLAUDE.md` — 전역 엔지니어링 원칙

## 폴더 구조

```
install-_global-_ai-_harness.sh/
├── README.md
├── install.sh
├── global/
│   └── CLAUDE.md                  # 전역 엔지니어링 원칙
└── agents/
    ├── orchestrator/
    │   └── developer.md           # 유일한 orchestrator
    ├── planning/
    │   ├── planner.md             # 계획 분석
    │   └── delivery-lead.md       # 경계 분석
    ├── implementer/
    │   ├── frontend-developer.md  # UI/상태/훅 owner 또는 peer
    │   └── backend-developer.md   # API/도메인/스토리지 owner 또는 peer
    └── quality/
        ├── devils-advocate.md     # 공격적 가정 검증
        ├── reviewer.md            # 최종 품질 게이트
        └── tester.md              # 실행 검증
```

Claude Code는 `~/.claude/agents/`를 flat 구조로만 읽기 때문에, 설치 스크립트가 하위 폴더를 평탄화해서 복사한다. 저장소 상의 폴더 분리는 **사람이 읽을 때의 역할 분류** 목적이다.

## 사용법

```bash
# dry-run: 무엇이 복사될지 먼저 확인
bash install.sh --dry-run

# 실제 설치 (기존 파일은 ~/.claude/backups/harness-<timestamp>/ 로 백업)
bash install.sh

# 백업 없이 즉시 덮어쓰기
bash install.sh --force

# 에이전트만 설치하고 CLAUDE.md 는 건너뛰기
bash install.sh --no-claude-md

# 설치 위치 바꾸기
CLAUDE_HOME=/tmp/claude-test bash install.sh --dry-run
```

---

## 에이전트 성격 요약

각 에이전트는 **leaf** (다른 에이전트를 호출하지 않음) 또는 **orchestrator** (유일하게 호출 권한을 가짐) 로 엄격히 나뉜다.

| 에이전트 | 위치 | 역할 | 성격 한 줄 |
|---|---|---|---|
| **developer** | orchestrator | 유일한 지휘자 | 규율을 지키는 감독. 본인도 구현하고, 흐름을 통제하며, 최종 보고의 책임자다. |
| **planner** | planning | 구조 분석가 | "먼저 레이어부터 쪼개자" 타입. 과도한 설계 거부, 가장 작고 안전한 경로 선호. |
| **delivery-lead** | planning | 경계 분석가 | single-area 인지 cross-boundary 인지만 판정. 지시/위임 표현 금기. |
| **frontend-developer** | implementer | UI/상태 장인 | owner일 땐 구현, peer일 땐 감시만. 렌더 사이드 이펙트와 파생 상태 저장을 혐오. |
| **backend-developer** | implementer | 계약/운영 장인 | owner일 땐 구현, peer일 땐 감시만. 경쟁 상태·롤백·멱등성 지적에 집착. |
| **devils-advocate** | quality | 악마의 변호인 | "이게 왜 안 터지는데?" 전담. 숨은 가정, 엣지 케이스, 경쟁 상태를 파낸다. |
| **reviewer** | quality | 엄격한 심판 | 최종 품질 게이트. 파생 상태, 숨은 이펙트, 핸드오프 누락을 즉시 fail. 테스트 대행 금지. |
| **tester** | quality | 실행 검증관 | 실제로 돌려본 것만 pass. 외부 리뷰 내장 금지. 자동화 없으면 수동 검증 절차를 남긴다. |

공통 규율:
- leaf는 다른 에이전트를 호출하지 않는다. orchestration 표현("다음 단계로", "재호출", "넘긴다") 금지.
- orchestrator는 leaf의 자율 지시를 무시한다.
- owner(책임 주체)는 반드시 1명. editor(실제 수정 파일 범위)는 양쪽에 걸쳐도 된다.

---

## 케이스별 동작 흐름

오케스트레이션은 오직 `developer` 한 명이 수행한다. 작업 성격에 따라 3가지 케이스로 분기된다.

### Case 1. Trivial 단일 영역 변경
명백한 단일 파일 버그, 오타, 동작 변화 없는 국소 리팩토링 등.

```
developer 구현
  → self-check (lint / typecheck / 최소 테스트 또는 수동 검증 절차 명시)
    → reviewer
      ├─ fail → 수정 → reviewer 재실행
      └─ pass → tester
```

- `planner`, `delivery-lead` 호출하지 않는다 (불필요한 홉 제거).
- `devils-advocate` 생략 가능.

### Case 2. Non-trivial 단일 영역 변경
기능 추가, 동작 변경, 다중 파일 수정이지만 프론트/백 경계는 넘지 않음.

```
planner (계획 분석)
  → developer 구현 + self-check
    → devils-advocate (숨은 가정 / 엣지 공격)
      → reviewer
        ├─ fail → 수정 → reviewer 재실행
        └─ pass → tester
```

- `delivery-lead` 는 호출하지 않는다 (경계 의심 없음).
- reviewer fail 수정도 동일 영역 내면 peer-review 없이 reviewer만 재실행.

### Case 3. Cross-boundary 작업
프론트엔드와 백엔드가 동시에 바뀜. API/계약/인증/스토리지에 영향.

```
planner
  → delivery-lead (single-area/boundary 판정 + 추천 owner + 계약)
    → 추천 owner 호출 (frontend-developer 또는 backend-developer, Role: owner) — 구현
      → 반대편 agent 호출 (Role: peer-review) — 계약 검토
        → Boundary Sync
          ├─ revision-needed → owner 재호출 → peer-review 재호출 (pass까지 반복)
          └─ pass → devils-advocate
                     → reviewer
                       ├─ fail (boundary 영향) → owner 재호출 → peer-review → Boundary Sync → reviewer 재실행
                       ├─ fail (boundary 무관) → 수정 → reviewer 재실행
                       └─ pass → tester
```

규칙:
- `delivery-lead` 는 **분석만** 한다. 구현/위임/재실행 지시는 무시한다.
- Boundary Sync: pass 전에는 절대 reviewer 로 진행하지 않는다.
- owner 는 1명, editor 는 양쪽 파일에 걸칠 수 있다 — 두 개념 혼동 금지.

---

## reviewer fail 처리 규칙

| 수정 성격 | 재실행 경로 |
|---|---|
| boundary 계약에 영향 있음 | owner 수정 → peer-review → Boundary Sync pass → reviewer 재실행 |
| boundary 무관 | 수정 → reviewer 재실행 |
| reviewer pass 이후 | tester 시작 |

## 외부 리뷰 (Codex 등) 처리

- `tester` / `reviewer` 안에 **내장하지 않는다**.
- 필요하면 `developer` 가 직접 sibling optional step 으로 호출한다.

---

## 전역 엔지니어링 원칙 (`global/CLAUDE.md` 요약)

**사고 순서** — 입력 정규화 → 순수 변환 → 상태 전이 → 이펙트 실행.

**핵심 원칙**
- 계산/검증/정규화/매핑/필터링/집계는 순수 함수 선호
- 사이드 이펙트는 경계에서 격리
- 불변성 기본
- 파생 상태 저장 금지
- 숨은 전역 상태와 암묵적 의존성 금지
- 명시적 상태 전이 선호
- 상속보다 조합
- 작고 되돌릴 수 있는 diff

**React**
- 상태 단일 출처
- 훅 의존성 완전
- 렌더링 · 변환 · 이펙트 분리
- network / storage / timer / browser API 는 경계 뒤에
- 장시간 이펙트는 cleanup, 필요 시 요청 취소
- 섣부른 memoization 금지

**Cross-boundary**
- owner 1명 지정
- 반대편은 peer boundary review
- Boundary Sync pass 전에 최종 리뷰 진입 금지

---

## 최종 보고 필수 항목

orchestrator(`developer`)의 최종 보고에는 아래 6개 항목이 반드시 존재해야 한다. 누락 시 reviewer 가 fail 처리한다.

- Summary
- Scope
- Changed Files
- Validation
- Risks
- Next Step
