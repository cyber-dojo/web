
class DeltaMaker

  include FileDeltaMaker

  def initialize(avatar)
    @avatar = avatar
    @was = avatar.visible_files
    @now = avatar.visible_files
  end

  attr_reader :was, :now

  def file?(filename)
    @now.keys.include?(filename)
  end

  def content(filename)
    @now[filename]
  end

  def new_file(filename, content)
    refute { file?(filename) }
    @now[filename] = content
  end

  def delete_file(filename)
    assert { file?(filename) }
    @now.delete(filename)
  end

  def change_file(filename, content)
    assert { file?(filename) }
    refute { @now[filename] == content }
    @now[filename] = content
  end

  def stub_colour(colour)
    root = File.expand_path(File.dirname(__FILE__)) + '/../../test/app_lib/output'
    # since start-points volume re-architecture
    # unit_test_framework is no longer directly available...
    unit_test_framework = lookup(@avatar.kata.display_name)
    path = "#{root}/#{unit_test_framework}/#{colour}"
    all_outputs = Dir.glob(path + '/*')
    filename = all_outputs.sample
    output = File.read(filename)
    nearest_ancestors(:runner, @avatar).stub_run_output(@avatar, output)
    @stubbed = true
  end

  def run_test_no_stub(at = time_now)
    visible_files = now
    delta = make_delta(@was, @now)
    output = @avatar.test(delta, visible_files, max_seconds)
    colour = @avatar.kata.red_amber_green(output)
    @avatar.tested(visible_files, at, output, colour)
    [delta, visible_files, output]
  end

  def run_test(at = time_now)
    visible_files = now
    delta = make_delta(@was, @now)
    if @stubbed.nil? && nearest_ancestors(:runner, @avatar).class.name == 'StubRunner'
      stub_colour(:red)
    end
    stdout,stderr,status = @avatar.test(delta, visible_files, max_seconds)
    output = stdout + stderr
    colour = @avatar.kata.red_amber_green(output)
    @avatar.tested(visible_files, at, output, colour)
    [delta, visible_files, output]
  end

  def test_args
    [delta, visible_files]
  end

  def delta
    make_delta(@was, @now)
  end

  def visible_files
    now
  end

  def max_seconds
    10
  end

  private

  include NearestAncestors
  include TimeNow
  include UnitTestFrameworkLookup

  def assert(&pred)
    fail RuntimeError.new('DeltaMaker.assert') unless pred.call
  end

  def refute(&pred)
    fail RuntimeError.new('DeltaMaker.refute') if pred.call
  end

end
