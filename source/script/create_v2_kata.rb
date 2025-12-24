
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
  id = $http.post('group_join', {id: gid})  
  files = $http.get('kata_event', {id:id, index:0 })['files']
  # [ bats_help.txt cyber-dojo.sh hiker.sh readme.txt test_hiker.sh ]

  index = 1
  index = file_create(id, index, files, 'wibble.txt')
  index = red_traffic_light(id, index, files)
  index = file_edit(id, index, files)
  index = file_rename(id, index, files, 'readme.txt', 'readme2.txt')
  index = amber_traffic_light(id, index, files)
  index = file_delete(id, index, files, 'readme2.txt')
  index = green_traffic_light(id, index, files)
  index = file_edit(id, index, files)

  print(id)
end

# - - - - - - - - - - - - - - - - - - - - -

def file_create(id, index, files, filename)
  index = $http.post('kata_file_create', {
    id: id,
    index: index,
    files: files,
    filename: filename
  })
  files[filename] = file('')
  index
end

def file_delete(id, index, files, filename)
  index = $http.post('kata_file_delete', {
    id: id,
    index: index,
    files: files,
    filename: filename
  })
  files.delete(filename)
  index
end

def file_rename(id, index, files, old_filename, new_filename)
  index = $http.post('kata_file_rename', {
    id: id,
    index: index,
    files: files,
    old_filename: old_filename,
    new_filename: new_filename
  })
  files[new_filename] = file(files[old_filename]['content'])
  files.delete(old_filename)
  index
end

def file_edit(id, index, files)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh + "\n#comment"
  index = $http.post('kata_file_edit', {
    id: id,
    index: index,
    files: files
  })
  index
end

# - - - - - - - - - - - - - - - - - - - - -

def red_traffic_light(id, index, files)
  $http.post('kata_ran_tests', {
    id: id,
    index: index,
    files: files,
    stdout: file('expected [42] but was [54]'),
    stderr: file(''),
    status: 1,
    summary: colour('red')
  })
end

def amber_traffic_light(id, index, files)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh.sub('6 * 9', '6 * 9s')
  $http.post('kata_ran_tests', {
    id: id,
    index: index,
    files: files,
    stdout: file('expected [42] but was []'),
    stderr: file('value too great for base (error token is "9s")'),
    status: 1,
    summary: colour('amber')
  })
end

def green_traffic_light(id, index, files)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh.sub('6 * 9', '6 * 7')
  $http.post('kata_ran_tests', {
    id: id,
    index: index,
    files: files,
    stdout: file('Overall result: SUCCESS'),
    stderr: file(''),
    status: 0,
    summary: colour('green')
  })
end

def colour(hue)
  { 'colour' => hue, 'predicted' => 'none' }
end

def file(content)
  { 'content' => content, 'truncated' => false }
end

# - - - - - - - - - - - - - - - - - - - - -

create_v2_kata
