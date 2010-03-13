module Ajax
  module Helpers

    # The URL is hashed if the fragment part starts with a /
    #
    # For example, http://lol.com#/Rihanna
    def is_hashed_url?(url)
      URI.parse(url).fragment =~ %r[^\/]
    end
  end
end