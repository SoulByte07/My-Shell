# ==============================================================================
# File: .zshrc
# Description: Main interactive shell configuration.
# Lifecycle: Loaded on interactive shell startups. Coordinates prompt, tools,
#            modular components, theme, and bytecode compilation.
# ==============================================================================

# --- 1. Powerlevel10k Instant Prompt ---
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else goes below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Ensure ZDOTDIR is defined
ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"

# --- 2. Source Modular Components ---
[[ -f "$ZDOTDIR/options.zsh" ]]   && source "$ZDOTDIR/options.zsh"
[[ -f "$ZDOTDIR/aliases.zsh" ]]   && source "$ZDOTDIR/aliases.zsh"
[[ -f "$ZDOTDIR/functions.zsh" ]] && source "$ZDOTDIR/functions.zsh"

# --- 3. Cached Tool Initializations ---
# Pre-evaluating tools into cached script files drastically speeds up startup time (< 50ms)
ZSH_TOOL_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/tools"
mkdir -p "$ZSH_TOOL_CACHE"

# FZF Integration Cache
if (( $+commands[fzf] )); then
    if [[ ! -f "$ZSH_TOOL_CACHE/fzf.zsh" ]]; then
        fzf --zsh > "$ZSH_TOOL_CACHE/fzf.zsh" 2>/dev/null
    fi
    [[ -f "$ZSH_TOOL_CACHE/fzf.zsh" ]] && source "$ZSH_TOOL_CACHE/fzf.zsh"
fi

# Zoxide (Smarter cd) Cache
if (( $+commands[zoxide] )); then
    if [[ ! -f "$ZSH_TOOL_CACHE/zoxide.zsh" ]]; then
        zoxide init zsh --cmd cd > "$ZSH_TOOL_CACHE/zoxide.zsh" 2>/dev/null
    fi
    [[ -f "$ZSH_TOOL_CACHE/zoxide.zsh" ]] && source "$ZSH_TOOL_CACHE/zoxide.zsh"
fi

# --- 4. Plugins (Deferred Loading) ---
[[ -f "$ZDOTDIR/plugins.zsh" ]] && source "$ZDOTDIR/plugins.zsh"

# --- 5. Theme & Visuals (Powerlevel10k) ---
local -a p10k_theme_paths=(
    "/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme"
    "/usr/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme"
    "/usr/share/powerlevel10k/powerlevel10k.zsh-theme"
    "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme"
    "/usr/local/share/powerlevel10k/powerlevel10k.zsh-theme"
    "$ZDOTDIR/plugins/powerlevel10k/powerlevel10k.zsh-theme"
)

for p in "${p10k_theme_paths[@]}"; do
    if [[ -f "$p" ]]; then
        source "$p"
        break
    fi
done

[[ -f "$ZDOTDIR/p10k.zsh" ]] && source "$ZDOTDIR/p10k.zsh"

# --- 6. On-Demand & Background Bytecode Compilation ---
# Compiles all zsh config files into .zwc bytecode for instantaneous parsing
zsh-compile() {
    local f
    local -a files=(
        "$ZDOTDIR/.zshrc"
        "$ZDOTDIR/.zshenv"
        "$ZDOTDIR/options.zsh"
        "$ZDOTDIR/aliases.zsh"
        "$ZDOTDIR/functions.zsh"
        "$ZDOTDIR/plugins.zsh"
        "$ZDOTDIR/p10k.zsh"
        "$ZSH_TOOL_CACHE"/*.zsh(N)
    )
    for f in "${files[@]}"; do
        if [[ -f "$f" ]]; then
            rm -f "${f}.zwc" 2>/dev/null
            zcompile "$f"
        fi
    done
    for f in "$ZDOTDIR/functions"/*(N); do
        if [[ -f "$f" ]]; then
            rm -f "${f}.zwc" 2>/dev/null
            zcompile -Uz "$f"
        fi
    done
    print -P "%F{green}✓%f Zsh configuration compiled to .zwc bytecode."
}

# Asynchronously update .zwc bytecode if configuration files are modified
function _zcompile_check() {
    local f
    local -a files=(
        "$ZDOTDIR/.zshrc"
        "$ZDOTDIR/.zshenv"
        "$ZDOTDIR/options.zsh"
        "$ZDOTDIR/aliases.zsh"
        "$ZDOTDIR/functions.zsh"
        "$ZDOTDIR/plugins.zsh"
        "$ZDOTDIR/p10k.zsh"
        "$ZSH_TOOL_CACHE"/*.zsh(N)
    )
    for f in "${files[@]}"; do
        if [[ -f "$f" && "$f" -nt "${f}.zwc" ]]; then
            (rm -f "${f}.zwc" 2>/dev/null; zcompile "$f") &!
        fi
    done
    for f in "$ZDOTDIR/functions"/*(N); do
        if [[ -f "$f" && "$f" -nt "${f}.zwc" ]]; then
            (rm -f "${f}.zwc" 2>/dev/null; zcompile -Uz "$f") &!
        fi
    done
}
if (( $+functions[zsh-defer] )); then
    zsh-defer _zcompile_check
fi

# --- 7. Local Overrides ---
# Load optional machine-specific configurations (untracked by git)
[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"
