#!/bin/sh
set -e

# See https://github.com/docker/compose/issues/1393
# See http://stackoverflow.com/questions/35022428
readonly WEB_HOME=/cyber-dojo
rm -f ${WEB_HOME}/tmp/pids/server.pid

export CYBER_DOJO_VERSIONER_CLASS=VersionerService

export CYBER_DOJO_CUSTOM_CLASS=CustomService
export CYBER_DOJO_EXERCISES_CLASS=ExercisesService
export CYBER_DOJO_LANGUAGES_CLASS=LanguagesService

export CYBER_DOJO_SAVER_CLASS=SaverService
export CYBER_DOJO_RUNNER_CLASS=RunnerService
export CYBER_DOJO_DIFFER_CLASS=DifferService
export CYBER_DOJO_ZIPPER_CLASS=ZipperService

export CYBER_DOJO_PORTER_CLASS=PorterService
export CYBER_DOJO_MAPPER_CLASS=MapperService
export CYBER_DOJO_RAGGER_CLASS=RaggerService

rails server \
  --environment=production
