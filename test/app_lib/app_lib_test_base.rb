
require_relative '../all'

class AppLibTestBase < TestBase

  def lion; 'lion'; end
  def salmon; 'salmon'; end

  def starting_files
    {
      'hiker.h'       => '#ifndef HIKER_INCLUDED...',
      'hiker.c'       => '#include "hiker.h"...',
      'hiker.tests.c' => '#include <assert.h>...',
      'cyber-dojo.sh' => 'make --always-make',
      'instructions'  => 'FizzBuzz is a game...'
    }.clone
  end

  def empty_delta
    { 'unchanged' => [], 'changed' => [], 'new' => [], 'deleted' => [] }
  end

end
