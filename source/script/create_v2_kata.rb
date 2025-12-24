
def require_source(path)
  require_relative "../app/#{path}"
end

require_source 'services/externals'
include Externals

$http = saver.instance_variable_get(:@http)

def create_v2_kata()
  v0_id = '5U2J18'
  manifest = $http.get('kata_manifest', {id: v0_id})
  manifest['version'] = 2
  manifest.delete('group_id')
  manifest.delete('group_index')
  
  id = $http.post('kata_create', {manifest: manifest})
  files = $http.get('kata_event', {id:id, index:0 })['files']
  # [ bats_help.txt cyber-dojo.sh hiker.sh readme.txt test_hiker.sh ]
  hiker_sh = files['hiker.sh']['content'] # includes '6 * 9'
  index = 1

  index = red_traffic_light(id, index, files)

  files['hiker.sh']['content'] = hiker_sh.sub('6 * 9', '6 * 9s')
  index = amber_traffic_light(id, index, files)

  files['hiker.sh']['content'] = hiker_sh.sub('6 * 9', '6 * 7')
  index = green_traffic_light(id, index, files)

  print(id)
end

def red_traffic_light(id, index, files)
  stdout = {'content' => 'expected [42] but was [54]', 'truncated' => false}
  stderr = {'content' => '', 'truncated' => false}
  status = 1
  $http.post('kata_ran_tests', {
    id: id,
    index: index,
    files: files,
    stdout: stdout,
    stderr: stderr,
    status: status,
    summary: {'colour' => 'red', 'predicted' => 'none'}
  })
end

def amber_traffic_light(id, index, files)
  stdout = {'content' => 'expected [42] but was []', 'truncated' => false}
  stderr = {'content' => 'value too great for base (error token is "9s")', 'truncated' => false}
  status = 1
  $http.post('kata_ran_tests', {
    id: id,
    index: index,
    files: files,
    stdout: stdout,
    stderr: stderr,
    status: status,
    summary: {'colour' => 'amber', 'predicted' => 'none'}
  })
end

def green_traffic_light(id, index, files)
  stdout = {'content' => 'Overall result: SUCCESS', 'truncated' => false}
  stderr = {'content' => '', 'truncated' => false}
  status = 0
  $http.post('kata_ran_tests', {
    id: id,
    index: index,
    files: files,
    stdout: stdout,
    stderr: stderr,
    status: status,
    summary: {'colour' => 'green', 'predicted' => 'none'}
  })
end

create_v2_kata
