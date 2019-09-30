# frozen_string_literal: true

class SaverFake

  def initialize(_externals)
    @@dirs ||= {}
    @@files ||= {}
    @@log ||= []
  end

  def log
    @@log
  end

  def sha
    append_log(['sha'])
    '71333653be9b1ca2c31f83810d4e6f128817deac'
  end

  def ready?
    append_log(['ready?'])
    true
  end

  def alive?
    append_log(['alive?'])
    true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def exists?(key)
    append_log(['exists?',key])
    do_exists?(key)
  end

  def create(key)
    append_log(['create',key])
    do_create(key)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(key, value)
    append_log(['write',key])
    do_write(key, value)
  end

  def append(key, value)
    append_log(['append',key])
    do_append(key, value)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def read(key)
    append_log(['read',key])
    do_read(key)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def batch(commands)
    append_log(['batch',commands.size])
    results = []
    commands.each do |command|
      name,*args = command
      result = case name
      when 'exists?' then do_exists?(*args)
      when 'create'  then do_create(*args)
      when 'write'   then do_write(*args)
      when 'append'  then do_append(*args)
      when 'read'    then do_read(*args)
      #TODO: else raise...
      end
      results << result
    end
    results
  end

  private

  def append_log(info)
    @@log << info
  end

  def do_exists?(key)
    dir?(path_name(key))
  end

  def do_create(key)
    if exists?(key)
      false
    else
      @@dirs[path_name(key)] = true
    end
  end

  def do_write(key,value)
    path = path_name(key)
    if dir?(File.dirname(path)) && !file?(path)
      @@files[path] = value
      true
    else
      false
    end
  end

  def do_append(key, value)
    path = path_name(key)
    if dir?(File.dirname(path)) && file?(path)
      @@files[path] += value
      true
    else
      false
    end
  end

  def do_read(key)
    @@files[path_name(key)] || false
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
