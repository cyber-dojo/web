# frozen_string_literal: true

require_relative '../services/externals'

class Avatars

  def self.names
    # self.new to create object to get avatars from Externals
    @@names ||= self.new.avatars.names
  end

  def self.index(name)
    self.names.index(name)
  end

  private

  include Externals

end
