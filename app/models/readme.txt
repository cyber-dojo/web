
The plan is to

- refactor app_models/ to use model-service DONE
- use model-service instead of saver-service in web DONE
- use model-service instead of saver-service in dashboard ONGOING

- use model-service in kata-controller DONE
- use model-service in review-controller DONE (except for run_tests())

- use model-service in kata JS and make clean separation from UX
- use model-service in review JS

- pull the saver microservice into the model microservice
- drop the saver microservice
