FROM ghcr.io/cyber-dojo/sinatra-base:1b1df8e@sha256:0cf1c46e55c2c66cb7c55724f405784364be1d18cb7a2f47f6f0abf1cee0a80d
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
RUN apk add --upgrade musl-utils=1.2.5-r12

WORKDIR ${APP_DIR}/source
COPY source/ .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
