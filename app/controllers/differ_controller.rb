
class DifferController < ApplicationController

  def diff
    diff = differ.diff(kata.id, was_files, now_files)
    view = diff_view(diff)

    render json: {
                         id: kata.id,
                 avatarName: kata.avatar_name,
                   wasIndex: was_index,
                   nowIndex: now_index,
                     events: kata.events.map{ |event| to_json(event) },
                      diffs: view,
	      idsAndSectionCounts: pruned(view),
          currentFilenameId: pick_file_id(view, current_filename),
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
