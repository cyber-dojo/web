# frozen_string_literal: true
require_relative 'cleaner'

module FilesFrom # mix-in

  def files_from(file_content)
    files = cleaned_files(file_content)
    files.delete('output')
    files.each.with_object({}) do |(filename,content),memo|
      memo[filename] = { 'content' => sanitized(content) }
    end
  end

  def sanitized(content)
    max_file_size = 50 * 1024
    content[0...max_file_size]
  end

  include Cleaner

end
