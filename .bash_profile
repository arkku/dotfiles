# .bash_profile: run instead of .profile by bash

# include .profile if it exists
if [ -f ~/.profile ]; then
    source ~/.profile
fi

# include .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

for rvmdir in "$HOME/.rvm" '/usr/local/rvm'; do
    if [ -s "$rvmdir/scripts/rvm" ]; then
        export rvmsudo_secure_path=0
        source "$rvmdir/scripts/rvm"
        break
    fi
done

# disallow messages
mesg n 2>/dev/null || true
