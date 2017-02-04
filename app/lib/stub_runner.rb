require_relative '../../lib/fake_disk'

class StubRunner

  def initialize(_parent)
    @@disk ||= FakeDisk.new(self)
  end

  def new_kata(_image_name, _kata_id); end
  def old_kata(_image_name, _kata_id); end

  # - - - - - - - - - - - - - - - - -

  def new_avatar(_image_name, _kata_id, _avatar_name, _starting_files); end
  def old_avatar(_image_name, _kata_id, _avatar_name); end

  # - - - - - - - - - - - - - - - - -

  def stub_run(stdout, stderr='', status=0)
    dir.make
    dir.write(filename, [stdout,stderr,status])
  end

  def run(_image_name, _kata_id, _name, _deleted_filenames, _changed_files, _max_seconds)
    if dir.exists?
      dir.read(filename)
    else
      ['blah blah blah', '', 0]
    end
  end

  private

  def filename
    'stub_output'
  end

  def dir
    disk[test_id]
  end

  def disk
    @@disk
  end

  def test_id
    ENV['CYBER_DOJO_TEST_ID']
  end

end

# In app_controller tests the stub and call
# calls happen in different threads so disk is
# @@ class variable and not @ instance variable.
