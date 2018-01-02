
module TestHexIdHelpers # mix-in

  def hex_test_kata_id
    ENV['CYBER_DOJO_TEST_ID']
  end

  def hex_setup
  end

  def hex_teardown
  end

  # - - - - - - - - - - - - - - - -

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    # ARGV[0] == module name
    @@args = ARGV[1..-1].sort.uniq.map(&:upcase)  # eg 2DD6F3 eg 2dd
    @@seen_ids = []

    def test(id, *words, &block)
      id = hex_prefix + id
      name = words.join(' ')
      # check hex-id is well-formed
      diagnostic = "'#{id}',#{name}"
      hex_chars = '0123456789ABCDEF'
      is_hex_id = id.chars.all? { |ch| hex_chars.include? ch }
      raise  "no hex-ID: #{diagnostic}" if id == ''
      raise "bad hex-ID: #{diagnostic}" unless is_hex_id
      # if no hex-id supplied, or test method matches any supplied hex-id
      # then define a mini_test method using the hex-id
      no_args = @@args == []
      any_arg_is_part_of_id = @@args.any?{ |arg| id.include?(arg) }
      if no_args || any_arg_is_part_of_id
        raise "duplicate hex_ID: #{diagnostic}" if @@seen_ids.include?(id)
        @@seen_ids << id
        block_with_test_id = lambda {
          ENV['CYBER_DOJO_TEST_ID'] = id
          hex_setup
          self.instance_eval &block
          hex_teardown
        }
        define_method("test_'#{id}',\n #{name}\n".to_sym, &block_with_test_id)
      end
    end

    ObjectSpace.define_finalizer(self, proc {
      # complain about any unfound hex-id args
      unseen_arg = lambda { |arg|
        @@seen_ids.none? { |id|
          id.include?(arg)
        }
      }
      unseen_args = @@args.find_all { |arg|
        unseen_arg.call(arg)
      }
      unless unseen_args == []
        message = 'the following test id arguments were *not* found'
        lines = [ '', message, "#{unseen_args}", '' ]
        # can't raise in a finalizer
        lines.each { |line| STDERR.puts line }
      end
    })
  end

end
