# .zprofile: Run instead of .profile by zsh

# Path helpers: autoload from ~/.zsh/functions when reachable, else use
# minimal add-if-absent fallbacks
if [ -d "$HOME/.zsh/functions" ] && [ -r "$HOME/.zsh/functions/path_force_order" ]; then
    fpath=( "$HOME/.zsh/functions" "${fpath[@]}" )
    autoload -Uz ${${(f)"$(print -l "$HOME/.zsh/functions"/*)"}##*/}
else
    path_add_head() {
        [ -d "$1" ] || return
        case ":$PATH:" in *":$1:"*) ;; *) export PATH="$1${PATH:+:$PATH}" ;; esac
    }
    path_add_tail() {
        [ -d "$1" ] || return
        case ":$PATH:" in *":$1:"*) ;; *) export PATH="${PATH:+$PATH:}$1" ;; esac
    }
    path_force_head() { path_add_head "$1" }
    path_force_tail() { path_add_tail "$1" }
    path_force_order() { path_add_head "$2"; path_add_head "$1" }
fi

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
    if command -v fzf >/dev/null 2>&1; then
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
