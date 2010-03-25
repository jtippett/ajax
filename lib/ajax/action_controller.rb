module Ajax
  module ActionController
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :render, :ajax
      end
      klass.extend(ClassMethods)
    end

    module ClassMethods
      # Specify a method to be called before render is invoked.  This method
      # will handle setting custom response headers that the Ajax framework
      # can use.
      #
      # Example:
      #
      #   class HomeController < ApplicationController
      #     before_render :include_custom_response_headers
      #
      #     # you can disable calling this method on a controller-by-controller basis:
      #     skip_filter :include_custom_response_headers
      #
      #     def include_custom_response_headers
      #       response.headers['Ajax-Page-Title'] = title
      #     end
      #   end
      #
      # Valid Options:
      #
      # * <tt>:only/:except</tt> - Passed to the <tt>after_filter</tt> call.  Set which actions are verified.
      def before_render(method)
        after_filter method if Ajax.is_enabled?
      end
    end

    protected

      # Don't include the layout by default if the request is AJAX.
      def render_with_ajax(options = nil, extra_options = {}, &block)
        if Ajax.is_enabled?
          if request.xhr?
            if options.nil?
              options = { :layout => false }
            elsif options.is_a?(Hash)
              options.reverse_merge!({ :layout => false })
            end
          end

          # Add custom headers that contain information about the
          # layout of the current render.
          response.headers["Ajax-Layout"] = default_layout.to_s
        end
        render_without_ajax(options, extra_options, &block)
      end
  end
end