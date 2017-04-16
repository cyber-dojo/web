
module ImageNameSplitter # mix-in

  module_function

  def split_image_name(image_name)
    # http://stackoverflow.com/questions/37861791
    i = image_name.index('/')
    if i.nil? || i == -1 || (
        !image_name[0...i].include?('.') &&
        !image_name[0...i].include?(':') &&
         image_name[0...i] != 'localhost')
      hostname = ''
      remote_name = image_name
    else
      hostname = image_name[0..i-1]
      remote_name = image_name[i+1..-1]
    end
    hostname_port = split_hostname(hostname)
    name_tag = split_remote_name(remote_name)
    hostname_port.merge(name_tag)
  end

  # - - - - - - - - - - - - - - - - - -

  def split_hostname(hostname)
    return { hostname:'', port:'' } if hostname == ''
    port = '[\d]+'
    component = "([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])"
    md = /^(#{component}(\.#{component})*)(:(#{port}))?$/.match(hostname)
    fail ArgumentError.new('image_name:invalid') if md.nil?
    { hostname:md[1], port:md[6] || '' }
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
