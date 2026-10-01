This cyber-dojo/ dir holds saver data, laid out as saver stores it on disk, so
it is tar-piped into the saver container at /cyber-dojo rather than copied (you
cannot docker cp to a tmpfs).

Three callers do that, which is why this lives at test/ root rather than under
test/server or test/client:
  copy_saver_test_data()    in bin/run_tests_in_container.sh - both test suites
  copy_in_saver_test_data() in bin/copy_in_saver_test_data.sh - bin/demo.sh

saver data, version 0
---------------------

/cyber-dojo/groups/Fx/Ww/rr
/cyber-dojo/groups/Fx/Ww/rr/32/kata.id ==> 5rTJv5  (32==mouse)
/cyber-dojo/katas/5r/TJ/v5

/cyber-dojo/groups/ch/y6/BJ
/cyber-dojo/groups/ch/y6/BJ/11/kata.id ==> k5ZTk0  (11==dolphin)
/cyber-dojo/katas/k5/ZT/k0


saver data, version 1
---------------------

/cyber-dojo/groups/RE/f1/t8/44
/cyber-dojo/groups/RE/f1/t8/katas.txt
/cyber-dojo/groups/RE/f1/t8/manifest.json   (44==rhino ==> 5U2J18)

/cyber-dojo/katas/5U/2J/18/0.event.json
/cyber-dojo/katas/5U/2J/18/1.event.json
/cyber-dojo/katas/5U/2J/18/2.event.json
/cyber-dojo/katas/5U/2J/18/3.event.json
/cyber-dojo/katas/5U/2J/18/events.json
/cyber-dojo/katas/5U/2J/18/manifest.json


/cyber-dojo/katas/H8/NA/vN/0.event.json             (single kata)
/cyber-dojo/katas/H8/NA/vN/1.event.json
/cyber-dojo/katas/H8/NA/vN/events.json
/cyber-dojo/katas/H8/NA/vN/manifest.json


/cyber-dojo/katas/RN/Cz/Ur/0.event.json             (single kata)
...
/cyber-dojo/katas/RN/Cz/Ur/14.event.json
