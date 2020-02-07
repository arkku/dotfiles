# .bash_profile: run instead of .profile by bash

# include .profile if it exists
if [ -f ~/.profile ]; then
    source ~/.profile
fi

# include .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
