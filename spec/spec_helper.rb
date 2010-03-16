$: << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'init')

require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'ajax/spec/extension'
require 'action_controller'

Spec::Runner.configure do |config|
  include Ajax::Spec::Extension
end