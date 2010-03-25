require 'ajax/helpers'

module Ajax
  extend Helpers

  # Return a boolean indicating whether the plugin is currently enabled
  def self.is_enabled?
    @enabled ||= true
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

  # Given a path, return a hash containing a tag(s) to set on the link.
  #
  # WillPaginate uses the <tt>rel</tt> tag on the page links, so I prefer
  # 'data-ajax-link'.
  def self.link_to_tag(address)
    { 'data-ajax-link' => address }
  end

  # If you would prefer not to include the Ajax module in ActionController::Base
  # you can include it in only those controllers you want with:
  #
  #   include Ajax
  #
  # Don't forget to disable <tt>init.rb</tt> in this case.
  def self.included(klass)
    klass.send(:include, Ajax::ActionController)
  end

  # Installs Ajax for Rails.
  #
  # This method is called by <tt>init.rb</tt>, which is run by Rails on startup.
  #
  # To prevent installing Ajax
  def self.install
    if defined?(Rails)
      # Customize rendering.  Include custom headers and don't render the layout for AJAX.
      ::ActionController::Base.send(:include, Ajax::ActionController)

      # Insert the Rack::Ajax middleware to rewrite and handle requests
      ::ActionController::Dispatcher.middleware.insert_before(Rack::Lock, Rack::Ajax)

      # Add custom attributes to outgoing links
      ::ActionView::Base.send(:include, Ajax::ActionView)
    end
  end
end