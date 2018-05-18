
module HiddenFileRemover

  def remove_hidden_files(files, hidden_regexps)
    return if hidden_regexps == []
    re = Regexp.new(hidden_regexps.map{ |s| "(#{s})" }.join('|'))
    hidden = files.keys.select { |filename| filename =~ re }
    hidden.each { |filename| files.delete(filename) }
  end

end