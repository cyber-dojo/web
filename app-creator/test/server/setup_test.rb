require_relative 'creator_test_base'

class SetupTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest Sx4Lp1: %w[
    |GET/setup?type=kata
    |offers all exercises_start_points names
  ] do
    get mounted_path('setup?type=kata')
    assert status?(200), status
    html = last_response.body
    exercises_start_points.names.each do |name|
      assert html =~ display_name_div(name), name
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sx4Lp2: %w[
    |GET/setup?type=kata
    |offers each language once, being each
    |languages_start_points name up to its first comma
  ] do
    get mounted_path('setup?type=kata')
    assert status?(200), status
    html = last_response.body
    languages = languages_start_points.names.map { |name| name.split(',', 2)[0] }.uniq
    languages.each do |language|
      assert html =~ display_name_div(language), language
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sx4Lp3: %w[
    |GET/setup?type=kata
    |carries every languages_start_points name
    |for the test-framework column and its preview
  ] do
    get mounted_path('setup?type=kata')
    assert status?(200), status
    html = last_response.body
    languages_start_points.names.each do |name|
      assert html.include?(%(data-ltf-name="#{escape_html(name)}")), name
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sx4Lp4: %w[
    |GET/setup?type=kata
    |each language-test-framework carries the content
    |of its selected file, for the preview
  ] do
    get mounted_path('setup?type=kata')
    assert status?(200), status
    html = last_response.body
    helper = Object.new.extend(SelectedHelper)
    languages_start_points.manifests.each do |name, manifest|
      visible_files = manifest['visible_files']
      content = visible_files[helper.selected(visible_files)]['content']
      expected = %(data-ltf-name="#{escape_html(name)}">#{escape_html(content)}</textarea>)
      assert html.include?(expected), name
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sx4Lp5: %w[
    |GET/setup?type=kata
    |lists the languages in case-insensitive order
  ] do
    get mounted_path('setup?type=kata')
    assert status?(200), status
    html = last_response.body
    languages = languages_start_points.names.map { |name| name.split(',', 2)[0] }.uniq
    listed = languages.sort_by { |language| html =~ display_name_div(language) }
    assert_equal languages.sort_by(&:downcase), listed
  end
end
