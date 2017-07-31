require_relative 'app_lib_test_base'

class RunnerServiceTest < AppLibTestBase

  # These will fail if there is no network connectivity.

  def setup
    super
    set_runner_class('RunnerService')
    @katas = Katas.new(self)
  end

  attr_reader :katas

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
    assert_spied_stateful(0, 'image_pulled?', {
      :image_name => kata.image_name,
      :kata_id    => kata.id
    })
  end

  test '2BDF808C85',
  'image_pulled? request forwards to stateless runner ' +
  'for kata whose runner_choice is stateless' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateless
    @http.clear
    runner.image_pulled? kata.image_name, kata.id
    assert_spied_stateless(0, 'image_pulled?', {
      :image_name => kata.image_name,
      :kata_id    => kata.id
    })
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
    assert_spied_stateful(0, 'image_pull', {
      :image_name => kata.image_name,
      :kata_id    => kata.id
    })
  end

  test '2BDF808205',
  'image_pull request forwards to stateless runner ' +
  'for kata whose runner_choice is stateless' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateless
    @http.clear
    runner.image_pull kata.image_name, kata.id
    assert_spied_stateless(0, 'image_pull', {
      :image_name => kata.image_name,
      :kata_id    => kata.id
    })
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_new
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808351',
  'kata_new request forwards to stateful runner ' +
  'for kata whose runner_choice is stateful' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateful
    assert_spied_stateful(0, 'kata_new', {
      :image_name => kata.image_name,
      :kata_id    => kata.id
    })
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
    assert_spied_stateful(0, 'kata_old', {
      :image_name => kata.image_name,
      :kata_id    => kata.id
    })
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
  # avatar_new
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808C2B',
  'avatar_new request forwards to stateful runner ' +
  'for kata whose runner_choice is stateful' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateful
    @http.clear
    runner.avatar_new(kata.image_name, kata.id, 'salmon', {})
    assert_spied_stateful(0, 'avatar_new', {
      :image_name     => kata.image_name,
      :kata_id        => kata.id,
      :avatar_name    => 'salmon',
      :starting_files => {}
    })
  end

  test '2BDF808C2C',
  'avatar_new request does not forward to stateless runner ' +
  'for kata whose runner_choice is stateless' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateless
    @http.clear
    runner.avatar_new(kata.image_name, kata.id, 'salmon', {})
    assert_nil @http.spied[0]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # avatar_old
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808174',
  'avatar_old request forwards to stateful runner ' +
  'for kata whose runner_choice is stateful' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateful
    @http.clear
    runner.avatar_old(kata.image_name, kata.id, 'salmon')
    assert_spied_stateful(0, 'avatar_old', {
      :image_name     => kata.image_name,
      :kata_id        => kata.id,
      :avatar_name    => 'salmon'
    })
  end

  test '2BDF808175',
  'avatar_old request does not forward to stateless runner ' +
  'for kata whose runner_choice is stateless' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateless
    @http.clear
    runner.avatar_old(kata.image_name, kata.id, 'salmon')
    assert_nil @http.spied[0]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # run
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF80874C',
  'stateful run() delegates to stateful runner',
  'args include deleted_filenames and changed_files' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateful
    args = []
    args << kata.image_name
    args << kata.id
    args << (avatar_name = lion)
    args << (max_seconds = 10)
    args << (delta = { :deleted => [], :new => [], :changed => {} })
    args << (files = {})
    @http.clear
    runner.run(*args)
    assert_spied_stateful(0, 'run', {
      :image_name        => kata.image_name,
      :kata_id           => kata.id,
      :avatar_name       => avatar_name,
      :max_seconds       => max_seconds,
      :deleted_filenames => [],
      :changed_files     => {}
    })
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808601',
  'stateless run() delegates to stateless runner',
  'args do not include deleted_filenames or changed_files',
  'but do include visible_files' do
    @http = HttpSpy.new(nil)
    kata = make_kata_stateless
    args = []
    args << kata.image_name
    args << kata.id
    args << (avatar_name = lion)
    args << (max_seconds = 10)
    args << (delta = { :deleted => [], :new => [], :changed => {} })
    args << (files = {})
    @http.clear
    runner.run(*args)
    assert_spied_stateless(0, 'run', {
      :image_name        => kata.image_name,
      :kata_id           => kata.id,
      :avatar_name       => avatar_name,
      :max_seconds       => max_seconds,
      :visible_files     => {}
    })
  end

end
