require_relative 'app_controller_test_base'

class KataEdit200Test  < AppControllerTestBase

  test 'BE79B9', %w(
  | edit landing page smoke test
  ) do
    in_kata do |kata|
      get "/kata/edit/#{kata.id}"
      assert last_response.ok?
    end
  end

  test 'BE79BA', %w(
  | JSON encodes special characters in stdout/stderr
  ) do
    in_kata do |kata|
      runner.stub_run(stdout: "BACK\\SLASH CRLF\r\nNEW\nLINE CR\rRETURN SINGLE'QUOTE DOUBLE\"QUOTE")
      post_run_tests
      body = last_response.body
      assert_includes body, 'BACK\\\\SLASH'  # \    -> \\ in JSON
      assert_includes body, 'CRLF\\r\\nNEW'  # \r\n -> \r\n in JSON
      assert_includes body, 'NEW\\nLINE'     # \n   -> \n in JSON
      assert_includes body, 'CR\\rRETURN'    # \r   -> \r in JSON
      assert_includes body, "SINGLE'QUOTE"   # '    -> ' in JSON (no escaping)
      assert_includes body, 'DOUBLE\\"QUOTE' # "    -> \" in JSON
    end
  end

end
