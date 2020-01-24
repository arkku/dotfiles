disable log

# UTF-8 combining characters
setopt combiningchars

# Add custom functions directory to fpath
[ -e "$HOME/.zsh/functions" ] && fpath=( "$HOME/.zsh/functions" "${fpath[@]}" )

if [[ -o interactive ]] && [ -n "$PS1" -a -z "$ENVONLY" ]; then
    local is_root=`print -nP '%(!_1_)'`
    local is_sudo="${is_root:-$SUDO_USER}"

    autoload -Uz colors && colors

    # A better move/rename command
    autoload -Uz zmv

    # Test for UTF-8
    if locale 2>/dev/null | grep -qiF -e 'UTF-8' -e 'utf8'; then
        [ -z "$UTF8" ] && export UTF8=1
        [ -z "$ELLIPSIS" ] && export ELLIPSIS='…'
        [ -z "$PROMPTCHAR" ] && export PROMPTCHAR='%F{blue}❯%F{reset}'
    else
        unset UTF8
        [ -z "$ELLIPSIS" ] && export ELLIPSIS='...'
        [ -z "$PROMPTCHAR" ] && export PROMPTCHAR='>'
    fi

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

    # Clipboard

    if [ -n "$TMUX" ]; then
        export TMUXCOPY='tmux load-buffer -'
        export TMUXPASTE='tmux save-buffer -'
        eval 'tmuxcopy() { echo -n "$*" | '"$TMUXCOPY"' }'
    fi

    if [ -n "$CLIPCOPY" ]; then
        CLIPCOPY="$CLIPCOPY"
    elif [ -z "$SSH_CONNECTION" ] && which -s pbcopy >/dev/null 2>&1; then
        CLIPCOPY='pbcopy'
    elif [ -n "$DISPLAY" ]; then
        if which -s xclip >/dev/null 2>&1; then
            CLIPCOPY='xclip -selection c'
        elif which -s xsel >/dev/null 2>&1; then
            CLIPCOPY='xsel -i -b'
        fi
    elif [ -z "$SSH_CONNECTION" ]; then
        if which -s clip >/dev/null 2>&1; then
            CLIPCOPY='clip'
        elif [ -w '/dev/clipboard' ]; then
            CLIPCOPY='cat >/dev/clipboard'
        fi
    fi
    if [ -z "$CLIPCOPY" -a -n "$TMUXCOPY" ]; then
        CLIPCOPY="$TMUXCOPY"
    fi
    export CLIPCOPY

    if [ -n "$CLIPCOPY" ]; then
        alias -g CL="| $CLIPCOPY"
        eval 'clipcopy() { echo -n "$*" | '"$CLIPCOPY"' }'

        # Bind ^X to copy the current input to system clipboard
        copy-input() {
            [ -n "$BUFFER" ] && clipcopy "$BUFFER"
            prompt_vi_mode=' %F{white}(copied)%F{reset}'
            zle reset-prompt
        }
        zle -N copy-input
        bindkey '\C-X' copy-input
    fi

    if [ -n "$CLIPPASTE" ]; then
        CLIPPASTE="$CLIPPASTE"
    elif [ -z "$SSH_CONNECTION" ] && which -s pbpaste >/dev/null 2>&1; then
        CLIPPASTE='pbpaste'
    elif [ -n "$DISPLAY" ]; then
        if which -s xclip >/dev/null 2>&1; then
            CLIPPASTE='xclip -o -selection c'
        elif which -s xsel >/dev/null 2>&1; then
            CLIPPASTE='xsel -o -b'
        fi
    elif [ -z "$SSH_CONNECTION" -a -r '/dev/clipboard' ]; then
        CLIPPASTE='cat /dev/clipboard'
    fi
    if [ -z "$CLIPPASTE" -a -n "$TMUXPASTE" ]; then
        CLIPPASTE="$TMUXPASTE"
    fi
    export CLIPPASTE

    # Each line is pasted and escaped as a separate argument,
    # whitespace is trimmed, and already quoted (' or ") are not escaped
    escape-and-paste-input() {
        local IFS=$'\n'
        local pasted
        if [ -z "$1" ]; then
            pasted=("${(@f)$(clippaste)}")
        else
            pasted=("${(@f)*}")
        fi
        local line
        for line in $pasted; do
            line="${line##+( )}" # trim space
            line="${line%%+( )}"
            if [ -z "${line:/\'*\'}" -o -z "${line:/\"*\"}" ]; then
                # already quoted, don't escape
                LBUFFER="$LBUFFER$line "
            else
                # escape the string
                LBUFFER="$LBUFFER${(q)line} "
            fi
        done
        LBUFFER="${LBUFFER/% }"
    }

    if [ -n "$CLIPPASTE" ]; then
        eval 'clippaste() { '"$CLIPPASTE"' }'

        # Bind ^B to paste ("Baste"?) and escape from system clipboard
        paste-input() {
            escape-and-paste-input
        }
        zle -N paste-input
        bindkey '\C-B' paste-input
    fi

    if [ -n "$TMUX" -a -n "$TMUXPASTE" ]; then
        eval 'tmuxpaste() { '"$TMUXPASTE"' }'

        paste-tmux-input() {
            escape-and-paste-input "$(tmuxpaste)"
        }
        zle -N paste-tmux-input
        bindkey '\C-T' paste-tmux-input
    fi

    # Aliases
    alias gr='grep --color=auto --exclude-dir={.git,.hg,.svn,.bzr}'
    alias gs='git status --show-stash'
    alias cdr='[ -n "$REPO" ] && cd "$REPO"'

    # Make a directory (including parent diretory) and cd to it
    alias md='(){ mkdir -pv "$1" && cd "$1" }'

    # Make sudo apply to aliases as well
    alias sudo='sudo '

    # Redo last command with sudo
    alias please='sudo "$SHELL" -c "$(fc -ln -1)"'

    # Grep `ps` (more brute force than pgrep)
    alias psg='ps axww | grep --color=auto'

    # Grep `history`
    alias hgrep='history 1 | grep -i --color=auto'

    # Grep aliases
    alias agrep='alias | grep -i --color=auto'

    # Copy last command
    alias clc='clipcopy "$(fc -ln -1)"'
    alias clct='tmuxcopy "$(fc -ln -1)"'

    # Copy current directory
    alias cpwd='clipcopy "$PWD" && echo "$PWD"'

    # Copy symlink-resolved path to current directory
    alias cpath='( cd -P "$PWD" && clipcopy "$PWD" && echo "$PWD" )'

    # Neovim
    if which -s nvim >/dev/null 2>&1; then
        alias vi='nvim'
        alias nvimdiff='nvim -d'
        alias -g :VI='| nvim -R -'
        alias -g :VIM='|& nvim -R -'
        if which -s viman >/dev/null 2>&1; then
            [ -z "$MANPAGER" ] && export MANPAGER='viman'
        fi
    else
        alias -g :VI='| vim -R -'
        alias -g :VIM='|& vim -R -'
    fi
    if which -s viless >/dev/null 2>&1; then
        alias -g :VL='| viless'
    fi

    # fzf
    if which -s fzf >/dev/null 2>&1; then
        fzo() {
            sels=( "${(@f)$(fd "${fd_default[@]}" "${@:2}"| fzf)}" )
            test -n "$sels" && print -z -- "$1 ${sels[@]:q:q}"
        }

        # fuzzy-find in nearby directories, e.g., `fz vi`
        # can also take a path, such as `fz vi /usr/include`
        fz() fzo "$@" --max-depth 3

        # current directory only, e.g., `f. mv`
        f.() fzo "$@" --max-depth 1
    fi

    # Pipe shortcuts
    alias -g :L='| less -XRF'
    alias -g :LE='|& less -XRF'
    alias -g :G='| grep --color=auto'
    alias -g :FG='| grep -F --color=auto'
    alias -g :EG='| egrep --color=auto'
    alias -g :GR='|& grep --color=auto'
    alias -g :FGR='|& grep -F --color=auto'
    alias -g :H1='| head -1'
    alias -g :T1='| tail -1'
    alias -g :H='|& head -n $(( LINES / 2 + 1 ))'
    alias -g :T='|& tail -n $(( LINES / 2 + 1 ))'
    alias -g :S='| sort'
    alias -g :SN='| sort -n'
    alias -g :SU='| sort -u'
    alias -g :N='>/dev/null'
    alias -g :NUL='>/dev/null 2>&1'
    alias -g :WC='| wc -l'

    # System-specific variations
    case `uname`; in
        IRIX)
            alias psg='ps -efa | grep'
            ;;
        *)
            ;;
    esac

    # ls
    alias ll='ls -kl'
    alias la='ls -kla'
    alias l.='ls -d .*'

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

    # Completion
    autoload -Uz compinit && compinit ${=is_sudo:+-i}

    zstyle ':completion:*' verbose yes

    # Use cache if the directory exists
    if [ -e "$HOME/.zsh/cache" ]; then
        zstyle ':completion:*' use-cache on
        zstyle ':completion:*' cache-path ~/.zsh/cache
    fi

    # Ignore functions for commands we don't have
    zstyle ':completion:*:functions' ignored-patterns '_*'

    # Remove the trailing slash from directory completion
    zstyle ':completion:*' squeeze-slashes true

    # Don't complete the parent directory itself in `../<TAB>`
    zstyle ':completion:*:cd:*' ignore-parents parent pwd

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
    zstyle ':vcs_info:*:*' max-exports 6

    # 0: repository name
    # 1: branch
    # 2: repository subdir
    # 3: repository root path
    # 4: info markers
    # 5: actions
    zstyle ':vcs_info:*:*' formats '%r' '%b' '%S' '%R' '%c%u' ' '
    zstyle ':vcs_info:*:*' actionformats '%r' '%b' '%S' '%R' '%c%u' '%a'

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

    # Smarter kill word
    smart-backward-kill-word() {
        local WORDCHARS='-_'
        zle backward-kill-word
    }
    zle -N smart-backward-kill-word

    local mode
    # Key bindings
    bindkey '\C-P' history-beginning-search-backward
    bindkey '\C-N' history-beginning-search-forward
    bindkey '\e[5~' history-search-backward
    bindkey '\e[6~' history-search-forward
    bindkey '\e[1;3C' beginning-of-line
    bindkey '\e[1;3D' end-of-line
    bindkey '\C-W' smart-backward-kill-word
    bindkey '\C-K' kill-word
    bindkey '\C-U' kill-whole-line
    bindkey '\C-Y' yank
    bindkey '\C-Q' push-line-or-edit
    bindkey '\C-D' delete-char
    bindkey '\C-_' history-incremental-pattern-search-backward
    bindkey '\C-\\' history-incremental-pattern-search-forward
    bindkey -M vicmd '/' history-incremental-pattern-search-backward
    bindkey -M vicmd '?' history-incremental-pattern-search-forward
    bindkey '\C-L' clear-screen
    for mode in vicmd viins; do
        bindkey -M "$mode" '\C-R' redo
        bindkey -M "$mode" '\C-Z' undo
    done
    for mode in '-M vicmd' '-M viins' ''; do
        # Make navigation the same for vi mode
        bindkey ${=mode} '\e[C' forward-char
        bindkey ${=mode} '\e[D' backward-char
        bindkey ${=mode} '\eOC' forward-char
        bindkey ${=mode} '\eOD' backward-char
        bindkey ${=mode} '\e[1~' beginning-of-line
        bindkey ${=mode} '\e[4~' end-of-line
        bindkey ${=mode} '\e[5C' forward-word
        bindkey ${=mode} '\e[5D' backward-word
        bindkey ${=mode} '\e[1;5C' forward-word
        bindkey ${=mode} '\e[1;5D' backward-word
        bindkey ${=mode} '\e[3~' delete-char
        bindkey ${=mode} '\C-E' end-of-line
        if [[ "$mode" = '-M vicmd' ]]; then
            bindkey ${=mode} '\C-?' backward-char
            bindkey ${=mode} '\C-H' backward-char
            bindkey ${=mode} '\eOA' up-line
            bindkey ${=mode} '\eOB' down-line
            bindkey ${=mode} '\e[A' up-line
            bindkey ${=mode} '\e[B' down-line
        else
            bindkey ${=mode} '\C-A' beginning-of-line
            bindkey ${=mode} '\C-?' backward-delete-char
            bindkey ${=mode} '\C-H' backward-delete-char
            bindkey ${=mode} '\eOA' up-line-or-history
            bindkey ${=mode} '\eOB' down-line-or-history
            bindkey ${=mode} '\e[A' up-line-or-history
            bindkey ${=mode} '\e[B' down-line-or-history
        fi
    done
    unset mode

    autoload -U edit-command-line
    zle -N edit-command-line
    bindkey '\C- ' edit-command-line
    bindkey -M vicmd v edit-command-line

    # Vim-like surround
    autoload -Uz surround
    zle -N delete-surround surround
    zle -N add-surround surround
    zle -N change-surround surround
    bindkey -a 'cs' change-surround
    bindkey -a 'ds' delete-surround
    bindkey -a 'ys' add-surround
    bindkey -M visual 'S' add-surround

    # In vi-mode, type vi" to select quoted text
    autoload -U select-quoted
    zle -N select-quoted
    for m in visual viopp; do
        for c in {a,i}{\',\",\`}; do
            bindkey -M $m $c select-quoted
        done
    done

    # Expand uppercase aliases as we type (credit: Pat Regan)
    expand-global-alias() {
        if [[ $LBUFFER =~ ' [:][A-Z0-9]+$' ]]; then # Only expand uppercase aliases
         zle _expand_alias
         #zle expand-word
       fi
       zle self-insert
    }
    zle -N expand-global-alias
    bindkey ' ' expand-global-alias
    bindkey -M isearch ' ' magic-space  # normal space during searches
    # Note: Do Ctrl-V + space to force a space without completing

    # Terminal title (or screen/tmux hardstatus)
    case "$TERM" in
        tmux*|screen*)
            export TITLE_SET_HEAD=`echo -ne '\033_'`
            export TITLE_SET_TAIL=`echo -ne '\033\\'`
            ;;
        xterm*|rxvt*)
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
            local line="${1/#(exec|nice|nohup|time|sudo) /}"
            local cmd="${line%% *}"
            line="${line:0:30}"
            local title="$line"
            if [[ ${#cmd} -gt ${#line} ]]; then
                title="$cmd" # If the command is longer than the truncated line, show it anyway
            elif [[ ${#1} -lt 26 ]]; then
                title="$1" # If the untruncated line is short enough, show it all
            fi
            if [[ ${#title} -gt 25 ]]; then
                title="${title:0:25}$ELLIPSIS"
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
            print -Pn '%n@%m'
            if [ -n "$vcs_info_msg_0_" ]; then
                print -n " $vcs_info_msg_0_/$vcs_info_msg_1_$vcs_info_msg_4_"
            fi
            print -n "$TITLE_SET_TAIL"
        }
        precmd_functions+=( set_title_prompt )
    fi

    if [ "$TERM_PROGRAM" = 'Apple_Terminal' ] && [[ $TERM != (screen|tmux)* ]]; then
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
            print -Pn "\e]7;file://%M"
            print -n "$pwd_url\a"
        }
        chpwd_functions+=( set_terminal_dir )
        set_terminal_dir # Set the initial directory
    fi

    # Change cursor to indicate vi mode
    function zle-line-init zle-keymap-select {
        case "$KEYMAP" in
            vicmd)
                print -n '\033[1 q'
                prompt_vi_mode="%F{yellow}(vi)%F{reset} "
                ;;
            *)
                print -n '\033[ 0q\033[5 q'
                prompt_vi_mode=''
                ;;
        esac
        zle reset-prompt
    }
    zle -N zle-line-init
    zle -N zle-keymap-select

    accept-line-vicmd() {
        prompt_vi_mode=''
        zle reset-prompt
        zle accept-line
    }
    zle -N accept-line-vicmd
    bindkey -M vicmd '\C-M' accept-line-vicmd

    # Prompt
    pwd_prompt=''
    vcs_prompt=''

    format_pwd() {
        setopt localoptions extendedglob

        if [ -n "$vcs_info_msg_0_" ]; then
            # Inside a git repository: start display from the repository base
            local repo="$vcs_info_msg_0_/$vcs_info_msg_2_"
            # Strip the trailing '/.' if we are in the repo root dir
            repo="${repo/%\/./}"
            if [ "$PWD" = "$HOME/$repo" ]; then
                pwd_prompt="~/$repo"
            elif [ ${#PWD} -le $(( ${#repo} + 5 )) ]; then
                # Don't abbreviate if it saves fewer than 5 chars
                pwd_prompt="${PWD/#$HOME/~}"
            else
                pwd_prompt="…/$repo"
            fi
            unset repo
            export REPO="$vcs_info_msg_3_"
        else
            # Use ~ to represent the home directory
            pwd_prompt="${PWD/#$HOME/~}"

            # Substitute the iCloud documents path
            pwd_prompt="${pwd_prompt/#\~\/Library\/Mobile Documents\/com\~apple\~CloudDocs/…iCloud}"
            # If we are inside a macOS .app directory, preserve the app name
            pwd_prompt="${pwd_prompt/#*\/(#b)([^\/]##.app)\/Contents\//…/$match[1]/…/}"

            unset REPO
            export REPO
        fi

        # Keep the first and last two directories only
        local trimmed="${pwd_prompt:/#%(#b)((…[[:alpha:]]#|\~|)\/[^\/]##\/[^\/]##\/)(#b)([^\/]##\/)##(#b)([^\/]##\/[^\/]##)/$match[1]…/$match[4]}"
        [[ ${#trimmed} -lt ${#pwd_prompt} ]] && pwd_prompt="$trimmed"

        # Clean up multiple ellipses
        pwd_prompt="${pwd_prompt//(…\/)##/…/}"

        # Convert the UTF-8 ellipsis if necessary
        [[ $ELLIPSIS != '…' ]] && pwd_prompt="${pwd_prompt//…/${ELLIPSIS:-...}}"

        vcs_prompt=''
        vcs_status=''
        if [ -n "$vcs_info_msg_0_" ]; then
            vcs_prompt='%F{white}'
            trimmed="$vcs_info_msg_1_"
            [[ ${#trimmed} -gt 20 ]] && trimmed="${trimmed//#*\//}"

            local pwd_truncated=''
            local columns="${COLUMNS:-0}"
            columns=$(( columns - ${#pwd_prompt} - 3 ))
            if [[ $columns -lt 65 ]]; then
                columns=65
                pwd_truncated=1
                [[ $columns -gt $(( COLUMNS  - 5 )) ]] && columns=$(( COLUMNS - 5 ))
            fi

            if [ "$trimmed" = 'master' -a $(( space - ${#vcs_info_msg_0_} )) -lt 40 ]; then
                trimmed='m'
            fi

            local used=${#trimmed}
            [[ $used -gt 20 ]] && used=20
            used=$(( used + 5 ))

            local space=$(( columns - used ))

            if [ -n "$pwd_truncated" -a $space -gt 20 ]; then
                # Only show repo on right if it may be truncated on left
                vcs_prompt+="%$(( -(columns - 10) ))<${ELLIPSIS:-...}<${vcs_info_msg_0_//\%/%%}%<<"
            fi
            if [ "$vcs_info_msg_1_" = 'master' ]; then
                vcs_prompt+="/%F{blue}${trimmed}"
            else
                vcs_prompt+="/%F{cyan}%20<${ELLIPSIS:-...}<${trimmed//\%/%%}%<<"
            fi

            # Show markers for changes in repo
            [ -n "$vcs_info_msg_4_" ] && vcs_prompt+="%F{yellow}${vcs_info_msg_4_//\%/%%}"

            if [ -n "$vcs_info_msg_5_" -a ! "$vcs_info_msg_5_" = ' ' ]; then
                vcs_status="%F{white}%-5>${ELLIPSIS:-...}>${vcs_info_msg_5_//\%/%%}%>>%F{reset}"
            fi

            unset columns used pwd_truncated space
        fi

        # Escape any percents to avoid prompt expansion
        pwd_prompt="${pwd_prompt//\%/%%}"

        unset trimmed
    }
    precmd_functions+=( format_pwd )

    zle_highlight=( 'isearch:underline' 'special:fg=cyan' 'paste:bold,fg=red' 'suffix:fg=white' 'region:standout' )

    # Left prompt:
    # Line 1: [$? on error] $! (vi mode) [user on sudo to non-root] [git misc]
    # Line 2: [shortened path][$PROMPTCHAR if non-root, # if root]
    #
    # Right prompt:
    # [git repo/branch] [markers if there are local changes]

    export pwd_prompt="$PWD"
    export vcs_prompt=''
    export vcs_status=''
    export prompt_vi_mode=''
    export PROMPT='%(?..%F{red}?$?%F{reset} )%F{white}!%! %(!__${SUDO_USER:+%n })${prompt_vi_mode}${vcs_status}
%F{cyan}%-60<$ELLIPSIS<${pwd_prompt:-%~}%<<%F{reset}%(!_#_${PROMPTCHAR:-%#}) '
    export RPROMPT='    %F{magenta}%(1j.%j&.)$vcs_prompt%F{reset}'

    # Syntax highlighting
    local hlpath
    for hlpath in "$HOME/.zsh" '/usr/local/share' '/usr/share'; do
        [ -r "$hlpath/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] || continue
        [ -n "$ZSH_NO_SYNTAX_HIGHLIGHT" ] && continue
        export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$hlpath/zsh-syntax-highlighting/highlighters"
        typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[default]='none'

        local style
        for style in arg0 command builtin reserved-word hashed-command command-substitution process-substitution; do
            ZSH_HIGHLIGHT_STYLES[$style]='bold'
        done
        for style in unknown-token path; do
            ZSH_HIGHLIGHT_STYLES[$style]='none'
        done
        for style in redirection named-fd commandseparator single-hyphen-option double-hyphen-option; do
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
        ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=magenta'
        ZSH_HIGHLIGHT_STYLES[global-alias]='fg=magenta,bold'

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

    unset is_root
    unset is_sudo
else
    echo "$PATH" | grep -qE '(^|:)/usr/local/bin(:|$)' || export PATH="/usr/local/bin:$PATH"
fi

[ -d "$HOME/.rvm/bin" ] && export PATH="$PATH:$HOME/.rvm/bin"

# Make path unique
typeset -aU path
