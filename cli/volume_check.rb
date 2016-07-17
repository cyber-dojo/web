#!/usr/bin/env ruby

require_relative './../app/lib/start_point_checker'

def failed; 1; end

def path; ARGV[0]; end

def show_use(message = '')
  STDERR.puts
  STDERR.puts 'USE: volume_check.rb PATH'
  STDERR.puts
  STDERR.puts 'Checks if PATH is suitable to create a cyber-dojo start-point volume from.'
  STDERR.puts
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

hash = StartPointChecker.new(path).check
error_count = hash.reduce(0) { |memo,(_,messages)| memo + messages.length }
STDERR.puts "FAILED..." unless error_count == 0
hash.each do |filename, messages|
  messages.each { |message| STDERR.puts filename + ': ' + message }
end
exit error_count
