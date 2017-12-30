FROM  alpine:latest
LABEL maintainer=jon@jaggersoft.com

USER root

# - - - - - - - - - - - - - - - - -
# install ruby+
# bundle install needs
#   zlib-dev for nokogiri
#   libffi-dev for sass-rails
# - - - - - - - - - - - - - - - - -

RUN apk --update --no-cache add \
    ruby ruby-io-console ruby-dev ruby-irb ruby-bundler ruby-bigdecimal \
    bash \
    tzdata \
    zlib-dev \
    libffi-dev

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
# copy source set own ownership
# - - - - - - - - - - - - - - - - -

COPY . ${CYBER_DOJO_HOME}
RUN  adduser -D -H -u 19661 cyber-dojo
RUN  chown -R cyber-dojo ${CYBER_DOJO_HOME}
USER cyber-dojo

# - - - - - - - - - - - - - - - - -
# bring service up
# - - - - - - - - - - - - - - - - -

WORKDIR ${CYBER_DOJO_HOME}
EXPOSE  3000
CMD [ "./run_rails_server.sh" ]
