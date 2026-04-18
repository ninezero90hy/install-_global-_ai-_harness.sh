# AGENTS.md

## 1. Purpose
이 문서는 이 저장소에서 Codex, Claude, 개발자가 일관된 기준으로 안전하게 변경하기 위한 공통 작업 규칙이다.

- 변경은 항상 작동 보존, 범위 최소화, 책임 분리를 우선한다.
- 구현 선택은 취향이 아니라 변경 용이성, 테스트 용이성, 복잡도 통제를 근거로 결정한다.
- 루트 AGENTS.md는 저장소 전체에 공통인 원칙만 다룬다.
- 영역별 상세 규칙은 각 하위 디렉터리의 AGENTS.md에서 다룬다.
- Claude 전용 역할 규칙은 `CLAUDE.md`, `.claude/agents/*`에 둔다.
- Codex, Claude, 개발자는 역할이 달라도 이 공통 규칙을 함께 따른다.

---

## 2. Core Working Rules
- 항상 최소 변경으로 문제를 해결한다.
- 관련 없는 파일은 수정하지 않는다.
- 기존 구조와 진입점을 임의로 바꾸지 않는다.
- 새 라이브러리 도입은 반드시 필요할 때만 한다.
- 먼저 기존 패턴을 따르고, 반복되는 문제나 명확한 구조적 문제가 있을 때만 새 패턴을 제안한다.
- 리팩토링과 동작 변경은 가능하면 분리한다.

---

## 3. Harness Engineering Rules
이 저장소는 프롬프트 기교보다 하네스 엔지니어링을 우선한다.

- 목표는 "한 번 그럴듯한 결과"가 아니라 "반복해도 비슷한 품질이 나오는 결과"다.
- 비사소한 작업은 바로 구현하지 말고, 먼저 문제를 구조화한다.
- 복잡한 작업은 PLANS.md를 따른다.
- 문서화, 검증, 리뷰, 평가까지 포함되어야 작업 완료로 본다.
- 외부 리뷰 도구와 로컬 검증 흐름이 함께 돌아가도 판단 기준은 일관되어야 한다.

---

## 4. When to Plan First
아래 중 하나라도 해당하면 구현 전에 PLANS.md에 따라 계획을 먼저 작성한다.

- 기능 추가
- 동작 변경
- 다중 파일 수정
- 아키텍처나 데이터 흐름 변경
- API / 인증 / 스토리지 / 타이머 / 폴링 변경
- 테스트 전략 변경
- 요구사항이 모호한 작업
- 영향 범위가 한눈에 보이지 않는 리팩토링

아래는 계획 없이 바로 진행할 수 있다.

- 오타 수정
- 문서 문구 수정
- 동작 변화가 없는 국소적 리팩토링
- 명백한 단일 파일 버그 수정

---

## 5. Required Execution Flow
비사소한 작업은 아래 순서를 따른다.

1. 요청의 목표와 제약을 정리한다.
2. 관련 코드와 기존 패턴을 먼저 확인한다.
3. PLANS.md 형식으로 Context / Problem / Solution / Risks / Validation을 정리한다.
4. 작업을 `developer` 경로 또는 `delivery-lead` 경로로 라우팅한다.
5. 계획 범위 안에서만 구현한다.
6. 가능하면 Codex 리뷰를 병렬로 시작한다.
7. 경계 작업이면 Boundary Sync를 먼저 완료한다.
8. 위험한 변경이면 Devil's Advocate 검토를 수행한다.
9. reviewer가 변경분을 판정한다.
10. reviewer가 pass하면 tester가 검증한다.
11. Codex 결과가 도착하면 findings를 병합하고, 반영 또는 미반영 사유를 기록한다.
12. 7.2 Final Report Format에 따라 결과를 보고한다.

### 5.0 Routing Rule
기본 작업은 `developer` 경로를 사용한다.

아래 중 하나라도 해당하면 `delivery-lead` 경로를 사용한다.
- frontend와 backend를 함께 수정한다
- API 계약이 바뀐다
- auth / session / permission이 걸린다
- retry / timeout / cancellation / dedupe 정책이 필요하다
- race condition 가능성이 있다
- storage / polling / optimistic update가 걸린다
- frontend와 backend의 책임 경계 조율이 필요하다

### 5.1 Cross-boundary Boundary Sync Gate
프론트엔드와 백엔드 경계를 함께 건드리는 작업은 구현 후 바로 reviewer로 넘기지 않는다.

