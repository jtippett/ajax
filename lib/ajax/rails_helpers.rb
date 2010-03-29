module Ajax
  module RailsHelpers
    def set_header(object, key, value)
      object.headers["Ajax-Info"] = object.headers["Ajax-Info"] || {}
      object.headers["Ajax-Info"][key.to_s] = value
    end

    # Given a path, return a hash containing a tag(s) to set on the link.
    #
    # WillPaginate uses the <tt>rel</tt> tag on the page links, so I prefer
    # 'data-ajax-link'.
    def link_to_tag(address)
      { 'data-ajax-link' => address }
    end
  end
end