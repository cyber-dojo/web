require_relative '../lib/file_delta_maker'
require_relative '../lib/hidden_file_remover'
require_relative '../../lib/cleaner'

class Runner

  def initialize(externals, kata_id)
    @externals = externals
    @kata_id = kata_id
  end

  def run(params)
    # run tests but don't save the results

    image_name = params[:image_name]
    max_seconds = params[:max_seconds].to_i
    files = cleaned_files(params[:file_content])
    output_filenames.each do |output_filename|
      files.delete(output_filename)
    end

    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    output_filenames.each do |output_filename|
      incoming.delete(output_filename)
      outgoing.delete(output_filename)
    end
    delta = FileDeltaMaker.make_delta(incoming, outgoing)

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

    stdout,stderr,status,
      colour,
        @new_files,@deleted_files,@changed_files =
          @externals.runner.run_cyber_dojo_sh(
            image_name, @kata_id,
            new_files, deleted_files,
            changed_files, unchanged_files,
            max_seconds)

    # If the runner has created an 'output' file remove it
    # otherwise it interferes with the pseudo output-files.
    output_filenames.each do |output_filename|
      @new_files.delete(output_filename)
    end

    hidden_filenames = JSON.parse(params[:hidden_filenames])
    remove_hidden_files(@new_files, hidden_filenames)

    # ensure files which will get sent to ran_tests() reflect changes
    @new_files.each     { |filename,content| files[filename] = content }
    @deleted_files.each { |filename,_      | files.delete(filename)    }
    @changed_files.each { |filename,content| files[filename] = content }

    [stdout,stderr,status,
     colour,
     files,@new_files,@deleted_files,@changed_files
    ]
  end

  private

  include FileDeltaMaker
  include HiddenFileRemover
  include Cleaner

  def output_filenames
    %w( stdout stderr status )
  end

end
