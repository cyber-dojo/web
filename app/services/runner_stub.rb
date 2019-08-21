require_relative 'disk_fake'
require 'json'

class RunnerStub

  def initialize(_externals)
    # This is @@disk and not @disk so that it behaves as
    # a real disk on tests that run across multiple threads
    # (as some app-controller tests do).
    @@disk ||= DiskFake.new(self)
  end

  # - - - - - - - - - - - - - - - - -

  def stub_run_colour(colour)
   stub_run('', '', 0, colour)
  end

  def stub_run(stdout, stderr='', status=0, colour='red')
    dir.make
    dir.write(filename, JSON.generate({
        'stdout' => file(stdout),
        'stderr' => file(stderr),
        'status' => status,
        'colour' => colour,
        'created' => {},
        'deleted' => [],
        'changed' => {}
    }))
  end

  def run_cyber_dojo_sh(_image_name, _kata_id, _files, _max_seconds)
    if dir.exists?
      JSON.parse(dir.read(filename))
    else
      { 'stdout' => file('so'),
        'stderr' => file('se'),
        'status' => 0,
        'colour' => 'red',
        'created' => {},
        'deleted' => [],
        'changed' => {}
      }
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

  def file(content)
    { 'content' => content,
      'truncated' => false
    }
  end

end
