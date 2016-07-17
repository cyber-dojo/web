#!/bin/bash ../test_wrapper.sh

require_relative './app_lib_test_base'

class StubTest < AppLibTestBase

  def setup
    super
    set_runner_class 'StubRunner'
  end

  def teardown
    shell.teardown if shell.class.name == 'MockHostShell'
    super
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '89433F',
  'pulled? returns true for pre-canned image names' do
    assert runner.pulled?("#{cdf}/csharp_nunit")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '099979',
  'pulled? returns false for other image_names' do
    refute runner.pulled?("#{cdf}/csharp_moq")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FCBC01',
  'pull issues shell command [sudo docker pull image_name]' do
    setup_mock_shell
    image_name = "#{cdf}/csharp_moq"
    command = [sudo, 'docker', 'pull', image_name].join(space).strip
    shell.mock_exec([command], any_output, success)
    runner.pull(image_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AC45F1',
  'stub_run_colour for anything other than red/amber/green raises' do
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    assert_raises { runner.stub_run_colour(lion, :yellow) }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '84A5A6',
  'stub_run_colour(red/amber/green) stubs red/amber/green output for following run()' do
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    [:red,:amber,:green].each do |colour|
      runner.stub_run_colour(lion, colour)
      output = runner.run(lion, nil, nil, nil)
      assert_equal 'String', output.class.name
      assert output.length > 0
      assert_equal colour.to_s, lion.kata.red_amber_green(output)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A986E6',
  'run() with no preceeding stub() gives random red/amber/green output sample' do
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    output = runner.run(lion, nil, nil, nil)
    assert_equal 'String', output.class.name
    assert output.length > 0
    colour = lion.kata.red_amber_green(output)
    assert ['red','amber','green'].include?(colour)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '81BA2C',
  'stub_run_output() stubs output for following run()' do
    expected = 'this is what you get'
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    runner.stub_run_output(lion, expected)
    actual = runner.run(lion, nil, nil, nil)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def setup_mock_shell
    ENV['CYBER_DOJO_TEST_ID'] = test_id
    set_shell_class('MockHostShell')
  end

  def sudo; dojo.env('runner_sudo'); end
  def space; ' '; end
  def any_output; 'sdsd'; end
  def success; 0; end
  def cdf; 'cyberdojofoundation'; end

end
