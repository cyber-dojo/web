
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := 244531986313.dkr.ecr.eu-central-1.amazonaws.com/web:${SHORT_SHA}

.PHONY: web_all web_image web_test_server web_test_client
.PHONY: web_metrics_test web_metrics_coverage web_test_check_metrics
.PHONY: web_rubocop_lint web_demo web_probe_demo
.PHONY: web_snyk_container_scan web_snyk_code_scan

# Build, run the server tests, and judge the run. The judging is checked first,
# and takes a second: a build and a test run are a long way to go to reach a
# verdict that cannot fail.
web_all: web_test_check_metrics web_image web_test_server web_metrics_test web_metrics_coverage

web_image:
	${PWD}/web/bin/build.sh

web_rubocop_lint:
	@${PWD}/web/bin/rubocop-lint.sh

# Run the server tests, optionally filtered by test-id prefix(es). Running the
# tests and judging them are separate targets, so a filtered run - whose metrics
# describe only the tests it loaded - is not gated.
#   eg make web_test_server tids=F1B7C
web_test_server:
	${PWD}/web/bin/run_server_tests.sh ${tids}

# Run the client (Capybara + Selenium) tests, optionally filtered by test-id
# prefix(es). Like web_test_server this does NOT depend on web_image: on CI
# the image under test is downloaded, and rebuilding it there would produce an
# artifact the evidence does not describe (see web/bin/build.sh). The served app
# loads its javascript from the image, so after a javascript change run
# 'make web_image' first.
#   eg make web_image web_test_client tids=fK3nQ7
web_test_client:
	${PWD}/web/bin/run_client_tests.sh ${tids}

# Judge the last web_test_server run, against web/test/test_metrics_params.json and
# web/test/coverage_metrics_params.json respectively. Both targets apply those
# bounds with the same rego policy CI applies them with, so a bound and the
# decision made from it are each written once.
web_metrics_test:
	@${PWD}/web/bin/check_test_metrics.sh

web_metrics_coverage:
	@${PWD}/web/bin/check_coverage_metrics.sh

# Check that the two targets above can fail: that a breached bound reaches the
# caller as a non-zero exit, and not merely as a line of output.
web_test_check_metrics:
	@${PWD}/web/test/check_metrics_exit_status.sh

count ?= 1
v ?= 2

web_demo:
	${PWD}/web/bin/demo.sh ${count} ${v}

web_probe_demo:
	${PWD}/web/bin/probe_demo.sh

web_snyk_container_scan: web_image
	snyk container test ${IMAGE_NAME} \
		--file=Dockerfile \
		--policy-path=web/.snyk \
		--sarif \
		--sarif-file-output=snyk.container.scan.json

web_snyk_code_scan:
	snyk code test \
		--policy-path=web/.snyk \
		--sarif \
		--sarif-file-output=snyk.code.scan.json

