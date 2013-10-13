let s:testcase = vimtest#new('test')
function! s:testcase.version()
  echomsg social_snippet#GetVersion()
  let ret = join(social_snippet#util#get_dir_list("/tmp/test_social_snippet/t001/001"), ', ')
  call self.assert.equals(ret, "test1, test2, test3")
endfunction
