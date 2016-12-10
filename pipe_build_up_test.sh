#!/bin/bash
set -e

./build.sh
./up.sh
./test.sh ${*}
