unset HISTFILE
export HISTFILE

# If running interactively, then:
if [ "$PS1" ]; then
    preexec_interactive_mode=''
    function preexec_install () {
        if [ -z "$DISABLE_PREEXEC" ]; then
            set -o functrace >/dev/null 2>&1
            shopt -s extdebug >/dev/null 2>&1
            PROMPT_COMMAND="${PROMPT_COMMAND}; preexec_interactive_mode=1;"
            trap 'preexec_invoke' DEBUG
        fi
    }
    function preexec_invoke () {
        [ -z "$preexec_interactive_mode" ] && return              # Interactive
        [ -n "$COMP_LINE" ] && return                             # Completer
        [ x0 = "x$BASH_SUBSHELL" ] && preexec_interactive_mode='' # Subshell
        local cmd="$(history 1 \
            | sed -e 's/^[ ]*[0-9]*[ ]*//g; s/^exec[ ]*//; s/^nice[ ]*//;
                      s/^nohup[ ]*//;')"
        local len=${#cmd}
        while [ ${#cmd} -gt 40 -a -z "${cmd##* *}" ]; do
            cmd="${cmd% *}"
        done
        [ $len -gt ${#cmd} ] && cmd="$cmd ..."
        set_term_title "$cmd"
    }
    function install_title_updates {
        PROMPT_COMMAND="$PROMPT_COMMAND"'; preexec_interactive_mode=""; set_term_title'
        [ -z "$TITLE_EXCLUDE_PWD" ] && PROMPT_COMMAND="$PROMPT_COMMAND "'"$SHORT_PWD"'
    }
    function short_pwd () {
        local pwd_limit=21
        SHORT_PWD="${PWD/#$HOME/~}"
        if [ ${#SHORT_PWD} -ge $pwd_limit ]; then
            SHORT_PWD="${SHORT_PWD#??????*/}"
            local first=${SHORT_PWD:0:1}
            local prev=''
            while [ ${#SHORT_PWD} -ge $pwd_limit -a \
                    ! "$prev" = "$SHORT_PWD" -a \
                    ! "$first" = '/' -a ! "$first" = '~' ]; do
                prev="$SHORT_PWD"
                SHORT_PWD="${SHORT_PWD#??*/}"
                first=${SHORT_PWD:0:1}
            done
            [ "$first" = '/' -o "$first" = '~' ] || SHORT_PWD=".../$SHORT_PWD"
        fi
        export SHORT_PWD
    }
    function set_term_title () {
        if [ -n "$TITLE_SET_HEAD" ]; then
            echo -n "${TITLE_SET_HEAD}${SHOW_USERNAME:+${USER}@}${SHORT_HOSTNAME}${1:+: $1}${TITLE_SET_TAIL}"
        fi
    }

    shopt -s checkwinsize
    shopt -s no_empty_cmd_completion
    shopt -s cmdhist

    set editing-mode vi
    set visible-stats on
    set mark-directories off
    set completion-ignore-case on

    # Aliases
    alias gr='grep --color=auto --exclude-dir={.git,.hg,.svn,.bzr}'
    alias gs='git status --show-stash'
    alias cdr='[ -n "$REPO" ] && cd "$REPO"'

    # Make a directory (including parent diretory) and cd to it
    md() {
        mkdir -pv "$1"
        cd "$1"
    }

    # Make sudo apply to aliases as well
    alias sudo='sudo '

    # Redo last command with sudo
    alias please='sudo $(fc -ln -1)'

    # Grep `ps` (more brute force than pgrep)
    alias psg='ps axww | grep --color=auto'

    # Grep `history`
    alias hgrep='history 1 | grep -i --color=auto'

    # Grep aliases
    alias agrep='alias | grep -i --color=auto'

    # Copy last command
    alias clc='fc -ln -1 | sed "s/^['$'\t'' ]*//" | tr -d "\n" | clipcopy'

    # Copy current directory
    alias cpwd='echo -n "$PWD" | clipcopy'

    # Copy symlink-resolved path to current directory
    alias cpath='( cd -P "$PWD" && echo -n "$PWD" | clipcopy "$PWD" ) && echo "$PWD"'

    # Neovim
    if which -s nvim >/dev/null 2>&1; then
        alias vi='nvim'
        alias nvimdiff='nvim -d'
    fi

    if [ "`uname`" = "IRIX" ]; then
        alias psg='ps -efa | grep'
    else
        alias psg='ps axww | grep'
    fi

    # ls
    alias ll='ls -kl'
    alias la='ls -kla'
    alias l.='ls -d .*'

    # set a fancy prompt
    PS1='\u@$SHORT_HOSTNAME:$SHORT_PWD\$ '
    PROMPT_COMMAND='short_pwd'
    SHORT_HOSTNAME="${HOSTNAME/%.*/}"

    # show username in terminal title if it isn't the "usual" user
    SHOW_USERNAME="$USER"
    if [ "$SHOW_USERNAME" = "$(basename "$HOME" 2>/dev/null)" -a ! "$SHOW_USERNAME" = 'root' ]; then
        SHOW_USERNAME=''
    fi

    if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
        printf '\e]7;\a'
        update_terminal_cwd() {
            local encoded=${PWD//%/%25}
            local PWD_URL="file://$HOSTNAME${encoded// /%20}"
            case "$TERM" in
            screen*|tmux*)
                echo -ne '\033P'
                ;;
            *)
                ;;
            esac
            printf '\e]7;%s\a' "$PWD_URL"
        }
        #PROMPT_COMMAND="update_terminal_cwd; $PROMPT_COMMAND"
        TITLE_EXCLUDE_PWD=1
    fi

    # Update window title
    case $TERM in
    xterm*|rxvt*)
        TITLE_SET_HEAD=`echo -ne '\033]0;'`
        TITLE_SET_TAIL=`echo -ne '\007'`
        install_title_updates
        preexec_install
        ;;
    screen*|tmux*)
        TITLE_SET_HEAD=`echo -ne '\033_'`
        TITLE_SET_TAIL=`echo -ne '\033\\'`
        install_title_updates
        preexec_install
        ;;
    *)
        # Don't update hardstatus but generate the SHORT_PWD for PS1.
        TITLE_SET_HEAD=''
        TITLE_SET_TAIL=''
        ;;
    esac

    [ -n "$COLORTERM" -a -z "$CLICOLOR" ] && export CLICOLOR=1

    if [ -r "$HOME/.dir_colors" ]; then
        which -s dircolors >/dev/null 2>&1 && eval `dircolors -b "$HOME/.dir_colors"`
    fi

    if ls --version 2>/dev/null | grep -q GNU; then
        alias ls='ls -F --color=auto --group-directories-first'
    elif [ "$CLICOLOR" = 1 ]; then
        export LSCOLORS='AxfxHehecxegehBDBDAhaD'
        alias ls='ls -F -G'
    else
        alias ls='ls -F'
    fi

    export PROMPT_COMMAND TITLE_SET_HEAD TITLE_SET_TAIL SHORT_HOSTNAME SHOW_USERNAME
else
    echo "$PATH" | grep -qE '(^|:)/usr/local/bin(:|$)' || export PATH="/usr/local/bin:$PATH"
fi
