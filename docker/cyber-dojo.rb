#!/usr/bin/env ruby

# Called from cyber-dojo.sh
# Returns non-zero to indicate cyber-dojo.sh should not proceed.

require 'json'
require 'tempfile'

$debug_mode = false
$exit_status = 0

def me; 'cyber-dojo'; end

def my_dir; File.expand_path(File.dirname(__FILE__)); end

def cyber_dojo_hub; ENV['CYBER_DOJO_HUB'] || 'cyberdojofoundation'; end

def space; ' '; end

def tab; space * 4; end

def minitab; space * 2; end

def show(lines); lines.each { |line| puts line }; print "\n"; end

def run(command)
  puts command if $debug_mode
  output = `#{command}`
  $exit_status = $?.exitstatus
  puts output if $debug_mode
  output
end

def get_arg(name, argv)
  # eg name=--git argv=--git=URL ====> returns URL
  args = argv.select{ |arg| arg.start_with?(name + '=')}.map{ |arg| arg.split('=')[1] || '' }
  args.size == 1 ? args[0] : nil
end

#=========================================================================================
# down
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
    exit 1
  end
  # cyber-dojo.sh does actual [down]
end

#=========================================================================================
# sh
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
    exit 1
  end
  # cyber-dojo.sh does actual [sh]
end

#=========================================================================================
# logs
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
    exit 1
  end

  if `docker ps --quiet --filter "name=cdf-web"` == ''
    puts "FAILED: Cannot show logs - the web server is not running"
    exit 1
  else
    puts `docker logs cdf-web`
  end
end

#=========================================================================================
# up
#=========================================================================================

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

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # asked for help?
  if ['help','--help'].include? ARGV[1]
    show help
    exit 1
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # unknown arguments?
  knowns = ['env','languages','exercises','instructions']
  unknown = ARGV[1..-1].select do |argv|
    knowns.none? { |known| argv.start_with?('--' + known + '=') }
  end
  if unknown != []
    show help
    unknown.each { |arg| puts "FAILED: unknown argument [#{arg}]" }
    exit 1
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # --env=
  args = ARGV[1..-1]
  env = get_arg('--env', args)
  if !env.nil? && !['development','production','test'].include?(env)
    show help
    puts "FAILED: bad argument value --env=[#{env}]"
    exit 1
  end

  github_cyber_dojo = 'https://github.com/cyber-dojo'

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # --languages=
  languages_vol = get_arg('--languages', args) || 'default-languages'
  if languages_vol == ''
    show help
    puts "FAILED: missing argument value --languages=[???]"
    exit 1
  end
  if !volume_exists?(languages_vol)
    if languages_vol == 'default-languages'
      git_clone_into_new_volume('default-languages', "#{github_cyber_dojo}/default-languages.git")
    else
      show help
      puts "FAILED: volume #{languages_vol} does not exist"
      exit 1
    end
  end
  type = cyber_dojo_type(languages_vol)
  if type != 'languages'
    show help
    puts "FAILED: #{languages_vol} is not a languages volume (it's #{type})"
    exit 1
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # --exercises=
  exercises_vol = get_arg('--exercises', args) || 'default-exercises'
  if exercises_vol == ''
    show help
    puts "FAILED: missing argument value --exercises=[???]"
    exit 1
  end
  if !volume_exists?(exercises_vol)
    if exercises_vol == 'default-exercises'
      git_clone_into_new_volume('default-exercises', "#{github_cyber_dojo}/default-exercises.git")
    else
      show help
      puts "FAILED: volume #{exercises_vol} does not exist"
      exit 1
    end
  end
  type = cyber_dojo_type(exercises_vol)
  if type != 'exercises'
    show help
    puts "FAILED: #{exercises_vol} is not an exercise volume (it's #{type})"
    exit 1
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # --instructions=
  instructions_vol = get_arg('--instructions', args) || 'default-instructions'
  if instructions_vol == ''
    show help
    puts "FAILED: missing argument value --instructions=[???]"
    exit 1
  end
  if !volume_exists?(instructions_vol)
    if exercises_vol == 'default-instructions'
      git_clone_into_new_volume('default-instructions', "#{github_cyber_dojo}/default-instructions.git")
    else
      show help
      puts "FAILED: volume #{instructions_vol} does not exist"
      exit 1
    end
  end
  type = cyber_dojo_type(instructions_vol)
  if type != 'instructions'
    show help
    puts "FAILED: #{instructions_vol} is not an instructions volume (it's #{type})"
    exit 1
  end

  # cyber-dojo.sh does actual [up]
