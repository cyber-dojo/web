require_relative 'app_models_test_base'

class ExternalDouble
  def initialize(_root)
  end
end

class ExternalsTest < AppModelsTestBase

  def self.hex_prefix
    'A1k'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '880',
  'setting an external class to the name of an existing class succeeds' do
    exists = 'ExternalDouble'
    set_differ_class(exists) && assert_equal(exists, differ.class.name)
    set_runner_class(exists) && assert_equal(exists, runner.class.name)
    set_custom_class(exists) && assert_equal(exists, custom.class.name)
    set_exercises_class(exists) && assert_equal(exists, exercises.class.name)
    set_languages_class(exists) && assert_equal(exists, languages.class.name)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '881',
  'setting an external class to the name of a non-existent class raises StandardError' do
    error = StandardError
    does_not_exist = 'DoesNotExist'
    set_differ_class(does_not_exist) && assert_raises(error) { differ.class }
    set_runner_class(does_not_exist) && assert_raises(error) { runner.class }
    set_custom_class(does_not_exist) && assert_raises(error) { custom.class }
    set_exercises_class(does_not_exist) && assert_raises(error) { exercises.class }
    set_languages_class(does_not_exist) && assert_raises(error) { languages.class }
  end

end
