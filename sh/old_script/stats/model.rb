
require 'json'
require_relative '../../lib/all'
require_relative '../../app/lib/all'
require_relative '../../app/models/all'

def dojo
  Dojo.new
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def number(value,width)
  spaces = ' ' * (width - value.to_s.length)
  "#{spaces}#{value.to_s}"
end

def dots(dot_count)
  dots = '.' * (dot_count % 32)
  spaces = ' ' * (32 - dot_count % 32)
  dots + spaces + number(dot_count,5)
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

class Dots
  def initialize(prompt)
    @count,@prompt = 0,prompt
  end
  def line
    if @count % 25 == 0
      @count += 1
      return "\r#{@prompt}" + dots
    else
      @count += 1
      return ''
    end
  end
private
  def dots
    n = 32 - @prompt.length
    dots = '.' * (@count % n)
    spaces = ' ' * (n - @count % n)
    dots + spaces + number(@count,5)
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - -

def mention(exceptions)
  if exceptions != [ ]
    puts
    puts
    puts "# #{exceptions.length} Exceptions saved in exceptions.log"
    `echo '#{exceptions.to_s}' > exceptions.log`
    puts
    puts
  end
end

