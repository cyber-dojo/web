
require_relative './unit_test_framework_lookup'

# Each GET/POST is serviced in a new thread which creates a
# new dojo object and thus a new runner object. To ensure
# state is preserved from the setup to the call it has
# to be saved to disk and then retrieved.

class StubRunner

  def initialize(dojo)
    @dojo = dojo
  end

  def parent
    @dojo
  end

  def pulled?(image_name)
    [
      "#{cdf}/nasm_assert",
      "#{cdf}/gcc_assert",
      "#{cdf}/csharp_nunit",
      "#{cdf}/gpp_cpputest"
    ].include?(image_name)
  end

  def pull(image_name)
    shell.exec("docker pull #{image_name}")
  end

  def stub_run_colour(avatar, rag)
    raise "invalid colour #{rag}" if ![:red,:amber,:green].include? rag
    save_stub(avatar, { :colour => rag })
  end

  def stub_run_output(avatar, output)
    save_stub(avatar, { :output => output })
  end

  def run(id, name, _delta, _files, _image_name)
    output = read_stub(katas[id].avatars[name])
    max_seconds = @dojo.env('runner_timeout')
    output_or_timed_out(output, success=0, max_seconds)
  end

  def max_seconds
    10
  end

  private

  include ExternalParentChainer
  include Runner
  include UnitTestFrameworkLookup

  def save_stub(avatar, json)
    # Better - combine test's hex-id with avater.name in tmp folder
    disk[storer.avatar_path(avatar.kata.id, avatar.name)].write_json(stub_run_filename, json)
  end

  def read_stub(avatar)
    dir = disk[storer.avatar_path(avatar.kata.id, avatar.name)]
    if dir.exists?(stub_run_filename)
      json = dir.read_json(stub_run_filename)
      output = json['output']
      return output unless output.nil?
      rag = json['colour']
      raise "no 'output' or 'colour' in #{json}" if rag.nil?
      return sample(avatar, rag)
    end
    return sample(avatar, red_amber_green.sample)
  end

  def sample(avatar, rag)
    # ?better in test/languages/outputs
    raise "#{rag} must be red/amber/green" unless red_amber_green.include?(rag)
    root = File.expand_path(File.dirname(__FILE__) + '/../../test') + '/app_lib/output'
    unit_test_framework = lookup(avatar.kata.display_name)
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

  def cdf
    'cyberdojofoundation'
  end

end
