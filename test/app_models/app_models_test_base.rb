require_relative '../all'

class AppModelsTestBase < TestBase

  def kata_ran_tests(id, index, files, stdout, stderr, status, summary)
    model.kata_ran_tests(id, index, files, stdout, stderr, status, summary)
  end

  def kata_revert(id, index, files, stdout, stderr, status, summary)
    model.kata_ran_tests(id, index, files, stdout, stderr, status, summary)
  end

end
