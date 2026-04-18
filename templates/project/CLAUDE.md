# 공통 엔지니어링 규칙

## 사고 순서
항상 문제를 아래 네 층으로 나누어 생각한다.

1. 입력 정규화
2. 순수 변환
3. 상태 전이
4. 부작용 실행

## 핵심 원칙
- 계산, 검증, 정규화, 매핑, 필터링, 집계는 가능한 한 순수 함수로 분리한다.
- 부작용은 경계에서만 수행한다.
- 불변성을 기본값으로 삼는다.
- 상태는 최소화한다.
- 파생 데이터는 저장하지 말고 계산으로 표현한다.
- 숨은 전역 상태와 암묵적 의존성을 만들지 않는다.
- 상태 변화는 명시적 전이로 표현한다.
- 상속보다 합성을 우선한다.
- 최적화보다 예측 가능성과 변경 용이성을 우선한다.
- 변경은 작고 안전하며 되돌리기 쉬워야 한다.
- 가능하면 리팩토링과 동작 변경을 분리한다.
- 중요한 변경은 정상 경로뿐 아니라 반례, 경계 조건, 실패 경로로도 검토한다.
- 요구사항이 애매하거나 상태 전이가 복잡한 경우, 숨은 가정을 먼저 드러낸다.

## JavaScript / React 규칙
- 상태는 단일 출처를 유지한다.
- 파생 상태 저장을 피한다.
- Hook 의존성 배열은 완전해야 한다.
- 렌더링, 변환, effect를 분리한다.
- 네트워크, 스토리지, 타이머, 브라우저 API는 경계 계층 뒤에 둔다.
- 장수 effect에는 cleanup을 둔다.
- 필요한 경우 요청 취소를 고려한다.
- index key는 정말 정적인 리스트가 아니면 피한다.
- 메모이제이션은 측정 이후에만 적용한다.

## Backend / Contract 규칙
- API 계약은 shape, 필드 의미, 실패 모델을 먼저 정의한다.
- validation / auth / permission / system error는 가능하면 구분해서 다룬다.
- retry / timeout / dedupe / idempotency가 필요한지 먼저 판단한다.
- I/O, DB, 외부 API, storage는 경계 계층에 격리한다.
- backward compatibility가 필요한 변경은 먼저 드러낸다.
- frontend convenience만으로 계약을 고정하지 않는다.
- backend convenience만으로 UX를 무시하지 않는다.

## Cross-boundary 규칙
- frontend와 backend가 함께 바뀌는 작업은 owner를 하나만 정한다.
- 다른 한쪽은 peer boundary review를 수행한다.
- Boundary Sync: pass 전에는 공통 게이트로 넘기지 않는다.

## 변경 정책
- 실제 코드와 설정을 먼저 확인한다.
- 기존 패턴을 함부로 깨지 않는다.
- 범위가 커지면 먼저 보고한다.
- 설명은 짧고 구조화해서 한다.

## 프로젝트 명령
- 설치: npm install
- 개발 서버: npm run dev
- lint: npm run lint
- 빌드: npm run build
- 프로덕션 실행: npm start
- 테스트: 현재 package.json에 test 스크립트가 없다. 테스트가 필요하면 수동 검증을 수행하고, 반복 검증이 필요하면 테스트 추가를 먼저 제안한다.

## 프로젝트 사실
- 이 저장소는 Next.js App Router 기반이다.
- TypeScript strict 모드가 켜져 있다.
- React Strict Mode가 켜져 있다.
- 기본 개발 서버 확인 주소는 http://localhost:3000 이다.

## 작업 시 주의
- npm test를 가정하지 않는다.
- 테스트 자동화가 없으면 반드시 수동 검증 항목을 구체적으로 적는다.
- 빌드나 라우팅에 영향이 있는 변경은 npm run build 검토를 우선한다.
- lint로 잡히는 문제는 merge 전 해결을 기본값으로 본다.
