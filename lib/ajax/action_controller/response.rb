module Ajax
  module ActionController
    module Response

      def self.included(klass)
        klass.class_eval do
          alias_method_chain :redirect, :ajax
        end
      end

      # Redirect to hashed URLs unless the path is excepted.
      #
      # If redirecting back to the referer, use the referer
      # in the Ajax-Info header.
      def redirect_with_ajax(url, status)
        unless Ajax.exclude_path?(url) || Ajax.is_hashed_url?(url)
          url = Ajax.hashed_url_from_traditional(url)
          Rails.logger.debug("-> rewrote redirect to #{url}")
        end
        redirect_without_ajax(url, status)
      end
    end
  end
end