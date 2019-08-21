
class Group

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  attr_reader :id

  def exists?
    saver.group_exists?(id)
  rescue SaverException
    false
  end

  def created
    Time.mktime(*manifest.created)
  end

  def join(indexes = (0..63).to_a.shuffle)
    kid = saver.group_join(id, indexes)
    if kid.nil?
      nil
    else
      kata(kid)
    end
  end

  def size
    katas.size
  end

  def empty?
    size == 0
  end

  def katas
    saver.group_joined(id).map{ |kid| kata(kid) }
  end

  def age
    katas.select(&:active?).map{ |kata| kata.age }.sort[-1] || 0
  end

  def manifest
    @manifest ||= Manifest.new(saver.group_manifest(id))
  end

  private

  def kata(kid)
    Kata.new(@externals, kid)
  end

  def saver
    @externals.saver
  end

end
