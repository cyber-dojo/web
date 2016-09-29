#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class ExceptionControllerTests < AppControllerTestBase

=begin

  def setup
    @consider = Rails.application.config.consider_all_requests_local
    @show = Rails.application.config.action_dispatch.show_exceptions
    Rails.application.config.consider_all_requests_local = false
    Rails.application.config.action_dispatch.show_exceptions = true
  end

  def teardown
    Rails.application.config.consider_all_requests_local = @consider
    Rails.application.config.action_dispatch.show_exceptions = @show
  end

  test 'bad path' do
    get 'dojo/sdsdsd'
    assert_template 'error/sorry'
  end

  test 'bad id' do
    get 'kata/edit/234523424234'
    assert_template 'error/sorry'
  end

=end

end
