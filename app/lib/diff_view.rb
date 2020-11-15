# frozen_string_literal: true

module DiffView # mix-in

  def diff_view(diffed_files)
    n = 0
    diffs = []
    diffed_files.each do |diff|

      id = 'id_' + n.to_s
      n += 1

      line_counts = diff['line_counts']

      diffs << {
                        id: id,
                      type: diff['type'],
              old_filename: diff['old_filename'],
              new_filename: diff['new_filename'],
                     lines: diff['lines'],
               line_counts: {
                              deleted: line_counts['deleted'],
                                added: line_counts['added'],
                                 same: line_counts['same']
                            }
      }
    end
    diffs
  end

end
