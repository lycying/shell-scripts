au GUIEnter * simalt ~x "maximum the initial window
set guioptions-=m
set guioptions-=T
set nuw=1
set sw=4        "auto Indent length
set ts=4        "the length of tab
set lbr         "word-wrap
set wrap        "set nowrap
set fo+=mB      "word-wrap for more language
set sm          "() or {} match
set cindent     "C type indent
set nobackup
set ignorecase
set viminfo='10,\"100,:20,%,n~/.viminfo
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
set history=1000
set ffs=unix,dos,mac
set tw=500
set completeopt=menu
set shiftwidth=4
set fdl=0
set so=7
set mat=2
set cmdheight=1
set laststatus=2
set autoread
set expandtab
set smarttab
set autoindent
set pastetoggle=<F3>
set nocompatible
set nowb
set noswapfile
set nofen
set wildmenu
set ruler
set nu
set lz
set hid
set incsearch
set magic
set noerrorbells
set novisualbell
set vb t_vb=
set showmatch
set hlsearch
set noshowmode
"set cursorline
syn enable
filetype plugin on
filetype indent on
map <space> :
map <C-a> ggVG
map <right> :bn<cr>
map <left> :bp<cr>
map <leader>tn :tabnew %<cr>
map <leader>te :tabedit
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
nmap <leader>f :find<cr>
"let g:mapleader=";"

try
  set switchbuf=usetab
  set stal=2
catch
endtry

""""""""""""""""""""""""""""""
"Bclose function is a better close function
"It close the current buffer and not exit the program
""""""""""""""""""""""""""""""
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")
   if buflisted(l:alternateBufNum)
     buffer #
   else
     q
   endif
   if bufnr("%") == l:currentBufNum
     new
   endif
   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction

call pathogen#infect()

"colorscheme molokai
let g:solarized_termcolors=256
set background=dark
colorscheme solarized
