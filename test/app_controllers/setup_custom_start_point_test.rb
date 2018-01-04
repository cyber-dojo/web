require_relative 'app_controller_test_base'

class SetupCustomStartPointControllerTest < AppControllerTestBase

  def self.hex_prefix
    'EB7634'
  end

  def hex_setup
    set_starter_class('StarterService')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B53',
  'show succeeds when id is invalid' do
    do_get 'show', 'id' => '379C8ABFDF'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA3',
  'show defaults to major,minor of custom-kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    id = create_custom_kata('Yahtzee refactoring, C# NUnit')
    do_get 'show', 'id' => id
    choices = starter.custom_choices
    major_names = choices['major_names']
    md = /var selectedMajor = \$\('#major_' \+ (\d+)/.match(html)
    refute_nil md
    assert_equal 'Yahtzee refactoring', major_names[md[1].to_i]
    # checking the initial test-framework looks to be
    # nigh on impossible in static html
  end

  # - - - - - - - - - - - - - - - - - - -

  test '7D9',
  'shows all custom exercises' do
    do_get 'show'
    choices = starter.custom_choices
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

  test '83D',
  'saves a custom exercises' do
    params = {
      'major' => 'Yahtzee refactoring',
      'minor' => 'C# NUnit'
    }
    do_get 'save', params
  end

  private

  def do_get(route, params = {})
    controller = 'setup_custom_start_point'
    get "/#{controller}/#{route}", params:params
    assert_response :success
  end

end
