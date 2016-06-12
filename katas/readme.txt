
Ensure a git clone of the main cyber-dojo server repository
include an empty katas folder.

An (initially) empty katas folder is needed if you are running
a local cyber-dojo server (using script/dev-server.sh)

A katas folder is not needed if you are running a dockerized web server
(using app/docker/cyber-dojo). This is because docker-compose.yml
is assumed to use volume-mount or volumes-from to map the location
of where the katas live.
