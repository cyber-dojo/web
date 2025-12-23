
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
  
  id = http.post('kata_create', {manifest: manifest})
  files = http.get('kata_event', {id:id, index:0 })['files']
  # [ bats_help.txt cyber-dojo.sh hiker.sh readme.txt test_hiker.sh ]
  hiker_sh = files['hiker.sh']['content'] # includes '6 * 9'

  stdout = {'content' => 'expected [42] but was [54]', 'truncated' => false}
  stderr = {'content' => '', 'truncated' => false}
  status = 1
  http.post('kata_ran_tests', {
    id: id,
    index: 1,
    files: files,
    stdout: stdout,
    stderr: stderr,
    status: status,
    summary: {'colour' => 'red', 'predicted' => 'none'}
  })

  files['hiker.sh']['content'] = hiker_sh.sub('6 * 9', '6 * 9s')
  stdout = {'content' => 'expected [42] but was []', 'truncated' => false}
  stderr = {'content' => 'value too great for base (error token is "9s")', 'truncated' => false}
  status = 1
  http.post('kata_ran_tests', {
    id: id,
    index: 2,
    files: files,
    stdout: stdout,
    stderr: stderr,
    status: status,
    summary: {'colour' => 'amber', 'predicted' => 'none'}
  })

  files['hiker.sh']['content'] = hiker_sh.sub('6 * 9', '6 * 7')
  stdout = {'content' => 'Overall result: SUCCESS', 'truncated' => false}
  stderr = {'content' => '', 'truncated' => false}
  status = 0
  http.post('kata_ran_tests', {
    id: id,
    index: 3,
    files: files,
    stdout: stdout,
    stderr: stderr,
    status: status,
    summary: {'colour' => 'green', 'predicted' => 'none'}
  })

  events = http.get('kata_events', {id:id})
  puts(events)
  puts(id)

end

create_v2_kata
