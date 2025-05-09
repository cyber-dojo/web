FROM cyberdojo/web-base:9d9bcdf@sha256:fb42330022e2ed35b150724b9c105e163c634e103a69b4ca87e7c7deded93a96
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
