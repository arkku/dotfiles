disable log
unset HISTFILE
export HISTFILE

[ "$TERM" = "screen" ] && unset DISPLAY
export DISPLAY

export HOSTNAME=`hostname`

# UTF-8 combining characters
setopt combiningchars

if [[ -o interactive ]]; then
    # Options

    # Allow comments on interactive prompt
    setopt interactivecomments

    # Shell substitutions in prompt
    setopt prompt_subst

    # Implicit `cd ` when executing a directory
    setopt auto_cd

    # pushd on cd
    setopt auto_pushd

    # Use cd -n instead of cd +n (similar to git history)
    setopt pushdminus

    # Completion menu on tab
    setopt auto_menu
    unsetopt menu_complete

    # Completion moves cursor to the end of the word
    setopt always_to_end

    # Allow completion in the middle of a word
    setopt complete_in_word

    # Aliases for ls
    alias ll='ls -kl'
    if [ "`uname`" = 'IRIX' ]; then
        alias psg='ps -efa | grep'
    else
        alias psg='ps axww | grep'
    fi

    if [ "$CLICOLOR" = 1 ]; then
        export LSCOLORS='AxfxcxdxbxegehBDBDAhaD'
        alias ls='ls -F -G'
    elif [ -n "$COLORTERM" ]; then
        alias ls='ls -F --color=auto'
	if [ -x "`which dircolors`" -a -r "$HOME/.dir_colors" ]; then
	    eval `dircolors -b "$HOME/.dir_colors"`
        fi
        export CLICOLOR=1
    else
        alias ls='ls -F'
    fi

    # Completion
    
    # Show completion options in a menu
    zstyle ':completion:*:*:*:*:*' menu select

    # Make completion case-, hyphen-, and underscore-insensitive
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

    # Git
    autoload -Uz compinit && compinit
    autoload -Uz vcs_info
    precmd_vcs_info() {
        vcs_info
    }
    precmd_functions+=( precmd_vcs_info )
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' use-prompt-escapes true
    zstyle ':vcs_info:*:*' formats '%F{red}%m%F{cyan}%r/%b%F{green}%c%F{yellow}%u%F{reset}' ' %r/%b%c%u'
    zstyle ':vcs_info:*:*' actionformats '%F{cyan}%a %F{green}%c%F{yellow}%u%F{reset}' ' %a'
    zstyle ':vcs_info:*' stagedstr '+'
    zstyle ':vcs_info:*' unstagedstr '~'

    # A function to easily enable/disable checking for changes in git repo
    zsh-check-changes() {
        if [ -n "$1" ]; then
            zstyle ':vcs_info:git*' check-for-changes "$1"
        else
            print 'Usage: $0 <true|false>'
        fi
    }
    zsh-check-changes true
    
    # Key bindings
    bindkey '^[[5C' forward-word
    bindkey '^[[5D' backward-word
    bindkey '^[[1;5C' forward-word
    bindkey '^[[1;5D' backward-word
    bindkey '^[[3~' delete-char
    bindkey '^[[5~' history-search-backward
    bindkey '^[[6~' history-search-forward
    bindkey '^[[1~' beginning-of-line
    bindkey '^[[4~' end-of-line

    autoload -U edit-command-line
    zle -N edit-command-line
    bindkey '^ ' edit-command-line

    # Terminal title (or screen/tmux hardstatus)
    case $TERM in
        screen*)
            export TITLE_SET_HEAD=`echo -ne '\033_'`
            export TITLE_SET_TAIL=`echo -ne '\033\\'`
            ;;
        xterm*)
            export TITLE_SET_HEAD=`echo -ne '\033]0;'`
            export TITLE_SET_TAIL=`echo -ne '\007'`
            ;;
        *)
            TITLE_SET_HEAD=''
            TITLE_SET_TAIL=''
            ;;
    esac

    if [ -n "$TITLE_SET_HEAD" ]; then
        set_title_exec() {
            local line="${2/#(exec|nice|nohup|time|sudo) /}"
            local cmd="${line%% *}"
            line="${line:0:30}"
            local title="$line"
            if [[ ${#cmd} -gt ${#line} ]]; then
                title="$cmd" # If the command is longer than the truncated line, show it anyway
            elif [[ ${#2} -lt 26 ]]; then
                title="$2" # If the untruncated line is short enough, show it all
            fi
            print -Pn "${TITLE_SET_HEAD}%28>…>$title%>>${TITLE_SET_TAIL}"
        }
        preexec_functions+=( set_title_exec )

        set_title_prompt() {
            print -Pn "${TITLE_SET_HEAD}%n@%m$vcs_info_msg_1_${TITLE_SET_TAIL}"
        }
        precmd_functions+=( set_title_prompt )
    fi

    if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
        set_terminal_dir() {
            local percent='%'
            local pwd_url=''
            local i ch len LC_CTYPE=C LC_ALL=
            len="${#PWD}"
            # Escape special characters
            for ((i = 0; i < $len; ++i)); do
                ch="${PWD:$i:1}";
                if [[ "$ch" =~ [/._~A-Za-z0-9-] ]]; then
                    pwd_url+="$ch"
                else
                    printf -v ch "%02X" "'$ch"
                    pwd_url+="%${ch: -2:2}"
                fi
            done
            [ "$TERM" = 'screen' ] && print -n '\033P'
            printf '\e]7;%s\a' "$pwd_url"
        }
        chpwd_functions+=( set_terminal_dir )
        set_terminal_dir # Set the initial directory
    fi

    # Prompt
    export PROMPT='
%(?..%F{red}?$? )%F{cyan}%-65<…<%~%<<%F{reset}%# '
    export RPROMPT='    %F{cyan}%(1j.%j&.)$vcs_info_msg_0_%F{reset}'
else
    echo "$PATH" | grep -qE '(^|:)/usr/local/bin(:|$)' || export PATH="/usr/local/bin:$PATH"
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
