export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ENABLE_CORRECTION="true"
plugins=(git command-not-found zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete you-should-use fzf sudo archlinux copypath dirhistory)
source $ZSH/oh-my-zsh.sh

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# ls replacements
alias ls="eza -F --icons --color=always --group-directories-first"
alias ll="eza -lF --icons --color=always --group-directories-first"
alias tree="eza -TF --icons --color=always --group-directories-first"

# Utility
alias zshconfig="nv ~/.zshrc"
alias nvconfig="nv ~/.config/nvim"
alias pacinstall="sudo pacman -S"
alias pacremove="sudo pacman -R"
alias pacupdate="sudo pacman -Syu"
alias ssh-startup='eval "$(ssh-agent -s)"'
alias nv="nvim"
alias reload="source ~/.zshrc"
alias icat="kitten icat"
alias home="cd ~"
alias top="btop"
alias brightness="brightnessctl set"

# Hyprshot
export HYPRSHOT_DIR="$HOME/Imagens/Screenshots/"

# Java
export _JAVA_AWT_WM_NONREPARENTING=1
wmname LG3D

# Yazi
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# Prompt & tools
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Telling go to GO fuck off somewhere else
export GOPATH="$HOME/.local/share/go"
