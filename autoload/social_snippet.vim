" 設定
let s:dir = expand('~/.social-snippets')
let s:cache_dir = s:dir.'/cache'


" データ
let s:snippets = {}
let s:ordered = []
let s:code = {}


" インターフェース系の関数
function! social_snippet#Reset()
    call s:Reset()
endfunction

function! social_snippet#Setup()
    let cmd = 'mkdir -p '.s:cache_dir
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
 --recursive
function! social_snippet#LoadSnippet(path_str)
    call s:LoadSnippet(a:path_str)
endfunction


" 関数
function! s:Reset()
    let s:snippets = {}
    let s:ordered = []
    let s:code = {}
endfunction

function! s:InstallRepository(repo_path)
    let path = s:cache_dir.'/'.a:repo_path
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
    let repos = split(system('ls -d '.s:cache_dir.'/*/*'))
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
    let user_name = matchstr(a:path_str, '^\zs[^/]*\ze/')
    let repo_name = matchstr(a:path_str[strlen(user_name):], '^/\zs[^:]*\ze:')
    let path = a:path_str[strlen(user_name)+strlen(repo_name)+2:]
    return {
                \'user_name': user_name,
                \'repo_name': repo_name,
                \'path': path
                \}
endfunction

function! s:ReadSnippetFile( snip_info )
    let user_name = a:snip_info.user_name
    let repo_name = a:snip_info.repo_name
    let path = a:snip_info.path
    
    let repo_dir = s:cache_dir.'/'.user_name.'/'.repo_name
    if ! isdirectory(repo_dir)
        echo 'Error: 指定されたリポジトリが取得できませんでした。'
        return []
    endif

    let file_path = repo_dir.'/'.path
    if ! filereadable(file_path)
        echo 'Error: 指定されたファイルが取得できませんでした。'
        return []
    endif

    return readfile(file_path)
endfunction

function! s:GetNamespacesFromPath(path)
    return split(a:path, '/')[0:-2]
endfunction

function! s:isSnipLine(line)
    return match(a:line, '^ *// *@snip *<') != -1
endfunction

function! s:isSnippetLine(line)
    return match(a:line, '^ *// *@snippet *<') != -1
endfunction

function! s:GetSnippetPath(comment_line)
    return matchstr(a:comment_line, '^ *// *@\(snip\|snippet\) *<\zs.*\ze>')
endfunction

function! s:SubstituteSnipLine(line)
    return substitute(a:line, '^ *// *@snip *<', '// @snippet<', '')
endfunction

function! s:LoadSnippet(path_str)
    let key = a:path_str
    if has_key(s:snippets, key)
        return
    endif
    let s:snippets[key] = 1
    let snip_info = s:GetSnippetInfoFromPath(a:path_str)
    
    " スニペットファイルの解析
    let lines = s:ReadSnippetFile(snip_info)
    let new_lines = []
    let n = len(lines)
    for i in range(0,n-1)
        let line = lines[i]
        if s:isSnipLine(line)
            let snippet_path = s:GetSnippetPath(line)
            if snippet_path != ''
                call s:LoadSnippet(snippet_path)
            endif
        else
            call add(new_lines, lines[i])
        endif
    endfor

    " コードの生成
    let namespaces = s:GetNamespacesFromPath(snip_info.path)
    let res = ['', '// @snippet<'.snip_info.user_name.'/'.snip_info.repo_name.':'.snip_info.path.'>']
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
            let snippet_path = s:GetSnippetPath(line)
            call s:LoadSnippet(snippet_path)
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

