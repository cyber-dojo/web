#!/usr/bin/env ruby

# Called from cyber-dojo.sh
# Returns non-zero to indicate cyber-dojo.sh should not proceed.

require 'json'

def me; 'cyber-dojo'; end

def my_dir; File.expand_path(File.dirname(__FILE__)); end

def cyber_dojo_hub; ENV['CYBER_DOJO_HUB']; end

def space; ' '; end

def tab(line = ''); (space * 4) + line; end

def minitab(line = ''); (space * 2) + line; end

def quiet_run(command); `#{command}`; end

def show(lines); lines.each { |line| puts line }; end

def run(command)
  puts command
  quiet_run(command)
end

def json_parse(s)
  manifest = {}
  begin
    manifest = JSON.parse(s)
  rescue
  end
  manifest
end

#=========================================================================================
# clean
#=========================================================================================

def clean
  help = [
    '',
    "Use: #{me} clean",
    '',
    'Removes all dangling docker images and volumes',
  ]
  if ['help','--help'].include? ARGV[1]
    show(help)
    exit 1
  end
  run "docker images --quiet --filter='dangling=true' | xargs docker rmi --force"
  run "docker volume ls --quiet --filter='dangling=true' | xargs docker volume rm"
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
    show(help)
    exit 1
  end
  # Nothing else to do. cyber-dojo.sh handles [down]
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
    show(help)
    exit 1
  end
  # Nothing else to do. cyber-dojo.sh handles [sh]
end

#=========================================================================================
# up
#=========================================================================================

def up
  help = [
    '',
    "Use: #{me} up [OPTIONS]",
    '',
    'Creates and starts the cyber-dojo server using default/named volumes',
    '',
    minitab('--languages=VOLUME      Specify the languages volume (otherwise default_languages)'),
    minitab('--exercises=VOLUME      Specify the exercises volume (otherwise default_exercises)'),
    minitab('--instructions=VOLUME   Specify the instructions volume (otherwise default_instructions)')
  ]

  if ['help','--help'].include? ARGV[1]
    show(help)
    exit 1
  end

  unknown = ARGV[1..-1].select do |arg|
    !arg.start_with?('--languages=') &&
    !arg.start_with?('--exercises=') &&
    !arg.start_with?('--instructions=')
  end

  if unknown != []
    show(help)
    exit 1
  end
  # Nothing else to do. cyber-dojo.sh handles [up]
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
    'Commands:',
    minitab('create         Creates a new cyber-dojo volume'),
    minitab('rm             Removes cyber-dojo volumes'),
    minitab('ls             Lists the names of all cyber-dojo volumes'),
    minitab('inspect        Displays cyber-dojo volume details'),
    minitab('pull           Pulls the docker images inside cyber-dojo volumes'),
    '',
    "Run '#{me} volume COMMAND --help' for more information on a command",
  ]
  case ARGV[1]
    when 'create'  then volume_create
    when 'rm'      then volume_rm
    when 'ls'      then volume_ls
    when 'inspect' then volume_inspect
    when 'pull'    then volume_pull
    else                show(help)
  end
end

# - - - - - - - - - - - - - - -

def quoted(s)
  '"' + s + '"'
end

def get_arg(name, argv)
  # eg name=--git
  #    argv=[--git=https://github.com/JonJagger/cyber-dojo-refactoring-exercises.git, ...]
  #   ---> https://github.com/JonJagger/cyber-dojo-refactoring-exercises.git

  args = argv.select{ |arg| arg.start_with?(name + '=')}.map{ |arg| arg.split('=')[1] }
  args.size == 1 ? args[0] : nil
end

def volume_exists?(name)
  # careful to not match substring
  space = ' '
  end_of_line = '$'
  pattern = "#{space}#{name}#{end_of_line}"
  quiet_run("docker volume ls --quiet | grep #{pattern}").include? name
end

def cyber_dojo_volume?(volume)
  info = quiet_run("docker volume inspect #{volume}")
  manifest = JSON.parse(info)[0]
  labels = manifest['Labels'] || []
  labels.include? 'cyber-dojo-volume'
end

# - - - - - - - - - - - - - - -

