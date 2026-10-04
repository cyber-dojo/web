require_relative 'client_test_base'

# The kata edit page's "this practice" dialog shows a facts table. A kata that
# is an avatar in a group gets an avatar row, under ID, naming that avatar, and
# a kata with no exercise shows it as (none).
class ThisPracticeDialogTest < ClientTestBase

  test 'a7e3c1', %w(
  | the this-practice dialog of a group's kata has an avatar row, under ID,
  | naming its avatar, and hovering the name tips that avatar's image
  ) do
    gid = saver.group_create(starter_manifest)
    id = join_at(gid, 28)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    open_this_practice_dialog
    rows = all('dialog[open] .kata-facts tr').map { |tr| tr.all('td').first.text }
    assert_equal %w[ID avatar], rows.first(2)
    name = find('dialog[open] .kata-avatar')
    assert_equal 'lion', name.text
    name.hover
    assert_selector('dialog[open] .hover-tip img[src="/images/avatars/28.jpg"]')
  end

  test 'a7e3c2', %w(
  | the this-practice dialog of a solo kata has no avatar row
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    open_this_practice_dialog
    refute_selector('dialog[open] .kata-avatar')
  end

  test 'a7e3c3', %w(
  | the this-practice dialog of a kata with language and test_framework
  | shows exercise, language and test framework rows, its skipped
  | exercise as (none)
  ) do
    manifest = starter_manifest
    manifest.delete('exercise')
    manifest['language'] = ['Bash', '5.2.37']
    manifest['test_framework'] = ['bats', '1.11.1']
    id = saver.kata_create(manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    open_this_practice_dialog
    assert_equal({ 'exercise' => '(none)', 'language' => 'Bash 5.2.37',
                   'test framework' => 'bats 1.11.1' }, facts.slice('exercise', 'language', 'test framework'))
    refute facts.key?('setup')
  end

  test 'a7e3c4', %w(
  | the this-practice dialog of a custom kata, with no exercise, language
  | or test_framework, shows one setup row: its display_name split at
  | its commas
  ) do
    manifest = starter_manifest
    %w[exercise language test_framework].each { |key| manifest.delete(key) }
    manifest['display_name'] = 'Yahtzee refactoring, C (gcc) assert'
    id = saver.kata_create(manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    open_this_practice_dialog
    assert_equal ['Yahtzee refactoring', 'C (gcc) assert'], facts['setup'].split("\n")
    refute facts.key?('language')
  end

  test 'a7e3c5', %w(
  | the this-practice dialog of an older kata, with an exercise but no
  | language or test_framework, shows one setup row: the exercise, then
  | its display_name split at its commas
  ) do
    manifest = starter_manifest
    %w[language test_framework].each { |key| manifest.delete(key) }
    manifest['exercise'] = 'Tennis'
    manifest['display_name'] = 'C (gcc), assert'
    id = saver.kata_create(manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    open_this_practice_dialog
    assert_equal ['Tennis', 'C (gcc)', 'assert'], facts['setup'].split("\n")
  end

  private

  # Returns the open dialog's visible facts, each row's title mapped to its
  # value text.
  def facts
    all('dialog[open] .kata-facts tr').to_h do |tr|
      title, value = tr.all('td').map(&:text)
      [title, value]
    end
  end

  # Joins the group at exactly the given avatar index and returns the new kata's
  # id; a one-element indexes list pins the index saver hands out.
  def join_at(gid, index)
    saver.instance_variable_get(:@http).post(:group_join, { id: gid, indexes: [index] })
  end

  # A fresh kata slides the ... panel out by itself and, once it has slid, opens
  # the traffic-lights dialog; waiting for that first stops it replacing the
  # facts dialog that hovering the "this practice" row then opens.
  def open_this_practice_dialog
    assert_selector('#traffic-lights-dialog[open]', wait: 5)
    find('#kata-info-button').hover
    assert_selector('dialog[open] .kata-facts')
  end
end
