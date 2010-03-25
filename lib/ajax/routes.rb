module Ajax
  module Routes
    # In your config/routes.rb file, call:
    #   Ajax::Routes.draw(map)
    # Passing in the routing "map" object.
    def self.draw(map)
      map.ajax_framework "/ajax/framework", :controller => 'ajax', :action => 'framework'
    end
  end
end