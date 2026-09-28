# This has to run inside a docker-container so it can call the dependent services

# This script is the only caller of the post half of the app's http chain:
# ExternalHttp#post, HttpJsonHash::Requester#post and
# HttpJsonHash::Unpacker#post. The dashboard itself only reads from the saver,
# so those three methods are live code that no test exercises, and they carry
# simplecov:disable markers pointing back here.

require 'json'
require 'securerandom'
require_relative 'external_differ'
require_relative 'external_saver'

def create_v2_dashboard
  p('Creating v2 dashboard')
  saver = ExternalSaver.new
  manifest = saver.group_manifest('REf1t8')
  manifest['version'] = 2

  gid = saver.group_create(manifest)
  puts("Group ID=#{gid}")
  kid = saver.group_join(gid)
  puts("Kata ID=#{kid}")
  # { index:0, event:created }

  # This kata is one writer (one laptop_id); tab_seq counts its writes 1, 2, 3.
  laptop_id = SecureRandom.hex(32)

  files = manifest['visible_files']
  new_filename = 'wibble.txt'
  files['cyber-dojo.sh']['content'] += '#comment'
  saver.kata_file_create(kid, files, new_filename, laptop_id, 1)
  # VIP that new_filename is added only now.
  files[new_filename] = { 'content' => '' }
  # { index:1, event:edit-file, filename:'cyber-dojo.sh'}
  # { index:2, event:create-file, filename:'wibble.txt'}

  files[new_filename]['content'] += 'Hello world'
  saver.kata_file_edit(kid, files, laptop_id, 2)
  # { index:3, event:edit-file, filename:'wibble.txt'}

  stdout = { 'content' => '', 'truncated' => false }
  stderr = { 'content' => '', 'truncated' => false }
  status = '0'
  summary = {
    duration: 1.234,
    colour: 'red',
    predicted: 'none',
    revert_if_wrong: false
  }
  saver.kata_ran_tests(kid, files, stdout, stderr, status, summary, laptop_id, 3)
  # { index:4, colour:red }

  # index = saver.kata_file_delete(kid, index, files, filename)
  # index = saver.kata_file_rename(kid, index, files, old_filename, new_filename)

  events = saver.kata_events(kid)
  puts(events)
  # { index:0, event:created }
  # { index:1, event:edit-file, filename:'cyber-dojo.sh'}
  # { index:2, event:create-file, filename:'wibble.txt'}
  # { index:3, event:edit-file, filename:'wibble.txt'}
  # { index:4, colour:red }

  puts("http://localhost:80/dashboard/show/#{gid}?auto_refresh=false&minute_columns=true")

  # The red traffic-light's tool-top gives plain red. Clicking it takes you to
  # http://localhost/review/show/L5Gw6Y?was_index=3&now_index=4
  # which is 3->4 which has no actual diff.
  # Changing the URL to 
  # http://localhost/review/show/L5Gw6Y?was_index=0&now_index=4
  # gives the same
  #
  # So initial impressions look like differ is not working *across* the new non-test events.
  # Next step could be to add external-differ and see what various diffs are.

  show_diff(kid, 0, 1)
  show_diff(kid, 1, 2)
  show_diff(kid, 2, 3)
  show_diff(kid, 3, 4)
  show_diff(kid, 0, 4)

  # I think there is an error in saver.kata_file_create()
  # It is showing
  # Diff 0 - 1
  # ----{"type"=>"changed", "new_filename"=>"cyber-dojo.sh", "old_filename"=>"cyber-dojo.sh", ...
  #
  # Diff 1 - 2
  # ----{"type"=>"created", "new_filename"=>"wibble.txt", "old_filename"=>nil, ...
  #
  # Diff 2 - 3
  # ----{"type"=>"changed", "new_filename"=>"wibble.txt", "old_filename"=>"wibble.txt", ...
  #
  # Diff 3 - 4
  # Nothing - it is now a pure test-outcome event
  #
  # ~~~~~~~~~~~~~~~~~
  #
  # Diff 0 - 4
  # ----{"type"=>"changed", "new_filename"=>"cyber-dojo.sh", "old_filename"=>"cyber-dojo.sh", ...
  # ----{"type"=>"created", "new_filename"=>"wibble.txt", "old_filename"=>nil, ...
  #
  # This looks right.
  # What about in web's review page? 
  # Diff 0 - 1
  # http://localhost/review/show/SR3Fxc?was_index=0&now_index=1
  # Correctly showing cyber-dojo.sh has changed
  #
  # Diff 1 - 2
  # http://localhost/review/show/SR3Fxc?was_index=1&now_index=2
  # Correctly showing wibble.txt was created, but not selected (cyber-dojo.sh is)
  # See web repo, source/server/web/views/review/lib/_pick_file.html.erb
  # which shows a bias to not selecting .txt files.
  #
  # Diff 2 - 3
  # http://localhost/review/show/SR3Fxc?was_index=2&now_index=3
  # Correctly showing wibble.txt is edited
  #
  # Diff 3 - 4
  # http://localhost/review/show/SR3Fxc?was_index=3&now_index=4
  # Correctly showing no diff, index=4 on review page, red traffic-light has underbar.
  #
  # Diff 0 - 4
  # http://localhost/review/show/SR3Fxc?was_index=0&now_index=4
  # Incorrectly showing same as 3-4
  # Is this because web's review page is actually changing this to 3-4?
  #
  # Diff 0 - 3
  # http://localhost/review/show/SR3Fxc?was_index=0&now_index=3
  # Incorrectly showing same as 2-3
  # Again suggesting web's review has changed this to 2-3
  #
  # Spiked web image. Retrying
  # Diff 0 - 4
  # http://localhost/review/show/SR3Fxc?was_index=0&now_index=4
  # Correctly showing wibble.txt created and cyber-dojo.sh edited
  # and index=4, and underbar on red traffic-light
  #
  # Diff 0 - 3
  # http://localhost/review/show/SR3Fxc?was_index=0&now_index=3
  # Correctly showing wibble.txt created and cyber-dojo.sh edited
  # and index=3, and NO underbar on red traffic-light


end

def show_diff(id, was_index, now_index)
  differ = ExternalDiffer.new
  diff = differ.diff_summary(id, was_index, now_index)
  puts()
  puts("Diff #{was_index} - #{now_index}")
  diff.each do |entry|
    if entry["type"] != "unchanged"
      puts("----#{entry}")
    end
  end
end

create_v2_dashboard
