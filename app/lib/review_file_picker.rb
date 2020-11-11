# frozen_string_literal: true

module ReviewFilePicker # mix-in

  module_function

  def pick_file_id(diffs, current_filename, filenameExtensions)
    # Rule 1
    # If the current-filename exists and has a diff, pick it.
    current_filename_diff = diffs.find { |diff|
      diff_filename(diff) === current_filename &&
        change_count(diff) > 0
    }
    unless current_filename_diff.nil?
      return current_filename_diff[:id]
    end

    # else Rule 2
    # If a filenameExtension file has a diff, pick the largest diff.
    matches = diffs.select { |diff|
      any_extension_match?(diff, filenameExtensions) &&
        change_count(diff) > 0
    }
    largest = matches.max { |lhs,rhs|
      change_count(lhs) <=> change_count(rhs)
    }
    unless largest.nil?
      return largest[:id]
    end

    # else Rule 3
    # If a non-filenameExtension file has a diff, pick the largest diff.
    matches = diffs.select { |diff|
      no_extension_match?(diff, filenameExtensions) &&
        change_count(diff) > 0
    }
    largest = matches.max { |lhs,rhs|
      change_count(lhs) <=> change_count(rhs)
    }
    unless largest.nil?
      return largest[:id]
    end

    # else Rule 4
    # If there are 100% identical file renames, pick the largest
    matches = diffs.select { |diff| renamed_file?(diff) }
    largest = matches.max { |lhs,rhs|
      same_count(lhs) <=> same_count(rhs)
    }
    unless largest.nil?
      return largest[:id]
    end

    # else Rule 5
    # If current_filename exists (with no diff), pick it
    current_filename_diff = diffs.find { |diff|
      diff_filename(diff) === current_filename
    }
    unless current_filename_diff.nil?
      return current_filename_diff[:id]
    end

    # else Rule 6
    # pick cyber-dojo.sh
    cyber_dojo_sh = diffs.find { |diff|
      diff_filename(diff) === 'cyber-dojo.sh'
    }
    cyber_dojo_sh[:id]
  end

  private

  def diff_filename(diff)
    if deleted_file?(diff)
      diff[:old_filename]
    else
      diff[:new_filename]
    end
  end

  def deleted_file?(diff)
    diff[:type] === 'deleted'
  end

  def renamed_file?(diff)
    diff[:type] === 'renamed'
  end

  def any_extension_match?(diff, filenameExtensions)
    filenameExtensions.any? { |ext|
      diff_filename(diff).end_with?(ext)
    }
  end

  def no_extension_match?(diff, filenameExtensions)
    filenameExtensions.none? { |ext|
      diff_filename(diff).end_with?(ext)
    }
  end

  def change_count(diff)
    diff[:deleted_line_count] + diff[:added_line_count]
  end

  def same_count(diff)
    diff[:same_line_count]
  end

end
