
class ReverterController < ApplicationController

  def revert
    event = kata.events[now_index]
    files = event.files
    stdout = event.stdout
    stderr = event.stderr
    status = event.status
    colour = event.colour
    index = params[:index].to_i + 1

    kata.revert(now_index, index, files, time.now, stdout, stderr, status, colour)

    visible_files = files.map{ |filename,file| [filename, file['content']] }.to_h

    render json: {
      stdout: stdout,
      stderr: stderr,
      status: status,
      visibleFiles: visible_files,
      light: {
        colour: colour,
        index: index,
        revert: now_index
      }
    }
  end

end
