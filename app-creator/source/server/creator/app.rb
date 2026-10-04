require_relative 'app_base'
require_relative 'cluster_avatar_order'
require_relative 'creator'
require_relative 'escape_html_helper'
require_relative 'id_typer'
require_relative 'prober'
require_relative 'selected_helper'

module CreatorApp
  class App < AppBase
    # Where nginx sends this app's traffic, and where it therefore mounts
    # itself. Named here so config.ru and the tests mount it identically.
    MOUNT_PATH = '/creator'.freeze

    # The rack app to run: this app under its mount point.
    def self.mounted(externals)
      Rack::URLMap.new(MOUNT_PATH => new(externals))
    end

    def initialize(externals)
      super(externals)
      @externals = externals
    end

    attr_reader :externals

    def creator
      Creator.new(externals)
    end

    get_delegate(Prober, :sha)
    get_delegate(Prober, :alive?)
    get_delegate(Prober, :ready?)

    get '/home' do
      @hostname = ENV.fetch('CYBER_DOJO_ENV', 'none')
      erb :home
    end

    get '/choose_problem' do
      redirect path_to("/setup?#{request.query_string}")
    end

    get '/choose_custom_problem' do
      @type = params['type']
      self.data_source = externals.custom_start_points
      erb :choose_custom_problem
    end

    get '/choose_ltf' do
      redirect path_to("/setup?#{request.query_string}")
    end

    get '/setup' do
      @type = params['type']
      self.data_source = externals.exercises_start_points
      ltfs = externals.languages_start_points
      @ltf_names = ltfs.names
      languages = @ltf_names.map { |name| name.split(',', 2)[0] }
      @languages = languages.uniq.sort_by(&:downcase)
      @ltf_previews = ltfs.manifests.to_h do |name, manifest|
        visible_files = manifest['visible_files']
        [name, visible_files[selected(visible_files)]['content']]
      end
      erb :setup
    end

    post '/create.json' do
      content_type :json
      args = json_args
      type = args.delete(:type)
      id = create(type, args)
      url = path_to("/enter?id=#{id}")
      { 'route' => url, 'id' => id }.to_json
    end

    get '/enter' do
      @id = params['id']
      erb :enter
    end

    get '/id_type' do
      content_type :json
      { 'id_type' => IdTyper.new(externals).id_type(params['id']) }.to_json
    end

    get '/cluster_children' do
      content_type :json
      groups = saver.cluster_manifest(params['id'])['groups']
      children = groups.map do |group_id, manifest|
        { 'id' => group_id, 'display_name' => manifest['display_name'] }
      end
      { 'children' => children }.to_json
    end

    get '/group_display_name' do
      content_type :json
      manifest = saver.group_manifest(params['id'])
      { 'display_name' => manifest['display_name'] }.to_json
    end

    post '/enter.json' do
      content_type :json
      group_id = json_args[:id]
      kata_id = saver.group_join(group_id, cluster_avatar_order(group_id))
      if kata_id.nil?
        { 'full' => true }.to_json
      else
        group_index = saver.kata_manifest(kata_id)['group_index']
        { 'route' => path_to("/avatar?id=#{kata_id}"),
          'id' => kata_id,
          'group_index' => group_index }.to_json
      end
    end

    get '/avatar' do
      @kata_id = params['id']
      manifest = saver.kata_manifest(@kata_id)
      @avatar_index = manifest['group_index'].to_i
      erb :avatar
    end

    # The avatars already in a group, each one's index mapped to its kata id,
    # so the enter page's join dialog can colour those and grey the rest.
    get '/group_joined' do
      content_type :json
      avatars = saver.group_joined(params['id'])
                     .to_h { |group_index, v| [group_index.to_s, v['id']] }
      { 'avatars' => avatars }.to_json
    end

    private

    include EscapeHtmlHelper
    include SelectedHelper

    def create(type, args)
      if type == 'cluster'
        create_cluster(args)
      elsif type == 'group'
        create_group(args)
      else
        create_kata(args)
      end
    end

    def create_cluster(args)
      creator.cluster_create(**args)
    end

    def create_group(args)
      if args.key?(:display_name)
        creator.group_create_custom(**args)
      else
        creator.group_create(**args)
      end
    end

    def create_kata(args)
      if args.key?(:display_name)
        creator.kata_create_custom(**args)
      else
        creator.kata_create(**args)
      end
    end

    # A group joined inside a cluster should hand out an avatar that is scarce
    # across the whole cluster, so a given animal identifies one person across
    # all its LTF groups. Resolve the group's cluster, count every avatar
    # already used across its sibling groups, and return the group_join
    # candidate order that prefers cluster-scarce avatars. Returns nil for a
    # bare group (no cluster), leaving that join on the saver's own default
    # ordering.
    def cluster_avatar_order(group_id)
      cluster_id = saver.group_manifest(group_id)['cluster_id']
      return nil if cluster_id.nil?

      sibling_group_ids = saver.cluster_manifest(cluster_id)['groups'].keys
      used_indexes = sibling_group_ids.flat_map do |sibling_group_id|
        saver.group_joined(sibling_group_id).keys.map(&:to_i)
      end
      ClusterAvatarOrder.new.candidate_indexes(used_indexes)
    end

    def data_source=(start_points)
      manifests = start_points.manifests
      @display_names = manifests.keys.sort_by(&:downcase)
      @display_contents = []
      @display_names.each do |name|
        visible_files = manifests[name]['visible_files']
        filename = selected(visible_files)
        content = visible_files[filename]['content']
        @display_contents << content
      end
    end

    def saver
      externals.saver
    end
  end
end
