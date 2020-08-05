
class ReverterController < ApplicationController

  def revert
    event = kata.events[index]
    stdout = event.stdout['content']
    stderr = event.stderr['content']
    status = event.status['content']
    visible_files = event.files
                         .map{ |filename,file| [filename, file['content']] }
                         .to_h
    render json: {
      stdout: stdout,
      stderr: stderr,
      status: status,
      visibleFiles: visible_files
    }
  end

end
