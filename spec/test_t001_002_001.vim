let s:testcase = vimtest#new('test')

function! s:testcase.test1()
  let str = '// @snip <username/reponame:gr'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, '~/.social-snippets/cache/username/reponame')
  call self.assert.equals(ret.path, '/')
  call self.assert.equals(ret.cand, 'gr')
endfunction

function! s:testcase.test2()
  let str = '// @snip <username2/reponame2:dir1/dir2/file.cpp>'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, '~/.social-snippets/cache/username2/reponame2')
  call self.assert.equals(ret.path, '/dir1/dir2/')
  call self.assert.equals(ret.cand, 'file.cpp')
endfunction

