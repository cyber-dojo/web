
class ReverterController < ApplicationController

  def revert
    event = kata.events[now_index]
    visible_files = event.files
                         .map{ |filename,file| [filename, file['content']] }
                         .to_h

    # TODO: save event
    # update index

    render json: {
      stdout: event.stdout['content'],
      stderr: event.stderr['content'],
      status: event.status,
      visibleFiles: visible_files,
      index: index + 1,
      light: {
        colour: event.colour,
        index: index + 1
      }
    }
  end

end
