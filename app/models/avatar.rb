
class Avatar

  def initialize(kata, index)
    @kata = kata
    @name = Avatars.names[index.to_i]
  end

  attr_reader :kata, :name

end
