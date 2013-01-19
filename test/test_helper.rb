# Load the normal Rails helper
require File.dirname(__FILE__) + '/../../../test/test_helper'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
end

require 'factory_girl_rails'
require File.dirname(__FILE__) + '/factories.rb'
FactoryGirl.find_definitions
