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
end
