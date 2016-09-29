#!/bin/bash ../test_wrapper.sh

require_relative './app_models_test_base'

class ExternalDouble
  def initialize(_dojo, _path = nil)
  end
end

class DojoTest < AppModelsTestBase

  def setup_id(_hex)
    # DON'T do super. Avoid defaults
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # external classes and roots have no defaults
  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FB7E2A',
  'using an unset external class raises StandardError' do
    unset_runner_class && assert_raises(StandardError) { runner.class }
    unset_storer_class && assert_raises(StandardError) { storer.class }
    unset_shell_class  && assert_raises(StandardError) {  shell.class }
    unset_disk_class   && assert_raises(StandardError) {   disk.class }
    unset_git_class    && assert_raises(StandardError) {    git.class }
    unset_log_class    && assert_raises(StandardError) {    log.class }
  end

  test 'FB76F9',
  'using an unset external root path raises StandardError' do
    unset_languages_root && assert_raises(StandardError) { languages.path }
    unset_exercises_root && assert_raises(StandardError) { exercises.path }
    unset_custom_root    && assert_raises(StandardError) {    custom.path }
    unset_katas_root     && assert_raises(StandardError) {     katas.path }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # external classes can be set via environment variables
  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FB7880',
  'setting an external class to the name of an existing class succeeds' do
    exists = 'ExternalDouble'
    set_runner_class(exists) && assert_equal(exists, runner.class.name)
    set_storer_class(exists) && assert_equal(exists, storer.class.name)
    set_shell_class( exists) && assert_equal(exists,  shell.class.name)
    set_disk_class(  exists) && assert_equal(exists,   disk.class.name)
    set_git_class(   exists) && assert_equal(exists,    git.class.name)
    set_log_class(   exists) && assert_equal(exists,    log.class.name)
  end

  test 'FB77E4',
  'setting an external class to the name of a non-existant class raises StandardError' do
    set_runner_class(does_not_exist) && assert_raises(StandardError) { runner.class }
    set_storer_class(does_not_exist) && assert_raises(StandardError) { storer.class }
    set_shell_class( does_not_exist) && assert_raises(StandardError) {  shell.class }
    set_disk_class(  does_not_exist) && assert_raises(StandardError) {   disk.class }
    set_git_class(   does_not_exist) && assert_raises(StandardError) {    git.class }
    set_log_class(   does_not_exist) && assert_raises(StandardError) {    log.class }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # external roots can be set via environment variables
  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FB7EA1',
  'setting an external root succeeds' do
    set_languages_root(path = tmp_root + '/languages') && assert_equal(path, languages.path)
    set_exercises_root(path = tmp_root + '/exercises') && assert_equal(path, exercises.path)
    set_custom_root(   path = tmp_root + '/custom'   ) && assert_equal(path,    custom.path)
    set_katas_root(    path = tmp_root + '/katas'    ) && assert_equal(path,    storer.path)
  end

  # - - - - - -

  test 'FB7D52',
  'setting an external root with a trailing slash chops off the trailing slash' do
    path = tmp_root + '/languages'
    set_languages_root(path + '/') && assert_equal(path, languages.path)

    path = tmp_root + '/exercises'
    set_exercises_root(path + '/') && assert_equal(path, exercises.path)

    path = tmp_root + '/custom'
    set_custom_root(path + '/') && assert_equal(path, custom.path)

    path = tmp_root + '/katas'
    set_katas_root(path + '/')     && assert_equal(path, storer.path)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test 'FB7F2D',
  'storer.path is set off /tmp by test setup because tests write to katas' do
    test_set_path = env_var.value('katas_root')
    assert test_set_path.start_with?('/tmp'), test_set_path
    assert storer.path.start_with?('/tmp'), storer.path
  end

  private

  def does_not_exist
    'DoesNotExist'
  end

end
