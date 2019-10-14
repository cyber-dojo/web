
class DifferController < ApplicationController

  def diff
    version = params[:version].to_i
    id = params[:id]
    was_index = params[:was_index].to_i
    now_index = params[:now_index].to_i
    manifest,events,old_files,new_files = kata.diff_info(was_index, now_index)
    # ensure stdout/stderr/status show no diff
    old_files['stdout'] = new_files['stdout']
    old_files['stderr'] = new_files['stderr']
    old_files['status'] = new_files['status']
    diff = differ.diff(id, old_files, new_files)
    view = diff_view(diff)
    m = Manifest.new(manifest)
    exts = m.filename_extension
    avatar_index = m.group_index
    avatar_name = avatar_index ? Avatars.names[avatar_index] : ''
    result = {
                    version: version,
                         id: id,
                avatarIndex: avatar_index,
                 avatarName: avatar_name,
                   wasIndex: was_index,
                   nowIndex: now_index,
                     events: events.map{ |event| to_json(event) },
                      diffs: view,
	      idsAndSectionCounts: pruned(view),
          currentFilenameId: pick_file_id(view, current_filename, exts)
	  }
    render json:result
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
