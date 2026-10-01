
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
	${PWD}/app-web/bin/build.sh

web_rubocop_lint:
	@${PWD}/app-web/bin/rubocop-lint.sh

# Run the server tests, optionally filtered by test-id prefix(es). Running the
# tests and judging them are separate targets, so a filtered run - whose metrics
# describe only the tests it loaded - is not gated.
#   eg make web_test_server tids=F1B7C
web_test_server:
	${PWD}/app-web/bin/run_server_tests.sh ${tids}

# Run the client (Capybara + Selenium) tests, optionally filtered by test-id
# prefix(es). Like web_test_server this does NOT depend on web_image: on CI
# the image under test is downloaded, and rebuilding it there would produce an
# artifact the evidence does not describe (see app-web/bin/build.sh). The served app
# loads its javascript from the image, so after a javascript change run
# 'make web_image' first.
#   eg make web_image web_test_client tids=fK3nQ7
web_test_client:
	${PWD}/app-web/bin/run_client_tests.sh ${tids}

# Judge the last web_test_server run, against app-web/test/test_metrics_params.json and
# app-web/test/coverage_metrics_params.json respectively. Both targets apply those
# bounds with the same rego policy CI applies them with, so a bound and the
# decision made from it are each written once.
web_metrics_test:
	@${PWD}/app-web/bin/check_test_metrics.sh

web_metrics_coverage:
	@${PWD}/app-web/bin/check_coverage_metrics.sh

# Check that the two targets above can fail: that a breached bound reaches the
# caller as a non-zero exit, and not merely as a line of output.
web_test_check_metrics:
	@${PWD}/app-web/test/check_metrics_exit_status.sh

count ?= 1
v ?= 2

web_demo: creator_image dashboard_image web_image
	${PWD}/app-web/bin/demo.sh ${count} ${v}

web_probe_demo:
	${PWD}/app-web/bin/probe_demo.sh

web_snyk_container_scan: web_image
	snyk container test ${IMAGE_NAME} \
		--file=Dockerfile \
		--policy-path=app-web/.snyk \
		--sarif \
		--sarif-file-output=snyk.container.scan.json

web_snyk_code_scan:
	snyk code test \
		--policy-path=app-web/.snyk \
		--sarif \
		--sarif-file-output=snyk.code.scan.json

.PHONY: dashboard_image dashboard_test_server dashboard_coverage_server
.PHONY: dashboard_rubocop_lint dashboard_snyk_container_scan
.PHONY: dashboard_demo dashboard_demo_data

dashboard_image:
	@${PWD}/app-dashboard/bin/build_image.sh server

dashboard_test_server:
	@${PWD}/app-dashboard/bin/run_tests.sh server

dashboard_coverage_server:
	@${PWD}/app-dashboard/bin/check_coverage.sh server

dashboard_rubocop_lint:
	@${PWD}/app-dashboard/bin/rubocop_lint.sh

dashboard_snyk_container_scan:
	@${PWD}/app-dashboard/bin/snyk_container_scan.sh

dashboard_demo: creator_image dashboard_image web_image
	@${PWD}/app-dashboard/bin/demo.sh

dashboard_demo_data:
	@${PWD}/app-dashboard/bin/demo_data.sh

.PHONY: creator_image creator_test creator_test_server creator_test_client
.PHONY: creator_rubocop_lint creator_snyk_container_scan creator_demo

creator_image:
	bash -c ". ${PWD}/app-creator/bin/build_tagged_images.sh && build_tagged_images"

creator_test:
	bash -c ". ${PWD}/app-creator/bin/run_tests_with_coverage.sh && run_tests_with_coverage"

# Run only the server (or client) tests. Optionally filter by test-id prefix(es)
# via the tids var, eg:  make creator_test_server tids=p42   or   make creator_test_server tids="p42 p99"
creator_test_server:
	@${PWD}/app-creator/bin/run_tests_with_coverage.sh server ${tids}

creator_test_client:
	@${PWD}/app-creator/bin/run_tests_with_coverage.sh client ${tids}

creator_rubocop_lint:
	@${PWD}/app-creator/bin/rubocop-lint.sh

# IMAGE_NAME above names web's image, so this names creator's itself.
creator_snyk_container_scan: creator_image
	snyk container test cyberdojo/creator:${SHORT_SHA} \
		--file=Dockerfile \
		--policy-path=app-creator/.snyk \
		--sarif \
		--sarif-file-output=snyk.container.scan.json

creator_demo: creator_image dashboard_image web_image
	@${PWD}/app-creator/bin/demo.sh

