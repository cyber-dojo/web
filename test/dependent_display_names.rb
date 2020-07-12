# frozen_string_literal: true
require_relative 'test_domain_helpers'

def run
  [
    TestDomainHelpers::DEFAULT_DISPLAY_NAME,
  ].each do |display_name|
    puts display_name
  end
end

# - - - - - - - - - - - - - - - - - - - - -

run if __FILE__ == $PROGRAM_NAME
