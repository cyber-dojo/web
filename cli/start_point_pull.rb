#!/usr/bin/env ruby

# Pulls all docker images named in manifest.json files below path.

require 'json'

def failed; 1; end

def path; ARGV[0]; end

def show_use(message = '')
  STDERR.puts
  STDERR.puts 'USE: start_point_pull.rb PATH'
  STDERR.puts
  STDERR.puts "   ERROR: #{message}" if message != ''
  STDERR.puts
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def manifests_hash
  hash = {}
  Dir.glob("#{path}/**/manifest.json").each do |filename|
    content = IO.read(filename)
    manifest = JSON.parse(content)
    major, minor = manifest['display_name'].split(',').map { |s| s.strip }
    image_name = manifest['image_name']
    hash[major] ||= {}
    hash[major][minor] = { 'image_name' => image_name }
  end
  hash
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

manifests_hash.sort.map do |major,minors|
  minors.sort.map do |minor, hash|
    image = hash['image_name']
    puts "PULLING #{image} (#{major}, #{minor})"
    system("docker pull #{image}")
  end
end
