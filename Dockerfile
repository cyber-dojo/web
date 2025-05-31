FROM cyberdojo/web-base:3411359@sha256:6e78ae1635acf8a11762f4a3d86fa79150a523aba69467c84ef60af59c089221
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add --upgrade libexpat=2.7.0-r0  # https://security.snyk.io/vuln/SNYK-ALPINE321-EXPAT-9459843
RUN apk add --upgrade c-ares=1.34.5-r0   # https://security.snyk.io/vuln/SNYK-ALPINE321-CARES-9680227

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
