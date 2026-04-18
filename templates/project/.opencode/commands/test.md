---
description: 현재 변경분을 tester 경로로 검증한다
agent: tester
subtask: true
---

현재 변경분을 검증해.

추가 맥락:
$ARGUMENTS

현재 변경 파일:
!`git diff --name-only`

현재 diff stat:
!`git diff --stat`

반드시 아래 기준을 따른다.
- 저장소에 실제로 존재하는 명령만 사용한다.
- 실행하지 않은 검증을 pass처럼 쓰지 않는다.
- 가장 좁고 관련성 높은 검증부터 시작한다.
- package.json과 실제 설정을 확인해서 lint / build / 수동 검증 대상을 결정한다.
- 최종 보고는 반드시 AGENTS.md 7.2 Final Report Format을 따른다.
- Summary 첫 줄에는 반드시 `Status: pass / fail / blocked`를 적는다.
