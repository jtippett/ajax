module Ajax
  module Spec
    module Extension
      def self.included(base)
        base.class_eval do
          extend  ClassMethods
        end
      end
    end

    module ClassMethods
      def integrate_ajax
        Ajax.mocked = false
      end

      def mock_ajax
        Ajax.mocked = true
      end
    end
  end
end

#
# In general we don't want the Ajax plugin to be enabled when testing our
# Rails application.  So we need to disable the plugin for most requests.
#
# To test the plugin we need it enabled.  If we are testing the Rack components
# we need to inspect the URL rewrites and redirects and make sure they are
# being applied correctly.  To do this we can
#
module ActiveSupport
  class TestCase
    include Ajax::Spec::Extension

    before(:all) do
      self.class.mock_ajax
    end
  end
end