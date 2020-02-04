unset HISTFILE
export HISTFILE

path_force_head() {
    [ ! -d "$1" ] && return
    if [[ ":$PATH:" == *":$1:"* ]]; then
        tmppath=":$PATH:"
        tmppath="$1${tmppath/:$1:/:}"
        tmppath="${tmppath//::/:}"
        export PATH="${tmppath/%:/}"
        unset tmppath
    else
        export PATH="$1${PATH:+":$PATH"}"
    fi
}
path_force_tail() {
    [ ! -d "$1" ] && return
    if [[ ":$PATH:" == *":$1:"* ]]; then
        tmppath=":$PATH:"
        tmppath="${tmppath/:$1:/:}$1"
        tmppath="${tmppath//::/:}"
        export PATH="${tmppath/#:/}"
        unset tmppath
    else
        export PATH="${PATH:+"$PATH:"}$1"
    fi
}
path_add_head() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1${PATH:+":$PATH"}"
    fi
}
path_add_tail() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="${PATH:+"$PATH:"}$1"
    fi
}
path_add_head '/usr/local/bin'
path_add_head "$HOME/bin"

# If running interactively, then:
if [ -n "$PS1" -a -z "$ENVONLY" ]; then
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
        SHORT_PWD=$(echo "$PWD" | awk -F/ -v "n=${COLUMNS:-80}" -v "h=^$HOME" '{
            sub(h,"~"); n= 0.3 * n; b=$1"/"$2
        }
        length($0) <= n || NF == 3 { print; next; }
        NF > 3 {
            b = b "/.../";
            e = $NF;
            n-=length(b $NF);
            for (i = NF - 1; i > 3 && n > length(e) + 1; i--) e =  $i "/" e;
        }
        { print b e; }')
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

    set -o vi
    set visible-stats on
    set mark-directories off
    set completion-ignore-case on

    # Bindings
    bind '"\C-P": history-search-backward'
    bind '"\C-N": history-search-forward'
    bind '"\C-U": kill-whole-line'

    # Aliases
    alias gr='grep --color=auto --exclude-dir={.git,.hg,.svn,.bzr}'
    alias gs='git status --show-stash'
    alias gsu='git submodule update --init --recursive'
    alias gsur='git submodule update --remote --recursive'

    # cd to the root of the current git repository
    cdr() {
        REPO="$(git rev-parse --show-toplevel)"
        [ -z "$REPO" ] && return 1
        cd "$REPO"
    }

    # cd to the outermost git repository (from nested submodules)
    cdrr() {
        REPO="$(git rev-parse --show-toplevel)"
        [ -z "$REPO" ] && return 1
        while [ -n "$REPO" ]; do
            cd "$REPO" || return 1
            REPO="$(git rev-parse --show-superproject-working-tree 2>/dev/null)"
        done
        return 0
    }

    # Make a directory (including parent diretory) and cd to it
    md() {
        mkdir -pv "$1"
        cd "$1"
    }

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
    alias clc='fc -ln -1 | sed "s/^['$'\t'' ]*//" | tr -d "\n" | clipcopy'

    # Copy current directory
    alias cpwd='echo -n "$PWD" | clipcopy'

    # Copy symlink-resolved path to current directory
    alias cpath='( cd -P "$PWD" && echo -n "$PWD" | clipcopy "$PWD" ) && echo "$PWD"'

    # Neovim
    if [ -n "$(command -v nvim)" ]; then
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

    if [ -n "$(command -v fzf)" ]; then
        if [ -n "$(command -v fd)" ]; then
            fzo() {
                [ -n "$2" ] || return 1
                local depth="$1"
                shift
                local prog="$1"
                shift
                sels=( $(fd "${fd_default[@]}" --max-depth "$depth" --color=always . "$@" | fzf -m --height=25% --min-height=20 --reverse -0 --ansi) )
                [ -n "$sels" ] && "$prog" "${sels[@]}"
            }
        fi

        # fuzzy-find in nearby directories, e.g., `fz vi`
        # can also take a path, such as `fz vi /usr/include`
        fz() {
            fzo 4 "$@"
        }

        # current directory only, e.g., `f. mv`
        f.() {
            fzo 1 "$@"
        }

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

        # A bunch of git wrappers using fzf (yes, it says .zsh but it mostly
        # works on bash, we just miss out on the key bindings)
        [ -s "$HOME/.fzfgit.zsh" ] && . "$HOME/.fzfgit.zsh"
    fi
    if [ -n "$SSH_CONNECTION" -o -n "$SUDO_USER" ]; then
        PS1='\u@$SHORT_HOSTNAME:$SHORT_PWD\$ '
    else
        PS1='$SHORT_PWD\$ '
    fi
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

    if [ -r "$HOME/.dir_colors" -a -n "$(command -v dircolors)" ]; then
        eval `dircolors -b "$HOME/.dir_colors"`
    fi

    if ls --version 2>/dev/null | grep -q GNU; then
        alias ls='ls -F --color=auto --group-directories-first'
    elif [ "$CLICOLOR" = 1 ]; then
        if [ "$BACKGROUND" = 'light' ]; then
            export LSCOLORS='AxfxHehecxegehBDBDAhaD'
        else
            export LSCOLORS='ExfxHehecxegehBDBDAhaD'
        fi
        alias ls='ls -F -G'
    else
        alias ls='ls -F'
    fi

    # Load fasd if it is installed and ~/.fasd-init-bash exists (touch it!)
    fasd_cache="$HOME/.fasd-init-bash"
    if [ -e "$fasd_cache" -a -n "$(command -v fasd)" ]; then
        if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
            fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
        fi
        source "$fasd_cache"
        unset fasd_cache

        alias v='f -e vi'
        alias vv='sf -e vi'

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
                local sel="$(fasd "$fargs" -- "$@" | fzf --height=25% --min-height=12 --reverse --ansi -1 -0)"
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
        for zdir in "$HOME/.profile.d" '/usr/local/etc/profile.d' '/etc/profile.d'; do
            if [ -r "$zdir/z.sh" ]; then
                source "$zdir/z.sh"
                break
            fi
        done
        unset zdir
    fi
    unset fasd_cache

    export PROMPT_COMMAND TITLE_SET_HEAD TITLE_SET_TAIL SHORT_HOSTNAME SHOW_USERNAME
fi

[ -e "$HOME/.bashrc_private" ] && . "$HOME/.bashrc_private"

path_force_tail "$HOME/.rvm/bin"
