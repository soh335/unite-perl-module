let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite-perl-module')
let s:F = s:V.import('System.Filepath')
let s:P = s:V.import('Prelude')

function! unite#sources#perl_module_cpan_list#define()
  return unite#sources#perl_module#util#is_available() ? s:source : {}
endfunction

let s:helper_path = printf(
      \ '%s%scpan_list.sh',
      \ expand('<sfile>:p:h'),
      \ s:F.separator())

let s:source = unite#sources#perl_module#util#new_source({
      \ "name": "perl-module/cpan",
      \ "description": "cpan list",
      \ "max_candidates": 100
      \ })

function! s:source.source__target_directories()
  let path = s:P.system("perl -e 'pop @INC; print join(q{ }, @INC);'")
  if s:P.get_last_status() != 0
    call unite#util#print_error(path)
    return []
  else
    return split(path, " ")
  endif
  return s:helper_path
endfunction

function! s:source.source__cache_name()
  return s:P.system("perl -MDigest::MD5 -e 'print \"perl_module_cpan_\" . Digest::MD5::md5_hex(join(\"\", @INC))'")
endfunction

function! s:source.source__process_name()
  return "unite_perl_module_cpan_list"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
