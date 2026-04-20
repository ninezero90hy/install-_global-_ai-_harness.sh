#!/usr/bin/env bash
# install.sh
# Global AI Harness 설치 스크립트.
# agents/ 이하의 모든 .md 파일을 ~/.claude/agents/ 로 flat 복사하고,
# global/CLAUDE.md 를 ~/.claude/CLAUDE.md 로 설치한다.
#
# 동작:
# - 기본은 안전 설치 (기존 파일은 타임스탬프 백업 후 덮어쓰기).
# - --dry-run  : 실제 복사 없이 어떤 파일이 바뀔지만 출력.
# - --force    : 백업 없이 즉시 덮어쓰기.
# - --no-claude-md : ~/.claude/CLAUDE.md 설치를 건너뛴다.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_AGENTS_DIR="${SCRIPT_DIR}/agents"
SRC_GLOBAL_CLAUDE_MD="${SCRIPT_DIR}/global/CLAUDE.md"

CLAUDE_HOME="${CLAUDE_HOME:-${HOME}/.claude}"
DEST_AGENTS_DIR="${CLAUDE_HOME}/agents"
DEST_CLAUDE_MD="${CLAUDE_HOME}/CLAUDE.md"

DRY_RUN=0
FORCE=0
INSTALL_CLAUDE_MD=1

log()  { printf "[install] %s\n" "$*"; }
warn() { printf "[install][warn] %s\n" "$*" >&2; }
die()  { printf "[install][error] %s\n" "$*" >&2; exit 1; }

for arg in "$@"; do
  case "$arg" in
    --dry-run)       DRY_RUN=1 ;;
    --force)         FORCE=1 ;;
    --no-claude-md)  INSTALL_CLAUDE_MD=0 ;;
    -h|--help)
      cat <<EOF
Usage: install.sh [--dry-run] [--force] [--no-claude-md]

  --dry-run        실제 복사 없이 계획만 출력
  --force          기존 파일 백업 없이 덮어쓰기
  --no-claude-md   ~/.claude/CLAUDE.md 설치 건너뛰기

환경 변수:
  CLAUDE_HOME      Claude 설정 루트 (기본: \$HOME/.claude)
EOF
      exit 0 ;;
    *) die "알 수 없는 옵션: ${arg}" ;;
  esac
done

[[ -d "${SRC_AGENTS_DIR}" ]] || die "소스 agents 디렉터리가 없습니다: ${SRC_AGENTS_DIR}"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${CLAUDE_HOME}/backups/harness-${TIMESTAMP}"

ensure_dir() {
  local d="$1"
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log "[dry-run] mkdir -p ${d}"
    return
  fi
  mkdir -p "${d}"
}

backup_if_exists() {
  local target="$1"
  [[ -e "${target}" ]] || return 0
  if [[ "${FORCE}" -eq 1 ]]; then
    log "force: ${target} (백업 없이 덮어씀)"
    return 0
  fi
  ensure_dir "${BACKUP_DIR}"
  local rel="${target#${CLAUDE_HOME}/}"
  local dest="${BACKUP_DIR}/${rel}"
  ensure_dir "$(dirname "${dest}")"
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log "[dry-run] backup ${target} -> ${dest}"
    return 0
  fi
  cp -p "${target}" "${dest}"
  log "backup: ${target} -> ${dest}"
}

copy_file() {
  local src="$1" dest="$2"
  backup_if_exists "${dest}"
  ensure_dir "$(dirname "${dest}")"
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    log "[dry-run] cp ${src} -> ${dest}"
    return
  fi
  cp "${src}" "${dest}"
  log "install: ${dest}"
}

install_agents() {
  ensure_dir "${DEST_AGENTS_DIR}"
  # agents/ 이하 모든 .md 를 flat 으로 복사. 같은 basename 충돌 시 경고.
  local -a files=()
  while IFS= read -r -d '' f; do
    files+=("${f}")
  done < <(find "${SRC_AGENTS_DIR}" -type f -name "*.md" -print0)

  [[ "${#files[@]}" -gt 0 ]] || die "복사할 에이전트 파일이 없습니다."

  # basename 충돌 사전 검사
  local -a seen=()
  for f in "${files[@]}"; do
    local base
    base="$(basename "${f}")"
    for s in "${seen[@]:-}"; do
      [[ "${s}" == "${base}" ]] && die "중복된 에이전트 파일명: ${base}"
    done
    seen+=("${base}")
  done

  for f in "${files[@]}"; do
    copy_file "${f}" "${DEST_AGENTS_DIR}/$(basename "${f}")"
  done
}

install_claude_md() {
  [[ "${INSTALL_CLAUDE_MD}" -eq 1 ]] || { log "skip ~/.claude/CLAUDE.md (--no-claude-md)"; return; }
  [[ -f "${SRC_GLOBAL_CLAUDE_MD}" ]] || { warn "source CLAUDE.md 없음: ${SRC_GLOBAL_CLAUDE_MD}"; return; }
  ensure_dir "${CLAUDE_HOME}"
  copy_file "${SRC_GLOBAL_CLAUDE_MD}" "${DEST_CLAUDE_MD}"
}

main() {
  log "CLAUDE_HOME = ${CLAUDE_HOME}"
  [[ "${DRY_RUN}" -eq 1 ]] && log "mode: dry-run"
  [[ "${FORCE}"   -eq 1 ]] && log "mode: force (no backup)"
  install_agents
  install_claude_md
  log "완료."
}

main "$@"
