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

  test 'fK3nQ9', %w(
  | for a kata in a group, the fork dialog's avatar option creates a new
  | avatar in that same group, and opens it straight in the edit page, since
  | it has already joined
  ) do
    gid = saver.group_create(starter_manifest)
    kid = saver.group_join(gid)
    index = with_light(kid, 'red')
    id = fork_through_browser('avatar', kid, index)
    assert_equal gid, saver.kata_manifest(id)['group_id']
    assert_equal "/kata/edit/#{id}", evaluate_script('window.forkedUrl')
  end

  test 'fK3nQG', %w(
  | the new avatar opens with the light it was forked from, so its edit page
  | shows that traffic-light and does not slide out the starting info
  ) do
    gid = saver.group_create(starter_manifest)
    kid = saver.group_join(gid)
    index = with_light(kid, 'red')
    id = fork_through_browser('avatar', kid, index)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    assert_selector('#kata-page #traffic-lights img.diff-traffic-light[data-colour="red"]',
                    count: 1, wait: 5)
    refute_selector('body.more-open')
  end

  test 'fK3nQD', %w(
  | for a kata in a group, on its creation event, which is not a
  | traffic-light, the fork dialog offers no avatar option
  ) do
    gid = saver.group_create(starter_manifest)
    kid = saver.group_join(gid)
    visit "/review/show/#{kid}?was_index=0&now_index=0"
    find('#fork-button').click
    assert_selector('#fork-dialog .group', visible: true)
    refute_selector('#fork-dialog .avatar', visible: true)
  end

  test 'fK3nQE', %w(
  | on a pulling, timed_out or faulty light, none of which is a test result,
  | the fork button is disabled
  ) do
    id = saver.kata_create(starter_manifest)
    %w( pulling timed_out faulty ).each do |colour|
      index = with_light(id, colour)
      visit "/review/show/#{id}?was_index=#{index}&now_index=#{index}"
      assert_selector('#fork-button[disabled]', wait: 5)
    end
  end

  test 'fK3nQA', %w(
  | for a kata in no group, the fork dialog offers group and solo but no
  | avatar, since there is no group for a new avatar to join
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/review/show/#{id}?was_index=0&now_index=0"
    find('#fork-button').click
    assert_selector('#fork-dialog .group', visible: true)
    assert_selector('#fork-dialog .kata', visible: true)
    refute_selector('#fork-dialog .avatar', visible: true)
  end

  test 'fK3nQB', %w(
  | for a kata in a group already holding 64 avatars, the fork dialog's
  | avatar option is disabled and says the group is full
  ) do
    gid = 'VdAxFE' # 63 avatars; see copy_saver_test_data
    kid = member_of(gid)
    index = with_light(kid, 'red')
    saver.group_join(gid)
    visit "/review/show/#{kid}?was_index=#{index}&now_index=#{index}"
    find('#fork-button').click
    assert_selector('#fork-dialog .avatar[disabled]', visible: true, wait: 5)
    assert_selector('#fork-dialog .avatar .fork-option-note', exact_text: 'this group is full')
  end

  test 'fK3nQC', %w(
  | when the group fills between opening the fork dialog and choosing
  | avatar, the avatar option opens no new tab and says the group is full
  ) do
    gid = 'nbRfW9' # 63 avatars; see copy_saver_test_data
    kid = member_of(gid)
    index = with_light(kid, 'red')
    visit "/review/show/#{kid}?was_index=#{index}&now_index=#{index}"
    execute_script('window.open = (url) => { window.forkedUrl = url; };')
    find('#fork-button').click
    assert_selector('#fork-dialog .avatar:not([disabled])', visible: true, wait: 5)

    saver.group_join(gid)
    find('#fork-dialog .avatar').click
    assert_selector('dialog[open] .dialog-title', exact_text: "sorry, it's full", wait: 5)
    assert_nil evaluate_script('window.forkedUrl')
  end

  private

  # The kata id of one of the avatars already in group gid.
  def member_of(gid)
    saver.group_joined(gid).values.first['id']
  end

  # Gives kata id a traffic-light of the given colour and returns its index.
  def with_light(id, colour)
    files = saver.kata_event(id, 0)['files']
    kata_ran_tests(id, files, content('out'), content('err'), 0,
                   ran_summary(colour), laptop_id, next_tab_seq)
    saver.kata_events(id).last['index']
  end

  # Clicks fork, then the named option, and returns the id of what was made.
  def fork_through_browser(option, id = saver.kata_create(starter_manifest), index = 0)
    visit "/review/show/#{id}?was_index=#{index}&now_index=#{index}"
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
      return url.split(%r{[=/]}).last unless url.nil?

      sleep 0.3
    end
    flunk 'fork never completed (window.open was not called)'
  end

end
