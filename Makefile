
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := 244531986313.dkr.ecr.eu-central-1.amazonaws.com/web:${SHORT_SHA}

.PHONY: image test probe demo snyk-container snyk-code

image:
	${PWD}/sh/build_test.sh -bo

test:
	${PWD}/sh/build_test.sh

demo:
	${PWD}/sh/demo.sh

probe_demo:
	${PWD}/sh/probe_demo.sh

snyk-container: image
	snyk container test ${IMAGE_NAME} \
		--file=Dockerfile \
		--policy-path=.snyk \
		--sarif \
		--sarif-file-output=snyk.container.scan.json

snyk-code:
	snyk code test \
		--policy-path=.snyk \
		--sarif \
		--sarif-file-output=snyk.code.scan.json

