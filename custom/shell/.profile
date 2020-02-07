# ~/.profile: executed by the command interpreter for login shells.

for rvmdir in "$HOME/.rvm" '/usr/local/rvm'; do
    if [ -s "$rvmdir/scripts/rvm" ]; then
        export rvmsudo_secure_path=0
        source "$rvmdir/scripts/rvm"
        break
    fi
done

# disallow messages
mesg n 2>/dev/null || true

[ -z "$SUDO_USER" -a ! "$UID" -eq 0 ] && umask 027 || umask 022

export MAIL="$HOME/Maildir"
export CONCURRENCY_LEVEL=2

if [ ! "$LC_ALL" = 'C' ]; then
    export LANG=en_US.UTF-8
    export LC_CTYPE=en_US.UTF-8
    export LC_MESSAGES=en_US.UTF-8
    export LC_PAPER=en_IE.UTF-8
    export LC_NUMERIC=C
    export LC_TIME=C
    export LC_COLLATE=C
    export LC_MONETARY=C
    export LC_ADDRESS=C
    export LC_TELEPHONE=C
    export LC_IDENTIFICATION=C
    export LC_NAME=C
    export LC_MEASUREMENT=en_IE.UTF-8
fi
export LESSCHARSET=utf-8
export COLORTERM=1

export MOSH_TITLE_NOPREFIX=1

export CLICOLOR=1

unset MAILCHECK
export MAILCHECK

if [ -n "$PS1" ]; then
    export GPG_TTY=`tty`
    if [ -n "`command -v gpg-connect-agent 2>/dev/null`" -a -c "$GPG_TTY" ]; then
        gpg-connect-agent --no-autostart updatestartuptty /bye 2>/dev/null
    fi
fi

. "$HOME/.profile_shared"

[ -e "$HOME/.profile_private" ] && . "$HOME/.profile_private"
