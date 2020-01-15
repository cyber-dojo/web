# frozen_string_literal: true

require_relative '../lib/hidden_file_remover'
require_relative '../../lib/cleaner'

class Runner

  def initialize(externals)
    @externals = externals
  end

  def run(params)
    image_name = params[:image_name]
    id = params[:id]
    files = files_from(params)
    max_seconds = params[:max_seconds].to_i

    json = runner.run_cyber_dojo_sh(image_name, id, plain(files), max_seconds)

    result = json.delete('run_cyber_dojo_sh')

    created = result.delete('created')
    deleted = result.delete('deleted')
    changed = result.delete('changed')

    # If there are newly created 's/s/s' files remove them
    # otherwise they interfere with the pseudo output-files.
    output_filenames.each do |output_filename|
      created.delete(output_filename)
    end

    # TODO: this has not been checked since {'content'=>content}
    hidden_filenames = JSON.parse(params[:hidden_filenames])
    remove_hidden_files(created, hidden_filenames)

    # Ensure files sent to saver.kata_ran_tests() reflect
    # changes; refreshing the browser should be a no-op.
    created.each { |filename,file| files[filename] = file }
    deleted.each { |filename     | files.delete(filename) }
    changed.each { |filename,file| files[filename] = file }

    [result,files,created,deleted,changed]
  end

  private

  include HiddenFileRemover
  include Cleaner

  def files_from(params)
    files = cleaned_files(params[:file_content])
    output_filenames.each do |output_filename|
      files.delete(output_filename)
    end
    files.map do |filename,content|
      [filename, {
        'content' => sanitized(content)
      }]
    end.to_h
  end

  def plain(files)
    files.map do |filename,file|
      [filename, file['content']]
    end.to_h
  end

  def output_filenames
    %w( stdout stderr status )
  end

  def sanitized(content)
    max_file_size = 50 * 1024
    content[0..max_file_size]
  end

  def runner
    @externals.runner
  end

end