end

=begin
def up
 return unless languages == []
  puts 'No language images pulled'
  puts 'Pulling a small starting collection of common language images'
  starting = %w( gcc_assert gpp_assert csharp_nunit java_junit python_pytest ruby_mini_test )
  starting.each { |image| pull(image) }
end
=end

#=========================================================================================
# volume
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

def quoted(s)
  '"' + s + '"'
end

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

def cyber_dojo_manifest(vol)
  command = quoted "cat /data/setup.json"
  JSON.parse(run "docker run --rm -v #{vol}:/data #{cyber_dojo_hub}/user-base sh -c #{command}")
end

def cyber_dojo_type(vol)
  cyber_dojo_manifest(vol)['type']
end

# - - - - - - - - - - - - - - -

class VolumeCreateFailed < Exception

  def initialize(hash)
    @hash = hash
    hash[:exit] = true unless hash.key? :exit
    hash[:rm]   = true unless hash.key? :rm
  end

  def [](key)
    @hash[key]
  end

  def handle(vol)
    # If a [docker run] commands fails then docker sometimes reports...
    #   Error response from daemon: Unable to remove volume, volume still in use: remove abcd: volume is in use -
    #      [9b2bd7be08e38a7315fec421e2a05442ff2ed2e533f10835514ac9a928a5a370]
    # when the given 9b2bd... volume does *not* exist (as reported by [docker volume ls])
    # https://github.com/docker/docker/issues/22093
    # Reports this is a known error and says you can fix it by stopping and starting the docker daemon
    #     $ docker-machine restart default
    # (but that should not be necessary)

    puts "#{self[:output]}" unless self[:output].nil?

    msg = self[:msg] || ''
    msg = ' - ' + msg unless msg == ''
    puts "FAILED: [volume create --name=#{vol}]#{msg}"

    unless self[:cidfile].nil?
      cid = IO.read self[:cidfile]
      run "docker rm --force #{cid}"
    end

    unless self[:rm] === false
      # Sometimes there appears to be a background process which ends
      # after a few seconds and only then can you remove the volume?!
      run "docker volume rm #{vol}"
      if $exit_status != 0
        sleep 2
        run "docker volume rm #{vol}"
      end
    end

    exit 1 unless self[:exit] === false
  end

end

# - - - - - - - - - - - - - - -

def raising_run(command, hash = {})
  if command.start_with? 'docker run'
    tmpfile = Tempfile.new('cyber-dojo')
    cidfile = tmpfile.path
    # cidfile must not exist prior to use
    tmpfile.close
    tmpfile.unlink
    command.slice! 'docker run'
    command = "docker run --cidfile=#{cidfile}" + command
    hash[:cidfile] = cidfile
  end
  output = ''
  begin
    output = run command
    if $exit_status != 0
      hash[:command] = command
      hash[:exit_status] = $exit_status
      hash[:output] = output
      raise VolumeCreateFailed.new(hash)
    end
  rescue Exception
    hash[:command] = command
    raise VolumeCreateFailed.new(hash)
  end
  output
end

#=========================================================================================
# volume create
#=========================================================================================

