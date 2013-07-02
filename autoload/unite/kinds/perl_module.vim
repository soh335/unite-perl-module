let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ "name" : "perl_module",
      \ "default_action": "open",
      \ "action_table": {},
      \ 'parents': ['file'],
      \}

let s:kind.action_table.ref = {
      \ 'is_selectable' : 1,
      \ "description" : "execute perldoc by ref.vim"
      \ }

function! s:kind.action_table.ref.func(candidates)
  " take from quickrun.vim
  let cmd = join([(winwidth(0) * 2 < winheight(0) * 5 ? "" : "vertical"), "split"], " ")
  for c in a:candidates
    call ref#open('perldoc', c.action__path, {'new': 1, 'open': cmd})
  endfor
endfunction

let s:kind.action_table.use_insert = {
      \ "description" : "use this module"
      \ }

function! s:kind.action_table.use_insert.func(candidate)
  let candidate = copy(a:candidate)
  let candidate.action__text = printf("use %s;", a:candidate.word)
  call unite#take_action('insert', candidate)
endfunction

function! unite#kinds#perl_module#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
