#!/usr/bin/env ruby

# Shows details of the start-point volume that has been mounted to path.
# Not (necessarily) related to the details of what start-point volumes are
# inside the running web container.

require 'json'

def failed; 1; end

def path; ARGV[0]; end

def show_use(message = '')
  STDERR.puts
  STDERR.puts 'USE: start_point_inspect.rb PATH'
  STDERR.puts
  STDERR.puts "   ERROR: #{message}" if message != ''
  STDERR.puts
end

$longest_test     = ''
$longest_language = ''
$longest_image    = ''

def max_size(lhs, rhs)
  lhs.size > rhs.size ? lhs : rhs
end

def spacer(longest, name)
  ' ' * (longest.size - name.size)
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def inspect_line(language, test, image, pulled)
  language_spacer = spacer($longest_language, language)
      test_spacer = spacer($longest_test    , test    )
     image_spacer = spacer($longest_image   , image   )
  gap = ' ' * 3
  line = ''
  line += language + language_spacer + gap
  line +=     test +     test_spacer + gap
  line +=    image +    image_spacer + gap
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
    $longest_language = max_size($longest_language, language  )
    $longest_test     = max_size($longest_test    , test      )
    $longest_image    = max_size($longest_image   , image_name)
    hash[language] ||= {}
    hash[language][test] = {
      'image_name' => image_name,
      'pulled' => pulled.include?(image_name) ? 'yes' : 'no'
    }
  end
  hash
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def setup
  content = IO.read("#{path}/setup.json")
  JSON.parse(content)
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if path.nil?
  show_use
  exit failed
end

if !File.directory?(path)
  show_use "#{path} not found"
  exit failed
end

major_name = 'MAJOR_NAME'
minor_name = 'MINOR_NAME'
image_name = 'IMAGE_NAME'

$longest_language = max_size($longest_language, major_name)
$longest_test     = max_size($longest_test    , minor_name)
$longest_image    = max_size($longest_image   , image_name)
inspection = inspect_from_manifests

puts inspect_line(major_name, minor_name, image_name, 'PULLED?')
inspection.sort.map do |major,minors|
  minors.sort.map do |minor, hash|
    puts inspect_line(major, minor, hash['image_name'], hash['pulled'])
  end
end
