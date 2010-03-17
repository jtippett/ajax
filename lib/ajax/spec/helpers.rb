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

      def should_respond_with(msg)
        should_be_a_rack_response
        @response[2][0].should == msg
      end

      def should_redirect_to(location, code=302)
        should_be_a_rack_response
        @response[0].should == code
        @response[1]['Location'].should == location
      end

      def should_rewrite_to(url)
        should_be_a_rack_response
        env = YAML.load(@response[2][0])
        env['REQUEST_URI'].should == url

        # Check custom headers
        env[Rack::Ajax::Parser::RACK_AJAX_REWRITE].should_not be(nil)
        env[Rack::Ajax::Parser::RACK_AJAX_REWRITE].should == env['REQUEST_URI']
      end

      def should_not_modify_request
        should_be_a_rack_response
        @response[2].class.should be(Hash)
        @env.each do |k,v|
          @response[2][k].should == v
        end
        @response[0].should == 200
      end

      # Response must be [code, {headers}, ['Response']]
      # Headers must contain the Content-Type header
      def should_be_a_rack_response
        @response.should be_a_kind_of(Array)
        @response.size.should == 3
        @response[0].should be_a_kind_of(Integer)
        @response[1].should be_a_kind_of(Hash)
        @response[1]['Content-Type'].should =~ %r[^text\/\w+]
        @response[2].should be_a_kind_of(Array)
        @response[2][0].should be_a_kind_of(String)
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