" There are two ways in which vim can detect Jinja:
"   option a: vim detected HTML in which case we will scan the first
"             50 lines to see if it looks like Jinja and then switch
"             over to htmljinja.
"   option b: vim detected htmldjango in which case we check the first
"             50 lines to look for Django-ism's.  If we don't find any
"             we switch to htmljinja.
"
" If we already did the detection we don't do anything so that users
" can still switch manually to a different syntax.
"
" Additionally whenever the buffer finished writing and the file type
" is html we also try to upgrade to htmljinja.  This can be separately
" disabled with g:htmljinja_disable_html_upgrade

if exists("g:htmljinja_disable_detection") && g:htmljinja_disable_detection
  finish
endif

fun! s:TryDetectJinja()
  if exists("b:did_jinja_autodetect")
    return
  endif
  let b:did_jinja_autodetect=1

  let n = 1
  while n < 50 && n < line("$")
    let line = getline(n)
    if line =~ '{%\s*\(extends\|block\|macro\|set\|if\|for\|include\|trans\)\>' || line =~ '{{\s*\S+[|(]'
      setlocal filetype=htmljinja
      return
    endif
    let n = n + 1
  endwhile
endfun

fun! s:ConsiderSwitchingToJinja()
  if exists("b:did_jinja_autodetect")
    return
  endif
  let b:did_jinja_autodetect=1

  let n = 1
  while n < 50 && n < line("$")
    let line = getline(n)
    " Bail on django specific tags
    if line =~ '{%\s*\(load\|autoescape \(on\|off\)\|cycle\|empty\)\>'
      return
    " Bail on django filter syntax
    elseif line =~ '\({%\|{{\).*|[a-zA-Z0-9]\+:'
      return
    endif
    let n = n + 1
  endwhile
  setlocal filetype=htmljinja
endfun

fun! s:ConsiderSwitchingToJinjaAgain()
  unlet b:did_jinja_autodetect
  call s:TryDetectJinja()
endfun

autocmd FileType htmldjango call s:ConsiderSwitchingToJinja()
autocmd FileType html call s:TryDetectJinja()

if !exists("g:htmljinja_disable_html_upgrade") || !g:htmljinja_disable_html_upgrade
  autocmd BufWritePost *.html,*.htm,*.shtml,*.stm call s:ConsiderSwitchingToJinjaAgain()
endif
