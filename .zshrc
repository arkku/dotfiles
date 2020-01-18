disable log

[ "$TERM" = "screen" ] && unset DISPLAY
export DISPLAY

# UTF-8 combining characters
setopt combiningchars

# Add custom functions directory to fpath
[ -e "$HOME/.zsh/functions" ] && fpath=( "$HOME/.zsh/functions" "${fpath[@]}" )

if [[ -o interactive ]]; then
    autoload -Uz colors && colors
    autoload -Uz zmv

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

    #setopt extended_glob
    setopt transient_rprompt

    # History
    export HISTSIZE=1000
    setopt hist_expire_dups_first
    setopt hist_find_no_dups
    setopt hist_ignore_dups
    setopt hist_no_store
    setopt hist_reduce_blanks

    # Aliases
    alias gr='grep --color=auto --exclude-dir={.git,.hg,.svn,.bzr}'
    alias please='sudo $(fc -ln -1)'

    # Grep `ps` (more brute force than pgrep)
    alias psg='ps axww | grep --color=auto'

    # Grep `history`
    alias hgrep='history 1 | grep --color=auto'

    # Copy last command
    alias clc='fc -ln -1 | xclip -selection c'

    # Pipe shortcuts
    alias -g L='| less'
    alias -g CL='| xclip -selection c'
    alias -g GR='| grep --color=auto'
    alias -g FGR='| grep -F --color=auto'

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
    autoload -Uz compinit && compinit -i

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

    # History (not used at the moment)
    #zstyle ':completion:*:historyevent' command 'fc -lr'
    #zstyle ':completion:*:historyevent' sort no

    # Git
    autoload -Uz vcs_info
    precmd_vcs_info() {
        vcs_info
    }
    precmd_functions+=( precmd_vcs_info )
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' use-prompt-escapes true
    zstyle ':vcs_info:*:*' max-exports 4
    zstyle ':vcs_info:*:*' formats '%F{cyan}%r%F{white}/%F{cyan}%b%F{green}%c%F{yellow}%u%F{reset}' ' %r/%b%c%u' ' ' '%r/%S'
    zstyle ':vcs_info:*:*' actionformats '%F{cyan}%r%F{white}/%F{cyan}%b%F{white}|%F{red}%a%F{green}%c%F{yellow}%u%F{reset}' '%r/%b %a%c%u' '%F{white}# %s %a: %m%F{reset} ' '%r/%S'
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

    local mode
    # Key bindings
    bindkey '^P' up-history
    bindkey '^N' down-history
    bindkey '^[[5~' history-search-backward
    bindkey '^[[6~' history-search-forward
    bindkey '^W' backward-kill-word
    bindkey '^K' kill-word
    bindkey '^U' kill-whole-line
    bindkey '^Y' yank
    bindkey '^Q' push-line-or-edit
    bindkey '^D' delete-char
    bindkey '^_' history-incremental-pattern-search-backward
    bindkey '^\\' history-incremental-pattern-search-forward
    bindkey -M vicmd '/' history-incremental-pattern-search-backward
    bindkey -M vicmd '?' history-incremental-pattern-search-forward
    bindkey '^L' clear-screen
    for mode in vicmd viins; do
        bindkey -M "$mode" '^R' redo
        bindkey -M "$mode" '^Z' undo
    done
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
            print -n "$TITLE_SET_HEAD"
            if [ -n "$SSH_CONNECTION" -o -n "$SUDO_USER" ]; then
                # Show the username under sudo and host under ssh
                print -Pn "${SUDO_USER:+%n@}%m: "
            fi
            print -n "$title$TITLE_SET_TAIL"
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
                prompt_vi_mode="%F{yellow}(vi)%F{reset} "
                ;;
            *)
                print -n '\033[1 q'
                prompt_vi_mode=''
                ;;
        esac
        zle reset-prompt
    }

    zle -N zle-line-init
    zle -N zle-keymap-select

    # Prompt

    format_pwd() {
        setopt localoptions extendedglob
        if [ -n "$vcs_info_msg_3_" ]; then
            # Inside a git repository: start display from the repository base
            local repo="${vcs_info_msg_3_/%\/./}"
            if [ "$PWD" = "$HOME/$repo" ]; then
                pwd_prompt="~/$repo"
            elif [ ${#PWD} -le $(( ${#repo} + 5 )) ]; then
                # Don't abbreviate if it saves fewer than 5 chars
                pwd_prompt="${PWD/#$HOME/~}"
            else
                pwd_prompt="…/$repo"
            fi
            unset repo
        else
            # Use ~ to represent the home directory
            pwd_prompt="${PWD/#$HOME/~}"

            # Substitute the iCloud documents path
            pwd_prompt="${pwd_prompt/#\~\/Library\/Mobile Documents\/com\~apple\~CloudDocs/…iCloud}"
            # If we are inside a macOS .app directory, preserve the app name
            pwd_prompt="${pwd_prompt/#*\/(#b)([^\/]##.app)\/Contents\//…/$match[1]/…/}"
        fi

        local trimmed

        # Keep the first and last two directories only
        trimmed="${pwd_prompt:/#%(#b)((…[[:alpha:]]#|\~|)\/[^\/]##\/[^\/]##\/)(#b)([^\/]##\/)##(#b)([^\/]##\/[^\/]##)/$match[1]…/$match[4]}"
        [[ ${#trimmed} -lt ${#pwd_prompt} ]] && pwd_prompt="$trimmed"

        # Clean up multiple ellipses
        pwd_prompt="${pwd_prompt//(…\/)##/…/}"

        # Escape any percents to avoid prompt expansion
        pwd_prompt="${pwd_prompt//\%/%%}"

        unset trimmed
    }
    precmd_functions+=( format_pwd )

    zle_highlight=( 'isearch:underline' 'special:fg=cyan' 'paste:bold,fg=red' 'suffix:fg=white' 'region:standout' )

    export PROMPT='%(?..%F{red}?$?%F{reset} )%F{white}!%! $prompt_vi_mode$vcs_info_msg_4_
%F{cyan}%-65<…<${pwd_prompt:-%~}%<<%F{reset}%# '
    export RPROMPT='    %F{cyan}%(1j.%j&.)$vcs_info_msg_0_%F{reset}'

    # Syntax highlighting
    local hlpath
    for hlpath in "$HOME/.zsh" '/usr/local/share' '/usr/share'; do
        [ -r "$hlpath/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] || continue
        export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$hlpath/zsh-syntax-highlighting/highlighters"
        typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[default]='none'

        local style
        for style in arg0 command builtin reserved-word hashed-command command-substitution process-substitution; do
            ZSH_HIGHLIGHT_STYLES[$style]='bold'
        done
        for style in single-hyphen-option double-hyphen-option unknown-token path; do
            ZSH_HIGHLIGHT_STYLES[$style]='none'
        done
        for style in redirection named-fd commandseparator; do
            ZSH_HIGHLIGHT_STYLES[$style]='fg=green'
        done
        for style in comment; do
            ZSH_HIGHLIGHT_STYLES[$style]='fg=white'
        done
        for style in single-quoted-argument double-quoted-argument; do
            ZSH_HIGHLIGHT_STYLES[$style]='fg=yellow'
        done
        for style in back-quoted-argument dollar-quoted-argument dollar-double-quoted-argument command-substitution process-substitution; do
            ZSH_HIGHLIGHT_STYLES[$style]='fg=cyan'
        done
        for style in alias function history-expansion; do
            ZSH_HIGHLIGHT_STYLES[$style]='fg=magenta,bold'
        done
        ZSH_HIGHLIGHT_STYLES[assign]='fg=blue'
        ZSH_HIGHLIGHT_STYLES[precommand]='fg=blue,bold'
        ZSH_HIGHLIGHT_STYLES[path_prefix]='underline'
        ZSH_HIGHLIGHT_STYLES[globbing]='fg=yellow,bold'
        ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=magenta,bold,underline'

        ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=red,bold'
        for style in 1 2 3 4 5; do
            ZSH_HIGHLIGHT_STYLES[bracket-level-$style]='fg=green'
        done

        source "$hlpath/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets cursor )

        unset style
        break
    done
    unset hlpath

    # If there is no syntax highlighting installed, make the prompt input bold
    [ -z "$ZSH_HIGHLIGHT_HIGHLIGHTERS" ] && zle_highlight+=( 'default:bold' )
else
    echo "$PATH" | grep -qE '(^|:)/usr/local/bin(:|$)' || export PATH="/usr/local/bin:$PATH"
fi

[ -d "$HOME/.rvm/bin" ] && export PATH="$PATH:$HOME/.rvm/bin"

# Make path unique
typeset -aU path
