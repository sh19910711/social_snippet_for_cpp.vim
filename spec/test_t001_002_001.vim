let s:testcase = vimtest#new('test')

function! s:testcase.test1()
  let str = '// @snip <username/reponame:gr'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, g:social_snippet_cache . '/username/reponame')
  call self.assert.equals(ret.path, '/')
  call self.assert.equals(ret.cand, 'gr')
endfunction

function! s:testcase.test2()
  let str = '// @snip <username2/reponame2:dir1/dir2/file.cpp>'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, g:social_snippet_cache . '/username2/reponame2')
  call self.assert.equals(ret.path, '/dir1/dir2/')
  call self.assert.equals(ret.cand, 'file.cpp')
endfunction

function! s:testcase.test3()
  let repo_path = '/tmp/test_social_snippet/t001/002/001/repo1'
  let str = '// @snip <' . repo_path . ':dir1/dir2/file.cpp>'
  let ret = social_snippet#util#get_snippet_info(str)
  echomsg join(values(ret), ', ')
  call self.assert.equals(ret.repopath, repo_path)
  call self.assert.equals(ret.path, '/dir1/dir2/')
  call self.assert.equals(ret.cand, 'file.cpp')
endfunction

