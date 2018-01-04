require_relative 'http_helper'

class StarterStub

  def initialize(_)
  end

  def language_manifest(major_name, minor_name, exercise_name)
    if [major_name,minor_name,exercise_name] == ['Python','unittest','Fizz_Buzz']
      {
        "display_name" => "Python, unittest",
        "image_name" => "cyberdojofoundation/python_unittest",
        "runner_choice" => "stateless",
        "filename_extension" => ".py",
        "tab_size" => 3,
        "progress_regexs" => [
          "FAILED \\(failures=\\d+\\)",
          "OK"
        ],
        "highlight_filenames" => [ "test_hiker.py" ],
        "max_seconds" => 11,
        "visible_files" => {
          "test_hiker.py" => test_hiker_py,
          "hiker.py" => hiker_py,
          "cyber-dojo.sh" => "python3 -m unittest *test*.py\n",
          "output" => "",
          "instructions" => "Fizz_Buzz"
        },
        "exercise" => "Fizz_Buzz"
      }
    end
  end

  private # = = = = = = = = = = = =

  def hiker_py
    <<~PYTHON_CODE
    class Hiker:

        def answer(self):
            return 6 * 9
    PYTHON_CODE
  end

  def test_hiker_py
    <<~PYTHON_CODE
    import hiker
    import unittest

    class TestHiker(unittest.TestCase):

        def test_life_the_universe_and_everything(self):
            '''simple example to start you off'''
            douglas = hiker.Hiker()
            self.assertEqual(42, douglas.answer())

    if __name__ == '__main__':
        unittest.main()
    PYTHON_CODE
  end

end
