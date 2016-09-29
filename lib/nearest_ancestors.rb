
module NearestAncestors # mix-in

  def nearest_ancestors(symbol, my = self)
    loop {
      fail "#{my.class.name} does not have a parent" unless my.respond_to? :parent
      my = my.parent
      return my.send(symbol) if my.respond_to? symbol
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
#   shell    - executes shell commands, eg mkdir,ls,git
#   disk     - file-system directories and file read/write
#   log      - memory/stdout based logging
#   git      - all required git commands. Forwards to shell
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Allows the lib/ classes representing external objects to easily access
# each other as well. For example:
#
#     HostGit   -> shell -> HostShell
#     HostShell -> log   -> HostLog
#
