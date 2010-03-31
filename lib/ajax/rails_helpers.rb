module Ajax
  module RailsHelpers
    def set_header(object, key, value)
      headers = object.is_a?(::ActionController::Response) ? object.headers : object
      unless headers["Ajax-Info"].is_a?(Hash)
        headers["Ajax-Info"] = {}
      end
      headers["Ajax-Info"][key.to_s] = value
    end

    def get_header(object, key)
      headers = object.is_a?(::ActionController::Request) ? object.headers : object
      unless headers["Ajax-Info"].is_a?(Hash)
        headers["Ajax-Info"] = {}
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
    # The string and regex paths are modified to match full URLs by prepending
    # them with the appropriate regular expression.
    def exclude_paths(paths=nil)
      if !instance_variable_defined?(:@exclude_paths)
        @exclude_paths = []
      end
      (paths || []).each do |path|
        @exclude_paths << /^(\w+\:\/\/[^\/]+\/?)?#{path.to_s}$/
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