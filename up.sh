#!/bin/bash
set -e

# You must do a down so the up brings up a new web container
cyber-dojo down
cyber-dojo up
sleep 2
