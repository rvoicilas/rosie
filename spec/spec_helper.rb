require 'minitest/autorun'
require 'rspec'

require_relative '../lib/rosie'

# Make rspec work with minitest's capture_io
RSpec.configure do |c|
  c.include MiniTest::Assertions
end

# Since the specs and the subject under test are ran in the
# same process space, when calling exit the specs will be killed.
# Use this function to not let that happen.
def run_with_rescue
  begin
    yield if block_given?
  rescue SystemExit
  end
end
