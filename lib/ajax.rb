require 'ajax/helpers'

module Ajax
  extend Helpers

  def self.enabled?
    @enabled ||= true
  end

  def self.enabled=(value)
    @enabled = (value && true)
  end
end