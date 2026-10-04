require_relative 'browser_test_base'

class EnterPageTest < BrowserTestBase

  # - - - - - - - - - - - - - - - - -

  qtest Ep3wQ1: %w[
    |group enter page: start opens a new tab straight onto
    |a new avatar's kata in that group, not the avatar page
  ] do
    group_id = create_group_onto_its_enter_page
    new_tab = window_opened_by { find('.ltf-group button.enter').click }
    within_window(new_tab) do
      # The tab opens blank and reaches the kata only once enter.json returns.
      assert_current_path(%r{\A/kata/edit/[0-9A-Za-z]{6}\z}, wait: 10)
      kata_id = current_path.split('/').last
      assert_equal group_id, kata_manifest(kata_id)['group_id']
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Ep3wQ2: %w[
    |group enter page: start on a full group leaves no new tab,
    |stays on the enter page, and shows a dialog saying it is full
  ] do
    # FD6ryx is the pre-created full group; see test/data/create_full_kata.sh
    visit(mounted_path('enter?id=FD6ryx'))
    find('.ltf-group button.enter').click
    assert_selector('dialog[open]', text: "sorry, it's full")
    assert_current_path('/creator/enter?id=FD6ryx')
    assert_equal 1, windows.size
  end

  # - - - - - - - - - - - - - - - - -

  qtest Ep3wQ3: %w[
    |group enter page: join on a group one avatar has started
    |shows, over the page, a dialog of the 8x8 avatars with only that one
    |in colour, hovering it tips its name, and clicking it opens its kata
    |in a new tab
  ] do
    group_id = create_group_onto_its_enter_page
    started_tab = window_opened_by { find('.ltf-group button.enter').click }
    kata_id = within_window(started_tab) do
      assert_current_path(%r{\A/kata/edit/[0-9A-Za-z]{6}\z}, wait: 10)
      current_path.split('/').last
    end
    find('.ltf-group button.reenter').click
    assert_selector('dialog[open] .dialog-title', exact_text: 'click your avatar')
    assert_selector('dialog[open] img.avatar.colour', count: 1)
    assert_selector('dialog[open] img.avatar.grey', count: 63)
    colour_avatar = find('dialog[open] img.avatar.colour')
    colour_avatar.hover
    assert_selector('dialog[open] .hover-tip', exact_text: colour_avatar['alt'])
    rejoined_tab = window_opened_by { find('dialog[open] img.avatar.colour').click }
    within_window(rejoined_tab) do
      assert_current_path("/kata/edit/#{kata_id}")
    end
    assert_current_path("/creator/enter?id=#{group_id}")
  end

  # - - - - - - - - - - - - - - - - -

  qtest Ep3wQ4: %w[
    |group enter page: join on a group no avatar has started
    |shows, over the page, a dialog saying no one has joined yet,
    |all 64 avatars grey
  ] do
    group_id = create_group_onto_its_enter_page
    find('.ltf-group button.reenter').click
    assert_selector('dialog[open] .dialog-title', exact_text: "no one's joined yet!")
    assert_selector('dialog[open] img.avatar.grey', count: 64)
    assert_current_path("/creator/enter?id=#{group_id}")
    assert_equal 1, windows.size
  end

  private

  # Creates a Tennis/Python-pytest group through the setup page and returns
  # its id, leaving the browser on that group's enter page.
  def create_group_onto_its_enter_page
    visit(mounted_path('setup?type=group'))
    find('.exercises .display-name', exact_text: 'Tennis').click
    find('.languages .display-name', exact_text: 'Python').click
    find('.frameworks .display-name', exact_text: 'pytest').click
    find('button.next').click
    assert_current_path(%r{\A/creator/enter\?id=[0-9A-Za-z]{6}\z})
    current_url.split('id=').last
  end
end
