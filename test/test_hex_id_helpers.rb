
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
    @@timings = {}

    def test(id, *words, &block)
      src = block.source_location
      src_file = src[0]
      src_line = src[1].to_s
      id = hex_prefix + id
      # test id is used as kata.id in StorerFake
      id += '0' * (10 - id.size)
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
          t1 = Time.now
          self.instance_eval &block
          t2 = Time.now
          @@timings[id+':'+src_file+':'+src_line+':'+name] = (t2 - t1)
          hex_teardown
        }
        define_method("test_'#{id}',\n #{name}\n".to_sym, &block_with_test_id)
      end
    end

    ObjectSpace.define_finalizer(self, proc {
      sorted = Hash[@@timings.sort_by{ |name,secs| -secs}]
      puts 'Slowest 5 tests are...' if sorted.size != 0
      sorted.each_with_index { |(name,secs),index|
        puts "%3.2f - %-72s" % [secs,name]
        break if index == 5
      }
    })

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