def git_clone_into_new_volume(name, url)
  puts "Creating #{name} from #{url}"
  # make empty volume
  raising_run "docker volume create --name=#{name} --label=cyber-dojo-volume=#{url}"
  # fill it from git repo, chown it, check it
  command = quoted [
    "git clone --depth=1 --branch=master #{url} /data",
    'rm -rf /data/.git',
    'chown -R cyber-dojo:cyber-dojo /data',
    'app/lib/check_setup_data.rb /data'
  ].join(" && ")

  raising_run "docker run --user=root --rm --volume #{name}:/data #{cyber_dojo_hub}/web:1.11.2 sh -c #{command}"
end

# - - - - - - - - - - - - - - - - - -

def volume_create
  help = [
    '',
    "Use: #{me} volume create --name=VOLUME --git=URL",
    '',
    'Creates a volume named VOLUME as git clone of URL and pulls all its docker images marked auto_pull:true'
  ]

  if [nil,'help','--help'].include? ARGV[2]
    show help
    exit 1
  end

  # TODO: check for unknown args

  args = ARGV[2..-1]
  vol = get_arg('--name', args)
  url = get_arg('--git', args)
  if vol.nil? || url.nil?
    show help
    exit 1
  end

  if vol.length == 1
    msg = 'volume names must be at least two characters long. See https://github.com/docker/docker/issues/20122'
    puts "FAILED: [volume create --name=#{vol}] #{msg}"
    exit 1
  end

  if volume_exists? vol
    msg = "#{vol} already exists"
    puts "FAILED: [volume create --name=#{vol}] #{msg}"
    exit 1
  end

  git_clone_into_new_volume(vol, url)

  # TODO: pull docker images marked auto_pull:true

  rescue VolumeCreateFailed => error
    error.handle(vol)

end

# - - - - - - - - - - - - - - -

def exit_unless_is_cyber_dojo_volume(vol, command)
  # TODO: when its implemented, use [volume ls --quiet] ?
  if !volume_exists? vol
    puts "FAILED: [volume #{command} #{vol}] - #{vol} does not exist."
    exit 1
  end

  if !cyber_dojo_volume? vol
    puts "FAILED: [volume #{command} #{vol}] - #{vol} is not a cyber-dojo volume."
    exit 1
  end
end

#=========================================================================================
# volume rm
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
    exit 1
  end

  exit_unless_is_cyber_dojo_volume(vol, 'rm')

  run "docker volume rm #{vol}"
  if $exit_status != 0
    puts "FAILED [volume rm #{vol}] can't remove volume if it's in use"
    exit 1
  end

end

#=========================================================================================
# volume ls
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
    exit 1
  end

  # There is currently no [--filter label=LABEL]  option on [docker volume ls]
  # https://github.com/docker/docker/pull/21567
  # So I have to inspect all volumes. Could be slow if lots of volumes.

  volumes = run("docker volume ls --quiet").split
  volumes = volumes.select{ |volume| cyber_dojo_volume?(volume) }

  if ARGV[2] == '--quiet'
    volumes.each { |volume| puts volume }
  else
    types   = volumes.map { |volume| cyber_dojo_type(volume)    }
    urls    = volumes.map { |volume| cyber_dojo_label(volume)   }

    headings = { :volume => 'VOLUME', :type => 'TYPE', :url => 'URL' }

    gap = 3
    max_volume = ([headings[:volume]] + volumes).max_by(&:length).length + gap
    max_type   = ([headings[:type  ]] + types  ).max_by(&:length).length + gap
    max_url    = ([headings[:url   ]] + urls   ).max_by(&:length).length + gap

    spaced = lambda { |max,s| s + (space * (max - s.length)) }

    heading = ''
    heading += spaced.call(max_volume, headings[:volume])
    heading += spaced.call(max_type, headings[:type])
    heading += spaced.call(max_url, headings[:url])
    puts heading
    volumes.length.times do |n|
      volume = spaced.call(max_volume, volumes[n])
      type   = spaced.call(max_type, types[n])
      url    = spaced.call(max_url, urls[n])
      puts volume + type + url
    end
  end

end

#=========================================================================================
# volume pull
#=========================================================================================

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
    exit 1
  end

  exit_unless_is_cyber_dojo_volume(vol, 'pull')

  p 'TODO: volume pull'
  #Then have to extract all image names from all manifest.json files.
  #Then do [docker pull IMAGE] for any not present
