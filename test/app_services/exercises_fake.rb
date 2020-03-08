# frozen_string_literal: true

class ExercisesFake

  def initialize(_externals)
  end

  def ready?
    true
  end

  def names
    NAMES
  end

  def manifests
    nil
  end

  def manifest(name)
    MANIFESTS[name]
  end

  private

  NAMES = [
    "(Verbal)", "100 doors", "Anagrams", "Array Shuffle",
    "Balanced Parentheses", "Bowling Game", "Calc Stats", "Closest To Zero",
    "Combined Number", "Count Coins", "Diversion", "Eight Queens",
    "Fizz Buzz", "Fizz Buzz Plus", "Friday 13th", "Game of Life", "Gray Code",
    "Haiku Review", "Harry Potter", "ISBN", "LCD Digits", "Leap Years",
    "Magic Square", "Mars Rover", "Mine Field", "Monty Hall", "Number Chains",
    "Number Names", "Phone Numbers", "Poker Hands", "Prime Factors",
    "Print Diamond", "Recently Used List", "Remove Duplicates", "Reordering",
    "Reverse Roman", "Reversi", "Roman Numerals", "Saddle Points",
    "Tennis", "Tiny Maze", "Unsplice", "Wonderland Number", "Word Wrap",
    "Yatzy", "Yatzy Cutdown", "Zeckendorf Number"
  ]

  MANIFESTS = {
    "Fizz Buzz" => {
      "display_name" => "Fizz Buzz",
      "visible_files" => {
        "readme.txt" => {
          "content" => [
            "Write a program that prints the numbers from 1 to 100.\n",
            "But for multiples of three print \"Fizz\" instead of the\n",
            "number and for the multiples of five print \"Buzz\". For\n",
            "numbers which are multiples of both three and five\n",
            "print \"FizzBuzz\".\n\n",
            "Sample output:\n\n",
            "1\n2\nFizz\n4\nBuzz\n",
            "Fizz\n7\n8\nFizz\nBuzz\n11\nFizz\n13\n14\n",
            "FizzBuzz\n16\n17\nFizz\n19\nBuzz\n... etc up to 100\n"
          ].join
        }
      }
    }
  }

end
