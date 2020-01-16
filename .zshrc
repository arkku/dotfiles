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
        export LSCOLORS='Axfxcxdxbxegedabagacad'
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
    zstyle ':vcs_info:*:*' formats '%F{cyan}%b%c%u%F{reset}'
    zstyle ':vcs_info:*:*' actionformats '%F{cyan}%a %c%u%F{reset}'
    zstyle ':vcs_info:git*' check-for-changes true
    zstyle ':vcs_info:git*' use-prompt-escapes true
    zstyle ':vcs_info:*' stagedstr '%F{green}+%F{reset}'
    zstyle ':vcs_info:*' unstagedstr '%F{yellow}+%F{reset}'
    
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

    # Terminal title
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
            local cmd="${2%% *}"
            local line="${2:0:20}"
            local title="$line"
            [[ ${#cmd} -gt ${#line} ]] && title="$cmd"
            print -n "${TITLE_SET_HEAD}$cmd${TITLE_SET_TAIL}"
        }
        preexec_functions+=( set_title_exec )

        set_title_prompt() {
            print -Pn "${TITLE_SET_HEAD}%n@%m${TITLE_SET_TAIL}"
        }
        precmd_functions+=( set_title_prompt )
    fi

    if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
        set_terminal_dir() {
            local percent='%'
            local pwd_url=''
            local i ch len LC_CTYPE=C LC_ALL=;
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
%(?..%F{red}?$? )%F{cyan}%2~%F{reset}%# '
    export RPROMPT='    %F{cyan}%(1j.%j&.)$vcs_info_msg_0_%F{reset}'
else
    echo "$PATH" | grep -qE '(^|:)/usr/local/bin(:|$)' || export PATH="/usr/local/bin:$PATH"
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
