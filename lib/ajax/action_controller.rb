module Ajax
  module ActionController
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :render, :ajax
        alias_method_chain :redirect_to_full_url, :ajax

        append_after_filter :process_response_headers
      end
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # Set a custom response header if the request is AJAX.
      #
      # Call with <tt>key</tt> and optional <tt>value</tt>.  Pass a
      # block to yield a dynamic value.
      #
      # Accepts :only and :except conditions because we create
      # an after_filter.
      def ajax_header(*args, &block)
        return unless Ajax.is_enabled?

        options = args.extract_options!
        key, value = args.shift, args.shift
        value = block_given? ? Proc.new : value

        prepend_after_filter(options) do |controller|
          if controller.request.xhr?
            value = value.is_a?(Proc) ? controller.instance_eval(&value) : value
            Ajax.set_header(controller.response, key, value)
          end
        end
      end

      # Set the layout to use for AJAX requests.
      #
      # By default we look in layouts/ajax/ for this controllers default
      # layout and render that.  If it can't be found, the default layout
      # is used.
      def ajax_layout(template_name)
        write_inheritable_attribute(:ajax_layout, template_name)
      end
    end

    protected

      # Redirect to hashed URLs unless the path is excepted.
      #
      # Store the URL that we are redirecting to in the session.
      # If we then have a request for the root URL we know
      # to render this URL into it.
      #
      # If redirecting back to the referer, use the referer
      # in the Ajax-Info header because it includes the
      # hashed part of the URL.  Otherwise the referer is
      # always the root url.
      #
      # For AJAX requests, respond with an AJAX-suitable
      # redirect.
      def redirect_to_full_url_with_ajax(url, status)
        raise DoubleRenderError if performed?
        if url == request.headers["Referer"] && !request.headers['Ajax-Info'].blank?
          url = request.headers['Ajax-Info']['referer']
          Ajax.logger.debug("[ajax] using referer #{url} from Ajax-Info")
        end

        if !Ajax.exclude_path?(url) && !Ajax.is_hashed_url?(url)
          url = Ajax.hashed_url_from_traditional(url)
          Ajax.logger.info("[ajax] rewrote redirect to #{url}")
        end

        session[:redirected_to] = url
        if request.xhr?
          render(:update) { |page| page.redirect_to(url) }
        else
          redirect_to_full_url_without_ajax(url, status)
        end
      end

      # Convert the Ajax-Info hash to JSON before the request is sent.
      def process_response_headers
        case response.headers['Ajax-Info']
        when Hash
          response.headers['Ajax-Info'] = response.headers['Ajax-Info'].to_json
        end
      end

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
          default = default.path_without_format_and_extension unless default.nil?
          ajax_layout = layout_for_ajax(default)
          ajax_layout = ajax_layout.path_without_format_and_extension unless ajax_layout.nil?
          options[:layout] = ajax_layout unless ajax_layout.nil?

          # Send the current layout and controller in a custom response header
          Ajax.set_header(response, :layout, ajax_layout)
          Ajax.set_header(response, :controller, self.class.controller_name)
        end
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
          find_layout("layouts/ajax/#{default.sub(/layouts(\/)?/, '')}", default_template_format) unless default.nil?
        else
          ajax_layout
        end
      rescue ::ActionView::MissingTemplate
        Ajax.logger.info("[ajax] no layout found in layouts/ajax using #{default}")
        default
      end
  end
end