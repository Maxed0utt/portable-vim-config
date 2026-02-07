"===========================================================================
"BASIC VIM SETUP SECTION START
"============================================================================
filetype plugin on
syntax on
autocmd BufEnter,BufRead *.* :syntax sync minlines=5000
set backspace=indent,eol,start
set noerrorbells
set relativenumber
set tabstop=2
set softtabstop=2 shiftwidth=2
set expandtab
set smartindent
set nu
set nowrap
set smartcase
set incsearch
set splitbelow
set ignorecase
set noswapfile
set signcolumn=number
set t_Co=256
set termguicolors
set bg=dark
let g:vim_json_conceal=0
let g:user_emmet_mode='n'
let g:user_emmet_leader_key=','
let g:svelte_indent_script = 0
let g:svelte_indent_style = 0
let g:svelte_preprocessors = ['typescript']
set updatetime=300
set encoding=utf-8
set nobackup
set nowritebackup
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/vendor,*/node_modules,*/.vscode/*,*/.code-workspace/*
set viminfo='20,<50,s10
set foldmethod=indent
" windows settings
" set ff=dos
" set fileformats=dos
" set clipboard=unnamed
" set mouse=a
set ff=unix
set fileformats=unix
syntax sync minlines=2000
autocmd VimEnter * :cd %:p:h
au BufNewFile,BufRead *.ejs set filetype=html
set clipboard=unnamedplus

"============================================================================
"PLUGIN SECTION START
"============================================================================
call plug#begin('~/.vim/plugged')
Plug 'lervag/vimtex'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/syntastic'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdcommenter'
Plug 'raimondi/delimitmate'
Plug 'dyng/ctrlsf.vim'
Plug 'mattn/emmet-vim'
Plug 'ervandew/supertab'
Plug 'crusoexia/vim-monokai'
Plug 'uguu-org/vim-matrix-screensaver'
Plug 'thaerkh/vim-indentguides'
Plug 'sirver/ultisnips'
Plug 'jimsei/winresizer'
Plug 'pantharshit00/vim-prisma', {'for': 'prisma'}
Plug 'anyakichi/vim-surround'
Plug 'kristijanhusak/vim-js-file-import', {'do': 'npm install'}
Plug 'ap/vim-css-color'
Plug 'drzel/vim-scroll-off-fraction'
Plug 'tpope/vim-obsession'
Plug 'dhruvasagar/vim-prosession'
Plug 'wuelnerdotexe/vim-astro', {'for': 'astro'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'madox2/vim-ai'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'dhruvasagar/vim-table-mode'
Plug 'ojroques/vim-oscyank', {'branch': 'main'}
Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}
Plug 'cakebaker/scss-syntax.vim'
Plug 'rust-lang/rust.vim'
Plug 'saecki/crates.nvim'
call plug#end()

"============================================================================
"INSTANT MARKDOWN SETTINGS START
"============================================================================
" Disable auto-start - only preview on manual command
let g:instant_markdown_autostart = 0

"============================================================================
"THEME SETTINGS SECTION START
"============================================================================
let g:scrolloff_fraction = 0.50
colorscheme monokai
hi Normal ctermbg=NONE
hi Normal guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE

"if (&background == 'dark')
  "hi Visual cterm=NONE ctermfg=NONE ctermbg=237 guibg=#3a3a3a
"else
  "hi Visual cterm=NONE ctermfg=NONE ctermbg=223 guibg=#ffd7af
"endif

"============================================================================
"SHORTKEYS START
"============================================================================
let mapleader = " "
nnoremap <Leader>s :vs<CR>
nnoremap <Leader>bs :split<CR>
nnoremap <Leader>a :qa<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>t :term<CR>
" In terminal buffers, let <Esc> act like <C-\><C-n>
tnoremap <Esc> <C-\><C-n>
nnoremap <Leader>h :wincmd h<CR>
nnoremap <Leader>P :diffput<CR>
nnoremap <Leader>D :Gdiff<CR>
nnoremap <Leader>B :Git blame<CR>
nnoremap <Leader>M :Git mergetool<CR>
nnoremap <C-h> <C-w>r
nnoremap <Leader>l :wincmd l<CR>
nnoremap <C-l> <C-w>r
nnoremap <Leader>j :wincmd j<CR>
nnoremap <Leader>k :wincmd k<CR>
nnoremap <C-f> :CtrlSF -I -ignoredir "node_modules"
nnoremap <Leader>p = :UltiSnipsEdit<CR>
nnoremap <Leader>v <C-v>
vnoremap <C-c> "+y
map <C-v> "+p
nnoremap <Leader>8 :Matrix<CR>
nnoremap <Leader>7 :call Transparent()<CR>
nnoremap <S-h> <C-S-6>
nnoremap <S-l> <C-o>
nnoremap <S-t> :tab split<CR>
nnoremap <Leader>n :tabn<CR>
nnoremap <Leader>b :tabp<CR>
" allows you to switch tabs by clicking space + 1, 2, 3
nnoremap <Leader>1 1gt
nnoremap <Leader>2 2gt
nnoremap <Leader>3 3gt
nnoremap <Leader>4 4gt
nnoremap <Leader>5 5gt
nnoremap <Leader>6 6gt
nnoremap <Leader>mp :InstantMarkdownPreview<CR>
nnoremap <Leader>f zM
nnoremap zO zR
inoremap <CapsLock> <Esc>
nnoremap <CapsLock> <Esc>
vnoremap <CapsLock> <Esc>
" <Leader>tm enters table mode
" | name | address | phone | to enter columns
" double || to add dividers

"============================================================================
"OSCYANK SETTINGS START
"============================================================================
" In normal mode, <leader>c is an operator that will copy the given text to the clipboard.
nmap <leader>c <Plug>OSCYankOperator
" In normal mode, <leader>cc will copy the current line.
nmap <leader>cc <leader>c_
" In visual mode, <leader>c will copy the current selection."
vmap <leader>c <Plug>OSCYankVisual

"============================================================================
"FZF SETTINGS START
"============================================================================
let $FZF_DEFAULT_COMMAND='find . \( -name vendor -o -name node_modules -o -name .git -o -path "*/.*" \) -prune -o -type f -print'

