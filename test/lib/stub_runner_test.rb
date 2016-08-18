#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'

class StubRunnerTest < LibTestBase

  def setup
    super
    set_shell_class 'MockProxyHostShell'
    set_runner_class 'StubRunner'
  end

  def teardown
    shell.teardown
    super
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6DFD81',
  'parent is ctor parameter' do
    assert_equal "StubRunner", runner.class.name
    assert_equal dojo, runner.parent
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E866',
  'pulled? is true only for 4 specific images' do
    assert runner.pulled? "#{cdf}/nasm_assert"
    assert runner.pulled? "#{cdf}/gcc_assert"
    assert runner.pulled? "#{cdf}/csharp_nunit"
    assert runner.pulled? "#{cdf}/gpp_cpputest"
    refute runner.pulled? "#{cdf}/csharp_moq"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0B42BD',
  'pull issues docker-pull command to shell' do
    shell.mock_exec(["docker pull #{cdf}/csharp_moq"], output='', success)
    runner.pull "#{cdf}/csharp_moq"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '84B2C0',
  'stub_run_output stubs output for subsequent run' do
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    runner.stub_run_output(lion, output='syntax error line 1')
    assert_equal output, runner.run(lion, _delta=nil, _files=nil, _image_name=nil)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '180F3F',
  'stub_run_colour stubs given colour for subsequent run' do
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    [:red, :amber, :green].each do |colour|
      runner.stub_run_colour(lion, colour)
      output = runner.run(lion, _delta=nil, _files=nil, _image_name=nil)
      assert_equal colour.to_s, kata.red_amber_green(output)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF797E',
  'run without preceeding stub returns red/amber/green at random' do
    counts = { 'red' => 0, 'amber' => 0, 'green' => 0 }
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    (1..30).each do
      output = runner.run(lion, _delta=nil, _files=nil, _image_name=nil)
      colour = kata.red_amber_green(output)
      assert %w(red amber green).include? colour
      counts[colour] += 1
    end
    %w(red amber green).each do |colour|
      assert counts[colour] > 0, "counts[#{colour}] > 0 (#{colour})"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4B29D5',
  'stub_run_colour with bad colour raises' do
    assert_raises { runner.stub_run_colour(lion=nil, :yellow) }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '195067',
  'max_seconds is 10' do
    assert_equal 10, runner.max_seconds
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def cdf; 'cyberdojofoundation'; end
  def success; 0; end

end
