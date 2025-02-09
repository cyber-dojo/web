
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := 244531986313.dkr.ecr.eu-central-1.amazonaws.com/web:${SHORT_SHA}

.PHONY: image test probe demo snyk-container snyk-code

image:
	${PWD}/build_test.sh -bo

test:
	${PWD}/build_test.sh

probe:
	${PWD}/sh/probe_demo.sh

demo:
	${PWD}/demo.sh

snyk-container: image
	snyk container test ${IMAGE_NAME} \
        --file=Dockerfile \
		--sarif \
		--sarif-file-output=snyk.container.scan.json \
        --policy-path=.snyk

snyk-code:
	snyk code test \
		--sarif \
		--sarif-file-output=snyk.code.scan.json \
        --policy-path=.snyk

