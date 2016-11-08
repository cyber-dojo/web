FROM cyberdojo/user-base
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 1. install tini (for pid 1 zombie reaping)
# https://github.com/krallin/tini
# https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/

USER root
RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ tini
ENTRYPOINT ["/sbin/tini", "--"]

# - - - - - - - - - - - - - - - - - - - - - -
# 2. bundle install from cyber-dojo's Gemfile
# o) ruby, ruby-io-console ruby-bigdecimal, tzdata (for rails server)
# o) ruby-irb (for debugging)
# o) bash (test scripts are written in bash)
# Doing the apk del build-dependencies in the same RUN command reduces the web
# image size from 437.3 MB to 265.9 MB

RUN  apk --update add \
           ruby ruby-irb ruby-io-console ruby-bigdecimal tzdata \
           bash

ARG  CYBER_DOJO_HOME
RUN  mkdir -p ${CYBER_DOJO_HOME}
COPY Gemfile ${CYBER_DOJO_HOME}
# Gemfile: source 'https://rubygems.org'
RUN apk add --no-cache openssl ca-certificates
RUN apk --update \
        add --virtual build-dependencies \
          build-base \
          ruby-dev \
          openssl-dev \
          postgresql-dev \
          libc-dev \
          linux-headers \
        && gem install bundler --no-ri --no-rdoc \
        && cd ${CYBER_DOJO_HOME} ; bundle install --without development test \
        && apk del build-dependencies

# - - - - - - - - - - - - - - - - - - - - - -
# 3. currently storer needs git
RUN apk add --update git

# - - - - - - - - - - - - - - - - - - - - - -
# 4. Copy the app source

ARG  CYBER_DOJO_HOME
RUN  mkdir -p ${CYBER_DOJO_HOME}
COPY . ${CYBER_DOJO_HOME}
RUN  chown -R cyber-dojo ${CYBER_DOJO_HOME}

WORKDIR ${CYBER_DOJO_HOME}
USER    cyber-dojo
EXPOSE  3000


