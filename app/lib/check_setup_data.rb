#!/usr/bin/env ruby

require_relative './setup_data_checker'

def show_use(message = '')
  puts
  puts 'USE: check_setup_data.rb PATH'
  puts
  puts 'Checks PATH is suitable to create a cyber-dojo volume from.'
  puts
  puts "   ERROR: #{message}" if message != ''
  puts
end

path = ARGV[0]

if path.nil?
  show_use
  exit 1
end

if !File.directory?(path)
  show_use "#{path} not found"
  exit
end

checker = SetupDataChecker.new(path)
count = 0
checker.check.each do |filename, messages|
  count += messages.size
  messages.each { |message| puts filename + ': ' + message }
end

exit count
