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
  # eg name=--git argv=--git=URL ====> returns URL
  args = argv.select{ |arg| arg.start_with?(name + '=')}.map{ |arg| arg.split('=')[1] || '' }
  args.size == 1 ? args[0] : nil
end

#=========================================================================================
# $ ./cyber-dojo clean
#=========================================================================================

def clean
  # TODO: help?
  # TODO: check for unknown args

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
  # TODO: check for unknown args
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
  # TODO: check for unknown args
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
  # TODO: check for unknown args
  if `docker ps --quiet --filter "name=cdf-web"` == ''
    puts "FAILED: Cannot show logs - the web server is not running"
    exit failed
  else
    puts `docker logs cdf-web`
  end
end

#=========================================================================================
# $ ./cyber-dojo up
#=========================================================================================

def up_arg_ok(help, args, name)
  vol = get_arg("--#{name}", args)
  if vol.nil? || vol == 'default-' + name # handled in cyber-dojo.sh
    return true
  end

  # TODO: edge case... this is not type checked
  # cyber-dojo up --languages=default-exercises

  if vol == ''
    show help
    puts "FAILED: missing argument value --#{name}=[???]"
    return false
  end
  if !volume_exists?(vol)
    show help
    puts "FAILED: volume #{vol} does not exist"
    return false
  end
  type = cyber_dojo_type(vol)
  if type != name
    show help
    puts "FAILED: #{vol} is not a #{name} volume (it's #{type})"
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
    'Creates and starts the cyber-dojo server using named/default volumes',
    '',
    minitab + '--languages=VOLUME      Specify the languages volume (otherwise default-languages)',
    minitab + '--exercises=VOLUME      Specify the exercises volume (otherwise default-exercises)',
    minitab + '--instructions=VOLUME   Specify the instructions volume (otherwise default-instructions)',
    minitab + '--env=development       Brings up the web server in development environment',
    minitab + '--env=production        Brings up the web server in production environment (default)',
    minitab + '--env=test              Brings up the web server in test environment',
  ]
  # asked for help?
  if ['help','--help'].include? ARGV[1]
    show help
    exit failed
  end
  # unknown arguments?
  knowns = ['env','languages','exercises','instructions']
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
  # explicit volumes?
  exit failed unless up_arg_ok(help, args, 'languages')     # --languages=VOL
  exit failed unless up_arg_ok(help, args, 'exercises')     # --exercises=VOL
  exit failed unless up_arg_ok(help, args, 'instructions')  # --instructions=VOL
  # cyber-dojo.sh does actual [up]
end

#=========================================================================================
# $ ./cyber-dojo volume
#=========================================================================================

def volume
  help = [
    '',
    "Use: #{me} volume [COMMAND]",
    '',
    'Manage cyber-dojo setup volumes',
    '',
    'Commands:',
    minitab + 'create         Creates a new volume',
    minitab + 'rm             Removes a volume',
    minitab + 'ls             Lists the names of all volumes',
    minitab + 'inspect        Displays details of a volume',
    minitab + 'pull           Pulls the docker images inside a volume',
    '',
    "Run '#{me} volume COMMAND --help' for more information on a command",
  ]
  case ARGV[1]
    when 'create'  then volume_create
    when 'rm'      then volume_rm
    when 'ls'      then volume_ls
    when 'inspect' then volume_inspect
    when 'pull'    then volume_pull
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
  labels.include? 'cyber-dojo-volume'
end

def cyber_dojo_label(vol)
  cyber_dojo_inspect(vol)['Labels']['cyber-dojo-volume']
end

def cyber_dojo_data_manifest(vol)
  command = quoted "cat /data/setup.json"
  JSON.parse(run "docker run --rm -v #{vol}:/data #{cyber_dojo_hub}/user-base sh -c #{command}")
end

def cyber_dojo_type(vol)
  cyber_dojo_data_manifest(vol)['type']
end

#=========================================================================================
# $ ./cyber-dojo volume create
#=========================================================================================

