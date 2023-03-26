# I would like to upgrade to Rails 7.0.0 and Ruby 3.1.3p185 using...
# FROM cyberdojo/web-base:6dde2ab
# but there seems to be a problem caused by a change in
# how keyword arguments are handled in Ruby 3.
# See https://stackoverflow.com/questions/66750055
# The current base image :f1ae4be is Rails 6.0.0 and Ruby 2.7.1

FROM cyberdojo/web-base:f1ae4be
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
