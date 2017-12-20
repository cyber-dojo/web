
class Dojo

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def katas
    @katas ||= Katas.new(self)
  end

end
