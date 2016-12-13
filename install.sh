#!/bin/bash
set -e

if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
fi

if [ ! -n "$MYSHELL" ]; then
    MYSHELL=~/.oh-my-shell-scripts
fi

if [ -d "$MYSHELL" ]; then
    printf "${RED}You already have Oh My Shell Scripts installed.${NORMAL}\n"
    printf "You'll need to remove $MYSHELL if you want to re-install.\n"
    printf "${YELLOW}Just upgrate it.......\n${NORMAL}"
    CUR_CD=`pwd`
    cd $MYSHELL
    git pull 
    cd $CUR_CD
    unset CUR_CD
else
    printf "${BLUE}Cloning Oh My Shell...${NORMAL}\n"
    hash git >/dev/null 2>&1 || {
        echo "Error: git is not installed"
        exit 1
    }
    
    env git clone --depth=1 https://github.com/lycying/shell-scripts.git  $MYSHELL || {
        printf "Error: git clone of oh-my-shell-script repo failed\n"
        exit 1
    }
fi

#check my shell
if [ `echo $SHELL| grep csh` ];then
    RC_FILE=~/.cshrc
fi
if [ `echo $SHELL| grep zsh` ];then
    RC_FILE=~/.zshrc
fi
if [ `echo $SHELL| grep bash` ];then
    RC_FILE=~/.bashrc
fi

if [ ! -n "`cat $RC_FILE | grep MY_SHELL_SCRIPTS_OMG`" ];then
    L1="export MY_SHELL_SCRIPTS_OMG=$MYSHELL"
    L2="export PATH=\$PATH:\$MY_SHELL_SCRIPTS_OMG/bin"
    echo $L1>>$RC_FILE
    echo $L2>>$RC_FILE
    printf "${BOLD}Append $L1 to $RC_FILE ${NORMAL}\n"
    printf "${BOLD}Append $L2 to $RC_FILE ${NORMAL}\n"
else
    printf "${RED}You have config it! ${NORMAL}\n"
fi

cat <<EOF
${YELLOW} ################################
${BOLD}         It is OK Now
${YELLOW} ################################
${GREEN}
 \\
    \\
        .--.
       |o_o |
       |:_/ |
      //   \\ \\
     (|     | )
    /'\_   _/\`\\
    \\___)=(___/
EOF
printf "${NORMAL}"

env $SHELL
