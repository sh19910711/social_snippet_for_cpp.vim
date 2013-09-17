let s:testcase = vimtest#new('test')
function! s:testcase.version()
  call self.assert.equals(social_snippet#GetVersion(), '0.0.0')
endfunction
