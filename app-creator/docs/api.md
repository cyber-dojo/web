# API
- - - -
## POST group_create_custom(display_names,options)
Creates a new group exercise from the [custom-start-points](https://github.com/cyber-dojo/custom-start-points) manifest whose key is `display_names[0]`, and returns its id.
- parameters [(JSON-in)](#json-in)
  * **display_names:[String...]**.
  The names of [custom-start-points](https://github.com/cyber-dojo/custom-start-points) manifests.  
  For example, `["Java Countdown, Round 1"]`.
  At present only `display_names[0]` is used.
  The array is for a planned feature.
  * **options:Hash[String=>Boolean]**.
  Currently unused (and defaulted). For a planned feature.
- returns [(JSON-out)](#json-out)
  * the new exercise's id.
- example
  ```bash
  $ curl \
    --data '{"display_names":["Java Countdown, Round 1"]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/group_create_custom

  {"group_create_custom":"P0R0cU"}
  ```

- - - -
## POST kata_create_custom(display_name,options)
Creates a new individual exercise from the [custom-start-points](https://github.com/cyber-dojo/custom-start-points) manifest whose key is `display_name`, and returns its id.
- parameters [(JSON-in)](#json-in)
  * **display_name:String**.
  The name of a [custom-start-points](https://github.com/cyber-dojo/custom-start-points) manifest.
  For example, `"Java Countdown, Round 2"`.
  * **options:Hash[String=>Boolean]**.
  Currently unused (and defaulted). For a planned feature.
- returns [(JSON-out)](#json-out)
  * the new exercise's id.
- example
  ```bash
  $ curl \
    --data '{"display_name":"Java Countdown, Round 2"}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/kata_create_custom

  {"kata_create_custom":"8Ey4xK"}
  ```

- - - -
## POST group_create(exercise_name,language_name,options)
Creates a new group exercise (a bare `Group_v2`) by combining the [exercises-start-points](https://github.com/cyber-dojo/exercises-start-points) manifest
whose key is `exercise_name` with the [languages-start-points](https://github.com/cyber-dojo/languages-start-points) manifest
whose key is `language_name`, and returns its id. This is the single-LTF path; for
2 to 5 LTFs use `cluster_create` (below).
- parameters [(JSON-in)](#json-in)
  * **exercise_name:String**.
  The name of an [exercises-start-points](https://github.com/cyber-dojo/exercises-start-points) manifest.  
  For example, `"Fizz Buzz"`
  * **language_name:String**.
  The name of a [languages-start-points](https://github.com/cyber-dojo/languages-start-points) manifest.  
  For example, `"C#, NUnit"`.
  * **options:Hash[String=>Boolean]**.
  Currently unused (and defaulted). For a planned feature.
- returns [(JSON-out)](#json-out)
  * the new group's id.
- example
  ```bash
  $ curl \
    --data '{"exercise_name":"Fizz Buzz","language_name":"C#, NUnit"}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/group_create

  {"group_create":"MwA7SJ"}
  ```

- - - -
## POST cluster_create(exercise_name,language_names,options)
Creates a **cluster** (the saver's multi-LTF mechanism) by combining the [exercises-start-points](https://github.com/cyber-dojo/exercises-start-points) manifest
whose key is `exercise_name` with the 2 to 5 [languages-start-points](https://github.com/cyber-dojo/languages-start-points) manifests
whose keys are in `language_names`, and returns the cluster's id. One child group is
created per LTF, all sharing `exercise_name`; a joiner later picks one LTF, and the
same LTF may appear more than once.
- parameters [(JSON-in)](#json-in)
  * **exercise_name:String**.
  The name of an [exercises-start-points](https://github.com/cyber-dojo/exercises-start-points) manifest.  
  For example, `"Fizz Buzz"`
  * **language_names:[String...]**.
  The names of 2 to 5 [languages-start-points](https://github.com/cyber-dojo/languages-start-points) manifests.  
  For example, `["Python, pytest", "Ruby, MiniTest"]`.
  Display names can themselves contain commas (e.g. `"JavaScript, Mocha, Chai, Sinon"`),
  so this is always a JSON array, never a delimited string.
  * **options:Hash[String=>Boolean]**.
  Currently unused (and defaulted). For a planned feature.
- returns [(JSON-out)](#json-out)
  * the new cluster's id.
- example
  ```bash
  $ curl \
    --data '{"exercise_name":"Fizz Buzz","language_names":["Python, pytest","Ruby, MiniTest"]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/cluster_create

  {"cluster_create":"K2p9Lm"}
  ```

- - - -
## POST kata_create(exercise_name,language_name,options)
Creates a new individual exercise by combining the [exercises-start-points](https://github.com/cyber-dojo/exercises-start-points) manifest whose key is `exercise_name` with the
[languages-start-points](https://github.com/cyber-dojo/languages-start-points) manifest
whose key is `language_name`, and returns its id.
- parameters [(JSON-in)](#json-in)
  * **exercise_name:String**.
  The name of an [exercises-start-points](https://github.com/cyber-dojo/exercises-start-points) manifest.
  For example `"Fizz Buzz"`.
  * **language_name:String**.
  The name of a [languages-start-points](https://github.com/cyber-dojo/languages-start-points) manifest.
  For example, `"C#, NUnit"`.
  * **options:Hash[String=>Boolean]**.
  Currently unused (and defaulted). For a planned feature.
- returns [(JSON-out)](#json-out)
  * the new exercise's id.
- example
  ```bash
  $ curl \
    --data '{"exercise_name":"Fizz Buzz","language_name":"C#, NUnit"}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/kata_create

  {"kata_create":"UrNKPr"}
  ```

- - - -
## GET ready?
Tests if the service is ready to handle requests.
Used as a [Kubernetes](https://kubernetes.io/) readiness probe.
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * **true** if the service is ready
  * **false** if the service is not ready
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/ready?

  {"ready?":false}
  ```

- - - -
## GET alive?
Tests if the service is alive.
Used as a [Kubernetes](https://kubernetes.io/) liveness probe.  
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * **true**
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/alive?

  {"alive?":true}
  ```

- - - -
## GET sha
The git commit sha used to create the Docker image.
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * the 40 character commit sha string.
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/sha

  {"sha":"41d7e6068ab75716e4c7b9262a3a44323b4d1448"}
  ```

- - - -
## JSON in
- All methods pass any arguments as a json hash in the http request body.
  * If there are no arguments you can use `''` (which is the default
    for `curl --data`) instead of `'{}'`.

- - - -
## JSON out      
- All methods return a json hash in the http response body.
  * If the method completes, a string key equals the method's name. eg
    ```bash
    $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/ready?

    {"ready?":true}
    ```
  * If the method raises an exception, a string key equals `"exception"`, with
    a json-hash as its value. eg
    ```bash
    $ curl --silent -X POST http://${IP_ADDRESS}:${PORT}/group_create_custom | jq      

    {
      "exception": {
        "path": "/group_create_custom",
        "body": "",
        "class": "CreatorService",
        "message": "...",
        "backtrace": [
          ...
          "/usr/bin/rackup:23:in `<main>'"
        ]
      }
    }
    ```
