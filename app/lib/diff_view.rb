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
    # Originally I left-padded each line-number.
    # Now I don't and the CSS right-aligns the line-numbers.
    # There is a downside to this approach however.
    # If I have two files in the diff-view and one has less
    # than 10 lines and the other has more than 10 lines then
    # the first one's line-numbers will be 2 chars wide and the
    # seconds one's line-numbers will be 3 chars wide. This
    # will make the left edge of a file's content move
    # horizontally when you switch between these two files.
    # In practice I've decided this is not worth worrying about
    # since the overwhelming feeling you get when switching files
    # is the change of content anyway.
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
