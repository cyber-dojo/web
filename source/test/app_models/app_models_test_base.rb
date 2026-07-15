require_relative '../all'

class AppModelsTestBase < TestBase

  def kata_ran_tests(id, index, files, stdout, stderr, status, summary, laptop_id)
    saver.kata_ran_tests(id, index, files, stdout, stderr, status, summary, laptop_id)
  end

  def kata_revert(id, index, files, stdout, stderr, status, summary, laptop_id)
    saver.kata_ran_tests(id, index, files, stdout, stderr, status, summary, laptop_id)
  end

end
