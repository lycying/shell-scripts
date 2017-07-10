mkdir -p ~/.vim/bundle
mkdir -p ~/.vim/autoload
cp -rvf $MY_SHELL_SCRIPTS_OMG/resources/.vimrc ~/.vimrc
cp -rvf $MY_SHELL_SCRIPTS_OMG/resources/pathogen.vim ~/.vim/autoload/
cd ~/.vim/bundle
#git clone https://github.com/fatih/vim-go.git
git clone https://github.com/plasticboy/vim-markdown.git
git clone https://github.com/jlanzarotta/bufexplorer.git
git clone https://github.com/tmhedberg/matchit.git
#color
git clone https://github.com/tomasr/molokai.git
git clone https://github.com/altercation/vim-colors-solarized.git
