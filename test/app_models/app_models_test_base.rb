require_relative '../all'

class AppModelsTestBase < TestBase

  def in_kata(runner_choice = :stateless, &block)
    display_name = {
       stateless: 'Python, unittest',
        stateful: 'C (gcc), assert',
      processful: 'Python, py.test'
    }[runner_choice]
    refute_nil display_name, runner_choice
    make_language_kata({ 'display_name' => display_name })
    begin
      block.call
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  # - - - - - - - - - - - - - - - -

  def as(name = :wolf, &block)
    avatar = kata.start_avatar([name.to_s])
    begin
      block.call
    ensure
      runner.avatar_old(kata.image_name, kata.id, avatar.name)
    end
  end

  # - - - - - - - - - - - - - - - -

  def wolf
    # Idea: wrap the avatar object inside a DeltaMaker
    # and return that as a 'proxy'. This would allow
    # lines such as
    #    maker = DeltaMaker.new(wolf)
    # to disappear from test code
    kata.avatars['wolf']
  end

end
