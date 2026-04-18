# src/AGENTS.md

## 1. Scope
이 문서는 `src/` 이하의 프론트엔드 코드에 적용한다.

- 루트 `AGENTS.md`의 공통 규칙을 먼저 따른다.
- 이 문서는 React / UI / 상태 / effect / 비동기 / 사용자 상호작용에 대한 구체 규칙만 다룬다.
- 규칙이 충돌하면 우선순위는 다음과 같다.
  1. 루트 `AGENTS.md`
  2. 이 문서
  3. 파일 로컬 관례

---

## 2. Frontend Architecture Boundary
프론트엔드 코드는 아래 네 층으로 나눈다.

1. UI
2. 순수 변환
3. 상태 전이
4. 부작용 경계

### 2.1 UI
UI 레이어의 책임:
- 렌더링
- 사용자 이벤트 연결
- props 조립
- 상태 표시

UI 레이어에서 하지 말 것:
- fetch / storage / timer / browser API 직접 호출
- 데이터 정규화 / 매핑 / 검증 로직 직접 구현
- 비즈니스 규칙 분기를 JSX 전반에 흩뿌리기
- render 중 부작용 실행

### 2.2 순수 변환
순수 변환 레이어의 책임:
- 정규화
- 검증
- 매핑
- 필터링
- 집계
- 포맷 변환
- 정책 판정

규칙:
- 입력이 같으면 항상 출력이 같아야 한다.
- 외부 상태, 시간, 랜덤, 네트워크에 의존하지 않는다.
- 같은 변환이 2번 이상 나오면 순수 함수 추출을 우선 검토한다.

### 2.3 상태 전이
상태 전이 레이어의 책임:
- 이벤트에 따른 상태 변경 규칙
- reducer / transition function / state machine
- 불변 조건 유지

규칙:
- 상태 변경은 의미 있는 이벤트 기준으로 표현한다.
- ad-hoc setState 연쇄보다 reducer / transition function을 우선한다.
- 아래 중 하나라도 해당하면 reducer를 우선 검토한다.
  - 함께 바뀌는 상태가 3개 이상
  - 이벤트 종류가 4개 이상
  - 이전 상태에 따라 다음 상태가 달라짐
  - 성공 / 실패 / 재시도 / 취소 흐름이 있음

### 2.4 부작용 경계
부작용 경계의 책임:
- API 호출
- localStorage / sessionStorage
- timer / polling
- browser API
- navigation
- analytics / logging

규칙:
- effect는 경계에서만 실행한다.
- 네트워크 / 저장소 / 타이머 / 브라우저 접근은 adapter / helper / service / custom hook 뒤에 둔다.
- UI 컴포넌트는 경계 구현 세부사항을 몰라야 한다.

---

## 3. Component Rules
컴포넌트는 표현과 이벤트 연결에 집중한다.

### 3.1 Allowed
- props를 받아 UI를 렌더링
- 사용자 이벤트를 핸들러에 연결
- selector / formatter / pure helper 호출
- 작은 UI 전용 분기

### 3.2 Not allowed
- fetch 직접 호출
- localStorage 직접 접근
- setTimeout / setInterval 직접 관리
- 큰 데이터 정규화 로직 직접 작성
- 비즈니스 규칙을 JSX 곳곳에 분산
- props를 복사해서 state로 저장
- 파생값을 state로 저장

### 3.3 Split Rules
아래 중 하나라도 해당하면 컴포넌트 분리를 우선 검토한다.

- 렌더링 + 데이터 요청 + 정규화 + mutation을 모두 가진다
- 이벤트 핸들러가 3개 이상인데 각각 로직이 길다
- JSX 밖 로직이 너무 많아 화면 의도가 흐려진다
- 같은 화면에서 "표현", "상태 계산", "effect orchestration"이 강하게 섞인다

분리 방향:
- View 컴포넌트
- Container / orchestration
- pure transformer
- custom hook
- adapter

---

## 4. State Rules
### 4.1 Single Source of Truth
- 같은 의미의 상태를 두 군데 저장하지 않는다.
- 서버 응답 원본과 가공 결과를 둘 다 state에 저장하지 않는다.
- props와 state에 같은 값을 중복 저장하지 않는다.

### 4.2 No Derived State
금지:
- 정렬 결과 저장
- 필터 결과 저장
- count / total / fullName 같은 계산값 저장
- props 복사본 저장

허용:
- 사용자가 편집 중인 임시 draft
- 외부 시스템과 동기화 시점 때문에 필요한 snapshot
- 비싼 계산 결과를 memo로 계산하는 경우

단, 허용 케이스도 이유가 설명 가능해야 한다.

### 4.3 Explicit Transition
- setX 여러 개를 순차 호출해 상태 의미를 만들지 않는다.
- 상태 의미가 있으면 reducer / transition function으로 올린다.
- boolean flag가 3개 이상 생기면 상태 모델을 다시 본다.

권장:
- `isLoading + isError + isSuccess` 조합보다 `status: 'idle' | 'loading' | 'success' | 'error'`
- 여러 setState 대신 event 기반 transition

### 4.4 Immutability
- 객체 / 배열 / 컬렉션을 직접 mutate하지 않는다.
- state update는 항상 새 값으로 만든다.
- 공유 객체 참조를 조용히 수정하지 않는다.

---

## 5. Hooks Rules
### 5.1 Basic
- Hook은 최상위에서만 호출한다.
- 조건부 Hook 호출 금지
- 반복문 안 Hook 호출 금지

### 5.2 Effect Purpose
한 `useEffect`에는 목적을 하나만 둔다.

허용:
- 구독
- 네트워크 요청
- 브라우저 동기화
- 타이머 관리

