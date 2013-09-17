require 'vimrunner'
require 'vimrunner/rspec'

def RunVimTest(script_name)
  script_path = File.expand_path("../#{script_name}", __FILE__)
  vim.edit(script_path)
  ret = vim.command('VimTest')
  fail_num = ret.match(/Failures: ([0-9]+)/)[1].to_i
  fail_num == 0
end

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true
  config.start_vim do
    vim = Vimrunner.start
    vim.add_plugin(File.expand_path('../plugin/vimtest', __FILE__), 'plugin/vimtest.vim')
    vim.add_plugin(File.expand_path('../../', __FILE__), 'plugin/social_snippet_plugin.vim')
    vim
  end
end
