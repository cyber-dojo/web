# frozen_string_literal: true
require_relative '../../app/services/saver_service'

class SaverFake

  def initialize(externals)
    @externals = externals
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

  def dir_make_command(dirname)
    saver.dir_make_command(dirname)
  end

  def dir_exists_command(dirname)
    saver.dir_exists_command(dirname)
  end

  def file_create_command(filename, content)
    saver.file_create_command(filename, content)
  end

  def file_append_command(filename, content)
    saver.file_append_command(filename, content)
  end

  def file_read_command(filename)
    saver.file_read_command(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

=begin
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
=end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def assert(command)
    append_log(['assert',command])
    result = run(command)
    if result
      result
    else
      raise "command != true"
    end
  end

  def run(command)
    name,*args = command
    case name
    when 'create'  then create(*args)
    when 'exists?' then exists?(*args)
    when 'write'   then write(*args)
    when 'append'  then append(*args)
    when 'read'    then read(*args)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_all(commands)
    append_log(['assert_all',commands.size])
    run_until(commands) {|r,index|
      if r
        false
      else
        raise SaverService::Error, "commands[#{index}] != true"
      end
    }
  end

  def run_all(commands)
    append_log(['run_all',commands.size])
    run_until(commands) {|r| r === :never }
  end

  def run_until_true(commands)
    run_until(commands) {|r| r}
  end

  def run_until_false(commands)
    run_until(commands) {|r| !r}
  end

  private

  def run_until(commands, &block)
    results = []
    commands.each.with_index(0) do |command,index|
      result = run(command)
      results << result
      break if block.call(result,index)
    end
    results
  end

  def append_log(info)
    @@log << info
  end

  # - - - - - - - - - - - - - - - - - -

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

  def write(key,value)
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

  def read(key)
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

  def saver
    SaverService.new(@externals)
  end

end
