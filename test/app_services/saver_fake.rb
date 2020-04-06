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

  def ready?
    append_log(['ready?'])
    true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def create_command(dirname)
    ['create',dirname]
  end

  def exists_command(dirname)
    ['exists?',dirname]
  end

  def write_command(filename, content)
    ['write',filename,content]
  end

  def append_command(filename, content)
    ['append',filename,content]
  end

  def read_command(filename)
    ['read',filename]
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

  def assert(command)
    append_log(['assert',command])
    result = execute(command)
    if result
      result
    else
      raise "command != true"
    end
  end

  def batch_assert(commands)
    append_log(['batch_assert',commands.size])
    batch_until(commands) {|r,index|
      if r
        false
      else
        raise SaverService::Error, "commands[#{index}] != true"
      end
    }
  end

  def batch(commands)
    append_log(['batch',commands.size])
    batch_until(commands) {|r| r === :never }
  end

  def batch_until_true(commands)
    batch_until(commands) {|r| r}
  end

  def batch_until_false(commands)
    batch_until(commands) {|r| !r}
  end

  private

  def execute(command)
    name,*args = command
    case name
    when 'create'  then do_create(*args)
    when 'exists?' then do_exists?(*args)
    when 'write'   then do_write(*args)
    when 'append'  then do_append(*args)
    when 'read'    then do_read(*args)
    end
  end

  def batch_until(commands, &block)
    results = []
    commands.each.with_index(0) do |command,index|
      result = execute(command)
      results << result
      break if block.call(result,index)
    end
    results
  end

  def append_log(info)
    @@log << info
  end

  # - - - - - - - - - - - - - - - - - -

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
