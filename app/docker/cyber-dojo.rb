#!/usr/bin/env ruby

# Called from cyber-dojo.sh
# Returns non-zero to indicate cyber-dojo.sh should not proceed.

require 'json'

def me; 'cyber-dojo'; end

def my_dir; File.expand_path(File.dirname(__FILE__)); end

def docker_hub_username; 'cyberdojofoundation'; end

def docker_version; ENV['DOCKER_VERSION']; end

def home; '/usr/src/cyber-dojo'; end  # home folder *inside* the server image

def space; ' '; end

def tab(line = ''); (space * 4) + line; end

def minitab(line = ''); (space * 2) + line; end

def quiet_run(command); `#{command}`; end

def show(lines); lines.each { |line| puts line }; end

def run(command)
  puts command
  quiet_run(command)
  #TODO: diagnostic if command fails
end

#=========================================================================================
# clean
#=========================================================================================

def clean
  help = [
    '',
    "Use: #{me} clean",
    '',
    'Removes all dangling docker images',
  ]
  if ['help','--help'].include? ARGV[1]
    show(help)
    exit 1
  end
  run "docker images -q -f='dangling=true' | xargs docker rmi --force"
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
    minitab('--languages=VOL      Specify the languages volume (otherwise default_languages)'),
    minitab('--exercises=VOL      Specify the exercises volume (otherwise default_exercises)'),
    minitab('--instructions=VOL   Specify the instructions volume (otherwise default_instructions)')
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

# - - - - - - - - - - - - - - -

def volume_create
  help = [
    '',
    "Use: #{me} volume create --name=NAME --git=URL",
    '',
    tab('Creates a volume named NAME as git clone of URL'),
    tab('and pulls all its docker images marked auto_pull:true')
  ]

  if [nil,'help','--help'].include? ARGV[2]
    show(help)
    exit 1
  end

  args = ARGV[2..-1]
  name = get_arg('--name', args)
  url = get_arg('--git', args)
  if name.nil? || url.nil?
    show(help)
    exit 1
  end

  matching = quiet_run("docker volume ls --quiet | grep #{name}")
  already_exists = matching.include? name
  if already_exists
    puts "Cannot create volume #{name} because it already exists."
    puts "To remove it use: ./cyber-dojo volume rm #{name}"
    exit 1
  end

  quiet_run("docker volume create --name=#{name} --label=cyber-dojo-volume")
  command = quoted("git clone --depth=1 --branch=master #{url} /data && rm -rf /data/.git")
  run("docker run --rm -v #{name}:/data #{docker_hub_username}/user-base sh -c #{command}")

  puts "TODO: check if that worked. git URL could be wrong."
  puts "TODO: if it is this will still create a volume but with nothing in it."
  puts "TODO: add details to top-level manifest"
  puts "TODO:    type: languages/exercises/instructions"
  puts "TODO:    columns: [ 'lhs', 'rhs' ]"
end

# - - - - - - - - - - - - - - -

def volume_rm
  # Are you allowed to delete the default volumes?
  # Yes. This allows you to create a new default (from a given URL) if you want.
  help = [
    '',
    "Use: #{me} volume rm VOL [VOL...]",
    '',
    tab('Removes one or more volumes created with the command'),
    tab("#{me} volume create")
  ]
  if [nil,'help','--help'].include? ARGV[2]
    show(help)
    exit 1
  end
  p "TODO: volume rm..."
  # check the volume exists and is labelled as per the [volume create] command.
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
    show(help)
    exit 1
  end
  p 'TODO: volume ls'
  #filter on label from [volume create]
  #There is no [--filter label=L]  option on [docker volume ls]
  #https://github.com/docker/docker/pull/21567
  #Hmmmm. How to work round that?!
  # How about creating a volume called cyber-dojo-X
  # when you specify a name of X.
end

# - - - - - - - - - - - - - - -

def volume_pull
  help = [
    '',
    "Use: #{me} volume pull VOL [VOL...]",
    '',
    tab('Pulls the docker images named inside the cyber-dojo volumes'),
  ]
  if [nil,'help','--help'].include? ARGV[2]
    show(help)
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
    "Use: #{me} volume inspect VOL [VOL...]",
    '',
    tab('Displays details of the named cyber-dojo volumes'),
  ]
  if [nil,'help','--help'].include? ARGV[2]
    show(help)
    exit 1
  end

  p 'TODO: volume inspect'
  # filter on label from [volume create]
  # docker volume inspect #{name} | grep cyber-dojo-volume
  # Note: this will volume mount the named VOL to find its info
  #       it does not show the details of what volumes are inside the web container.
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# catalog
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$longest_test = ''
$longest_language = ''

def docker_images_pulled
  `docker images`.split("\n").map{ |line| line.split[0] }
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
  line += test + test_spacer + gap
  line += pulled + pulled_spacer + gap
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
  run "docker pull #{docker_hub_username}/#{image}:#{tag}"
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
  #'    pull IMAGE                     Pulls the named docker IMAGE',
  image = ARGV[1]
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

def rm
  #'    rm IMAGE                   Removes a docker image', #pulled language IMAGE',
  image = ARGV[1]
  if languages.include?(image)
    run "docker rmi #{docker_hub_username}/#{image}"
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
    '    clean     Removes dead images',
    '    down      Brings down the server',
    '    pull      Pulls a docker image',
    '    rm        Removes a docker image',
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
  when 'rm'      then rm
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
