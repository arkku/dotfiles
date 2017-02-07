#!/bin/sh

xinitd=/usr/X11/lib/X11/xinit/

# Disable annoying bells and whistles.
xset b off
xset b 0 0 0

# Load .Xresources and .Xmodmap.

nocpp=''
[ ! -x "`which cpp 2>/dev/null`" ] && nocpp='-nocpp'

for d in "$xinitd" "$HOME"; do
    if [ -r "$d/.Xresources" ]; then
        xrdb $nocpp -merge "$d/.Xresources"
    fi
    if [ -r "$d/.Xmodmap" ]; then
        xmodmap "$d/.Xmodmap"
    fi
done
unset d

# Execute init scripts.

if [ -d "$xinitd/xinitrc.d/." ] ; then
    for f in "$xinitd"/xinitrc.d/*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi
unset xinitd
unset nocpp

exec quartz-wm
