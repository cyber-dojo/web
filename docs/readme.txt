
The web repo is currently messy as it is part way through a large refactoring.
The /app/models/ code is slowly being migrated to the model http-service.
See https://github.com/cyber-dojo/model

The plan is...

o) kata.ran_tests() and kata.revert() call directly to model.ran_tests()
   which would be better renamed to model.test_event()

o) the reverter/revert route delegates to a kata.revert()
   and reverter controller is dropped.

o) the dashboard to become its own sinatra http-service too.
   See https://github.com/cyber-dojo-retired/dashboard
   This will also need the app-bar to become a shareable service.
   It will also need the traffic-light hover-tip to be a shareable service.
   dashboard_controller is dropped.

That will leave...

o) differ/diff
   This partly uses the http differ service's differ.diff() method already.
   The differ http service will become a sinatra server and service the diff html.
   This will require it to access the traffic-light hover-tip.

o) review/show
   The .js code for the review is shared by kata/edit
   So it will need to become a shared service, which kata/edit can consume.
   Then reviewer will become a sinatra server serving its html too.

Byeond this I would like to...

o) make sure model service is the only code using saver.
o) move model's API (and code) into saver.
o) make model delegate === to saver.
o) rename saver to model
o) drop model

Then
o) Think about splitting the storage.
o) group+kata in one place, events in another?
o) Create a new version=2 format inside model/ that stores in git
