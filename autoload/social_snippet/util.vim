function! social_snippet#util#get_dir_list(path)
    let ls_result = system('ls -m ' . a:path)
    let ls_result = substitute(ls_result, '\n', ',', 'g')
    let ls_list = split(ls_result, ',')
    let ls_list = map(ls_list, "substitute(v:val,'^\\s*\\(.*\\)\\s*$','\\1','')")
    let ls_list = filter(ls_list, 'v:val != ""')
    let ls_list = filter(ls_list, 'v:val[0] != "_"')
    return ls_list
endfunction
