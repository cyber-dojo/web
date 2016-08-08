#!/usr/bin/env ruby

def process(params)
  if params[0] == 'start-point' && params[1] == 'create'
    name = params[2]
    dir = params[3]
    unless dir.start_with?('--dir=')
      p "FAIL"
      p "expected: --dir=..."
      p "  actual: #{dir}"
      exit 1
    end
    dir = dir[6..-1]
    src = dir

    cmd = 'mktemp -t cyber-dojo.cid.XXXXXX'
    g_cidfile=`#{cmd}`.strip
    # TODO: add error check

    # docker run --cid=cidfile requires that the cidfile does not already exist
    cmd = "rm -f #{g_cidfile}"
    `#{cmd}`
    # TODO: add error check

    # 1. make an empty docker volume
    cmd = "docker volume create --name=#{name} --label=cyber-dojo-start-point=#{src}"
    `#{cmd}`
    # TODO: add error check

    # 2. mount empty volume inside docker container
    cmd = [
       'docker run',
         '--detach',
         "--cidfile=#{g_cidfile}",
         '--interactive',
         '--net=none',
         '--user=root',
         "--volume=#{name}:/data",
         'cyberdojo/script-spike:1.12.0 sh'
    ].join(' ')

    `#{cmd}`
    # TODO: add error check

    g_cid = `cat #{g_cidfile}`.strip
    # TODO: add error check

    # TODO: rm g_cidfile

    command = [
      # 3. fill empty volume from local dir
      # NB: [cp DIR/.] != [cp DIR];  DIR/. means copy the contents
      "docker cp #{dir}/. #{g_cid}:/data",
      # 4. ensure cyber-dojo user owns everything in the volume
      "docker exec #{g_cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'",
      # 5. check the volume is a good start-point
      "docker exec #{g_cid} sh -c 'cd /usr/src/cyber-dojo/cli && ./start_point_check.rb /data'",
      # 6
      "docker rm -f #{g_cid}"
    ].join(' && ')

    # must use puts (not p) so surrounding quotes are not output
    puts command
  end
end

process(ARGV)

