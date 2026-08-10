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

RESULT:  ALLOWED
```

A breach names the metric, what it measured, and the bound it broke:

```
$ make metrics_coverage

RESULT:      DENIED
VIOLATIONS:  code.branches.missed is 3, above its maximum of 2
Error: [kosli evaluate input] policy denied: [code.branches.missed is 3, above its maximum of 2]
make: *** [metrics_coverage] Error 1
```

`make metrics_test` does the same for the test counts and the run's duration.

The bounds live in `test/coverage_metrics_params.json` and
`test/test_metrics_params.json`, and are written once. So is the decision made
from them: these targets and CI both apply the bounds with one rego policy,
shared from the kosli-attestation-types repo, which CI then attests to Kosli.
Running it locally needs no kosli account - the policy is evaluated from a
published CLI image, and makes no API calls.

Every metric names a range, `{"min": n, "max": m}`, and the check is
`min <= value <= max`. The maximum is a ratchet - the number may fall, never
rise - so growing the code, or letting a missed count grow, is a deliberate act
that has to be acknowledged by editing the file. The minimum is there because
upper bounds alone cannot catch an empty report: a report of all zeros
satisfies every one of them. Naming one side and not the other leaves a metric
half checked, so the policy reports it as a breach rather than applying the
side that is there.

# Screenshots

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
