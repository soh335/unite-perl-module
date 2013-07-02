let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#perl_module_cpan_list#define()
  return unite#sources#perl_module#util#is_available() ? s:source : {}
endfunction

let s:source = unite#sources#perl_module#util#new_source({
      \ "name": "perl-module/cpan",
      \ "description": "cpan list",
      \ "max_candidates": 100
      \ })

function! s:source.source__command()
  return "find `perl -e 'pop @INC; print join(q{ }, @INC);'` -name '*.pm' -type f | xargs egrep -o 'package [a-zA-Z0-9:]+;' | perl -nle 's/package\\s+(.*);/$1/; print' | sort | uniq"
endfunction

function! s:source.source__cache_name()
  return "perl_module_cpan_list"
endfunction

function! s:source.source__process_name()
  return "unite_perl_module_cpan_list"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
