require_relative '../../lib/files_from'

class Runner

  def initialize(externals)
    @externals = externals
  end

  def run(params)
    files = files_from(params[:file_content])
    args = {
      id: params[:id] + '-' + (params[:index] || '0'),
      files: plain(files),
      manifest: {
        image_name: params[:image_name],
        max_seconds: params[:max_seconds].to_i
      }
    }

    if params[:rag_lambda] != ""
      args[:manifest][:rag_lambda] = params[:rag_lambda]
    end

    result = runner.run_cyber_dojo_sh(args)

    created = result.delete('created')
    changed = result.delete('changed')

    # Ensure files sent to saver.kata_ran_tests() reflect
    # changes; refreshing the browser should be a no-op.
    created.each { |filename,file| files[filename] = file }
    changed.each { |filename,file| files[filename] = file }

    [result,files,created,changed]
  end

  private

  include FilesFrom

  def plain(files)
    files.each.with_object({}) do |(filename,file),memo|
      memo[filename] = file['content']
    end
  end

  def runner
    @externals.runner
  end

end
