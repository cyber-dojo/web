require_relative 'client_test_base'

class ForkButtonCreatesKataOrGroupTest < ClientTestBase

  test 'fK3nQ7', %w(
  | the fork dialog's solo option creates a kata: the button's fetch reaches
  | the app through nginx, and the id coming back names a kata saver holds
  | and no group. Nothing else drives the fork path in a browser, so this is
  | what fails if the button's POST path ever goes stale.
  ) do
    id = fork_through_browser('kata')
    assert saver.kata_exists?(id), "#{id} is not a kata"
    refute saver.group_exists?(id), "#{id} is a group"
  end

  test 'fK3nQ8', %w(
  | the fork dialog's group option creates a group, not a kata. The two
  | options post to sibling routes that differ in one word, so asserting the
  | kind - and not merely that something was created - is what tells them
  | apart.
  ) do
    id = fork_through_browser('group')
    assert saver.group_exists?(id), "#{id} is not a group"
    refute saver.kata_exists?(id), "#{id} is a kata"
  end

  private

  # Clicks fork, then the named option, and returns the id of what was made.
  def fork_through_browser(option)
    id = saver.kata_create(starter_manifest)
    visit "/review/show/#{id}?was_index=0&now_index=0"
    # On success the button opens the new practice in a second tab. Replacing
    # window.open keeps the test to one tab, and its argument carries the new
    # id, which is the only place the id reaches the browser.
    execute_script('window.open = (url) => { window.forkedUrl = url; };')
    find('#fork-button').click
    find("#fork-dialog .#{option}").click
    wait_for_forked_id
  end

  # Polls until the stubbed window.open has been handed the new practice's URL.
  def wait_for_forked_id
    20.times do
      url = evaluate_script('window.forkedUrl')
      return url.split('id=').last unless url.nil?

      sleep 0.3
    end
    flunk 'fork never completed (window.open was not called)'
  end

end
