require_relative 'app_models_test_base'
require_relative '../app_lib/delta_maker'

class TagsTest < AppModelsTestBase

  def self.hex_prefix
    'A30753'
  end

  #- - - - - - - - - - - - - - - - - - -

  test 'AF3',
  'tag zero exists after avatar is started',
  'and before first [test] is run',
  'and contains all visible files' do
    in_kata {
      as(:wolf) {
        tags = wolf.tags
        assert_equal 1, tags.length
        refute tags[0].light?
        n = 0
        tags.each { n += 1 }
        assert_equal 1, n

        visible_files = tags[0].visible_files
        filenames = %w(
          hiker.rb
          test_hiker.rb
          instructions
          cyber-dojo.sh
          output
        )
        filenames.each { |filename|
          assert visible_files.keys.include?(filename), filename
        }
        assert_equal '', tags[0].output
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - -

  test 'D39',
  'each [test]-event creates a new tag which is a light' do
    in_kata {
      as(:wolf) {
        assert_equal 1, wolf.tags.length
        maker = DeltaMaker.new(wolf)
        maker.run_test
        maker.run_test
        maker.run_test
        assert_equal 4, wolf.tags.length
        wolf.tags.each_with_index do |tag, i|
          assert_equal i, tag.number
          assert i == 0 || tag.light?
        end
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - -

  test 'A42',
  'tags[-n] duplicates Array[-n] behaviour' do
    in_kata {
      as(:wolf) {
        maker = DeltaMaker.new(wolf)
        maker.run_test
        maker.run_test
        maker.run_test
        tags = wolf.tags
        (1..tags.length).each do |i|
          assert_equal tags.length - i, tags[-i].number
        end
      }
    }
  end

end
