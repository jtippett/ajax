module Rack
  class Ajax
    class Parser
      def initialize(env)
        @env = env
        @request = ActionController::Request.new(env)
        @params = request.params
      end

      protected

      def hashed_url?
        @hashed_url ||= @request.path
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
        @url_is_root ||= @request.path =~ %r[\/?]
      end

      def user_is_robot?
        @user_is_robot ||= (Utilities::RobotFinder.robot_for(@request.user_agent) && true)
      end

      def r302(url)
        [302, {'Location' => url, 'Content-Type' => 'text/html'}, ['Redirecting...']]
      end

      def rewrite(interpreted_to)
        env['REQUEST_URI'] = interpreted_to
        if q_index = interpreted_to.index('?')
          env['PATH_INFO'] = interpreted_to[0..q_index-1]
          env['QUERY_STRING'] = interpreted_to[q_index+1..interpreted_to.size-1]
        else
          env['PATH_INFO'] = interpreted_to
          env['QUERY_STRING'] = ''
        end
      end

      def rewrite_to_traditional_url
        'AJAX'
      end

      def redirect_to_fragment_of_url
        'non-AJAX'
      end

      def redirect_to_hashed_url
        'AJAX'
      end
    end
  end
end