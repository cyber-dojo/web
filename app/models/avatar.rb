
class Avatar

  def initialize(kata, name)
    # Does *not* validate.
    # All access to avatar object must come through dojo.katas[id].avatars[name]
    @kata = kata
    @name = name
  end

  # modifier

  def test(delta, files)
    runner.run(self, delta, files, kata.image_name)
  end

  def tested(files, at, output, colour)
    storer.avatar_ran_tests(kata.id, name, files, at, output, colour)
  end

  # queries

  attr_reader :kata, :name

  def parent
    kata
  end

  def diff(was_tag, now_tag)
    storer.tag_git_diff(kata.id, name, was_tag, now_tag)
  end

  def active?
    # Players sometimes start an extra avatar solely to read the
    # instructions. I don't want these avatars appearing on the dashboard.
    # When forking a new kata you can enter as one animal to sanity check
    # it is ok (but not press [test])
    storer.avatar_exists?(kata.id, name) && !lights.empty?
  end

  def tags
    ([tag0] + increments).map { |h| Tag.new(self, h) }
  end

  def lights
    tags.select(&:light?)
  end

  def visible_filenames
    visible_files.keys
  end

  def visible_files
    storer.avatar_visible_files(kata.id, name)
  end

  private

  include ExternalParentChainer
  include TimeNow

  def increments
    storer.avatar_increments(kata.id, name)
  end

  def tag0
    @zeroth ||=
    {
      'event'  => 'created',
      'time'   => time_now(kata.created),
      'number' => 0
    }
  end

end

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# tags vs lights
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# When a new avatar enters a dojo, kata.start_avatar()
# will do a 'git commit' + 'git tag' for tag 0 (zero).
# This initial tag is *not* recorded in the
# increments.json file which starts as [ ]
# It probably should be but isn't for existing dojos
# and so for backwards compatibility it stays that way.
#
# All subsequent 'git commit' + 'git tag' commands
# correspond to a gui action and store an entry in the
# increments.json file.
# eg
# [
#   {
#     'colour' => 'red',
#     'time'   => [2014, 2, 15, 8, 54, 6],
#     'number' => 1
#   },
# ]
#
# At the moment the only event that creates an
# increments.json file entry is a [test].
#
# However, I may create finer grained tags than
# just [test] events...
#    o) creating a new file
#    o) renaming a file
#    o) deleting a file
#    o) opening a different file
#    o) editing a file
#
# If this happens the difference between tags and lights
# will be more pronounced.
# ------------------------------------------------------
# Invariants
#
# If the latest tag is N then
#   o) increments.length == N
#   o) tags.length == N+1
#
# The inclusive upper bound for n in avatar.tags[n] is
# always the current length of increments.json (even if
# that is zero) which is also the latest tag number.
#
# The inclusive lower bound for n in avatar.tags[n] is zero.
# When an animal does a diff of [1] what is run is a diff
# between
#   avatar.tags[0] and
#   avatar.tags[1]
#
# ------------------------------------------------------
