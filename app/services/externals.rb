
module Externals # mix-in

  def env_var; @env_var ||= EnvVar.new; end

  def differ ; @differ  ||= external; end
  def runner ; @runner  ||= external; end
  def starter; @starter ||= external; end
  def storer ; @storer  ||= external; end
  def zipper ; @zipper  ||= external; end

  def http ; @http ||= external; end

  private

  include NameOfCaller

  def external
    key = name_of(caller)
    var = env_var.value(key + '_class')
    Object.const_get(var).new(self)
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
#
# The env-vars are set in /lib/env_var.rb
# For testing the env-vars are set in /test/run.sh
#
# The external objects are held using
#    @name ||= ...
# I use ||= partly for optimization and partly for testing
# (where it is sometimes handy that it is the same object)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
