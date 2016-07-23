#!/usr/bin/env ruby

# Called from cyber-dojo.sh
# Returns non-zero to indicate cyber-dojo.sh should not proceed.

require 'json'
require 'tempfile'

$debug_mode = false
$exit_status = 0

def failed; 1; end

def me; 'cyber-dojo'; end

def cyber_dojo_hub; 'cyberdojo'; end

def space; ' '; end

def tab; space * 4; end

def minitab; space * 2; end

def show(lines); lines.each { |line| puts line }; print "\n"; end

def quoted(s); '"' + s + '"'; end

def docker_version; `docker --version`.split()[2].chomp(','); end

def web_container_name; 'cyber-dojo-web'; end

def web_server_running; `docker ps --quiet --filter "name=#{web_container_name}"` != ''; end

def read_only; 'ro'; end

def run(command)
  output = `#{command}`
  $exit_status = $?.exitstatus
  if $debug_mode
    puts command
    puts $exit_status
    puts output
  end
  output
end

def get_arg(name, argv)
  # eg name: --git
  #    argv: --git=URL
  #    ====> returns URL
  args = argv.select{ |arg| arg.start_with?(name + '=')}.map{ |arg| arg.split('=')[1] || '' }
  args.size == 1 ? args[0] : nil
end

#=========================================================================================
# $ ./cyber-dojo update
#=========================================================================================

def update
  help = [
    '',
    "Use: #{me} update",
    '',
    'Installs latest web server docker images and associated script files'
  ]
  if ['help','--help'].include? ARGV[1]
    show help
    exit failed
  end

  unless ARGV[1].nil?
    puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end

  # cyber-dojo.sh does actual [update]
end

#=========================================================================================
# $ ./cyber-dojo clean
#=========================================================================================

def clean
  help = [
    '',
    "Use: #{me} clean",
    '',
    'Removes dangling docker images',
  ]
  if ['help','--help'].include? ARGV[1]
    show help
    exit failed
  end

  unless ARGV[1].nil?
    puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end

  # Can give the following
  # Error response from daemon: conflict: unable to delete cfc459985b4b (cannot be forced)
  #   image is being used by running container a7108a524a4d
  command = "docker images -q -f='dangling=true' | xargs docker rmi --force"
  run command
end

#=========================================================================================
# $ ./cyber-dojo down
#=========================================================================================

def down
  help = [
    '',
    "Use: #{me} down",
    '',
    "Stops and removes docker containers created with 'up'",
  ]
  if ['help','--help'].include? ARGV[1]
    show help
    exit failed
  end

  unless ARGV[1].nil?
    puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end

  # cyber-dojo.sh does actual [down]
end

#=========================================================================================
# $ ./cyber-dojo sh
#=========================================================================================

def sh
  help = [
    '',
    "Use: #{me} sh",
    '',
    "Shells into the cyber-dojo web server docker container",
  ]
  if ['help','--help'].include? ARGV[1]
    show help
    exit failed
  end

  unless ARGV[1].nil?
    puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end

  unless web_server_running
    puts "FAILED: Cannot shell in - the web server is not running"
    exit failed
  end

  # cyber-dojo.sh does actual [sh]
end

#=========================================================================================
# $ ./cyber-dojo logs
#=========================================================================================

def logs
  help = [
    '',
    "Use: #{me} logs",
    '',
    "Fetches and prints the logs of the web server (if running)",
  ]
  if ['help','--help'].include? ARGV[1]
    show help
    exit failed
  end

  unless ARGV[1].nil?
    puts "FAILED: unknown argument [#{ARGV[1]}]"
    exit failed
  end

  unless web_server_running
    puts "FAILED: Cannot show logs - the web server is not running"
    exit failed
  else
    puts `docker logs #{web_container_name}`
  end
end

#=========================================================================================
# $ ./cyber-dojo up
#=========================================================================================

