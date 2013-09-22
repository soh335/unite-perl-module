let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite-perl-module')
let s:F = s:V.import('System.Filepath')
let s:P = s:V.import('Prelude')

function! unite#sources#perl_module_carton_local_list#define()
  return unite#sources#perl_module#util#is_available() ? s:source : {}
endfunction

let s:helper_path = printf(
      \ '%s%scarton_local_list.sh',
      \ expand('<sfile>:p:h'),
      \ s:F.separator())

let s:source = unite#sources#perl_module#util#new_source({
      \ "name": "perl-module/carton-local",
      \ "description": "cpanm module list in your carton",
      \ "max_candidates": 100
      \})

function! s:source.source__target_directories()
  let path = s:P.system("carton exec -- perl -e 'print join q{ }, grep { index($_, $ENV{PERL5LIB}) > -1 } @INC'")
  if s:P.get_last_status() != 0
    call unite#util#print_error(path)
    return []
  else
    return split(path, " ")
  endif
endfunction

function! s:source.source__cache_name()
  let path = s:P.system("carton exec -- perl -e 'print \"perl_module_carton_local_\" . $ENV{PERL5LIB}'")
  return path
endfunction

function! s:source.source__process_name()
  return "unite_carton_local_list"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
