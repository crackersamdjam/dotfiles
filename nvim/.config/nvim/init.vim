set nocompatible | filetype indent plugin on | syn on

set autoindent
set nomodeline
set encoding=utf8

" https://vim.fandom.com/wiki/Indenting_source_code
set shiftwidth=4 tabstop=4 noexpandtab shiftround
autocmd FileType python setlocal shiftwidth=4 tabstop=4 noexpandtab

set backspace=indent,eol,start
set hidden
set laststatus=2

" Set linenumbers
set number relativenumber
set wrap

" column ruler at 100
" set ruler
" set colorcolumn=80

" Highlight searching
set incsearch showmatch hlsearch ignorecase smartcase

if has("nvim")
    set inccommand="nosplit"
endif

set autoread " autoread files
au FocusGained,BufEnter * :checktime "trigger autoread whenever buffer switched or refocused on vim
set mouse=a " use mouse for scroll or window size

" :h clipboard
" :checkhealth
set clipboard+=unnamedplus

" https://github.com/Ninjaclasher/scripts-and-config/blob/master/dotfiles/nvim/.config/nvim/init.vim
set background=light
hi QuickFixLine guibg=Black
"https://www.reddit.com/r/neovim/comments/17pkryg/disable_highlighting_of_unused_variables/
highlight link DiagnosticUnnecessary NONE

" run my printcolors cmd to see available colors
set hlsearch
hi Search ctermbg=Black

" ===== Plugins =====

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
	silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
				\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
"Plug 'jiangmiao/auto-pairs'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mbbill/undotree'
Plug 'tpope/vim-fugitive'
Plug 'lervag/vimtex', {'for': 'tex'}
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'altercation/vim-colors-solarized'
" https://jonasdevlieghere.com/vim-lsp-clangd/
" tut: https://codeforces.com/blog/entry/67828?#comment-520439
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'vim-scripts/vimcompletesme' " get clangd suggestions instead of default vim text-based suggestions
Plug 'preservim/nerdtree'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.4' }
call plug#end()


" ===== Telescope =====
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>


" ===== Vim-lsp =====
" https://github.com/prabirshrestha/vim-lsp

" clangd arugments in compile_flags.txt
if executable('clangd')
	augroup lsp_clangd
		autocmd!
		autocmd User lsp_setup call lsp#register_server({
					\ 'name': 'clangd',
					\ 'cmd': {server_info->['clangd']},
					\ 'whitelist': ['h', 'hpp', 'c', 'cc', 'cpp', 'c++', 'objc', 'objcpp'],
					\ })
		autocmd FileType h setlocal omnifunc=lsp#complete
		autocmd FileType hpp setlocal omnifunc=lsp#complete
		autocmd FileType c setlocal omnifunc=lsp#complete
		autocmd FileType cc setlocal omnifunc=lsp#complete
		autocmd FileType cpp setlocal omnifunc=lsp#complete
		autocmd FileType c++ setlocal omnifunc=lsp#complete
		autocmd FileType objc setlocal omnifunc=lsp#complete
		autocmd FileType objcpp setlocal omnifunc=lsp#complete
	augroup end
endif

if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'allowlist': ['python'],
        \ })
endif

" Lsp key blindings in here
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> ge <plug>(lsp-code-action)
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
	" K to get error msg?
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END


" ===== Run commands =====

function! Run()
	wa
	let file_name = expand('%:t:r')
	let extension = expand('%:e')
	
	if index(['cpp', 'cc', 'c++'], extension) >= 0
		let output = execute('!ulimit -s unlimited -v 2097152 && g++ -DLOCAL -std=c++17 -O2 -march=native -Wfatal-errors -Wall -Wextra -Wshadow -Wformat=2 -Wfloat-equal -Wconversion -Wlogical-op -Wshift-overflow=2 -Wduplicated-cond -Wcast-qual -Wcast-align -Wno-unused-result -Wno-unused-parameter -Wno-misleading-indentation '.@%.' -o '.file_name)
		if v:shell_error != 0
			echo 'Compilation Failed'
			"echo '\u001b[31mCompilation Failed\u001b[0m'
			" can not display ascii colour output in nvim
			echo output
			return
		endif
		"let output = execute('!timeout 3s ./' . file_name  . ' < in > out 2> err; cat err | grep ' . file_name . ' > ferr || true')
		execute('!timeout 3s ./'.file_name.' < in > out 2> err')
		if v:shell_error != 0
			echo 'Run Failed'
			"echo output
			return
		endif

	elseif index(['c'], extension) >= 0
		let output = execute('!ulimit -s unlimited -v 2097152 && gcc -DLOCAL -std=c99 -Wall '.@%.' -o '.file_name)
		if v:shell_error != 0
			echo 'Compilation Failed'
			echo output
			return
		endif
		execute('!timeout 3s ./'.file_name.' < in > out 2> err')
		if v:shell_error != 0
			echo 'Run Failed'
			"echo output
			return
		endif
	
	elseif index(['py2'], extension) >= 0
		execute('!timeout 3s python2 '.@%.' < in > out 2> err')
		if v:shell_error != 0
			echo 'Run Failed'
			"echo output
			return
		endif
	
	elseif index(['py'], extension) >= 0
		execute('!timeout 3s python '.@%.' < in > out 2> err')
		if v:shell_error != 0
			echo 'Run Failed'
			"echo output
			return
		endif
	
	elseif index(['rkt'], extension) >= 0
		execute('!timeout 3s racket '.@%.' < in > out 2> err')
		if v:shell_error != 0
			echo 'Run Failed'
			"echo output
			return
		endif
	else
		echo 'Invalid extension'
		return
	endif

	echo 'Success'
