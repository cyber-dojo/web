#!/usr/bin/env ruby

# Shows details of the volume that has been mounted to path.
# Does *not* (necessarily) show the details of what volumes are
# inside the running web container.

# TODO: shows whether image has been pulled or not?
# TODO: shows whether image is auto-pull or not?
# TODO: change name of catalog_line()

require 'json'

def failed; 1; end

def path; ARGV[0]; end

def show_use(message = '')
  STDERR.puts
  STDERR.puts 'USE: volume_inspect.rb PATH'
  STDERR.puts
  #puts 'Checks PATH is suitable to create a cyber-dojo volume from.'
  #puts
  STDERR.puts "   ERROR: #{message}" if message != ''
  STDERR.puts
end

if path.nil?
  show_use
  exit failed
end

if !File.directory?(path)
  show_use "#{path} not found"
  exit failed
end

$longest_test = ''
$longest_language = ''
$longest_image_name = ''

def max_size(lhs, rhs)
  lhs.size > rhs.size ? lhs : rhs
end

def spacer(longest, name)
  ' ' * (longest.size - name.size)
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def catalog_line(language, test, image, pulled)
  language_spacer = spacer($longest_language, language)
  test_spacer = spacer($longest_test, test)
  image_spacer = spacer($longest_image_name, image)
  gap = ' ' * 3
  line = ''
  line += language + language_spacer + gap
  line += test     + test_spacer     + gap
  line += image    + image_spacer   + gap
  line += pulled
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def docker_images_pulled
  `docker images`.split("\n").drop(1).map{ |line| line.split[0] }.sort - ['<none>']
  # eg
  # REPOSITORY                               TAG     IMAGE ID     CREATED      SIZE
  # cyberdojofoundation/visual-basic_nunit   latest  eb5f54114fe6 4 months ago 497.4 MB
  # cyberdojofoundation/ruby_mini_test       latest  c7d7733d5f54 4 months ago 793.4 MB
  # cyberdojofoundation/ruby_rspec           latest  ce9425d1690d 4 months ago 411.2 MB
  # -->
  # cyberdojofoundation/visual-basic_nunit
  # cyberdojofoundation/ruby_mini_test
  # cyberdojofoundation/ruby_rspec
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def inspect_from_manifests
  hash = {}
  pulled = docker_images_pulled
  Dir.glob("#{path}/**/manifest.json").each do |filename|
    content = IO.read(filename)
    manifest = JSON.parse(content)
    language, test = manifest['display_name'].split(',').map { |s| s.strip }
    image_name = manifest['image_name']
    $longest_language = max_size($longest_language, language)
    $longest_test = max_size($longest_test, test)
    $longest_image_name = max_size($longest_image_name, image_name)
    hash[language] ||= {}
    hash[language][test] = {
      'image_name' => image_name,
      'pulled' => pulled.include?(image_name) ? 'yes' : 'no'
    }
  end
  hash
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

lines = []
# TODO: these will have to come from setup.json
# TODO: thse also affect $longest_test and $longest_language
#lines << catalog_line('LANGUAGE', 'TESTS', 'IMAGE')
inspect_from_manifests.sort.map do |language,tests|
  tests.sort.map do |test, hash|
    image_name = hash['image_name']
    pulled = hash['pulled']
    puts catalog_line(language, test, image_name, pulled)
  end
end
