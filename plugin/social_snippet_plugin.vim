" set home directory
let g:social_snippet_home = expand('~/.social-snippets')
if isdirectory(expand($SOCIAL_SNIPPET_HOME))
  let g:social_snippet_home = $SOCIAL_SNIPPET_HOME
endif

" generate home
if ! isdirectory(g:social_snippet_home)
  system('mkdir ' . g:social_snippet_home)
endif

" load config
let config_path = g:social_snippet_home . '/config.vim'
if filereadable(config_path)
  execute 'source ' . expand(config_path)
endif
let g:social_snippet_cache = g:social_snippet_home . '/cache'

" commands
command! SocialSnippetVersion echomsg social_snippet#GetVersion()
command! SocialSnippetReset call social_snippet#Reset()
command! SocialSnippetSetup call social_snippet#Setup()
command! -nargs=1 SocialSnippetInstallRepository call social_snippet#InstallRepository(<f-args>)
command! SocialSnippetUpdateRepository call social_snippet#UpdateRepository()
command! SocialSnippetInsertSnippet call social_snippet#InsertSnippet()

