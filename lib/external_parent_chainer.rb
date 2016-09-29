
module ExternalParentChainer # mix-in

  def method_missing(command, *args)
    raise "not-expecting-arguments #{args}" unless args == []
    current = self
    loop { current = current.parent }
  rescue NoMethodError
    current.send(command, *args)
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Hijack *method*_missing to provide transparent access to external *objects*.
# Works by assuming the object (which included this module) has a parent
# property and repeatedly chains back parent to parent to parent
# till it gets to an object without a parent property which it assumes
# is the root object holding the external objects, which it delegates to.
#
# For example, a call such as shell.exec(...) will start with a
#    method_missing(:shell,[])
# which then searches for the root object and may end up as
#    parent.parent.parent.shell.exec(...)
#
# See app/models/dojo.rb
#
#   runner   - performs the actual test run, using docker
#   katas    - access to cyber-dojo's sessions, by ID
#   shell    - executes shell commands, eg mkdir,ls,git
#   disk     - file-system directories and file read/write
#   log      - memory/stdout based logging
#   git      - all required git commands. Forwards to shell
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Allows the lib/ classes representing external objects to easily access
# each other by chaining back to the root dojo object. For example:
#
#     HostGit   -> shell -> dojo.shell -> HostShell
#     HostShell -> log   -> dojo.log   -> HostLog
#
