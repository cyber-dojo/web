
class Exercise

  def initialize(exercises, dir_name, text = nil)
    @exercises = exercises
    @dir_name = dir_name
    @text = text
  end

  def name
    path.split('/')[-1]
  end

  def parent
    @exercises
  end

  def path
    @dir_name
  end

  def text
    @text ||= disk[path].read(filename)
  end

  private

  def filename
    'instructions'
  end

  include NearestAncestors

  def disk
    nearest_ancestors(:disk)
  end

end
