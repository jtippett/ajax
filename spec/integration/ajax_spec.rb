require 'spec_helper'
require 'uri'
require 'ajax/spec/helpers'

include Ajax::Spec::Helpers

# Test the Rack::Ajax handling of urls according to our block from
# <tt>config/initializers/ajax.rb</tt>
#
# Test Rack middleware using integration tests because the Spec controller tests
# do not invoke Rack.
context 'Rack::Ajax' do
  before :all do
    mock_ajax      # Force a return from Rack::Ajax
  end

  after :all do
    unmock_ajax
  end
  
  context "XMLHttpRequest" do
    context "hashed url" do
      it "should rewrite GET request" do
        xhr(:get, '/?query1#/Beyonce?query2')
        should_rewrite_to('/Beyonce?query2')
      end
  
      it "should not modify POST" do
        xhr(:post, '/#/user_session/new?param1=1&param2=2')
        should_not_modify_request
      end
    end
  
    context "traditional url" do
      it "should not be modified" do
        xhr(:get, '/Beyonce')
        should_not_modify_request
      end
  
      it "should not be modified" do
        xhr(:post, '/user_session/new?param1=1&param2=2')
        should_not_modify_request
      end
    end
  end

  context "request for root url" do
    it "should not be modified" do
      get('/')
      should_not_modify_request
    end
    
    it "should not be modified" do
      get('/?query_string')
      should_not_modify_request
    end

    it "should be rewritten if it is hashed" do
      get('/?query1#/Beyonce?query2')
      should_rewrite_to('/Beyonce?query2')
    end
  end

  context "robot" do
    before :each do
      @user = login_robot_user
    end
  
    it "should not modify request for root" do
      get('/')
      should_not_modify_request
    end
  
    it "should not modify traditional requests" do
      get('/Beyonce')
      should_not_modify_request
    end
  
    context "request hashed" do
      context "non-root url" do
        it "should not modify the request" do
          get('/Akon/?query1#/Beyonce?query2')
          should_not_modify_request
        end
      end
  
      context "root url" do
        it "should rewrite to traditional url" do
          get('/#/Beyonce?query2')
          should_rewrite_to('/Beyonce?query2')
        end
      end
    end
  end
  
  context "regular user" do
    it "should not modify request for root" do
      get('/')
      should_not_modify_request
    end
  
    it "should ignore query string on root url" do
      get('/?query1#/Beyonce?query2')
      should_rewrite_to('/Beyonce?query2')
    end
  
    context "request hashed" do
      context "non-root url" do
        it "should redirect to hashed part at root" do
          get('/Akon/?query1#/Beyonce?query2')
          should_redirect_to('/#/Beyonce?query2')
        end
      end
  
      context "root url" do
        it "should rewrite to traditional url" do
          get('/#/Beyonce?query2')
          should_rewrite_to('/Beyonce?query2')
        end
      end
    end
  
    context "request traditional url" do
      it "should not be modified" do
        get('/')
        should_not_modify_request
      end
      it "should not be modified" do
        get('/?query_string')
        should_not_modify_request
      end
  
      it "should redirect GET request" do
        get('/Beyonce')
        should_redirect_to('/#/Beyonce')
      end
  
      it "should not modify non-GET request" do
        %w[post put delete].each do |method|
          send(method, '/')
          should_not_modify_request
        end
      end
    end
  end
end