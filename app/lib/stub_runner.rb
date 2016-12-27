
require_relative './unit_test_framework_lookup'

# Each GET/POST is serviced in a new thread which creates a
# new dojo object and thus a new runner object. To ensure
# state is preserved from the setup to the call it has
# to be saved to disk and then retrieved.

class StubRunner

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def pulled?(image_name); image_names.include?(image_name); end
  def pull(_image_name); end

  # - - - - - - - - - - - - - - - - -

  def new_kata(_image_name, _kata_id); end
  def old_kata(_kata_id); end

  # - - - - - - - - - - - - - - - - -

  def new_avatar(_image_name, _kata_id, _avatar_name, _starting_files); end
  def old_avatar(_kata_id, _avatar_name); end

  # - - - - - - - - - - - - - - - - -

  def stub_run_output(avatar, output)
    save_stub(avatar, { :output => output })
  end

  def run(_image_name, _kata_id, _name, _deleted_filenames, _changed_files, _max_seconds)
    stdout = read_stub
    stderr = ''
    status = (success = 0)
    [stdout,stderr,status]
  end

  private

  include NearestAncestors
  def disk; nearest_ancestors(:disk); end

  include UnitTestFrameworkLookup

  def image_names
    cdf = 'cyberdojofoundation'
    [
      "#{cdf}/nasm_assert",
      "#{cdf}/gcc_assert",
      "#{cdf}/csharp_nunit",
      "#{cdf}/gpp_cpputest"
    ]
  end

  def save_stub(avatar, json)
    dir = disk['/tmp/cyber-dojo/StubRunner/' + test_id]
    dir.make
    dir.write_json(stub_run_filename, json)
    @avatar = avatar
  end

  def read_stub
    return 'blah' if @avatar.nil?
    dir = disk['/tmp/cyber-dojo/StubRunner/' + test_id]
    fail 'nothing stubbed for StubRunner' unless dir.exists?(stub_run_filename)
    json = dir.read_json(stub_run_filename)
    json['output']
  end

  def stub_run_filename
    'stub_run.json'
  end

  def test_id
    ENV['CYBER_DOJO_TEST_ID']
  end

end