end

#=========================================================================================
# volume inspect
#=========================================================================================

def volume_inspect # was catalog
  help = [
    '',
    "Use: #{me} volume inspect VOLUME",
    '',
    'Displays details of the named cyber-dojo volume',
  ]

  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit 1
  end

  exit_unless_is_cyber_dojo_volume(vol, 'inspect')

  p 'TODO: volume inspect'

  # Note: this will volume mount the named VOL to find its info
  #       then use globbing as per line 359
  #       it does *not* show the details of what volumes are inside the running web container.
end


#=========================================================================================
#=========================================================================================
#=========================================================================================
#=========================================================================================
# old code below here
#=========================================================================================
#=========================================================================================
#=========================================================================================
#=========================================================================================


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# catalog
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$longest_test = ''
$longest_language = ''

def docker_images_pulled
  `docker images`.drop(1).split("\n").map{ |line| line.split[0] }
  # REPOSITORY                               TAG     IMAGE ID     CREATED      SIZE
  # cyberdojofoundation/visual-basic_nunit   latest  eb5f54114fe6 4 months ago 497.4 MB
  # cyberdojofoundation/ruby_mini_test       latest  c7d7733d5f54 4 months ago 793.4 MB
  # cyberdojofoundation/ruby_rspec           latest  ce9425d1690d 4 months ago 411.2 MB
  # -->
  # cyberdojofoundation/visual-basic_nunit
  # cyberdojofoundation/ruby_mini_test
  # cyberdojofoundation/ruby_rspec
end

def docker_images_from_manifests(root)
  pulled = docker_images_pulled
  hash = {}
  Dir.glob("#{root}/**/manifest.json") do |file|
    manifest = JSON.parse(IO.read(file))
    language, test = manifest['display_name'].split(',').map { |s| s.strip }
    $longest_language = max_size($longest_language, language)
    $longest_test = max_size($longest_test, test)
    image = manifest['image_name']
    hash[language] ||= {}
    hash[language][test] = {
      'image' => image,
      'pulled' => pulled.include?(image) ? 'yes' : 'no'
    }
  end
  hash
end

def max_size(lhs, rhs)
  lhs.size > rhs.size ? lhs : rhs
end

def spacer(longest, name)
  ' ' * (longest.size - name.size)
end

def catalog_line(language, test, pulled, image)
  language_spacer = spacer($longest_language, language)
  test_spacer = spacer($longest_test, test)
  pulled_spacer = spacer(3, pulled)
  gap = ' ' * 3
  line = ''
  line += language + language_spacer + gap
  line += test     + test_spacer     + gap
  line += pulled   + pulled_spacer   + gap
  line += image
end

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

#= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

def help
  puts [
    '',
    "Use: #{me} [--debug] COMMAND",
    "     #{me} --help",
    '',
    'Commands:',
    tab + 'down      Brings down the server',
    tab + 'logs      Fetch the logs from the server',
    tab + 'pull      Pulls a docker image',
    tab + 'rmi       Removes a docker image',
    tab + 'sh        Shells into the server',
    tab + 'up        Brings up the server',
    tab + 'upgrade   Upgrades the server and languages',
    tab + 'volume    Manage cyber-dojo setup volumes',
    '',
    "Run '#{me} COMMAND --help' for more information on a command."
  ].join("\n") + "\n"

  # TODO: add sh function so it can process [help,--help]
  #'    sh [COMMAND]             Shells into the server', #' (and run COMMAND if provided)',

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
  when 'down'    then down
  when 'logs'    then logs
  when 'pull'    then pull
  when 'rmi'     then rmi
  when 'sh'      then sh
  when 'up'      then up
  when 'upgrade' then upgrade
  when 'volume'  then volume
  else
    puts "#{me}: '#{ARGV[0]}' is not a command."
    puts "See '#{me} --help'."
    exit 1
end

exit 0
