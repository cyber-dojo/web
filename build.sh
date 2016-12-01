#!/bin/bash

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker-compose --file ${my_dir}/docker-compose.yml build
