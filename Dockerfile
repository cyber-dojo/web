FROM cyberdojo/web-base:3c8bbe2@sha256:3d2e21c8728c55ce32987743c7bd87bdeb8dc3e119bcd352d75b4573965e7df5
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
