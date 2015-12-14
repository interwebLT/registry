require 'minitest/spec'
require 'json_expressions/minitest'

World(MiniTest::Assertions)
MiniTest::Spec.new(nil)

World(FactoryGirl::Syntax::Methods)

require 'webmock/cucumber'