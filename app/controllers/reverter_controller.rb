
class ReverterController < ApplicationController

  def revert
    src_id = params[:src_id]
    src_index = params[:src_index].to_i
    event = katas[src_id].events[src_index]
    files = event.files
    stdout = event.stdout
    stderr = event.stderr
    status = event.status
    colour = event.colour

    index = params[:index].to_i + 1

    kata.revert(index, files, time.now, stdout, stderr, status, colour, [src_id,src_index])

    render json: {
      stdout: stdout,
      stderr: stderr,
      status: status,
      files: files.map{ |filename,file| [filename, file['content']] }.to_h,
      light: {
        colour: colour,
        index: index,
        revert: [src_id,src_index]
      }
    }
  end

end
