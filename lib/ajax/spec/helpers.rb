require 'uri'

module Ajax
  module Spec
    module Helpers

      def create_app
        @app = Class.new { def call(env); true; end }.new
      end

      def env(uri)
        uri = URI.parse(uri)
        @env = {'REQUEST_URI' => uri.to_s, 'PATH_INFO' => uri.path, 'QUERY_STRING' => uri.query}
      end

      def call_rack(url, &block)
        env(url)
        @rack = Rack::Ajax.new(@app, &block)
      end

      def should_redirect_to(location, code=302)
        ret = @rack.call(@env)
        ret[0].should == code
        ret[1]['Location'].should == location
      end

      def should_rewrite_to(url)
        ret = @rack.call(@env)
        ret[2]['REQUEST_URI'].should == url
      end

      def should_not_modify_request
        ret = @rack.call(@env)
        @env.each do |k,v|
          ret[2][k].should == v
        end
        ret[0].should == 200
      end
    end
  end
end