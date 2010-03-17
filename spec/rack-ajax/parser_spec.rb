# Test Rack middleware using integration tests because the Spec controller tests
# do not invoke Rack.
require 'spec_helper'
require 'ajax/spec/helpers'

include Ajax::Spec::Helpers

# Test the Rack handling of AJAX urls
describe Rack::Ajax::Parser, :type => :integration do
  before :all do
    mock_ajax
    create_app
  end

  it "should be able to tell if a url is root" do
    call_rack('/') { rack_response(url_is_root?) }
    should_respond_with('true')

    call_rack('/Beyonce') { rack_response(url_is_root?) }
    should_respond_with('false')

    call_rack('/#/Beyonce?query2') { rack_response(url_is_root?) }
    should_respond_with('true')
  end

  it "should redirect to hashed url from fragment" do
    call_rack('/Beyonce?page=1#/Akon') do
      redirect_to_hashed_url_from_fragment
    end
    should_redirect_to('/#/Akon', 302)
  end

  it "should rewrite to traditional url from fragment" do
    call_rack('/Beyonce?page=1#/Akon?query2') do
      rewrite_to_traditional_url_from_fragment
    end
    should_rewrite_to('/Akon?query2')
  end

  it "should return a valid rack response" do
    call_rack('/') { rack_response('test') }
    should_respond_with('test')
  end

  # We only get the environment returned to us on rewrites,
  # so do a rewrite and inspect the result manually.
  it "should set a custom header on rewrites" do
    call_rack('/Beyonce?page=1#/Akon?query2') do
      rewrite_to_traditional_url_from_fragment
    end
    response_body_as_hash[Rack::Ajax::Parser::RACK_AJAX_REWRITE].should_not be(nil)
    response_body_as_hash[Rack::Ajax::Parser::RACK_AJAX_REWRITE].should == response_body_as_hash['REQUEST_URI']
  end
end
