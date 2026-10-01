require_relative 'apps_test_base'
require_relative 'spooler_recording_order_stub'

class RunTestsWriteAfterResponseTest < AppsTestBase

  # The order the two events actually happened in, shared by the recording
  # middleware below and the spooler double.
  def order
    @order ||= []
  end

  # Wraps the mounted app so the test can mark the moment the response was
  # returned. It sits OUTSIDE every middleware the app mounts, so its mark
  # lands after the response is built and before the server closes the body.
  class ResponseReturnedRecorder
    def initialize(app, order)
      @app = app
      @order = order
    end
    def call(env)
      result = @app.call(env)
      @order << :response_returned
      result
    end
  end

  def app
    app_instance = ResponseReturnedRecorder.new(Web.mounted(externals), order)
    Rack::Builder.new do
      use Rack::Session::Cookie,
        key: '_cyber_dojo_session',
        secret: 'test_secret_key_that_is_long_enough_to_meet_racks_minimum_requirement!'
      run app_instance
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Q6nR4t',
  'the light reaches the browser before the spooler write, so the browser does not wait on it' do
    recording = order
    externals.instance_exec(recording) { |it| @spooler = SpoolerRecordingOrderStub.new(self, it) }
    in_kata do
      # Seed the csrf cookie, which post() otherwise fetches mid-test, so the
      # only request the recorder marks is the [test] run itself.
      get '/alive'
      order.clear
      post_run_tests
      assert_equal [:response_returned, :spooler_write], order, :write_happens_after_the_response
    end
  end

end
