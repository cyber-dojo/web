
class Tag

  def initialize(externals, id, hash)
    @externals = externals
    @id = id
    @hash = hash
  end

  # queries

  #attr_reader :kata

  def visible_files
    @manifest ||= singler.tag_visible_files(@id, number)
  end

  def output
    # Very early dojos didn't store output in initial tag 0
    visible_files['output'] || ''
  end

  def time
    Time.mktime(*hash['time'])
  end

  def light?
    colour.to_s != ''
  end

  def colour
    # Very early dojos used outcome
    (hash['colour'] || hash['outcome'] || '').to_sym
  end

  def to_json
    # Used only in differ_controller.rb
    {
      'colour' => colour,
      'time'   => time,
      'number' => number
    }
  end

  def number
    hash['number']
  end

  private # = = = = = = = = = = =

  attr_reader :hash

  def singler
    @externals.singler
  end

end