"============================================================================
"COC SETTINGS START
"============================================================================
"these are all my completion servers
let g:coc_global_extensions=['coc-solargraph', 'coc-phpls', 'coc-html', 'coc-json', 'coc-sql', 'coc-eslint', 'coc-html', 'coc-db', 'coc-java', 'coc-python', 'coc-tsserver', 'coc-css', 'coc-clangd', 'coc-pairs', 'coc-prisma', '@yaegassy/coc-astro', 'coc-rust-analyzer']
let g:svelte_indent_script = 0
let g:svelte_indent_style = 0
let g:svelte_preprocessors = ['typescript']

"=======================================TAB SETTINGS======================================
inoremap <silent><expr> <Tab>
            \ pumvisible() ? "\<C-n>"
            \ <SID>check_back_space() ? "\<Tab>" :
            \ coc#refresh()

inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

"=======================================<C-SPACE> TO TRIGGER COMPLETION======================================
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

"=======================================GOTO CODE NAVIGATION======================================
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <Leader>rn <Plug>(coc-rename)

"=======================================SHOW DOCUMENTATION======================================
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

"=======================================FORMATTING COMMANDS======================================
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

"=======================================SHOW ALL DIAGNOSTICS======================================
nnoremap <silent><nowait> <space>d  :<C-u>CocList diagnostics<cr>

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap keys for applying codeAction to the current buffer.
nmap <C-1> <Plug>(coc-codeaction)

" Apply AutoFix to problem on the current line.
nmap <C-2> <Plug>(coc-fix-current)

"============================================================================
"AI
"============================================================================
" complete text on the current line or in visual selection
nnoremap <leader>i :AI<CR>

" edit text with a custom prompt
nnoremap <leader>e :AIEdit fix grammar and spelling<CR>

" trigger chat
nnoremap <leader>c :AIChat<CR>

" redo last AI command
nnoremap <leader>r :AIRedo<CR>
let g:vim_ai_token_file_path = '~/.config/openai.token'
" let s:vim_ai_endpoint_url = "http://localhost:11434/v1/chat/completions"
" let s:vim_ai_model = "llama3.2"
" let s:vim_ai_temperature = 0.3

" let s:vim_ai_chat_config = #{
      " \  engine: "chat",
      " \  options: #{
      " \    model: s:vim_ai_model,
      " \    temperature: s:vim_ai_temperature,
      " \    endpoint_url: s:vim_ai_endpoint_url,
      " \    enable_auth: 0,
      " \    max_tokens: 0,
      " \    request_timeout: 60,
      " \  },
      " \  ui: #{
      " \    code_syntax_enabled: 1,
      " \  },
      " \}

