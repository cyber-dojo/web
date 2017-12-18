
# When the [setup a new practice session] button is clicked (on home page)
# then if there is an id present make the initial selection of the
# language+test and the exercise the same as the kata with that id
# (if it still exists).
# This helps to re-inforce the idea of repetition.

module StartPointChooser # mix-in

  module_function

  def choose_language(languages, kata)
    chooser(languages, kata) { kata.display_name }
  end

  def chooser(choices, kata)
    choice = [*0...choices.length].sample
    unless kata.nil?
      index = choices.index(yield)
      choice = index unless index.nil?
    end
    choice
  end

end
