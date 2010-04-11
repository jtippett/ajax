module Ajax
  module Spec
    module Extension

      def integrate_ajax
        Ajax.enabled = true
      end

      def disable_ajax
        Ajax.enabled = false
      end
      
      def mock_ajax
        integrate_ajax
        Ajax.mocked = true
      end
    end
  end
end

module ActiveSupport
  class TestCase
    include Ajax::Spec::Extension

    before(:all) do
      ::Ajax.enabled = false
    end if method_defined?(:before)
  end
end