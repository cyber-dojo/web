# frozen_string_literal: true

module DiffView # mix-in

  def diff_view(diffed_files)
    n = 0
    diffs = []
    diffed_files.each do |diff|

      id = 'id_' + n.to_s
      n += 1

      if diff['type'] === "deleted"
        filename = diff['old_filename']
      else
        filename = diff['new_filename']
      end

      lines = diff['lines']
      line_counts = diff['line_counts']

      diffs << {
                        id: id,
                      type: diff['type'],
                  filename: filename,
              old_filename: diff['old_filename'],
              new_filename: diff['new_filename'],
             section_count: lines.count { |line| line['type'] === 'section' },
        deleted_line_count: line_counts['deleted'],
          added_line_count: line_counts['added'],
           same_line_count: line_counts['same'],
                   content: diff_html_file(id, lines),
              line_numbers: diff_html_line_numbers(lines)
      }
    end
    diffs
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def diff_html_file(id, diff)
    diff.map { |n| diff_htmlify(id, n) }.join('')
  end

  def diff_htmlify(id, n)
    result = ''
    if n['type'] == 'section'
      result = "<span id='#{id}_section_#{n['index']}'></span>"
    else
      line = CGI.escapeHTML(n['line'])
      line = '&nbsp;' if line == ''
      result =
        "<#{n['type']}>" +
          line +
        "</#{n['type']}>"
    end
    result
  end

  def diff_html_line_numbers(diff)
    diff.map { |n| diff_htmlify_line_numbers(n) }.join('')
  end

  def diff_htmlify_line_numbers(n)
    result = ''
    if n['type'] != 'section'
      result =
        "<#{n['type']}>" +
          '<ln>' + n['number'].to_s + '</ln>' +
        "</#{n['type']}>"
    end
    result
  end

end
