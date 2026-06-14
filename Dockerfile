FROM ghcr.io/cyber-dojo/sinatra-base:4eba88f@sha256:5250025235427e5458349654003c3791f2dc9d3dbdc10e6b80dbb101b57a6b6e AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo

FROM cyberdojo/asset_builder:f2bcab7 AS assets
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
COPY source/ .
COPY --from=assets /tmp/out/app.js  public/assets/app.js
COPY --from=assets /tmp/out/app.css public/assets/app.css

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
