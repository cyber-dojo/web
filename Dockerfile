FROM  alpine:latest
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

ARG             CYBER_DOJO_HOME
RUN  mkdir -p ${CYBER_DOJO_HOME}
COPY Gemfile  ${CYBER_DOJO_HOME}

RUN  apk --update add --virtual build-dependencies build-base \
  && bundle config --global silence_root_warning 1 \
  && cd ${CYBER_DOJO_HOME} \
  && bundle install \
  && apk del build-dependencies

RUN  cat ${CYBER_DOJO_HOME}/Gemfile.lock

# - - - - - - - - - - - - - - - - -
# copy source & set ownership
# - - - - - - - - - - - - - - - - -

COPY . ${CYBER_DOJO_HOME}
RUN  adduser -D -H -u 19661 cyber-dojo
RUN  chown -R cyber-dojo ${CYBER_DOJO_HOME}
USER cyber-dojo

# - - - - - - - - - - - - - - - - -
# bring it up
# - - - - - - - - - - - - - - - - -

WORKDIR ${CYBER_DOJO_HOME}
EXPOSE  3000
CMD [ "./run_rails_server.sh" ]
