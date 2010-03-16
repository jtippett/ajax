module Ajax
  module Helpers

    # The URL is hashed if the fragment part starts with a /
    #
    # For example, http://lol.com#/Rihanna
    def is_hashed_url?(url)
      !!(URI.parse(url).fragment =~ %r[^\/])
    end

    # Return a hashed URL using the fragment of <tt>url</tt>
    def hashed_url_from_fragment(url)
      ('/#/' + (URI.parse(url).fragment || '')).sub /\/\//, '/'
    end

    # Return a traditional URL from the fragment of <tt>url</tt>
    def traditional_url_from_fragment(url)
      ('/' + (URI.parse(url).fragment || '')).sub /\/\//, '/'
    end
  end
end