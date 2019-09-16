# frozen_string_literal: true

module IdPather

  def katas_id_path(id, *parts)
    id_path('katas', id, *parts)
  end

  def groups_id_path(id, *parts)
    id_path('groups', id, *parts)
  end

  def id_path(type, id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', type, id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

end
