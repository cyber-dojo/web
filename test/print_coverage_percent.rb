
filename = ENV['COVERAGE_DIR'] + '/index.html'
cwd = ARGV[0]                 # eg app_helpers
filter = cwd.sub('_','/')     # eg app/helpers
flat = filter.sub('/','')     # eg apphelpers


html = IO.popen("cat #{filename}").read
# guard against invalid byte sequence
html = html.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
html = html.encode('UTF-8', 'UTF-16')

pattern = /<div class=\"file_list_container\" id=\"#{flat}\">
\s*<h2>\s*<span class=\"group_name\">#{filter}<\/span>
\s*\(<span class=\"covered_percent\">\s*<span class=\"\w+\">\s*([\d\.]*)\%/m

r = html.match(pattern)

puts "Coverage of #{filter} = #{r[1]}%"

# A group matching no files reports 100% covered, which reads as a pass.
# Print its file count too so the summary can tell empty from complete.
files_pattern = /<div class=\"file_list_container\" id=\"#{flat}\">
.*?<b>(\d+)<\/b> files in total/m

f = html.match(files_pattern)

puts "Files of #{filter} = #{f[1]}"
