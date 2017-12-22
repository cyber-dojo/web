
# When you are setting up a new cyber-dojo practice session
# cyber-dojo remembers the kata-id of the current practice
# session and the initially selected choices are the same
# as the current practice session
# (if they are still available).
# This is to help re-inforce the idea of repetition.
#
# For example, if the languages display_names are
#
#   [ "C#,Moq", "C#,NUnit", "Java,JUnit", "Java,Mockito" ]
#
# and the current practice session's display_name
# is "C#, NUnit", then the UN-matched result of
# starter.languages_choices() would be:
#
#  {
#   "major_names"  : [ "C#", "Java" ],
#   "minor_names"  : [ "JUnit", "Mockito", "Moq", "NUnit" ],
#   "minor_indexes": [ [2,3], [1,0] ]
#  }
#
# display_name_index() will alter this to:
#
#  {
#   "major_names"  : [ "C#", "Java" ],
#   "minor_names"  : [ "JUnit", "Mockito", "Moq", "NUnit" ],
#   "minor_indexes": [ [3,2], [1,0] ],
#   "major_index"  : 0
#  }
#
# Specifically:
#   major_name("C#,NUnit") == "C#"
#   minor_name("C#,NUnit") == "NUnit"
#
#   o) It adds a 'major_index' entry such that
#      major_names[major_index] == "C#"
#      or, if there is no matching major_name,
#      (eg the current display_name is "Python, NUnit")
#      it will set it to a random index into major_names
#
#   o) It ensures that
#      minor_names[minor_indexes[major_index][0]] == "NUnit"
#      or, if there is no matching minor_name,
#      (eg the current display_name is "C#, py.test")
#      it will leave minor_indexes unchanged.

module DisplayNameIndexer # mix-in

  module_function

  def display_name_index(choices, current_display_name)
    major_names = choices['major_names']
    minor_names = choices['minor_names']
    current_display_name ||= ' , '

    major_index = major_names.index(major_name(current_display_name))
    if major_index.nil?
      choices['major_index'] = rand(0...major_names.size)
      return
    else
      choices['major_index'] = major_index
    end

    minor_index = minor_names.index(minor_name(current_display_name))
    if minor_index.nil?
      return
    end

    matched = choices['minor_indexes'][major_index]
    matched.delete(minor_index)
    matched.unshift(minor_index)
  end

  # - - - - - - - - - - - - - - - - - -

  def major_name(display_name)
    display_name.split(',')[0].strip
  end

  # - - - - - - - - - - - - - - - - - -

  def minor_name(display_name)
    display_name.split(',')[1].strip
  end

end