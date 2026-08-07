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

# Run the server tests
$ make test_server

# Run only specific tests, naming test-id prefix(es)
$ make test_server tids=3d99

# Run the client (Capybara + Selenium) tests, which make test_server does not
$ make test_client

# Build, run the server tests, and judge the run
$ make all
```

Running the tests and judging them are separate steps. `make test_server` runs
every server test directory in one ruby process, its test classes in parallel,
and writes `reports/test_metrics.json` and `reports/coverage_metrics.json`. Two
targets then check those against pinned limits, and fail if any is breached:

```
$ make metrics_coverage

                   test.lines.total |  1340   <=  1340 |  true
                  test.lines.missed |     9   <=     9 |  true
                test.branches.total |    26   <=    26 |  true
               test.branches.missed |     8   <=     8 |  true

                   code.lines.total |   496   <=   496 |  true
                  code.lines.missed |     0   ==     0 |  true
                code.branches.total |    33   <=    33 |  true
               code.branches.missed |     3   <=     3 |  true
```

`make metrics_test` does the same for the test counts and the run's duration.
The limits live in `test/coverage_metrics_limits.rb` and
`test/test_metrics_limits.rb`; a `missed` count pinned with `==` must stay
where it is, one with `<=` is a ratchet that may fall but never rise.

# Screenshots

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
