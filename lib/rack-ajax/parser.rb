# The <tt>rewrite</tt> and <tt>redirect</tt> methods are terminal methods meaning
# that they return a Rack response or modify the Rack request.
#
# Return <tt>nil</tt> to allow the request to fall-through to the Application.
module Rack
  class Ajax
    class Parser
      def initialize(env)
        @env = env
        @request = ActionController::Request.new(env)
      end

      protected

      def hashed_url?
        @hashed_url ||= ::Ajax.is_hashed_url?(@env['REQUEST_URI'])
      end

      def ajax_request?
        @request.xml_http_request?
      end

      def get_request?
        @request.get?
      end

      def post_request?
        @request.post?
      end

      def url_is_root?
        @url_is_root ||= ::Ajax.url_is_root?(@env['PATH_INFO'])
      end

      def rewrite_to_traditional_url_from_fragment
        rewrite(::Ajax.traditional_url_from_fragment(@env['REQUEST_URI']))
      end

      # Redirect to a hashed URL consisting of the fragment portion of the current URL.
      # This is an edge case.  What can theoretically happen is a user visits a
      # bookmarked URL, then browses via AJAX and ends up with a URL like
      # '/Beyonce#/Akon'.  Redirect them to '/#/Akon'.
      def redirect_to_hashed_url_from_fragment
        r302(::Ajax.hashed_url_from_fragment(@env['REQUEST_URI']))
      end

      private

      def r302(url)
        [302, {'Location' => url, 'Content-Type' => 'text/html'}, ['Redirecting...']]
      end

      def rewrite(interpreted_to)
        @env['REQUEST_URI'] = interpreted_to
        if q_index = interpreted_to.index('?')
          @env['PATH_INFO'] = interpreted_to[0..q_index-1]
          @env['QUERY_STRING'] = interpreted_to[q_index+1..interpreted_to.size-1]
        else
          @env['PATH_INFO'] = interpreted_to
          @env['QUERY_STRING'] = ''
        end
        nil # fallthrough to app
      end
    end
  end
end