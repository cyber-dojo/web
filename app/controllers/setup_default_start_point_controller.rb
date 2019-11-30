
class SetupDefaultStartPointController < ApplicationController

  def show
    @id = id
    @language_names = languages.names
    @language_index = random_index(@language_names)
    manifests = exercises_start_points.manifests
    @exercise_names = manifests.keys.sort
    @exercise_index = random_index(@exercise_names)
    @instructions = []
    @exercise_names.each do |name|
      @instructions << largest(manifests[name]['visible_files'])
    end
    @from = params['from']
  end

  def save_individual
    manifest = starter_manifest
    kata = katas.new_kata(manifest) # [1]
    respond_to do |format|
      format.html { redirect_to "/kata/edit/#{kata.id}" }
    end
  end

  def save_group
    manifest = starter_manifest
    group = groups.new_group(manifest)
    respond_to do |format|
      format.html { redirect_to "/kata/group/#{group.id}" }
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def save_individual_json
    manifest = starter_manifest
    kata = katas.new_kata(manifest)
    respond_to do |format|
      format.json { render json:{id:kata.id} }
    end
  end

  def save_group_json
    manifest = starter_manifest
    group = groups.new_group(manifest)
    respond_to do |format|
      format.json { render json:{id:group.id} }
    end
  end

  private

  include LargestHelper

  def starter_manifest
    exercise_name = params['exercise']
    em = exercises_start_points.manifest(exercise_name)
    language_name = params['language']
    manifest = languages.manifest(language_name)
    manifest['visible_files'].merge!(em['visible_files'])
    manifest['exercise'] = em['display_name']
    manifest['created'] = time.now
    manifest['version'] = 1
    manifest
  end

  def random_index(names)
    rand(0...names.size)
  end

end

=begin
[1] TODO: rescue SaverService::Error
  # go 'offline' if SaverService::Error
  language = "language=#{params['language']}"
  exercise = "exercise=#{params['exercise']}"
  redirect_to "/kata/edit_offline?#{language}&#{exercise}"
=end
