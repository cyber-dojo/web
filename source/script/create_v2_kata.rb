
def require_source(path)
  require_relative "../app/#{path}"
end

require_source 'services/externals'
include Externals

def create_v2_dashboard()
  puts("create_v2_dashboard")
  
  http = saver.instance_variable_get(:@http)
  v0_kid = '5U2J18'
  manifest = http.get('kata_manifest', {id: v0_kid})
  manifest['version'] = 2
  v2_kid = http.post('kata_create', {manifest: manifest})
  puts(v2_kid)

end

create_v2_dashboard
