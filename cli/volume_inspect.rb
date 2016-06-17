#!/usr/bin/env ruby

def failed; 1; end

def show_use(message = '')
  puts
  puts 'USE: volume_inspect.rb PATH'
  puts
  #puts 'Checks PATH is suitable to create a cyber-dojo volume from.'
  #puts
  puts "   ERROR: #{message}" if message != ''
  puts
end

path = ARGV[0]

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
#
# use globbing as per line 359
# shows whether image has been pulled or not
# shows whether image is auto-pull or not
