command! SocialSnippetVersion echomsg social_snippet#GetVersion()
command! SocialSnippetReset call social_snippet#Reset()
command! SocialSnippetSetup call social_snippet#Setup()
command! -nargs=1 SocialSnippetInstallRepository call social_snippet#InstallRepository(<f-args>)
command! SocialSnippetUpdateRepository call social_snippet#UpdateRepository()
command! SocialSnippetInsertSnippet call social_snippet#InsertSnippet()

