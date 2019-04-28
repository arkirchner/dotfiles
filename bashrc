# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# set git as standard browser
export VISUAL=vim
export EDITOR="$VISUAL"

# load dotfile bin
export PATH="$HOME/.dotfiles/bin:$PATH"

# disable freeze terminal commands
stty -ixon
stty ixany

# stay always in tmux
_not_inside_tmux() {
  [[ -z "$TMUX" ]]
}

ensure_tmux_is_running() {
  if _not_inside_tmux; then
    tat
  fi
}

ensure_tmux_is_running
alias vi='vim'

# Less git typing
alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias go='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'

alias got='git '

# Version manger for all languages
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# export PATH="$HOME/.rbenv/bin:$PATH"
# eval "$(rbenv init -)"
# export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# qmake link
# export qmake=/usr/bin/qmake-qt4

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# work pathes
if [ -f $HOME/.work_pathes ]; then
    . $HOME/.work_pathes
fi

# server access
if [ -f $HOME/.server_access ]; then
    . $HOME/.server_access
fi

# mysql access shortcuts
if [ -f $HOME/.mysql_access ]; then
    . $HOME/.mysql_access
fi

# include .bashrc if it exists
if [ -f $HOME/.keys ]; then
    . $HOME/.keys
fi

