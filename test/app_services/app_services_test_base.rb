require_relative '../all'

class AppServicesTestBase < TestBase

  def creation_time
    [ 2016,12,5, 17,44,23 ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def tag0
    {
      'event'  => 'created',
      'time'   => creation_time,
      'number' => 0
    }
  end

end
