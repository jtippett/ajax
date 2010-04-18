# The <tt>rewrite</tt> and <tt>redirect</tt> methods are terminal methods meaning
# that they return a Rack response or modify the Rack request.
#
# Return <tt>nil</tt> to allow the request to fall-through to the Application.
module Rack
  class Ajax
    class Parser

      # Instantiate an ActionController::Request object to make it
      # easier to introspect the headers.
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

      # Return a boolean indicating if the request is from a robot.
      #
      # Inspect the headers first - if there are any - so we don't
      # look in the database unneccessarily.
      #
      # Sets the result in a header {Ajax-Info}[user_is_robot] so we 
      # don't have to repeat this check in the application.
      def user_is_robot?
        return @user_is_robot if instance_variable_defined?(:@user_is_robot)
        @user_is_robot =
          if @request.user_agent.nil?
            false
          else
            ::Ajax.is_robot?(@request.user_agent)
          end
        ::Ajax.set_header(@env, :robot, @user_is_robot)
        @user_is_robot
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

      # Redirect to the hashed URL equivalent of the current traditional URL.
      # The user has likely followed a traditional link or bookmark.
      def redirect_to_hashed_url_equivalent
        r302(::Ajax.hashed_url_from_traditional(@env['REQUEST_URI']))
      end

      def rewrite_to_render_ajax_framework
        rewrite('/ajax/framework')
      end

      private

      def r302(url)
        rack_response('Redirecting...', 302, 'Location' => url)
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

      # You can use this method during integration testing Rack::Ajax
      # in your Rails app.  If you don't return a proper Rack response
      # during integration testing, ActiveSupport can't parse the
      # response.
      #
      # If you're testing Rack without Rails you can return base types
      # so you don't need this method.
      def self.rack_response(msg, code=200, headers={})
        headers.reverse_merge!({'Content-Type' => 'text/html'})
        [code, headers, [msg.to_s]]
      end
      
      def rack_response(*args)
        self.class.rack_response(*args)
      end
    end
  end
end