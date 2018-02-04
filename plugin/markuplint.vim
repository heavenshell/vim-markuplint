" File: markuplint.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:  http://github.com/heavenshell/vim-markuplint/
" Description: Markuplint for Vim
" License: BSD, see LICENSE for more details.
" Copyright: 2018 Shinya Ohyanagi. All rights reserved.
let s:save_cpo = &cpo
set cpo&vim

if get(b:, 'loaded_markuplint')
  finish
endif

" version check
if !has('channel') || !has('job')
  echoerr '+channel and +job are required for markuplint.vim'
  finish
endif

command! Markuplint :call markuplint#run()

noremap <silent> <buffer> <Plug>(Markuplint)  :Markuplint<CR>

let b:loaded_markuplint = 1

let &cpo = s:save_cpo
unlet s:save_cpo
