module Ajax
  module Helpers
    module UrlHelper

      # Return a boolean indicating whether the given URL points to the
      # root path.
      def url_is_root?(url)
        !!(encode_and_parse_url(url).path =~ %r[^\/?$])
      end

      # The URL is hashed if the fragment part starts with a /
      #
      # For example, http://lol.com#/Rihanna
      def is_hashed_url?(url)
        !!(encode_and_parse_url(url).fragment=~ %r[^\/])
      end
      
      # Return a hashed URL using the fragment of <tt>url</tt>
      def hashed_url_from_fragment(url)
        url_host(url) + ('/#/' + (encode_and_parse_url(url).fragment || '')).gsub(/\/\//, '/')
      end

      # Return a traditional URL from the fragment of <tt>url</tt>
      def traditional_url_from_fragment(url)
        url_host(url) + ('/' + (encode_and_parse_url(url).fragment || '')).gsub(/\/\//, '/')
      end

      # Return a hashed URL formed from a traditional <tt>url</tt>
      def hashed_url_from_traditional(url)
        uri = encode_and_parse_url(url)
        hashed_url = url_host(url) + ('/#/' + (uri.path || '')).gsub(/\/\//, '/')
        hashed_url += ('?' + uri.query) unless uri.query.nil?
        hashed_url
      end

      protected
      
      def encode_and_parse_url(url)
        URI.parse(URI.encode(url).gsub("%23", "#"))
      end
       
      def url_host(url)
        if url.match(/^(\w+\:\/\/[^\/]+)\/?/)
          $1
        else
          ''
        end
      end
    end
  end
end