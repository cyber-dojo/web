FROM cyberdojo/web-base:cb220be@sha256:6e78ae1635acf8a11762f4a3d86fa79150a523aba69467c84ef60af59c089221
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

#RUN apk add --upgrade libexpat=2.7.3-r0       # https://security.snyk.io/vuln/SNYK-ALPINE321-EXPAT-13003711
#RUN apk add --upgrade c-ares=1.34.5-r0        # https://security.snyk.io/vuln/SNYK-ALPINE321-CARES-9680227
#RUN apk add --upgrade icu=74.2-r1             # https://security.snyk.io/vuln/SNYK-ALPINE321-ICU-10691539
#RUN apk add --upgrade sqlite=3.48.0-r4        # https://security.snyk.io/vuln/SNYK-ALPINE321-SQLITE-11191066
#RUN apk add --upgrade sqlite-libs=3.48.0-r4   # https://security.snyk.io/vuln/SNYK-ALPINE321-SQLITE-11191066
#RUN apk upgrade musl                          # https://security.snyk.io/vuln/SNYK-ALPINE320-MUSL-8720638
#RUN apk upgrade libcrypto3 libssl3            # https://security.snyk.io/vuln/SNYK-ALPINE322-OPENSSL-13174133
#RUN apk upgrade git                           # https://security.snyk.io/vuln/SNYK-ALPINE320-GIT-10669667
#RUN apk upgrade curl                          # https://security.snyk.io/vuln/SNYK-ALPINE321-CURL-13277278

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
