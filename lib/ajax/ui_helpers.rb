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