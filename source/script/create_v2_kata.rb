
def require_source(path)
  require_relative "../app/#{path}"
end

require_source 'services/externals'
include Externals

def create_v2_kata()
  puts("create_v2_kata")  
  http = saver.instance_variable_get(:@http)
  v0_kid = '5U2J18'
  manifest = http.get('kata_manifest', {id: v0_kid})
  manifest['version'] = 2
  v2_kid = http.post('kata_create', {manifest: manifest})
  puts(v2_kid)
  files = http.get('kata_event', {id:v2_kid, index:0 })['files']
  # [ bats_help.txt cyber-dojo.sh hiker.sh readme.txt test_hiker.sh ]
  hiker_sh = files['hiker.sh']['content'] # includes '6 * 9'

end

create_v2_kata
