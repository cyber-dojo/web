FROM ghcr.io/cyber-dojo/sinatra-base:a2408d5@sha256:d0d4d7f9c44500a5fae8275e777658ac9d2b09ea44e0313a4a56d698437da3e7
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG APP_DIR=/web
ENV APP_DIR=${APP_DIR}

# https://security.snyk.io/vuln/SNYK-ALPINE322-OPENSSL-15993406
RUN apk add --upgrade openssl=3.5.6-r0
# https://security.snyk.io/vuln/SNYK-ALPINE323-MUSL-16032072
RUN apk add --upgrade musl=1.2.5-r23
RUN apk add --upgrade musl-utils=1.2.5-r23

WORKDIR ${APP_DIR}/source
COPY source/ .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
