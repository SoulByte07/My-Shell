# ==============================================================================
# File: options.zsh
# Description: Zsh shell options, history configuration, RAM-based completion,
#              FZF environment defaults, and fzf-tab interactive styling.
# ==============================================================================

# ==========================================
# 1. History Configuration
# ==========================================
fpath=($^fpath(N-/))
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"

setopt SHARE_HISTORY             # Share history concurrently across all open terminals 
setopt HIST_IGNORE_ALL_DUPS      # Delete older duplicate entries from history
setopt HIST_IGNORE_SPACE         # Do not record entries starting with a blank space
setopt HIST_REDUCE_BLANKS        # Clean up superfluous whitespace before saving
setopt INC_APPEND_HISTORY        # Append entries immediately rather than on exit
setopt EXTENDED_HISTORY          # Record timestamp and command duration
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming
setopt HIST_FIND_NO_DUPS         # Do not display duplicates when searching history
setopt AUTO_CD                   # Change directory by typing its path without 'cd'
setopt AUTO_PUSHD                # Automatically push old directory to directory stack
setopt PUSHD_IGNORE_DUPS         # Don't store duplicate directories in directory stack
setopt INTERACTIVE_COMMENTS      # Allow comments (#) in interactive shell command lines
setopt NO_BEEP                   # Disable bell audio on errors
setopt HASH_CMDS                 # Cache command locations in hash table for instant lookup

# ==========================================
# 2. RAM-Optimized Completion Setup
# ==========================================
# Prefer RAM ($XDG_RUNTIME_DIR) on host for fastest possible completion parsing,
# falling back to cache directory or /tmp
setopt EXTENDED_GLOB
local zdump_dir
if [[ -n "$XDG_RUNTIME_DIR" && -d "$XDG_RUNTIME_DIR" && -w "$XDG_RUNTIME_DIR" ]]; then
  zdump_dir="$XDG_RUNTIME_DIR"
elif [[ -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" ]]; then
  zdump_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
else
  zdump_dir="/tmp"
fi
local ZDUMP="$zdump_dir/.zcompdump-$HOST-$ZSH_VERSION"

autoload -Uz compinit

# Regenerate completion dump only if older than 24 hours
if [[ -s "$ZDUMP" && -n "$ZDUMP"(#qN.m-1) ]]; then
  compinit -C -d "$ZDUMP"
else
  compinit -i -d "$ZDUMP"
  zcompile "$ZDUMP"
fi

zmodload zsh/complist

# Persistent completion cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# ==========================================
# 3. FZF Global Options & Theme (Catppuccin Mocha)
# ==========================================
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
fi

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--pointer='▌' --prompt='❯ ' --marker='✔ '"

# ==========================================
# 4. fzf-tab Interactive Menu Behavior
# ==========================================
# Disable traditional menu completion so fzf-tab captures completion candidates
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format $'\e[01;35m[%d]\e[0m'

zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# Rounded borders, custom pointer, and padding
zstyle ':fzf-tab:*' fzf-flags --border=rounded --pointer='▌'
zstyle ':fzf-tab:*' fzf-pad 6

# Preview directory content with eza (or ls) when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'if (( $+commands[eza] )); then eza -1 --color=always "$realpath"; else ls -1 --color=always "$realpath"; fi'

# Switch groups with [ and ]
zstyle ':fzf-tab:*' switch-group '[' ']'

# Group heading color sequence
zstyle ':fzf-tab:*' group-colors \
    $'\e[31m' $'\e[32m' $'\e[33m' $'\e[34m' $'\e[35m' $'\e[36m'

# ==========================================
# 5. fzf-tab Dynamic Previews
# ==========================================
# Environment variables preview
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'

# Process kill preview
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid="$word" -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags --preview-window=down:3:wrap

# Systemctl status preview
if (( $+commands[systemctl] )); then
    zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'systemctl status "$word" 2>/dev/null'
fi

# Help & Manual page previews
zstyle ':fzf-tab:complete:(\\|)run-help:*' fzf-preview 'run-help "$word"'
zstyle ':fzf-tab:complete:(\\|)man:*' fzf-preview 'man "$word"'

# Git command completions with diff/log previews
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff "$word" | delta 2>/dev/null || git diff "$word"'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always "$word"'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview 'git help "$word" | bat -plman --color=always 2>/dev/null || man "$word"'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	'case "$group" in
	"commit tag") git show --color=always "$word" ;;
	*) git show --color=always "$word" | delta 2>/dev/null || git show --color=always "$word" ;;
	esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
	'case "$group" in
	"modified file") git diff "$word" | delta 2>/dev/null || git diff "$word" ;;
	"recent commit object name") git show --color=always "$word" | delta 2>/dev/null || git show --color=always "$word" ;;
	*) git log --color=always "$word" ;;
	esac'
