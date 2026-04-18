# AI Harness Kit

FP/OOP 혼합 설계 철학과 엄격한 리뷰/검증 흐름을 전제로, **Claude Code**와 **OpenCode**에서 공통적으로 사용할 수 있는 하네스 모음입니다.

## 목적

이 레포는 아래를 한 번에 제공합니다.

- 전역 설치 스크립트
- 프로젝트 로컬 하네스 생성 스크립트
- Claude Code용 에이전트 파일
- OpenCode용 에이전트 파일
- OpenCode 커맨드 파일
- 프로젝트용 `AGENTS.md`, `CLAUDE.md`, `src/AGENTS.md` 템플릿

## 핵심 구조

### 기본 경로
- `developer`
- 필요 시 `planner`
- 위험한 변경이면 `devils-advocate`
- 최종 게이트는 `reviewer`
- 검증은 `tester`

### 경계 작업 경로
frontend와 backend를 함께 수정하거나 API 계약, auth/session, retry/timeout/cancellation, storage, race condition이 걸리면 `delivery-lead` 경로를 사용합니다.

흐름:

1. `delivery-lead`가 owner를 정함
   - `Owner: frontend`
   - `Owner: backend`
2. owner가 초안/구현 주도
3. 다른 쪽 개발자가 peer boundary review
4. `Boundary Sync: pass`가 되면
5. `devils-advocate -> reviewer -> tester`

## 파일 구조

```text
scripts/
  install_global_ai_harness.sh
  generate_project_harness.sh

templates/
  project/
    AGENTS.md
    CLAUDE.md
    opencode.json
    src/AGENTS.md
    .claude/
      settings.local.json
      agents/
        planner.md
        developer.md
        delivery-lead.md
        frontend-developer.md
        backend-developer.md
        devils-advocate.md
        reviewer.md
        tester.md
    .opencode/
      agents/
        planner.md
        developer.md
        delivery-lead.md
        frontend-developer.md
        backend-developer.md
        devils-advocate.md
        reviewer.md
        tester.md
      commands/
        delivery.md
        review.md
        test.md
```

## 스크립트 설명

### 1) 전역 설치
`install_global_ai_harness.sh`

무엇을 하나요?
- Claude Code 전역 설정을 `~/.claude/` 아래에 설치
- OpenCode 전역 설정을 `~/.config/opencode/` 아래에 설치
- 기존 설정은 `~/.ai-harness-backups/<timestamp>/`로 백업

지원 옵션:
- `--claude`
- `--opencode`
- `--both`

예시:

```bash
chmod +x ./scripts/install_global_ai_harness.sh
./scripts/install_global_ai_harness.sh --both
```

Codex에서 비대화식으로 실행:

```bash
codex exec --sandbox danger-full-access -a never "Run ./scripts/install_global_ai_harness.sh --both and summarize what was installed and where backups were saved."
```

### 2) 프로젝트 로컬 생성
`generate_project_harness.sh`

무엇을 하나요?
- 현재 디렉터리를 repo 루트라고 가정
- 로컬 프로젝트용 하네스 파일 생성
- 기존 파일은 타임스탬프 백업 디렉터리로 이동

생성 대상:
- `AGENTS.md`
- `CLAUDE.md`
- `opencode.json`
- `src/AGENTS.md`
- `.claude/agents/*`
- `.claude/settings.local.json`
- `.opencode/agents/*`
- `.opencode/commands/*`

예시:

```bash
chmod +x ./scripts/generate_project_harness.sh
./scripts/generate_project_harness.sh
```

Codex에서 실행:

```bash
codex exec -a never --sandbox workspace-write "Run ./scripts/generate_project_harness.sh from the repository root and summarize which files were created or overwritten."
```

## OpenCode에서 실제 사용법

기본 에이전트는 `developer`입니다.

### 단일 영역 작업
그냥 요청합니다.

```text
로그인 버튼 스타일 수정
```

### 경계 작업
OpenCode 커맨드를 사용합니다.

```text
/delivery 로그인 기능 개발
```

owner를 명시하고 싶으면:

```text
/delivery 이번 작업은 backend-led로 진행해.
Owner: backend
frontend-developer는 peer boundary review를 수행해.
Boundary Sync: pass 전에는 다음 게이트로 넘기지 마.
```

리뷰만 다시 돌릴 때:

```text
/review 인증 흐름 변경 점검
```

검증만 다시 돌릴 때:

```text
/test 로그인 변경 검증
```

## Claude Code에서 실제 사용법

기본 에이전트는 `developer`입니다.

### 단일 영역 작업
```bash
claude "로그인 버튼 스타일 수정"
```

### 경계 작업
```bash
claude --agent delivery-lead --teammate-mode in-process "로그인 기능 개발"
```

## 에이전트 설명

### planner
비사소한 작업에서 범위, 계약, 상태 전이, 검증 계획을 먼저 구조화합니다.

### developer
기본 구현 에이전트입니다. 단일 영역 작업을 처리합니다.

### delivery-lead
frontend와 backend를 동등한 peer developer로 조율합니다. 작업마다 owner를 정하고 `Boundary Sync`를 통과시킨 뒤 공통 게이트로 넘깁니다.

### frontend-developer
프론트엔드 구현자이자 peer boundary reviewer입니다. owner가 될 수도 있고, backend 작업에 대해 UX/state/effect 관점 피드백을 줄 수도 있습니다.

### backend-developer
백엔드 구현자이자 peer boundary reviewer입니다. owner가 될 수도 있고, frontend 작업에 대해 API/auth/error/state 관점 피드백을 줄 수도 있습니다.

### devils-advocate
숨은 가정, 반례, race condition, rollback, failure mode를 공격적으로 찾습니다.

### reviewer
엄격한 최종 품질 게이트입니다. 코드 품질뿐 아니라 handoff/report 누락도 fail로 처리할 수 있습니다.

### tester
검증 담당입니다. AGENTS.md 7.2 형식으로 검증 근거를 남깁니다.

## 중요한 주의점

- 이 하네스는 **작은 안전한 변경**을 기본값으로 둡니다.
- `reviewer` pass 전에는 `tester`를 돌리지 않습니다.
- 경계 작업은 `Boundary Sync: pass` 전에는 공통 게이트로 넘기지 않습니다.
- OpenCode에서는 `delivery-lead`가 오케스트레이션하고, `frontend-developer`/`backend-developer`는 peer developer로 동작합니다.
- Claude Code와 OpenCode는 파일 위치와 설정 방식이 다르므로, 템플릿과 스크립트는 그 차이를 반영합니다.

## 권장 레포 운영 방식

- 이 레포는 **배포용 하네스 저장소**로 둡니다.
- 실제 프로젝트에는 `generate_project_harness.sh`로 로컬 파일을 뿌립니다.
- 개인 환경에는 `install_global_ai_harness.sh`로 전역 설정을 깝니다.
- 변경 이력은 이 레포에서 관리합니다.

## 다음 추천 작업

- `/boundary-sync` 전용 OpenCode 커맨드 추가
- repo별 명령(`npm`, `pnpm`, `bun`) 선택형 생성 옵션 추가
- reviewer fail 기준을 도메인별로 세분화
- backend 전용 상세 규칙 파일 추가
