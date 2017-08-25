
class ForkerController < ApplicationController

  def fork
    result = { forked: false }
    error = false

    if !error && !storer.kata_exists?(id)
      error = true
      result[:reason] = "dojo(#{id})"
    end

    if !error && !storer.avatar_exists?(id, avatar_name)
      error = true
      result[:reason] = "avatar(#{avatar_name})"
    end

    #tag = avatar.tags[params['tag']]
    if !error # && !light.exists?
      tag = params['tag'];
      if tag == '-1'
        tag = "#{avatar.lights.count}"
      end
      is_number = tag.match(/^\d+$/)
      if !is_number || tag.to_i <= 0 || tag.to_i > avatar.lights.count
        error = true
        result[:reason] = "traffic_light(#{tag})"
      else
        tag = tag.to_i
      end
    end

    if !error
      manifest = {
                         'id' => unique_id,
                    'created' => time_now,
                 'image_name' => kata.image_name,
                   'language' => kata.language,
                   'exercise' => kata.exercise,
                   'tab_size' => kata.tab_size,
              'visible_files' => avatar.tags[tag].visible_files
      }

      # before or after start-points volume re-architecture?
      if !kata.unit_test_framework.nil?
        # before
        manifest['unit_test_framework'] = kata.unit_test_framework
      else
        # after
        manifest['display_name'       ] = kata.display_name
        manifest['filename_extension' ] = kata.filename_extension
        manifest['progress_regexs'    ] = kata.progress_regexs
        manifest['highlight_filenames'] = kata.highlight_filenames
        manifest['lowlight_filenames' ] = kata.lowlight_filenames
      end

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

  private

  include TimeNow
  include UniqueId

end

