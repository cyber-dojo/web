ARG   ALPINE_VERSION
FROM  alpine:${ALPINE_VERSION}
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - -
# install ruby+
# using FROM alpine:latest and install only the ruby packages
# I need results in an image of ~102MB whereas
# using FROM ruby:alpine results in an image of ~162MB
# bundle install needs
#   libffi-dev for sass-rails
#   tzdata for railties
#   zlib-dev for nokogiri
# - - - - - - - - - - - - - - - - -

RUN apk --update --no-cache add \
    bash \
    libffi-dev \
    ruby \
    ruby-bigdecimal \
    ruby-bundler \
    ruby-dev \
    tzdata \
    zlib-dev

# - - - - - - - - - - - - - - - - -
# install gems
# - - - - - - - - - - - - - - - - -

ARG             WEB_HOME
COPY Gemfile  ${WEB_HOME}/
WORKDIR       ${WEB_HOME}

RUN  apk --update --no-cache add --virtual build-dependencies build-base \
  && bundle config --global silence_root_warning 1 \
  && bundle install \
  && apk del build-dependencies build-base \
  && rm -vrf /var/cache/apk/*

RUN  cat ${WEB_HOME}/Gemfile.lock

# - - - - - - - - - - - - - - - - -
# copy source & set ownership
# - - - - - - - - - - - - - - - - -

COPY . ${WEB_HOME}
RUN  chown -R nobody:nogroup ${WEB_HOME}
USER nobody

# - - - - - - - - - - - - - - - - -
# git commit sha image is built from
# - - - - - - - - - - - - - - - - -

ARG SHA
RUN echo ${SHA} > ${WEB_HOME}/sha.txt

# - - - - - - - - - - - - - - - - -
# bring it up
# - - - - - - - - - - - - - - - - -

EXPOSE  3000
CMD [ "./up.sh" ]
