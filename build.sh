#!/bin/bash

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker-compose -f ${my_dir}/docker-compose.yml build
