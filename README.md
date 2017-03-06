
If you're a developer wanting to build your own cyber-dojo server from source [start here](https://github.com/cyber-dojo/home/tree/master/dev).

[![Build Status](https://travis-ci.org/cyber-dojo/web.svg?branch=master)](https://travis-ci.org/cyber-dojo/web)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png" alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

- The main web-server micro-service for [cyber-dojo](http://cyber-dojo.org).
- Uses the [runner](https://github.com/cyber-dojo/runner) to run each avatar's tests.
- Uses the [storer](https://github.com/cyber-dojo/storer) to save the code/tests associated with each avatar's test.
- Uses the [differ](https://github.com/cyber-dojo/differ) to diff the code/tests in successive avatar's tests.
