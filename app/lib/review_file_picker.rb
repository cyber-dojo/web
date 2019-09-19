# frozen_string_literal: true

module ReviewFilePicker # mix-in

  module_function

  def pick_file_id(diffs, current_filename, filenameExtensions)
    # Rule 1
    # If the current-filename exists and has a diff, pick it.
    current_filename_diff = diffs.find { |diff|
      diff[:filename] === current_filename &&
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

    # There are no diffs!

    # else Rule 4
    # If current_filename exists (with no diff), pick it
    current_filename_diff = diffs.find { |diff|
      diff[:filename] === current_filename
    }
    unless current_filename_diff.nil?
      return current_filename_diff[:id]
    end

    # else Rule 5
    # Pick largest of stdout/stderr, if it has content
    stdout = diffs.find { |diff| diff[:filename] === 'stdout' }
    stderr = diffs.find { |diff| diff[:filename] === 'stderr' }
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
      diff[:filename] === 'cyber-dojo.sh'
    }
    cyber_dojo_sh[:id]
  end

  def anyExtensionMatch?(diff, filenameExtensions)
    filenameExtensions.any? { |ext|
      diff[:filename].end_with?(ext)
    }
  end

  def noExtensionMatch?(diff, filenameExtensions)
    filenameExtensions.none? { |ext|
      diff[:filename].end_with?(ext)
    }
  end

  def change_count(diff)
    diff[:deleted_line_count] + diff[:added_line_count]
  end

end
