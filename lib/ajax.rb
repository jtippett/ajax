require 'ajax/url_helpers'
require 'ajax/rails_helpers'

module Ajax
  # Set to the Rails logger by default, assign nil to turn off logging
  class << self
    attr_writer :logger
  end

  extend UrlHelpers
  extend RailsHelpers

  # Dummy a logger if logging is turned off of if Ajax isn't enabled
  def self.logger
    if !@logger.nil? && is_enabled?
      @logger
    else
      @logger = Class.new { def method_missing(*args); end; }.new
    end
  end

  # Return a boolean indicating whether the plugin is currently enabled
  def self.is_enabled?
    !!@enabled
  end

  # Set to false to prevent disable this plugin completely
  def self.enabled=(value)
    @enabled = !!value
  end

  # Return a boolean indicating whether the plugin is being mock tested
  def self.is_mocked?
    @mocked ||= false
  end

  # Set to true to enable mocking testing the plugin.
  #
  # Integration tests will return the result of the URL rewriting in a
  # special response.  Redirects will be indicated using standard responses.
  #
  # Use this to test the handling of URLs in various states and with different
  # HTTP request methods.
  def self.mocked=(value)
    @mocked = !!value
  end

  # Installs Ajax for Rails.
  #
  # This method is called by <tt>init.rb</tt>, which is run by Rails on startup.
  #
  # To prevent installing Ajax
  def self.install
    if defined?(Rails)
      Ajax.logger = Rails.logger

      # Customize rendering.  Include custom headers and don't render the layout for AJAX.
      ::ActionController::Base.send(:include, Ajax::ActionController)

      # Insert the Rack::Ajax middleware to rewrite and handle requests
      ::ActionController::Dispatcher.middleware.insert_before(Rack::Head, Rack::Ajax)

      # Add custom attributes to outgoing links
      ::ActionView::Base.send(:include, Ajax::ActionView)
    end
  end
end