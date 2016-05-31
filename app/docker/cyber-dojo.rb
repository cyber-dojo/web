#!/usr/bin/env ruby

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def run(command)
  puts command
  quiet_run(command)
  #TODO: diagnostic if command fails
end

def help
  [
    '',
    "Use: #{me} COMMAND",
    "     #{me} [help]",
    '',
    '    clean    Removes dead images',
    '    down     Brings down the server',
    '    pull     Pulls a docker image',
    '    rm       Removes a docker image',
    '    sh       Shells into the server',
    '    up       Brings up the server',
    '    upgrade  Upgrades the server and languages',
    '    volume   Manage cyber-dojo data volumes',
    '',
  ].join("\n") + "\n"

  #'    pull IMAGE                     Pulls the named docker IMAGE',
  #'    remove IMAGE                   Removes a docker image', #pulled language IMAGE',
  #'    sh [COMMAND]             Shells into the server', #' (and run COMMAND if provided)',
  #'    up [NAME...]             Brings up the server using the default/named volumes',
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def clean
  run "docker images -q -f='dangling=true' | xargs docker rmi --force"
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def up
  return unless languages == []
  puts 'No language images pulled'
  puts 'Pulling a small starting collection of common language images'
  starting = %w( gcc_assert gpp_assert csharp_nunit java_junit python_pytest ruby_mini_test )
  starting.each { |image| pull(image) }
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# volume

def show(lines)
  lines.each { |line| puts line }
end

def volume
  help = [
    '',
    "Use: #{me} volume [COMMAND]",
    '',
    'Commands:',
    minitab('create         Creates a new volume to use with the [up] command'),
    minitab('rm             Removes one or more volumes'),
    minitab('ls             Lists the names of all volumes'),
    minitab('inspect        Displays details of one or more volume'),
    minitab('pull           Pulls all docker images named in one or more volumes'),
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
  # eg name=--git  arg=--git=https://github.com/JonJagger/cyber-dojo-refactoring-exercises.git
  #   ---> https://github.com/JonJagger/cyber-dojo-refactoring-exercises.git

  args = argv.select{ |arg| arg.start_with?(name + '=')}.map{ |arg| arg.split('=')[1] }
  args.size == 1 ? args[0] : nil
end

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
  else
    args = ARGV[2..-1]
    name = get_arg('--name', args)
    url = get_arg('--git', args)
    if name.nil? || url.nil?
      show(help)
    else
      matching = quiet_run("docker volume ls --quiet | grep #{name}")
      already_exists = matching.include? name
      if already_exists
        puts "Cannot create volume #{name} because it already exists."
        puts "To remove it use: ./cyber-dojo volume rm #{name}"
      else
        quiet_run("docker volume create --name=#{name} --label=cyber-dojo-volume")
        command = quoted("git clone --depth=1 --branch=master #{url} /data && rm -rf /data/.git")
        run("docker run --rm -v #{name}:/data #{docker_hub_username}/user-base sh -c #{command}")
      end
    end
  end
end

# - - - - - - - - - - - - - - -

def volume_rm
  help = [
    '',
    "Use: #{me} volume rm VOL [VOL...]",
    '',
    tab('Removes one or more volumes created with the command'),
    tab("#{me} volume create")
  ]
  if [nil,'help','--help'].include? ARGV[2]
    show(help)
  else
    p "do volume rm..."
  end
end

# - - - - - - - - - - - - - - -

def volume_ls
  p 'volume ls'
  #minitab + 'ls                  Lists the names of all volumes',
end

# - - - - - - - - - - - - - - -

def volume_inspect
  p 'volume inspect'
  # was catalog
  #minitab + 'inspect NAME        Shows details of the named volume', #(WAS catalog)
end

# - - - - - - - - - - - - - - -

def volume_pull
  p 'volume pull'
  #minitab + 'pull NAME           ....',
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# catalog

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def pull(image)
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def rm(image)
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

if ARGV.length == 0
  puts help
  exit
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

options = {}
arg = ARGV[0]
container_commands = ['down', 'sh', 'up']
image_commands = ['clean', 'catalog', 'pull', 'rm', 'upgrade']
all_commands = ['--help','help'] + ['volume'] + container_commands + image_commands
if all_commands.include? arg
  options[arg] = true
else
  puts "#{me}: '#{arg}' is not a command."
  puts "See '#{me} --help'."
  exit
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

puts help       if options['--help'] || options['help']
volume          if options['volume']
up              if options['up']

puts catalog    if options['catalog']
clean           if options['clean']
pull(ARGV[1])   if options['pull']
rm(ARGV[1])     if options['rm']
upgrade         if options['upgrade']
