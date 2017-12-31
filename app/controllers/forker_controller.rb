
class ForkerController < ApplicationController

  def fork
    result = { forked:false }
    error = true
    begin
      tag_visible_files = storer.tag_visible_files(id, avatar_name, tag)
      error = false
    rescue => caught
      if caught.message == 'invalid kata_id'
        result[:reason] = "dojo(#{id})"
      end
      if caught.message == 'invalid avatar_name'
        result[:reason] = "avatar(#{avatar_name})"
      end
      if caught.message == 'invalid tag'
        result[:reason] = "traffic_light(#{tag})"
      end
    end

    unless error
      manifest = {
               'display_name' => kata.display_name,
                   'exercise' => kata.exercise,
         'filename_extension' => kata.filename_extension,
        'highlight_filenames' => kata.highlight_filenames,
                 'image_name' => kata.image_name,
        'lowlight_filenames'  => kata.lowlight_filenames,
                'max_seconds' => kata.max_seconds,
            'progress_regexs' => kata.progress_regexs,
              'runner_choice' => kata.runner_choice,
                   'tab_size' => kata.tab_size,
              'visible_files' => tag_visible_files
      }

      katas.create_kata(manifest)

      result[:forked    ] = true
      result[:id        ] = manifest['id']
      result[:image_name] = manifest['image_name']
      result[:selection ] = manifest['display_name']
    end

    respond_to do |format|
      format.json { render json: result }
      format.html { redirect_to controller: 'enter',
                                    action: 'show',
                                        id: result[:id] }
    end
  end

end

