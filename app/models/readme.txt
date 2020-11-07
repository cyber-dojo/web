
Originally all requests coming into a controller would
use the models/ abstractions. However, this slowed down
response times since it would result in numerous non-batched
requests to dependent services, particularly saver.
Consequently, saver has been reworked to include a batch()
method in its API. Most requests coming into a controller
no longer use the models/ abstractions; instead they use
saver's batch() method and forward data directly to the views.
Most but not all. So currently some of the models/ code is
only used in tests. The plan is to
- move all the model/ code into the model microservice
- layer the saver API underneath the model microservice
- drop all other use of the saver microservice
- put the model microservice into the saver microservice
