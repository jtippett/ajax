module Rack
  module Ajax
    module DecisionTree
      
      # Decision tree for Rack rewrites and redirects.
      #
      # To use your own decision tree set it on the <tt>Ajax</tt> instance with:
      #
      #     Ajax.decision_tree = Proc.new do
      #       # your code
      #     end
      #
      # Note: User agents never send the hashed part of the URL, meaning some of
      # the conditions below will never be true, but I've included them for
      # completeness.
      def default_decision_tree
        @@default_decision_tree ||= Proc.new do
          ::Ajax.logger.debug("[ajax] rack session #{@env['rack.session'].inspect}")
          ::Ajax.logger.debug("[ajax] Ajax-Info #{@env['Ajax-Info'].inspect}")
        
          if !::Ajax.exclude_path?(@env['PATH_INFO'] || @env['REQUEST_URI'])
            if ajax_request?
              if hashed_url? # the browser never sends the hashed part
                rewrite_to_traditional_url_from_fragment
              end
            else
              if url_is_root?
                if hashed_url? # the browser never sends the hashed part
                  rewrite_to_traditional_url_from_fragment
                elsif get_request? && !user_is_robot?
                  # When we render the framework we would like to show the
                  # page the user wants on the first request.  If the
                  # session has a value for <tt>redirected_to</tt> then
                  # that page will be rendered.
                  if redirected_to = (@env['rack.session'][:redirected_to] || @env['rack.session']['redirected_to'])
                    redirected_to = ::Ajax.is_hashed_url?(redirected_to) ? ::Ajax.traditional_url_from_fragment(redirected_to) : redirected_to
                    ::Ajax.logger.debug("[ajax] showing #{redirected_to} instead of root_url")
                    rewrite(redirected_to)
                  else
                    rewrite_to_render_ajax_framework
                  end
                end
              else
                if !user_is_robot?
                  if hashed_url? # will never be true
                    redirect_to_hashed_url_from_fragment
                  else
                    if get_request?
                      redirect_to_hashed_url_equivalent
                    end
                  end
                end
              end
            end
          end          
        end
      end
    end
  end
end