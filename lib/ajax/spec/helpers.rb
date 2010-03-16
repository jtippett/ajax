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

      def should_redirect_to(location, code)
        ret = @rack.call(@env)
        assert_equal code, ret[0]
        assert_equal location, ret[1]['Location'], 'Location is incorrect'
      end

      def should_rewrite_to(url)
        ret = @rack.call(@env)
        assert_equal url, ret[2]['REQUEST_URI'], 'Rewritten URL is incorrect'
      end
    end
  end
end