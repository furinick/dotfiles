#!/usr/bin/env bash
# scripts/sync.sh — stage, commit, and push dotfiles changes
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

# ── colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${CYAN}${BOLD}=>${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }
warn() { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }
error() {
  echo -e "${RED}${BOLD}✗${RESET} $*" >&2
  exit 1
}

# ── sanity checks ─────────────────────────────────────────────────────────────
command -v git &>/dev/null || error "git not found"
git rev-parse --git-dir &>/dev/null || error "not inside a git repo"

# ── show status ───────────────────────────────────────────────────────────────
info "Current status:"
git status --short

if git diff --quiet && git diff --cached --quiet; then
  success "Nothing to commit — everything is up to date."
  exit 0
fi

echo

# ── staging ───────────────────────────────────────────────────────────────────
echo -e "${BOLD}How do you want to stage changes?${RESET}"
echo "  [a] Stage all"
echo "  [p] Stage interactively (git add -p)"
echo "  [q] Quit"
echo -n "Choice: "
read -r stage_choice

case "$stage_choice" in
a | A)
  git add -A
  success "Staged all changes."
  ;;
p | P) git add -p ;;
q | Q)
  info "Aborted."
  exit 0
  ;;
*) error "Unknown choice." ;;
esac

# bail if nothing ended up staged
if git diff --cached --quiet; then
  warn "Nothing staged — aborting."
  exit 0
fi

echo
info "Staged diff summary:"
git diff --cached --stat

# ── commit message ────────────────────────────────────────────────────────────
echo
echo -n "Commit message (leave blank for default): "
read -r msg

if [[ -z "$msg" ]]; then
  # auto-generate from changed paths
  changed=$(git diff --cached --name-only | awk -F/ '{print $1"/"$2}' | sort -u | paste -sd ', ')
  msg="chore: update ${changed}"
  info "Using: \"${msg}\""
fi

git commit -m "$msg"
success "Committed."

# ── push ──────────────────────────────────────────────────────────────────────
echo
BRANCH=$(git symbolic-ref --short HEAD)
echo -n "Push to origin/${BRANCH}? [Y/n] "
read -r push_choice

if [[ "${push_choice,,}" != "n" ]]; then
  git push origin "$BRANCH"
  success "Pushed to origin/${BRANCH}."
else
  info "Skipped push."
fi
