call plug#begin('~/.vim/plugged')

Plug 'dense-analysis/ale'
Plug 'jaromero/vim-monokai-refined'
Plug 'kien/ctrlp.vim'
Plug 'airblade/vim-gitgutter'
Plug 'vim-test/vim-test'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'lukas-reineke/indent-blankline.nvim', { 'as': 'ibl' }

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

call plug#end()

if has('nvim')
  lua require('ibl').setup()
endif

colorscheme Monokai-Refined

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

autocmd FileType typescript setlocal ts=2 sw=2       " .ts
autocmd FileType typescriptreact setlocal ts=2 sw=2  " .tsx
autocmd FileType javascript setlocal ts=2 sts=2 sw=2
autocmd FileType vue setlocal ts=2 sts=2 sw=2
autocmd FileType yaml setlocal ts=2 sts=2 sw=2
autocmd FileType css setlocal ts=2 sts=2 sw=2
autocmd FileType vue syntax sync fromstart

" ALE Config
let g:ale_linters = {
\    'python': ['flake8', 'pylint', 'mypy'],
\    'javascript': ['eslint'],
\    'vue': ['stylelint', 'eslint'],
\}
let g:ale_pattern_options = {
  \ '\.go$': {'ale_enabled': 0},
\}
let g:ale_linter_aliases =  {'vue': ['javascript', 'css', 'scss', 'html']}
let g:ale_python_mypy_options='--ignore-missing-imports'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 'normal'
let g:ale_open_list = 1
let g:ale_exclude_highlights = ['outside_git_repo']
let g:ale_project_root_detection = ['git']
let g:ale_python_pylint_options='-s n -r n -j 0 --disable=missing-docstring --init-hook="import sys; sys.path.append(\"$(git root)\")"'

" Custom Config
let g:deoplete#enable_at_startup = 0
let g:black_linelength = 100
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
let g:airline_statusline_ontop = 0

" Map Q to q to avoid ex mode by mistake
nnoremap Q q
command Q q
nnoremap Qa qa
command Qa qa

" Space to toggle folding
noremap <space> za

" fold
"   set all folds to be open when opening a file
set foldmethod=indent
set foldlevelstart=999

" Clear highlights etc
nmap <silent> <C-L> <C-L>:nohlsearch<CR>:match<CR>:diffupdate<CR>

" tabs
nnoremap <C-b>  :tabprevious<CR>
inoremap <C-b>  <Esc>:tabprevious<CR>i
nnoremap <C-n>  :tabnext<CR>
inoremap <C-n>  <Esc>:tabnext<CR>i
nnoremap <C-t>  :tabnew<CR>
inoremap <C-t>  <Esc>:tabnew<CR>i

" misc
" to autoindent:what does <silent> mean in vim nmap command mode then visual mode(ESC v), select lines then =
set mouse=a
set number

" copy paste between windows
" Ctrl + c - copy
" Ctrl + p - paste
nmap <C-v> "*p 
vmap <C-c> "*y

" git gutter rebinds
nmap gp :GitGutterPreviewHunk<CR>
nmap ga :GitGutterStageHunk<CR>
nmap gu :GitGutterUndoHunk<CR>

" window navigation
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" vim test
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>
nmap <silent> <leader>a :TestSuite<CR>
nmap <silent> <leader>l :TestLast<CR>
nmap <silent> <leader>g :TestVisit<CR>

" vim-go
"   The below maps <Ctrl+g>t to new tab for go files (to avoid clash with
"   existing vim-go bindings)
au FileType go nnoremap <C-g>t  :tabnew<CR>
au FileType go inoremap <C-g>t  <Esc>:tabnew<CR>i

" Use the system clipboard. Note this require xclip
set clipboard+=unnamedplus