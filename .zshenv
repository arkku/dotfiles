# UTF-8 combining characters
setopt combiningchars

[ -z "$SUDO_USER" -a ! "$UID" -eq 0 ] || umask 022

[ -e "$HOME/.zshenv_private" ] && . "$HOME/.zshenv_private"