def volume_create
  help = [
    '',
    "Use: #{me} volume create --name=VOLUME --git=URL",
    '',
    tab('Creates a volume named VOLUME as git clone of URL'),
    tab('and pulls all its docker images marked auto_pull:true')
  ]

  if [nil,'help','--help'].include? ARGV[2]
    show help
    exit 1
  end

  args = ARGV[2..-1]
  vol = get_arg('--name', args)
  url = get_arg('--git', args)
  if vol.nil? || url.nil?
    show help
    exit 1
  end

  if vol.length == 1
    puts "FAILED [volume create --name=#{vol}] because of a restriction in docker."
    puts "volume names must be at least two characters long."
    puts "See https://github.com/docker/docker/issues/20122"
    exit 1
  end

  if volume_exists? vol
    puts "FAILED [volume create --name=#{vol}] because #{vol} already exists."
    exit 1
  end

  quiet_run "docker volume create --name=#{vol} --label=cyber-dojo-volume=#{url}"
  command = quoted "git clone --depth=1 --branch=master #{url} /data && rm -rf /data/.git"
  output = run "docker run --rm -v #{vol}:/data #{cyber_dojo_hub}/user-base sh -c #{command}"
  if $?.exitstatus != 0
    quiet_run "docker volume rm #{vol}"
    exit 1
  end

  command = quoted "cat /data/volume.json"
  output = quiet_run "docker run --rm -v #{vol}:/data #{cyber_dojo_hub}/user-base sh -c #{command}"
  if $?.exitstatus != 0
    quiet_run "docker volume rm #{vol}"
    puts "FAILED [volume create --name=#{vol}] because #{vol} does not have a well-formed /volume.json"
    exit 1
  end

  manifest = json_parse(output)

  type = manifest['type']
  if !['languages','exercises','instructions'].include? type
    quiet_run "docker volume rm #{vol}"
    puts "FAILED [volume create --name=#{vol}] because #{vol} does not have a well-formed /volume.json"
    puts "volume.json must include one of..."
    puts "{ 'type': 'languages' }"
    puts "{ 'type': 'exercises' }"
    puts "{ 'type': 'instructions' }"
    exit 1
  end

  # TODO:    if 'type' != 'instructions' check manifest contains...
  # TODO:    'lhs-column-title': 'name',
  # TODO:    'rhs-column-title': 'language'

  # TODO: in other commands extract the type dynamically from the volume's volume.json manifest

end

# - - - - - - - - - - - - - - -

def volume_rm
  # You are allowed to delete a default volume.
  # This allows you to create default volumes.
  help = [
    '',
    "Use: #{me} volume rm VOLUME",
    '',
    tab('Removes a volume created with the command'),
    tab("#{me} volume create")
  ]

  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit 1
  end

  if !volume_exists? vol
    puts "FAILED [volume rm #{vol}] because #{vol} does not exist."
    exit 1
  end

  if !cyber_dojo_volume? vol
    puts "FAILED [volume rm #{vol}] because #{vol} is not a cyber-dojo volume."
    exit 1
  end

  quiet_run "docker volume rm #{vol}"
end

# - - - - - - - - - - - - - - -

def volume_ls
  help = [
    '',
    "Use: #{me} volume ls",
    '',
    tab('Lists the names of all cyber-dojo volumes'),
  ]

  if ['help','--help'].include? ARGV[2]
    show help
    exit 1
  end

  # TODO: display the volume's TYPE [languages/exercises/instructions]
  # TODO: display the volume's URL (from the label)
  # TODO: add --quiet option to display only the names

  # There seems to be no [--filter label=L]  option on [docker volume ls]
  # https://github.com/docker/docker/pull/21567
  # So I have to inspect all volumes.
  # Could be slow if lots of volumes.

  volumes = quiet_run("docker volume ls --quiet").split
  puts volumes.select{ |volume| cyber_dojo_volume?(volume) }.join("\n")
end

# - - - - - - - - - - - - - - -

def volume_pull
  help = [
    '',
    "Use: #{me} volume pull VOLUME",
    '',
    tab('Pulls the docker images named inside the cyber-dojo volume'),
  ]
  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit 1
  end

  p 'TODO: volume pull'
  #check volume is labelled as per [volume create]
  #Then have to extract all image names from all manifest.json files.
end

# - - - - - - - - - - - - - - -

def volume_inspect # was catalog
  help = [
    '',
    "Use: #{me} volume inspect VOLUME",
    '',
    tab('Displays details of the named cyber-dojo volume'),
  ]

  vol = ARGV[2]
  if [nil,'help','--help'].include? vol
    show help
    exit 1
  end

  if !volume_exists? vol
    puts "FAILED [volume inspect #{vol}] because #{vol} does not exist."
    exit 1
  end

  if !cyber_dojo_volume? vol
    puts "FAILED [volume inspect #{vol}] because #{vol} is not a cyber-dojo volume."
    exit 1
  end

  p 'TODO: volume inspect'

  # Note: this will volume mount the named VOL to find its info
  #       then use globbing as per line 359
  #       it does not show the details of what volumes are inside the running web container.
end

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
    tab('Pulls the named docker image'),
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
    tab('Removes the named docker image'),
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
    "Use: #{me} COMMAND",
    "     #{me} [help]",
    '',
    '    clean     Removes dangling docker images and volumes',
    '    down      Brings down the server',
    '    pull      Pulls a docker image',
    '    rmi       Removes a docker image',
    '    sh        Shells into the server',
    '    up        Brings up the server',
    '    upgrade   Upgrades the server and languages',
    '    volume    Manage cyber-dojo data volumes',
    '',
  ].join("\n") + "\n"

  # TODO: add sh function so it can process [help,--help]
  #'    sh [COMMAND]             Shells into the server', #' (and run COMMAND if provided)',

  # TODO: add [help,--help] processing for ALL commands, eg clean,down,up
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

case ARGV[0]
  when nil       then help
  when '--help'  then help
  when 'help'    then help
  when 'clean'   then clean
  when 'down'    then down
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