def volume_create
  # TODO: Add a --dir=PATH option which will create a volume from a regular _local_ dir.

  help = [
    '',
    "Use: #{me} volume create --name=VOLUME --git=URL",
    '',
    'Creates a volume named VOLUME as git clone of URL and pulls all its docker images marked auto_pull:true'
  ]
  # asked for help?
  if [nil,'help','--help'].include? ARGV[2]
    show help
    exit failed
  end
  # unknown arguments?
  knowns = ['name','git']
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
  if vol.nil? || url.nil?
    show help
    exit failed
  end
  if vol.length == 1
    msg = 'volume names must be at least two characters long. See https://github.com/docker/docker/issues/20122'
    puts "FAILED: [volume create --name=#{vol}] #{msg}"
    exit failed
  end
  if volume_exists? vol
    msg = "#{vol} already exists"
    puts "FAILED: [volume create --name=#{vol}] #{msg}"
    exit failed
  end
  # cyber-dojo.sh does actual [volume create]
end

# - - - - - - - - - - - - - - -

def exit_unless_is_cyber_dojo_volume(vol, command)
  # TODO: when its implemented, use [volume ls --quiet] ?
  if !volume_exists? vol
    puts "FAILED: [volume #{command} #{vol}] - #{vol} does not exist."
    exit failed
  end

  if !cyber_dojo_volume? vol
    puts "FAILED: [volume #{command} #{vol}] - #{vol} is not a cyber-dojo volume."
    exit failed
  end
end

#=========================================================================================
# $ ./cyber-dojo volume ls
#=========================================================================================

def volume_ls
  help = [
    '',
    "Use: #{me} volume ls",
    '',
    'Lists the names of all cyber-dojo volumes',
    '',
    minitab + '--quiet     Only display volume names'
  ]

  if ['help','--help'].include? ARGV[2]
    show help
    exit failed
  end

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

    headings = { :name => 'NAME', :type => 'TYPE', :url => 'URL' }

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
# $ ./cyber-dojo volume inspect
#=========================================================================================

def volume_inspect
  help = [
    '',
    "Use: #{me} volume inspect VOLUME",
    '',
    'Displays details of the named cyber-dojo volume',
  ]
  # asked for help?
  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit failed
  end

  # TODO: check for unknown args

  exit_unless_is_cyber_dojo_volume(vol, 'inspect')

  docker_version = `docker --version`.split()[2].chomp(',')
  read_only = 'ro'

  command =
  [
    'docker run',
    '--rm',
    "--user=root",
    "--volume=#{vol}:/data:#{read_only}",
    '--volume=/var/run/docker.sock:/var/run/docker.sock',
    "#{cyber_dojo_hub}/web:#{docker_version}",
    "sh -c 'cd /usr/src/cyber-dojo/cli && ./volume_inspect.rb /data'"
  ].join(space=' ')

  print run(command)
end

#=========================================================================================
# $ ./cyber-dojo volume rm
#=========================================================================================

def volume_rm
  # Allow deletion of a default volume.
  # This allows you to create custom default volumes.
  help = [
    '',
    "Use: #{me} volume rm VOLUME",
    '',
    "Removes a volume created with the [#{me} volume create] command"
  ]

  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit failed
  end

  exit_unless_is_cyber_dojo_volume(vol, 'rm')

  run "docker volume rm #{vol}"
  if $exit_status != 0
    puts "FAILED [volume rm #{vol}] can't remove volume if it's in use"
    exit failed
  end

end

#=========================================================================================
# $ ./cyber-dojo volume pull
#=========================================================================================
#
# TODO: Should this pull images?
#       Or should images be pulled when a volume is used in an UP command?
#

