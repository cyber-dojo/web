
module Cleaner # mix-in

  module_function

  def cleaned_files(files)
    # If files is a Rails ActionController::Parameters then
    # you can't do a .map or .to_h on it, so using .each
    cleaned = {}
    files.each do |filename, content|
      content = cleaned_string(content)
      content = content.gsub(/\r\n/, "\n")
      cleaned[filename] = content
    end
    cleaned
  end

  def cleaned_string(s)
    # force an encoding change
    # if encoding is already utf-8
    # then encoding to utf-8 is a no-op and
    # invalid byte sequences are not detected.
    s = s.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    s = s.encode('UTF-8', 'UTF-16')
  end

end

# http://robots.thoughtbot.com/fight-back-utf-8-invalid-byte-sequences
