if exists('g:loaded_dired')
    finish
endif
command! -nargs=? -complete=dir Dired lua require'nvim-dired'.open(<q-args>)
command! -nargs=? -complete=file DiredRename lua require'nvim-dired'.rename(<q-args>)
command! -nargs=? -complete=file DiredDelete lua require'nvim-dired'.delete(<q-args>)
command! DiredEnter lua require'nvim-dired'.enter()
command! DiredCreate lua require'nvim-dired'.create()
command! DiredQuit lua require'nvim-dired'.quit()


noremap <unique> <Plug>(dired_up) <cmd>execute 'Dired ..'<cr>
noremap <unique> <Plug>(dired_enter) <cmd>execute 'DiredEnter'<cr>
noremap <unique> <Plug>(dired_rename) <cmd>execute 'DiredRename'<cr>
noremap <unique> <Plug>(dired_delete) <cmd>execute 'DiredDelete'<cr>
noremap <unique> <Plug>(dired_create) <cmd>execute 'DiredCreate'<cr>

if mapcheck('-', 'n') ==# '' && !hasmapto('<Plug>(dired_up)', 'n')
    nmap - <Plug>(dired_up)
endif

autocmd FileType dired nnoremap <buffer> <cr> <Plug>(dired_enter)
autocmd FileType dired nnoremap <buffer> - <Plug>(dired_up)
autocmd FileType dired nnoremap <buffer> R <Plug>(dired_rename)
autocmd FileType dired nnoremap <buffer> d <Plug>(dired_create)
autocmd FileType dired nnoremap <buffer> D <Plug>(dired_delete)

augroup dired
    autocmd!
    " Makes editing a directory open a nvim-dired. We always re-init the dired
    autocmd BufEnter * if isdirectory(expand('%')) && !&modified
          \ | execute 'lua require"nvim-dired".init(vim.b.dirbuf_history, vim.b.dirbuf_history_index, true)'
          \ | endif
    " Netrw hijacking for vim-plug and &rtp friends
    autocmd VimEnter * if exists('#FileExplorer') | execute 'autocmd! FileExplorer *' | endif
augroup END
" Netrw hijacking for packer and packages friends
if exists('#FileExplorer') | execute 'autocmd! FileExplorer *' | endif
let g:loaded_dired = 1
