require_relative 'app_lib_test_base'

class PullerMockTest < AppLibTestBase

  def setup
    super
    @puller = PullerMock.new(self)
  end

  def teardown
    puller.reset
  end

  attr_reader :puller

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '05B866',
  'pulled? mocked true' do
    puller.mock_pulled? image_name, true
    assert puller.pulled? image_name, kata_id
    puller.teardown
  end

  test '05B867',
  'pulled? mocked false' do
    puller.mock_pulled? image_name, false
    refute puller.pulled? image_name, kata_id
    puller.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '05B868',
  'pull mocked true' do
    puller.mock_pull image_name, true
    assert puller.pull image_name, kata_id
    puller.teardown
  end

  test '05B869',
  'pull mocked false' do
    puller.mock_pull image_name, false
    refute puller.pull image_name, kata_id
    puller.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '05B902',
  'mock set in one thread has to be visible in another thread',
  'because app_controller methods are routed into a new thread' do
    tid = Thread.new {
      puller.mock_pulled? image_name, true
    }
    tid.join
    assert puller.pulled? image_name, kata_id
    puller.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '05B444',
  'pulled? with no mocked pulled? raises' do
    assert_error('no mock for pulled?(') { puller.pulled? image_name, kata_id }
  end

  test '05B445',
  'pull with no mocked pull raises' do
    assert_error('no mock for pull(') { puller.pull image_name, kata_id }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '05B5FB',
  'pulled? with mock for different image_name raises' do
    puller.mock_pulled? 'X'+image_name, true
    assert_error("pulled?() expected:X#{image_name}, actual:#{image_name}") {
      puller.pulled? image_name, kata_id
    }
  end

  test '05B5FC',
  'pull with mock for different image_name raises' do
    puller.mock_pull 'X'+image_name, true
    assert_error("pull() expected:X#{image_name}, actual:#{image_name}") {
      puller.pull image_name, kata_id
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '05B575',
  'mock_pulled? result not true or false raises' do
    assert_error('mock_pulled?() 2nd arg must be true/false') {
      puller.mock_pulled? image_name, 'X'
    }
  end

  test '05B576',
  'mock_pull result not true or false raises' do
    assert_error('mock_pull() 2nd arg must be true/false') {
      puller.mock_pull image_name, 'X'
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '05B959',
  'teardown with unrequited mock_pulled? raises' do
    puller.mock_pull image_name, true
    assert_error('unrequited mock pull:') { puller.teardown }
  end

  test '05B960',
  'teardown with unrequired mock_pull raises' do
    puller.mock_pulled? image_name, true
    assert_error('unrequited mock pulled?:') { puller.teardown }
  end

  private

  def assert_error(message)
    error = assert_raises { yield }
    assert error.message.start_with?('MockPuller:' + message), message
  end

  def image_name
    'cyberdojofoundation/nasm_assert'
  end

  def kata_id
    'BE53FA3455'
  end

end
