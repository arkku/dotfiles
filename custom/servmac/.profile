export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_TIME=C
export LC_PAPER=fi_FI.UTF-8
export LC_MONETARY=fi_FI.UTF-8
export LC_TELEPHONE=fi_FI.UTF-8
export LC_ADDRESS=fi_FI.UTF-8
export LC_MEASUREMENT=fi_FI.UTF-8

export MOSH_TITLE_NOPREFIX=1

export CONCURRENCY_LEVEL=4

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

if [ -n "$PS1" -a -z "$ENVONLY" -a -t 0 ]; then
    tabs -4
fi

SSL_CERT_FILE=/usr/local/etc/openssl/cert.pem
if [ -r "$SSL_CERT_FILE" ]; then
    export SSL_CERT_FILE
else
    unset SSL_CERT_FILE
fi

if [ -d "/ServerRoot/usr/bin" ]; then
    PATH="$PATH:/ServerRoot/usr/bin:/ServerRoot/usr/sbin"
    MANPATH="$MANPATH:/ServerRoot/usr/share/man"
fi

[ -e "$HOME/.profile_private" ] && . "$HOME/.profile_private"
