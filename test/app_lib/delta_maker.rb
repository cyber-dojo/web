
class DeltaMaker

  include FileDeltaMaker

  def initialize(kata)
    @kata = kata
    @was = kata.files
    @now = kata.files
  end

  attr_reader :was, :now

  def file?(filename)
    @now.keys.include?(filename)
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

  def run_test(at = time_now)
    params = {
      file_hashes_outgoing:@was,
      file_hashes_incoming:@now,
      image_name:@kata.manifest.image_name,
      max_seconds:@kata.manifest.max_seconds,
      file_content:@now,
    }
    #stdout,stderr,status,
    # colour,
    #  files,new_files,deleted_files,changed_files = *@kata.run_tests(params)

    @kata.ran_tests(visible_files, at, stdout, stderr, colour)

    [delta, visible_files, stdout, stderr]
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

  private

  include TimeNow

  def assert(&pred)
    fail RuntimeError.new('DeltaMaker.assert') unless pred.call
  end

  def refute(&pred)
    fail RuntimeError.new('DeltaMaker.refute') if pred.call
  end

end
