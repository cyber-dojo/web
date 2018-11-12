require_relative 'app_lib_test_base'

class RingPrevNextTest < AppLibTestBase

  def self.hex_prefix
    '9A9'
  end

  include RingPrevNext

  def hex_setup
    set_differ_class('NotUsed')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '099',
  'prev/next for individual inactive kata is empty-string' do
    in_kata do |kata|
      assert_equal ['',''], ring_prev_next(kata)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '09A',
  'prev/next for individual active kata is empty-string' do
    in_kata do |kata|
      ran_tests(kata, 1)
      assert_equal ['',''], ring_prev_next(kata)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3BA',
  'prev/next for any number of inactive group members is empty-string' do
    in_group do |group|
      lion = join(group, 'lion')
      assert_equal ['',''], ring_prev_next(lion)
      tiger = join(group, 'tiger')
      assert_equal ['',''], ring_prev_next(lion)
      assert_equal ['',''], ring_prev_next(tiger)
      wolf = join(group, 'wolf')
      assert_equal ['',''], ring_prev_next(lion)
      assert_equal ['',''], ring_prev_next(tiger)
      assert_equal ['',''], ring_prev_next(wolf)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '345', %w(
  prev/next for one active member of group is the empty-string
  ) do
    in_group do |group|
      lion = join(group, 'lion')
      ran_tests(lion, 1)
      assert_equal ['',''], ring_prev_next(lion)
      wolf = join(group, 'wolf')
      assert_equal ['',''], ring_prev_next(lion)
      spider = join(group, 'spider')
      assert_equal ['',''], ring_prev_next(lion)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '346', %w(
  prev/next for inactive group member is empty-string
  regardless of how many other active group members there are
  ) do
    in_group do |group|
      bee = join(group, 'bee')
      assert_equal ['',''], ring_prev_next(bee)
      snake = join(group, 'snake')
      ran_tests(snake, 1)
      assert_equal ['',''], ring_prev_next(bee)
      fox = join(group, 'fox')
      ran_tests(fox, 1)
      assert_equal ['',''], ring_prev_next(bee)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '69B', %w(
  prev/next for active group member when there are two active group members
  ) do
    in_group do |group|
      frog = join(group, 'frog')
      ran_tests(frog, 1)
      owl = join(group, 'owl')
      ran_tests(owl, 1)
      assert_equal [owl.id,owl.id], ring_prev_next(frog)
      assert_equal [frog.id,frog.id], ring_prev_next(owl)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '69C', %w(
  prev/next for active group member when there are three active group members
  ) do
    in_group do |group|
      frog = join(group, 'frog')
      ran_tests(frog, 1)
      owl = join(group, 'owl')
      ran_tests(owl, 1)
      lion = join(group, 'lion')
      ran_tests(lion, 1)
      assert_equal [owl.id,lion.id], ring_prev_next(frog)
      assert_equal [lion.id,frog.id], ring_prev_next(owl)
      assert_equal [frog.id,owl.id], ring_prev_next(lion)
    end
  end

  private

  def ran_tests(kata, index)
    colour = ['red','amber','green'].sample
    kata.ran_tests(index, kata.files, time_now, duration, '', '', 0, colour)
  end

  def join(group, avatar_name)
    indexes = (0..63).to_a.shuffle
    index = Avatars.index(avatar_name)
    indexes.delete(index)
    indexes.unshift(index)
    group.join(indexes)
  end

end
