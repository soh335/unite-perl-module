" ref from https://github.com/rhysd/unite-ruby-require.vim/

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite-perl-module')
let s:PM = s:V.import('ProcessManager')
let s:P = s:V.import('Prelude')
let s:C = s:V.import('System.Cache')
let s:F = s:V.import('System.Filepath')

let s:source = {
      \ "source__ramcache" : ["undefined"],
      \}

let s:helper_path = printf(
      \ '%s%smodule_list.sh',
      \ expand('<sfile>:p:h'),
      \ s:F.separator())


function! unite#sources#perl_module#util#is_available()
  return s:PM.is_available()
endfunction

function! unite#sources#perl_module#util#new_source(opt)
  return extend(copy(s:source), copy(a:opt))
endfunction

function! s:source.gather_candidates(args, context)
  if self.source__ramcache == ['undefined']
    let self.source__ramcache = s:_slurp_cache(self.source__cache_name())
  endif
  if a:context.is_async && !empty(self.source__ramcache)
    let a:context.is_async = 0
    return self.source__ramcache
  elseif a:context.is_redraw
    let self.source__ramcache = []
    let a:context.is_async = 1
  end
  return self.async_gather_candidates(a:args, a:context)
endfunction

function! s:source.async_gather_candidates(args, context)
  let directories = self.source__target_directories()

  if ! (type(directories) == type([]) && len(directories) > 0)
    let a:context.is_async = 0
    call unite#util#print_error("no directories")
    return []
  endif

  let cmd = [s:helper_path]
  call extend(cmd, directories)
  call s:PM.touch(self.source__process_name(), join(cmd, " "))
  let [out, err, type] = s:PM.read(self.source__process_name(), ['$'])
  call unite#util#print_error(err)

  if type ==# 'timedout'
    let formatted = s:_format(out)
    let self.source__ramcache += formatted
    return formatted
  elseif type ==# 'inactive'
    call s:PM.stop(self.source__process_name())
    return s:source.async_gather_candidates(a:args, a:context)
  else
    let a:context.is_async = 0
    call s:PM.stop(self.source__process_name())

    if err != ''
      return []
    endif

    let formatted = s:_format(out)
    let self.source__ramcache += formatted
    call s:_spit_cache(self.source__ramcache, self.source__cache_name())
    return formatted
  endif
endfunction

function! s:_format(out)
  let list = split(a:out, "\r\\?\n")
  let ret = []

  for line in list
    let vars = split(line, '\.pm\zs:')

    if len(vars) != 2
      continue
    endif

    let dict = {
          \ "word": vars[1],
          \ "action__path": vars[0],
          \ "kind": "perl_module",
          \ }
    call add(ret, dict)
  endfor

  return ret
endfunction

function! s:_spit_cache(list, cache_name)
  let xs = map(copy(a:list), 'string(v:val)')
  call s:C.writefile(g:unite_data_directory, a:cache_name, xs)
endfunction

function! s:_slurp_cache(cache_name)
  let list = s:C.readfile(g:unite_data_directory, a:cache_name)
  return map(list, 'eval(v:val)')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
