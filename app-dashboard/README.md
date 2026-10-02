[![Github Action (main)](https://github.com/cyber-dojo/web/actions/workflows/main-dashboard.yml/badge.svg?branch=main)](https://github.com/cyber-dojo/web/actions/workflows/main-dashboard.yml)


- A [docker-containerized](https://registry.hub.docker.com/r/cyberdojo/dashboard) micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- The HTTP UI for a group-exercise dashboard.
- Demonstrates a [Kosli](https://www.kosli.com/) instrumented [GitHub CI workflow](https://app.kosli.com/cyber-dojo/flows/dashboard-ci/trails/) deploying, with Continuous Compliance, to its [staging](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/) AWS environment.
- Deployment to its [production](https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/) AWS environment is via a separate [promotion workflow](https://github.com/cyber-dojo/aws-prod-co-promotion).
- Uses attestation patterns from https://www.kosli.com/blog/using-kosli-attest-in-github-action-workflows-some-tips/

# Development

```bash
# To build the image
$ make dashboard_image

# To run all tests
$ make dashboard_test_server

# To run only specific tests
$ make dashboard_test_server tid=449AC6

# To check coverage metrics
$ make dashboard_coverage_server

# To run snyk-container-scan
$ make dashboard_snyk_container_scan

# To run rubocop-lint
$ make dashboard_rubocop_lint

# To run the demo (all three apps, nginx on port 80)
$ make demo
```

- - - -
* [GET alive](docs/api.md#get-alive)  
* [GET ready](docs/api.md#get-ready)
* [GET sha](docs/api.md#get-sha)
* ...

- - - -
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
