# UTF-8 combining characters
setopt combiningchars

umask 027

# Add or move the argument dir to the head of path
path_force_head() {
    [ ! -d "$1" ] && return
    if [[ ":$PATH:" == *":$1:"* ]]; then
        local tmppath=":$PATH:"
        tmppath="$1${tmppath/:$1:/:}"
        tmppath="${tmppath//::/:}"
        export PATH="${tmppath/%:/}"
    else
        export PATH="$1${PATH:+":$PATH"}"
    fi
}

# Add or move the argument dir to the tail of path
path_force_tail() {
    [ ! -d "$1" ] && return
    if [[ ":$PATH:" == *":$1:"* ]]; then
        local tmppath=":$PATH:"
        tmppath="${tmppath/:$1:/:}$1"
        tmppath="${tmppath//::/:}"
        export PATH="${tmppath/#:/}"
    else
        export PATH="${PATH:+"$PATH:"}$1"
    fi
}

# Add the argument dir to the head of path unless already in path
path_add_head() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1${PATH:+":$PATH"}"
    fi
}

# Add the argument dir to the tail of path unless already in path
path_add_tail() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="${PATH:+"$PATH:"}$1"
    fi
}

# Take two arguments, force both to be in the path in that order
path_force_order() {
    if [ ! -d "$1" ]; then
        # First doesn't exist, just make sure the second does
        path_add_head "$2"
        return
    fi
    [[ ":$PATH:" == *":$1:"*":$2:"* ]] && return
    if [[ ":$PATH:" == *":$2:"* ]]; then
        local tmppath=":$PATH:"
        tmppath="${tmppath/:$1:/:}"
        tmppath="${tmppath/:$2:/:$1:$2:}"
        tmppath="${tmppath//::/:}"
        tmppath="${tmppath/#:/}"
        export PATH="${tmppath/%:/}"
    else
        # Second is not in path, add both to head
        path_add_head "$2"
        path_force_head "$1"
    fi
}

path_force_order '/usr/local/bin' '/usr/bin'
path_force_order "$HOME/bin" '/usr/local/bin'

[ -e "$HOME/.zshenv_private" ] && . "$HOME/.zshenv_private"
