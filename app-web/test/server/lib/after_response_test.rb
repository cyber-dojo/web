require_relative 'lib_test_base'
require_source 'after_response'

class AfterResponseTest < LibTestBase

  # A downstream app standing in for a route: it stashes work in the env the way
  # a route does, and returns a body of its own.
  def app_stashing(work)
    lambda { |env|
      Web::AfterResponse.stash(env, work)
      [200, {}, ['the-body']]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F4rT8m',
  'stashed work runs when the body is closed, so the response reaches the browser first' do
    ran = []
    middleware = Web::AfterResponse.new(app_stashing(->{ ran << :work }))
    _status, _headers, body = middleware.call({})
    assert_equal [], ran, :not_run_when_the_response_is_returned
    body.each { |chunk| assert_equal 'the-body', chunk, :body_passes_through }
    assert_equal [], ran, :not_run_while_the_body_is_written
    body.close
    assert_equal [:work], ran, :run_once_the_body_is_written
  end

end
