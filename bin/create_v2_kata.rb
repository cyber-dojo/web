
def require_source(path)
  require_relative "../app/#{path}"
end

require 'securerandom'
require_source 'services/externals'
include Externals

$http = saver.instance_variable_get(:@http)

# One avatar is one writer: a fixed laptop_id (a browser profile) plus a
# monotonic tab_seq advanced on every write, so same-colour writes never
# collide on the saver's (laptop_id, tab_seq, colour) idempotency key.
class Writer
  attr_reader :laptop_id

  # Mints a fresh browser-profile laptop_id; the tab counter starts at 0.
  def initialize
    @laptop_id = SecureRandom.hex(32)
    @tab_seq = 0
  end

  # Advances to and returns this writer's next tab_seq (its first write is 1).
  def next_tab_seq
    @tab_seq += 1
  end
end

def create_v2_kata(count)
  v0_id = '5U2J18'
  manifest = $http.get('kata_manifest', {id: v0_id})
  manifest['version'] = 2
  manifest.delete('group_id')
  manifest.delete('group_index')
  gid = $http.post('group_create', {manifest: manifest})
  create_avatar(gid, inter_test_events=false, count)
  id = create_avatar(gid, inter_test_events=true, count)
  print(id)
end

def create_avatar(gid, inter_test_events, count)
  id = $http.post('group_join', {id: gid})
  files = $http.get('kata_event', {id:id, index:0 })['files']
  # [ bats_help.txt cyber-dojo.sh hiker.sh readme.txt test_hiker.sh ]
  original_hiker_sh = files['hiker.sh']['content']

  # One avatar is one writer; its tab_seq counts every write it makes here.
  writer = Writer.new
  count.times do
    files['hiker.sh']['content'] = original_hiker_sh
    if inter_test_events
      file_create(id, files, 'wibble.txt', writer)
    end
    red_traffic_light(id, files, writer)
    if inter_test_events
      file_edit(id, files, writer)
      file_rename(id, files, 'wibble.txt', 'wibble2.txt', writer)
    end
    amber_traffic_light(id, files, writer)
    if inter_test_events
      file_delete(id, files, 'wibble2.txt', writer)
    end
    green_traffic_light(id, files, writer)
    if inter_test_events
      file_edit(id, files, writer)
    end
  end
  id
end

# - - - - - - - - - - - - - - - - - - - - -

def file_create(id, files, filename, writer)
  $http.post('kata_file_create', {
    id: id,
    files: files,
    filename: filename,
    laptop_id: writer.laptop_id,
    tab_seq: writer.next_tab_seq
  })
  files[filename] = file('')
end

def file_delete(id, files, filename, writer)
  $http.post('kata_file_delete', {
    id: id,
    files: files,
    filename: filename,
    laptop_id: writer.laptop_id,
    tab_seq: writer.next_tab_seq
  })
  files.delete(filename)
end

def file_rename(id, files, old_filename, new_filename, writer)
  $http.post('kata_file_rename', {
    id: id,
    files: files,
    old_filename: old_filename,
    new_filename: new_filename,
    laptop_id: writer.laptop_id,
    tab_seq: writer.next_tab_seq
  })
  files[new_filename] = file(files[old_filename]['content'])
  files.delete(old_filename)
end

def file_edit(id, files, writer)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh + "\n#comment"
  $http.post('kata_file_edit', {
    id: id,
    files: files,
    laptop_id: writer.laptop_id,
    tab_seq: writer.next_tab_seq
  })
end

# - - - - - - - - - - - - - - - - - - - - -

def red_traffic_light(id, files, writer)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh.sub('6 * 9', '6 * 99')
  $http.post('kata_ran_tests', {
    id: id,
    files: files,
    stdout: file('expected [42] but was [54]'),
    stderr: file(''),
    status: 1,
    summary: colour('red'),
    laptop_id: writer.laptop_id,
    tab_seq: writer.next_tab_seq
  })
end

def amber_traffic_light(id, files, writer)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh.sub('6 * 99', '6 * 99s')
  $http.post('kata_ran_tests', {
    id: id,
    files: files,
    stdout: file('expected [42] but was []'),
    stderr: file('value too great for base (error token is "9s")'),
    status: 1,
    summary: colour('amber'),
    laptop_id: writer.laptop_id,
    tab_seq: writer.next_tab_seq
  })
end

def green_traffic_light(id, files, writer)
  hiker_sh = files['hiker.sh']['content']
  files['hiker.sh']['content'] = hiker_sh.sub('6 * 99s', '6 * 7')
  $http.post('kata_ran_tests', {
    id: id,
    files: files,
    stdout: file('Overall result: SUCCESS'),
    stderr: file(''),
    status: 0,
    summary: colour('green'),
    laptop_id: writer.laptop_id,
    tab_seq: writer.next_tab_seq
  })
end

def colour(hue)
  { 'colour' => hue, 'predicted' => 'none' }
end

def file(content)
  { 'content' => content, 'truncated' => false }
end

# - - - - - - - - - - - - - - - - - - - - -

create_v2_kata(ARGV.fetch(0, '1').to_i)
