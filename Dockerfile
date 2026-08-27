FROM ghcr.io/cyber-dojo/sinatra-base:5ab6a10@sha256:c096154011cc1cef9cc69e8be948fb4329543f9670d4fb4fd3851a8aa016630d AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo

# Compile the SCSS/JS assets to a single app.css and app.js.
FROM cyberdojo/asset_builder:5e9f6ad AS assets
COPY source/server/web/assets/javascripts /app/app/assets/javascripts
COPY source/server/web/assets/stylesheets /app/app/assets/stylesheets
RUN /app/config/compile.sh /tmp/out

FROM base
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG APP_DIR=/web
ENV APP_DIR=${APP_DIR}

WORKDIR ${APP_DIR}/source
COPY --chown=nobody:nogroup source/server/ .
COPY --from=assets --chown=nobody:nogroup /tmp/out/app.css ${APP_DIR}/assets/app.css
COPY --from=assets --chown=nobody:nogroup /tmp/out/app.js  ${APP_DIR}/assets/app.js

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./config/up.sh" ]
