# frozen_string_literal: true

require_relative '../../lib/cleaner'

class Runner

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - -

  def run(params)
    files = files_from(params)
    args = {
      id: params[:id] + '-' + (params[:index] || '0'),
      files: plain(files),
      manifest: {
        image_name: params[:image_name],
        max_seconds: params[:max_seconds].to_i,
        hidden_filenames: params[:hidden_filenames]
      }
    }

    json = runner.run_cyber_dojo_sh(args)

    result = json.delete('run_cyber_dojo_sh')

    created = result.delete('created')
    deleted = result.delete('deleted')
    changed = result.delete('changed')

    # If there are newly created 's/s/s' files remove them
    # otherwise they interfere with the pseudo output-files.
    output_filenames.each do |output_filename|
      created.delete(output_filename)
    end

    # Ensure files sent to saver.kata_ran_tests() reflect
    # changes; refreshing the browser should be a no-op.
    created.each { |filename,file| files[filename] = file }
    deleted.each { |filename     | files.delete(filename) }
    changed.each { |filename,file| files[filename] = file }

    [result,files,created,deleted,changed]
  end

  private

  include Cleaner

  def files_from(params)
    files = cleaned_files(params[:file_content])
    output_filenames.each do |output_filename|
      files.delete(output_filename)
    end
    files.each.with_object({}) do |(filename,content),memo|
      memo[filename] = { 'content' => sanitized(content) }
    end
  end

  # - - - - - - - - - - - - - - -

  def plain(files)
    files.each.with_object({}) do |(filename,file),memo|
      memo[filename] = file['content']
    end
  end

  # - - - - - - - - - - - - - - -

  def output_filenames
    %w( output stdout stderr status )
  end

  # - - - - - - - - - - - - - - -

  def sanitized(content)
    max_file_size = 50 * 1024
    content[0..max_file_size]
  end

  # - - - - - - - - - - - - - - -

  def runner
    @externals.runner
  end

end
