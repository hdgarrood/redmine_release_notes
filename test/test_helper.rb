# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class ActiveSupport::TestCase
  # Ensure that we are using the plugin's fixture path
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
end
