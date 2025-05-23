# .zshrc
# Kimmo Kulovesi <https://arkku.dev>

disable log

# Add custom functions directory to fpath
if [ -e "$HOME/.zsh/functions" ]; then
    fpath=( "$HOME/.zsh/functions" "${fpath[@]}" )
    autoload -Uz ${${(f)"$(print -l "$HOME/.zsh/functions"/*)"}##*/}
fi

# Try to determine the background color
if [ -z "$BACKGROUND" ]; then
    if [ -n "$COLORFGBG" ]; then
        if [[ $COLORFGBG =~ '[,;][0-68]$' ]]; then
            BACKGROUND=dark
        elif [[ $COLORFGBG =~ '[,;](7|1[0-9])$' ]]; then
            BACKGROUND=light
        fi
    else
        case "$TERM" in
            (linux*|ansi|vt*|dos*|bsd*|mach*|console*|con*)
                BACKGROUND=dark
                ;;
            (*)
                ;;
        esac
    fi
    export BACKGROUND
fi

# The "faded" (hard to see) color for the background
if [ "$BACKGROUND" = 'dark' ]; then
    FADED_COLOR='8'
else
    FADED_COLOR='7'
fi

if [[ -o interactive ]] && [ -n "$PS1" -a -z "$ENVONLY" ]; then
    # Vi-mode
    bindkey -v
    setopt vi

    export KEYTIMEOUT=1

    local is_root=`print -nP '%(!_1_)'`
    local is_sudo="${is_root:-$SUDO_USER}"

    autoload -Uz colors && colors

    # A better move/rename command
    autoload -Uz zmv

    # Test for UTF-8
    if [ -z "$NOUTF8" ] && locale 2>/dev/null | grep -qi -e 'LC_CTYPE.*UTF-8' -e 'LC_CTYPE.*utf8'; then
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
    setopt hist_find_no_dups
    setopt hist_expire_dups_first
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
    elif [ -z "$SSH_CONNECTION" -a -n "$(command -v pbcopy)" ]; then
        CLIPCOPY='pbcopy'
    elif [ -n "$DISPLAY" ]; then
        if [ -n "$(command -v xclip)" ]; then
            CLIPCOPY='xclip -selection c'
        elif [ -n "$(command -v xsel)" ]; then
            CLIPCOPY='xsel -i -b'
        fi
    elif [ -z "$SSH_CONNECTION" ]; then
        if [ -n "$(command -v clip)" ]; then
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
        alias -g :CL="| $CLIPCOPY"
        eval 'clipcopy() { echo -n "$*" | '"$CLIPCOPY"' }'

        # Bind ^X to copy the current input to system clipboard
        copy-input() {
            [ -n "$BUFFER" ] && clipcopy "$BUFFER"
            prompt_vi_mode=" %F{$FADED_COLOR}(copied)%F{reset}"
            zle reset-prompt
        }
        zle -N copy-input
        bindkey '\C-X' copy-input
    fi

    if [ -n "$CLIPPASTE" ]; then
        CLIPPASTE="$CLIPPASTE"
    elif [ -z "$SSH_CONNECTION" -a -n "$(command -v pbpaste)" ]; then
        CLIPPASTE='pbpaste'
    elif [ -n "$DISPLAY" ]; then
        if [ -n "$(command -v xclip)" ]; then
            CLIPPASTE='xclip -o -selection c'
        elif [ -n "$(command -v xsel)" ]; then
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
    _escape-and-paste-input() {
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
    zle -N _escape-and-paste-input

    if [ -n "$CLIPPASTE" ]; then
        eval 'clippaste() { '"$CLIPPASTE"' }'

        # Bind ^B to paste ("Baste"?) and escape from system clipboard
        zle -N _escape-and-paste-input
        bindkey '\C-B' _escape-and-paste-input
    fi

    if [ -n "$TMUX" -a -n "$TMUXPASTE" ]; then
        eval 'tmuxpaste() { '"$TMUXPASTE"' }'

        _paste-tmux-input() {
            zle _escape-and-paste-input "$(tmuxpaste)"
        }
        zle -N _paste-tmux-input
        bindkey '\C-T' _paste-tmux-input
    fi

    # Aliases

    # Grep while excluding version control dirs
    alias gr='grep --color=auto --exclude-dir={.git,.hg,.svn,.bzr}'

    # Git status
    alias gs='git status'

    # Git show last commit
    alias glast='git log -1 -p HEAD'

    # Git clone
    alias gcl='git clone --recurse-submodules'

    # Git fetch all
    alias gfa='git fetch --all --prune'

    # Git pull
    alias gpull='git pull'

    # Print the git main branch name (master, main)
    alias gitmainbranch='git branch -l master main | awk '\''{print $1}'\' 

    # Get pull master
    alias gpullm='git fetch origin `gitmainbranch`:`gitmainbranch`'

    # Git update from remote
    alias gupdate='git pull --rebase --autostash -v'

    # Git push
    alias gpush='git push'

    # Git push with tags
    alias gpusht='git push && git push --tags'

    # Git push all
    alias gpusha='git push --all && git push --tags'

    # Git push and set upstream
    alias gpushup='git push -u origin HEAD'

    # Git ubdate submodules, recursively
    alias gsubu='git submodule update --init --recursive'

    # Git update submodules from remote, recursively
    alias gsubr='git submodule update --init --remote --recursive'

    # Git log with a graph
    alias ggl='git log --oneline --decorate --graph --all'

    # Git list files
    alias gls='git ls-files --exclude-standard'

    # Git list modified files
    alias glsm='git ls-files -m -o --exclude-standard'

    # Git new branch
    alias gbranch='git checkout -b'

    # Git new feature branch on remote
    gfeature() {
        local branch="$1"
        if [ -z "$branch" ] ; then
            echo "Usage: $0 new_feature_branch [remote]"
            return 1
        fi
        [[ "$branch" != "feature/"* && "$branch" != "fix/"* ]] && branch="feature/$branch"
        local remote="$2"
        [ -z "$remote" ] && remote='origin'
        git checkout -b "$branch" && git push -u "$remote" HEAD
    }

    # Git push and then close/delete the current feature branch
    gfeaturedone() {
        local branch="$(git rev-parse --abbrev-ref HEAD)"
        local trunk='master'
        [ -z "$1" ] && master="$1"
        if [ -z "$branch" -o "$branch" = "$trunk" ] || ! [[ "$branch" == "feature/"* ]]; then
            echo 'Must be run on a feature branch!'
            return 1
        fi
        git push && git checkout "$trunk" && git branch -D "$branch"
    }

    # Git new tag, pushed to remote
    gtag() {
        if [ -z "$1" ]; then
            echo "Usage: $0 new_tag"
            return 1
        fi
        git tag -s "$@" && git push --tags
    }

    # Git reset to merge base
    gresetmb() {
        local trunk="$1"
        [ -z "$1" ] && trunk='master'
        local base="$(git merge-base "$trunk" HEAD)"
        if [ -n "$base" ]; then
            git reset "$base"
        else
            echo "Error: HEAD does not have a common ancestor with $trunk" >&2
            return 1
        fi
    }

    # cd to the root of the git repository
    cdr() {
        REPO="$(git rev-parse --show-toplevel)"
        [ -z "$REPO" ] && return 1
        cd "$REPO"
    }

    # cd to the outermost git repository (from nested submodules)
    cdrr() {
        local gitroot="$(git rev-parse --show-toplevel)"
        [ -z "$gitroot" ] && return 1
        while [ -n "$gitroot" ]; do
            cd "$gitroot" || return 1
            gitroot="$(git rev-parse --show-superproject-working-tree 2>/dev/null)"
        done
        return 0
    }

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

    # Paste command-line (mnemonic to match `clc`)
    alias plc='print -z -- "$(clippaste)"'
    alias plct='print -z -- "$(tmuxpaste)"'

    # Copy current directory
    alias cpwd='clipcopy "$PWD" && echo "$PWD"'

    # Copy symlink-resolved path to current directory
    alias cpath='( cd -P "$PWD" && clipcopy "$PWD" && echo "$PWD" )'

    # sudo-edit
    alias svi='sudo -e'

    # Neovim
    if [ -n "$(command -v nvim)" ]; then
        alias vi='nvim'
        alias nvimdiff='nvim -d'
        alias -g :VI='| nvim -R -'
        alias -g :VIM='|& nvim -R -'
        if [ -n "$(command -v viman)" ]; then
            if [ -z "$MANPAGER" -a -z "$MANROFFOPT" ]; then
                export MANROFFOPT='-c'
                export MANPAGER='viman'
            fi
        fi
        nvis() {
            if [ -e "Session.vim" ]; then
                nvim -S Session.vim "$@"
            else
                nvim "$@"
            fi
        }
    else
        alias -g :VI='| vim -R -'
        alias -g :VIM='|& vim -R -'
    fi
    if [ -n "$(command -v viless)" ]; then
        alias -g :VL='| viless'
    fi

    # bat
    if [ -n "$(command -v bat)" ]; then
        bat() {
            if [ "$1" = 'cache' ]; then
                command bat "$@"
            else
                local batargs
                batargs=()
                local batstyle=''

                [ "$BACKGROUND" = 'dark' ] && batargs+=( "--theme=Arkku Dark" )

                local filecount=0
                for arg in "$@"; do
                    [ -f "$arg" ] && filecount=$(( filecount + 1 ))
                done

                if [ "$filecount" -ge 1 ]; then
                    # In git repo with changes, show changes
                    [ -n "$REPO" -a -n "$vcs_info_msg_4_" ] && batstyle=',changes'
                    # Multiple files, show grid
                    [ "$filecount" -ge 2 ] && batstyle+=',header,grid'
                fi
                [ -n "$batstyle" ] && batargs+=( "--style=${batstyle/#,}" )
                command bat "${batargs[@]}" "$@"
            fi
        }
    fi

    # fzf
    if [ -n "$(command -v fzf)" ]; then
        # Type ~~<Tab> to start fzf completion
        export FZF_COMPLETION_TRIGGER='~~'
        export FZF_COMPLETION_OPTS='+c -x'
        #export FZF_TMUX=1
        export FZF_TMUX_HEIGHT='30%'
        export FZF_DEFAULT_OPTS='--layout=reverse'

        if whence fzf-completion >/dev/null 2>&1; then
            # fzf is probably sourced first so the completion binding breaks
            bindkey -M viins '\C-I' fzf-completion
        fi

        # use fd with fzf (note: symlink /usr/bin/fdfind to ~/bin/fd)
        if [ -n "$(command -v fd)" ]; then
            export FZF_DEFAULT_COMMAND='fd --color=always --exclude .git'

            fzfind() {
                local fdargs=( '--color=always' '--exclude' '.git' )
                local fzfargs=( )
                local have_path=''
                while [ $# -ge 1 ]; do
                    local arg="$1"
                    shift
                    case "$arg" in
                        (--fzf)
                            fzfargs+=( "$1" )
                            shift
                            ;;
                        (-*)
                            fdargs+=( "$arg" )
                            ;;
                        (*)
                            [ -d "$arg" ] && have_path="$arg"
                            fdargs+=( "$arg" )
                            ;;
                    esac
                done
                [ -n "$have_path" -a ! "$have_path" = '.' ] && fdargs=( '.' "${fdargs[@]}" )
                fd -0 "${fdargs[@]}" 2>/dev/null \
                    | fzf --read0 --ansi --reverse \
                    --preview="file -b -h {} 2>/dev/null; ls -lah {} 2>/dev/null" \
                    --preview-window='top:40%:wrap' "${fzfargs[@]}"
            }

            ffz() { fzfind --fzf -m "$@"  }
            fff() { fzfind --fzf -m --type=file --hidden "$@"  }
            ffd() { fzfind --type=directory --hidden "$@" }
            ff.() { fzfind --fzf -m --max-depth 1 --hidden "$@" }
        else
            ffz() {
                local fdargs=( '-not' '-iwholename' '*/.git/*' )
                local fzfargs=( )
                local have_path='.'
                local value_next=''
                while [ $# -ge 1 ]; do
                    local arg="$1"
                    shift
                    case "$arg" in
                        (--fzf)
                            fzfargs+=( "$1" )
                            shift
                            ;;
                        (-*)
                            fdargs+=( "$arg" )
                            value_next=1
                            ;;
                        (*)
                            if [ -d "$arg" ]; then
                                have_path="$arg"
                            elif [ -n "$value_next" ]; then
                                value_next=''
                                fdargs+=( "$arg" )
                            else
                                fdargs+=( -iwholename "*$arg*" )
                            fi
                            ;;
                    esac
                done
                find "${have_path:-.}" "${fdargs[@]}" 2>/dev/null \
                    | fzf --ansi -m --reverse \
                    --preview="file -b -h {} 2>/dev/null; ls -lah {} 2>/dev/null" \
                    --preview-window='top:40%:wrap' "${fzfargs[@]}"
            }

            fff() { ffz -type f "$@"  }
            ffd() { ffz -type d "$@" }
            ff.() { ffz -depth 1 "$@" }
        fi

        _last_argument() {
            echo 
        }

        # Ctrl-F to find from insert mode
        _fuzzy-find() {
            local dir=''
            local fdargs=''
            local -a args
            args=(${(z)LBUFFER})
            local buf=$args[-1]
            buf="${buf/#\~/$HOME}"
            if [ -d "${buf:Q}" ]; then
                dir="${buf:Q}"
                fdargs=' .'
            else
                buf=''
            fi
            local sels=( "${(@f)$(ffz --max-depth 4 ${dir:-.} \
                --fzf --bind \
                --fzf 'ctrl-f:reload(fd -0'"$fdargs"' --color=always --hidden --type=file --max-depth 1 '"${buf:-.}"' 2>/dev/null)' \
                --fzf --bind \
                --fzf 'ctrl-d:reload(fd -0'"$fdargs"' --color=always --hidden --exclude .git --type=directory '"${buf:-.}"' 2>/dev/null)' \
                --fzf --bind \
                --fzf 'ctrl-a:reload(fd -0'"$fdargs"' --color=always --hidden --max-depth 4 --exclude .git '"${buf:-.}"' 2>/dev/null)' \
                --fzf --bind \
                --fzf 'ctrl-g:reload(git -C '"${buf:-}"' ls-files -c -z --exclude-standard --recurse-submodules 2>/dev/null)' \
                --fzf --header \
                --fzf 'Esc: Close | Tab: Select | ^A: Show All | ^D: Directories | ^G: Git | ^F: Files' \
                "$@")}" )

            local quoted="${sels[@]:q}"
            [ -z "$quoted" ] && return

            if [ -n "$dir" ]; then
                local oldbuf="$LBUFFER"
                LBUFFER="${LBUFFER%$buf}"
                if [ "$oldbuf" = "$LBUFFER" ]; then
                    buf="${buf/#$HOME/~}"
                    LBUFFER="${LBUFFER/%$buf}"
                    quoted=" $quoted"
                    quoted="${quoted// $HOME\// ~/}"
                    quoted="${quoted/# /}"
                fi
            fi
            LBUFFER+="$quoted "
            [ -n "$widgets[autosuggest-clear]" ] && zle autosuggest-clear
        }
        zle -N _fuzzy-find
        bindkey -M viins '\C-F' _fuzzy-find

        # fuzzy-find a directory and cd to it
        cdf() {
            local seld="$(ffd "$@")"
            [ -n "$seld" ] && pushd "$seld" >/dev/null
        }

        # fuzzy-find a file and cd to its directory
        cdff() {
            local seld="$(fff "$@")"
            [ -n "$seld" ] && pushd "$(dirname "$seld")"
        }

        # fuzzy-find in history and paste to command-line
        fzh() {
            local selh="$(history -1 0 | fzf --query="$@" --ansi --no-sort -m --height=50% --min-height=25 -n 2.. | awk '{ sub(/^[ ]*[^ ]*[ ]*/, ""); sub(/[ ]*$/, ""); print }')"
            [ -n "$selh" ] && print -z -- ${selh}
        }

        _fuzzy-history() {
            local selh="$(history -1 0 | fzf --query="$BUFFER" --ansi --no-sort -m --height=50% --min-height=25 -n 2.. | awk '{ sub(/^[ ]*[^ ]*[ ]*/, ""); sub(/[ ]*$/, ""); print }')"
            if [ -n "$selh" ]; then
                LBUFFER="$selh"
                RBUFFER=''
            fi
            [ -n "$widgets[autosuggest-clear]" ] && zle autosuggest-clear
            zle reset-prompt
        }
        zle -N _fuzzy-history
        bindkey -M viins '\C-R' _fuzzy-history

        # kill process selected with fzf
        fzk() {
            local showall=''
            [[ $EUID = 0 ]] && showall=e
            ps "${showall}xu" \
                | sed 1d \
                | eval "fzf ${FZF_DEFAULT_OPTS} -m --reverse --header='[kill ${@:-process}]'" \
                | tee /dev/stderr \
                | awk '{ print $2 }' \
                | xargs kill "$@"
        }

        # A bunch of git wrappers using fzf
        [ -s "$HOME/.fzfgit.zsh" ] && . "$HOME/.fzfgit.zsh"
    else
        bindkey -M viins '\C-R' history-beginning-search-backward
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
    alias -g :H='| head'
    alias -g :T='| tail'
    alias -g :S='| sort'
    alias -g :SN='| sort -n'
    alias -g :SU='| sort -u'
    alias -g :N='>/dev/null'
    alias -g :NUL='>/dev/null 2>&1'
    alias -g :WC='| wc -l'

    if [ -n "$(command -v ag)" ]; then
        alias -g :AG='| ag'
    fi
    if [ -n "$(command -v rg)" ]; then
        alias -g :RG='| rg --smart-case'
    fi

    # System-specific variations
    case `uname` in
        IRIX)
            alias psg='ps -efa | grep'
            ;;
        *)
            ;;
    esac

    # cd to the directory of a file
    fcd() {
        if [ -d "$1" ]; then
            cd "$1"
        else
            cd "$(dirname "$1")"
        fi
    }

    [ -n "$COLORTERM" -a -z "$CLICOLOR" ] && export CLICOLOR=1

    if [ -r "$HOME/.dir_colors" -a -n "$(command -v dircolors)" ]; then
        eval `dircolors -b "$HOME/.dir_colors"`
    fi

    if [ -n "$(command -v exa)" -a "$CLICOLOR" -eq 1 ]; then
        # use exa instead of ls for long listings when available w/ colours
        alias exa='exa --group-directories-first --sort=name'
        alias l='exa -Fx'
        alias ll='exa -lgFH --git'
        alias la='ll -a -@'
        export EXA_COLORS="da=37:Makefile=0;33:README*=0;33:lm=4:uu=0:un=1:gu=0:gn=1:${EXA_COLORS:+:$EXA_COLORS}"
    else
        # ls
        alias l='ls'
        alias ll='ls -kl'
        alias la='ls -kla'
    fi
    alias l.='ls -d .*'

    if ls --version 2>/dev/null | grep -q GNU; then
        alias ls='ls -F --color=auto --group-directories-first'
    elif [ "$CLICOLOR" = 1 ] && ls -G "$HOME" >/dev/null 2>&1; then
        if [[ $BACKGROUND == 'light' ]]; then
            # ls on macOS does not support X for bold, and the bold
            # black would be invisible on dark background
            export LSCOLORS='AxfxHehecxegehBDBDAhaD'
        else
            export LSCOLORS='ExfxHehecxegehBDBDAhaD'
        fi
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
    #zstyle ':completion:*:messages' format "%F{$FADED_COLOR}# %d"$DEFAULT
    zstyle ':completion:*:warnings' format "%F{$FADED_COLOR}# No matches for: %d"$DEFAULT
    #zstyle ':completion:*:descriptions' format "%F{$FADED_COLOR}# %B%d%b%f"$DEFAULT

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

    # Smarter kill word
    _smart-backward-kill-word() {
        local WORDCHARS='-_'
        zle backward-kill-word
    }
    zle -N _smart-backward-kill-word

    local mode

    # Key bindings
    bindkey '\C-P' history-beginning-search-backward
    bindkey '\C-N' history-beginning-search-forward
    bindkey '\e[5~' history-search-backward
    bindkey '\e[6~' history-search-forward
    bindkey '\e[1;5A' up-line
    bindkey '\e[1;5B' down-line
    bindkey '\C-W' _smart-backward-kill-word
    bindkey '\e\C-?' _smart-backward-kill-word
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
    bindkey -M vicmd '\C-R' redo
    for mode in '-M vicmd' '-M viins' ''; do
        # Make navigation the same for vi mode
        bindkey ${=mode} '\e[C' forward-char
        bindkey ${=mode} '\e[D' backward-char
        bindkey ${=mode} '\eOC' forward-char
        bindkey ${=mode} '\eOD' backward-char
        bindkey ${=mode} '\e[1~' beginning-of-line
        bindkey ${=mode} '\e[4~' end-of-line
        bindkey ${=mode} '\e[H' beginning-of-line
        bindkey ${=mode} '\e[F' end-of-line
        bindkey ${=mode} '\e[5C' forward-word
        bindkey ${=mode} '\e[5D' backward-word
        bindkey ${=mode} '\e[1;5C' end-of-line
        bindkey ${=mode} '\e[1;5D' beginning-of-line
        bindkey ${=mode} '\e[3~' delete-char
        bindkey ${=mode} '\C-E' end-of-line
        bindkey ${=mode} '\e[1;3A' beginning-of-line
        bindkey ${=mode} '\e[1;3B' end-of-line
        bindkey ${=mode} '\e[1;3C' forward-word
        bindkey ${=mode} '\e[1;3D' backward-word
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
    bindkey -a '\C- ' edit-command-line

    # Execute `fg` on Ctrl-Z if the buffer is empty
    _zle-insmode-ctrlz() {
        if [ -z "$BUFFER" ]; then
            if zle push-line-or-edit && [ -z "$BUFFER" ]; then
                LBUFFER=' fg'
                zle accept-line
            fi
        else
            zle self-insert
        fi
    }
    zle -N _zle-insmode-ctrlz
    bindkey -M viins '\C-Z' _zle-insmode-ctrlz

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
    local m c
    for m in visual viopp; do
        for c in {a,i}{\',\",\`}; do
            bindkey -M $m $c select-quoted
        done
    done
    unset m c

    # Toggle "sudo" at the beginning of the command line
    _toggle-sudo() {
        if [[ -z $BUFFER ]]; then
            LBUFFER='please'
        elif [[ $BUFFER == please ]]; then
            LBUFFER=''
        elif [[ $BUFFER == sudo\ * ]]; then
            LBUFFER="${LBUFFER#sudo }"
        elif [[ $BUFFER == svi\ * ]]; then
            LBUFFER="${LBUFFER#svi }"
            LBUFFER="$EDITOR $LBUFFER"
        elif [[ $BUFFER == $EDITOR\ * ]]; then
            LBUFFER="${LBUFFER#$EDITOR }"
            LBUFFER="svi $LBUFFER"
        elif [[ $BUFFER == vi\ * ]]; then
            LBUFFER="${LBUFFER#vi }"
            LBUFFER="svi $LBUFFER"
        else
            LBUFFER="sudo $LBUFFER"
        fi
    }
    zle -N _toggle-sudo
    bindkey -M viins '\C-S' _toggle-sudo

    # Expand uppercase aliases as we type (credit: Pat Regan)
    expand-global-alias() {
        if [[ $LBUFFER =~ ' [:][A-Z0-9]+$' ]]; then # Only expand :ALIASes
         zle _expand_alias
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
            setopt localoptions extendedglob
            local line="${1/#(exec|nice|nohup|time) /}"
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

    _accept-line-vicmd() {
        prompt_vi_mode=''
        zle reset-prompt
        zle accept-line
    }
    zle -N _accept-line-vicmd
    bindkey -M vicmd '\C-M' _accept-line-vicmd

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
            vcs_prompt="%F{$FADED_COLOR}"
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
                vcs_status="%F{$FADED_COLOR}%-5>${ELLIPSIS:-...}>${vcs_info_msg_5_//\%/%%}%>>%F{reset}"
            fi

            unset columns used pwd_truncated space
        fi

        # Escape any percents to avoid prompt expansion
        pwd_prompt="${pwd_prompt//\%/%%}"

        unset trimmed
    }
    precmd_functions+=( format_pwd )

    # Load fasd if it is installed and ~/.fasd-init-zsh exists (touch it!)
    local fasd_cache="$HOME/.fasd-init-zsh"
    if [ -w "$fasd_cache" -a -n "$(command -v fasd )" ]; then
        if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
            fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install >| "$fasd_cache"
        fi
        source "$fasd_cache"
        unset fasd_cache

        if [ -n "$(command -v nvim)" ]; then
            alias v='f -e nvim'
            alias vv='sf -e nvim'
        else
            alias v='f -e vim'
            alias vv='sf -e vim'
        fi

        if [ -n "$(command -v fzf)" ]; then
            fasd_fzf() {
                local fargs="$1"
                shift
                local cmd=''
                if [ "$1" = '-e' ]; then
                    shift
                    cmd="$1"
                    shift
                fi
                local sel="$(fasd "$fargs" -- "$@" | fzf --ansi -1 -0)"
                [ -z "$sel" ] && return
                if [ -n "$cmd" ]; then
                    "$cmd" "$sel"
                else
                    echo "$sel"
                fi
            }

            # fzf select a directory from fasd list
            unalias sd 2>/dev/null
            sd() {
                fasd_fzf -ld "$@"
            }

            # fzf select a file from fasd list
            unalias sf 2>/dev/null
            sf() {
                fasd_fzf -lf "$@"
            }

            # fzf select a file or directory from fasd list
            unalias any 2>/dev/null
            any() {
                fasd_fzf -la "$@"
            }

            # replace the fasd interactive selection with fzf
            unalias zz 2>/dev/null
            zz() {
                local dir="$(sd "$@")"
                [ -n "$dir" ] && cd "$dir"
            }

            # replace the fasd interactive selection with fzf
            unalias zzz 2>/dev/null
            zzz() {
                local file="$(any "$@")"
                if [ -d "$file" -a ! "$file" = '/' ]; then
                    cd "$file/.."
                elif [ -n "$file" ]; then
                    cd "$(dirname "$file")"
                fi
            }
        fi
    elif [ -e "$HOME/.z" ]; then
        # If fasd didn't exist, then load z.sh if both it and ~/.z exist
        local zdir
        for zdir in "$HOME/.profile.d" '/usr/local/etc/profile.d' '/etc/profile.d'; do
            if [ -r "$zdir/z.sh" ]; then
                source "$zdir/z.sh"
                break
            fi
        done
        unset zdir
    fi
    unset fasd_cache

    zle_highlight=( 'isearch:underline' 'special:fg=cyan' 'paste:bold,fg=red' "suffix:fg=$FADED_COLOR" 'region:standout' )

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
    export PROMPT='%(?..%F{red}?$?%F{reset} )%F{'"$FADED_COLOR"'}!%! %(!__${SUDO_USER:+%n })${prompt_vi_mode}${vcs_status}
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
            ZSH_HIGHLIGHT_STYLES[$style]="fg=$FADED_COLOR"
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

        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=$FADED_COLOR"

        source "$hlpath/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets cursor )

        unset style
        break
    done
    unset hlpath

    # If there is no syntax highlighting installed, make the prompt input bold
    if [ -z "$ZSH_HIGHLIGHT_HIGHLIGHTERS" ]; then
        zle_highlight+=( 'default:bold' )
    else
        local aspath
        for aspath in "$HOME/.zsh" '/usr/local/share' '/usr/share'; do
            [ -r "$aspath/zsh-autosuggestions/zsh-autosuggestions.zsh" ] || continue
            ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
            ZSH_AUTOSUGGEST_USE_ASYNC=1
            ZSH_AUTOSUGGEST_MANUAL_REBIND=1
            ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)"
            ZSH_AUTOSUGGEST_STRATEGY=( completion )
            source "$aspath/zsh-autosuggestions/zsh-autosuggestions.zsh"
        done
        unset aspath
    fi

    unset is_root
    unset is_sudo
fi

[ -e "$HOME/.yarn/bin" ] && path_force_tail "$HOME/.yarn/bin"
[ -e "$HOME/.yarn/global/node_modules/bin" ] && path_force_tail "$HOME/.yarn/global/node_modules/.bin"

[ -e "$HOME/.zshrc_private" ] && . "$HOME/.zshrc_private"

if command -v path_force_order >/dev/null 2>&1; then
    path_force_order '/usr/local/bin' '/usr/bin'
    path_force_order "$HOME/bin" '/usr/local/bin'
    [ -e "$HOME/.local/bin" ] && path_force_order "$HOME/.local/bin" '/usr/local/bin'

    for rvmdir in "$HOME/.rvm/bin" '/usr/local/rvm/bin'; do
        if [ -d "$rvmdir" ]; then
            path_force_tail "$rvmdir"
            break
        fi
    done
fi

# Make path unique
typeset -aU path
