require 'spec_helper'

context 'Ajax::Helpers' do

  describe "hashed_url_from_fragment" do
    it "should strip double slashes" do
      Ajax.hashed_url_from_fragment('/Beyonce#/Akon').should == '/#/Akon'
      Ajax.hashed_url_from_fragment('/Beyonce#Akon').should == '/#/Akon'
    end

    it "should handle no fragment" do
      Ajax.hashed_url_from_fragment('/Beyonce').should == '/#/'
    end
  end
end

