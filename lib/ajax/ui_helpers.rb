# Under development.  Defines hierarchy of containers on the page for reporting of
# parent container state in Ajax requests.
#
# Should be a nested hash.  keys are CSS selectors.  The hash should be written into
# the page by the framework or app layout.
module Ajax
  module UiHelpers
    def self.extended(klass)
      klass.class_eval do
        attr_reader :containers
      end
    end

    # Return a struct
    def containers(containers)
      @containers_js = containers.to_s

    end
  end
end