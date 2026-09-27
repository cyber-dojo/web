require 'json'

# The suite's default runner, so no server test starts a real container. A test
# arranges the next run's outcome with stub_run; the app then reads it back
# through run_cyber_dojo_sh. The stub lives in this instance, which the test and
# the app share (Externals memoizes one runner), so concurrent tests cannot see
# each other's stubs.
class RunnerStub

  # Takes the externals it is built from, as every collaborator does, and
  # ignores them: this stub talks to nothing.
  def initialize(_externals)
    @stubbed_run = nil
  end

  # - - - - - - - - - - - - - - - - -

  # Stands in for a healthy runner, mirroring RunnerService#ready?, so a test
  # exercising a readiness probe sees the runner as ready.
  def ready?
    true
  end

  # - - - - - - - - - - - - - - - - -

  # Arranges what the next run_cyber_dojo_sh returns. Every key is optional.
  def stub_run(stub = {})
    stub[:stdout] ||= ''
    stub[:stderr] ||= ''
    stub[:status] ||= 0
    stub[:outcome] ||= 'red'
    stub[:created] ||= {}
    stub[:deleted] ||= []
    stub[:changed] ||= {}
    # Held as JSON so what the app reads back is plain data, the same shape a
    # real runner's response arrives in.
    @stubbed_run = JSON.generate({
      'stdout' => file(stub[:stdout]),
      'stderr' => file(stub[:stderr]),
      'status' => stub[:status],
      'outcome' => stub[:outcome],
      'created' => stub[:created],
      'deleted' => stub[:deleted],
      'changed' => stub[:changed]
    })
  end

  # - - - - - - - - - - - - - - - - -

  # Returns the arranged run, or a red default for a test that arranged none.
  def run_cyber_dojo_sh(_args)
    if @stubbed_run.nil?
      {
        'stdout' => file('so'),
        'stderr' => file('se'),
        'status' => 0,
        'outcome' => 'red',
        'created' => {},
        'deleted' => [],
        'changed' => {}
      }
    else
      JSON.parse(@stubbed_run)
    end
  end

  private

  # One file, in the shape the runner reports files in.
  def file(content)
    { 'content' => content,
      'truncated' => false
    }
  end

end
