
module Externals # mix-in

  def differ ; @differ  ||= external; end
  def runner ; @runner  ||= external; end
  def starter; @starter ||= external; end
  def storer ; @storer  ||= external; end
  def zipper ; @zipper  ||= external; end

  def http ; @http ||= external; end

  private # = = = = = = = = =

  def external
    key = 'CYBER_DOJO_' + name_of(caller).upcase + '_CLASS'
    var = ENV[key] || fail("ENV[#{key}] not set")
    Object.const_get(var).new(self)
  end

  def name_of(caller)
    # eg caller[0] == "dojo.rb:7:in `exercises'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# External class-names are set using environment variables.
# This gives tests a way to do Parameterize-From-Above that
# can tunnel through a *deep* stack. For example, I can set an
# environment variable and then run a controller test which issues
# GETs/POSTs, which work their way through the rails stack,
# in a different thread, reaching externals.rb, where the
# specificied Double/Mock/Stub/Fake class takes effect.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
