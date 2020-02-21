# .zprofile: Run instead of .profile by zsh

# Add or move the argument dir to the head of path
path_force_head() {
    [ ! -d "$1" ] && return
    if [[ ":$PATH:" == *":$1:"* ]]; then
        local tmppath=":$PATH:"
        tmppath="$1${tmppath/:$1:/:}"
        tmppath="${tmppath//::/:}"
        export PATH="${tmppath/%:/}"
    else
        export PATH="$1${PATH:+":$PATH"}"
    fi
}

# Add or move the argument dir to the tail of path
path_force_tail() {
    [ ! -d "$1" ] && return
    if [[ ":$PATH:" == *":$1:"* ]]; then
        local tmppath=":$PATH:"
        tmppath="${tmppath/:$1:/:}$1"
        tmppath="${tmppath//::/:}"
        export PATH="${tmppath/#:/}"
    else
        export PATH="${PATH:+"$PATH:"}$1"
    fi
}

# Add the argument dir to the head of path unless already in path
path_add_head() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1${PATH:+":$PATH"}"
    fi
}

# Add the argument dir to the tail of path unless already in path
path_add_tail() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="${PATH:+"$PATH:"}$1"
    fi
}

# Take two arguments, force both to be in the path in that order
path_force_order() {
    if [ ! -d "$1" ]; then
        # First doesn't exist, just make sure the second does
        path_add_head "$2"
        return
    fi
    [[ ":$PATH:" == *":$1:"*":$2:"* ]] && return
    if [[ ":$PATH:" == *":$2:"* ]]; then
        local tmppath=":$PATH:"
        tmppath="${tmppath/:$1:/:}"
        tmppath="${tmppath/:$2:/:$1:$2:}"
        tmppath="${tmppath//::/:}"
        tmppath="${tmppath/#:/}"
        export PATH="${tmppath/%:/}"
    else
        # Second is not in path, add both to head
        path_add_head "$2"
        path_force_head "$1"
    fi
}

if id -Gn 2>&1 | grep -q -E '(^| )(staff|admin|sudoers|sudo|wheel)( |$)' >/dev/null 2>&1; then
    path_add_tail '/usr/local/sbin'
    path_add_tail '/usr/sbin'
    path_add_tail '/sbin'
fi

path_force_order '/usr/local/bin' '/usr/bin'
path_force_order "$HOME/bin" '/usr/local/bin'

[ -r "$HOME/.profile" ] && . "$HOME/.profile"

if [[ -o interactive ]] && [ -n "$PS1" -a -z "$ENVONLY" ]; then
    # Replace irb with pry if available
    irb() {
        if whence -s pry >/dev/null 2>&1; then
            pry "$@"
        else
            command irb "$@"
        fi
    }

    # irbb to run the actual irb
    alias irbb='command irb'

    # Obtain fzf if installed
    if [ -n "$(command -v fzf)" ]; then
        local fzfpath
        for fzfpath in "$HOME/.profile.d" "$HOME/opt/fzf/shell" "$HOME/.fzf/shell" '/usr/local/opt/fzf/shell' '/usr/share/doc/fzf/examples'; do
            if [[ -r "$fzfpath/completion.zsh" ]]; then
                source "$fzfpath/completion.zsh"
                break
            fi
        done
        unset fzfpath
    fi

    setopt hist_verify hist_no_store hist_ignore_space extended_history
    export HISTFILE=~/.zsh_history

    # Turn on history if the file exists and is owned by this user
    if [ -O "$HISTFILE" ]; then
        chmod 600 "$HISTFILE" 2>/dev/null
        setopt hist_expire_dups_first append_history hist_reduce_blanks hist_save_no_dups inc_append_history
        export SAVEHIST=500

        # Refresh command history from other shell instances
        update_history() {
            fc -RI
        }

        # Share history between shell instances, but refresh it from other
        # shells only on directory change so as not to mess up the up arrow
        # while doing something in a specific directory
        chpwd_functions+=( update_history )
    else
        unset HISTFILE
    fi
fi
