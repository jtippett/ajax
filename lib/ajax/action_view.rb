module Ajax
  module ActionView
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :link_to, :ajax
      end
    end

    protected

      # Include an attribute on all outgoing links to mark them as Ajax deep links.
      #
      # The deep link will be the path and query string from the href.
      #
      # To specify a different deep link pass <tt>:data-deep-link => '/deep/link/path'</tt>
      # in the <tt>link_to</tt> <tt>html_options</tt>.
      #
      # To turn off deep linking for a URL, pass <tt>:traditional => true</tt> or
      # <tt>:data-deep-link => false</tt>.
      def link_to_with_ajax(*args, &block)
        if Ajax.is_enabled? && !block_given?
          options      = args.second || {}
          html_options = args.third
          html_options = (html_options || {}).stringify_keys

          # Insert the deep link unless the URL is traditional
          if !html_options.has_key?('data-deep-link') && !html_options.delete('traditional')
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