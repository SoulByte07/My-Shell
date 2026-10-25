# ==============================================================================
# File: .zshenv
# Description: Environment variables and core path definitions for Zsh.
# Lifecycle: Loaded FIRST on EVERY invocation (interactive, login, and scripts).
# ==============================================================================

# --- 1. XDG Base Directory Specification ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Location of Zsh configuration files
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# --- 2. Default Programs ---
if (( $+commands[nvim] )); then
    export EDITOR="nvim"
    export VISUAL="nvim"
elif (( $+commands[vim] )); then
    export EDITOR="vim"
    export VISUAL="vim"
else
    export EDITOR="nano"
    export VISUAL="nano"
fi

# Ensure default shell is set
export SHELL="${SHELL:-$(command -v zsh 2>/dev/null || echo /bin/zsh)}"

# Pager configuration (prioritizes modern pagers if installed)
if (( $+commands[moor] )); then
    export PAGER="moor"
    export MANPAGER="moor"
    export MOOR="--statusbar=bold --style=catppuccin-mocha"
elif (( $+commands[bat] )); then
    export PAGER="bat --plain"
    export MANPAGER="bat -l man -p"
else
    export PAGER="less"
    export MANPAGER="less"
fi

# --- 3. PATH Deduplication & Assembly ---
# Keeps PATH array unique (no duplicate entries)
typeset -U path PATH

# Add language runtimes and local binaries to PATH if directories exist
local -a candidate_paths=(
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "${CARGO_HOME:-$HOME/.cargo}/bin"
    "${BUN_INSTALL:-$HOME/.bun}/bin"
    "$XDG_DATA_HOME/pnpm/bin"
)

for p in "${candidate_paths[@]}"; do
    [[ -d "$p" ]] && path=("$p" $path)
done

# Source Cargo environment if present and not already sourced
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Filter out non-existent directories from PATH
path=($^path(N))

# --- 4. Local Environment Overrides ---
# Load optional machine-specific or private environment overrides
[[ -f "$ZDOTDIR/.zshenv.local" ]] && source "$ZDOTDIR/.zshenv.local"
[[ -f "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"
