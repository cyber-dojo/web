#!/usr/bin/env ruby

require_relative './../app/lib/setup_data_checker'

def failed; 1; end

def path; ARGV[0]; end

def show_use(message = '')
  STDERR.puts
  STDERR.puts 'USE: volume_check.rb PATH'
  STDERR.puts
  STDERR.puts 'Checks PATH is suitable to create a cyber-dojo volume from.'
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

hash = SetupDataChecker.new(path).check
error_count = hash.values.reduce(:+).size
STDERR.puts "FAILED..." unless error_count == 0
hash.each do |filename, messages|
  messages.each { |message| STDERR.puts filename + ': ' + message }
end
exit error_count