" let s:vim_ai_edit_config = #{
      " \  engine: "chat",
      " \  options: #{
      " \    model: s:vim_ai_model,
      " \    temperature: s:vim_ai_temperature,
      " \    endpoint_url: s:vim_ai_endpoint_url,
      " \    enable_auth: 0,
      " \    max_tokens: 0,
      " \    request_timeout: 60,
      " \  },
      " \  ui: #{
      " \    paste_mode: 1,
      " \  },
      " \}

" let g:vim_ai_chat = s:vim_ai_chat_config
" let g:vim_ai_complete = s:vim_ai_edit_config
" let g:vim_ai_edit = s:vim_ai_edit_config

"=======================================AI TRANSLATION======================================
command! -range -nargs=? AITranslate <line1>,<line2>call AIEditRun(<range>, "Translate to French : " . <q-args>)

"============================================================================
"RUST SETTINGS START
"============================================================================
let g:rustfmt_autosave = 1

"============================================================================
"RIPGREP EXPRESSION
"============================================================================
if executable('rg')
    let g:rg_derive_root='true'
endif

"============================================================================
"NERD TREE SETTINGS START
"============================================================================
" NERDTree Configuration
let NERDTreeCDCommand='cd ' . getcwd()
let g:NERDTreeShowBookmarks = 1
let NERDTreeShowHidden = 1
"
"NERDCommenter settings
let g:NERDSpaceDelims = 1

"NERDTree remap
nnoremap nt :NERDTree<CR>
nnoremap <leader>bm :Bookmark<CR>
nnoremap <leader>rm :ClearAllBookmarks<CR>

"hide status line at top of screen
augroup nerdtreehidecwd
	autocmd!
	autocmd FileType nerdtree syntax match NERDTreeHideCWD #^[</].*$# conceal
augroup end

"add bookmarks for each git project

if isdirectory(expand(".git"))
  let g:NERDTreeBookmarksFile = '.git/.nerdtree-bookmarks'
else
  let g:NERDTreeBookmarksFile = expand('~/.NERDTreeBookmarks')
endif

"============================================================================
"SESSIONS SECTION START
"============================================================================
let g:sessions_dir = '~/.vim/session'

" Remaps for Sessions
" Store Session
exec 'nnoremap <Leader>ss :Obsession ' . g:sessions_dir . '/*.vim<C-D><BS><BS><BS><BS><BS>'
" Restore Session
exec 'nnoremap <Leader>sr :so ' . g:sessions_dir. '/*.vim<C-D><BS><BS><BS><BS><BS>'
" Pause Session
nnoremap <Leader>sp :Obsession<CR>

" Our custom TabLine function
function MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

    let s .= '%=' " Right-align after this

    if exists('g:this_obsession')
        let s .= '%#diffadd#' " Use the "DiffAdd" color if in a session
    endif

    " add vim-obsession status if available
    if exists(':Obsession')
        let s .= "%{ObsessionStatus()}"
        if exists('v:this_session') && v:this_session != ''
            let s:obsession_string = v:this_session
            let s:obsession_parts = split(s:obsession_string, '/')
            let s:obsession_filename = s:obsession_parts[-1]
            let s .= ' ' . s:obsession_filename . ' '
            let s .= '%*' " Restore default color
        endif
    endif

  return s
endfunction

" Required for MyTabLine()
function MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  return bufname(buflist[winnr - 1])
endfunction

"=======================================TRANSPARENT BACKGROUND FUNCTION======================================
function! Transparent()
    highlight Normal guibg=NONE ctermbg=NONE
    highlight LineNr guibg=NONE ctermbg=NONE
endfunction

"=======================================TRIM WHITESPACE AUTOMATICALLY ON SAVE======================================
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

"Trim White Space
augroup MAX_VIM
    autocmd!
    autocmd BufWritePre * :call TrimWhitespace()
augroup END

"=======================================SESSIONS======================================
let g:prosession_per_brtanch = 1

"=======================================ULTISNIPS SETTINGS======================================
let g:UltiSnipsSnippetDirectories=['~/.vim/UltiSnips/', 'UltiSnips']
let g:UltiSnipsEditSplit='vertical'
let g:UltiSnipsListSnippets = '<C-S-tab>'
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-tab>'
"automatically set buffer to be the current directory
"autocmd BufEnter * lcd %:p:h

"=======================================CTRLSF SETTINGS======================================
let g:ctrlsf_search_mode = 'async'

"=======================================SUPERTAB SETTINGS======================================
let g:SuperTabDefaultCompletionType = "<c-n>"

