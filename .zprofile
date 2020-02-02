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
