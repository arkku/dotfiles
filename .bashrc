# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

unset HISTFILE
export HISTFILE

if [ "$TERM" = "screen" ]; then
    unset DISPLAY
    export DISPLAY
fi

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

    # check the window size after each command and, if necessary,
    # update the values of LINES and COLUMNS.
    shopt -s checkwinsize

    shopt -s no_empty_cmd_completion
    shopt -s cmdhist

    set editing-mode vi
    set visible-stats on
    set mark-directories off
    set completion-ignore-case on

    # enable color support of ls and also add handy alias
    if [ -n "$COLORTERM" ]; then
        alias ls='ls -F --color=auto'
	if [ -x "`which dircolors`" -a -r "$HOME/.dir_colors" ]; then
	    eval `dircolors -b "$HOME/.dir_colors"`
	fi
    else
        alias ls='ls -F'
    fi

    # more aliases
    alias ll='ls -kl'
    if [ "`uname`" == "IRIX" ]; then
        alias psg='ps -efa | grep'
    else
        alias psg='ps axww | grep'
    fi

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
        update_terminal_cwd() {
            local encoded=${PWD//%/%25}
            local PWD_URL="file://$HOSTNAME${encoded// /%20}"
            [ "$TERM" = 'screen' ] && echo -ne '\033P'
            printf '\e]7;%s\a' "$PWD_URL"
        }
        PROMPT_COMMAND="update_terminal_cwd; $PROMPT_COMMAND"
        TITLE_EXCLUDE_PWD=1
    fi

    case $TERM in
    xterm*)
        # Update window title.
        TITLE_SET_HEAD=`echo -ne '\033]0;'`
        TITLE_SET_TAIL=`echo -ne '\007'`
        install_title_updates
        preexec_install
        ;;
    screen*)
        # Update hardstatus.
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

    export PROMPT_COMMAND TITLE_SET_HEAD TITLE_SET_TAIL SHORT_HOSTNAME SHOW_USERNAME
else
    echo "$PATH" | grep -qE '(^|:)/usr/local/bin(:|$)' || export PATH="/usr/local/bin:$PATH"
fi
