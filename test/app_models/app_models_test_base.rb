require_relative '../all'

class AppModelsTestBase < TestBase

  class TimeStub
    def initialize(now)
      @now = now
    end
    attr_reader :now
  end

end
