require_relative 'client_test_base'

# The kata edit page opens on one file. A readme comes first; without one (eg
# a practice whose exercise was skipped) the test file opens, rather than
# whichever source file sorts first alphabetically.
class KataEditOpeningFileTest < ClientTestBase

  test 'c4b8e1', %w(
  | a kata with no readme and no highlight files opens on its test file,
  | not on a helper source file that sorts before it
  ) do
    manifest = starter_manifest
    manifest['visible_files'] = no_readme_files(manifest['visible_files'])
    manifest['highlight_filenames'] = []
    id = saver.kata_create(manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    assert_selector('#filename-list .filename.selected', exact_text: 'test_hiker.sh')
  end

  test 'c4b8e2', %w(
  | a kata with a readme still opens on its readme
  ) do
    manifest = starter_manifest
    files = no_readme_files(manifest['visible_files'])
    files['readme.txt'] = { 'content' => "Write a function returning 42.\n" }
    manifest['visible_files'] = files
    manifest['highlight_filenames'] = []
    id = saver.kata_create(manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    assert_selector('#filename-list .filename.selected', exact_text: 'readme.txt')
  end

  private

  # Returns a Bash practice's files without a readme: cyber-dojo.sh from the
  # template, a coverage helper that sorts first, the code, and its test.
  def no_readme_files(template_files)
    {
      'cyber-dojo.sh' => template_files['cyber-dojo.sh'],
      'coverage.sh'   => { 'content' => "# Reports line coverage of hiker.sh\n" },
      'hiker.sh'      => { 'content' => "answer() { echo $((6 * 9)); }\n" },
      'test_hiker.sh' => { 'content' => "source ./hiker.sh\n[ \"$(answer)\" = 42 ]\n" }
    }
  end
end
