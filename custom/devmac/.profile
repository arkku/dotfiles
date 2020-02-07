# .profile

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

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_TIME=C
export LC_PAPER=fi_FI.UTF-8
export LC_MONETARY=fi_FI.UTF-8
export LC_TELEPHONE=fi_FI.UTF-8
export LC_ADDRESS=fi_FI.UTF-8
export LC_MEASUREMENT=fi_FI.UTF-8
#export LC_COLLATE=C
export LESSCHARSET=utf-8

export MOSH_TITLE_NOPREFIX=1

export CONCURRENCY_LEVEL=4

export CLICOLOR=1

unset MAILCHECK
export MAILCHECK

export NVIM_TUI_ENABLE_TRUE_COLOR=0

if [ -n "$PS1" ]; then
    export GPG_TTY=`tty`
fi

[ -d "$HOME/.npm-packages" ] && export NPM_PACKAGES="$HOME/.npm-packages"
[ -d "$HOME/go" ] && export GOPATH="$HOME/go"
[ -d "$HOME/google-cloud-sdk" ] && export GCLOUD="$HOME/google-cloud-sdk"
[ -d "$GCLOUD/bin" ] && export PATH="$PATH:$GCLOUD/bin"

. "$HOME/.profile_shared"

#if [ -n "$PS1" -a -z "$ENVONLY" -a -t 0 ]; then
#    tabs -4
#fi

if [ -d "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" ]; then
    export PATH="$PATH:/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin"
fi

for vscpath in "$HOME/" '/'; do
    if [ -d "${vscpath}Application/Visual Studio Code.app/Contents/Resources/app/bin" ]; then
        export PATH="$PATH:${vscpath}Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    fi
done

[ -e "$HOME/.profile_private" ] && . "$HOME/.profile_private"
