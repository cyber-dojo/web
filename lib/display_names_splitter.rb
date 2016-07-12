
class DisplayNamesSplitter

  def initialize(display_names, initial_index)
    @display_names = display_names
    @initial_index = initial_index
  end

  def major
    @major ||= split(0)
  end

  def initial_index
    name = @display_names[@initial_index].split(',')[0].strip
    major.index(name)
  end

  def minor
    @minor ||= split(1)
  end

  def minor_indexes
    major.map { |major_name| make_minor_indexes(major_name) }
  end

private

  def split(n)
    @display_names.map { |name| name.split(',')[n].strip }.sort.uniq
  end

  def make_minor_indexes(major_name)
    indexes = []
    @display_names.each do |display_name|
      if display_name.start_with?(major_name + ',')
        minor_name = display_name.split(',')[1].strip
        indexes << minor.index(minor_name)
      end
    end
    indexes.shuffle

    # if this is the tests index array for the selected-language
    # then make sure the index for the selected-language's test
    # is at position zero.
    # Why?
    # See /app/views/shared/_languages_list.hmtl.erb
    #     8     data-test-index="<%= @display_names.minor_indexes[index][0] %>"
    #
    # and /app/views/shared/_start_point_chooser.html.erb
    #     25 var ti = language.data('test-index');
    #     26 $('[id=test_' + ti +']').click();
    #
    # These ensure the initial selection of the language causes the correct
    # initial selection of the test for that language.

    if major_name == major[initial_index]
      minor_name = @display_names[@initial_index].split(',')[1].strip
      minor_index = minor.index(minor_name)
      indexes.delete(minor_index)
      indexes.unshift(minor_index)
    end

    indexes
  end

end
