let s:save_cpo = &cpo
set cpo&vim

if get(b:, 'loaded_markuplint')
  finish
endif

" version check
if !has('channel') || !has('job')
  echoerr '+channel and +job are required for misspell.vim'
  finish
endif

command! Markuplint :call markuplint#run()

noremap <silent> <buffer> <Plug>(Markuplint)  :Markuplint<CR>

let b:markuplint_misspell = 1

let &cpo = s:save_cpo
unlet s:save_cpo
