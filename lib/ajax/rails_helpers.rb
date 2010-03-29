module Ajax
  module RailsHelpers
    def set_header(object, key, value)
      headers = object.is_a?(::ActionController::Response) ? object.headers : object
      headers["Ajax-Info"] = object.headers["Ajax-Info"] || {}
      headers["Ajax-Info"][key.to_s] = value
    end

    def get_header(object, key)
      headers = object.is_a?(::ActionController::Request) ? object.headers : object
      if headers["Ajax-Info"].nil?
        headers["Ajax-Info"] = if headers['HTTP_AJAX_INFO']
          require 'json'
          headers['Ajax-Info'] = JSON.parse(headers['HTTP_AJAX_INFO'])
        else
          {}
        end
      end
      headers['Ajax-Info'][key.to_s]
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