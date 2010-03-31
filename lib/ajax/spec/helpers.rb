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
        should_be_a_valid_response
        response_body.should == msg
      end

      def should_redirect_to(location, code=302)
        should_be_a_valid_response
        response_code.should == code
        response_headers['Location'].should == location
      end

      def should_rewrite_to(url)
        should_be_a_valid_response

        # Check custom headers
        response_body_as_hash['REQUEST_URI'].should == url
      end

      def should_not_modify_request
        should_be_a_valid_response
        response_code.should == 200

        # If we have the original headers from a call to call_rack()
        # check that they haven't changed.  Otherwise, just make sure
        # that we don't have the custom rewrite header.
        if !@env.nil?
          @env.each { |k,v| response_body_as_hash.should == v }
        end
      end

      # Response must be [code, {headers}, ['Response']]
      # Headers must contain the Content-Type header
      def should_be_a_valid_response
        return if @response.is_a?(::ActionController::Response)
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

      def response_body
        @response.is_a?(::ActionController::Response) ? @response.body : @response[2][0]
      end

      def response_code
        @response.is_a?(::ActionController::Response) ? @response.status.to_i : @response[0]
      end

      def response_headers
        @response.is_a?(::ActionController::Response) ? @response.headers.to_hash : @response[1]
      end

      def response_body_as_hash
        @response_body_as_hash ||= YAML.load(response_body)
      end
    end
  end
end