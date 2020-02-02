# ~/.profile: executed by the command interpreter for login shells.

umask 027

export MAIL="$HOME/Maildir"
export CONCURRENCY_LEVEL=2
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
export LESSCHARSET=utf-8
export COLORTERM=1

export MOSH_TITLE_NOPREFIX=1

export CLICOLOR=1

unset MAILCHECK
export MAILCHECK

if [ -n "$PS1" ]; then
    export GPG_TTY=`tty`
fi

. "$HOME/.profile_shared"

if [ -n "$PS1" -a -z "$ENVONLY" -a -t 0 ]; then
    tabs -4
fi

[ -e "$HOME/.profile_private" ] && . "$HOME/.profile_private"