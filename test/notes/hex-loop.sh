#!/bin/bash

# Script to copy saved local katas into cyber-dojo-web data-container.
# Useful for
# 1. cyber-dojo.org so all katas are inside the data-container again
# 2. a stand-alone script to be used inside of the complexity inside cli/cyber-dojo.sh
# 3. to copy katas saved from custom servers.

# TODO: put a pause after each hex transfer
# TODO: delete from src after transfer (otherwise may run out of disk space)

src_path=/home/jrbjagger/katas
dst_path=/usr/src/cyber-dojo/katas

for i in {0..255}
do
  hex=`printf '%02X' ${i}`
  echo ${hex}
  tar -c -f - -C ${src_path} ${hex} | sudo docker exec -i cyber-dojo-web tar -x -f - -C ${dst_path}
done
