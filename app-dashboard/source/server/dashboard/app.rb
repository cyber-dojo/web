require_relative 'app_base'
require_relative 'prober'
require_relative 'helpers/gatherer'
require_relative 'helpers/avatars_progress'

module DashboardApp
  class App < AppBase
    # Where nginx sends this app's traffic, and where it therefore mounts
    # itself. Named here so config.ru and the tests mount it identically.
    MOUNT_PATH = '/dashboard'.freeze

    # The rack app to run: this app under its mount point.
    def self.mounted(externals)
      Rack::URLMap.new(MOUNT_PATH => new(externals))
    end

    def initialize(externals)
      super
      @externals = externals
    end

    attr_reader :externals

    get_delegate(Prober, :alive?)
    get_delegate(Prober, :ready?)
    get_delegate(Prober, :sha)

    get '/show/:id', provides: [:html] do
      @id = params[:id]
      resolve_group_and_tabs
      redirect(cluster_url) if @cluster_id && @cluster_id != @id
      respond_to do |wants|
        wants.html do
          erb :show
        end
      end
    end

    get '/heartbeat/:id', provides: [:json] do
      # Process all traffic-lights into minute columns here in Ruby
      # which can easily handle integers (unlike JS).
      # Then let browser do all rendering in JS.
      respond_to do |wants|
        wants.json do
          gather
          time_ticks = modified(@time_ticks)
          avatars = altered(@all_indexes, @gapped)
          json({ time_ticks: time_ticks, avatars: avatars })
        end
      end
    end

    get '/diff_summary', provides: [:json] do
      respond_to do |wants|
        wants.json do
          id = params[:id]
          was_index = params[:was_index].to_i
          now_index = params[:now_index].to_i
          summary = externals.saver.diff_summary(id, was_index, now_index)
          json({ diff_summary: summary })
        end
      end
    end

    get '/progress/:id', provides: [:json] do
      respond_to do |wants|
        wants.json do
          json(katas: avatars_progress)
        end
      end
    end

    get '/active_groups/:id', provides: [:json] do
      respond_to do |wants|
        wants.json do
          json(active_groups)
        end
      end
    end

    private

    # For each child group of the cluster @id resolves up to, whether that group
    # has any avatar with a non-creation event (a traffic-light) - ie whether it
    # is worth rotating a cluster dashboard's auto-refresh onto. Keyed by child
    # group id. Empty for a standalone group (no cluster - nothing to rotate).
    def active_groups
      chain = externals.saver.id_chain(params[:id])
      cluster = chain.find { |entry| entry['type'] == 'cluster' }
      return {} unless cluster

      group_ids = externals.saver.cluster_manifest(cluster['id'])['groups'].keys
      group_ids.to_h { |group_id| [group_id, group_active?(group_id)] }
    rescue StandardError
      # Best-effort, like resolve_group_and_tabs: on any saver hiccup report
      # nothing active so the caller simply refreshes in place, never crashing.
      {}
    end

    # True when any avatar in the group has a non-creation event. A freshly
    # joined avatar has only its index-0 'created' event; a test run adds an
    # event with index != 0. Matches gatherer's has_activity notion.
    def group_active?(group_id)
      externals.saver.group_joined(group_id).any? do |_avatar_index, o|
        o['events'].any? { |event| event['index'] != 0 }
      end
    end

    helpers AvatarsProgressHelper
    helpers GathererHelper

    # Resolves the shared id in @id (a kata, group or cluster id) up to the
    # topmost entity and decides how the page renders it:
    # - @cluster_id is the cluster the id belongs to (nil for a standalone
    #   group); it is the id the URL is canonicalised onto.
    # - @group_id is the child group whose avatars are shown first
    #   (cd.groupId()).
    # - @tabs is one entry per child group of a cluster (id + LTF display_name);
    #   it is empty for a standalone group, so today's single view is unchanged.
    # A cluster shows one tab per child group (duplicate-LTF children each get
    # their own tab); the given id picks the active child (kata/group -> its own
    # group; a bare cluster id -> the first child).
    def resolve_group_and_tabs
      chain = externals.saver.id_chain(@id)
      cluster = chain.find { |entry| entry['type'] == 'cluster' }
      group   = chain.find { |entry| entry['type'] == 'group' }
      if cluster
        groups = externals.saver.cluster_manifest(cluster['id'])['groups']
        @tabs = groups.map do |group_id, manifest|
          { 'id' => group_id, 'display_name' => manifest['display_name'] }
        end
        @cluster_id = cluster['id']
        @group_id = active_child_id(group)
      else
        @cluster_id = nil
        @tabs = []
        @group_id = group ? group['id'] : @id
      end
    rescue StandardError
      # Resolving is best-effort: if the id resolves to nothing (or the saver is
      # unreachable), render as a standalone group keyed on the given id, and
      # let the per-child fetches surface any error.
      @cluster_id = nil
      @tabs = []
      @group_id = @id
    end

    # The canonical URL of the cluster the requested id sits in: the cluster's
    # own /show URL, carrying the resolved child group as ?group_id= so the same
    # tab stays active, and keeping every other query param (eg sort_by).
    # path_to() prepends wherever the app is mounted, so this reads the same
    # whether that is /dashboard or, in tests, the root.
    def cluster_url
      query = request.params.merge('group_id' => @group_id)
      path_to("/show/#{@cluster_id}?#{Rack::Utils.build_query(query)}")
    end

    # Picks which child group of a cluster is the initially-active tab. A
    # ?group_id= query param naming a real child wins (deep-linking straight to
    # one LTF's tab); otherwise the child from the resolved path id, else the
    # first tab. An unknown group_id is ignored so we never activate an absent
    # tab.
    def active_child_id(group)
      wanted = params[:group_id]
      return wanted if @tabs.any? { |tab| tab['id'] == wanted }

      group ? group['id'] : @tabs.first['id']
    end

    def altered(indexes, gapped)
      indexes.to_h do |kata_id, group_index|
        [group_index, {
          kata_id: kata_id,
          lights: lights_json(gapped[kata_id])
        }]
      end
    end

    def lights_json(minutes)
      # eg minutes = {
      #     "0": [ L,L,L ],
      #     "1": { "collapsed":525 },
      #   "526": [ L,L ]
      # }
      minutes.transform_values { |value| minute_json(value) }
    end

    def minute_json(minute)
      if collapsed?(minute)
        minute
      else
        minute.map { |light| light_json(light) }
      end
    end

    def collapsed?(section)
      section.is_a?(Hash) # lights are in an Array
    end

    def light_json(light)
      element = {
        previous_index: light.previous_index,
        index: light.index,
        major_index: light.major_index,
        minor_index: light.minor_index,
        colour: light.colour,
        time: light.time_a
      }
      if light.predicted && light.predicted != 'none'
        element['predicted'] = light.predicted
      end
      element['revert'] = light.revert if light.revert
      element['checkout'] = light.checkout if light.checkout
      element['filename'] = light.filename if light.filename
      element
    end

    def modified(ticks)
      ticks.transform_values do |v|
        dhm(v)
      end
    end

    def dhm(value)
      if value.is_a?(Integer)
        time_tick(value)
      else
        value # Hash === collapsed columns
      end
    end

    def time_tick(seconds)
      # Avoiding Javascript integer arithmetic
      minutes = (seconds / 60) % 60
      hours   = (seconds / 60 / 60) % 24
      days    = (seconds / 60 / 60 / 24)
      [days, hours, minutes]
    end
  end
end
