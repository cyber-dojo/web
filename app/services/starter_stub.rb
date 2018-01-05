require_relative 'http_helper'

class StarterStub

  def initialize(_)
  end

  def language_manifest(major_name, minor_name, exercise_name)
    # Important not to make these returned Constants
    # because I manipulate the manifest in tests,
    # eg deleting keys to test kata defaults and
    # eg setting specific id's to test kata.id completion.
    if [major_name,minor_name,exercise_name] == ['Python','unittest','Fizz_Buzz']
      return {
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
          "test_hiker.py" => TEST_HIKER_PY_UNITTEST,
          "hiker.py" => HIKER_PY,
          "cyber-dojo.sh" => "python3 -m unittest *test*.py\n",
          "output" => "",
          "instructions" => "Fizz_Buzz"
        },
        "exercise" => "Fizz_Buzz"
      }
    end
    if [major_name,minor_name,exercise_name] == ['C (gcc)','assert','Fizz_Buzz']
      return {
        "display_name" => "C (gcc), assert",
        "image_name" => "cyberdojofoundation/gcc_assert",
          "filename_extension" => ".c",
          "runner_choice" => "stateful",
          "visible_files" => {
            "hiker.tests.c" => HIKER_TESTS_C,
            "hiker.c" => HIKER_C,
            "hiker.h" => HIKER_H,
            "makefile" => MAKEFILE,
            "cyber-dojo.sh" => "make --always-make",
            "output" => "",
            "instructions" => "Fizz_Buzz"
          },
          "exercise" => "Fizz_Buzz"
      }
    end
    if [major_name,minor_name,exercise_name] == ['Python','py.test','Fizz_Buzz']
      return     {
        "display_name" => "Python, py.test",
        "image_name" => "cyberdojofoundation/python_pytest",
        "runner_choice" => "processful",
        "filename_extension" => ".py",
        "tab_size" => 4,
        "visible_files" => {
          "test_hiker.py" => TEST_HIKER_PY_PYTEST,
          "hiker.py" => HIKER_PY,
          "cyber-dojo.sh" => "pytest *test*.py\n",
          "output" => "",
          "instructions" => "Fizz_Buzz"
        },
        "exercise" => "Fizz_Buzz"
      }
    end
  end

  private # = = = = = = = = = = = =

  HIKER_PY = <<~PYTHON_CODE
    class Hiker:

        def answer(self):
            return 6 * 9
    PYTHON_CODE

  # - - - - - - - - - - - - - - - -

  TEST_HIKER_PY_PYTEST = <<~PYTHON_CODE
    import hiker

    def test_life_the_universe_and_everything():
        '''a simple example to start you off'''
        douglas = hiker.Hiker()
        assert douglas.answer() == 42
    PYTHON_CODE

  # - - - - - - - - - - - - - - - -

  TEST_HIKER_PY_UNITTEST = <<~PYTHON_CODE
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

  # - - - - - - - - - - - - - - - -

  HIKER_TESTS_C = <<~C_CODE
    #include "hiker.h"
    #include <assert.h>
    #include <stdio.h>

    static void life_the_universe_and_everything(void)
    {
        assert(answer() == 42);
    }

    int main(void)
    {
        life_the_universe_and_everything();
        // green-traffic light pattern...
        puts("All tests passed");
    }
    C_CODE

  # - - - - - - - - - - - - - - - -

  HIKER_C = <<~C_CODE
    #include "hiker.h"

    int answer(void)
    {
        return 6 * 9;
    }
    C_CODE

  # - - - - - - - - - - - - - - - -

  HIKER_H = <<~C_CODE
    #ifndef HIKER_INCLUDED
    #define HIKER_INCLUDED

    int answer(void);

    #endif
    C_CODE

  # - - - - - - - - - - - - - - - -

  MAKEFILE = [
      "CFLAGS += -I. -Wall -Wextra -Werror -std=c11",
      "CFLAGS += -Wsequence-point",
      "CFLAGS += -Wstrict-prototypes",
      "CFLAGS += -Wmissing-prototypes",
      "CFLAGS += -Wshadow -Wfloat-equal -O",
      "",
      "H_FILES = $(wildcard *.h)",
      "COMPILED_H_FILES = $(patsubst %.h,%.compiled_h,$(H_FILES))",
      "C_FILES = $(wildcard *.c)",
      "",
      ".PHONY: test.output",
      "test.output: test makefile",
      "\t@./$<",
      "",
      "test: makefile $(C_FILES) $(COMPILED_H_FILES)",
      "\t@gcc $(CFLAGS) $(C_FILES) -o $@",
      "",
      "# This rule ensures header files build in their own right.",
      "# The quality of header files is important because header files",
      "# are #included from other files and thus have a large span",
      "# of influence (unlike .c files which are not #included).",
      "",
      "%.compiled_h: %.h",
      "\t@gcc -x c $(CFLAGS) -c -o $@ $<"
    ].join("\n") + "\n"

end
