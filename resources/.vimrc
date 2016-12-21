""""""""""""""""""""""""""""""
" Encoding settings
""""""""""""""""""""""""""""""
set fileencodings=ucs-bom,utf-8,gbk
if has("multi_byte") " Set fileencoding priority
   if getfsize(expand("%")) > 0
       set fileencodings=ucs-bom,utf-8,cp936,big5,euc-jp,euc-kr,latin1
   else
       set fileencodings=cp936,big5,euc-jp,euc-kr,latin1
   endif
    " CJK environment detection and corresponding setting
   if v:lang =~ "^zh_CN"
        " Use cp936 to support GBK, euc-cn == gb2312
       set encoding=cp936
       set termencoding=cp936
       set fileencoding=cp936
   elseif v:lang =~ "^zh_TW"
        " cp950, big5 or euc-tw
        " Are they equal to each other?
       set encoding=big5
       set termencoding=big5
       set fileencoding=big5
   elseif v:lang =~ "^ko"
        " Copied from someone's dotfile, untested
       set encoding=euc-kr
       set termencoding=euc-kr
       set fileencoding=euc-kr
   elseif v:lang =~ "^ja_JP"
        " Copied from someone's dotfile, unteste
       set encoding=euc-jp
       set termencoding=euc-jp
       set fileencoding=euc-jp
   endif
    " Detect UTF-8 locale, and replace CJK setting if needed
   if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
       set encoding=utf-8
       set termencoding=utf-8
       set fileencoding=utf-8
   endif
else
   echoerr "Sorry, this version of (g)vim was not compiled with multi_byte"
endif

filetype plugin on
filetype indent on
syn enable

au GUIEnter * simalt ~x "maximum the initial window
set guioptions-=m
set guioptions-=T

set nuw=1
set sw=4        "auto Indent length
set ts=4        "the length of tab
set lbr         "word-wrap
set wrap        "set nowrap
                "set guioptions+=b
set fo+=mB      "word-wrap for more language
set sm          "() or {} match
set cindent     "C type indent

set nobackup
set ignorecase
"set path+=.,./include,../include,/usr/include,/usr/include/**,/usr/X11R6/include,/usr/local/include
"set tags=/home/lycy/.tags/tags,./tags,../tags,../../tags,/usr/include/tags,/usr/include/X11/tags
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
"set mouse=a
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
"let mapleader = ";"
"let g:mapleader=";"


map <space> :
map <C-a> ggVG
map <right> :bn<cr>
map <left> :bp<cr>
map <leader>tn :tabnew %<cr>
map <leader>te :tabedit
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
nmap <leader>f :find<cr>

try
  set switchbuf=usetab
  set stal=2
catch
endtry


""""""""""""""""""""""""""""""
" au BufRead,BufNewFile *  setfiletype txt
""""""""""""""""""""""""""""""
"The line shown like [filename CWD Line..]
""""""""""""""""""""""""""""""
function! CurDir()
     let curdir = substitute(getcwd(), '/home/lycy/', "~/", "g")
     return curdir
endfunction

