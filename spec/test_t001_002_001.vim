let s:testcase = vimtest#new('test')

function! s:testcase.test_001()
  let str = '// @snip <username/reponame:gr'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, g:social_snippet_cache . '/username/reponame')
  call self.assert.equals(ret.path, '/')
  call self.assert.equals(ret.cand, 'gr')
  call self.assert.equals(ret.type, 'github')
  call self.assert.equals(ret.snip, 'username/reponame:')
endfunction

function! s:testcase.test_002()
  let str = '// @snip <username2/reponame2:dir1/dir2/file.cpp>'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, g:social_snippet_cache . '/username2/reponame2')
  call self.assert.equals(ret.path, '/dir1/dir2/')
  call self.assert.equals(ret.cand, 'file.cpp')
  call self.assert.equals(ret.type, 'github')
  call self.assert.equals(ret.snip, 'username2/reponame2:dir1/dir2/')
endfunction

function! s:testcase.test_003()
  let repo_path = '/tmp/test_social_snippet/t001/002/001/repo1'
  let str = '// @snip <' . repo_path . ':dir1/dir2/file.cpp>'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, repo_path)
  call self.assert.equals(ret.path, '/dir1/dir2/')
  call self.assert.equals(ret.cand, 'file.cpp')
  call self.assert.equals(ret.type, 'abspath')
  call self.assert.equals(ret.snip, repo_path . ':dir1/dir2/')
endfunction

function! s:testcase.test_004()
  let str = '// @snip <t'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.type, 'github')
  call self.assert.equals(ret.snip, '')
endfunction

function! s:testcase.test_005()
  let str = '// @snip <user5/repo5'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.type, 'github')
  call self.assert.equals(ret.snip, 'user5/')
endfunction

function! s:testcase.test_006()
  let repo_path = '/tmp/test_social_snippet/t001/002/001/repo1'
  let str = '// @snip <' . repo_path . ':dir'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, repo_path)
  call self.assert.equals(ret.path, '/')
  call self.assert.equals(ret.cand, 'dir')
  call self.assert.equals(ret.type, 'abspath')
  call self.assert.equals(ret.snip, repo_path . ':')
endfunction

function! s:testcase.test_007()
  let repo_path = '/tmp/test_social_snippet/t001/002/001/repo1'
  let str = '// @snip <' . repo_path . ':dir1/dir2'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, repo_path)
  call self.assert.equals(ret.path, '/dir1/')
  call self.assert.equals(ret.cand, 'dir2')
  call self.assert.equals(ret.type, 'abspath')
  call self.assert.equals(ret.snip, repo_path . ':dir1/')
endfunction

function! s:testcase.test_008()
  let str = '// @snip </dir1/dir2/abc'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, '/dir1/dir2')
  call self.assert.equals(ret.path, '/')
  call self.assert.equals(ret.cand, 'abc')
  call self.assert.equals(ret.type, 'abspath')
  call self.assert.equals(ret.snip, '/dir1/dir2/')
endfunction

function! s:testcase.test_009()
  let str = '// @snip </dir1/dir2/abc:def/ghi-jkl.cpp'
  let ret = social_snippet#util#get_snippet_info(str)
  call self.assert.equals(ret.repopath, '/dir1/dir2/abc')
  call self.assert.equals(ret.path, '/def/')
  call self.assert.equals(ret.cand, 'ghi-jkl.cpp')
  call self.assert.equals(ret.type, 'abspath')
  call self.assert.equals(ret.snip, '/dir1/dir2/abc:def/')
endfunction

