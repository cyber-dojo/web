# See cyber-dojo-model.pdf

class Dojo

  def languages; @languages ||= StartPoints.new(self, 'languages_root'); end
  def exercises; @exercises ||=   Exercises.new(self, 'exercises_root'); end
  def    custom; @custom    ||= StartPoints.new(self,    'custom_root'); end

  def     katas; @katas ||= Katas.new(self); end

  include Externals

end
