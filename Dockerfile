FROM ghcr.io/cyber-dojo/sinatra-base:3efccf8@sha256:ec7ac22d2d1935065036de11e8b119a1d60a21e112eac395de10987349e5bfe3
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG APP_DIR=/web
ENV APP_DIR=${APP_DIR}

WORKDIR ${APP_DIR}/source
COPY source/ .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
