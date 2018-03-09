require_relative 'app_models_test_base'
require_relative '../app_lib/delta_maker'

class AvatarTest < AppModelsTestBase

  def self.hex_prefix
    'FB7A42'
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'E81', %w(
  an avatar's kata is the kata it was created with ) do
    in_kata {
      as(:wolf) {
        assert_equal kata.id, wolf.kata.id
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'D2B', %w(
  an avatar's' initial visible_files are:
  1. the language+testFramework visible_files,
  2. the exercise's instructions file,
  3. the output file ) do
    expected = %w( cyber-dojo.sh hiker.rb test_hiker.rb instructions output )
    in_kata(:stateless) {
      as(:wolf) {
        assert_equal expected.sort, wolf.visible_filenames.sort
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '92F', %w(
  an avatar with zero traffic-lights is not active?
  but with one-or-more traffic-lights is it active ) do
    in_kata {
      as(:wolf) {
        assert_equal [], wolf.lights
        refute wolf.active?
        DeltaMaker.new(wolf).run_test
        assert_equal 1, wolf.lights.length
        assert wolf.active?
        DeltaMaker.new(wolf).run_test
        assert_equal 2, wolf.lights.length
        assert wolf.active?
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '0CA', %w(
  test() output is added to visible_files ) do
    in_kata {
      as(:wolf) {
        assert wolf.visible_files.keys.include?('output')
        assert_equal '', wolf.visible_files['output']
        _, visible_files, output = DeltaMaker.new(wolf).run_test
        assert wolf.visible_files.keys.include?('output')
        refute_equal '', wolf.visible_files['output']
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '925', %w(
  delta[:changed] files are changed ) do
    in_kata {
      as(:wolf) {
        filename = 'cyber-dojo.sh'
        maker = DeltaMaker.new(wolf)
        maker.change_file(filename, new_sh = 'pwd')
        _, visible_files,_ = maker.run_test
        assert_equal new_sh, visible_files[filename], 'returned to browser'
        assert_equal new_sh, wolf.visible_files[filename], 'saved to storer'
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '749', %w(
  delta[:unchanged] files are unchanged ) do
    in_kata {
      as(:wolf) {
        filename = 'cyber-dojo.sh'
        sh = wolf.visible_files[filename]
        maker = DeltaMaker.new(wolf)
        _, visible_files,_ = maker.run_test
        assert_equal sh, visible_files[filename], 'returned to browser'
        assert_equal sh, wolf.visible_files[filename], 'saved to storer'
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '683', %w(
  delta[:new] files are created ) do
    in_kata {
      as(:wolf) {
        maker = DeltaMaker.new(wolf)
        filename = 'new_file.rb'
        content = 'once upon a time'
        maker.new_file(filename, content)
        _, visible_files, _ = maker.run_test
        assert_equal content, visible_files[filename], 'returned to browser'
        assert_equal content, wolf.visible_files[filename], 'saved to storer'
      }
    }
  end

end

