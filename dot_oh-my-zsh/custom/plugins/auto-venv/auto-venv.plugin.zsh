#!/usr/bin/env zsh
# ===== Auto Python Virtual Environment Activation Plugin =====

find_venv() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/venv/bin/activate" ]]; then
            echo "$dir/venv"
            return 0
        elif [[ -f "$dir/.venv/bin/activate" ]]; then
            echo "$dir/.venv"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

auto_activate_venv() {
    local venv_path
    venv_path=$(find_venv)
    
    if [[ -n "$venv_path" ]]; then
        # Found a venv, activate it if not already active
        if [[ "$VIRTUAL_ENV" != "$venv_path" ]]; then
            source "$venv_path/bin/activate"
        fi
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        # No venv found but one is active, deactivate it
        deactivate
    fi
}

# Set up the hook
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_activate_venv
auto_activate_venv # Run once for current directory

