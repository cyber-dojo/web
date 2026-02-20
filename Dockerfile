FROM cyberdojo/web-base:8a409cd@sha256:d8fda7714933d9312720f01244c8de8bce8fdfbf45030ba2c634bac4d486db01
# The FROM statement above is typically set via an automated pull-request from the web-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add --upgrade c-ares=1.34.6-r0        # https://security.snyk.io/vuln/SNYK-ALPINE322-CARES-14409293
RUN apk add --upgrade libexpat=2.7.4-r0       # https://security.snyk.io/vuln/SNYK-ALPINE321-EXPAT-13003711
RUN apk upgrade musl                          # https://security.snyk.io/vuln/SNYK-ALPINE320-MUSL-8720638
RUN apk upgrade libcrypto3 libssl3            # https://security.snyk.io/vuln/SNYK-ALPINE322-OPENSSL-13174133
RUN apk upgrade busybox                       # https://security.snyk.io/vuln/SNYK-ALPINE321-BUSYBOX-14102399
RUN apk upgrade git                           # https://security.snyk.io/vuln/SNYK-ALPINE320-GIT-10669667
RUN apk upgrade curl                          # https://security.snyk.io/vuln/SNYK-ALPINE321-CURL-13277278

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

WORKDIR /cyber-dojo
RUN chown nobody:nogroup .
COPY --chown=nobody:nogroup source .
EXPOSE 3000
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
