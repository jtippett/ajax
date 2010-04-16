require 'spec_helper'

include Ajax::RailsHelpers

describe 'Ajax::RailsHelpers' do
  describe 'set_header' do
    before :each do
      @headers = {}
    end

    it "should add headers" do
      set_header @headers, :tab, '#main .home_tab'
      @headers['Ajax-Info']['tab'].should == '#main .home_tab'
    end

    it "should add assets" do
      set_header @headers, :assets, { :key => ['value'] }
      @headers['Ajax-Info']['assets'].should == { :key => ['value'] }
    end

    it "should merge hashes" do
      set_header @headers, :assets, { :key => ['value1'] }
      set_header @headers, :assets, { :key => ['value2'] }
      @headers['Ajax-Info']['assets'].should == { :key => ['value1', 'value2'] }
    end
    
    it "should concat arrays" do
      set_header @headers, :callbacks, ['one']
      set_header @headers, :callbacks, ['two']
      @headers['Ajax-Info']['callbacks'].should == ['one', 'two']
    end    
  end
end