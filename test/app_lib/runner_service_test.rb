require_relative 'app_lib_test_base'

class RunnerServiceTest < AppLibTestBase

  # These will fail if there is no network connectivity.

  def setup
    super
    set_runner_class('RunnerService')
  end

  def make_kata_stateful
    kata = make_kata({ 'language' => 'C (gcc)-assert' })
    assert_equal 'stateful', kata.runner_choice
    kata
  end

  def make_kata_stateless
    kata = make_kata({ 'language' => 'Python-unittest' })
    assert_equal 'stateless', kata.runner_choice
    kata
  end

  def assert_spied_stateful(index, method_name, args)
    assert_equal [
      stateful_runner_name = 'runner',
      stateful_runner_port = 4557,
      method_name,
      args
    ], @http.spied[index]
  end

  def assert_spied_stateless(index, method_name, args)
    assert_equal [
      stateless_runner_name = 'runner_stateless',
      stateless_runner_port = 4597,
      method_name,
      args
    ], @http.spied[index]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # image_pulled?
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808C84',
  'image_pulled? request forwards to stateful runner ' +
  'for kata whose runner_choice is stateful' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateful
    @http.clear
    runner.image_pulled? kata.image_name, kata.id
    assert_spied_stateful(0, 'image_pulled?', {:image_name=>kata.image_name, :kata_id => kata.id })
  end

  test '2BDF808C85',
  'image_pulled? request forwards to stateless runner ' +
  'for kata whose runner_choice is stateless' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateless
    @http.clear
    runner.image_pulled? kata.image_name, kata.id
    assert_spied_stateless(0, 'image_pulled?', {:image_name=>kata.image_name, :kata_id => kata.id })
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # image_pull
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808204',
  'image_pull request forwards to stateful runner ' +
  'for kata whose runner_choice is stateful' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateful
    @http.clear
    runner.image_pull kata.image_name, kata.id
    assert_spied_stateful(0, 'image_pull', {:image_name=>kata.image_name, :kata_id => kata.id })
  end

  test '2BDF808205',
  'image_pull request forwards to stateless runner ' +
  'for kata whose runner_choice is stateless' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateless
    @http.clear
    runner.image_pull kata.image_name, kata.id
    assert_spied_stateless(0, 'image_pull', {:image_name=>kata.image_name, :kata_id => kata.id })
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_new
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808351',
  'kata_new request forwards to stateful runner ' +
  'for kata whose runner_choice is stateful' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateful
    assert_spied_stateful(0, 'kata_new', {:image_name=>kata.image_name, :kata_id => kata.id })
  end

  test '2BDF808352',
  'kata_new request does not forward to stateless runner ' +
  'for kata whose runner_choice is stateless' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateless
    assert_nil @http.spied[0]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_old
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808767',
  'kata_old request forwards to stateful runner ' +
  'for kata whose runner_choice is stateful' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateful
    @http.clear
    runner.kata_old(kata.image_name, kata.id)
    assert_spied_stateful(0, 'kata_old', {:image_name=>kata.image_name, :kata_id => kata.id })
  end

  test '2BDF808768',
  'kata_old request does not forward to stateless runner ' +
  'for kata whose runner_choice is stateless' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateless
    @http.clear
    runner.kata_old(kata.image_name, kata.id)
    assert_nil @http.spied[0]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF8082E5',
  'runner defaults to running statefully' do
    assert runner.running_statefully?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_stateful_runner(kata_id, image_name)
    @http = HttpSpy.new(nil)
    args = []
    args << image_name
    args << kata_id
    args << (avatar_name = lion)
    args << (max_seconds = 10)
    args << (delta = { :deleted => [], :new => [],:changed => {} })
    args << (files = {})
    runner.run_statefully
    assert runner.running_statefully?
    runner.run(*args)
    assert @http.spied_hostname? 'runner'
    assert @http.spied_named_arg? :deleted_filenames
    assert @http.spied_named_arg? :changed_files
    refute @http.spied_named_arg? :visible_files
  end

  test '2BDF80874C',
  'stateful run() delegates to stateful runner',
  'args include deleted_filenames and changed_files' do
    assert_stateful_runner('2BDAD8074C', 'cyberdojofoundation/gcc_assert')
    assert_stateful_runner('2BDAD8074D', 'quay.io:8080/cyberdojofoundation/gcc_assert:latest')
    assert_stateful_runner('2BDAD8074E', 'localhost/cyberdojofoundation/gcc_assert:stateless')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808601',
  'stateless run() delegates to stateless runner',
  'args do not include deleted_filenames or changed_files',
  'but do include visible_files' do
    assert_stateless_runner('2BDAD80601', 'cyberdojofoundation/gcc_assert_stateless')
    assert_stateless_runner('2BDAD80602', 'quay.io:8080/cyberdojofoundation/gcc_assert_stateless')
    assert_stateless_runner('2BDAD80603', 'localhost/cyberdojofoundation/gcc_assert_stateless:1.2')
  end

  def assert_stateless_runner(kata_id, image_name)
    @http = HttpSpy.new(nil)
    args = []
    args << image_name
    args << kata_id
    args << (avatar_name = lion)
    args << (max_seconds = 10)
    args << (delta = { :deleted => [], :new => [],:changed => {} })
    args << (files = {})
    runner.run_statelessly
    refute runner.running_statefully?
    runner.run(*args)
    assert @http.spied_hostname? 'runner_stateless'
    refute @http.spied_named_arg? :deleted_filenames
    refute @http.spied_named_arg? :changed_files
    assert @http.spied_named_arg? :visible_files
  end

end
