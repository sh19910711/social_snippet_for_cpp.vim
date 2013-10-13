require 'spec_helper'

describe 'T001' do
  before do
    _mkdir_tmp
    _rm 't001'
    _mkdir 't001'
  end

  # it '000: version' do
  #   RunVimTest('test_version.vim').should == true
  # end

  describe '001: #get_dir_list' do
    before do
      _mkdir 't001/001'
      _mkdir 't001/001/test3'
      _mkdir 't001/001/test1'
      _touch 't001/001/test1/test'
      _touch 't001/001/test2'
    end
    it '001' do
      RunVimTest('test_t001_001_001.vim').should == true
    end
  end

  describe '002: #get_snippet_info' do
    it '001' do
      RunVimTest('test_t001_002_001.vim').should == true
    end
  end
end

