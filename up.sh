#!/bin/sh
set -e

# [1] https://github.com/docker/compose/issues/1393
# [1] http://stackoverflow.com/questions/35022428
readonly WEB_HOME=/cyber-dojo
rm -f ${WEB_HOME}/tmp/pids/server.pid # [1]

export CYBER_DOJO_CUSTOM_START_POINTS_CLASS=CustomStartPointsService
export CYBER_DOJO_EXERCISES_START_POINTS_CLASS=ExercisesStartPointsService
export CYBER_DOJO_LANGUAGES_START_POINTS_CLASS=LanguagesStartPointsService

export CYBER_DOJO_AVATARS_CLASS=AvatarsService
export CYBER_DOJO_DIFFER_CLASS=DifferService
export CYBER_DOJO_MODEL_CLASS=ModelService
export CYBER_DOJO_RUNNER_CLASS=RunnerService
export CYBER_DOJO_SAVER_CLASS=SaverService

rails server \
  --environment=production
