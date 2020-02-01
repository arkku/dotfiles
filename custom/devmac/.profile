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
fi

. "$HOME/.profile_shared"

if [ -n "$PS1" -a -z "$ENVONLY" -a -t 0 ]; then
    tabs -4
fi

if [ -d "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" ]; then
    export PATH="$PATH:/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin"
fi

for vscpath in "$HOME/" '/'; do
    if [ -d "${vscpath}Application/Visual Studio Code.app/Contents/Resources/app/bin" ]; then
        export PATH="$PATH:${vscpath}Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    fi
done

[ -e "$HOME/.profile_private" ] && . "$HOME/.profile_private"

for rvmpath in "$HOME/.rvm" '/usr/local/rvm'; do
    if [ -s "$rvmpath/scripts/rvm" ]; then
        source "$rvmpath/scripts/rvm"
        break
    fi
done

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"