def up_arg_ok(help, args, name)
  vol = get_arg("--#{name}", args)
  if vol.nil? || vol == name # handled in cyber-dojo.sh
    return true
  end

  if vol == ''
    show help
    puts "FAILED: missing argument value --#{name}=[???]"
    return false
  end
  unless volume_exists?(vol)
    show help
    puts "FAILED: start-point #{vol} does not exist"
    return false
  end
  type = cyber_dojo_type(vol)
  if type != name
    show help
    puts "FAILED: #{vol} is not a #{name} start-point (it's type from setup.json is #{type})"
    return false
  end
  return true
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def up
  help = [
    '',
    "Use: #{me} up [OPTIONS]",
    '',
    'Creates and starts the cyber-dojo server using named/default start-points',
    '',
    minitab + '--languages=START-POINT  Specify the languages start-point.',
    minitab + "                         Defaults to a start-point named 'languages' created from",
    minitab + '                         https://github.com/cyber-dojo/start-points-languages.git',
    minitab + '--exercises=START-POINT  Specify the exercises start-point.',
    minitab + "                         Defaults to a start-point named 'exercises' created from",
    minitab + '                         https://github.com/cyber-dojo/start-points-exercises.git',
    minitab + '--custom=START-POINT     Specify the custom start-point.',
    minitab + "                         Defaults to a start-point named 'custom' created from",
    minitab + '                         https://github.com/cyber-dojo/start-points-custom.git',
    minitab + '--env=development        Brings up the web server in development environment',
    minitab + '--env=test               Brings up the web server in test environment',
    minitab + '--env=production         Brings up the web server in production environment (default)',
  ]
  # asked for help?
  if ['help','--help'].include? ARGV[1]
    show help
    exit failed
  end
  # unknown arguments?
  knowns = ['env','languages','exercises','custom']
  unknown = ARGV[1..-1].select do |argv|
    knowns.none? { |known| argv.start_with?('--' + known + '=') }
  end
  if unknown != []
    show help
    unknown.each { |arg| puts "FAILED: unknown argument [#{arg.split('=')[0]}]" }
    exit failed
  end
  # --env=
  args = ARGV[1..-1]
  env = get_arg('--env', args)
  if !env.nil? && !['development','production','test'].include?(env)
    show help
    puts "FAILED: bad argument value --env=[#{env}]"
    exit failed
  end
  # explicit start-points?
  exit failed unless up_arg_ok(help, args, 'languages')  # --languages=NAME
  exit failed unless up_arg_ok(help, args, 'exercises')  # --exercises=NAME
  exit failed unless up_arg_ok(help, args,    'custom')  # --custom=NAME
  # cyber-dojo.sh does actual [up]
end

#=========================================================================================
# $ ./cyber-dojo start_point
#=========================================================================================

def start_point
  help = [
    '',
    "Use: #{me} start-point [COMMAND]",
    '',
    'Manage cyber-dojo start-points',
    '',
    'Commands:',
    minitab + 'create         Creates a new start-point',
    minitab + 'rm             Removes a start-point',
    minitab + 'ls             Lists the names of all start-points',
    minitab + 'inspect        Displays details of a start-point',
    minitab + 'pull           Pulls all the docker images named inside a start-point',
    '',
    "Run '#{me} start-point COMMAND --help' for more information on a command",
  ]
  case ARGV[1]
    when 'create'  then start_point_create
    when 'rm'      then start_point_rm
    when 'ls'      then start_point_ls
    when 'inspect' then start_point_inspect
    when 'pull'    then start_point_pull
    else                show help
  end
end

# - - - - - - - - - - - - - - -

def volume_exists?(name)
  # careful to not match substring
  start_of_line = '^'
  end_of_line = '$'
  pattern = "#{start_of_line}#{name}#{end_of_line}"
  run("docker volume ls --quiet | grep '#{pattern}'").include? name
end

def cyber_dojo_inspect(vol)
  info = run("docker volume inspect #{vol}")
  JSON.parse(info)[0]
end

