ARG BASE_IMAGE=cyberdojo/web-base:ea6086b
FROM ${BASE_IMAGE}
# ARGs are reset after FROM See https://github.com/moby/moby/issues/34129
ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

LABEL maintainer=jon@jaggersoft.com

WORKDIR /cyber-dojo
RUN chown nobody:nogroup .
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

EXPOSE 3000
USER nobody

HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
