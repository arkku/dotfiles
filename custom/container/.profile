# ~/.profile: executed by the command interpreter for login shells.

export LESSCHARSET=utf-8
export COLORTERM=1
export MOSH_TITLE_NOPREFIX=0
export CLICOLOR=1

unset MAILCHECK
export MAILCHECK

. "$HOME/.profile_shared"

[ -d "$HOME/.local/bin" ] && export PATH="$PATH:$HOME/.local/bin"

[ -e "$HOME/.profile_private" ] && . "$HOME/.profile_private"
