#!/usr/bin/env bash
# scripts/bootstrap.sh — first-time setup for this dotfiles repo
#
# What it does:
#   1. Installs the .githooks directory as the repo's hook path
#   2. Creates a hosts/<hostname>/ directory if one doesn't exist yet
#   3. Prints next steps
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${CYAN}${BOLD}=>${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }
warn() { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }

# ── 1. wire up git hooks ──────────────────────────────────────────────────────
info "Configuring git hooks path → .githooks/"
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
success "Hooks installed"

# ── 2. make scripts executable ────────────────────────────────────────────────
chmod +x scripts/*.sh
success "Scripts marked executable"

# ── 3. scaffold host-specific directory ───────────────────────────────────────
HOST=$(hostname -s)
HOST_DIR="hosts/${HOST}"

if [[ -d "$HOST_DIR" ]]; then
  warn "Host directory already exists: ${HOST_DIR}"
else
  info "Creating host directory: ${HOST_DIR}"

  # Mirror the same structure as shared/ so overrides are easy to find
  mkdir -p \
    "${HOST_DIR}/hypr/conf" \
    "${HOST_DIR}/waybar"

  # hyprland.conf stub — source shared first, then override
  cat >"${HOST_DIR}/hypr/hyprland.conf" <<'HYPR'
# host-specific hyprland overrides for this machine
# This file is sourced AFTER shared/hypr/hyprland.conf

# Example: override monitor layout for this machine
# source = ~/.config/dotfiles/hosts/HOSTNAME/hypr/conf/monitors.conf
HYPR

  # monitors.conf stub
  cat >"${HOST_DIR}/hypr/conf/monitors.conf" <<'MON'
# monitors.conf — edit for this machine's display layout
# See: https://wiki.hyprland.org/Configuring/Monitors/
#
# Example:
# monitor = DP-1, 2560x1440@144, 0x0, 1
# monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
MON

  # waybar config stub
  cat >"${HOST_DIR}/waybar/config.jsonc" <<'WB'
// waybar host overrides — merged on top of shared/waybar/config.jsonc
// Useful for: different module sets per machine, battery module on laptop, etc.
{}
WB

  success "Host directory scaffolded: ${HOST_DIR}"
fi

# ── 4. summary ────────────────────────────────────────────────────────────────
echo
echo -e "${BOLD}All set! Here's what was configured:${RESET}"
echo -e "  • Git hooks:  ${CYAN}.githooks/pre-commit${RESET} runs on every commit"
echo -e "  • Sync:       ${CYAN}./scripts/sync.sh${RESET} to stage → commit → push"
echo -e "  • Host dir:   ${CYAN}${HOST_DIR}/${RESET} for ${HOST}-specific overrides"
echo -e "  • CI:         ${CYAN}.github/workflows/ci.yml${RESET} validates on push"
echo
echo -e "${BOLD}Multi-machine pattern:${RESET}"
echo "  shared/           — configs that apply everywhere"
echo "  hosts/<hostname>/ — machine-specific overrides"
echo
echo -e "  In your hyprland.conf, add at the bottom:"
echo -e "  ${CYAN}source = \$HOME/.config/dotfiles/hosts/\$(hostname -s)/hypr/hyprland.conf${RESET}"
