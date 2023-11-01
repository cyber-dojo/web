ARG BASE_IMAGE=cyberdojo/web-base:c4f03f0
FROM ${BASE_IMAGE}
LABEL maintainer=jon@jaggersoft.com

WORKDIR /cyber-dojo
RUN chown nobody:nogroup .
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}
ENV COMMIT_SHA=${COMMIT_SHA}

# ARGs are reset after FROM See https://github.com/moby/moby/issues/34129
ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

EXPOSE 3000
USER nobody
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
