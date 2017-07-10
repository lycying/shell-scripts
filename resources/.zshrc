export ZSH=${HOME}/.oh-my-zsh
#ZSH_THEME="muse"
#ZSH_THEME="gnzh"
ZSH_THEME="gentoo"
plugins=(git autojump colored-man-pages mvn)
source $ZSH/oh-my-zsh.sh

alias rm='rm -i'
alias vi='vim'
alias mv='mv -i'

export SVN_EDITOR=vim
export EDITOR=vim
export LANG='en_US.UTF-8'
export LC_CTYPE='en_US.UTF-8'
export GOPATH=${HOME}/go

export SOFTF="${HOME}/soft"
export JAVA_HOME=`/usr/libexec/java_home`

#make soft link for all program
PATH="${PATH}:$NDK_ROOT"
PATH="${PATH}:${JAVA_HOME}/bin"
PATH="${PATH}:${SOFTF}/scala/bin"
PATH="${PATH}:${SOFTF}/maven/bin/"
PATH="${PATH}:${SOFTF}/ant/bin"
PATH="${PATH}:${SOFTF}/gradle/bin"
PATH="${PATH}:${SOFTF}/sbt/bin"
PATH="${PATH}:${HOME}/bin" #oh , private script and can not share to github
export PATH=${PATH}:${GOPATH}/bin

export NDK_ROOT="${SOFTF}/android-ndk-r10e"
export ANDROID_HOME=${SOFTF}/android/sdk
#export NVM_DIR=~/.nvm
#source $(brew --prefix nvm)/nvm.sh
#export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.5/bin
alias vim="/usr/local/Cellar/vim/8.0.0666_1/bin/vim"

export MY_SHELL_SCRIPTS_OMG=/Users/lycy/.oh-my-shell-scripts
export PATH=$PATH:$MY_SHELL_SCRIPTS_OMG/bin
