# fzfgit.zsh: A bunch of git helpers using fzf
#
# This is primarily intended for zsh, which makes it easy to do key bindings,
# etc., but the functions and aliases should also work with bash.
#
# By Kimmo Kulovesi <https://arkku.dev/>, 2020-02-04

# Read NUL-terminated lines, drop the first n fields without touching other
# whitespace in between fields, print the lines NUL-terminated. If the argument
# is negative, then that many first fields are kept instead, while the rest of
# each line is dropped.
_drop_n_fields0() {
    local drop="$1"
    local i
    local line
    if [ -z "$BASH_VERSION" ]; then
        setopt localoptions extendedglob
        while read -r -d '' line; do
            if (( drop < 0 )); then
                local original="${line/#[[:space:]]#/}"
                for (( i = drop; i < 0; i++ )); do
                    line="${line/#[[:space:]]#[^[:space:]]##/}"
                done
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
    else
        local hadglob=''
        shopt -q extglob && hadglob=1
        shopt -s extglob
        while read -r -d '' line; do
            if (( drop < 0 )); then
                local original="${line##+([[:space:]])}"
                for (( i = drop; i < 0; i++ )); do
                    line="${line##+([[:space:]])}"
                    line="${line##+([^[:space:]])}"
                done
                i=$(( ${#original} - ${#line} ))
                line="${original:0:$i}"
            else
                for (( i = 0; i < drop; i++ )); do
                    line="${line##+([[:space:]])}"
                    line="${line##+([^[:space:]])}"
                    line="${line##+([[:space:]])}"
                done
            fi
            echo -n "$line"
            echo -ne "\0"
        done
        [ -z "$hadglob" ] && shopt -u extglob
    fi
}

# A wrapper for fzf commands, usage:
# _fzfcmd <n> <generator> [args...] -- <handler> [args...] -- [user args]
#
# Arguments to generator may also include `--fzf`, in which case the next
# argument is passed to `fzf` instead of the generator. There are also a
# couple of helper arguments to abbreviate common operations, see the source.
# The first argument, n, is the number of fields to drop when passing the
# selection to the handler.
_fzfcmd() {
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
        (--fzfm)
            fargs+=( '-m' '--bind' 'ctrl-a:select-all' '--bind' 'ctrl-d:deselect-all' )
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
        case "$arg" in
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
        case "$arg" in
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
    query="${query## }"

    # If there is a third -- (from the user's command-line) then we no longer
    # consider arguments after that for the query
    while [ $# -ge 1 ]; do
        cmdargs+=( "$1" )
        shift
    done
    [ -n "$ddash" ] && cmdargs+=( "$ddash" )

    "$lister" "${largs[@]}" \
        | fzf --print0 --reverse --query="$query" "${fargs[@]}" \
        | _drop_n_fields0 "$drop_fields" \
        | xargs -0 -t "${cmdargs[@]}"
}

# Git mergetool
gmt() {
    _fzfcmd 0 git diff-files --name-only --relative --diff-filter=U -z --fzfm --fzf0 --fzf --query="$query" --ddash -- git mergetool -y -- "$@"
}

# Git difftool
gdt() {
    _fzfcmd 0 git diff-files --name-only --relative --diff-filter=M -z --fzfm --fzf0 --fzfpreview "git --no-pager diff --color=always {}" --ddash -- git difftool -y -- "$@"
}

# Git add/stage
gadd() {
    _fzfcmd 1 git ls-files -m -o -v -z --exclude-standard --fzfm --fzf0 --fzfpreview "git --no-pager diff --color=always {2..}" --ddash -- git add -- "$@"
}

# Git discard changes
gdiscard() {
    _fzfcmd 0 git --no-pager diff --name-only --relative -z --fzfm --fzf0 --fzfpreview "git --no-pager diff --color=always {}" --ddash -- git restore -- "$@"
}

# Git unstage
gunstage() {
    # TODO: change `git reset HEAD` to `git restore --staged` once common
    _fzfcmd 0 git --no-pager diff --name-only --relative --staged -z --fzfm --fzf0 --fzfpreview "git --no-pager diff --color=always --staged {}" --ddash -- git reset HEAD -- "$@"
}

# Fuzzy-pick git files
fzgf() {
    local lsoptions='-lahGF'
    ls --version 2>/dev/null | grep -q GNU && lsoptions="$lsoptions --color=always"
    git ls-files --exclude-standard -z \
        | fzf --read0 --reverse -m --query="$@" \
        --preview="test -d {} && ls $lsoptions {} || ( command -v bat >/dev/null 2>&1 && bat --color=always --style=plain --paging=never {} || cat {}) | head -n 1000" \
        --preview-window='top:50%:wrap' \
        --bind "ctrl-a:select-all" \
        --bind "ctrl-d:deselect-all" \
        --header "Esc: Close | Enter: Accept | Tab: Toggle Selection | ^A: Select All | ^D: Deselect"
}

# Fuzzy-pick changed git files
fzgcf() {
    git ls-files -m -o --exclude-standard | uniq \
        | fzf --reverse -m --query="$@" \
        --preview="git --no-pager diff --relative --color=always {}" \
        --preview-window='top:50%:wrap' \
        --bind "ctrl-a:select-all" \
        --bind "ctrl-d:deselect-all" \
        --header "Esc: Close | Enter: Accept | Tab: Toggle Selection | ^A: Select All | ^D: Deselect"
}

# Fuzzy-pick git files recursively into submodules
fzgfr() {
    local lsoptions='-lahGF'
    ls --version 2>/dev/null | grep -q GNU && lsoptions="$lsoptions --color=always"
    git ls-files --exclude-standard --recurse-submodules -z \
        | fzf --read0 --reverse -m --query="$@" \
        --preview="test -d {} && ls $lsoptions {} || ( command -v bat >/dev/null 2>&1 && bat --color=always --style=plain --paging=never {} || cat {}) | head -n 1000" \
        --preview-window='top:50%:wrap' \
        --bind "ctrl-a:select-all" \
        --bind "ctrl-d:deselect-all" \
        --header "Esc: Close | Enter: Accept | Tab: Toggle Selection | ^A: Select All | ^D: Deselect"
}

# Git edit in "$EDITOR"
ge() {
    _fzfcmd 0 git ls-files -z --recurse-submodules --fzfm --fzf0 --exclude-standard --fzfpreview "test -d {} && ls -lhG {} || command -v bat >/dev/null 2>&1 && bat --color=always --style=plain --paging=never {} || cat {}" -- "$EDITOR" -- "$@"
}

gdf() {
    [ -n "$ZSH_VERSION" ] && setopt localoptions shwordsplit
    local pager='less -R'
    local color='always'
    if [ -n "$(command -v viless)" ]; then
        pager='viless -c "set ft=diff"'
        color=never
    fi
    local gargs='--no-pager diff --name-only --relative --color=always'
    local diffargs=''
    local stagedprompt='^A: Add'
    local query=''
    while [ $# -ge 1 ]; do
        local arg="$1"
        shift
        case "$arg" in
            (--staged|--cached)
                diffargs="$diffargs $arg"
                stagedprompt='^U: Unstage'
                ;;
            (-*)
                diffargs="$diffargs $arg"
                ;;
            (*)
                if git rev-parse --verify --quiet "$arg" >/dev/null 2>&1; then
                    diffargs="$diffargs $arg"
                else
                    query="$query $arg"
                fi
                ;;
        esac
    done
    query="${query## }"

    # TODO: change `git reset HEAD` to `git restore --staged` once common
    local diffcmd="reset; git diff$diffargs --color=$color {} | $pager"
    gargs="$gargs$diffargs"
    local greload="git $gargs 2>/dev/null | uniq"
    git ${gargs} | uniq | fzf -0 --no-multi \
        --query="$query" --reverse \
        --preview="git --no-pager diff --color=always $diffargs -- {} 2>/dev/null" \
        --preview-window='top:50%:wrap' \
        --bind "enter:execute[$diffcmd]" \
        --bind "double-click:execute[$diffcmd]" \
        --bind "ctrl-a:execute(set -x; git add -- {})+reload($greload)" \
        --bind "ctrl-u:execute(set -x; git reset HEAD -- {})+reload($greload)" \
        --bind "ctrl-t:execute(set -x; git checkout --theirs -- {})+reload($greload)" \
        --bind "ctrl-o:execute(set -x; git checkout --ours -- {})+reload($greload)" \
        --bind "ctrl-g:execute(git difftool -y$diffargs -- {})" \
        --bind "ctrl-c:execute(echo -n {} | clipcopy)" \
        --bind "ctrl-e:execute($EDITOR {})+reload($greload)" \
        --bind "ctrl-x:execute(git restore -- {})+reload($greload)" \
        --bind "ctrl-r:reload($greload)+clear-screen" \
        --header "Esc: Close | $stagedprompt | ^Edit | ^Git difftool | ^Reload | ^C: Copy | ^X: Discard | ^Theirs | ^Ours"
}

# Interactive git diff of staged changes
alias gdfs='gdf --staged'
alias gstaged='gdf --staged'

# Interactive git diff commit
gcommit() {
    local viewer='cat'
    if command -v bat >/dev/null 2>&1; then
        viewer='bat --style=plain --color=always --paging=never --'
    fi
    local color='always'
    local pager='less -R'
    if [ -n "$(command -v viless)" ]; then
        pager='viless -c "set ft=diff"'
        color=never
    fi
    local commitargs='commit'
    while [ $# -ge 1 ]; do
        local arg="$1"
        shift
        if [ -n "$ZSH_VERSION" ]; then
            commitargs="$commitargs ${arg:q}"
        else
            commitargs="$commitargs '${arg//\'/\'\\\'\'}'"
        fi
    done

    # Go to the repository root, otherwise we may miss staged files
    pushd "$(git rev-parse --show-toplevel)" >/dev/null || return 1

    # TODO: change `git reset HEAD` to `git restore --staged` once common
    local statusfunc='git --no-pager diff --name-only --relative --staged | sed "s/^/A /"; git --no-pager ls-files -m -o -v -d --exclude-standard'
    eval "$statusfunc" | fzf --ansi -0 --reverse -m \
        --bind "ctrl-o:execute[set -x; git $commitargs -- {+2..}]+abort" \
        --bind "enter:execute[git $commitargs]+abort" \
        --bind "double-click:ignore" \
        --bind "ctrl-r:reload($statusfunc)" \
        --bind "ctrl-a:select-all" \
        --bind "ctrl-d:deselect-all" \
        --bind "ctrl-x:execute(set -x; git restore -- {+2..})+reload($statusfunc)" \
        --bind "ctrl-l:execute(set -x; git rm --cached -- {+2..})+reload($statusfunc)" \
        --bind "ctrl-s:execute(set -x; git add -- {+2..})+reload($statusfunc)" \
        --bind 'ctrl-t:execute[git `test x{1} = xA && echo reset HEAD || echo add` -- {2..}]+'"reload($statusfunc)" \
        --bind "ctrl-u:execute(set -x; git reset HEAD -- {+2..})+reload($statusfunc)" \
        --bind "ctrl-c:execute(echo -n {+2..} | clipcopy)" \
        --bind "ctrl-e:execute($EDITOR {+2..})+reload($statusfunc)" \
        --bind 'ctrl-g:execute[git difftool -y `test x{1} = xA && echo --staged` -- {2..}]+'"reload($statusfunc)" \
        --bind 'ctrl-v:execute[test x{1} = "x?" && '"$viewer"' {2..} | less -R || git --no-pager diff --color='"$color"' $(test x{1} = xA && echo --staged) -- {2..} 2>/dev/null | '"$pager"']' \
        --preview='test x{1} = "x?" && '"$viewer"' {2..} || git --no-pager diff --color=always $(test x{1} = xA && echo --staged) -- {2..} 2>/dev/null' \
        --preview-window='top:50%:wrap' \
        --header "^Stage ^Unstage ^Toggle ^Edit | <Enter> Commit Staged / ^Override | ^All ^Deselect ^X Discard ^Copy ^Git difftool ^View"

    popd >/dev/null
}

# Interactive git stash viewing and manipulation
gstash() {
    git --no-pager stash list \
        --pretty='%C(yellow)%h %C(white)%<(15)%gD %C(reset)%gs' \
        --color=always \
        | fzf --ansi -0 --no-sort --no-multi --print0 \
            --query="$@" --reverse \
            --preview='git --no-pager stash show --color=always --stat -- {1}; echo; git --no-pager stash show --color=always -p {1}' \
            --preview-window='top:50%:wrap' \
            --bind "ctrl-a:execute(set -x; git stash pop {2})+abort" \
            --bind "ctrl-b:execute(set -x; git stash branch stash-{1} {1})+abort" \
            --bind "ctrl-x:execute[set -x; git stash drop {2}]+abort" \
            --header "Esc: Close | Enter: Diff | ^A: Apply/Pop | ^B: Branch | ^X: DROP" \
            | _drop_n_fields0 -1 \
            | xargs -0 git diff
}

# List branches and/or tags
# The first argument may contain the following substrings:
#   tags        include tags
#   tagsonly    nothing but tags
#   remote      include remote branches
git-ls-branches() {
    local remotes=''
    [[ "$1" == *'remote'* ]] && remotes='--all'
    [[ "$1" != *'tagsonly'* ]] && git --no-pager branch ${remotes} \
        --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)branch%09%(refname:short)%(end)%(end)" \
        | sed '/^$/d'
    [[ "$1" == *'tags'* ]] && git --no-pager tag --sort -creatordate | sed 's/^/tag     /'
}

# A helper for various commands that need to pick a branch or tag
fzfgitbranchcmd() {
    local tags="$1"
    local action="$2"
    local name="$3"
    shift 3
    local pager='less -R'
    local color='always'
    if [ -n "$(command -v viless)" ]; then
        pager='viless -c "set ft=diff"'
        color=never
    fi
    local query=''
    local cmdargs=''
    while [ $# -ge 1 ]; do
        local arg="$1"
        shift
        case "$arg" in
            (-*)
                cmdargs="$cmdargs $arg"
                ;;
            (*)
                query="$query $arg"
                ;;
        esac
    done
    query="${query## }"

    git-ls-branches ${tags} | fzf --ansi -0 --no-multi \
            --query="$query" --reverse \
            --preview='echo "+++" {2}; git --no-pager log --color=always --abbrev-commit --pretty=oneline ..{2}; echo "--- HEAD"; git --no-pager log --color=always --abbrev-commit --pretty=oneline {2}..'\
            --preview-window='top:50%:wrap' \
            --bind "enter:execute[set -x; $action$cmdargs {2}]+abort" \
            --bind "double-click:execute[set -x; $action$cmdargs {2}]+abort" \
            --bind 'ctrl-o:execute(hub compare $(git rev-parse --abbrev-ref HEAD)...{2})' \
            --bind "ctrl-g:execute(git --no-pager diff --color=$color ..{2} | $pager)" \
            --bind "ctrl-a:execute(git --no-pager diff --color=$color ...{2} | $pager)" \
            --header "Esc: Close | Enter: $name | ^G: Git Diff | ^A: Ancestor Diff"
}

# Pick and check out a branch or tag
gcheckout() {
    fzfgitbranchcmd tags,remotes 'git checkout' 'Checkout' "$@"
}

# Pick and check out a branch or tag
alias gco='gcheckout'

# Pick and check out a branch
gcheckoutb() {
    fzfgitbranchcmd remotes 'git checkout -t' 'Checkout' "$@"
}

# Pick and check out a branch
alias gcobranch='gcheckoutb'

# Pick and check out a tag
gcheckoutt() {
    fzfgitbranchcmd tagsonly 'git checkout' 'Checkout' "$@"
}

# Pick and check out a tag
alias gcotag='gcheckoutt'

# Pick a branch and rebase
grebase() {
    fzfgitbranchcmd remotes 'git rebase' 'Rebase' "$@"
}

# Pick a branch and rebase interactively
grebasei() {
    fzfgitbranchcmd remotes 'git rebase --interactive' 'Rebase Interactive' "$@"
}

# Pick a branch and merge
gmerge() {
    fzfgitbranchcmd remotes 'git merge' 'Merge' "$@"
}

# Pick a branch and merge, no fast forward
alias gmergef='gmerge --no-ff'

# Pick a branch and reset to its state
greset() {
    fzfgitbranchcmd remotes 'git reset' 'Reset to Branch' "$@"
}

# Pick a branch to remove
gbranchdel() {
    fzfgitbranchcmd '' 'git branch -d' 'REMOVE' "$@"
}

# Pick and remove a tag
gtagdel() {
    fzfgitbranchcmd tagsonly 'git tag -d' 'REMOVE' "$@"
}

_fzbrtcmd() {
    local arg="$1"
    shift
    git-ls-branches "$arg" \
        | fzf --ansi --query="$@" --reverse \
            --preview='echo "+++" ..{2}; git --no-pager log --color=always --abbrev-commit --pretty=oneline ..{2}; echo "---" {2}..; git --no-pager log --color=always --abbrev-commit --pretty=oneline {2}..'\
            --preview-window='top:50%:wrap' \
        | awk '{ print $2 }'
}

# A substitution alias for a single branch
alias fzbr='_fzbrtcmd branches'

# A substitution alias for a single branch, including remotes
alias fzbrr='_fzbrtcmd remotes'

# A substitution alias for a single branch or tag
alias fzbrt='_fzbrtcmd tags'

# A substitution alias for a single tag
alias fztag='_fzbrtcmd tagsonly'

# A helper for various commands that need to pick a commit
#
# Usage: $1
_fzfgitcommitcmd() {
    local multi='--no-multi'
    [[ "$1" == *'multi'* ]] && multi='--multi'

    local action="$2"
    local name="$3"
    shift 3
    local pager='less -R'
    local color='always'
    if [ -n "$(command -v viless)" ]; then
        pager='viless -c "set ft=diff"'
        color=never
    fi
    local branch=''
    local cmdargs=''
    while [ $# -ge 1 ]; do
        local arg="$1"
        shift
        case "$arg" in
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
        | fzf --ansi -0 --reverse "$multi" --no-sort \
            --preview='git --no-pager show --stat --color=always --pretty=full {1} --; git --no-pager show --color=always --pretty="%b" {1} -- 2>/dev/null' \
            --preview-window='top:50%:wrap' \
            --bind "enter:execute[set -x; $action$cmdargs {+1}]+abort" \
            --bind "double-click:execute[set -x; $action$cmdargs {+1}]+abort" \
            --bind "ctrl-c:execute(echo -n {1} | clipcopy)" \
            --bind "ctrl-g:execute(git --no-pager diff --color=$color {1} | $pager)" \
            --bind "ctrl-s:execute(git --no-pager show --color=$color --pretty=fuller {1} | $pager)" \
            --header "Esc: Close | Enter: $name | ^S: Show | ^G: Git Diff | ^C: Copy Hash"
}

# Show the git log interactively
glog() {
    _fzfgitcommitcmd '' 'git show --pretty=fuller --color=always' 'Show' "$@"
}

# Show the git log interactively
alias gll='glog'

# Pick commit(s) to cherry-pick (give branch of commits as first argument)
gcherry() {
    local branch=''
    [ -n "$1" ] && case "$1" in
        (-*)
        ;;
        (*)
            branch="$1"
            shift
        ;;
    esac
    if [ -z "$branch" ]; then
        branch="$(fzbrr '' -0 --header='Enter: Choose Branch of Commits | Esc: master')"
        [ -z "$branch" ] && branch='master'
    fi
    _fzfgitcommitcmd 'multi' 'git cherry-pick' 'Pick | Tab: Toggle' "$branch" "$@"
}

# Pick a commit and make a new commit as a fix-up to it
gfixup() {
    _fzfgitcommitcmd '' 'git commit --no-verify' 'Fix-up Commit' -- "$@" '--fixup'
}

# Pick a commit and revert it
grevert() {
    _fzfgitcommitcmd '' 'git revert' 'Revert Commit' "$@"
}

# Pick a commit to check out
gcheckoutc() {
    _fzfgitcommitcmd '' 'git checkout' 'Checkout Commit' "$@"
}

# Pick a commit to check out
alias gcocommit='gcheckoutc'

# Pick a commit to reset the current branch to it
gresetc() {
    _fzfgitcommitcmd '' 'git reset' 'Reset to Commit' -- "$@"
}

# Pick a commit and move everything after it to a new branch
gmovetobranch() {
    local newbranch="$1"
    if [ -z "$newbranch" ]; then
        echo "Usage: $0 newbranch"
        return 1
    fi
    shift
    local oldhead="$(git rev-parse HEAD)"
    git branch "$newbranch" || return 1
    local stashed=''
    if ! git diff-index --quiet HEAD --; then
        stashed="move-$oldhead-to-$newbranch"
        if ! git stash push -m "$stashed"; then
            echo "Could not stash changes in working copy" >&2
            git branch -D "$newbranch"
            return 1
        fi
    fi
    _fzfgitcommitcmd '' 'git reset --hard' "Pick LAST commit to KEEP on $(git branch --show)" -- "$@"
    if [ "$(git rev-parse HEAD)" = "$oldhead" ]; then
        echo "No change, abort move to branch" >&2
        set -x; git branch -D "$newbranch"
        git branch --show
        return 1
    else
        git switch "$newbranch"
    fi
    if [ -n "$stashed" ] && [[ $(git --no-pager stash list --pretty='%gs' -n 1) == *"$stashed"* ]]; then
        git stash pop
    fi
}

# Pick a commit and interactively rebase
grebasec() {
    _fzfgitcommitcmd '' 'git rebase --interactive' 'Rebase on Commit' "$@"
}

# Pick git commits, e.g.: git rebase --onto `fzc`<TAB>
fzc() {
    git --no-pager log --color=always -n 1000 --abbrev-commit --pretty="%C(yellow)%h %C(white)%<(19,mtrunc)%an %C(cyan)%<(14,trunc)%ar %C(reset)%s" "$@" \
        | fzf --ansi -0 --no-sort --multi --reverse \
            --preview='git --no-pager show --stat --color=always --pretty=full {1} --; git --no-pager show --color=always --pretty="%b" {1} -- 2>/dev/null' \
            --preview-window='top:50%:wrap' \
            --bind "ctrl-a:select-all" \
            --bind "ctrl-d:deselect-all" \
            --header "Esc: Close | Enter: Accept | Tab: Toggle Selection | ^A: Select All | ^D: Deselect" \
            | awk '{ print $1 }'
}

if [ -n "$(command -v hub)" ]; then
    # Pick a commit to check out
    gcistatus() {
        _fzfgitcommitcmd '' 'hub ci-status --color=always' 'CI Status' "$@"
    }

    # A helper for selecting interactively from GitHub issues
    fzhubi() {
        local action="$1"
        local name="$2"
        shift 2
        local query=''
        local largs=( '-o' 'updated' '-L' '1000' )
        local linit=${#largs}
        while [ $# -ge 1 ]; do
            local arg="$1"
            shift
            case "$arg" in
                (--)
                    if [ -z "$query" ]; then
                        query='--'
                    else
                        largs+=( "$arg" )
                    fi
                    ;;
                (-*)
                    largs+=( "$arg" )
                    ;;
                (*)
                    if [ -z "$query" -a ${#largs} -eq $linit ]; then
                        query="$arg"
                    else
                        largs+=( "$arg" )
                    fi
                    ;;
            esac
        done
        [ "$query" = '--' ] && query=''

        hub issue -f '%sC%<(6)%Cyellow%I%Creset %t    %Cwhite[%l%Cwhite] %U%n' --color=always "${largs[@]}" \
            | fzf --ansi -0 --reverse --query="$query" \
                --nth=..-2 --with-nth=..-2 \
                --preview='hub issue show --color=always \
                --format="%sC%<(6)%i %<(6)%S %Ccyan%cr %Creset%l%n%Creset%t%n%Cwhite(Updated: %ur) %Cyellow%Mn %Cwhite%Mt%n%CcyanAuthor: %Creset%<(20)%au %CcyanAssignees: %Creset%as%n%Cblue%U%n%n%Creset%b%n" {1}' \
                --preview-window='top:50%:wrap' \
                --bind "enter:execute($action)+abort" \
                --bind "double-click:execute($action)+abort" \
                --bind "ctrl-u:execute(echo -n {-1} | clipcopy)" \
                --bind "ctrl-c:execute(echo -n {1} | clipcopy)" \
                --bind "ctrl-o:execute(open {-1})" \
                --bind "ctrl-e:execute(hub issue update --edit {1})+abort" \
                --header "Esc: Close | Enter: $name | ^E: Edit | ^O: Open | ^C: Copy # | ^U: Copy URL"
    }

    # View Github issues interactively
    gissues() {
        fzhubi 'hub issue show --color=always {1}' 'Show' "$@"
    }

    # View Github issues interactively and commit to close the selected one
    gissuecommit() {
        fzhubi 'git commit -m "Closes #"{1} -e' 'Commit' "$@"
    }

    # A substitution alias for selecting a GitHub issue
    alias fziss='hub issue -f "%sC%<(6)%Cyellow%I%Creset %t    %Cwhite[%l%Cwhite]%n" --color=always -o updated -L 100 | fzf --ansi -m | awk "{ printf(\"%s\", \$1) }"'

    # A helper for selecting interactively from GitHub pull requests
    fzhubpr() {
        local action="$1"
        local name="$2"
        shift 2
        local query=''
        local largs=( '-o' 'updated' '-L' '500' )
        local linit=${#largs}
        while [ $# -ge 1 ]; do
            local arg="$1"
            shift
            case "$arg" in
                (--)
                    if [ -z "$query" ]; then
                        query='--'
                    else
                        largs+=( "$arg" )
                    fi
                    ;;
                (-*)
                    largs+=( "$arg" )
                    ;;
                (*)
                    if [ -z "$query" -a ${#largs} -eq $linit ]; then
                        query="$arg"
                    else
                        largs+=( "$arg" )
                    fi
                    ;;
            esac
        done
        [ "$query" = '--' ] && query=''

        hub pr list -f '%sC%<(6)%Cyellow%I %Creset %t    %Cwhite[%l%Cwhite] %U%n' --color=always "${largs[@]}" \
            | fzf --ansi -0 --reverse --query="$query" \
                --nth=..-2 --with-nth=..-2 \
                --preview='hub pr show --color=always \
                --format="%sC%<(6)%i %<(6)%S %Ccyan%cr %Creset%l%n%Creset%t%n%Cwhite(Updated: %ur) %Cyellow%Mn %Cwhite%Mt%n%CcyanAuthor: %Creset%<(20)%au %CcyanAssignees: %Creset%as%n%Cblue%U%n%n%Creset%b%n" {1}' \
                --preview-window='top:50%:wrap' \
                --bind "enter:execute($action)+abort" \
                --bind "double-click:execute($action)+abort" \
                --bind "ctrl-u:execute(echo -n {-1} | clipcopy)" \
                --bind "ctrl-c:execute(echo -n {1} | clipcopy)" \
                --bind "ctrl-o:execute(open {-1})" \
                --bind "ctrl-e:execute(hub pr checkout {1})+abort" \
                --header "Esc: Close | Enter: $name | ^E: Checkout | ^O: Open | ^C: Copy # | ^U: Copy URL"
    }

    # View Github pull requests interactively
    gpullrs() {
        fzhubpr 'hub pr show --color=always {1}' 'Show' "$@"
    }

    # A substitution alias for selecting a GitHub pull request
    alias fzpullr='hub pr list -f "%sC%<(6)%Cyellow%I%Creset %t    %Cwhite[%l%Cwhite]%n" --color=always -L 100 | fzf --ansi -m | awk "{ printf(\"%s\", \$1) }"'
fi

if [ -n "$(command -v jira)" ]; then
    # A helper for selecting interactively from Jira issues
    fzjira() {
        local action="$1"
        local name="$2"
        shift 2
        local query=''
        local largs=( -l 500 -s status )
        local linit=${#largs}
        while [ $# -ge 1 ]; do
            local arg="$1"
            shift
            case "$arg" in
                (--)
                    if [ -z "$query" ]; then
                        query='--'
                    else
                        largs+=( "$arg" )
                    fi
                    ;;
                (-*)
                    largs+=( "$arg" )
                    ;;
                (*)
                    if [ -z "$query" -a ${#largs} -eq $linit ]; then
                        query="$arg"
                    else
                        largs+=( "$arg" )
                    fi
                    ;;
            esac
        done
        [ "$query" = '--' ] && query=''

        jira list "${largs[@]}" | sed 's/:/ /' \
            | fzf --ansi -0 --reverse --query="$query" \
                --preview='jira view {1}' \
                --preview-window='top:50%:wrap' \
                --bind "enter:execute($action)+abort" \
                --bind "double-click:execute($action)+abort" \
                --bind "ctrl-c:execute(echo -n {1} | clipcopy)" \
                --header "Esc: Close | Enter: $name | ^C: Copy #"
    }

    # View Jira issues interactively
    gjira() {
        fzjira 'echo' 'Show' "$@"
    }
fi

# Bind Ctrl-G in vi insert mode to a Git object insertion menu (zsh only)
if [ -n "$ZSH_VERSION" ]; then
    bindkey -N gitfind

    _widget_gitcancel() {
        zle -R ''
        zle -K main
        [ -n "$widgets[autosuggest-clear]" ] && zle autosuggest-clear
    }
    zle -N _widget_gitcancel
    bindkey -M gitfind '^C' _widget_gitcancel
    bindkey -M gitfind '^[' _widget_gitcancel

    _gitfind_apply() {
        local sels=( "$@" )
        [ -n "$1" ] && LBUFFER+="${sels[@]:q} "
        zle _widget_gitcancel
    }

    _widget-gitcommits() {
        _gitfind_apply "${(@f)$(fzc)}"
    }
    zle -N _widget-gitcommits
    bindkey -M gitfind 'c' _widget-gitcommits

    _widget-gitcommitson() {
        local branch="$(fzbr '' -0 --header='Enter: Choose Branch of Commits | Esc: Current HEAD')"
        _gitfind_apply "${(@f)$(fzc "${branch:-HEAD}")}"
    }
    zle -N _widget-gitcommitson
    bindkey -M gitfind 'C' _widget-gitcommitson

    _widget-gitbranches() {
        _gitfind_apply "${(@f)$(fzbrr)}"
    }
    zle -N _widget-gitbranches
    bindkey -M gitfind 'b' _widget-gitbranches

    _widget-gitbranchestags() {
        _gitfind_apply "${(@f)$(fzbrt)}"
    }
    zle -N _widget-gitbranchestags
    bindkey -M gitfind 'B' _widget-gitbranchestags

    _widget-gitfiles() {
        _gitfind_apply "${(@f)$(fzgf)}"
    }
    zle -N _widget-gitfiles
    bindkey -M gitfind 'f' _widget-gitfiles

    _widget-gitchangedfiles() {
        _gitfind_apply "${(@f)$(fzgcf)}"
    }
    zle -N _widget-gitchangedfiles
    bindkey -M gitfind 'F' _widget-gitchangedfiles

    _widget-gitfilesr() {
        _gitfind_apply "${(@f)$(fzgfr)}"
    }
    zle -N _widget-gitfilesr
    bindkey -M gitfind 'r' _widget-gitfilesr

    _widget-gittags() {
        _gitfind_apply "${(@f)$(fztag)}"
    }
    zle -N _widget-gittags
    bindkey -M gitfind 't' _widget-gittags

    _widget-gitissues() {
        _gitfind_apply "${(@f)$(fziss)}"
    }
    zle -N _widget-gitissues
    bindkey -M gitfind 'i' _widget-gitissues

    _widget-gitpullrs() {
        _gitfind_apply "${(@f)$(fzpullr)}"
    }
    zle -N _widget-gitpullrs
    bindkey -M gitfind 'p' _widget-gitpullrs

    _widget-gitfind() {
        zle -K gitfind
        zle -M '? (c)ommits (C)ommits on (b)ranches (t)ags (B)oth (F)iles (i)ssues (p)ull reqs'
    }
    zle -N _widget-gitfind

    if [ -z "$FZFGIT_NO_BINDINGS" ]; then
        bindkey -M viins '^G' _widget-gitfind
    fi
fi
