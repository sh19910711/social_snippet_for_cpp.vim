" データ
let s:snippets = {}
let s:ordered = []
let s:code = {}

" バージョン情報
function! social_snippet#GetVersion()
  return '0.0.0'
endfunction

" システム用
function! social_snippet#SetHomePath(new_path)
  if ! isdirectory(a:new_path)
    throw path . ' is not directory'
  endif
  let g:social_snippet_home = a:new_path
endfunction

function! social_snippet#SetCachePath(new_path)
  if ! isdirectory(a:new_path)
    throw path . ' is not directory'
  endif
  let g:social_snippet_cache = a:new_path
endfunction

" インターフェース系の関数
function! social_snippet#Reset()
  call s:Reset()
endfunction

function! social_snippet#Setup()
  let cmd = 'mkdir -p '.g:social_snippet_cache
  call system(cmd)
endfunction

function! social_snippet#InstallRepository(repo_path)
  call s:InstallRepository(a:repo_path)
endfunction

function! social_snippet#UpdateRepository()
  call s:UpdateRepository()
endfunction

function! social_snippet#InsertSnippet()
  call s:InsertSnippet()
endfunction

function! social_snippet#LoadSnippet(path_str)
  call s:LoadSnippet(a:path_str, 0)
endfunction


" 関数
function! s:Reset()
  let s:snippets = {}
  let s:ordered = []
  let s:code = {}
endfunction

function! s:InstallRepository(repo_path)
  let path = g:social_snippet_cache.'/'.a:repo_path
  if isdirectory(path)
    echo 'already exist'
  else
    let url = 'http://github.com/'.a:repo_path
    let cmd = 'git clone '.url.' '.path.' --recursive'
    echo cmd
    call system(cmd)
  endif
endfunction

function! s:UpdateRepository()
  let repos = split(system('ls -d '.g:social_snippet_cache.'/*/*'))
  for repo in repos
    call system('cd '.repo.' && git pull')
  endfor
endfunction

function! s:IndentCurrentBuffer()
  let n = line('$')
  for i in range(1,n)
    call setline(i, repeat(' ', cindent(i)).getline(i)[indent(i):])
  endfor
endfunction

function! s:GetSnippetInfoFromPath( path_str )
  return social_snippet#util#get_snippet_info(a:path_str)
endfunction

function! s:ReadSnippetFile( snip_info )
  let filepath = a:snip_info.repopath . a:snip_info.path . a:snip_info.cand
  if ! filereadable(filepath)
    echo 'Error: 指定されたファイルが取得できませんでした。'
    return []
  endif
  return readfile(filepath)
endfunction

function! s:GetNamespacesFromPath(path)
  return split(a:path, '/')
endfunction

function! s:isSnipLine(line)
  return match(a:line, '^ *// *@snip *<') != -1
endfunction

function! s:isSnippetLine(line)
  return match(a:line, '^ *// *@snippet *<') != -1
endfunction

function! s:GetSnippetPath(comment_line)
  return matchstr(a:comment_line, '^\s*//\s*@\(snip\|snippet\)\s*<\zs.*\ze>')
endfunction

function! s:SubstituteSnipLine(line)
  return substitute(a:line, '^ *// *@snip *<', '// @snippet<', '')
endfunction

function! s:LoadSnippet(path_line, depth)
  let key = s:GetSnippetPath(a:path_line)
  if has_key(s:snippets, key)
    return
  endif
  let s:snippets[key] = 1
  let snip_info = s:GetSnippetInfoFromPath(a:path_line)

  " スニペットファイルの解析
  let lines = s:ReadSnippetFile(snip_info)
  let new_lines = []
  let n = len(lines)
  for i in range(0,n-1)
    let line = lines[i]
    if s:isSnipLine(line)
      call s:LoadSnippet(line, a:depth + 1)
    else
      call add(new_lines, lines[i])
    endif
  endfor

  " コードの生成
  let namespaces = s:GetNamespacesFromPath(snip_info.path)
  let res = ['', '// @snippet<' . snip_info.snip . snip_info.cand . '>']
  for namespace in namespaces
    let res = res + ['namespace '.namespace.' {']
  endfor
  let res = res + new_lines
  for namespace in namespaces
    let res = res + ['}']
  endfor
  let res = res
  let s:code[key] = res

  call add(s:ordered, key)
endfunction

function! s:CheckLoadedSnippet(lines)
  let n = len(a:lines)
  for i in range(0,n-1)
    let line = a:lines[i]
    if s:isSnippetLine(line)
      let key = s:GetSnippetPath(line)
      let s:snippets[key] = 1
    endif
  endfor
endfunction

" カレントバッファへスニペットを挿入する
function! s:InsertSnippet()
  let current_line = line('.')

  let new_lines = []
  let n = line('$')
  for i in range(1,n)
    call add(new_lines, getline(i))
  endfor

  let t = 0
  let found_snippet = 0
  for i in range(1,n)
    let line = getline(i)
    if s:isSnipLine(line)
      call s:Reset()
      call s:CheckLoadedSnippet(new_lines)
      call s:LoadSnippet(line, 0)
      if t > 0
        let top = new_lines[0:t-1]
      else
        let top = []
      endif
      let bottom = new_lines[t+1:]

      let new_lines = top
      let diff = 0
      for key in s:ordered
        let code = s:code[key]
        let new_lines = new_lines + code
        let diff = diff + len(code)
      endfor
      let new_lines = new_lines + bottom
      let t = t + diff - 1
      let found_snippet = 1
    endif
    let t = t + 1
  endfor

  if ! found_snippet
    return
  endif

  :%d " 全ての行を削除
  call reverse(new_lines)
  for line in new_lines
    call append(0,line)
  endfor
  call s:IndentCurrentBuffer()

  execute(':'.current_line)
endfunction

