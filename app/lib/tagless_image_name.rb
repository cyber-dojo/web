
module TaglessImageName # mix-in

  module_function

  def tagless_image_name(image_name)
    # http://stackoverflow.com/questions/37861791
    # A full implementation of parsing the image_name is in
    # https://github.com/cyber-dojo/commander/blob/master/start_point_checker.rb
    i = image_name.index('/')
    if i.nil? || i == -1 || (
        !image_name[0...i].include?('.') &&
        !image_name[0...i].include?(':') &&
         image_name[0...i] != 'localhost')
      hostname = ''
      return split_remote_name(image_name)[:name]
    else
      hostname = image_name[0..i-1]
      remote_name = image_name[i+1..-1]
      return hostname + '/' + split_remote_name(remote_name)[:name]
    end
  end

  # - - - - - - - - - - - - - - - - - -

  def split_remote_name(remote_name)
    alpha_numeric = '[a-z0-9]+'
    separator = '([.]{1}|[_]{1,2}|[-]+)'
    component = "#{alpha_numeric}(#{separator}#{alpha_numeric})*"
    name = "#{component}(/#{component})*"
    tag = '[\w][\w.-]{0,126}'
    md = /^(#{name})(:(#{tag}))?$/.match(remote_name)
    fail ArgumentError.new('image_name:invalid') if md.nil?
    { name:md[1], tag:md[8] || '' }
  end

end
