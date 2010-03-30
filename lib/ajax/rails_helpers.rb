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
        headers["Ajax-Info"] = {}
      elsif headers["Ajax-Info"].is_a?(String)
        require 'json'
        headers["Ajax-Info"] = (JSON.parse(headers['HTTP_AJAX_INFO']) rescue {})
      end
      headers['Ajax-Info'][key.to_s]
    end

    # Set one or more paths that can be accessed directly without the AJAX framework.
    #
    # Useful for excluding pages with HTTPS content on them from being loaded
    # via AJAX.
    #
    # <tt>paths</tt> a list of String or Regexp instances that are matched
    # against each REQUEST_PATH.
    #
    # If the path is a string it is used to create a regular expression that
    # is able to match when the path includes the host and protocol.
    def exclude_paths(paths=nil)
      if !instance_variable_defined?(:@exclude_paths)
        @exclude_paths = []
      end
      (paths || []).each do |path|
        @exclude_paths << (path.is_a?(Regexp) ? path : /^(\w+\:\/\/[^\/]+\/?)?#{path}$/)
      end
      @exclude_paths
    end

    # Return a boolean indicating whether or not to exclude a path from the
    # AJAX redirect.
    def exclude_path?(path)
      !!((@exclude_paths || []).find do |excluded|
        !!excluded.match(path)
      end)
    end
  end
end