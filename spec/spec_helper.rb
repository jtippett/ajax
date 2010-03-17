require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'ajax/spec/extension'

# Rails dependencies
require 'action_controller'
require 'active_support/core_ext'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'init')

Spec::Runner.configure do |config|
  include Ajax::Spec::Extension
end