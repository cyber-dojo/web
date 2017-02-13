require_relative '../../lib/disk_fake'

class RaggerStub

  def initialize(_parent)
    @@disk ||= DiskFake.new(self)
  end

  def stub_colour(rag)
    fail "invalid colour #{rag}" unless [:red,:amber,:green].include? rag
    dir.make
    dir.write(filename, rag)
  end

  def colour(_kata, _output)
    dir.read(filename)
  end

  private

  def filename
    'stub_colour'
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

# In app_controller tests the stubs and calls
# calls happen in different threads so disk is
# @@ class variable and not @ instance variable.
