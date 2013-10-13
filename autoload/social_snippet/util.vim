function! social_snippet#util#get_dir_list(path)
  let ls_result = system('ls -m ' . a:path)
  let ls_result = substitute(ls_result, '\n', ',', 'g')
  let ls_list = split(ls_result, ',')
  let ls_list = map(ls_list, "substitute(v:val,'^\\s*\\(.*\\)\\s*$','\\1','')")
  let ls_list = filter(ls_list, 'v:val != ""')
  let ls_list = filter(ls_list, 'v:val[0] != "_"')
  return ls_list
endfunction

function! social_snippet#util#get_snippet_info(str)
  let res = {}
  let path = ""
  let snippet_path = matchstr(a:str, '^\/\/\s*@snip\s*<\zs.*[:\/]\@<=\ze>\?')
  let cand = matchstr(a:str, '[a-z0-9\.]*\ze>\?$')
  let type = ""

  if match(snippet_path, '^[a-z0-9]') == 0
    let type = "github"
  elseif match(snippet_path, '^\/') == 0
    let type = "abspath"
  endif
  echomsg snippet_path
  echomsg type

  if type == "github"
    let github_username = matchstr(snippet_path, '^\w*')
    let github_reponame = matchstr(snippet_path, '^\w*\/\zs\w*')
    let repopath = g:social_snippet_cache . '/' . github_username . '/' . github_reponame
    let res = extend(res, {
          \   'repopath': repopath,
          \ })
  elseif type == 'abspath'
    let repopath = matchstr(snippet_path, '^\zs.*\ze:')
    let res = extend(res, {
          \   'repopath': repopath,
          \ })
  endif

  let res = extend(res, {
        \   "cand": cand,
        \   "type": type,
        \   'path': '/' . matchstr(snippet_path, ':\zs.*\ze>\?'),
        \ })

  return res
endfunction
