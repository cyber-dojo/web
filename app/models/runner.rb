require_relative '../lib/hidden_file_remover'
require_relative '../../lib/cleaner'

class Runner

  def initialize(externals, kata_id)
    @externals = externals
    @kata_id = kata_id
  end

  def run(params)
    image_name = params[:image_name]
    max_seconds = params[:max_seconds].to_i
    files = files_from(params)

    result =
      @externals.runner.run_cyber_dojo_sh(
        image_name, @kata_id, files, max_seconds)

    created = result['created']
    deleted = result['deleted']
    changed = result['changed']

    # If there are newly created 'output' files remove them
    # otherwise they interferes with the pseudo output-files.
    output_filenames.each do |output_filename|
      created.delete(output_filename)
    end

    # TODO: this has not been checked since {'content'=>content}
    hidden_filenames = JSON.parse(params[:hidden_filenames])
    remove_hidden_files(created, hidden_filenames)

    # Ensure files which will get sent to saver.ran_tests()
    # reflect changes; refreshing the browser should be a no-op.
    created.each { |filename,file| files[filename] = file }
    deleted.each { |filename,_   | files.delete(filename) }
    changed.each { |filename,file| files[filename] = file }

    [result['stdout'], result['stderr'], result['status'],
     result['colour'],
     files,created,deleted,changed
    ]
  end

  private

  include HiddenFileRemover
  include Cleaner

  def files_from(params)
    files = cleaned_files(params[:file_content])
    output_filenames.each do |output_filename|
      files.delete(output_filename)
    end
    Hash[files.map{|filename,content|
      [filename, { 'content' => content }]
    }]
  end

  def output_filenames
    %w( stdout stderr status )
  end

end
