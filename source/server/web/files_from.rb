require_relative 'cleaner'

module Web
  module FilesFrom # mix-in
    def files_from(file_content)
      files = cleaned_files(file_content)
      # The editor gives the 'output' textarea no name, so a current browser
      # leaves it out of the upload. A browser holding an earlier cached copy
      # of the javascript still posts it, and this delete is what keeps that
      # content out of the runner and out of the saved files. It can go once
      # no client posts 'output'.
      files.delete('output')
      files.each.with_object({}) do |(filename, content), memo|
        memo[filename] = { 'content' => sanitized(content) }
      end
    end

    def sanitized(content)
      max_file_size = 50 * 1024
      content[0...max_file_size]
    end

    include Cleaner
  end
end
