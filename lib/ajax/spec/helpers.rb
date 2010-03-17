require 'uri'

module Ajax
  module Spec
    module Helpers

      def create_app
        @app = Class.new { def call(env); true; end }.new
      end

      def call_rack(url, request_method='GET', &block)
        env(url, request_method)
        @rack = Rack::Ajax.new(@app, &block)
        @response = @rack.call(@env)
      end

      def should_redirect_to(location, code=302)
        @response[0].should == code
        @response[1]['Location'].should == location
      end

      def should_rewrite_to(url)
        @response[2].class.should be(Hash)
        @response[2]['REQUEST_URI'].should == url
      end

      def should_not_modify_request
        @response[2].class.should be(Hash)
        @env.each do |k,v|
          @response[2][k].should == v
        end
        @response[0].should == 200
      end

      def env(uri, request_method)
        uri = URI.parse(uri)
        @env = {
          'REQUEST_URI' => uri.to_s,
          'PATH_INFO' => uri.path,
          'QUERY_STRING' => uri.query,
          'REQUEST_METHOD' => request_method
        }
      end
    end
  end
end