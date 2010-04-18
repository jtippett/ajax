require 'ajax/helpers/request_helper'
require 'ajax/helpers/robot_helper'
require 'ajax/helpers/url_helper'

module Ajax #:nodoc:
  module Helpers #:nodoc:
    def self.included(klass)
      klass.class_eval do
        extend RequestHelper
        extend RobotHelper
        extend UrlHelper   
      end     
    end
  end
end