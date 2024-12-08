# .profile

[ -x "/opt/homebrew/bin/brew" ] && eval `/opt/homebrew/bin/brew shellenv`

if command -v pyenv 1>/dev/null 2>&1; then
    eval "`pyenv init -`"
fi

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
    #pgrep -q gpg-agent && export SSH_AUTH_SOCK=`gpgconf --list-dirs agent-ssh-socket`
fi

[ -d "$HOME/.npm-packages" ] && export NPM_PACKAGES="$HOME/.npm-packages"
[ -d "$HOME/go" ] && export GOPATH="$HOME/go"
[ -d "$HOME/google-cloud-sdk" ] && export GCLOUD="$HOME/google-cloud-sdk"
[ -d "$GCLOUD/bin" ] && export PATH="$PATH:$GCLOUD/bin"
[ -x "$HOME/flutter/bin/flutter" ] && export PATH="$PATH:$HOME/flutter/bin"
[ -e "$NPM_PACKAGES" -a -d "$NPM_PACKAGES/bin" ] && export PATH="$PATH:$NPM_PACKAGES/bin"
[ -d '/usr/local/share/dotnet' ] && export PATH="$PATH:/usr/local/share/dotnet"

if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PATH:$PYENV_ROOT/bin"
    command -v pyenv >/dev/null && eval "$(pyenv init -)"
fi

. "$HOME/.profile_shared"

if [ -d "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" ]; then
    export PATH="$PATH:/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin"
fi
if [ -d "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/" ]; then
    export PATH="$PATH:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
fi

for vscpath in "$HOME/" '/'; do
    if [ -d "${vscpath}Application/Visual Studio Code.app/Contents/Resources/app/bin" ]; then
        export PATH="$PATH:${vscpath}Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    fi
done

[ -e "$HOME/.profile_private" ] && . "$HOME/.profile_private"

for rvmdir in "$HOME/.rvm" '/usr/local/rvm'; do
    if [ -s "$rvmdir/scripts/rvm" ]; then
        export rvmsudo_secure_path=0
        source "$rvmdir/scripts/rvm"
        break
    fi
done
