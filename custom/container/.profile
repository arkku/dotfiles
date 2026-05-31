# ~/.profile: executed by the command interpreter for login shells.

export LESSCHARSET=utf-8
export COLORTERM=1
export MOSH_TITLE_NOPREFIX=0
export CLICOLOR=1

unset MAILCHECK
export MAILCHECK

[ -d "$HOME/.npm-packages" ] && export NPM_PACKAGES="$HOME/.npm-packages"
[ -e "$NPM_PACKAGES" -a -d "$NPM_PACKAGES/bin" ] && export PATH="$PATH:$NPM_PACKAGES/bin"

. "$HOME/.profile_shared"

[ -d "$HOME/.local/bin" ] && export PATH="$PATH:$HOME/.local/bin"

[ -e "$HOME/.profile_private" ] && . "$HOME/.profile_private"
[ -e "$HOME/.profile_secrets" ] && . "$HOME/.profile_secrets"
