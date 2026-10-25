# ==============================================================================
# File: plugins.zsh
# Description: Modular plugin configuration with optional non-blocking deferred
#              loading via zsh-defer. Keeps shell startup under 50ms.
# ==============================================================================

# --- 1. Core Deferred Loading Engine (zsh-defer) ---
# Supports user-cloned plugin locations or system packages
local -a defer_paths=(
    "$ZDOTDIR/plugins/zsh-defer/zsh-defer.plugin.zsh"
    "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-defer/zsh-defer.plugin.zsh"
    "/usr/share/zsh/plugins/zsh-defer/zsh-defer.plugin.zsh"
    "/opt/homebrew/share/zsh-defer/zsh-defer.plugin.zsh"
    "/usr/local/share/zsh-defer/zsh-defer.plugin.zsh"
)

for p in "${defer_paths[@]}"; do
    if [[ -f "$p" ]]; then
        source "$p"
        break
    fi
done

# --- 2. Interactive Completion Menu (fzf-tab) ---
# Loaded immediately after compinit for stable widget hooking
local -a fzf_tab_paths=(
    "/usr/share/zsh/plugins/fzf-tab-git/fzf-tab.zsh"
    "/usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
    "/opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh"
    "/usr/local/share/fzf-tab/fzf-tab.plugin.zsh"
    "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
    "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/fzf-tab/fzf-tab.plugin.zsh"
    "$ZDOTDIR/plugins/fzf-tab/fzf-tab.plugin.zsh"
)

for p in "${fzf_tab_paths[@]}"; do
    if [[ -f "$p" ]]; then
        source "$p"
        break
    fi
done

# --- 3. Autosuggestions ---
# Loaded asynchronously via zsh-defer if available, or synchronously as fallback
_load_autosuggestions() {
    local -a as_paths=(
        "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "$ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
    )
    for p in "${as_paths[@]}"; do
        if [[ -f "$p" ]]; then
            source "$p"
            
            ZSH_AUTOSUGGEST_STRATEGY=(history) 
            ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
            ZSH_AUTOSUGGEST_USE_ASYNC=true
            ZSH_AUTOSUGGEST_COMPLETION_IGNORE=true

            # Prevent Tab from inadvertently accepting suggestions
            ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(expand-or-complete complete-word)
            ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${(@)ZSH_AUTOSUGGEST_ACCEPT_WIDGETS:#(expand-or-complete|complete-word)}")
            ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(expand-or-complete complete-word)

            # Accept full suggestion with Ctrl+E
            bindkey "^E" autosuggest-accept
            break
        fi
    done
}

if (( $+functions[zsh-defer] )); then
    zsh-defer _load_autosuggestions
else
    _load_autosuggestions
fi

# --- 4. Syntax Highlighting (Synchronous) ---
# Loaded synchronously before prompt display to hook correctly into ZLE
local -a hl_paths=(
    "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "$ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
)
for p in "${hl_paths[@]}"; do
    if [[ -f "$p" ]]; then
        source "$p"
        break
    fi
done

# --- 5. Interactive Editing Buffer Utility ---
# Edit current shell command line in $EDITOR with Ctrl+X
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X' edit-command-line
