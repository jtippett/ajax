require 'ajax/helpers'

module Ajax
  extend Helpers

  # Return a boolean indicating whether the plugin is currently enabled
  def self.enabled?
    @enabled ||= true
  end

  # Set to false to prevent disable this plugin completely
  def self.enabled=(value)
    @enabled = (value && true)
  end

  # Return a boolean indicating whether the plugin is being mock tested
  def self.mocked?
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
    @mocked = (value && true)
  end
end