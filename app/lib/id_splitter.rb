
module IdSplitter # mix-in

  module_function

  def outer(id)
    id.upcase[0..1]  # 'E5'
  end

  def inner(id)
    id.upcase[2..-1] # '6A3327FE'
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - -
# cyber-dojo uses a file-system instead of a database.
# Each kata has its own 10 digit hex-id, eg '356CDE70DB'
# which corresponds to a dir such as
# ..../katas/35/6CDE70DB/
# where the hex-id is split into a 2/8 dir structure like git.
# This means the katas dir has 256 2-digit dirs.
# - - - - - - - - - - - - - - - - - - - - - - - - - -
