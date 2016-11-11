FROM cyberdojo/web_base
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# - - - - - - - - - - - - - - - - - - - - - -
# currently storer needs git
RUN apk add --update git

ARG  CYBER_DOJO_HOME
RUN  mkdir -p ${CYBER_DOJO_HOME}
COPY . ${CYBER_DOJO_HOME}
RUN  chown -R 19661 ${CYBER_DOJO_HOME}

WORKDIR ${CYBER_DOJO_HOME}
USER    cyber-dojo
EXPOSE  3000


