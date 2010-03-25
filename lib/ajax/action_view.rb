module Ajax
  module ActionView
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :link_to, :ajax
      end
    end

    protected

      # Include the <tt>rel="address: "</tt> for Ajax
      def link_to_with_ajax(*args, &block)
        if Ajax.is_enabled? && !block_given?
          options      = args.second || {}
          html_options = args.third

          html_options = (html_options || {}).stringify_keys
          unless html_options['data-deep-link']
            path = url_for(options)
            if path.match(%r[^(http:\/\/[^\/]*)(\/?.*)])
              path = $2
            end
            html_options['data-deep-link'] = path
          end
          args[2] = html_options
        end
        link_to_without_ajax(*args, &block)
      end
  end
end