require_relative '../../lib/nearest_ancestors'

class RaggerService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def colour(kata_id, stdout, stderr)
    # Only called if runner.run() returns colour=nil
    # Causes an extra trip to the storer-service to
    # retrieve the manifest.
    # The plan is to make runner.run() always return a
    # non-nil colour and then deprecate this.
    output = stdout + stderr
    manifest = storer.kata_manifest(kata_id)
    # before or after start-points re-architecture?
    src = manifest['red_amber_green']
    if src.nil? # before
      unit_test_framework = manifest['unit_test_framework']
      OutputColour.of(unit_test_framework, output)
    else # after
      colour = eval(src.join("\n"))
      colour.call(output).to_s
    end
  end

  private

  include NearestAncestors
  def storer; nearest_ancestors(:storer); end

end
