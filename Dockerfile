ARG BASE_IMAGE
FROM ${BASE_IMAGE}
LABEL maintainer=jon@jaggersoft.com

RUN apk add --upgrade libexpat=2.7.0-r0  # https://security.snyk.io/vuln/SNYK-ALPINE321-EXPAT-9459843

# ARGs are reset after FROM See https://github.com/moby/moby/issues/34129
ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

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