""""""""""""""""""""""""""""""
"User the * and  # to search the word at pos
""""""""""""""""""""""""""""""
function! VisualSearch(direction) range
  let l:saved_reg = @"
  execute "normal! vgvy"
  let l:pattern = escape(@", '\\/.*$^~[]')
  let l:pattern = substitute(l:pattern, "\n$", "", "")
  if a:direction == 'b'
    execute "normal ?" . l:pattern . "^M"
  else
    execute "normal /" . l:pattern . "^M"
  endif
  let @/ = l:pattern
  let @" = l:saved_reg
endfunction
vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>
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
""""""""""""""""""""""""""""""
"Java  and Javascript fold for java file .auto load at setup
""""""""""""""""""""""""""""""
function! JavaFold()
     setl foldmethod=syntax
     setl foldlevelstart=1
     syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend
     "syn match foldImports /\(\n\?import.\+;\n\)\+/ transparent fold

     function! FoldText()
       return substitute(getline(v:foldstart), '{.*', '{...}', '')
     endfunction
     setl foldtext=FoldText()
endfunction
au FileType java setl shiftwidth=4
au FileType java setl tabstop=4
au FileType java setl fen
"au FileType java call JavaFold()
" now for javascript
function! JavaScriptFold()
     setl foldmethod=syntax
     setl foldlevelstart=1
     syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

     function! FoldText()
       return substitute(getline(v:foldstart), '{.*', '{...}', '')
     endfunction
     setl foldtext=FoldText()
endfunction
au FileType javascript setl shiftwidth=4
au FileType javascript setl tabstop=4
au FileType javascript setl fen
"au FileType javascript call JavaScriptFold()
""""""""""""""""""""""""""""""
"HTML Encoding

function! DetectHtmlEncoding()
    if &filetype != 'html'
      return
    endif
    normal m`
    normal gg
    if search('\c<meta http-equiv=\("\?\)Content-Type\1 content="text/html; charset=[-A-Za-z0-9_]\+">') != 0
      let reg_bak=@"
      normal y$
      let charset=matchstr(@", 'text/html; charset=\zs[-A-Za-z0-9_]\+')
      let charset=ConvertHtmlEncoding(charset)
      normal ``
      let @"=reg_bak
      if &fileencodings == ''
        let auto_encodings=',' . &encoding . ','
      else
        let auto_encodings=',' . &fileencodings . ','
      endif
      if charset !=? &fileencoding &&
         \(auto_encodings =~ ',' . &fileencoding . ',' || &fileencoding == '')
        silent! exec 'e ++enc=' . charset
      endif
    else
      normal ``
    endif
endfunction
au BufReadPost *.htm* nested      call DetectHtmlEncoding()
""""""""""""""""""""""""""""""
" extends .. show marks setting
""""""""""""""""""""""""""""""
let showmarks_enable = 1
let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
let showmarks_ignore_type = "hqm"
let showmarks_hlline_lower = 1
let showmarks_hlline_upper = 1


fun! OmniComplete()
    let left = strpart(getline('.'), col('.') - 2, 1)
    if left =~ "^$"
        return ""
    elseif left =~ ' $'
        return ""
    else
        return "\<C-x>\<C-o>"
    endfun
    inoremap <silent> <S-Tab> <C-R>=OmniComplete()<CR>



""""""""""""""""""""""""""""""
"names and values
""""""""""""""""""""""""""""""
let g:explVertical=1
let g:explWinSize=35
let g:explSplitLeft=1
let g:explSplitBelow=1
let g:explHideFiles='^\.,.*\.class$,.*\.swp$,.*\.pyc$,.*\.swo$,\.DS_Store$'
let g:explDetailedHelp=0
let g:miniBufExplModSelTarget = 1
let g:miniBufExplorerMoreThanOne = 2
let g:miniBufExplModSelTarget = 0
let g:miniBufExplUseSingleClick = 1
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplVSplit = 25
let g:miniBufExplSplitBelow=1
let g:bufExplorerSortBy = "name"
let xml_use_xhtml = 1
let html_use_css = 1
let html_number_lines = 0
let use_xhtml = 1


let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ""
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_section_b="%{strftime('%H:%M:%S')}"
let g:airline_section_y="[%{&fileformat}/%{strlen(&fenc)?&fenc:&enc}]"
"let g:airline_theme='badwolf'
"let g:airline_theme='base16'
"let g:airline_theme='bubblegum'
"let g:airline_theme='dark'
"let g:airline_theme='hybrid'
"let g:airline_theme='jellybeans'
"let g:airline_theme='kalisi'
"let g:airline_theme='kolor'
"let g:airline_theme='laederon'
"let g:airline_theme='light'
"let g:airline_theme='lucius'
"let g:airline_theme='luna'
"let g:airline_theme='molokai'
"let g:airline_theme='monochrome'
let g:airline_theme='murmur'
"let g:airline_theme='powerlineish'
"let g:airline_theme='serene.vim
"let g:airline_theme='simple'
"let g:airline_theme='solarized'
"let g:airline_theme='sol'
"let g:airline_theme='tomorrow'
"let g:airline_theme='ubaryd'
"let g:airline_theme='understated'
"let g:airline_theme='wombat'
"let g:airline_theme='zenburn'



call pathogen#infect()
nmap <F4> :TagbarToggle<CR>
nmap <F5> :NERDTreeToggle<CR>

set background=dark
"let g:solarized_termcolors=256
"let g:solarized_visibility = "high"
"let g:solarized_contrast = "high"
"let g:solarized_termtrans = 1
"colorscheme solarized

"colorscheme jellybeans
colorscheme molokai
"let g:molokai_original = 1
"let g:rehash256 = 1
"colorscheme zellner
"colorscheme zendnb
"colorscheme calmar256_light
"colorscheme biogoo
"colorscheme herald
"colorscheme lucius
"colorscheme winter
"colorscheme vividchalk
"colorscheme pyte

silent! if emoji#available()
  let g:gitgutter_sign_added = emoji#for('small_blue_diamond')
  let g:gitgutter_sign_modified = emoji#for('small_orange_diamond')
  let g:gitgutter_sign_removed = emoji#for('small_red_triangle')
  let g:gitgutter_sign_modified_removed = emoji#for('collision')
endif
