
class MockPuller

  @@pulled = []
  @@pull = []

  def initialize(_parent)
  end

  def reset
    @@pulled = []
    @@pull = []
  end

  def teardown
    unless @@pulled == []
      error "unrequited mock pulled?:#{@@pulled}"
    end
    unless @@pull == []
      error "unrequited mock pull:#{@@pull}"
    end
  end

  def mock_pulled?(image_name, result)
    unless [true,false].include? result
      error 'mock_pulled?() 2nd arg must be true/false'
    end
    @@pulled << [image_name, result]
  end

  def pulled?(image_name)
    if @@pulled == []
      error "no mock for pulled?(#{image_name})"
    end
    mock = @@pulled.shift
    unless mock[0] == image_name
      error "pulled?() expected:#{mock[0]}, actual:#{image_name}:"
    end
    mock[1]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def mock_pull(image_name, result)
    unless [true,false].include? result
      error 'mock_pull() 2nd arg must be true/false'
    end
    @@pull << [image_name, result]
  end

  def pull(image_name)
    if @@pull == []
      error "no mock for pull(#{image_name})"
    end
    mock = @@pull.shift
    unless mock[0] == image_name
      error "pull() expected:#{mock[0]}, actual:#{image_name}:"
    end
    mock[1]
  end

  private

  def error(message)
    fail "MockPuller:#{message}"
  end

end
