FROM ghcr.io/cyber-dojo/sinatra-base:3f47d6e@sha256:097d7a40f2dbec0e041c29faf64e3886a4e299ab1e0f68a8e2fcf4b1c9886575 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

FROM cyberdojo/asset_builder:f2bcab7 AS assets
COPY source/app/assets/javascripts /app/app/assets/javascripts
COPY source/app/assets/stylesheets /app/app/assets/stylesheets
RUN /app/config/compile.sh /tmp/out

FROM base

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG APP_DIR=/web
ENV APP_DIR=${APP_DIR}

WORKDIR ${APP_DIR}/source
COPY source/ .
COPY --from=assets /tmp/out/app.js  public/assets/app.js
COPY --from=assets /tmp/out/app.css public/assets/app.css

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
