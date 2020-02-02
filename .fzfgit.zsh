# fzfgit.zsh: A bunch of git helpers using zsh and fzf
#
# By Kimmo Kulovesi <https://arkku.dev/>

# Read NUL-terminated lines, drop the first n fields without touching other
# whitespace in between fields, print the lines NUL-terminated. If the argument
# is negative, then that many first fields are kept instead, while the rest of
# each line is dropped.
drop_n_fields() {
    setopt localoptions extendedglob
    local drop="$1"
    local i
    local line
    while read -r -d '' line; do
        if (( drop < 0 )); then
            local original="${line/#[[:space:]]#/}"
            for (( i = drop; i < 0; i++ )) line="${line/#[[:space:]]#[^[:space:]]##/}"
            i=$(( ${#original} - ${#line} ))
            line="${original:0:$i}"
        else
            for (( i = 0; i < drop; i++ )); do
                line="${line/#[[:space:]]#[^[:space:]]##[[:space:]]#/}"
            done
        fi
        echo -n "$line"
        echo -ne "\0"
    done
}

# A wrapper for fzf commands, usage:
# fzfcmd <n> <generator> [args...] -- <handler> [args...] -- [user args]
#
# Arguments to generator may also include `--fzf`, in which case the next
# argument is passed to `fzf` instead of the generator. There are also a
# couple of helper arguments to abbreviate common operations, see the source.
# The first argument, n, is the number of fields to drop when passing the
# selection to the handler.
fzfcmd() {
    local fargs=( '-0' )
    local drop_fields="$1"
    local lister="$2"
    shift 2
    local largs=( )
    local ddash=''
    while [ $# -ge 2 ]; do
        local arg="$1"
        shift
        case "$arg" in
        (--)
            break
            ;;
        (--fzf0)
            fargs+=( '--read0' )
            ;;
        (--fzfpreview)
            fargs+=( "--preview=$1" )
            fargs+=( '--preview-window=top:50%:wrap' )
            shift
            ;;
        (--fzfgdiffs)
            fargs+=( "--preview=git diff --staged --color=always -- {$1}" )
            fargs+=( '--preview-window=top:50%:wrap' )
            shift
            ;;
        (--fzfm)
            fargs+=( '-m' '--bind' 'ctrl-a:select-all' )
            ;;
        (--fzf)
            fargs+=( "$1" )
            shift
            ;;
        (--ddash)
            ddash='--'
            ;;
        (*)
            largs+=( "$arg" )
            ;;
        esac
    done

    # All arguments between first and second -- are the handler
    local cmdargs=( )
    while [ $# -ge 1 ]; do
        local arg="$1"
        shift
        case "$arg"; in
            (--)
                break
                ;;
            (*)
                cmdargs+=( "$arg" )
                ;;
        esac
    done

    # If there is a second --, the following are user arguments and may be
    # considered for the initial fzf query
    local query=''
    while [ $# -ge 1 ]; do
        local arg="$1"
        shift
        case "$arg"; in
            (--)
                break
                ;;
            (-*)
                cmdargs+=( "$arg" )
                ;;
            (*)
                query="$query $arg"
                ;;
        esac
    done
    query="${query/# /}"

    # If there is a third -- (from the user's command-line) then we no longer
    # consider arguments after that for the query
    while [ $# -ge 1 ]; do
        cmdargs+=( "$1" )
        shift
    done

    "$lister" "${largs[@]}" | fzf --print0 --reverse --query="$query" "${fargs[@]}" | drop_n_fields "$drop_fields" | xargs -0 -t "${cmdargs[@]}" ${=ddash}
}

# Git mergetool
gmt() {
    fzfcmd 0 git diff-files --name-only --diff-filter=U -z --fzfm --fzf0 --fzf --query="$query" --ddash -- git mergetool -y -- "$@"
}

# Git difftool
gdt() {
    fzfcmd 0 git diff-files --name-only --diff-filter=M -z --fzfm --fzf0 --fzfpreview "git diff --color=always {}" --ddash -- git difftool -y -- "$@"
}

# Git add/stage
gadd() {
    fzfcmd 1 git ls-files -m -o -v -z --exclude-standard --fzfm --fzf0 --fzfpreview "git diff --color=always {2..}" --ddash -- git add -- "$@"
}

# Git discard changes
gdiscard() {
    fzfcmd 0 git diff --name-only -z --fzfm --fzf0 --fzfpreview "git diff --color=always {}" --ddash -- git restore -- "$@"
}

# Git unstage
gunstage() {
    fzfcmd 0 git diff --name-only --staged -z --fzfm --fzf0 --fzfpreview "git diff --color=always --staged {}" --ddash -- git restore --staged -- "$@"
}

# Git edit in "$EDITOR"
gite() {
    fzfcmd 0 git ls-files -z --fzfm --fzf0 --exclude-standard --fzfpreview "( command -v bat >/dev/null 2>&1 && bat --color=always --style=plain --paging=never {} || cat {}) | head -n 1000" -- "$EDITOR" -- "$@"
}

# Interactive git diff with preview (^E to edit, ^G for git difftool, ^A to add)
gdf() {
    local pager='less -R'
    if [ -n "$(command -v bat)" ]; then
        pager='bat --paging=always --style=plain'
    fi
    local staged=''
    if [ "$1" = '--staged' ]; then
        staged="$1"
        shift
    fi
    git --no-pager diff --name-only -z ${=staged} | fzf -0 --read0 --no-multi \
        --query="$@" --reverse \
        --preview="git diff ${=staged} "$@" --color=always -- {}" \
        --preview-window='top:50%:wrap' \
        --bind "enter:execute(git diff ${=staged} --color=always {} | $pager)" \
        --bind "double-click:execute(git diff ${=staged} --color=always {} | $pager)" \
        --bind "ctrl-a:execute(git add -- {})+reload(git diff ${=staged} --name-only -z)" \
        --bind "ctrl-u:execute(git restore --staged -- {})+reload(git diff ${=staged} --name-only -z)" \
        --bind "ctrl-g:execute(git difftool ${=staged} -y -- {})" \
        --bind "ctrl-o:execute(git commit)+abort" \
        --bind "ctrl-e:execute($EDITOR {})" \
        --bind "ctrl-r:execute(echo -n)+reload(git diff ${=staged} --name-only -z)" \
        --header "Esc: Close / ${${staged:+^U: Unstage}:-^A: Add} / ^E Edit / ^G Git difftool / ^R Reload${staged:+ / ^O Commit}"
}

# Interactive git diff of staged changes
alias gdfs='gdf --staged'

# Interactive git stash viewing and manipulation
gstash() {
    local pager='less -R'
    if [ -n "$(command -v bat)" ]; then
        pager='bat --paging=always --style=plain'
    fi
    local gitargs=( --no-pager stash list --pretty='%C(yellow)%h %C(white)%<(15)%gD %C(reset)%gs' --color=always )
    git ${gitargs[@]} | fzf --ansi -0 --no-sort --no-multi \
            --query="$@" --reverse \
            --preview='git stash show --color=always --stat -- {1}; echo; git stash list --pretty=short --color=always' \
            --preview-window='top:50%:wrap' \
            --bind "ctrl-a:execute(git stash pop -- {2})+abort" \
            --bind "ctrl-b:execute(git stash branch stash-{1} {1})+abort" \
            --bind "enter:execute(git stash show --color=always -p -- {1} | $pager)" \
            --header "Esc: Close / Enter: Diff / ^B Branch / ^A Apply/Pop"
}

git-ls-branches() {
    local remotes=''
    [[ "$1" == *'remote'* ]] && remotes='--all'
    [[ "$1" != *'tagsonly'* ]] && git --no-pager branch ${=remotes} \
        --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)branch%09%(refname:short)%(end)%(end)" \
        | sed '/^$/d'
    [[ "$1" == *'tags'* ]] && git --no-pager tag | sed 's/^/tag     /'
}

# A helper for various commands that need to pick a branch or tag
fzfgitbranchcmd() {
    local tags="$1"
    local action="$2"
    local name="$3"
    shift 3
    local pager='less -R'
    local query=''
    local cmdargs=''
    while [ $# -ge 1 ]; do
        local arg="$1"
        shift
        case "$arg"; in
            (-*)
                cmdargs="$cmdargs $arg"
                ;;
            (*)
                query="$query $arg"
                ;;
        esac
    done
    query="${query/# /}"

    git-ls-branches ${=tags} | fzf --ansi -0 --no-sort --no-multi \
            --query="$query" --reverse \
            --preview='echo "+++"; git --no-pager log --color=always --abbrev-commit --pretty=oneline ..{2}; echo "---"; git --no-pager log --color=always --abbrev-commit --pretty=oneline {2}..'\
            --preview-window='top:50%:wrap' \
            --bind "enter:execute[set -x; $action$cmdargs {2}]+abort" \
            --bind "ctrl-g:execute(git --no-pager diff --color=always ..{2} | $pager)" \
            --bind "ctrl-a:execute(git --no-pager diff --color=always ...{2} | $pager)" \
            --header "Esc: Close | Enter: $name | ^G: Git Diff | ^A: Ancestor Diff"
}

# Pick and check out a branch or tag
gcheckout() {
    fzfgitbranchcmd tags,remotes 'git checkout' 'Checkout' "$@"
}

# Pick and check out a branch or tag
alias gco='gcheckout'

# Pick and check out a tag
gcotag() {
    fzfgitbranchcmd tagsonly 'git checkout' 'Checkout' "$@"
}

# Pick a branch and rebase
grebase() {
    fzfgitbranchcmd remotes 'git rebase' 'Rebase' "$@"
}

# Pick a branch and merge
gmerge() {
    fzfgitbranchcmd '' 'git merge' 'Merge' "$@"
}

# A helper for various commands that need to pick a commit
fzfgitcommitcmd() {
    local clipcopy='pbcopy'
    if [ -n "$(command -v clipcopy)" ]; then
        clipcopy='clipcopy'
    fi
    local multi='--no-multi'
    [[ "$1" == *'multi'* ]] && multi='--multi'

    local action="$2"
    local name="$3"
    shift 3
    local pager='less -R'
    local branch=''
    local cmdargs=''
    while [ $# -ge 1 ]; do
        local arg="$1"
        shift
        case "$arg"; in
            (--)
                if [ -z "$branch" -a -z "$cmdargs" ]; then
                    branch='HEAD'
                else
                    cmdargs="$cmdargs $arg"
                fi
                ;;
            (-*)
                cmdargs="$cmdargs $arg"
                ;;
            (*)
                if [ -z "$branch" -a -z "$cmdargs" ]; then
                    branch="$arg"
                else
                    cmdargs="$cmdargs $arg"
                fi
                ;;
        esac
    done
    [ "$branch" = 'HEAD' ] && branch=''

    git --no-pager log --color=always -n 1000 --abbrev-commit --pretty="%C(yellow)%h %C(white)%<(19,mtrunc)%an %C(cyan)%<(14,trunc)%ar %C(reset)%s" $branch \
        | fzf --ansi -0 --no-sort --reverse "$multi" \
            --preview='git --no-pager show --stat --color=always --pretty=fuller {1}'\
            --preview-window='top:50%:wrap' \
            --bind "enter:execute[set -x; $action$cmdargs {+1}]+abort" \
            --bind "ctrl-c:execute(echo -n {1} | $clipcopy)" \
            --bind "ctrl-g:execute(git --no-pager diff --color=always {1} | $pager)" \
            --bind "ctrl-s:execute(git --no-pager show --color=always --pretty=fuller {1} | $pager)" \
            --header "Esc: Close | Enter: $name | ^S: Show | ^G: Git Diff | ^C: Copy Hash"
}

# Show the git log interactively
glog() {
    fzfgitcommitcmd '' 'git show --pretty=fuller --color=always' 'Show' "$@"
}

# Show the git log interactively
alias gll='glog'

# Pick commit(s) to cherry-pick (give branch of commits as first argument)
gcherry() {
    fzfgitcommitcmd 'multi' 'git cherry-pick' 'Pick | Tab: Toggle' "$@"
}

# Pick a commit and make a new commit as a fix-up to it
gfixup() {
    fzfgitcommitcmd '' 'git commit --no-verify' 'Fix-up Commit' -- "$@" '--fixup'
}

# Pick a commit and revert it
grevert() {
    fzfgitcommitcmd '' 'git revert' 'Revert Commit' -- "$@"
}

# Pick git commits, e.g.: git rebase --onto `fzc`<TAB>
fzc() {
    git --no-pager log --color=always -n 1000 --abbrev-commit --pretty="%C(yellow)%h %C(white)%<(19,mtrunc)%an %C(cyan)%<(14,trunc)%ar %C(reset)%s" "$@" \
        | fzf --ansi -0 --no-sort --multi --reverse \
            --preview='git --no-pager show --color=always --pretty=fuller {1}'\
            --preview-window='top:50%:wrap' \
            --header "Esc: Close | Tab: Toggle Selection | Enter: Accept" \
            | awk '{ print $1 }'
}
