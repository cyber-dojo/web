
* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

<img width="707" alt="cyber-dojo-screen-shot" src="https://cloud.githubusercontent.com/assets/252118/25101292/9bdca322-23ab-11e7-9acb-0aa5f9c5e005.png">

- - - -

[![Build Status](https://travis-ci.org/cyber-dojo/web.svg?branch=master)](https://travis-ci.org/cyber-dojo/web)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png" alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

- The main web-server micro-service for [cyber-dojo](http://cyber-dojo.org).
- Uses [runner](https://github.com/cyber-dojo/runner) to run some avatar's tests statefully.
- Uses [runner_stateless](https://github.com/cyber-dojo/runner) to run some avatar's tests statelessly.
- Uses [storer](https://github.com/cyber-dojo/storer) to save the code/tests associated with each avatar's test.
- Uses [differ](https://github.com/cyber-dojo/differ) to diff the code/tests in successive avatar's tests.
- Uses [zipper](https://github.com/cyber-dojo/zipper) to create tgz kata/avatar downloads
- Uses [nginx](https://github.com/cyber-dojo/nginx) for security and to cache image assets
- Uses [prometheus](https://github.com/cyber-dojo/prometheus) to store monitoring data
- Uses [grafana](https://github.com/cyber-dojo/prometheus) to display monitoring data
