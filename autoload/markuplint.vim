" File: markuplint.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:  http://github.com/heavenshell/vim-markuplint/
" Description: markuplint for Vim
" License: BSD, see LICENSE for more details.
" Copyright: 2018 Shinya Ohyanagi. All rights reserved.
let s:save_cpo = &cpo
set cpo&vim

let g:markuplint_bin = get(g:, 'markuplint_bin', '')
let g:markuplint_enable_quickfix = get(g:, 'markuplint_enable_quickfix', 0)
let g:markuplint_callbacks = get(g:, 'markuplint_callbacks', {})
let s:root_path = ''
let s:rcfile = ''
let s:results = []

function! s:parse(msg, file)
  let results = []
  for m in a:msg
    call add(results, {
          \ 'filename': a:file,
          \ 'lnum': m['line'],
          \ 'col': m['col'],
          \ 'vcol': 0,
          \ 'text': printf('[Markuplint] %s [%s]', m['message'], m['ruleId']),
          \ })
  endfor
  return results
endfunction

function! s:detect_root()
  if s:root_path != ''
    return s:root_path
  endif

  let path = expand('%:p')
  let root_path = finddir('node_modules', path . ';')
  let s:root_path = root_path

  return root_path
endfunction

function! s:detect_rcfile() abort
  if s:rcfile != ''
    return s:rcfile
  endif

  let path = expand('%s')
  let file = findfile('.markuplintrc', path . ';')
  return file
endfunction

function! markuplint#bin()
  let bin = ''
  if executable('markuplint') == 0
    let root_path = s:detect_root()
    let bin = root_path . '/.bin/markuplint'
  else
    let bin = exepath('markuplint')
  endif

  return bin
endfunction

function! s:callback(ch, msg)
  call add(s:results, a:msg)
endfunction

function! s:exit_callback(ch, msg, mode, file)
  let str = join(s:results, '')
  let results = s:parse(json_decode(str), a:file)
  if len(results) == 0 && len(getqflist()) == 0
    " No Errors. Clear quickfix then close window if exists.
    call setqflist([], 'r')
    cclose
  else
    call setqflist(results, a:mode)
    if g:markuplint_enable_quickfix == 1
      cwindow
    endif
  endif

  if has_key(g:markuplint_callbacks, 'after_run')
    call g:markuplint_callbacks['after_run'](a:ch, a:msg)
  endif
endfunction

function! s:err_callback(ch, msg)
  echomsg printf('err: %s', a:msg)
endfunction

function! markuplint#run(...)
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif
  let bin = markuplint#bin()
  let rcfile = s:detect_rcfile()

  if bin == ''
    return
  endif

  let mode = a:0 > 0 ? a:1 : 'r'
  let file = expand('%:p')
  let cmd = printf('%s -c --ruleset %s --format JSON', bin, rcfile)
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m)},
        \ 'exit_cb': {c, m -> s:exit_callback(c, m, mode, file)},
        \ 'err_cb': {c, m -> s:error_callback(c, m)},
        \ 'in_io': 'buffer',
        \ 'in_name': file,
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
