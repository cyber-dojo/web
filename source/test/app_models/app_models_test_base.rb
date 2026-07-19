require_relative '../all'

class AppModelsTestBase < TestBase

  def kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    saver.kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
  end

  def kata_revert(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    saver.kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
  end

end
