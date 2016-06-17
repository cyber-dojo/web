#!/usr/bin/env ruby

def failed; 1; end

def show_use(message = '')
  STDERR.puts
  STDERR.puts 'USE: volume_inspect.rb PATH'
  STDERR.puts
  #puts 'Checks PATH is suitable to create a cyber-dojo volume from.'
  #puts
  STDERR.puts "   ERROR: #{message}" if message != ''
  STDERR.puts
end

def path
  ARGV[0]
end

if path.nil?
  show_use
  exit failed
end

if !File.directory?(path)
  show_use "#{path} not found"
  exit failed
end

p "TODO: ./cyber-dojo volume inspect #{path}"

# does *not* show the details of what volumes are inside the running web container.
# use globbing
# Dir.glob("#{path}/**/manifest.json").each do |filename|
#
# shows whether image has been pulled or not
# shows whether image is auto-pull or not
