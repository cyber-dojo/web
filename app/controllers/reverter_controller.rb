
class ReverterController < ApplicationController

  def revert
    event = kata.events[now_index]
    files = event.files
    colour = event.colour
    stdout = event.stdout['content']
    stderr = event.stderr['content']
    status = event.status
    visible_files = files.map{ |filename,file| [filename, file['content']] }
                         .to_h

    index = params[:index].to_i + 1
    event_summary = {
      'index' => index,
      'time' => time.now,
      'colour' => colour,
      'duration' => 0.0,
      'revert' => now_index
    }
    event_n = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    saver.assert_all([
      # The order of these commands matters.
      # A failing create_command() ensures the append_command() is not run.
      event_file_create_command(id, index, json_plain(event_n.merge(event_summary))),
      events_file_append_command(id, ",\n" + json_plain(event_summary))
    ])

    render json: {
      stdout: stdout,
      stderr: stderr,
      status: status,
      visibleFiles: visible_files,
      light: {
        colour: colour,
        index: index
      }
    }
  end

  private

  include IdPather # kata_id_path
  include OjAdapter

  def event_file_create_command(id, index, event_src)
    saver.file_create_command(event_filename(id,index), event_src)
  end

  def events_file_append_command(id, eventN_src)
    saver.file_append_command(events_filename(id), eventN_src)
  end

  def events_filename(id)
    kata_id_path(id, 'events.json')
  end
  
  def event_filename(id, index)
    kata_id_path(id, "#{index}.event.json")
  end

end
