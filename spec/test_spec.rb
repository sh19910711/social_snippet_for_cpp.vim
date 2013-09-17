require 'spec_helper'

describe 'social_snippet_plugin.vim' do
  it 'version' do
    RunVimTest('test_version.vim').should == true
  end
end

