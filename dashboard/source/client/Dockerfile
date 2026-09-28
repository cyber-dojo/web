FROM ghcr.io/cyber-dojo/sinatra-base:5ab6a10@sha256:c096154011cc1cef9cc69e8be948fb4329543f9670d4fb4fd3851a8aa016630d
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

WORKDIR /app
COPY . .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /app/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/app/config/up.sh" ]
