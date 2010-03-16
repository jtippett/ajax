require 'rack-ajax/parser'

module Rack
  class Ajax
    attr_accessor :user, :request, :params

    def initialize(app)
      @app = app
      @decision_tree = block_given? ? Proc.new : nil
    end

    def call(env)
      return @app.call(env) unless ::Ajax.is_enabled?

      @parser = Parser.new(env)
      rack_response = @parser.instance_eval(&@decision_tree)

      # If we are testing our Rack::Ajax middleware, return
      # a Rack response now.
      #
      # In order to test rewrites, return a 200 response with
      # the environment.
      if ::Ajax.is_mocked?
        rack_response.nil? ? [200, {}, env] : rack_response
      elsif !rack_response.nil?
        rack_response
      else
        # Fallthrough to the app.
        @app.call(env)
      end
    ensure
      # Release the connections back to the pool.
      # @see http://blog.codefront.net/2009/06/15/activerecord-rails-metal-too-many-connections/
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
