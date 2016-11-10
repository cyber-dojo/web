
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

  def new_kata(_image_name, _id); end
  def old_kata(_id); end

  # - - - - - - - - - - - - - - - - -

  def new_avatar(_image_name, _id, _avatar_name, _starting_files); end
  def old_avatar(_id, _avatar_name); end

  # - - - - - - - - - - - - - - - - -

  def stub_run_colour(avatar, rag)
    fail "invalid colour #{rag}" unless [:red,:amber,:green].include? rag
    save_stub(avatar, { :colour => rag })
  end

  def stub_run_output(avatar, output)
    save_stub(avatar, { :output => output })
  end

  def run(_image, _id, _name, _delta, _files, _image_name)
    stdout = read_stub
    stderr = ''
    status = (success = 0)
    [stdout,stderr,status]
  end

  def max_seconds
    10
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
    output = json['output']
    return output unless output.nil?
    rag = json['colour']
    fail "no 'output' or 'colour' in #{json}" if rag.nil?
    return sample(@avatar, rag)
  end

  def sample(avatar, rag)
    # ?better in test/languages/outputs
    fail "#{rag} must be red/amber/green" unless red_amber_green.include?(rag)
    root = File.expand_path(File.dirname(__FILE__) + '/../../test') + '/app_lib/output'
    unit_test_framework = lookup(@avatar.kata.display_name)
    path = "#{root}/#{unit_test_framework}/#{rag}"
    all_output_samples = disk[path].each_file.collect { |filename| filename }
    filename = all_output_samples.sample
    disk[path].read(filename)
  end

  def red_amber_green
    %w(red amber green)
  end

  def stub_run_filename
    'stub_run.json'
  end

  def test_id
    ENV['CYBER_DOJO_TEST_ID']
  end

  #def output_or_timed_out(output, status)
  #  status != 'timed_out' ? output : did_not_complete
  #end
  #
  #def did_not_complete
  #  "Unable to complete the tests in #{max_seconds} seconds.\n" +
  #  "Is there an accidental infinite loop?\n" +
  #  "Is the server very busy?\n" +
  #  "Please try again."
  #end

end
