if exists('g:loaded_dired')
    finish
endif
command! -nargs=? -complete=dir Dired lua require'dired'.open(<q-args>)
command! -nargs=? -complete=file DiredRename lua require'dired'.rename(<q-args>)
command! -nargs=? -complete=file DiredDelete lua require'dired'.delete(<q-args>)
command! DiredEnter lua require'dired'.enter()
command! DiredCreate lua require'dired'.create()
command! DiredToggleHidden lua require'dired'.toggle_hidden_files()
command! DiredToggleSortOrder lua require'dired'.toggle_sort_order()
command! DiredQuit lua require'dired'.quit()


noremap <unique> <Plug>(dired_up) <cmd>execute 'Dired ..'<cr>
noremap <unique> <Plug>(dired_enter) <cmd>execute 'DiredEnter'<cr>
noremap <unique> <Plug>(dired_rename) <cmd>execute 'DiredRename'<cr>
noremap <unique> <Plug>(dired_delete) <cmd>execute 'DiredDelete'<cr>
noremap <unique> <Plug>(dired_create) <cmd>execute 'DiredCreate'<cr>
noremap <unique> <Plug>(dired_toggle_hidden) <cmd>execute 'DiredToggleHidden'<cr>
noremap <unique> <Plug>(dired_toggle_sort_order) <cmd>execute 'DiredToggleSortOrder'<cr>

if mapcheck('-', 'n') ==# '' && !hasmapto('<Plug>(dired_up)', 'n')
    nmap - <Plug>(dired_up)
endif

autocmd FileType dired nnoremap <buffer> <cr> <Plug>(dired_enter)
autocmd FileType dired nnoremap <buffer> - <Plug>(dired_up)
autocmd FileType dired nnoremap <buffer> R <Plug>(dired_rename)
autocmd FileType dired nnoremap <buffer> d <Plug>(dired_create)
autocmd FileType dired nnoremap <buffer> D <Plug>(dired_delete)
autocmd FileType dired nnoremap <buffer> . <Plug>(dired_toggle_hidden)
autocmd FileType dired nnoremap <buffer> , <Plug>(dired_toggle_sort_order)

augroup dired
    autocmd!
    " Makes editing a directory open a dired. We always re-init the dired
    autocmd BufEnter * if isdirectory(expand('%')) && !&modified
          \ | execute 'lua require"dired".init(vim.b.dirbuf_history, vim.b.dirbuf_history_index, true)'
          \ | endif
    " Netrw hijacking for vim-plug and &rtp friends
    autocmd VimEnter * if exists('#FileExplorer') | execute 'autocmd! FileExplorer *' | endif
augroup END
" Netrw hijacking for packer and packages friends
if exists('#FileExplorer') | execute 'autocmd! FileExplorer *' | endif
let g:loaded_dired = 1