def cyber_dojo_volume?(vol)
  labels = cyber_dojo_inspect(vol)['Labels'] || []
  labels.include? 'cyber-dojo-start-point'
end

def cyber_dojo_label(vol)
  cyber_dojo_inspect(vol)['Labels']['cyber-dojo-start-point']
end

def cyber_dojo_data_manifest(vol)
  command = quoted "cat /data/setup.json"
  JSON.parse(run "docker run --rm -v #{vol}:/data #{cyber_dojo_hub}/user-base sh -c #{command}")
end

def cyber_dojo_type(vol)
  cyber_dojo_data_manifest(vol)['type']
end

#=========================================================================================
# $ ./cyber-dojo start-point create
#=========================================================================================

def start_point_create
  help = [
    '',
    "Use: #{me} start-point create --name=NAME --git=URL",
    "Use: #{me} start-point create --name=NAME --dir=PATH",
    '',
    'Creates a start-point named NAME from a git clone of URL',
    'Creates a start-point named NAME from a copy of PATH'
  ]
  # asked for help?
  if [nil,'help','--help'].include? ARGV[2]
    show help
    exit failed
  end
  # unknown arguments?
  knowns = ['name','git','dir']
  unknown = ARGV[2..-1].select do |argv|
    knowns.none? { |known| argv.start_with?('--' + known + '=') }
  end
  if unknown != []
    show help
    unknown.each { |arg| puts "FAILED: unknown argument [#{arg.split('=')[0]}]" }
    exit failed
  end
  # required known arguments
  args = ARGV[2..-1]
  vol = get_arg('--name', args)
  url = get_arg('--git', args)
  dir = get_arg('--dir', args)
  if vol.nil? || (url.nil? && dir.nil?)
    show help
    exit failed
  end
  if vol.length == 1
    msg = 'start-point names must be at least two characters long. See https://github.com/docker/docker/issues/20122'
    puts "FAILED: [start-point create --name=#{vol}] #{msg}"
    exit failed
  end
  if volume_exists? vol
    msg = "#{vol} already exists"
    puts "FAILED: [start-point create --name=#{vol}] #{msg}"
    exit failed
  end
  # cyber-dojo.sh does actual [start-point create]
end

# - - - - - - - - - - - - - - -

def exit_unless_is_cyber_dojo_volume(vol, command)
  # TODO: when its implemented, use [volume ls --quiet] ?
  if !volume_exists? vol
    puts "FAILED: [start-point #{command} #{vol}] - #{vol} does not exist."
    exit failed
  end

  if !cyber_dojo_volume? vol
    puts "FAILED: [start-point #{command} #{vol}] - #{vol} is not a cyber-dojo start-point."
    exit failed
  end
end

#=========================================================================================
# $ ./cyber-dojo start-point ls
#=========================================================================================

def start_point_ls
  help = [
    '',
    "Use: #{me} start-point ls",
    '',
    'Lists the names of all cyber-dojo start-points',
    '',
    minitab + '--quiet     Only display start-point names'
  ]

  if ['help','--help'].include? ARGV[2]
    show help
    exit failed
  end

  # TODO: check for unknown args

  # There is currently no [--filter label=LABEL]  option on [docker volume ls]
  # https://github.com/docker/docker/pull/21567
  # So I have to inspect all volumes. Could be slow if lots of volumes.

  names = run("docker volume ls --quiet").split
  names = names.select{ |name| cyber_dojo_volume?(name) }

  if ARGV[2] == '--quiet'
    names.each { |name| puts name }
  else
    types = names.map { |name| cyber_dojo_type(name)  }
    urls  = names.map { |name| cyber_dojo_label(name) }

    headings = { :name => 'NAME', :type => 'TYPE', :url => 'SRC' }

    gap = 3
    max_name = ([headings[:name]] + names).max_by(&:length).length + gap
    max_type = ([headings[:type]] + types).max_by(&:length).length + gap
    max_url  = ([headings[:url ]] + urls ).max_by(&:length).length + gap

    spaced = lambda { |max,s| s + (space * (max - s.length)) }

    name = spaced.call(max_name, headings[:name])
    type = spaced.call(max_type, headings[:type])
    url  = spaced.call(max_url , headings[:url ])
    puts name + type + url
    names.length.times do |n|
      name = spaced.call(max_name, names[n])
      type = spaced.call(max_type, types[n])
      url  = spaced.call(max_url ,  urls[n])
      puts name + type + url
    end
  end
