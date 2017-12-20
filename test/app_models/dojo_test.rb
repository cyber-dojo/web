require_relative 'app_models_test_base'

class ExternalDouble
  def initialize(_dojo, _path = nil)
  end
end

class DojoTest < AppModelsTestBase

  test 'A70931',
  'CYBER_DOJO_HOME env-var is set to /app' do
    refute_nil ENV['CYBER_DOJO_HOME']
    assert_equal '/app', ENV['CYBER_DOJO_HOME']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # external classes and roots have no defaults
  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A70E2A',
  'using an unset external class raises StandardError' do
    error = StandardError

    unset_runner_class && assert_raises(error) { runner.class }
    unset_storer_class && assert_raises(error) { storer.class }

    unset_shell_class  && assert_raises(error) {  shell.class }
    unset_disk_class   && assert_raises(error) {   disk.class }
    unset_log_class    && assert_raises(error) {    log.class }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # external classes can be set via environment variables
  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A70880',
  'setting an external class to the name of an existing class succeeds' do
    exists = 'ExternalDouble'

    set_runner_class(exists) && assert_equal(exists, runner.class.name)
    set_storer_class(exists) && assert_equal(exists, storer.class.name)

    set_shell_class( exists) && assert_equal(exists,  shell.class.name)
    set_disk_class(  exists) && assert_equal(exists,   disk.class.name)
    set_log_class(   exists) && assert_equal(exists,    log.class.name)
  end

  test 'A707E4',
  'setting an external class to the name of a non-existant class raises StandardError' do
    error = StandardError

    set_runner_class(does_not_exist) && assert_raises(error) { runner.class }
    set_storer_class(does_not_exist) && assert_raises(error) { storer.class }

    set_shell_class( does_not_exist) && assert_raises(error) {  shell.class }
    set_disk_class(  does_not_exist) && assert_raises(error) {   disk.class }
    set_log_class(   does_not_exist) && assert_raises(error) {    log.class }
  end

  private

  def does_not_exist
    'DoesNotExist'
  end

end
