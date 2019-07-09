
module Externals # mix-in

  def versioner
    @versioner ||= external
  end

  def custom
    @custom ||= external
  end
  def exercises
    @exercises ||= external
  end
  def languages
    @languages ||= external
  end

  def saver
    @saver ||= external
  end

  def runner
    @runner ||= external
  end

  def ragger
    @ragger ||= external
  end

  def differ
    @differ ||= external
  end

  def mapper
    @mapper ||= external
  end

  #def zipper
  #  @zipper ||= external
  #end

  def http
    @http ||= Net::HTTP
  end
  def set_http(obj)
    @http = obj
  end

  private # = = = = = = = = =

  def external
    # See comment below
    key = 'CYBER_DOJO_' + name_of(caller).upcase + '_CLASS'
    var = ENV[key] || fail("ENV[#{key}] not set")
    Object.const_get(var).new(self)
  end

  def name_of(caller)
    # eg caller[0] == "externals.rb:23:in `runner'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# External class-names are set using environment variables.
# This gives tests a way to do Parameterize-From-Above that
# can tunnel through a *deep* stack. In particular, I can set an
# environment variable and then run a controller test which issues
# GETs/POSTs, which work their way through the rails stack,
# -In-A-Different-Thread-, reaching externals.rb, where the
# specificied Substitute class takes effect.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
