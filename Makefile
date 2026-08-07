
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := 244531986313.dkr.ecr.eu-central-1.amazonaws.com/web:${SHORT_SHA}

.PHONY: all image test_server test_client metrics_test metrics_coverage rubocop-lint demo probe_demo snyk-container-scan snyk-code-scan

# Build, run the server tests, and judge the run.
all: image test_server metrics_test metrics_coverage

image:
	${PWD}/bin/build.sh

rubocop-lint:
	@${PWD}/bin/rubocop-lint.sh

# Run the server tests, optionally filtered by test-id prefix(es). Running the
# tests and judging them are separate targets, so a filtered run - whose metrics
# describe only the tests it loaded - is not gated.
#   eg make test_server tids=F1B7C
test_server:
	${PWD}/bin/run_tests.sh ${tids}

# Run the client (Capybara + Selenium) tests, optionally filtered by test-id
# prefix(es). Like test_server this does NOT depend on the image target: on CI
# the image under test is downloaded, and rebuilding it there would produce an
# artifact the evidence does not describe (see bin/build.sh). The served app
# loads its javascript from the image, so after a javascript change run
# 'make image' first.
#   eg make image test_client tids=fK3nQ7
test_client:
	${PWD}/bin/run_client_tests.sh ${tids}

# Judge the last test_server run, against test/test_metrics_params.json and
# test/coverage_metrics_params.json respectively. CI evaluates those same files
# with a rego policy, so a bound is written once and applied in both places.
metrics_test:
	@${PWD}/bin/check_test_metrics.sh

metrics_coverage:
	@${PWD}/bin/check_coverage_metrics.sh

count ?= 1
v ?= 2

demo:
	${PWD}/bin/demo.sh ${count} ${v}

probe_demo:
	${PWD}/bin/probe_demo.sh

snyk-container-scan: image
	snyk container test ${IMAGE_NAME} \
		--file=Dockerfile \
		--policy-path=.snyk \
		--sarif \
		--sarif-file-output=snyk.container.scan.json

snyk-code-scan:
	snyk code test \
		--policy-path=.snyk \
		--sarif \
		--sarif-file-output=snyk.code.scan.json