- 먼저 `delivery-lead`가 이번 작업의 owner를 정한다.
  - Owner: frontend
  - Owner: backend
- owner가 초안과 경계 제안을 만든다.
- 다른 한쪽 developer는 peer 관점에서 boundary review를 한다.
- 두 developer는 반드시 아래 둘 중 하나로 상태를 정리한다.
  - Boundary Sync: pass
  - Boundary Sync: revision-needed
- Boundary Sync: pass 전에는 devils-advocate / reviewer / tester 단계로 넘어가지 않는다.
- Boundary Sync: revision-needed이면 owner가 제안을 수정하고 다시 동기화를 수행한다.

### 5.2 Codex Review Rules
`Claude Code`에서 `Codex`를 통해 코드 리뷰를 수행할 때는 아래 기준을 따른다.

- Codex 리뷰 요청은 환경에 맞는 명령으로 수행한다. 예: `/codex:review`
- 스타일 지적보다 차단 이슈와 고위험 이슈를 먼저 본다.
- 인증, 데이터 손실, 롤백 안정성, 경쟁 상태, 회귀를 중점적으로 본다.
- 광범위한 재작성보다 가장 작고 안전한 수정안을 우선한다.
- 동작이 변경되는 경우 실행해야 할 구체적인 테스트를 제안한다.
- 피처 브랜치의 머지 전 리뷰는 `main` 브랜치를 기준으로 비교한다. `main` 브랜치에서 직접 작업 중이면 워킹 트리 diff를 대상으로 리뷰한다.
- 단순 포맷팅 변경은 실제 결함을 가리지 않는 한 지적하지 않는다.
- 확신이 없을 때는 어떤 식으로 실패할 수 있는지와 영향을 받는 파일을 설명한다.
- Codex 리뷰는 보조 신호이지만 무시하지 않는다.
- Codex 결과가 늦거나 unavailable이어도 로컬 리뷰와 검증은 멈추지 않는다.
- Codex findings는 blocker / high-risk / non-blocking으로 다시 분류해 병합한다.

### 5.3 Devil's Advocate Rules
아래 조건 중 하나라도 해당하면 Devil's Advocate 검토를 먼저 수행한다.

- 인증 / 권한
- 삭제 / 복구 / 롤백
- API 계약 변경
- 상태 전이 / reducer / 상태 머신
- 캐시 / 동기화 / 재시도 / 타이머 / 폴링
- localStorage / sessionStorage
- 경쟁 상태 가능성
- 요구사항 해석 여지가 큰 작업

검토 기준:
- 코드 스타일이 아니라 숨은 가정, 반례, 경계 조건, 실패 시나리오를 찾는다.
- "정상 동작"보다 "어떻게 실패할 수 있는가"를 먼저 본다.
- 가능한 경우 넓은 재설계보다 작은 안전장치를 먼저 제안한다.
- findings는 reviewer 이전에 가능한 한 반영하고, 남긴 경우 이유를 기록한다.

### 5.4 Claude Review / Validation Rules
저장소의 로컬 품질 게이트와 검증 흐름은 아래 기준을 따른다.

- reviewer는 실제 diff와 변경 파일만 기준으로 판단한다.
- reviewer는 회귀, 숨은 상태, 숨은 의존성, effect 누수, Hook 규칙 위반, 테스트 가능성 저하를 우선 본다.
- reviewer가 fail이면 tester로 넘기기 전에 blocker부터 수정한다.
- tester는 가장 좁고 관련성 높은 검증부터 수행한다.
- tester는 저장소에 실제로 존재하는 명령만 사용한다.
- tester는 실행하지 않은 검증을 통과라고 쓰지 않는다.
- Codex 결과를 기다리느라 로컬 리뷰 / 검증을 멈추지 않는다.
- 단, reviewer가 fail인 상태에서는 tester를 진행하지 않는다.
- Codex 결과가 늦게 도착하면 최종 종료 전에 병합해서 다시 판단한다.

---

## 6. Hard Rules

### 6.1 No else
- `else`는 사용하지 않는다.
- `else if`도 사용하지 않는다.
- guard clause / early return으로 분기한다.
- 실패, 예외, 빈 값, 무효 입력을 먼저 반환한다.
- 중첩 `if`는 평탄화한다.
- 삼항 연산자는 허용하되 중첩 삼항은 금지한다.

### 6.2 Const-first
- 기본은 `const`를 사용한다.
- 재할당이 꼭 필요할 때만 `let`을 사용한다.
- `var`는 금지한다.

