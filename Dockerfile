FROM cyberdojo/web-base:8a409cd@sha256:d8fda7714933d9312720f01244c8de8bce8fdfbf45030ba2c634bac4d486db01
# The FROM statement above is typically set via an automated pull-request from the web-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add --upgrade expat=2.7.5-r0    # https://security.snyk.io/vuln/SNYK-ALPINE322-EXPAT-15704589

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
