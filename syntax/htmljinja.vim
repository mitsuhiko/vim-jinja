if exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'html'
endif

runtime! syntax/jinja.vim
runtime! syntax/html.vim

let b:current_syntax = "htmljinja"
