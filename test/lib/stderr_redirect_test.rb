#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'

class StderrRedirectTest < LibTestBase

  include StderrRedirect

  test '72F5ED',
  'stdout redirect at shell is 2>&1' do
    assert_equal '2>&1', stderr_2_stdout
  end

end
