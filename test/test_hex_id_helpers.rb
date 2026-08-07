
$args = ARGV.sort.uniq # eg 2DD6F3 eg 2dd
$seen_ids = []

module TestHexIdHelpers # mix-in

  def hex_setup
  end

  def hex_teardown
  end

  # - - - - - - - - - - - - - - - -

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def test(id, *words, &block)
      name = words.join(' ')
      # check test-id is well-formed
      diagnostic = "'#{id}',#{name}"
      raise  "no test-ID: #{diagnostic}" if id == ''
      raise "bad test-ID: #{diagnostic}" unless is_base58?(id)
      # if no hex-id supplied, or test method matches any supplied hex-id
      # then define a mini_test method using the hex-id
      no_args = $args === []
      any_arg_is_part_of_id = $args.any?{ |arg| id.include?(arg) }
      if no_args || any_arg_is_part_of_id
        raise "duplicate test-ID: #{diagnostic}" if $seen_ids.include?(id)
        $seen_ids << id
        block_with_test_id = lambda {
          hex_setup
          self.instance_eval(&block)
          hex_teardown
        }
        define_method("test_'#{id}',\n #{name}\n".to_sym, &block_with_test_id)
      end
    end

    def is_base58?(id)
      alphabet = %w(
        0123456789
        abcdefgh jklmn pqrstuvwxyz
        ABCDEFGH JKLMN PQRSTUVWXYZ
      ).join
      id.chars.all?{ |ch| alphabet.include?(ch) }
    end

  end
end
