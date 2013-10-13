require 'vimrunner'
require 'vimrunner/rspec'

TMP_DIR = "/tmp/test_social_snippet"

def _mkdir_tmp
  unless File.directory? "#{TMP_DIR}"
    _rm_tmp
    Dir.mkdir "#{TMP_DIR}"
  end
end

def _mkdir(path)
  Dir.mkdir "#{TMP_DIR}/#{path}"
end

def _touch(path)
  FileUtils.touch "#{TMP_DIR}/#{path}"
end

def _rm(path)
  if File.exists? "#{TMP_DIR}/#{path}"
    FileUtils.rm_r "#{TMP_DIR}/#{path}", :secure => true
  end
end

def _rm_tmp
  if File.directory? "#{TMP_DIR}"
    FileUtils.rm_r "#{TMP_DIR}", :secure => true
  end
end

def RunVimTest(script_name)
  script_path = File.expand_path("../#{script_name}", __FILE__)
  vim.edit(script_path)
  ret = vim.command('VimTest')
  # to debug
  puts ""
  puts "@RunVimTest ------------"
  puts ret
  puts "------------------------"
  puts ""
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
