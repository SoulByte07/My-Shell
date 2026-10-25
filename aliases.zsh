# ==============================================================================
# File: aliases.zsh
# Description: Global command shortcuts, modern CLI tool replacements,
#              directory navigation, package manager aliases, and suffix rules.
# ==============================================================================

# --- 1. Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- 2. Modern CLI Replacements ---
# Neovim as default editor
alias v='nvim'

# Modern file manager (Yazi)
if (( $+commands[yazi] )); then
    alias f='yazi'
elif (( $+commands[lf] )); then
    alias f='lf'
fi

# Modern 'ls' using eza (with icons and directory grouping)
if (( $+commands[eza] )); then
    alias l='eza --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias ll='eza -lh --icons --git --group-directories-first'
    alias lla='eza -lah --icons --git --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
    alias ld='eza -D --icons'
else
    alias l='ls -F --color=auto'
    alias la='ls -A --color=auto'
    alias ll='ls -lh --color=auto'
    alias lla='ls -lah --color=auto'
fi

# Lazygit
alias lg='lazygit'

# Fastfetch
alias ff='fastfetch'

# Chezmoi (Dotfiles manager)
alias cz='chezmoi'

# Distrobox
alias db='distrobox'

# --- 3. Safety & Usability Guards ---
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ping='ping -c 5'
alias c='clear'
alias cx='chmod +x'

# Quick sudo make install
alias smci='sudo make clean install'

# Neovim pager / quick viewer
alias nv='nvim - -c "nnoremap q :q!<CR>"'

# --- 4. Cross-Platform Clipboard Copy ---
if (( $+commands[wl-copy] )); then
    alias cf='wl-copy <'
elif (( $+commands[xclip] )); then
    alias cf='xclip -selection clipboard <'
elif (( $+commands[pbcopy] )); then
    alias cf='pbcopy <'
fi

# --- 5. Git Shortcuts ---
alias gpl='git pull'
alias gph='git push'

# --- 6. Document Viewer ---
alias pdf='zathura'

# --- 7. Package Management (Arch Linux / Paru) ---
if (( $+commands[pacman] )); then
    alias pss='pacman -Ss'
    alias pqs='pacman -Qs'
    alias psi='sudo pacman -S --needed'
    alias psyu='sudo pacman -Syu'
    alias prns='sudo pacman -Rns'
fi

if (( $+commands[paru] )); then
    alias yss='paru -Ss'
    alias ysi='paru -S'
    alias yrns='paru -Rns'
fi

# --- 8. Zsh Maintenance & Bytecode Cache ---
alias zsh-update-cache='rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/tools" && zsh-compile && exec zsh'
alias zc='zsh-compile'

# --- 9. Suffix Aliases (Open files directly with associated viewer/editor) ---
alias -s {go,py,md,conf,yaml,yml,json,xml,toml,ini}='$EDITOR'

if (( $+commands[bat] )); then
    alias -s {txt,log}=bat
else
    alias -s {txt,log}='$EDITOR'
fi

# --- 10. Local Aliases ---
# Load optional machine-specific aliases (untracked by git)
[[ -f "$ZDOTDIR/aliases.local.zsh" ]] && source "$ZDOTDIR/aliases.local.zsh"