endfunction

function! Debug()
	wa
	let file_name = expand('%:t:r')
	let extension = expand('%:e')
	
	if index(['cpp', 'cc', 'c++'], extension) >= 0
		let output = execute('!ulimit -s unlimited -v 2097152 && g++ -DLOCAL -std=c++17 -O2 -march=native -Wfatal-errors -Wall -Wextra -Wshadow -Wformat=2 -Wfloat-equal -Wconversion -Wlogical-op -Wshift-overflow=2 -Wduplicated-cond -Wcast-qual -Wcast-align -Wno-unused-result -Wno-unused-parameter -Wno-misleading-indentation '.@%.' -o '.file_name)
		if v:shell_error != 0
			echo 'Compilation Failed'
			"echo '\u001b[31mCompilation Failed\u001b[0m'
			echo output
			return
		endif
		"let output = execute('!timeout 3s ./' . file_name  . ' < in > out 2> err; cat err | grep ' . file_name . ' > ferr || true')
		execute('!timeout 3s ./'.file_name.' < in > out 2> err')
		if v:shell_error != 0
			echo 'Run Failed'
			"echo output
			return
		endif

	elseif index(['c'], extension) >= 0
		let output = execute('!ulimit -s unlimited -v 2097152 && gcc -DLOCAL -std=c99 -Wall -fsanitize=address -fsanitize=undefined -fno-sanitize-recover -fstack-protector -g '.@%.' -o '.file_name)
		if v:shell_error != 0
			echo 'Compilation Failed'
			echo output
			return
		endif
		execute('!timeout 3s ./'.file_name.' < in > out 2> err')
		if v:shell_error != 0
			echo 'Run Failed'
			"echo output
			return
		endif
	
	elseif index(['rkt'], extension) >= 0
		execute('!timeout 3s racket '.@%.' < in > out 2> err')
		if v:shell_error != 0
			echo 'Run Failed'
			"echo output
			return
		endif
	else
		echo 'Invalid extension'
		return
	endif

	echo 'Success'
endfunction

:map <M-r> :call Run()<Cr>
:map <M-d> :call Debug()<Cr>


" ===== Key bindings =====
imap kj <Esc>
" much nicer than having to click Esc



" ===== Window Management =====

function! CP(extra_args)
	"set splitright
	set splitbelow
	vsp in
	sp|view out
	sp|view err
	call feedkeys("\<C-w>l") "go back to main window on right
	call feedkeys("\<C-w>40>") "resize
endfunction
command! -nargs=* CP call CP('<args>')

" To retab
" https://stackoverflow.com/a/9105889
" :set tabstop=2      " To match the sample file
" :set noexpandtab    " Use tabs, not spaces
" :%retab!            " Retabulate the whole file
" To show whether spaces or tabs:
nnoremap    <F2> :<C-U>setlocal lcs=tab:>-,trail:-,eol:$ list! list? <CR>

" ===== Plugins =====

"let g:usemarks=0
" don't need this since it's for lh-brackets? (which I removed)
"let g:cb_jump_over_newlines=0

" === VimTex with zathura ===
let g:instant_markdown_slow=1
let g:instant_markdown_autostart=0
let g:instant_markdown_mathjax=1

let g:tex_flavor='latex'
let b:tex_stylish=1
let g:vimtex_quickfix_open_on_warning=0
let g:vimtex_quickfix_mode=0
let g:vimtex_view_general_viewer='zathura'
let g:vimtex_compiler_latexmk = {'aux_dir': 'aux'}
"let g:vimtex_syntax_packages={'amsmath':{'load':2}, 'tikz':{'load':2}, 'markdown':{'load':2}}
"`load`  Specify when to load the package syntax addon.
"      0 = disable this syntax package
"      1 = enable this syntax package if it is detected (DEFAULT)
"      2 = always enable this syntax package
let g:vimtex_view_method='zathura' "https://wikimatze.de/vimtex-the-perfect-tool-for-working-with-tex-and-vim/


" === Theme ===
" https://github.com/vim-airline/vim-airline/wiki/Screenshots
let g:airline_theme='onedark'

" load it
"let g:solarized_visibility='low'
"syntax enable
"set t_Co=256
"let g:solarized_termcolors=256
"set background=dark
"colorscheme solarized

