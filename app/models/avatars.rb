
class Avatars

  def self.names
    @@names ||= Avatars.new.avatars.names
  end

  private

  include Externals

end
