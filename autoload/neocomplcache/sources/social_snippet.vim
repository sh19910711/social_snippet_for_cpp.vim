let s:source = {
            \ 'name': 'social_snippet',
            \ 'kind': 'complfunc',
            \ }

function! s:get_dir_list(path)
    let ls_result = system('ls -m ' . a:path)
    let ls_result = substitute(ls_result, '\n', ',', 'g')
    let ls_list = split(ls_result, ',')
    let ls_list = map(ls_list, "substitute(v:val,'^\\s*\\(.*\\)\\s*$','\\1','')")
    let ls_list = filter(ls_list, 'v:val != ""')
    let ls_list = filter(ls_list, 'v:val[0] != "_"')
    return ls_list
endfunction

function! s:source.initialize()
endfunction

function! s:source.finalize()
endfunction

function! s:source.get_keyword_pos(str)
    return match(a:str, '\/\/\s*@snip\s*.*[<:/]\@<=')
endfunction

function! s:source.get_complete_words(post, str)
    let path = matchstr(a:str, '^\/\/\s*@snip\s*<\zs.*[:\/]\@<=\ze>\?')
    let cand = matchstr(a:str, '[a-z0-9\.]*\ze>\?$')

    let snip_info = {
                \   'user': matchstr(path, '^\w*'),
                \   'repo': matchstr(path, '^\w*\/\zs\w*'),
                \   'path': matchstr(path, ':\zs.*\ze>\?')
                \}

    let snippet_path = '~/.social-snippets/cache'
    if snip_info.user != ''
        let snippet_path = snippet_path . '/' . snip_info.user
    endif
    if snip_info.repo != ''
        let snippet_path = snippet_path . '/' . snip_info.repo
    endif
    if snip_info.user != ''
        let snippet_path = snippet_path . '/' . snip_info.path
    endif

    let l:list = []
    let ls_list = s:get_dir_list(snippet_path)
    for x in ls_list
        if match(x, '^' . cand ) != -1
            call add( l:list, {
                        \   'word': '// @snip <' . path . x,
                        \   'menu': '[SS]'
                        \})
        endif
    endfor

    return neocomplcache#keyword_filter(l:list, "")
endfunction

function! neocomplcache#sources#social_snippet#define()
    return s:source
endfunction

