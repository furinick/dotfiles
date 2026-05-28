#!/usr/bin/env bash
# scripts/install-packages.sh
# Installs all packages for this dotfiles setup.
# Requires: pacman (system), yay (AUR)
set -euo pipefail

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

# ── preflight ─────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${CYAN}Package Installation${RESET}"
echo -e "${DIM}────────────────────────────────────────${RESET}"

command -v pacman &>/dev/null || error "pacman not found — are you on Arch?"
command -v yay &>/dev/null || error "yay not found — install it first: https://github.com/Jguer/yay"

# ── package lists ─────────────────────────────────────────────────────────────

PACMAN_PACKAGES=(
  # Hyprland ecosystem
  hyprland
  hyprland-protocols
  hyprland-qt-support
  hypridle
  hyprlock
  hyprpaper
  hyprpicker
  hyprpolkitagent
  hyprshot
  hyprsunset
  uwsm
  xdg-desktop-portal-hyprland
  xdg-utils

  # Wayland / display
  qt5-wayland
  qt5ct
  qt6-wayland
  grim
  slurp
  cliphist
  brightnessctl
  nwg-look
  swaync
  waybar
  wofi

  # Terminal & shell
  kitty
  zsh
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
  zsh-autocomplete

  # Editor & dev
  neovim
  python-pynvim
  stylua
  lua51
  tree-sitter-cli
  nodejs
  npm
  cmake
  meson
  git
  lazygit
  tmux

  # CLI tools
  starship
  eza
  fzf
  fd
  btop
  htop
  atuin
  zoxide
  yazi
  tldr
  wget
  imagemagick
  inotify-tools
  wmname
  wev

  # Audio / video
  pipewire
  pipewire-alsa
  pipewire-jack
  pipewire-pulse
  wireplumber
  gst-plugin-pipewire
  libpulse
  pavucontrol

  # Bluetooth
  bluez
  bluez-utils

  # Networking
  networkmanager
  network-manager-applet
  wpa_supplicant

  # Printing
  cups
  cups-pk-helper
  system-config-printer
  ghostscript

  # Apps
  firefox
  flatpak
  libreoffice-fresh
  dolphin
  steam
  gamescope
  vesktop
  pacseek
  sddm
  polkit-kde-agent
  pavucontrol
  gnome-themes-extra
  papirus-icon-theme

  # Fonts
  ttf-dejavu
  ttf-liberation
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra
  ttf-nerd-fonts-symbols
  ttf-nerd-fonts-symbols-mono
  otf-atkinsonhyperlegiblemono-nerd
  otf-aurulent-nerd
  otf-codenewroman-nerd
  otf-comicshanns-nerd
  otf-commit-mono-nerd
  otf-droid-nerd
  otf-firamono-nerd
  otf-geist-mono-nerd
  otf-hasklig-nerd
  otf-hermit-nerd
  otf-monaspace-nerd
  otf-opendyslexic-nerd
  otf-overpass-nerd
  ttf-0xproto-nerd
  ttf-3270-nerd
  ttf-adwaitamono-nerd
  ttf-agave-nerd
  ttf-anonymouspro-nerd
  ttf-arimo-nerd
  ttf-bigblueterminal-nerd
  ttf-bitstream-vera-mono-nerd
  ttf-cascadia-code-nerd
  ttf-cascadia-mono-nerd
  ttf-cousine-nerd
  ttf-d2coding-nerd
  ttf-daddytime-mono-nerd
  ttf-dejavu-nerd
  ttf-envycoder-nerd
  ttf-fantasque-nerd
  ttf-firacode-nerd
  ttf-go-nerd
  ttf-gohu-nerd
  ttf-hack-nerd
  ttf-heavydata-nerd
  ttf-iawriter-nerd
  ttf-ibmplex-mono-nerd
  ttf-inconsolata-go-nerd
  ttf-inconsolata-lgc-nerd
  ttf-inconsolata-nerd
  ttf-intone-nerd
  ttf-iosevka-nerd
  ttf-iosevkaterm-nerd
  ttf-iosevkatermslab-nerd
  ttf-jetbrains-mono-nerd
  ttf-lekton-nerd
  ttf-liberation-mono-nerd
  ttf-lilex-nerd
  ttf-martian-mono-nerd
  ttf-meslo-nerd
  ttf-monofur-nerd
  ttf-monoid-nerd
  ttf-mononoki-nerd
  ttf-mplus-nerd
  ttf-noto-nerd
  ttf-profont-nerd
  ttf-proggyclean-nerd
  ttf-recursive-nerd
  ttf-roboto-mono-nerd
  ttf-sharetech-mono-nerd
  ttf-sourcecodepro-nerd
  ttf-space-mono-nerd
  ttf-terminus-nerd
  ttf-tinos-nerd
  ttf-ubuntu-mono-nerd
  ttf-ubuntu-nerd
  ttf-victor-mono-nerd
  ttf-zed-mono-nerd

  # Misc
  unzip
  zip
  rar
  nano
  vim
  man-db
  smartmontools
  tectonic
  mono
  wine
  wine-mono
  ufw
  snapper
  zram-generator
)

AUR_PACKAGES=(
  hyprland-autoname-workspaces-git
  hyprlauncher
  hyprpwcenter
  hyprshutdown
  walker-bin
  elephant-calc
  elephant-clipboard
  elephant-desktopapplications
  elephant-files
  elephant-runner
  elephant-symbols
  elephant-unicode
  elephant-websearch
  firefoxpwa
  awww
  yay
  yay-debug
  zsh-you-should-use
)

# ── install ───────────────────────────────────────────────────────────────────
section "Pacman packages"
info "Updating system..."
sudo pacman -Syu --noconfirm
info "Installing packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
success "Pacman packages done"

section "AUR packages"
info "Installing AUR packages via yay..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
success "AUR packages done"

# ── post-install ──────────────────────────────────────────────────────────────
section "Post-install"

info "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager
success "NetworkManager enabled"

info "Enabling Bluetooth..."
sudo systemctl enable --now bluetooth
success "Bluetooth enabled"

info "Enabling CUPS..."
sudo systemctl enable --now cups
success "CUPS enabled"

info "Setting zsh as default shell..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
  chsh -s "$(which zsh)"
  success "Default shell set to zsh (re-login to apply)"
else
  success "zsh is already the default shell"
fi

echo -e "\n${GREEN}${BOLD}All packages installed!${RESET}\n"
