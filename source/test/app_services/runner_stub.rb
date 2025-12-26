# frozen_string_literal: true
require 'fileutils'
require 'json'

class RunnerStub

  def initialize(_externals)
  end

  # - - - - - - - - - - - - - - - - -

  def stub_run(stub = {})
    stub[:stdout] ||= ''
    stub[:stderr] ||= ''
    stub[:status] ||= 0
    stub[:outcome] ||= 'red'
    stub[:deleted] ||= []
    dir_write(JSON.generate({
      'stdout' => file(stub[:stdout]),
      'stderr' => file(stub[:stderr]),
      'status' => stub[:status],
      'outcome' => stub[:outcome],
      'created' => {},
      #'deleted' => [],
      'deleted' => stub[:deleted],
      'changed' => {}
    }))
  end

  # - - - - - - - - - - - - - - - - -

  def run_cyber_dojo_sh(_args)
    if dir_exists?
      JSON.parse(dir_read)
    else
      {
        'stdout' => file('so'),
        'stderr' => file('se'),
        'status' => 0,
        'outcome' => 'red',
        'created' => {},
        'deleted' => [],
        'changed' => {}
      }
    end
  end

  private

  def dir_exists?
    Dir.exist?(dirname)
  end

  def dir_write(content)
    FileUtils.mkdir_p(dirname)
    IO.write(filename, content)
  end

  def dir_read
    IO.read(filename)
  end

  def dirname
    "/tmp/runner-stub/#{test_id}"
  end

  def filename
    "#{dirname}/stub_output"
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
