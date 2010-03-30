module Ajax
  module Routes
    # In your <tt>config/routes.rb</tt> file call:
    #   Ajax::Routes.draw(map)
    # Passing in the routing <tt>map</tt> object.
    #
    # Adds an <tt>ajax_framework_path</tt> pointing to <tt>/ajax/framework</tt>
    def self.draw(map)
      map.ajax_framework "/ajax/framework", :controller => 'ajax', :action => 'framework'
    end
  end
end