### 6.3 No magic values
- 의미 있는 숫자와 문자열은 상수로 승격한다.
- timeout, interval, retry, limit, key, label은 상수로 관리한다.

### 6.4 Clear naming
- 이름은 역할과 책임이 드러나야 한다.
- `util`, `data`, `handler`, `temp` 같은 모호한 이름 남용을 금지한다.

### 6.5 Pure core / effect boundary
- 계산, 검증, 정규화, 매핑, 필터링, 집계는 가능한 한 순수 함수로 분리한다.
- 비즈니스 로직과 IO / 네트워크 / 스토리지 / 타이머 / 브라우저 effect를 섞지 않는다.
- 상태는 최소화하고, 파생 데이터는 저장하지 말고 계산으로 표현한다.
- 상태 변화는 암묵적 mutation보다 명시적 전이로 표현한다.
- 공유 mutable 상태와 숨은 전역 상태를 피한다.

---

## 7. Definition of Done
작업은 아래 조건을 만족해야 완료로 본다.

- 요청한 동작 또는 수정이 실제로 반영되었다.
- 변경 범위가 계획 범위를 넘지 않았다.
- 관련 lint / test / review를 수행했다.
- 가능하면 Codex review를 요청했고, 결과가 있으면 반영 또는 미반영 사유를 남겼다.
- 위험한 변경에서는 Devil's Advocate 검토를 수행했고, 남긴 이슈가 있으면 기록했다.
- 경계 작업에서는 Boundary Sync를 완료했고, 남긴 이슈가 있으면 기록했다.
- 로컬 리뷰 게이트 결과와 검증 결과가 명시되었다.
- 검증하지 못한 항목이 있으면 명시했다.
- 남은 리스크를 숨기지 않았다.
- 아래 Handoff Ready 기준을 모두 만족한다.
- 최종 보고는 7.2 Final Report Format을 따른다.

## 7.1 Handoff Ready
아래 조건을 모두 만족해야 "사람이 이어받을 수 있는 상태"로 본다.

1. 변경 목적이 3줄 이내로 요약되어 있다.
2. 변경 범위가 명시되어 있다.
   - 무엇을 바꿨는지
   - 무엇은 의도적으로 안 바꿨는지
3. 변경 파일 목록이 있다.
   - 각 파일마다 왜 바꿨는지 1줄 설명이 있다.
4. 검증 내역이 있다.
   - 실행한 명령
   - 실행 결과
   - 실행하지 못한 검증과 이유
5. 남은 이슈가 있다면 숨기지 않고 적혀 있다.
   - 남은 리스크
   - 후속 작업 필요 여부
   - 임시 처리라면 제거 조건
6. 다음 작업자가 바로 이어서 할 수 있는 시작점이 있다.
   - 다음으로 볼 파일 / 함수 / 화면 / 명령 중 하나 이상이 적혀 있다.
7. 개인 로컬 맥락에 의존하지 않는다.
   - "내 로컬에서는 됨"으로 끝나지 않는다.
   - 별도 설명 없이는 재현 불가능한 상태가 아니다.
   - 숨은 환경 변수, 수동 단계, 임시 데이터 의존이 있으면 반드시 적는다.
8. 동작 변경이 있으면 그 사실이 명시되어 있다.
   - 사용자 관점에서 무엇이 달라졌는지 적는다.
9. 포기한 선택지가 있으면 이유가 적혀 있다.
   - 왜 이 방식으로 했는지
   - 왜 다른 대안을 쓰지 않았는지 짧게 남긴다.

Handoff Ready는 아래 중 하나라도 빠지면 fail이다.
- Summary 없음
- Changed Files 없음
- Validation 명령 없음
- 미검증 항목 누락
- 남은 리스크 누락
- Next Step 없음

## 7.2 Final Report Format
최종 보고는 아래 형식을 반드시 따른다.

1. Summary
   - 무엇을 바꿨는지 3줄 이내

2. Scope
   - 변경한 것
   - 의도적으로 제외한 것

3. Changed Files
   - 파일별 변경 이유 1줄씩

4. Validation
   - 실행한 명령
   - 결과
   - 실행하지 못한 검증과 이유

5. Risks
   - 남은 리스크
   - 임시 처리 여부

6. Next Step
   - 다음 작업자가 바로 시작할 수 있는 1~3개 액션

---

## 8. Directory-specific Rule
- 프론트엔드 관련 상세 규칙은 `src/AGENTS.md`를 따른다.
- 레거시 CLI 관련 상세 규칙은 `legacy-cli/AGENTS.md`를 따른다.
