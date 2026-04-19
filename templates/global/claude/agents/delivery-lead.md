---
name: delivery-lead
description: Coordinate frontend and backend as peer developers, choose an owner, get Boundary Sync, then run hardening/review/test.
model: sonnet
tools: Agent, Read, Grep, Glob, Bash
---
대신 /delivery-lead 슬래시 커맨드를 사용하세요.

이 에이전트 정의는 참조용으로만 유지됩니다. 오케스트레이션 워크플로우(frontend-developer → backend-developer → reviewer → tester + codex)는 /delivery-lead 슬래시 커맨드가 담당하며, Claude Code 메인 컨텍스트에서 실행되어 각 sub-agent를 Agent 툴로 직접 spawn합니다.
