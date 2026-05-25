#!/usr/bin/env bash
# scripts/bootstrap.sh
# First-time setup for this dotfiles repo. Safe to re-run.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

# ── colors ────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  CYAN='\033[0;36m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
  RED='\033[0;31m' BOLD='\033[1m' RESET='\033[0m'
  DIM='\033[2m'
else
  CYAN='' GREEN='' YELLOW='' RED='' BOLD='' RESET='' DIM=''
fi

info() { echo -e "  ${CYAN}${BOLD}→${RESET}  $*"; }
success() { echo -e "  ${GREEN}${BOLD}✓${RESET}  $*"; }
warn() { echo -e "  ${YELLOW}${BOLD}⚠${RESET}  $*"; }
error() {
  echo -e "  ${RED}${BOLD}✗${RESET}  $*" >&2
  exit 1
}
section() { echo -e "\n${BOLD}$*${RESET}"; }
dim() { echo -e "  ${DIM}$*${RESET}"; }

# ── preflight ─────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${CYAN}Dotfiles Bootstrap${RESET}  ${DIM}${DOTFILES_DIR}${RESET}"
echo -e "${DIM}────────────────────────────────────────${RESET}"

command -v git &>/dev/null || error "git is required but not installed"
command -v hostnamectl &>/dev/null || error "hostnamectl is required but not installed"

HOST=$(hostnamectl hostname)
HOST_DIR="hosts/${HOST}"
SHARED="$DOTFILES_DIR/shared"

# ── git hooks ─────────────────────────────────────────────────────────────────
section "Git"
info "Configuring hooks path → .githooks/"
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
chmod +x scripts/*.sh
success "Hooks and scripts ready"

# ── host directory ────────────────────────────────────────────────────────────
section "Host  ${DIM}(${HOST})${RESET}"
if [[ -d "$HOST_DIR" ]]; then
  warn "Directory already exists: ${HOST_DIR}"
else
  info "Scaffolding ${HOST_DIR}/"
  mkdir -p "${HOST_DIR}/hypr/conf" "${HOST_DIR}/waybar"

  cat >"${HOST_DIR}/hypr/hyprland.conf" <<'HYPR'
# ── Shared ────────────────────────────────────────────────────────────────────
source = $HOME/dotfiles/shared/hypr/hyprland.conf

# ── Machine-specific ──────────────────────────────────────────────────────────
source = ./conf/env.conf
source = ./conf/monitors.conf
HYPR

  cat >"${HOST_DIR}/hypr/conf/env.conf" <<'ENV'
# Machine-specific environment variables
# env = HOSTNAME, your-hostname
ENV

  cat >"${HOST_DIR}/hypr/conf/monitors.conf" <<'MON'
# Monitor layout for this machine
# See: https://wiki.hyprland.org/Configuring/Monitors/
#
# monitor = DP-1,  2560x1440@144, 0x0,    1
# monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
MON

  cat >"${HOST_DIR}/waybar/config.jsonc" <<'WB'
// Machine-specific waybar overrides
// Useful for: battery, backlight, or interface modules unique to this machine
{}
WB

  success "Scaffolded ${HOST_DIR}/"
fi

# ── symlinks ──────────────────────────────────────────────────────────────────
section "Symlinks  ${DIM}(~/.config/)${RESET}"

link() {
  local src="$1" dst="$2"
  ln -sfn "$src" "$dst"
  success "$(basename "$dst")  ${DIM}→ ${src#"$HOME/"}${RESET}"
}

# shared
link "$SHARED/elephant" "$HOME/.config/elephant"
link "$SHARED/gtk-3.0" "$HOME/.config/gtk-3.0"
link "$SHARED/gtk-4.0" "$HOME/.config/gtk-4.0"
link "$SHARED/hyprland-autoname-workspaces" "$HOME/.config/hyprland-autoname-workspaces"
link "$SHARED/kitty" "$HOME/.config/kitty"
link "$SHARED/nvim" "$HOME/.config/nvim"
link "$SHARED/walker" "$HOME/.config/walker"
link "$SHARED/waybar" "$HOME/.config/waybar"
link "$SHARED/starship.toml" "$HOME/.config/starship.toml"
link "$SHARED/yazi" "$HOME/.config/yazi"

# host-specific
link "$DOTFILES_DIR/$HOST_DIR/hypr" "$HOME/.config/hypr"

# ── done ──────────────────────────────────────────────────────────────────────
echo -e "\n${GREEN}${BOLD}All done!${RESET}\n"

if [[ ! -s "${HOST_DIR}/hypr/conf/monitors.conf" ]] ||
  grep -q "^#" "${HOST_DIR}/hypr/conf/monitors.conf" 2>/dev/null &&
  ! grep -qv "^#\|^$" "${HOST_DIR}/hypr/conf/monitors.conf" 2>/dev/null; then
  echo -e "${YELLOW}${BOLD}Action required:${RESET}"
  dim "1. Edit ${HOST_DIR}/hypr/conf/env.conf     — set HOSTNAME"
  dim "2. Edit ${HOST_DIR}/hypr/conf/monitors.conf — set display layout"
  dim "3. Run: hyprctl reload"
  echo
fi
