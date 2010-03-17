require 'spec_helper'

context 'Ajax::Helpers' do

  describe "(URL) hashed_url_from_traditional" do
    it "should handle a query string" do
      Ajax.hashed_url_from_traditional('/Beyonce?one=1').should == '/#/Beyonce?one=1'
    end

    it "should ignore the fragment" do
      Ajax.hashed_url_from_traditional('/Beyonce?one=1#fragment').should == '/#/Beyonce?one=1'
    end

    it "should handle no query string" do
      Ajax.hashed_url_from_traditional('/Beyonce').should == '/#/Beyonce'
    end
  end

  describe "(URL) hashed_url_from_fragment" do
    it "should strip double slashes" do
      Ajax.hashed_url_from_fragment('/Beyonce#/Akon').should == '/#/Akon'
      Ajax.hashed_url_from_fragment('/Beyonce#Akon').should == '/#/Akon'
    end

    it "should handle no fragment" do
      Ajax.hashed_url_from_fragment('/Beyonce').should == '/#/'
    end
  end

  describe "(boolean) url_is_root?" do
    it "should detect root urls" do
      Ajax.url_is_root?('/#/Beyonce?query2').should be(true)
      Ajax.url_is_root?('/').should be(true)
    end

    it "should detect non-root urls" do
      Ajax.url_is_root?('/Beyonce').should be(false)
    end
  end

  describe "(boolean) is_hashed_url?" do
    it "should return false for fragments that don't start with /" do
      Ajax.is_hashed_url?('/Beyonce#Akon').should be(false)
      Ajax.is_hashed_url?('/Beyonce?query#Akon/').should be(false)
    end

    it "should return false for no fragment" do
      Ajax.is_hashed_url?('/Beyonce?query%23/').should be(false)
    end

    it "should return true if the fragment starts with /" do
      Ajax.is_hashed_url?('/Beyonce#/Akon').should be(true)
      Ajax.is_hashed_url?('/#/Akon').should be(true)
    end
  end

  describe "(URL) traditional_url_from_fragment" do
    it "should handle slashes" do
      Ajax.traditional_url_from_fragment('/Beyonce#Akon').should == '/Akon'
      Ajax.traditional_url_from_fragment('/Beyonce#/Akon').should == '/Akon'
      Ajax.traditional_url_from_fragment('/Beyonce#/Akon/').should == '/Akon/'
    end

    it "should handle no fragment" do
      Ajax.traditional_url_from_fragment('/Beyonce').should == '/'
    end
  end
end

