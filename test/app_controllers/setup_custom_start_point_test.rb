require_relative 'app_controller_test_base'

class SetupCustomStartPointControllerTest < AppControllerTestBase

  test 'EB7B53',
  'show succeeds when id is invalid' do
    do_get 'show', 'id' => '379C8ABFDF'
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'EB77D9',
  'shows all custom exercises' do
    do_get 'show'
    choices = starter.custom_choices(nil)
    choices['major_names'].each do |major_name|
      diagnostic = "#{major_name} not found in html"
      r = Regexp.new(Regexp.escape(major_name))
      assert r.match(html), diagnostic
    end
    choices['minor_names'].each do |minor_name|
      diagnostic = "#{minor_name} not found in html"
      r = Regexp.new(Regexp.escape(minor_name))
      assert r.match(html), diagnostic
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'EB783D',
  'saves a custom exercises' do
    params = {
      'major' => 'Yahtzee refactoring',
      'minor' => 'C# NUnit'
    }
    do_get 'save', params
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  private

  def do_get(route, params = {})
    controller = 'setup_custom_start_point'
    get "#{controller}/#{route}", params
    assert_response :success
  end

end
