# frozen_string_literal: true

module ReviewFilePicker # mix-in

  module_function

  def pick_file_id(diffs, current_filename, filenameExtensions)
    # TODO: Revisit now the review page shows if files are deleted|created|renamed
    # For example, the diff could be for a 100% identical renamed file.

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
      anyExtensionMatch?(diff, filenameExtensions) &&
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
      noExtensionMatch?(diff, filenameExtensions) &&
        change_count(diff) > 0
    }
    largest = matches.max { |lhs,rhs|
      change_count(lhs) <=> change_count(rhs)
    }
    unless largest.nil?
      return largest[:id]
    end

    # There are no diffs! [X]

    # else Rule 4
    # If current_filename exists (with no diff), pick it
    current_filename_diff = diffs.find { |diff|
      diff_filename(diff) === current_filename
    }
    unless current_filename_diff.nil?
      return current_filename_diff[:id]
    end

    # else Rule 5
    # Pick largest of stdout/stderr, if it has content
    stdout = diffs.find { |diff| diff_filename(diff) === 'stdout' }
    stderr = diffs.find { |diff| diff_filename(diff) === 'stderr' }
    stdout_size = stdout[:content].size
    stderr_size = stderr[:content].size
    if (stdout_size > 0 && stdout_size >= stderr_size)
      return stdout[:id]
    end
    if (stderr_size > 0 && stderr_size >= stdout_size)
      return stderr[:id]
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
    if diff[:type] === "deleted"
      diff[:old_filename]
    else
      diff[:new_filename]
    end
  end

  def anyExtensionMatch?(diff, filenameExtensions)
    filenameExtensions.any? { |ext|
      diff_filename(diff).end_with?(ext)
    }
  end

  def noExtensionMatch?(diff, filenameExtensions)
    filenameExtensions.none? { |ext|
      diff_filename(diff).end_with?(ext)
    }
  end

  def change_count(diff)
    diff[:deleted_line_count] + diff[:added_line_count]
  end

end
