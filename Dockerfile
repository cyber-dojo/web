FROM ghcr.io/cyber-dojo/sinatra-base:3ce6c9b@sha256:7e53acc4239e11722997e85367eb8e995d995ceec05f1cc6430da989bb09b108
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG APP_DIR=/web
ENV APP_DIR=${APP_DIR}

# https://security.snyk.io/vuln/SNYK-ALPINE322-OPENSSL-15993406
RUN apk add --upgrade openssl=3.5.6-r0

# https://security.snyk.io/vuln/SNYK-ALPINE322-MUSL-16008606
RUN apk add --upgrade musl=1.2.5-r12
RUN apk add --upgrade musl=1.2.5-r12 musl-utils=1.2.5-r12

WORKDIR ${APP_DIR}/source
COPY source/ .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
