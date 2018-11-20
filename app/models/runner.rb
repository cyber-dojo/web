require_relative '../lib/file_delta_maker'
require_relative '../lib/hidden_file_remover'
require_relative '../../lib/cleaner'

class Runner

  def initialize(externals, kata_id)
    @externals = externals
    @kata_id = kata_id
  end

  def run(params)
    runner_choice = params[:runner_choice]
    image_name = params[:image_name]
    max_seconds = params[:max_seconds].to_i

    files = files_from(params)
    unchanged_files = files_from(params)

=begin
    deleted_files = {}
    changed_files = {}
    new_files = {}
    files = files_from(params)
    delta = delta_from(params)

    new_files = files.select { |filename|
      delta[:new].include?(filename)
    }
    deleted_files = Hash[
      delta[:deleted].map { |filename| [filename, ''] }
    ]
    changed_files = files.select { |filename|
      delta[:changed].include?(filename)
    }
    unchanged_files = files.select { |filename|
      delta[:unchanged].include?(filename)
    }
=end
    result =
      @externals.runner.run_cyber_dojo_sh(
        runner_choice,
        image_name, @kata_id,
        {}, {}, {}, unchanged_files,
        max_seconds)

    created_files = result['created_files']
    deleted_files = result['deleted_files']
    changed_files = result['changed_files']

    # If there are newly created 'output' files remove them
    # otherwise they interferes with the pseudo output-files.
    output_filenames.each do |output_filename|
      created_files.delete(output_filename)
    end

    hidden_filenames = JSON.parse(params[:hidden_filenames])
    remove_hidden_files(created_files, hidden_filenames)

    # Ensure files which will get sent to saver.ran_tests()
    # reflect changes; refreshing the browser should be a no-op.
    created_files.each { |filename,file| files[filename] = file }
    deleted_files.each { |filename,_   | files.delete(filename) }
    changed_files.each { |filename,file| files[filename] = file }

    [result['stdout'], result['stderr'], result['status'],
     result['colour'],
     files,created_files,deleted_files,changed_files
    ]
  end

  private

  #include FileDeltaMaker
  include HiddenFileRemover
  include Cleaner

  def files_from(params)
    files = cleaned_files(params[:file_content])
    output_filenames.each do |output_filename|
      files.delete(output_filename)
    end
    files
  end

=begin
  def delta_from(params)
    # incoming/outgoing is from the Browser's perspective
    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    output_filenames.each do |output_filename|
      incoming.delete(output_filename)
      outgoing.delete(output_filename)
    end
    FileDeltaMaker.make_delta(incoming, outgoing)
  end
=end

  def output_filenames
    %w( stdout stderr status )
  end

end
