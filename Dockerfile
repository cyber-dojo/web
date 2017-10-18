FROM  alpine:3.4
LABEL maintainer=jon@jaggersoft.com

USER root
RUN adduser -D -H -u 19661 cyber-dojo

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install ruby
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RUN apk --update --no-cache add \
    openssl ca-certificates \
    ruby ruby-io-console ruby-dev ruby-irb ruby-bundler ruby-bigdecimal \
    bash tzdata

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install tini (for pid 1 zombie reaping)
# https://github.com/krallin/tini
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ tini

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install web service
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ARG  CYBER_DOJO_HOME
RUN  mkdir -p ${CYBER_DOJO_HOME}
COPY Gemfile ${CYBER_DOJO_HOME}
RUN  echo 'gem: --no-document' > ~/.gemrc

RUN apk add --no-cache openssl ca-certificates
RUN apk --update \
        add --virtual build-dependencies \
          build-base \
          openssl-dev \
          postgresql-dev \
          libc-dev \
          linux-headers \
        && gem install bundler --no-ri --no-rdoc \
        && cd ${CYBER_DOJO_HOME} ; bundle install \
        && apk del build-dependencies

COPY . ${CYBER_DOJO_HOME}
RUN  chown -R cyber-dojo ${CYBER_DOJO_HOME}

WORKDIR ${CYBER_DOJO_HOME}
USER    cyber-dojo
EXPOSE  3000

ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "./run_rails_server.sh" ]

RUN cat ${CYBER_DOJO_HOME}/Gemfile.lock
