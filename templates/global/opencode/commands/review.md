---
description: 현재 변경분을 reviewer strict gate로 리뷰한다
agent: reviewer
subtask: true
---

현재 변경분을 엄격하게 리뷰해.

추가 맥락:
$ARGUMENTS

현재 변경 파일:
!`git diff --name-only`

현재 diff stat:
!`git diff --stat`

반드시 아래 기준을 따른다.
- AGENTS.md의 공통 규칙
- reviewer 에이전트 규칙
- AGENTS.md 7.1 Handoff Ready
- AGENTS.md 7.2 Final Report Format

리뷰는 실제 diff와 변경 파일 기준으로만 수행한다.
출력은 reviewer 형식을 그대로 사용한다.
