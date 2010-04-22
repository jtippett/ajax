require 'ajax/helpers'

module Ajax
  include Ajax::Helpers
  
  class << self
    attr_writer :logger
  end

  # Return a logger instance.
  #
  # Use the Rails logger by default, assign nil to turn off logging.
  # Dummy a logger if logging is turned off of if Ajax isn't enabled.
  def self.logger
    if !@logger.nil? && is_enabled?
      @logger
    else
      @logger = Class.new { def method_missing(*args); end; }.new
    end
  end

  # Return a boolean indicating whether the plugin is enabled.
  #
  # Enabled by default.
  def self.is_enabled?
    @enabled.nil? ? true : !!@enabled
  end
  class << self
    alias_method :enabled?, :is_enabled?
  end
  
  # Set to false to disable this plugin completely.
  #
  # ActionController and ActionView helpers are still mixed in but
  # they are effectively disabled, which means your code will still
  # run.
  def self.enabled=(value)
    @enabled = !!value
  end

  # Return a boolean indicating whether to enable lazy loading assets.
  # There are currently issues with some browsers when using this feature.
  #
  # Disabled by default.
  def self.lazy_load_assets?
    @lazy_load_assets.nil? ? false : !!@lazy_load_assets
  end

  # Set to false to disable lazy loading assets.  Callbacks will
  # be executed immediately.
  #
  # ActionController and ActionView helpers are still mixed in but
  # they are effectively disabled, which means your code will still
  # run.
  def self.lazy_load_assets=(value)
    @lazy_load_assets = !!value
  end
  
  # Return a boolean indicating whether the plugin is being mock tested.
  #
  # Mocking forces the environment to be returned after Ajax processing
  # so that we can introspect it and verify that the correct actions were
  # taken.
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
  # Customize rendering.  Include custom headers and don't render the layout for AJAX.
  # Insert the Rack::Ajax middleware to rewrite and handle requests.
  # Add custom attributes to outgoing links.
  def self.install_for_rails
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