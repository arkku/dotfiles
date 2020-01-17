disable log
unset HISTFILE
export HISTFILE

[ "$TERM" = "screen" ] && unset DISPLAY
export DISPLAY

export HOSTNAME=`hostname`

# UTF-8 combining characters
setopt combiningchars

if [[ -o interactive ]]; then
    autoload -Uz colors && colors

    # Options

    # Allow comments on interactive prompt
    setopt interactivecomments

    # Shell substitutions in prompt
    setopt prompt_subst

    # Plain `dir` works as `cd dir`
    setopt auto_cd

    # Automatic `pushd` on change directory
    setopt auto_pushd

    # Use `cd -n` instead of `cd +n` (similar to git history)
    setopt pushdminus

    # Completion menu on tab
    setopt auto_menu
    unsetopt menu_complete

    # Completion moves cursor to the end of the word
    setopt always_to_end

    # Allow completion in the middle of a word
    setopt complete_in_word

    # Don't beep
    setopt no_beep

    setopt extended_glob
    setopt transient_rprompt

    # Aliases
    alias gr='grep --color=auto --exclude-dir={.git,.hg,.svn,.bzr}'
    alias please='sudo $(fc -ln -1)'

    # Grep `ps` (more brute force than pgrep)
    alias psg='ps axww | grep'

    # Copy last command
    alias clc='fc -ln -1 | xclip -selection c'

    # Pipe shortcuts
    alias -g L='| less'
    alias -g CL='| xclip -selection c'

    # System-specific variations
    case `uname`; in
        Darwin)
            alias clc='fc -ln -1 | pbcopy'
            alias -g CL='| pbcopy'
            ;;
        IRIX)
            alias psg='ps -efa | grep'
            ;;
        *)
            ;;
    esac

    # ls
    alias ll='ls -kl'

    [ -n "$COLORTERM" -a -z "$CLICOLOR" ] && export CLICOLOR=1

    if [ -x "`which dircolors`" -a -r "$HOME/.dir_colors" ]; then
        eval `dircolors -b "$HOME/.dir_colors"`
    fi

    if ls --version 2>/dev/null | grep -q GNU; then
        alias ls='ls -F --color=auto --group-directories-first'
    elif [ "$CLICOLOR" = 1 ]; then
        export LSCOLORS='AxfxHehecxegehBDBDAhaD'
        alias ls='ls -F -G'
    else
        alias ls='ls -F'
    fi

    # Completion
    autoload -Uz compinit && compinit

    zstyle ':completion:*' verbose yes

    # Show completion options in a menu
    zstyle ':completion:*:*:*:*:*' menu select

    # Make completion case-, hyphen-, and underscore-insensitive
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

    # Use the same colors as GNU ls
    zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

    # Show description for options
    zstyle ':completion:*:options' description 'yes'

    # Theme
    #zstyle ':completion:*:messages' format '%F{white}# %d'$DEFAULT
    zstyle ':completion:*:warnings' format '%F{white}# No matches for: %d'$DEFAULT
    #zstyle ':completion:*:descriptions' format '%F{white}# %B%d%b%f'$DEFAULT

    # Prediction (rather intrusive, disabled)
    #autoload -Uz predict-on && zstyle ':predict' verbose true && predict-on

    # Git
    autoload -Uz vcs_info
    precmd_vcs_info() {
        vcs_info
    }
    precmd_functions+=( precmd_vcs_info )
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' use-prompt-escapes true
    zstyle ':vcs_info:*:*' max-exports 3
    zstyle ':vcs_info:*:*' formats '%F{cyan}%r%F{white}/%F{cyan}%b%F{green}%c%F{yellow}%u%F{reset}' ' %r/%b%c%u' ' '
    zstyle ':vcs_info:*:*' actionformats '%F{cyan}%r%F{white}/%F{cyan}%b%F{white}|%F{red}%a%F{green}%c%F{yellow}%u%F{reset}' '%r/%b %a%c%u' '%F{white}# %s %a: %m%F{reset} '
    zstyle ':vcs_info:*' get-revision false
    zstyle ':vcs_info:*' stagedstr '+'
    zstyle ':vcs_info:*' unstagedstr '~'

    # A function to easily enable/disable checking for changes in git repo
    zsh-check-changes() {
        case "$1" in
            true|false|staged)
                zstyle ':vcs_info:git*' check-for-staged-changes true
                zstyle ':vcs_info:git*' check-for-changes "$1"
            ;;
            none)
                zstyle ':vcs_info:git*' check-for-changes false
                zstyle ':vcs_info:git*' check-for-staged-changes false
            ;;
            *)
                print 'Usage: $0 <true|false|staged|none>'
            ;;
        esac
    }
    zsh-check-changes true
    
    # Vi-mode
    bindkey -v
    export KEYTIMEOUT=1

    # Key bindings
    bindkey '^P' up-history
    bindkey '^N' down-history
    bindkey '^[[5~' history-search-backward
    bindkey '^[[6~' history-search-forward
    bindkey '^R' history-incremental-search-backward
    bindkey -M vicmd '^R' redo
    bindkey '^W' backward-kill-word
    bindkey '^K' kill-word
    bindkey '^U' kill-whole-line
    bindkey '^Y' yank
    bindkey '^Q' push-line-or-edit
    bindkey '^D' delete-char
    bindkey '^_' undo
    bindkey '^L' clear-screen
    for mode in '-M vicmd' '-M viins' ''; do
        # Make navigation the same for vi mode
        bindkey ${=mode} '^[[C' forward-char
        bindkey ${=mode} '^[[D' backward-char
        bindkey ${=mode} '^[OC' forward-char
        bindkey ${=mode} '^[OD' backward-char
        bindkey ${=mode} '^[[1~' beginning-of-line
        bindkey ${=mode} '^[[4~' end-of-line
        bindkey ${=mode} '^[[5C' forward-word
        bindkey ${=mode} '^[[5D' backward-word
        bindkey ${=mode} '^[[1;5C' forward-word
        bindkey ${=mode} '^[[1;5D' backward-word
        bindkey ${=mode} '^[[3~' delete-char
        bindkey ${=mode} '^E' end-of-line
        if [[ "$mode" = '-M vicmd' ]]; then
            bindkey ${=mode} '^?' backward-char
            bindkey ${=mode} '^H' backward-char
            bindkey ${=mode} "^[OA" up-line
            bindkey ${=mode} "^[OB" down-line
            bindkey ${=mode} "^[[A" up-line
            bindkey ${=mode} "^[[B" down-line
        else
            bindkey ${=mode} '^A' beginning-of-line
            bindkey ${=mode} '^E' end-of-line
            bindkey ${=mode} '^H' backward-delete-char
            bindkey ${=mode} '^?' backward-delete-char
            bindkey ${=mode} '^H' backward-delete-char
            bindkey ${=mode} "^[OA" up-line-or-history
            bindkey ${=mode} "^[OB" down-line-or-history
            bindkey ${=mode} "^[[A" up-line-or-history
            bindkey ${=mode} "^[[B" down-line-or-history
        fi
    done
    unset mode
    bindkey -M vicmd '?' history-incremental-search-backward
    bindkey -M vicmd '/' history-incremental-search-forward

    autoload -U edit-command-line
    zle -N edit-command-line
    bindkey '^ ' edit-command-line

    # Vim-like surround
   autoload -Uz surround
   zle -N delete-surround surround
   zle -N add-surround surround
   zle -N change-surround surround
   bindkey -a cs change-surround
   bindkey -a ds delete-surround
   bindkey -a ys add-surround
   bindkey -M visual S add-surround

   # In vi-mode, type vi" to select quoted text
    autoload -U select-quoted
    zle -N select-quoted
    for m in visual viopp; do
        for c in {a,i}{\',\",\`}; do
            bindkey -M $m $c select-quoted
        done
    done

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
            if [[ ${#title} -gt 25 ]]; then
                title="${title:0:25}…"
            fi
            print -n "$TITLE_SET_HEAD$title$TITLE_SET_TAIL"
        }
        preexec_functions+=( set_title_exec )

        set_title_prompt() {
            print -n "$TITLE_SET_HEAD"
            print -Pn '%n@%m$vcs_info_msg_1_'
            print -n "$TITLE_SET_TAIL"
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

    # Change cursor to indicate vi mode
    function zle-line-init zle-keymap-select {
        case "$KEYMAP" in
            vicmd)
                print -n '\033[4 q'
                export ZSHVIMODE="%F{yellow}(vi)%F{reset} "
                ;;
            *)
                print -n '\033[1 q'
                export ZSHVIMODE=''
                ;;
        esac
        zle reset-prompt
    }

    zle -N zle-line-init
    zle -N zle-keymap-select

    # Prompt
    export PROMPT='%(?..%F{red}?$?%F{reset} )$ZSHVIMODE$vcs_info_msg_2_
%F{cyan}%-65<…<%~%<<%F{reset}%# '
    export RPROMPT='    %F{cyan}%(1j.%j&.)$vcs_info_msg_0_%F{reset}'
else
    echo "$PATH" | grep -qE '(^|:)/usr/local/bin(:|$)' || export PATH="/usr/local/bin:$PATH"
fi

[ -d "$HOME/.rvm/bin" ] && export PATH="$PATH:$HOME/.rvm/bin"

# Make path unique
typeset -aU path