def volume_pull
  help = [
    '',
    "Use: #{me} volume pull VOLUME",
    '',
    'Pulls all the docker images named inside the cyber-dojo volume'
  ]
  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit failed
  end

  exit_unless_is_cyber_dojo_volume(vol, 'pull')

  p 'TODO: volume pull'
  #Then have to extract all image names from all manifest.json files.
  #Then do [docker pull IMAGE] for any not present
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def help
  puts [
    '',
    "Use: #{me} [--debug] COMMAND",
    "     #{me} --help",
    '',
    'Commands:',
    tab + 'clean     Removes dangling images',
    tab + 'down      Brings down the server',
    tab + 'logs      Fetch the logs from the server',
    #tab + 'pull      Pulls a docker image',
    #tab + 'rmi       Removes a docker image',
    tab + 'sh        Shells into the server',
    tab + 'up        Brings up the server',
    tab + 'upgrade   Upgrades the server and languages',
    tab + 'volume    Manage cyber-dojo setup volumes',
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
  when nil       then help
  when '--help'  then help
  when 'help'    then help
  when 'clean'   then clean
  when 'down'    then down
  when 'logs'    then logs
  #when 'pull'    then pull
  #when 'rmi'     then rmi
  when 'sh'      then sh
  when 'up'      then up
  when 'upgrade' then upgrade
  when 'volume'  then volume
  else
    puts "#{me}: '#{ARGV[0]}' is not a command."
    puts "See '#{me} --help'."
    exit failed
end

exit 0

=begin
#=========================================================================================
#=========================================================================================
#=========================================================================================
#=========================================================================================
# old code below here
#=========================================================================================
#=========================================================================================
#=========================================================================================
#=========================================================================================

def catalog
  root = File.expand_path('../data/languages', File.dirname(__FILE__))
  all = docker_images_from_manifests(root)
  lines = []
  lines << catalog_line('LANGUAGE', 'TESTS', 'PULLED', 'IMAGE')
  all.sort.map do |language,tests|
    tests.sort.map do |test, hash|
      pulled = hash['pulled']
      image = hash['image']
      lines << catalog_line(language, test, pulled, image)
    end
  end
  lines.join("\n")
  # LANGUAGE          TESTS                PULLED  IMAGE
  # Asm               assert               yes     cyberdojofoundation/nasm_assert
  # BCPL              all_tests_passed     no      cyberdojofoundation/bcpl-all_tests_passed
  # Bash              shunit2              no      cyberdojofoundation/bash_shunit2
  # C (clang)         assert               yes     cyberdojofoundation/clang_assert
  # C (gcc)           CppUTest             yes     cyberdojofoundation/gcc_cpputest
  # ...
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def all_languages
  catalog.split("\n").drop(1).map{ |line| line.split[-1] }
  # [ bcpl-all_tests_passed, bash_shunit2, clang_assert, gcc_cpputest, ...]
end

def in_catalog?(image)
  all_languages.include?(image)
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def languages
  lines = catalog.split("\n").drop(1)
  lines.select { |line| line.split[-2] == 'yes' }.map { |line| line.split[-1] }
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def docker_pull(image, tag)
  run "docker pull #{cyber_dojo_hub}/#{image}:#{tag}"
end

#=========================================================================================
# upgrade
#=========================================================================================

def upgrade
  languages.each { |image| docker_pull(image, 'latest') }
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def bad_image(image)
  if image.nil?
    puts 'missing IMAGE'
  else
    puts "unknown IMAGE #{image}"
  end
  puts "Try '#{me} help'"
end

#=========================================================================================
# pull
#=========================================================================================

def pull
  help = [
    '',
    "Use: #{me} pull IMAGE",
    '',
    'Pulls the named docker image',
  ]
  if [nil,'help','--help'].include? ARGV[1]
    show(help)
    exit 1
  end

  image = ARGV[1]
  # TODO: this should be --all
  if image == 'all'
    all_languages.each do |language|
      docker_pull(language, 'latest')
    end
  elsif in_catalog?(image)
    docker_pull(image, 'latest')
  else
    bad_image(image)
  end
end

#=========================================================================================
# rm
#=========================================================================================

def rmi
  help = [
    '',
    "Use: #{me} rmi IMAGE",
    '',
    'Removes the named docker image',
  ]
  if [nil,'help','--help'].include? ARGV[1]
    show(help)
    exit 1
  end

  image = ARGV[1]
  if languages.include?(image)
    run "docker rmi #{cyber_dojo_hub}/#{image}"
  elsif all_languages.include?(image)
    puts "IMAGE #{image} is not installed"
    puts "Try '#{me} help'"
  else
    bad_image(image)
  end
end

=end