#!/bin/bash

# Script to copy saved local katas into cyber-dojo-web data-container.
# Useful for
# 1. cyber-dojo.org so all katas are inside the data-container again
# 2. a stand-alone script to be used instead of the complexity inside cli/cyber-dojo.sh
# 3. to copy katas saved from short-lived servers into long-lived servers.

# Note. this script does not delete the dir after transferring it.
# If you are transferring a large amount of data you need a large
# amount of free disk space.
# Note. this script does not ensure the copied files inside the
# cyber-dojo-web data container have the correct rights. You may need to
# add a [chown -R cyber-dojo] docker command

src_path=/home/jrbjagger/katas
dst_path=/usr/src/cyber-dojo/katas

for i in {0..255}
do
  hex=`printf '%02X' ${i}`
  echo ${hex} # eg 3F
  tar -c -f - -C ${src_path} ${hex} | sudo docker exec -i cyber-dojo-web tar -x -f - -C ${dst_path}
  sleep 5s
done
