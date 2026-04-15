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
  | j() escapes special characters for safe embedding in JavaScript string literals
  ) do
    in_kata do |kata|
      runner.stub_run(stdout: "BACK\\SLASH CRLF\r\nNEW\nLINE CR\rRETURN SINGLE'QUOTE DOUBLE\"QUOTE")
      post_run_tests
      body = last_response.body
      assert_includes body, 'BACK\\\\SLASH'  # \    -> \\
      assert_includes body, 'CRLF\\nNEW'    # \r\n -> \n
      assert_includes body, 'NEW\\nLINE'    # \n   -> \n
      assert_includes body, 'CR\\nRETURN'   # \r   -> \n
      assert_includes body, "SINGLE\\'"     # '    -> \'
      assert_includes body, 'DOUBLE\\"'     # "    -> \"
    end
  end

end
