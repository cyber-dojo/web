
class Dojo

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def languages
    @languages ||= StartPoints.new(self, 'languages_root')
  end

  def custom
    @custom ||= StartPoints.new(self, 'custom_root')
  end

  def katas
    @katas ||= Katas.new(self)
  end

end
