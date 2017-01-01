
filename = ENV['COVERAGE_DIR'] + '/index.html'
cwd = ARGV[0]                 # eg app_lib
filter = cwd.sub('_','/')     # eg app/lib
flat = filter.sub('/','')     # eg applib


html = IO.popen("cat #{filename}").read
# guard against invalid byte sequence
html = html.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
html = html.encode('UTF-8', 'UTF-16')

pattern = /<div class=\"file_list_container\" id=\"#{flat}\">
\s*<h2>\s*<span class=\"group_name\">#{filter}<\/span>
\s*\(<span class=\"covered_percent\"><span class=\"\w+\">([\d\.]*)\%/m

r = html.match(pattern)

puts "Coverage of #{filter} = #{r[1]}%"
