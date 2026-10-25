# ==============================================================================
# File: functions.zsh
# Description: Custom function loader and ZLE (Zsh Line Editor) mode handlers.
# ==============================================================================

# --- 1. Custom Function Autoloading ---
# Prepend custom functions directory to fpath so they take precedence
fpath=("$ZDOTDIR/functions" $fpath)

# Autoload all custom functions in the directory:
#   -U: suppress alias expansion during function definition
#   -z: enforce native zsh execution semantics
autoload -Uz \
    cpcd \
    extract \
    fkf \
    fkill \
    lfcd \
    mkcd \
    mvcd \
    pf \
    rm

# --- 2. ZLE Cursor Shape Widgets (Vi-Mode Feedback) ---
# Automatically changes terminal cursor shape based on editing mode:
#   - Insert mode:   Vertical beam cursor (\e[6 q)
#   - Command mode:  Solid block cursor   (\e[2 q)

function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ "$1" = 'block' ]]; then
        echo -ne '\e[2 q'
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ "$1" = 'beam' ]]; then
        echo -ne '\e[6 q'
    fi
}
zle -N zle-keymap-select

# Reset to insert mode and beam cursor on new prompt line
zle-line-init() {
    zle -K viins
    echo -ne '\e[6 q'
}
zle -N zle-line-init
