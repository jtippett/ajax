require 'rack-ajax/parser'

module Rack
  class Ajax
    attr_accessor :user, :request, :params

    def initialize(app)
      @app = app
      @decision_tree = block_given? ? Proc.new : nil
    end

    def call(env)
      return @app.call(env) unless AjaxSite.enabled?

      @parser = Parser.new(env)
      rack_response = @parser.instance_eval(@decision_tree)

      # Don't invoke the app if applying the rule returns a rack response
      return rack_response unless rack_response === true

      @app.call(env)
    ensure
      # Release the connections back to the pool.
      # @see http://blog.codefront.net/2009/06/15/activerecord-rails-metal-too-many-connections/
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
