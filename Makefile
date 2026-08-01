
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := 244531986313.dkr.ecr.eu-central-1.amazonaws.com/web:${SHORT_SHA}

.PHONY: image test test_browser rubocop-lint demo probe_demo snyk-container-scan snyk-code-scan

image:
	${PWD}/bin/build.sh

rubocop-lint:
	@DOCKER_CLI_HINTS=false docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

test:
	${PWD}/bin/run_tests.sh

test_browser: image
	${PWD}/bin/run_browser_tests.sh

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

