[![Github Action (main)](https://github.com/cyber-dojo/web/actions/workflows/main.yml/badge.svg)](https://github.com/cyber-dojo/web/actions)

- A [docker-containerized](https://hub.docker.com/r/cyberdojo/web/tags) micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- An HTTP [Ruby on Rails](https://rubyonrails.org/) web service, for the core edit+review pages.
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

# Run only specific tests
$ ./sh/run_tests.sh app_controllers 87C
...
======app_controllers======
Run options: --seed 42705
# Running:
....
Finished in 1.604879s, 2.4924 runs/s, 10.5927 assertions/s.
4 runs, 17 assertions, 0 failures, 0 errors, 0 skips
...
                    t      a  f  e  s   secs  t/sec  a/sec      cov
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
app_controllers     4     17  0  0  0   1.60      2     10    40.37
```

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
