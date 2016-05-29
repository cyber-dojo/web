#!/usr/bin/env ruby

require 'json'

def me; 'cyber-dojo'; end

def my_dir; File.expand_path(File.dirname(__FILE__)); end

def docker_hub_username; 'cyberdojofoundation'; end

def docker_version; ENV['DOCKER_VERSION']; end

def home; '/usr/src/cyber-dojo'; end  # home folder *inside* the server image

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def help
  [
    '',
    "Use: #{me} COMMAND",
    "     #{me} [help]",
    '',
    '     create-collection NAME=URL  Creats a collection named NAME from URL',
  # '     list-collection NAME',
  # '     pull-collection NAME        Pulls all the docker IMAGES in collection named NAME',
  # '     up use-collection NAME      Starts the server using the named collection',
    '',
    '     down                        Stops the server',
    '     sh [COMMAND]                Shell into the server',
    '     up                          Starts the server using the default collections',
    '',
  #  '     catalog                     Lists all language images',
    '     clean                       Deletes dead images',
    '     pull IMAGE                  Pulls the named docker IMAGE',
#    '     pull all                    Pulls one language IMAGE or all images',
#
    '     remove IMAGE                Removes a pulled language IMAGE',
    '     upgrade                     Pulls the latest server and language images',
    ''
  ].join("\n") + "\n"
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def run(command)
  puts command
  `#{command}`
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
# catalog

def docker_images_pulled
  `docker images`.split("\n").map{ |line| line.split[0] }
  # cyberdojofoundation/visual-basic_nunit   latest  eb5f54114fe6 4 months ago 497.4 MB
  # cyberdojofoundation/ruby_mini_test       latest  c7d7733d5f54 4 months ago 793.4 MB
  # cyberdojofoundation/ruby_rspec           latest  ce9425d1690d 4 months ago 411.2 MB
  # -->
  # cyberdojofoundation/visual-basic_nunit
  # cyberdojofoundation/ruby_mini_test
  # cyberdojofoundation/ruby_rspec
  # ...
end

def docker_images_from_manifests
  pulled = docker_images_pulled
  hash = {}
  Dir.glob("#{languages_home}/**/manifest.json") do |file|
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

def languages_home
  File.expand_path('../data/languages', File.dirname(__FILE__))
end

def max_size(lhs, rhs)
  lhs.size > rhs.size ? lhs : rhs
end

def spacer(longest, name)
  ' ' * (longest.size - name.size)
end

$longest_test = ''
$longest_language = ''

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
  all = docker_images_from_manifests
  lines = []
  lines << catalog_line('LANGUAGE', 'TESTS', 'PULLED', 'IMAGE')
  all.sort.map do |language,tests|
    tests.sort.map do |test, hash|
      lines << catalog_line(language, test, hash['pulled'], hash['image'])
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

def images
  pulled = all_docker_images
  all = catalog.split("\n")
  heading = [ all.shift ]
  languages = all.select do |line|
    image = line.split[-1]
    pulled.include? image
  end
  (heading + languages).join("\n")
  # LANGUAGE          TESTS                IMAGE
  # Asm               assert               cyberdojofoundation/nasm_assert
  # C (gcc)           assert               cyberdojofoundation/gcc_assert
  # F#                NUnit                cyberdojofoundation/fsharp_nunit
  # Go                testing              cyberdojofoundation/go_testing
end

def languages
  images.split("\n").drop(1).map { |line| line.split[-1] }
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

def remove(image)
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
arg = ARGV[0].to_sym
container_commands = [:down, :restart, :sh, :up]
image_commands = [:clean, :catalog, :images, :pull, :remove, :upgrade]
all_commands = [:help] + container_commands + image_commands
if all_commands.include? arg
  options[arg] = true
else
  puts "#{me}: #{arg} ?"
  puts "Try '#{me} help"
  exit
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

puts help       if options[:help]
up              if options[:up]

puts catalog    if options[:catalog]
clean           if options[:clean]
puts images     if options[:images]
pull(ARGV[1])   if options[:pull]
remove(ARGV[1]) if options[:remove]
upgrade         if options[:upgrade]
