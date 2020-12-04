# frozen_string_literal: true
require_relative 'id_pather'
require_relative 'runner'

class Kata

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def id
    @params[:id]
  end

  def exists?
    id?(id) && model.kata_exists?(id)
  end

  def manifest
    @manifest ||= model.kata_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def run_tests(params = @params)
    Runner.new(@externals).run(params)
  end

  def events
    model.kata_events(id)
  end

  def event(index)
    model.kata_event(id, index)
  end

  # - - - - - - - - - - - - - - - - -

  def theme=(value)
    # value == 'dark'|'light'
    filename = kata_id_path(id, 'theme')
    saver.run_all([
      saver.file_create_command(filename, "\n"+value),
      saver.file_append_command(filename, "\n"+value)
    ])
  end

  def theme
    filename = kata_id_path(id, 'theme')
    result = saver.run(saver.file_read_command(filename))
    if result
      result.lines.last
    else
      'light' # default, better on projectors (other option is 'dark')
    end
  end

  # - - - - - - - - - - - - - - - - -

  def colour=(value)
    # value == 'on'|'off'
    filename = kata_id_path(id, 'colour')
    saver.run_all([
      saver.file_create_command(filename, "\n"+value),
      saver.file_append_command(filename, "\n"+value)
    ])
  end

  def colour
    filename = kata_id_path(id, 'colour')
    result = saver.run(saver.file_read_command(filename))
    if result
      result.lines.last
    else
      'on' # default (other option is 'off')
    end
  end

  # - - - - - - - - - - - - - - - - -

  def predict
    filename = kata_id_path(id, 'predict')
    result = saver.run(saver.file_read_command(filename))
    if result
      result.lines.last
    else
      'off' # default (other options in 'on')
    end
  end

  def predict=(value)
    # value == 'on'|'off'
    filename = kata_id_path(id, 'predict')
    saver.run_all([
      saver.file_create_command(filename, "\n"+value),
      saver.file_append_command(filename, "\n"+value)
    ])
  end

  private

  ALPHABET = %w{
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
    a b c d e f g h   j k l m n   p q r s t u v w x y z
  }.join.freeze

  include IdPather

  def id?(s)
    s.is_a?(String) &&
      s.length === 6 &&
        s.chars.all?{ |ch| ALPHABET.include?(ch) }
  end

  def model
    @externals.model
  end

  def saver
    @externals.saver
  end

end
