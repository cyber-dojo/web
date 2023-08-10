# I would like to upgrade to Rails 7.0.6 and ruby 3.2.2 (2023-03-30 revision e51014f9c0) using...
FROM cyberdojo/web-base:e15d606
LABEL maintainer=jon@jaggersoft.com

WORKDIR /cyber-dojo
RUN chown nobody:nogroup .
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

EXPOSE 3000
USER nobody
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
