# Test Rack middleware using integration tests because the Spec controller tests
# do not invoke Rack.
require 'spec_helper'
require 'ajax/spec/helpers'
require 'uri'

include Ajax::Spec::Helpers

# Test the Rack::Ajax::Parser.  See <tt>lib/rack-ajax-parser.rb</tt>
#
# Test Rack middleware using integration tests because the Spec controller tests
# do not invoke Rack.
describe Rack::Ajax::Parser, :type => :integration do
  before :all do
    mock_ajax
    create_app
  end

  it "should recognize robots" do
    call_rack('/', 'GET', { 'HTTP_USER_AGENT' => 'Googlebot' }) do
      rack_response(user_is_robot?)
    end
    should_set_ajax_request_header('robot', true)
  end
  
  it "should recognize regular users" do
    call_rack('/', { 'HTTP_USER_AGENT' => 'Safari' }) do
      rack_response(user_is_robot?)
    end      
    should_set_ajax_request_header('robot', false)
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
end
