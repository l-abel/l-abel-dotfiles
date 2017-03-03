"" {{{{ Intro }}}}
" TOC:

" Plugins
""" tpope
""" syntax
""" misc
""" fzf

" Core Vim
""" general
""" whitespace
""" folding
""" searching
""" statusline
""" tabline

" Colorscheme (256 neodark)

" Netrw

" Linter Settings

" Keymappings

" Replace grep with ripgrep

" Last call (path+=**, cd to project)

" Homebrew packages (not necessarily deps for Vim):
""" ripgrep
""" task
""" ctags
""" ruby
""" fzf


"" {{{{ Vundle }}}}
filetype off " required for Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')
Plugin 'gmarik/Vundle.vim' " let Vundle manage Vundle, required

"tpope
Plugin 'tpope/vim-fugitive.git'
Plugin 'tpope/vim-commentary'

"syntax & linting
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'scooloose/syntastic'
Plugin 'mtscout6/syntastic-local-eslint.vim' " use project eslint

"misc
Plugin 'wikitopian/hardmode'
"Plugin 'scrooloose/nerdtree'

" all Vundle plugins must be added before the following line
call vundle#end() "required
filetype plugin indent on "required

"fzf
set rtp+=/usr/local/opt/fzf


"" {{{{ General Settings }}}}
set nocompatible		" no compatibility with legacy vi, required for Vundle
syntax enable
set encoding=utf-8
set showcmd			" display incomplete commands
set number      " show line numbers
set relativenumber
set wildmenu
set wildignore +=**/node_modules/**
set switchbuf=useopen,usetab
filetype plugin indent on
au FocusGained,BufEnter * checktime "like gVim, prompt if file changed


"" {{{{ Whitespace }}}}
set nowrap
set tabstop=2 shiftwidth=2
set expandtab			" use spaces, not tabs (optional)
set backspace=indent,eol,start	" backspace through everything in insert mode

" Whitespace cleanup
function! Whitespace() " whitespace and endline cleanup function
  if !&binary && &filetype != 'diff'
    normal mz
    normal Hmy
    $put _
    %s/\s\+$//e
    %s#\($\n\s*\)\+\%$##
    $put _
    normal 'yz<CR>
    normal `z
    echo "Whitespace cleanup complete."
  endif
endfunction
"" for regex breakdown: http://stackoverflow.com/q/7495932/


"" {{{{ Folding }}}}
set foldmethod=indent
set foldcolumn=0


"" {{{{ Searching }}}}
set hlsearch			" highlight matches
set incsearch			" incremental searching
set ignorecase		" searches are case insensitive...
set smartcase			" ... unless they contain at least one capital letter


"" {{{{ statusline, tabline }}}}
set laststatus=2  " always display statusline
set statusline=   " clear out for reload
set statusline=%3.3n " buffer number
set statusline+=\ %F " full file path
set statusline+=\ %h%m%r%w " status flags
set statusline+=\ %#warningmsg# " highlight switch
set statusline+=\ %{SyntasticStatuslineFlag()}
set statusline+=\ %* " highlight exit

function! GuiTabLabel()
  let label = ''
  let bufnrlist = tabpagebuflist(v:lnum)

  " Add '+' if one of the buffers in the tab page is modified
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&modified")
      let label = '+'
      break
    endif
  endfor

  " Append the number of windows in the tab page if more than one
  let wincount = tabpagewinnr(v:lnum, '$')
  if wincount > 1
    let label .= wincount
  endif
  if label != ''
    let label .= ' '
  endif

  " Append the buffer name
  return label . bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
endfunction
set guitablabel=    " clear for reload
set guitablabel=%{GuiTabLabel()}


"" {{{{ colorschemes }}}}
let g:neodark#use_256color = 1 " default: 0
colorscheme neodark


"" {{{{ netrw }}}}
let g:netrw_banner = 0 " hide banner
"let g:netrw_liststyle = 3 " tree list
"if that doesn't resolve netrw issue, try this
"autocmd FileType netrw setl bufhidden=wipe


"" {{{{ Linting }}}}
" (manual invoke w/:SyntasticCheck)
let g:syntastic_mode_map = { 'mode': 'active',
                            \ 'active_filetypes': ['javascript'],
                            \ 'passive_filetypes': [] }
let g:jsx_ext_required = 0
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
" attempted fix for nvm/vim/eslint path issue
" currently resolved with 'local eslint plugin'
" may need to revisit depending on project
" let g:syntastic_javascript_eslint_exec = '~/.nvm/versions/node/v4.2.1/bin/eslint'
let g:syntastic_javascript_checkers = ['eslint']


"" {{{{ Keymappings }}}}
"moving pane manipulation over to space-w, easier to use on 40% keyboards
map <Space> <leader>
noremap <Leader>a <C-a>
noremap <Leader>r <C-r>
noremap <Leader>w <C-w>
noremap <Leader>x <C-x>
noremap <Leader>F :FZF<Cr>
noremap <Leader>v :call GetVimRC()<Cr>
noremap <Leader>= :call Whitespace()<Cr>
noremap <Leader>/ :noh<Cr>
noremap <Leader>p :cd %:p:h<Cr>
noremap <Leader>h :cd ~/repos/<Cr>
noremap gO :!open -a Adobe\ Photoshop\ CS5 <cfile><CR>

function! WhichTab(filename)
    " Try to determine whether file is open in any tab.  
    " Return number of tab it's open in
    " http://stackoverflow.com/q/35465597/
    let buffername = bufname(a:filename)
    if buffername == ""
        return 0
    endif
    let buffernumber = bufnr(buffername)

    " tabdo will loop through pages and leave you on the last one;
    " this is to make sure we don't leave the current page
    let currenttab = tabpagenr()
    let buffs_arr = []
    tabdo let buffs_arr += tabpagebuflist()

    " return to current page
    exec "tabnext ".currenttab

    " Start checking tab numbers for matches
    let i = 0
    for bnum in buffs_arr
        let i += 1
        echo "bnum: ".bnum." buff: ".buffernumber." i: ".i
        if bnum == buffernumber
            return i
        endif
    endfor
endfunction

function! GetVimRC()
  let bnr = WhichTab("~/.vimrc")
  if bnr > 0
    sb ~/.vimrc
  else
    $tabnew
    e $MYVIMRC
  endif
  echo bnr
endfunction

"" {{{{ Plugin-specific settings }}}}

"" {{{{ ripgrep }}}}
"  use ripgrep instead of grep
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif


"" HardMode
"autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode() " call on start


"" {{{{ Last Call }}}}
set path+=** " use ** by default for filepath commands
cd ~/repos " Change to repos directory
