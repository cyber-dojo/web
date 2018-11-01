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

    stdout,stderr,status,
      colour,
        @new_files,@deleted_files,@changed_files =
          @externals.runner.run_cyber_dojo_sh(
            runner_choice,
            image_name, @kata_id,
            new_files, deleted_files,
            changed_files, unchanged_files,
            max_seconds)

    # If there are newlycreated 'output' files remove them
    # otherwise they interferes with the pseudo output-files.
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

  def files_from(params)
    files = cleaned_files(params[:file_content])
    output_filenames.each do |output_filename|
      files.delete(output_filename)
    end
    files
  end

  def delta_from(params)
    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    output_filenames.each do |output_filename|
      incoming.delete(output_filename)
      outgoing.delete(output_filename)
    end
    FileDeltaMaker.make_delta(incoming, outgoing)
  end

  def output_filenames
    %w( stdout stderr status )
  end

end
