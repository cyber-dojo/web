
class DifferController < ApplicationController

  def diff
    @kata = kata
    events = @kata.events
    was_index, now_index = *was_now(events)
    was_files = events[was_index].files(:with_output)
    now_files = events[now_index].files(:with_output)
    diff = differ.diff(was_files, now_files)
    view = diff_view(diff)
    prev_kata_id, next_kata_id = *ring_prev_next(@kata)

    render json: {
                         id: @kata.id,
                 avatarName: @kata.avatar_name,
                   wasIndex: was_index,
                   nowIndex: now_index,
                     events: events.map{ |event| to_json(event) },
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

  def was_now(events)
    # You get -1 when in non-diff mode
    was = was_tag
    now = now_tag
    was = events[-1].index if was == -1
    now = events[-1].index if now == -1
    [was,now]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

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
