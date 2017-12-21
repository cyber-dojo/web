
module NearestAncestors # mix-in

  def nearest_ancestors(symbol, my = self)
    loop {
      if my.respond_to?(symbol)
        return my.send(symbol)
      else
        unless my.respond_to?(:parent)
          fail "#{my.class.name} does not have a parent"
        end
        my = my.parent
      end
    }
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Works by assuming the object (which included the module) has a parent
# and repeatedly chains back parent to parent to parent until it gets to
# an object with the required property, or runs out of parents.
# Properties accessed in this way include:
#
#   runner   - performs the actual test run, using docker
#   log      - memory/stdout based logging
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Allows the lib/ classes representing external objects to easily access
# each other as well. For example:
#
#     HostShell -> log   -> HostLog
#
