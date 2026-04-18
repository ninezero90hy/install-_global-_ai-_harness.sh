---
description: 크로스바운더리 작업을 delivery-lead 경로로 실행한다
agent: delivery-lead
subtask: true
---

다음 요청을 `delivery-lead` 경로로 처리해.

요청:
$ARGUMENTS

반드시 아래 순서를 따른다.
1. 이 작업이 frontend / backend 경계 작업인지 판단한다.
2. 작업 owner를 하나만 정한다.
   - Owner: frontend
   - Owner: backend
3. owner가 초안과 경계 제안을 만든다.
4. 다른 한쪽 developer가 peer boundary review를 한다.
5. 아래 둘 중 하나로 정리한다.
   - Boundary Sync: pass
   - Boundary Sync: revision-needed
6. Boundary Sync: revision-needed이면 owner가 수정하고 다시 sync를 수행한다.
7. Boundary Sync: pass 전에는 다음 단계로 넘기지 않는다.
8. Boundary Sync: pass 이후에만 아래 순서로 진행한다.
   - devils-advocate
   - reviewer
   - tester
9. 최종 보고는 반드시 AGENTS.md 7.2 Final Report Format을 따른다.
10. AGENTS.md 7.1 Handoff Ready를 만족하지 못하면 완료로 선언하지 않는다.
