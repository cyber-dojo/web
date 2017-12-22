require_relative 'app_models_test_base'

class ExternalDouble
  def initialize(_root)
  end
end

class ExternalsTest < AppModelsTestBase

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # external classes and roots have no defaults
  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A70E2A',
  'using an unset external class raises StandardError' do
    error = StandardError
    unset_runner_class && assert_raises(error) { runner.class }
    unset_storer_class && assert_raises(error) { storer.class }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # external classes can be set via environment variables
  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A70880',
  'setting an external class to the name of an existing class succeeds' do
    exists = 'ExternalDouble'
    set_runner_class(exists) && assert_equal(exists, runner.class.name)
    set_storer_class(exists) && assert_equal(exists, storer.class.name)
  end

  test 'A707E4',
  'setting an external class to the name of a non-existant class raises StandardError' do
    error = StandardError
    set_runner_class(does_not_exist) && assert_raises(error) { runner.class }
    set_storer_class(does_not_exist) && assert_raises(error) { storer.class }
  end

  private

  def does_not_exist
    'DoesNotExist'
  end

end
