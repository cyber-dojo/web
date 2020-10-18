# frozen_string_literal: true
require_relative '../../app/services/saver_service'

class SaverWithLogging

  def initialize(externals)
    @externals = externals
    @@log ||= []
  end

  def log
    @@log
  end

  def ready?
    saver.ready?
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

  def assert(command)
    append_log(['assert',command])
    saver.assert(command)
  end

  def run(command)
    append_log(['run',command])
    saver.run(command)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_all(commands)
    append_log(['assert_all',commands.size])
    saver.assert_all(commands)
  end

  def run_all(commands)
    append_log(['run_all',commands.size])
    saver.run_all(commands)
  end

  def run_until_true(commands)
    append_log(['run_until_true',commands.size])
    saver.run_until_true(commands)
  end

  def run_until_false(commands)
    append_log(['run_until_false',commands.size])
    saver.run_until_false(commands)
  end

  private

  def append_log(info)
    @@log << info
  end

  def saver
    SaverService.new(@externals)
  end

end
