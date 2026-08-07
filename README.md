[![Github Action (main)](https://github.com/cyber-dojo/web/actions/workflows/main.yml/badge.svg)](https://github.com/cyber-dojo/web/actions)

- A [docker-containerized](https://hub.docker.com/r/cyberdojo/web/tags) micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- An HTTP [Sinatra](https://sinatrarb.com/) web service, for the core edit+review pages.
- Demonstrates a [Kosli](https://www.kosli.com/) instrumented [GitHub CI workflow](https://app.kosli.com/cyber-dojo/flows/web-ci/trails/) 
  deploying, with Continuous Compliance, to its [staging](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/) AWS environment.
- Deployment to its [production](https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/) AWS environment is via a separate [promotion workflow](https://github.com/cyber-dojo/aws-prod-co-promotion).
- Uses attestation patterns from https://www.kosli.com/blog/using-kosli-attest-in-github-action-workflows-some-tips/

# Development

```bash
# Run a demo
$ make demo

# Build the image
$ make image

# Run all the tests
$ make test

# Run only specific tests, naming test-id prefix(es). A filtered run skips the
# browser tests, and leaves coverage ungated because a partial run's coverage
# says nothing about the suite as a whole.
$ make test tids=3d99
...
Run options: --seed 45085
# Running:
......
Finished in 0.006136s, 977.8290 runs/s, 2607.5441 assertions/s.
6 runs, 16 assertions, 0 failures, 0 errors, 0 skips
...
Filtered run - coverage not gated.

# Run only the browser tests
$ make test_browser
```

A full `make test` runs every test directory in one process, so it produces a
single coverage report, and ends with the gate:

```
tests      : 117
assertions : 443
failures   : 0
errors     : 0
skips      : 0
secs       : 50.19
code files : 18
coverage   : 100.00%

DONE
```

# Screenshots

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
