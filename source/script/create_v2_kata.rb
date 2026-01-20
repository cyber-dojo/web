
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
  gid = $http.post('group_create', {manifest: manifest})
  create_avatar(gid, inter_test_events=false)
  id = create_avatar(gid, inter_test_events=true)
  print(id)
end

def create_avatar(gid, inter_test_events)
  id = $http.post('group_join', {id: gid})  
  files = $http.get('kata_event', {id:id, index:0 })['files']
  # [ bats_help.txt cyber-dojo.sh hiker.sh readme.txt test_hiker.sh ]

  index = 1
  if inter_test_events
    index = file_create(id, index, files, 'wibble.txt')
  end
  index = red_traffic_light(id, index, files)
  if inter_test_events
    index = file_edit(id, index, files)
    index = file_rename(id, index, files, 'readme.txt', 'readme2.txt')
  end
  index = amber_traffic_light(id, index, files)
  if inter_test_events
    index = file_delete(id, index, files, 'readme2.txt')
  end
  index = green_traffic_light(id, index, files)
  if inter_test_events
    index = file_edit(id, index, files)
  end
  id
end

# - - - - - - - - - - - - - - - - - - - - -

def file_create(id, index, files, filename)
  next_index = $http.post('kata_file_create', {
    id: id,
    index: index,
    files: files,
    filename: filename
  })
  files[filename] = file('')
  next_index
end

def file_delete(id, index, files, filename)
  next_index = $http.post('kata_file_delete', {
    id: id,
    index: index,
    files: files,
    filename: filename
  })
  files.delete(filename)
  next_index
end

def file_rename(id, index, files, old_filename, new_filename)
  next_index = $http.post('kata_file_rename', {
    id: id,
    index: index,
    files: files,
    old_filename: old_filename,
    new_filename: new_filename
  })
  files[new_filename] = file(files[old_filename]['content'])
  files.delete(old_filename)
  next_index
end

def file_edit(id, index, files)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh + "\n#comment"
  next_index = $http.post('kata_file_edit', {
    id: id,
    index: index,
    files: files
  })
  next_index
end

# - - - - - - - - - - - - - - - - - - - - -

def red_traffic_light(id, index, files)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh.sub('6 * 9', '6 * 99')
  $http.post('kata_ran_tests2', {
    id: id,
    index: index,
    files: files,
    stdout: file('expected [42] but was [54]'),
    stderr: file(''),
    status: 1,
    summary: colour('red')
  })['next_index']
end

def amber_traffic_light(id, index, files)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh.sub('6 * 99', '6 * 99s')
  $http.post('kata_ran_tests2', {
    id: id,
    index: index,
    files: files,
    stdout: file('expected [42] but was []'),
    stderr: file('value too great for base (error token is "9s")'),
    status: 1,
    summary: colour('amber')
  })['next_index']
end

def green_traffic_light(id, index, files)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh.sub('6 * 99s', '6 * 7')
  $http.post('kata_ran_tests2', {
    id: id,
    index: index,
    files: files,
    stdout: file('Overall result: SUCCESS'),
    stderr: file(''),
    status: 0,
    summary: colour('green')
  })['next_index']
end

def colour(hue)
  { 'colour' => hue, 'predicted' => 'none' }
end

def file(content)
  { 'content' => content, 'truncated' => false }
end

# - - - - - - - - - - - - - - - - - - - - -

create_v2_kata
