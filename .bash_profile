# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# include .profile if it exists
if [ -f ~/.profile ]; then
    source ~/.profile
fi

# include .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# disallow messages
mesg n 2>/dev/null || true

#[ -x ~/bin/tmx -a -z "$TMUX" -a -n "$PS1" ] && ~/bin/tmx
