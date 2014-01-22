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
  if match(a:str, ':') != -1
    let snippet_path = matchstr(a:str, '^\/\/\s*@snip\s*<\zs.*[:\/]\@<=\ze>\?')
  else
    let snippet_path = matchstr(a:str, '^\/\/\s*@snip\s*<\zs.*')
  endif

  let cand = matchstr(a:str, '[a-z0-9\-\_\.]*\ze>\?$')
  let type = ""

  if match(snippet_path, '^[a-zA-Z0-9]') == 0
    let type = "github"
  elseif match(snippet_path, '^\/') == 0
    let type = "abspath"
  endif

  let path = matchstr(snippet_path, ':\zs.*\ze>\?')

  if type == "github"
    " GitHub Path
    let github_username = matchstr(snippet_path, '^[a-zA-Z0-9\-]*')
    let github_reponame = matchstr(snippet_path, '^[a-zA-Z0-9\-]*\/\zs[a-zA-Z0-9\-]*')
    if match(snippet_path, '/') == -1
      let github_username = ''
      let github_reponame = ''
    else
      if match(snippet_path, ':') == -1
        let github_reponame = ''
      endif
    endif
    " Repositry path
    let repopath = g:social_snippet_cache
    if github_username != ""
      let repopath = repopath . '/' . github_username
      if github_reponame != ""
        let repopath = repopath . '/' . github_reponame
      endif
    endif
    " Snippet path
    let snip = ''
    if github_username != ''
      let snip = github_username . '/'
      if github_reponame != ""
        let snip = snip . github_reponame . ':'
        if path != ''
          let snip = snip . path
        endif
      endif
    endif
    let snip = matchstr(snip, '\zs.*[:/]')
    let res = extend(res, {
          \   'repopath': repopath,
          \   'snip': snip,
          \ })
  elseif type == 'abspath'
    " Absolute Path
    if match(snippet_path, ':') == -1
      let repopath = matchstr(snippet_path, '^\zs.*\ze/')
      let snip = repopath . '/'
    else
      let repopath = matchstr(snippet_path, '^\zs.*\ze:')
      let snip = repopath . ':' . path
    endif
    let res = extend(res, {
          \   'repopath': repopath,
          \   'snip': snip,
          \ })
  endif

  " Resolve path
  let snip_path = path
  if isdirectory(repopath)
    " load config
    let config_path = repopath . '/' . '.social_snippet.json'
    if filereadable(config_path)
      let config = eval(join(readfile(config_path)))
      let path = config.source . '/' . path
    end
  endif

  let res = extend(res, {
        \   "cand": cand,
        \   "type": type,
        \   'path': '/' . path,
        \   'snip_path': snip_path,
        \ })

  return res
endfunction
