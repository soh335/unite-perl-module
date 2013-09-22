let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite-perl-module')
let s:F = s:V.import('System.Filepath')

function! unite#sources#perl_module_carton_list#define()
  return unite#sources#perl_module#util#is_available() ? s:source : {}
endfunction

let s:helper_path = printf(
      \ '%s%scarton_list.sh',
      \ expand('<sfile>:p:h'),
      \ s:F.separator())

let s:source = unite#sources#perl_module#util#new_source({
      \ "name": "perl-module/carton",
      \ "description": "cpanm module list in your carton",
      \ "max_candidates": 100
      \})

function! s:source.source__command()
  let dir = s:search_cpanfile_snapshot()
  let cmd = [s:helper_path]
  if dir != -1
    call add(cmd, dir)
  endif
  return join(cmd, " ")
endfunction

function! s:source.source__cache_name()
  let dir = s:search_cpanfile_snapshot()
  if dir != -1
    let dir = "perl_module_carton_list:" . fnameescape(dir)
  else
    let dir = "perl_module_carton_list"
  endif
  return dir
endfunction

function! s:source.source__process_name()
  return "unite_carton_list"
endfunction

function! s:search_cpanfile_snapshot()
  let dir = expand('%:p:h')
  let parent_dir = ''
  while isdirectory(dir) && dir !=# parent_dir
    if globpath(dir, '/cpanfile.snapshot') != ''
      return dir
    endif
    let parent_dir = dir
    let dir = fnamemodify(dir, ':h')
  endwhile
  return -1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