금지:
- 서로 unrelated한 작업을 하나의 effect에 혼합
- 데이터 요청 + 이벤트 리스너 등록 + DOM 조작을 한 effect에 같이 넣기

### 5.3 Dependency Completeness
- 의존성 배열은 완전해야 한다.
- 의존성을 숨기려고 eslint-disable에 기대지 않는다.
- 의존성 문제는 구조 문제로 보고 먼저 분리할 수 있는지 본다.

### 5.4 Cleanup
아래는 cleanup이 반드시 있어야 한다.

- 이벤트 리스너
- subscription
- timer
- polling
- observer
- 장수 async effect

### 5.5 Request Cancellation
아래 중 하나라도 해당하면 취소 또는 무효화 처리를 둔다.

- 컴포넌트 언마운트 가능
- 빠른 연속 요청 가능
- 이전 요청 결과가 늦게 도착할 수 있음
- 검색 / 자동완성 / 필터 변경 같은 인터랙션

기본:
- fetch 계열은 AbortController 우선
- 취소가 어려운 경우 stale result 무시 전략이라도 둔다

---

## 6. Async / Data Rules
### 6.1 Required UI States
데이터 요청이 있으면 가능한 한 아래를 분리해서 다룬다.

- loading
- error
- empty
- success

### 6.2 Race / Retry / Timeout
아래는 숨기지 않고 명시적으로 다룬다.

- 중복 요청
- 늦게 도착한 응답
- 재시도
- 타임아웃
- polling 주기
- dedupe 필요 여부

규칙:
- retry / timeout / polling interval은 상수로 관리한다.
- 네트워크 정책은 adapter / client 레이어에 둔다.
- 컴포넌트에서 매번 정책을 새로 정의하지 않는다.

### 6.3 Adapter Boundary
외부 시스템 연동은 가능한 한 adapter 뒤에 둔다.

예:
- API client
- storage client
- analytics helper
- date/time provider
- browser capability helper

금지:
- 여러 컴포넌트가 같은 endpoint shape를 직접 해석
- 여러 화면이 localStorage key를 제각각 직접 만짐

---

## 7. List / Rendering Rules
- key는 안정 식별자를 사용한다.
- index key는 리스트가 완전히 정적일 때만 허용한다.
- 조건부 렌더링은 읽기 쉬운 형태를 유지한다.
- 중첩 삼항으로 화면 상태를 표현하지 않는다.
- 렌더링 중 데이터 변경, 로그 전송, 네비게이션 같은 부작용을 실행하지 않는다.

---

## 8. Form Rules
- 폼 입력값은 사용자가 편집하는 데이터만 state로 둔다.
- 검증 결과, 에러 메시지, submit 가능 여부는 가능한 한 계산으로 표현한다.
- 제출 로직과 필드 포맷팅 로직을 한 함수에 섞지 않는다.
- 서버 에러와 클라이언트 검증 에러를 구분한다.

---

## 9. Naming Rules
- 이름은 역할과 책임을 드러내야 한다.
- `data`, `util`, `handler`, `temp`, `common` 같은 모호한 이름 남용 금지
- UI 컴포넌트 이름은 화면 의미를 드러낸다.
- Hook 이름은 `use`로 시작하고, 무엇을 캡슐화하는지 드러내야 한다.
- 변환 함수는 입력을 무엇으로 바꾸는지 드러내야 한다.

---

## 10. Testing Rules
### 10.1 Pure Logic
아래는 순수 함수 단위 테스트 대상으로 본다.
- 정규화
- 검증
- 매핑
- 필터링
- 집계
- transition function
- reducer

### 10.2 UI
UI 테스트는 구현 디테일보다 행동을 본다.

우선 검증:
- 사용자 입력
- 클릭 / 제출
- 상태 표시
- 에러 메시지
- loading / empty / success 화면 전환

### 10.3 Async
비동기 검증에서는 아래를 빠뜨리지 않는다.
- 취소 가능성
- stale result 무시
- 에러 처리
- retry / timeout
- unmount 이후 setState 방지

### 10.4 DoD for frontend test
프론트엔드 변경에서 아래 중 관련 항목은 반드시 검토한다.
- Hook dependency
- cleanup
- request cancellation
- stable key
- loading / error / empty
- 파생 상태 중복 저장 여부
- effect boundary 누수 여부

---

## 11. Frontend Review Fail Conditions
아래 중 하나라도 해당하면 reviewer는 fail을 우선 검토한다.

- props/state 중복 저장
- 계산 가능한 파생값 저장
- render 중 부작용
- effect dependency 누락
- cleanup 누락
- cancellation 필요한 요청에 방어 없음
- API / storage / timer / browser 접근이 UI에 직접 노출
- reducer가 필요한 복잡한 상태를 ad-hoc setState로 처리
- shared mutable state
- index key 남용
- loading / error / empty 중 필요한 상태 누락
- 테스트 가능한 순수 로직 분리가 가능한데 하지 않음

---

## 12. Definition of Done for `src/`
`src/` 변경은 아래를 만족해야 완료로 본다.

- UI / 순수 변환 / 상태 전이 / 부작용 경계가 뒤섞이지 않았다.
- 파생 상태를 불필요하게 저장하지 않았다.
- 필요한 effect cleanup / cancellation / dependency 처리가 있다.
- 변경된 동작에 필요한 loading / error / empty / success 경로를 검토했다.
- 외부 연동은 경계 뒤에 있다.
- 테스트 가능한 순수 단위가 분리되어 있다.
- 루트 `AGENTS.md`의 DoD / Handoff Ready / Final Report Format을 함께 만족한다.
