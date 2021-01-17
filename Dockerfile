FROM cyberdojo/web-base:f1ae4be
LABEL maintainer=jon@jaggersoft.com

WORKDIR /cyber-dojo
RUN chown nobody:nogroup .
COPY --chown=nobody:nogroup . .

# Note
# originally the copy+chown was
#    COPY . .
#    RUN chown -R nobody:nogroup /cyber-dojo
# That works but is _much_ slower than
#    RUN chown nobody:nogroup .
#    COPY --chown=nobody:nogroup . /cyber-dojo

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

EXPOSE 3000
USER nobody
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./up.sh" ]
