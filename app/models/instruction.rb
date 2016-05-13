
class Instruction

  def initialize(instructions, dir_name, text = nil)
    @instructions = instructions
    @name = dir_name
    @text = text
  end

  attr_reader :name

  def parent
    @instructions
  end

  def path
    parent.path + '/' + name
  end

  def text
    @text || disk[path].read(filename)
  end

  private

  include ExternalParentChainer

  def filename
    'instructions'
  end

end
