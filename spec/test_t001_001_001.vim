let s:testcase = vimtest#new('test')
function! s:testcase.version()
  let ret = join(social_snippet#util#get_dir_list("/tmp/test_social_snippet/t001/001"), ', ')
  echomsg ret
  call self.assert.equals(ret, "test1, test2, test3")
endfunction
