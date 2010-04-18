require 'rack-ajax/parser'
require 'json'

module Rack
  class Ajax
    cattr_accessor :decision_tree, :default_decision_tree
    attr_accessor :user, :request, :params

    # If called with a block, executes that block as the "decision tree".
    # This is useful when testing.
    #
    # To integrate Rack::Ajax into your app you should store the decision
    # tree in a class-attribute <tt>decision_tree</tt>.  This
    # decision tree will be used unless a block is provided.
    def initialize(app)
      @app = app
      @decision_tree = block_given? ? Proc.new : (self.class.decision_tree || self.class.default_decision_tree)
    end

    def call(env)
      return @app.call(env) unless ::Ajax.is_enabled?

      # Parse the Ajax-Info header
      if env["HTTP_AJAX_INFO"].nil?
        env["Ajax-Info"] = {}
      elsif env["HTTP_AJAX_INFO"].is_a?(String)
        env["Ajax-Info"] = (JSON.parse(env['HTTP_AJAX_INFO']) rescue {})
      end

      @parser = Parser.new(env)
      rack_response = @parser.instance_eval(&@decision_tree)

      # Clear the value of session[:redirected_to]
      unless env['rack.session'].nil?
        env['rack.session']['redirected_to'] = env['rack.session'][:redirected_to] = nil
      end

      # If we are testing our Rack::Ajax middleware, return
      # a Rack response now rather than falling through
      # to the application.
      #
      # To test rewrites, return a 200 response with
      # the modified request environment encoded as Yaml.
      #
      # The Ajax::Spec::Helpers module includes a helper
      # method to test the result of a rewrite.
      if ::Ajax.is_mocked?
        rack_response.nil? ? Rack::Ajax::Parser.rack_response(env.to_yaml) : rack_response
      elsif !rack_response.nil?
        rack_response
      else
        # Fallthrough to the app.
        @app.call(env)
      end
    end
    
    def default_decision_tree
    end
  end
end