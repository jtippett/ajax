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
      # can use.  No filter will be created if Ajax is not enabled.
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

      def ajax_layout(template_name)
        write_inheritable_attribute(:ajax_layout, template_name)
      end
    end

    protected

      #
      # Intercept rendering to customize the headers and layout handling
      #
      def render_with_ajax(options = nil, extra_options = {}, &block) #:nodoc:
        original_args = [options, extra_options]

        if Ajax.is_enabled? && request.xhr?

          # Options processing taken from ActionController::Base#render
          if options.nil?
            options = { :template => default_template, :layout => true }
          elsif options == :update
            options = extra_options.merge({ :update => true })
          elsif options.is_a?(String) || options.is_a?(Symbol)
            case options.to_s.index('/')
            when 0
              extra_options[:file] = options
            when nil
              extra_options[:action] = options
            else
              extra_options[:template] = options
            end
            options = extra_options
          elsif !options.is_a?(Hash)
            extra_options[:partial] = options
            options = extra_options
          end

          default = pick_layout(options)
          options[:layout] = layout_for_ajax(default.to_s)

          # Send the current layout in a custom response header
          response.headers["Ajax-Layout"] = options[:layout].to_s
        end
            # Rails.logger.debug("pick layout #{pick_layout(options).to_s}")
            # Rails.logger.debug("active layout #{active_layout.to_s}")
            # Rails.logger.debug("default layout #{default_layout.to_s}")
            # Rails.logger.debug("default template #{default_template.to_s}")
            # Rails.logger.debug("default template format #{default_template_format.to_s}")
        #
        #     # options = options.nil? ? {} : options
        #     # if options.is_a?(Hash) && !options.has_key?(:layout)
        #     #   layout = pick_layout(options).to_s
        #     #   options[:layout] = layout.nil? ? nil : layout_for_ajax(layout)
        #     # end
        #     Rails.logger.debug("ajax layout #{options.inspect}")
        #   end
        #

        # end
        render_without_ajax(options, extra_options, &block)
      end

      # Return the layout to use for an AJAX request, or the default layout if one
      # cannot be found.  If no default is known, <tt>layouts/ajax/application</tt> is used.
      #
      # If no ajax_layout is set, look for the default layout in <tt>layouts/ajax</tt>.
      # If the layout cannot be found, use the default.
      #
      def layout_for_ajax(default) #:nodoc:
        ajax_layout = self.class.read_inheritable_attribute(:ajax_layout)
        if ajax_layout.nil? || !(ajax_layout =~ /^layouts\/ajax/)
          find_layout("layouts/ajax/#{default.sub(/layouts(\/)?/, '')}", default_template_format)
        else
          ajax_layout
        end
      rescue ::ActionView::MissingTemplate
        Rails.logger.debug("ajax layout missing! using #{default}")
        default
      end
  end
end