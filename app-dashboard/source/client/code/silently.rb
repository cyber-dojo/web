def silently
  old_stderr = $stderr
  $stderr = StringIO.new
  yield
ensure
  $stderr = old_stderr
end
