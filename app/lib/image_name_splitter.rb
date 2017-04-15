
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

    alpha_numeric = '[a-z0-9]+'
    separator = '([.]{1}|[_]{1,2}|[-]+)'
    component = "#{alpha_numeric}(#{separator}#{alpha_numeric})*"
    name = "#{component}(/#{component})*"
    tag = '[\w][\w.-]{0,126}'
    md = /^(#{name})(:(#{tag}))?$/.match(remote_name)

    fail ArgumentError.new('image_name:invalid') if md.nil?

    {
      hostname:hostname,
      name:md[1],
      tag:md[8] || ''
    }
  end

end
