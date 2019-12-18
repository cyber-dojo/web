
module TestHexIdHelpers # mix-in

  def hex_test_kata_id
    ENV['CYBER_DOJO_TEST_ID']
  end

  def hex_test_name
    ENV['CYBER_DOJO_TEST_NAME']
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
    @@args = ARGV[1..-1].sort.uniq # eg 2DD6F3 eg 2dd
    @@seen_ids = []
    @@timings = {}

    def test(id, *words, &block)
      src = block.source_location
      src_file = File.basename(src[0])
      src_line = src[1].to_s
      id = hex_prefix + id
      name = words.join(' ')
      # check test-id is well-formed
      diagnostic = "'#{id}',#{name}"
      raise  "no test-ID: #{diagnostic}" if id == ''
      raise "bad test-ID: #{diagnostic}" unless is_base58?(id)
      # if no hex-id supplied, or test method matches any supplied hex-id
      # then define a mini_test method using the hex-id
      no_args = @@args == []
      any_arg_is_part_of_id = @@args.any?{ |arg| id.include?(arg) }
      if no_args || any_arg_is_part_of_id
        raise "duplicate test-ID: #{diagnostic}" if @@seen_ids.include?(id)
        @@seen_ids << id
        block_with_test_id = lambda {
          ENV['CYBER_DOJO_TEST_ID'] = id
          ENV['CYBER_DOJO_TEST_NAME'] = name
          hex_setup
          t1 = Time.now
          self.instance_eval(&block)
          t2 = Time.now
          @@timings[id+':'+src_file+':'+src_line+':'+name] = (t2 - t1)
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

    ObjectSpace.define_finalizer(self, proc {
      slow = @@timings.select{ |_name,secs| secs > 0.000 }
      sorted = slow.sort_by{ |name,secs| -secs }.to_h
      size = sorted.size < 5 ? sorted.size : 5
      puts
      puts "Slowest #{size} tests are..." if size != 0
      sorted.each_with_index { |(name,secs),index|
        puts "%3.4f - %-72s" % [secs,name]
        break if index == size
      }
    })

    ObjectSpace.define_finalizer(self, proc {
      # complain about any unfound test-id args
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
