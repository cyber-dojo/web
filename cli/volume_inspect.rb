#!/usr/bin/env ruby

# Shows details of the volume that has been mounted to path.
# Does *not* (necessarily) show the details of what volumes are
# inside the running web container.

# TODO: shows whether image is marked pull-on-use or not

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

$longest_test     = ''
$longest_language = ''
$longest_image    = ''
$longest_auto     = ''

def max_size(lhs, rhs)
  lhs.size > rhs.size ? lhs : rhs
end

def spacer(longest, name)
  ' ' * (longest.size - name.size)
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def inspect_line(language, test, image, auto, pulled)
  language_spacer = spacer($longest_language, language)
      test_spacer = spacer($longest_test    , test    )
     image_spacer = spacer($longest_image   , image   )
      auto_spacer = spacer($longest_auto    , auto    )
  gap = ' ' * 3
  line = ''
  line += language + language_spacer + gap
  line +=     test +     test_spacer + gap
  line +=    image +    image_spacer + gap
  line +=     auto +     auto_spacer + gap
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
    auto_pull = manifest['auto_pull'] || 'false'
    $longest_language = max_size($longest_language, language  )
    $longest_test     = max_size($longest_test    , test      )
    $longest_image    = max_size($longest_image   , image_name)
    $longest_auto     = max_size($longest_auto    , auto_pull)
    hash[language] ||= {}
    hash[language][test] = {
      'image_name' => image_name,
      'auto_pull' => auto_pull,
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

lhs_column_name = setup['lhs_column_name']
rhs_column_name = setup['rhs_column_name']

$longest_language = max_size($longest_language, lhs_column_name)
$longest_test     = max_size($longest_test    , rhs_column_name)
$longest_image    = max_size($longest_image   , 'IMAGE')
$longest_auto     = max_size($longest_auto    , 'AUTO_PULL')
inspection = inspect_from_manifests

puts inspect_line(lhs_column_name.upcase, rhs_column_name.upcase, 'IMAGE', 'AUTO_PULL', 'PULLED')
inspection.sort.map do |language,tests|
  tests.sort.map do |test, hash|
    image = hash['image_name']
    pulled = hash['pulled']
    auto = hash['auto_pull']
    puts inspect_line(language, test, image, auto, pulled)
  end
end