end

#=========================================================================================
# $ ./cyber-dojo start-point inspect
#=========================================================================================

def start_point_inspect
  help = [
    '',
    "Use: #{me} start-point inspect VOLUME",
    '',
    'Displays details of the named cyber-dojo start-point',
  ]
  # asked for help?
  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit failed
  end

  # TODO: check for unknown args

  exit_unless_is_cyber_dojo_volume(vol, 'inspect')

  command =
  [
    'docker run',
    '--rm',
    "--user=root",
    "--volume=#{vol}:/data:#{read_only}",
    '--volume=/var/run/docker.sock:/var/run/docker.sock',
    "#{cyber_dojo_hub}/web:#{docker_version}",
    "sh -c 'cd /usr/src/cyber-dojo/cli && ./start_point_inspect.rb /data'"
  ].join(space=' ')

  print run(command)
end

#=========================================================================================
# $ ./cyber-dojo start-point rm
#=========================================================================================

def start_point_rm
  # Allow deletion of a default volume.
  # This allows you to create custom default volumes.
  help = [
    '',
    "Use: #{me} start-point rm VOLUME",
    '',
    "Removes a start-point created with the [#{me} start-point create] command"
  ]

  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit failed
  end

  exit_unless_is_cyber_dojo_volume(vol, 'rm')

  # TODO: check for unknown args

  run "docker volume rm #{vol}"
  if $exit_status != 0
    puts "FAILED [start-point rm #{vol}] can't remove start-point if it's in use"
    exit failed
  end

end

#=========================================================================================
# $ ./cyber-dojo start-point pull
#=========================================================================================
#
def start_point_pull
  help = [
    '',
    "Use: #{me} start-point pull VOLUME",
    '',
    'Pulls all the docker images named inside the cyber-dojo start-point'
  ]
  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit failed
  end

  exit_unless_is_cyber_dojo_volume(vol, 'pull')

  # TODO: check for unknown args

  command =
  [
    'docker run',
    '--rm',
    '--tty',
    "--user=root",
    "--volume=#{vol}:/data:#{read_only}",
    '--volume=/var/run/docker.sock:/var/run/docker.sock',
    "#{cyber_dojo_hub}/web:#{docker_version}",
    "sh -c 'cd /usr/src/cyber-dojo/cli && ./start_point_pull.rb /data'"
  ].join(space=' ')

  system(command)
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def help
  puts [
    '',
    "Use: #{me} [--debug] COMMAND",
    "     #{me} --help",
    '',
    'Commands:',
    tab + 'clean        Removes dangling images',
    tab + 'down         Brings down the server',
    tab + 'logs         Fetch the logs from the server',
    tab + 'sh           Shells into the server',
    tab + 'up           Brings up the server',
    tab + 'update       Updates the server to the latest image',
    tab + 'start-point  Manage cyber-dojo start-points',
    '',
    "Run '#{me} COMMAND --help' for more information on a command."
  ].join("\n") + "\n"

  # TODO: add [help,--help] processing for ALL commands, eg clean,down,up
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ARGV[0] == '--debug'
  $debug_mode = true
  ARGV.shift
end

case ARGV[0]
  when nil            then help
  when '--help'       then help
  when 'help'         then help
  when 'clean'        then clean
  when 'down'         then down
  when 'logs'         then logs
  when 'sh'           then sh
  when 'up'           then up
  when 'update'       then update
  when 'start-point'  then start_point
  else
    puts "#{me}: '#{ARGV[0]}' is not a command."
    puts "See '#{me} --help'."
    exit failed
end

exit 0
