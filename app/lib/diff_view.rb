# frozen_string_literal: true

module DiffView # mix-in

  def diff_view(diffed_files)
    n = 0
    diffs = []
    diffed_files.sort.each do |filename, diff|
      id = 'id_' + n.to_s
      n += 1
      diffs << {
                        id: id,
                  filename: filename,
             section_count: diff.count { |line| line['type'] == 'section' },
        deleted_line_count: diff.count { |line| line['type'] == 'deleted' },
          added_line_count: diff.count { |line| line['type'] == 'added'   },
                   content: diff_html_file(id, diff),
              line_numbers: diff_html_line_numbers(diff)
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
