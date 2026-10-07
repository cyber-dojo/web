FROM ghcr.io/cyber-dojo/sinatra-base:c58736f@sha256:35f8f0ad8bf53b955398392891ca64949787d414edb53789be8a628d76f6d217 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo

# ============== creator ==============
# Compile the SCSS/JS assets to a single app.css and app.js.
FROM cyberdojo/asset_builder:3a99172 AS creator-assets
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
FROM cyberdojo/asset_builder:3a99172 AS dashboard-assets
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
FROM cyberdojo/asset_builder:3a99172 AS web-assets
COPY app-web/source/server/web/assets/javascripts /app/app/assets/javascripts
COPY app-web/source/server/web/assets/stylesheets /app/app/assets/stylesheets
COPY common/stylesheets /app/app/assets/stylesheets/common
COPY common/javascripts /app/app/assets/javascripts/common
RUN /app/config/compile.sh /tmp/out

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
