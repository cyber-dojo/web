
class RaggerStub

  def initialize(_externals)
  end

  def stub_colour(colour)
    @colour = colour
  end

  def colour(_image_name, _id, _stdout, _stderr, _status)
    @colour || 'amber'
  end

end
