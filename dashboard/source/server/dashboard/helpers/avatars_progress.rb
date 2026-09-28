# mixin
module DashboardApp
  module AvatarsProgressHelper
    module_function

    def avatars_progress
      data = []
      gid = params[:id]
      externals.saver.group_joined(gid).map do |avatar_index, o|
        lights = o['events'].select { |event| event.key?('colour') }
        next if lights == []

        data << {
          id: o['id'],
          avatar_index: avatar_index,
          colour: lights[-1]['colour'],
          index: most_recent_non_amber_index(lights)
        }
      end
      all_ids = data.map { |d| d[:id] }
      all_indexes = data.map { |d| d[:index] }
      katas_events = externals.saver.katas_events(all_ids, all_indexes)

      manifest = externals.saver.group_manifest(gid)
      regexs = manifest['progress_regexs'].map { |pattern| Regexp.new(pattern) }

      progress = []
      data.each do |d|
        event = katas_events[d[:id]][d[:index].to_s]
        output = event['stdout']['content'] + event['stderr']['content']
        progress << {
          id: d[:id],
          avatar_index: d[:avatar_index].to_i,
          colour: d[:colour].to_sym,
          progress: regexs.map { |regex| regex.match(output) }.join
        }
      end
      progress
    end

    def most_recent_non_amber_index(lights)
      oldest_non_amber = lights.reverse.find do |light|
        %w[red green].include?(light['colour'])
      end
      if oldest_non_amber.nil?
        lights[-1]['index']
      else
        oldest_non_amber['index']
      end
    end
  end
end
