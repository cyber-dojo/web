# simplecov:disable
require 'English'
require 'minitest/autorun'
require 'rack/test'

class Id58TestBase < Minitest::Test
  def initialize(arg)
    @id58 = nil
    @name58 = nil
    super
  end

  @@args = (ARGV.sort.uniq - ['--']) # eg 2m4
  @@seen_ids = []
  @@timings = {}

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.qtest(hash, &test_block)
    id58 = hash.keys[0]
    lines = hash[id58].join(' ').split('|').join("\n|")
    test(id58, "#{lines}\n\n", &test_block)
  end

  def self.test(id58, *lines, &test_block)
    source = test_block.source_location
    source_file = File.basename(source[0])
    source_line = source[1].to_s
    id58 = checked_id58(id58.to_s, lines)
    return unless @@args === [] || @@args.any? { |arg| id58.include?(arg) }

    space = ' '
    name58 = lines.join(space)
    execute_around = lambda {
      ENV['ID58'] = id58
      @id58 = id58
      @name58 = name58
      id58_setup
      begin
        t1 = Time.now
        instance_exec(&test_block)
        t2 = Time.now
        stripped = trimmed(name58.split("\n").join)
        @@timings["#{id58}:#{source_file}:#{source_line}:#{stripped}"] = (t2 - t1)
      ensure
        puts $ERROR_INFO.message unless $ERROR_INFO.nil?
        id58_teardown
      end
    }
    name = "#{id58}:#{name58}"
    define_method("test_\n\n#{name}".to_sym, &execute_around)
  end

  def trimmed(str)
    if str.length > 80
      "#{str[0..80]}..."
    else
      str
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  Minitest.after_run do
    slow = @@timings.select { |_name, secs| secs > 0.000 }
    sorted = slow.sort_by { |_name, secs| -secs }.to_h
    size = sorted.size < 5 ? sorted.size : 5
    puts
    puts "Slowest #{size} tests are..." if size != 0
    sorted.each_with_index do |(name, seconds), index|
      break if index === size
      puts format('%3.4f - %-72s', seconds, name)
    end
    puts
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  # NOTE: does not include i I o O
  ID58_ALPHABET = %w[
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H J K L M N P Q R S T U V W X Y Z
    a b c d e f g h j k l m n p q r s t u v w x y z
  ].join.freeze

  def self.id58?(obj)
    obj.instance_of?(String) &&
      obj.chars.all? { |ch| ID58_ALPHABET.include?(ch) }
  end

  def self.checked_id58(id58, lines)
    method = "test '#{id58}',"
    pointer = "#{' ' * method.index("'")}!"
    space = ' '
    proposition = lines.join(space)
    pointee = ['', pointer, method, "'#{proposition}'", '', ''].join("\n")
    pointer.prepend("\n\n")
    raise "#{pointer}empty#{pointee}" if id58 === ''
    raise "#{pointer}not id58#{pointee}" unless id58?(id58)
    raise "#{pointer}duplicate#{pointee}" if @@seen_ids.include?(id58)

    @@seen_ids << id58
    id58
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def id58_setup
  end

  def id58_teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  attr_reader :id58, :name58
end
# simplecov:enable
