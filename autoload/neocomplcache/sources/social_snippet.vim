let s:source = {
      \ 'name': 'social_snippet',
      \ 'kind': 'complfunc',
      \ }

function! s:get_dir_list(path)
  return social_snippet#util#get_dir_list(a:path)
endfunction

function! s:source.initialize()
endfunction

function! s:source.finalize()
endfunction

function! s:source.get_keyword_pos(str)
  return match(a:str, '\/\/\s*@snip\s*.*[<:/]\@<=')
endfunction

function! s:source.get_complete_words(post, str)
  let snippet_info = social_snippet#util#get_snippet_info(a:str)

  if ! isdirectory(snippet_info.repopath)
    let snippet_info.repopath = matchstr(snippet_info.repopath, '\zs.*\/')
    let snippet_info.path = ''
  elseif ! isdirectory(snippet_info.repopath . snippet_info.path)
    let snippet_info.path = matchstr(snippet_info.path, '\zs.*\/')
  endif
  let dir_path = snippet_info.repopath . snippet_info.path

  let l:list = []
  if isdirectory(dir_path)
    let ls_list = s:get_dir_list(dir_path)
    for x in ls_list
      if match(x, '^' . snippet_info.cand ) != -1
        call add( l:list, {
              \   'word': '// @snip <' . snippet_info.snip . x,
              \   'menu': '[SS]'
              \})
      endif
    endfor
  endif

  return neocomplcache#keyword_filter(l:list, "")
endfunction

function! neocomplcache#sources#social_snippet#define()
  return s:source
endfunction

