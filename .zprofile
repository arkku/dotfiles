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
        setopt hist_expire_dups_first append_history hist_save_no_dups hist_reduce_blanks
        export SAVEHIST=200
    else
        unset HISTFILE
    fi
fi

for rvmdir in "$HOME/.rvm" '/usr/local/rvm'; do
    if [ -s "$rvmdir/scripts/rvm" ]; then
        export rvmsudo_secure_path=0
        source "$rvmdir/scripts/rvm"
        break
    fi
done

# disallow messages
mesg n 2>/dev/null || true
