FROM ghcr.io/cyber-dojo/sinatra-base:1a1d65f@sha256:31bfb1e5cbc25d4b37e0dfea2e460d4ecdaf8062bfc5b70b6a28c40211daea61 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo

# Compile the SCSS/JS assets to a single app.css and app.js.
FROM cyberdojo/asset_builder:5e9f6ad AS assets
COPY source/app/assets/javascripts /app/app/assets/javascripts
COPY source/app/assets/stylesheets /app/app/assets/stylesheets
RUN /app/config/compile.sh /tmp/out

FROM base
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG APP_DIR=/web
ENV APP_DIR=${APP_DIR}

WORKDIR ${APP_DIR}/source
COPY --chown=nobody:nogroup source/ .
COPY --from=assets --chown=nobody:nogroup /tmp/out/app.css ${APP_DIR}/assets/app.css
COPY --from=assets --chown=nobody:nogroup /tmp/out/app.js  ${APP_DIR}/assets/app.js

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
