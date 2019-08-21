
class DifferController < ApplicationController

  def diff
    old_files = was_files
    new_files = now_files
    # ensure stdout/stderr/status show no diff
    old_files['stdout'] = new_files['stdout']
    old_files['stderr'] = new_files['stderr']
    old_files['status'] = new_files['status']
    diff = differ.diff(kata.id, old_files, new_files)
    view = diff_view(diff)
    exts = kata.manifest.filename_extension

    render json: {
                         id: kata.id,
                avatarIndex: kata.avatar_index,
                 avatarName: kata.avatar_name,
                   wasIndex: was_index,
                   nowIndex: now_index,
                     events: kata.events.map{ |event| to_json(event) },
                      diffs: view,
	      idsAndSectionCounts: pruned(view),
          currentFilenameId: pick_file_id(view, current_filename, exts)
	  }
  end

  private

  include DiffView
  include ReviewFilePicker

  def current_filename
    params[:filename]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def pruned(array)
    array.map { |hash| {
      :id            => hash[:id],
      :section_count => hash[:section_count]
    }}
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def to_json(light)
    {
      'colour' => light.colour,
      'time'   => light.time,
      'index'  => light.index
    }
  end

end
