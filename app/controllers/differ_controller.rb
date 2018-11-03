
class DifferController < ApplicationController

  def diff
    # This currently returns events that are traffic-lights.
    # This matches the default event handling in the review-controller.
    # The review/diff dialog/page has been refactored so it
    # works when sent either just traffic-lights or the full set of events.
    # It does not yet have a way to select between these two options.
    # However if it is sent the full set of events it must drop event zero
    # (which is the _kata_ creation event). This is partly so that
    # the lowest index is 1 (one) and not 0 (zero) as it is not
    # clear how to cleanly handle a index of zero in diff-mode since it does
    # not have a previous index. It is also partly because it makes sense
    # for the events to correspond to actual kata/edit events.
    # So, in summary, if returning all the events you still need to do a
    #         events.shift

    @kata = kata
    events = @kata.events
    was_index, now_index = *was_now(events)
    was_files = events[was_index].files(:with_output)
    now_files = events[now_index].files(:with_output)
    diff = differ.diff(was_files, now_files)
    view = diff_view(diff)

    prev_kata_id, next_kata_id = *ring_prev_next(@kata)

    lights = events.select(&:light?).map{ |light| to_json(light) }

    render json: {
                         id: @kata.id,
                     avatar: @kata.avatar_name,
                     wasTag: was_index,
                     nowTag: now_index,
                     events: lights,
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
