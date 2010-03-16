module Ajax
  module Spec
    module Extension

      def integrate_ajax
        Ajax.enabled = true
      end

      def mock_ajax
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