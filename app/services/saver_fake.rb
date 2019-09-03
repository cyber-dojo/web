# frozen_string_literal: true

class SaverFake

  def initialize(_externals)
    @@dirs ||= {}
    @@files ||= {}
  end

  def sha
    '71333653be9b1ca2c31f83810d4e6f128817deac'
  end

  def ready?
    true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def exists?(key)
    dir?(path_name(key))
  end

  def create(key)
    if exists?(key)
      false
    else
      @@dirs[path_name(key)] = true
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(key, value)
    path = path_name(key)
    if dir?(File.dirname(path)) && !file?(path)
      @@files[path] = value
      true
    else
      false
    end
  end

  def append(key, value)
    path = path_name(key)
    if dir?(File.dirname(path)) && file?(path)
      @@files[path] += value
      true
    else
      false
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def read(key)
    @@files[path_name(key)]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def batch(commands)
    results = []
    commands.each do |command|
      name,*args = command
      result = case name
      when 'create'  then create(*args)
      when 'exists?' then exists?(*args)
      when 'write'   then write(*args)
      when 'append'  then append(*args)
      when 'read'    then read(*args)
      #TODO: else raise...
      end
      results << result
    end
    results
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def path_name(key)
    File.join('', 'tmp', 'cyber-dojo', key)
  end

  def dir?(key)
    @@dirs.has_key?(key)
  end

  def file?(key)
    @@files.has_key?(key)
  end

end
