
module TaglessImageName # mix-in

  module_function

  def stripped_image_name(image_name)
    # removes hostname, tag, digest
    # eg quay.io:80/cdf/gcc_assert:latest@sha2-s1+s2.s3_s5:1234...
    # hostname quay.io:80/ is stripped
    # tag :latest is stripped
    # digest @sha2-s1+s2.s3_s5:1234... is stripped
    # --> cdf/gcc_assert
    split_image_name(image_name)[:name]
  end

  # - - - - - - - - - - - - - - - - - -

  def split_image_name(image_name)
    # http://stackoverflow.com/questions/37861791
    # A full implementation of parsing the image_name is in
    # https://github.com/cyber-dojo/commander/blob/master/start_point_checker.rb
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

    digest_component = '[A-Za-z][A-Za-z0-9]*'
    digest_separator = '[-_+.]'
    digest_algorithm = "#{digest_component}(#{digest_separator}#{digest_component})*"
    digest_hex = "[0-9a-fA-F]{32,}"
    digest = "#{digest_algorithm}[:]#{digest_hex}"
    alpha_numeric = '[a-z0-9]+'
    separator = '([.]{1}|[_]{1,2}|[-]+)'
    component = "#{alpha_numeric}(#{separator}#{alpha_numeric})*"
    name = "#{component}(/#{component})*"
    tag = '[\w][\w.-]{0,126}'
    md = /^(#{name})(:(#{tag}))?(@#{digest})?$/.match(remote_name)

    fail ArgumentError.new('image_name:invalid') if md.nil?

    {
      hostname:hostname,
      name:md[1],
      tag:md[8] || '',
    }
  end

  # - - - - - - - - - - - - - - - - - -

  def stripped_remote_name(remote_name)
    digest_component = '[A-Za-z][A-Za-z0-9]*'
    digest_separator = '[-_+.]'
    digest_algorithm = "#{digest_component}(#{digest_separator}#{digest_component})*"
    digest_hex = "[0-9a-fA-F]{32,}"
    digest = "#{digest_algorithm}[:]#{digest_hex}"

    alpha_numeric = '[a-z0-9]+'
    separator = '([.]{1}|[_]{1,2}|[-]+)'
    component = "#{alpha_numeric}(#{separator}#{alpha_numeric})*"
    name = "#{component}(/#{component})*"
    tag = '[\w][\w.-]{0,126}'

    md = /^(#{name})(:(#{tag}))?(@#{digest})?$/.match(remote_name)
    fail ArgumentError.new('image_name:invalid') if md.nil?
    md[1]
  end

end
