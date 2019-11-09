
Originally all requests coming into a controller would
use the models/ abstractions. However, this slowed down
response times since it would result in numerous non-batched
requests to dependent services, particularly storer/saver.
Consequently, saver has been reworked to include a batch()
method in its API. Most requests coming into a controller
no longer use the models/ abstractions; instead they use
saver's batch() method and forward data directly to the views.
Most but not all. So currently some of the models/ code is 
only used in tests.
