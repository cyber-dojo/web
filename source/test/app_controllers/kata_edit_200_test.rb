require_relative 'app_controller_test_base'

class KataEdit200Test  < AppControllerTestBase

  def self.hex_prefix
    'BE7'
  end

  test '9B9', %w( edit landing page ) do
    with_runner_class('RunnerStub') do
      in_kata do |kata|
        get "/kata/edit/#{kata.id}"
        assert_response :success
      end
    end
  end

end
