#!/usr/bin/env ruby
# frozen_string_literal: true

# -h  Show this help

if ARGV.include?('-h') || ARGV.size != 1
  puts <<~HELP
    Usage: ruby bin/merge_tgz.rb BASE_TGZ < ADDED_TGZ > MERGED_TGZ

    Writes to stdout a tgz holding every entry of BASE_TGZ followed by every
    entry of the tgz read from stdin. Plain Ruby, so it behaves the same with
    macOS's bsdtar and Linux's GNU tar installed, and never unpacks either
    archive to disk (where macOS's case-insensitive filesystem would merge
    case-distinct dirs, eg katas/Ks and katas/ks).

    Example:
      ruby bin/merge_tgz.rb test/data/saver_data.v2.tgz < group.tgz > merged.tgz
  HELP
  exit(ARGV.include?('-h') ? 0 : 1)
end

require 'zlib'

BLOCK_SIZE = 512

# True for the all-zero block that marks a tar archive's end.
def end_of_archive?(block)
  block.nil? || block.bytes.all?(&:zero?)
end

# Copies every block of the archive in gz_in to gz_out, up to but excluding
# its end-of-archive marker, so another archive's blocks can follow.
def copy_entries(gz_in, gz_out)
  loop do
    block = gz_in.read(BLOCK_SIZE)
    break if end_of_archive?(block)

    gz_out.write(block)
    size = block[124, 12].strip.to_i(8)
    data_blocks = (size + BLOCK_SIZE - 1) / BLOCK_SIZE
    gz_out.write(gz_in.read(data_blocks * BLOCK_SIZE)) if data_blocks.positive?
  end
end

$stdin.binmode
$stdout.binmode
gz_out = Zlib::GzipWriter.new($stdout)
File.open(ARGV[0], 'rb') do |base|
  copy_entries(Zlib::GzipReader.new(base), gz_out)
end
copy_entries(Zlib::GzipReader.new($stdin), gz_out)
gz_out.write("\0" * BLOCK_SIZE * 2)
gz_out.close
