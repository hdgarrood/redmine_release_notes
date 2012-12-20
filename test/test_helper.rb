# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

# Ensure that we are using the temporary fixture path
class ActiveSupport::TestCase
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
end
