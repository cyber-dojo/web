# frozen_string_literal: true

require_relative '../lib/id_generator'
require_relative '../../test/app_services/service_doubles'

module Externals # mix-in

  def custom
    @custom ||= external
  end

  def exercises
    @exercises ||= external
  end

  def languages
    @languages ||= external
  end

  # - - - - - - - - - - - - - - -

  def avatars
    @avatars ||= external
  end

  def differ
    @differ ||= external
  end

  def mapper
    @mapper ||= external
  end

  def ragger
    @ragger ||= external
  end

  def runner
    @runner ||= external
  end

  def saver
    @saver ||= external
  end

  #def zipper
  #  @zipper ||= external
  #end

  def id_generator
    @id_generator ||= IdGenerator.new
  end

  def http
    @http ||= Net::HTTP
  end
  def set_http(klass)
    @http = klass
  end

  private # = = = = = = = = =

  def external
    # See comment below
    key = 'CYBER_DOJO_' + name_of(caller).upcase + '_CLASS'
    var = ENV[key] || fail("ENV[#{key}] not set")
    Object.const_get(var).new(self)
  end

  def name_of(caller)
    # eg caller[0] == "externals.rb:36:in `runner'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# External class-names are set using environment variables.
# This gives tests a way to do Parameterize-From-Above that
# can tunnel through a *deep* stack. In particular, you can set
# an environment variable and then run a controller test which
# issue GETs/POSTs, which work their way through the rails stack,
# -In-A-Different-Thread-, reaching externals.rb, where the
# specificied Substitute class takes effect.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
