let s:save_cpo = &cpo
set cpo&vim

let s:root_path = ''
let s:rcfile = ''

function! s:parse(msg)
endfunction

function! markuplint#detect_root()
  if s:root_path != ''
    return s:root_path
  endif

  let path = expand('%:p')
  let root_path = finddir('node_modules', path . ';')
  let s:root_path = root_path

  return root_path
endfunction

function! markuplint#bin()
  let bin = ''
  if executable('markuplint') == 0
    let root_path = markuplint#detect_root()
    let bin = root_path . '/.bin/markuplint'
  else
    let bin = exepath('markuplint')
  endif

  return bin
endfunction

function! s:rcfile()
  if s:rcfile
    return s:rcfile
  endif
  let root = markuplint#detect_root()

  let s:rcfile = printf('%s/.markuplintrc', root)
  return s:rcfile
endfunction

function! s:callback(ch, msg, mode) abort
  echomsg string(a:msg)
endfunction

function! markuplint#run(...)
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif
  let bin = markuplint#bin()
  let rcfile = s:rcfile()

  if bin == ''
    return
  endif

  let mode = a:0 > 0 ? a:1 : 'r'
  let file = expand('%:p')
  let cmd = printf('%s -c --ruleset %s', bin, rcfile)
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m, mode)},
        \ 'in_io': 'buffer',
        \ 'in_name': file,
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
