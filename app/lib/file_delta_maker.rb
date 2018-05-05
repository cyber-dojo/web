
module FileDeltaMaker # mix-in

  module_function

  # make_delta finds out which files are
  # :new, :unchanged, :changed, or :deleted.
  #
  # Files deleted in the browser are correspondingly deleted in the runner.
  # Files not changed in the browser are _not_ (re)saved.

  def make_delta(was, now)
    now_keys = now.keys.clone
    result = { unchanged: [], changed: [], deleted: [] }
    was.each do |filename, hash|
      if now[filename] == hash
        result[:unchanged] << filename
      elsif !now[filename].nil?
        result[:changed] << filename
      else
        result[:deleted] << filename
      end
      now_keys.delete(filename)
    end
    result[:new] = now_keys
    result
  end

end
