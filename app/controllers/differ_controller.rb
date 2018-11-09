
class DifferController < ApplicationController

  def diff
    was_files = kata.events[was_index].files(:with_output)
    now_files = kata.events[now_index].files(:with_output)
    diff = differ.diff(was_files, now_files)
    view = diff_view(diff)
    prev_kata_id, next_kata_id = *ring_prev_next(kata)

    render json: {
                         id: kata.id,
                 avatarName: kata.avatar_name,
                   wasIndex: was_index,
                   nowIndex: now_index,
                     events: kata.events.map{ |event| to_json(event) },
                      diffs: view,
                 prevKataId: prev_kata_id,
                 nextKataId: next_kata_id,
	      idsAndSectionCounts: pruned(view),
          currentFilenameId: pick_file_id(view, current_filename),
	  }
  end

  private

  include DiffView
  include RingPrevNext
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
