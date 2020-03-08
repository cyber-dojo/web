# frozen_string_literal: true

class CustomFake

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
    'C++ Countdown, Practice Round',
    'C++ Countdown, Round 1',
    'C++ Countdown, Round 2',
    'C++ Countdown, Round 3',
    'C++ Countdown, Round 4',
    'C++ Countdown, Round 5',
    'C++ Countdown, Round 6',
    'Java Countdown, Practice Round',
    'Java Countdown, Round 1',
    'Java Countdown, Round 2',
    'Java Countdown, Round 3',
    'Java Countdown, Round 4',
    'Tennis refactoring, C# NUnit',
    'Tennis refactoring, C++ (g++) assert',
    'Tennis refactoring, Java JUnit',
    'Tennis refactoring, Python unitttest',
    'Tennis refactoring, Ruby Test::Unit',
    'Yahtzee refactoring, C (gcc) assert',
    'Yahtzee refactoring, C# NUnit',
    'Yahtzee refactoring, C++ (g++) assert',
    'Yahtzee refactoring, Java JUnit',
    'Yahtzee refactoring, Python unitttest'
  ]

  CPP_COUNTDOWN_PRACTICE_ROUND_MANIFEST = {
    "display_name" => "C++ Countdown, Practice Round",
    "highlight_filenames" => [
      "countdown.cpp"
    ],
    "image_name" => "cyberdojofoundation/gpp_assert",
    "filename_extension" => [ ".cpp" ],
    "tab_size" => 4,
    "visible_files" => {
      "countdown.cpp" => {
        "content" => "class m\n{\n    int operator->()\n    {\n        try{}\n        catch(...){}\n        return 0;\n    }\n};\n"
      },
      "cyber-dojo.sh" => {
        "content" => "g++ -std=c++17 -c countdown.cpp\nif [ $? != 0 ]; then\n  echo\n  echo \">>> Score = 0\"\n  echo \">>> [countdown.cpp does not compile]\"\n  echo\n  exit\nfi\n\ng++ -std=c++17 scorer.cpp -o scorer\n./scorer countdown.cpp"
      },
      "rules" => {
        "content" => "Your task is to write a C++ program in the file countdown.cpp \nthat compiles and uses all of the tokens listed in tokens.cpp\nThe smaller your program the higher your score.\nThe size of the program does not include whitespace\nso please format the code nicely for the reviews.\n\nEach time you press the [test] button cyber-dojo\n  o) sees if countdown.cpp compiles \n  o) tells your your score\n  o) tells you exactly how your score is calculated\n\n\nSCORING\n-------\nscore = minus the size of countdown.cpp\nfor each token you have used in countdown.cpp\n  score += 3*token.size \nif (all tokens used in countdown.cpp)\n  score += 50\n\n\nRULES\n-----\no) You may edit only the file countdown.cpp\no) The size of the program does not include whitespace\no) The code is not run (so you do not need a main)\no) The code has to compile \no) The code may have warnings\no) The code may have extra tokens!\no) Tokens must be whole tokens\n   eg you cannot use the keyword double for the do keyword\n   eg you cannot use ... for the . operator\no) Keyword tokens must be keywords\n   eg you cannot use the string \"do\" for the do keyword\no) The judges decision is final\n\n"
      },
      "scorer.cpp" => {
        "content" => "#include <algorithm>\n#include <cctype>\n#include <fstream>\n#include <iostream>\n#include <iomanip>\n#include <vector>\n\nusing namespace std;\n\n#include \"tokens.cpp\"\n\nstatic void print_compiler_version()\n{\n    cout << \">>> Compiler is G++ \" << __VERSION__ << '\\n';\n    cout << \">>> Standard C++ \" << __cplusplus << '\\n';\n    cout << \">>>\\n\";\n}\n\nstatic int line_size(const string & line)\n{\n    int size = 0;\n    for (auto & ch : line)\n        if (!isspace(ch))\n            size++;\n    return size;\n}\n\nstatic int lines_size(const vector<string> & lines)\n{\n    int size = 0;\n    for (auto & line : lines)\n        size += line_size(line);\n    return size;\n}\n\nstatic void print_program_size(const vector<string> & lines)\n{\n    const int width = 60;\n    cout << endl;\n    cout << \"-----|\" << string(width,'-') << endl;\n    int total_size = 0;\n    for (auto & line : lines)\n    {\n        const int size = line_size(line);\n        cout << setw(3) << setfill(' ') << size << \"  |\" << line << endl;\n        total_size += size;\n    }\n    cout << \"-----|\" << string(width, '-') << endl;\n    cout << setw(3) << setfill(' ') << total_size\n         << \" == countdown.cpp.size\" << endl;\n    cout << endl;\n}\n\n// - - - - - - - - - - - - - - - - - - - -\n\nstatic vector<string> read_lines(const char * filename)\n{\n    vector<string> lines;\n    ifstream is(filename);\n    string line;\n    while (getline(is, line))\n        lines.push_back(line);\n    return lines;\n}\n\n// - - - - - - - - - - - - - - - - - - - -\n\nstatic bool uses(const vector<string> & lines, const string & token)\n{\n    // ... also matches .\n    // double also matches do\n    // etc etc\n\n    for (auto & line : lines)\n        if (line.find(token) != string::npos)\n            return true;\n    return false;\n}\n\nstatic int tokens_size(const vector<string> & lines)\n{\n    int size = 0;\n    for (auto & token : tokens)\n        if (uses(lines, token))\n            size += token.size();\n\n    return size;\n}\n\nstatic bool missing_tokens(const vector<string> & lines)\n{\n    vector<string> unused;\n    for (auto & token : tokens)\n        if (!uses(lines, token))\n            return true;\n\n    return false;\n}\n\n// - - - - - - - - - - - - - - - - - - - -\n\nstatic void print_token_bonuses(const vector<string> & lines)\n{\n    const int width = 20;\n    int tokens_size = 0;\n    cout << \"-----|\" << string(width,'-') << endl;\n    for (auto & token : tokens)\n        if (uses(lines, token))\n        {\n            cout << setw(3) << setfill(' ')  << token.size() << \"  |\" << token << endl;\n            tokens_size += token.size();\n        }\n\n    for (auto & token : tokens)\n        if (!uses(lines, token))\n            cout << setw(3) << setfill(' ') << 0 << \"  |\" << token << endl;\n\n    cout << \"-----|\" << string(width,'-') << endl;\n    cout << setw(3) << setfill(' ') << tokens_size << \" == used_tokens.size\" << endl;\n    int completion_bonus = missing_tokens(lines) ? 0 : 50;\n    cout << setw(3) << setfill(' ') << completion_bonus << \" == completion.bonus\" << endl;\n}\n\n// - - - - - - - - - - - - - - - - - - - -\n\nint main(int, const char * argv[])\n{\n    print_compiler_version();\n    vector<string> lines = read_lines(argv[1]);\n    int program_size = lines_size(lines);\n    int used_token_bonus = tokens_size(lines);\n    int completion_bonus = missing_tokens(lines) ? 0 : 50;\n\n    cout << \">>> Score = -countdown.cpp.size + 3*used_tokens.size + completion.bonus\" << endl\n         << \">>>       = \" << setw(3) << setfill(' ') << -program_size << \" + \"\n                              << \"3*\" << used_token_bonus << \" + \"\n                              << completion_bonus << endl\n         << \">>>       = \" << (-program_size + (3*used_token_bonus) + completion_bonus) << endl;\n\n    cout << endl;\n    print_token_bonuses(lines);\n    cout << endl;\n    print_program_size(lines);\n\n    // green-traffic light pattern...put it out of sight\n    for(int i = 0; i < 100; i++)\n        cout << endl;\n    cout << \"All tests passed\\n\";\n}\n"
      },
      "tokens.cpp" => {
        "content" => "const vector<string> tokens =\n{\n    \"catch\",                    \n    \"->\",                    \n    \"[\",                  \n    \"operator\"                \n};\n"
      }
    }
  }

  YAHZTEE_PYTHON_MANIFEST = {
    "filename_extension" => [ ".py" ],
     "display_name" => "Yahtzee refactoring, Python unitttest",
     "image_name" => "cyberdojofoundation/python_unittest",
     "visible_files" => {
       "test_yahtzee.py" => {
         "content" => "import yahtzee\nimport unittest\n\nclass TestYahtzee(unittest.TestCase):\n\n    def test_chance_scores_sum_of_all_dice(self):\n        expected = 15\n        actual = yahtzee.Yahtzee.chance(2,3,4,5,1)\n        assert expected == actual\n        self.assertEqual(16, yahtzee.Yahtzee.chance(3,3,4,5,1))\n  \n    def test_yahtzee_scores_50(self):\n        expected = 50\n        actual = yahtzee.Yahtzee.yahtzee([4,4,4,4,4])\n        assert expected == actual\n"
       },
       "yahtzee.py" => {
         "content" => "class Yahtzee():\n\n    @staticmethod\n    def chance(d1, d2, d3, d4, d5):\n        total = 0\n        total += d1\n        total += d2\n        total += d3\n        total += d4\n        total += d5\n        return total\n\n    @staticmethod\n    def yahtzee(dice):\n        counts = [0]*(len(dice)+1)\n        for die in dice:\n            counts[die-1] += 1\n        for i in range(len(counts)):\n            if counts[i] == 5:\n                return 50\n"
       },
       "instructions" => {
         "content" => "The starting code and tests implements the requirements\nbelow but are (deliberately) very poor.\nYour task is simply to refactor the code and tests.\n\n--------------------------------------------------\n\nThe game of yahtzee is a simple dice game. Each player\nrolls five six-sided dice. They can re-roll some or all\nof the dice up to three times (including the original roll).\n\nFor example, suppose a players rolls\n    3,4,5,5,2\nThey hold (-,-,5,5,-) and re-roll"
       },
       "cyber-dojo.sh" => {
         "content" => "python -m unittest *test*.py"
       }
     }
  }

  YAHTZEE_CSHARP_MANIFEST = {
    "filename_extension" => [ ".cs" ],
    "display_name" => "Yahtzee refactoring, C# NUnit",
    "image_name" => "cyberdojofoundation/csharp_nunit",
    "visible_files" => {
      "YahtzeeTest.cs" => {
        "content" => "using NUnit.Framework;\n\n[TestFixture]\npublic class UntitledTest\n{\n    [Test]\n    public void Chance_scores_sum_of_all_dice()\n    {\n        int expected = 15;\n        int actual = Yahtzee.Chance(2,3,4,5,1);\n        Assert.AreEqual(expected, actual);\n        Assert.AreEqual(16, Yahtzee.Chance(3,3,4,5,1));\n    }\n\n    [Test]\n    public void Yahtzee_scores_50()\n    {\n        int expected = 50;\n        int actual = Yahtzee.yahtzee(4,4,4,4,4);\n"
      },
      "Yahtzee.cs" => {
        "content" => "public class Yahtzee {\n\n    public static int Chance(int d1, int d2, int d3, int d4, int d5)\n    {\n        int total = 0;\n        total += d1;\n        total += d2;\n        total += d3;\n        total += d4;\n        total += d5;\n        return total;\n    }\n\n    public static int yahtzee(params int[] dice)\n    {\n        int[] counts = new int[6];\n        foreach (int die in dice)\n            counts[die-1]++;\n        for (int i = 0; i != 6; i++)\n"
      },
      "instructions" => {
        "content" => "The starting code and tests implements the requirements\nbelow but are (deliberately) very poor.\nYour task is simply to refactor the code and tests.\n\n--------------------------------------------------\n\nThe game of yahtzee is a simple dice game. Each player\nrolls five six-sided dice. They can re-roll some or all\nof the dice up to three times (including the original roll).\n\nFor example, suppose a players rolls\n    3,4,5,5,2\nThey hold (-,-,5,5,-) and re-roll"
      },
      "cyber-dojo.sh" => {
        "content" => "NUNIT_PATH=/nunit/lib/net45\nexport MONO_PATH=${NUNIT_PATH}\n\nmcs -t:library \\\n  -r:${NUNIT_PATH}/nunit.framework.dll \\\n  -out:RunTests.dll *.cs\n\nif [ $? -eq 0 ]; then\n  NUNIT_RUNNERS_PATH=/nunit/tools\n  mono ${NUNIT_RUNNERS_PATH}/nunit3-console.exe --noheader ./RunTests.dll\nfi\n"
      }
    }
  }

  MANIFESTS = {
    'C++ Countdown, Practice Round' => CPP_COUNTDOWN_PRACTICE_ROUND_MANIFEST,
    'Yahtzee refactoring, Python unitttest' => YAHZTEE_PYTHON_MANIFEST,
    'Yahtzee refactoring, C# NUnit' => YAHTZEE_CSHARP_MANIFEST
  }

end
