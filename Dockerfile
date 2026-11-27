FROM ghcr.io/cyber-dojo/sinatra-base:4d448af@sha256:d2d3fd0451afc5954ea4433e41f6f17ad6ad856bf607c9cd23dd4cf9c32b6ce8 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo

# ============== creator ==============
# Compile the SCSS/JS assets to a single app.css and app.js.
# The output is platform-independent text, so the stage runs on the build
# machine's own platform and every target platform copies the same files.
FROM --platform=$BUILDPLATFORM cyberdojo/asset_builder:4f30636 AS creator-assets
COPY app-creator/source/server/creator/assets/javascripts /app/app/assets/javascripts
COPY app-creator/source/server/creator/assets/stylesheets /app/app/assets/stylesheets
COPY common/stylesheets /app/app/assets/stylesheets/common
COPY common/javascripts /app/app/assets/javascripts/common
RUN /app/config/compile.sh /tmp/out

FROM base AS creator
LABEL maintainer=jon@jaggersoft.com
ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}
ARG APP_DIR=/app
ENV APP_DIR=${APP_DIR}
WORKDIR ${APP_DIR}/source
COPY --chown=nobody:nogroup app-creator/source/server/ .
COPY --from=creator-assets --chown=nobody:nogroup /tmp/out/app.css ${APP_DIR}/assets/app.css
COPY --from=creator-assets --chown=nobody:nogroup /tmp/out/app.js  ${APP_DIR}/assets/app.js
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT [ "/sbin/tini", "-g", "--" ]
CMD [ "./config/up.sh" ]

# ============== dashboard ==============
# Compile the SCSS/JS assets to a single app.css and app.js.
FROM --platform=$BUILDPLATFORM cyberdojo/asset_builder:4f30636 AS dashboard-assets
COPY app-dashboard/source/server/dashboard/assets/javascripts /app/app/assets/javascripts
COPY app-dashboard/source/server/dashboard/assets/stylesheets /app/app/assets/stylesheets
COPY common/stylesheets /app/app/assets/stylesheets/common
RUN /app/config/compile.sh /tmp/out

FROM base AS dashboard
LABEL maintainer=jon@jaggersoft.com
ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}
ARG APP_DIR=/dashboard
ENV APP_DIR=${APP_DIR}
WORKDIR ${APP_DIR}/source
COPY --chown=nobody:nogroup app-dashboard/source/server/ .
COPY --from=dashboard-assets --chown=nobody:nogroup /tmp/out/app.css ${APP_DIR}/assets/app.css
COPY --from=dashboard-assets --chown=nobody:nogroup /tmp/out/app.js  ${APP_DIR}/assets/app.js
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["./config/up.sh"]

# ============== web ==============
# Compile the SCSS/JS assets to a single app.css and app.js.
FROM --platform=$BUILDPLATFORM cyberdojo/asset_builder:4f30636 AS web-assets
COPY app-web/source/server/web/assets/javascripts /app/app/assets/javascripts
COPY app-web/source/server/web/assets/stylesheets /app/app/assets/stylesheets
COPY common/stylesheets /app/app/assets/stylesheets/common
COPY common/javascripts /app/app/assets/javascripts/common
RUN /app/config/compile.sh /tmp/out

# Only the two compiled bundles, for docker build --output, which exports a
# stage's whole filesystem. app-web/bin/run_server_tests_bare.sh mounts them
# into the bare image, at the path the stage below copies them to.
FROM scratch AS web-assets-files
COPY --from=web-assets /tmp/out/app.css /tmp/out/app.js /

FROM base AS web
LABEL maintainer=jon@jaggersoft.com
ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}
ARG APP_DIR=/web
ENV APP_DIR=${APP_DIR}
WORKDIR ${APP_DIR}/source
COPY --chown=nobody:nogroup app-web/source/server/ .
COPY --from=web-assets --chown=nobody:nogroup /tmp/out/app.css ${APP_DIR}/assets/app.css
COPY --from=web-assets --chown=nobody:nogroup /tmp/out/app.js  ${APP_DIR}/assets/app.js
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./config/up.sh" ]
