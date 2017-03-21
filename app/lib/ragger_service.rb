require_relative '../../lib/nearest_ancestors'

class RaggerService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def colour(image_name, id, output)

    if image_name == "#{cdf}/gcc_assert"
      src = gcc_assert
      rag = eval(src.join("\n"))
      return rag.call(output).to_s
    end

    manifest = storer.kata_manifest(id)
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

  def cdf; 'cyberdojofoundation'; end

  def gcc_assert
    [ 'lambda { |output|',
        'return :red   if /(.*)Assertion(.*)failed./.match(output)',
        'return :green if /(All|\d+) tests passed/.match(output)',
        'return :amber',
      '}'
    ]
  end

end
