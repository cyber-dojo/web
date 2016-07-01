#!/usr/bin/env ruby

# Pulls all docker images named in manifest.json files below path.

# TODO: make the output of the [docker pull] command appear on the terminal

require 'json'

def failed; 1; end

def path; ARGV[0]; end

def show_use(message = '')
  STDERR.puts
  STDERR.puts 'USE: volume_pull.rb PATH'
  STDERR.puts
  STDERR.puts "   ERROR: #{message}" if message != ''
  STDERR.puts
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def inspect_from_manifests
  hash = {}
  Dir.glob("#{path}/**/manifest.json").each do |filename|
    content = IO.read(filename)
    manifest = JSON.parse(content)
    language, test = manifest['display_name'].split(',').map { |s| s.strip }
    image_name = manifest['image_name']
    hash[language] ||= {}
    hash[language][test] = { 'image_name' => image_name }
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

inspect_from_manifests.sort.map do |language,tests|
  tests.sort.map do |test, hash|
    image = hash['image_name']
    puts "PULLING #{image} (#{language}, #{test})"
    system("docker pull #{image}")
  end
end
