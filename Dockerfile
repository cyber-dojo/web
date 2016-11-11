FROM cyberdojo/web_base
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# -D=no password, -H=no home directory
RUN adduser -D -H -u 19661 cyber-dojo

ARG  CYBER_DOJO_HOME
RUN  mkdir -p ${CYBER_DOJO_HOME}
COPY . ${CYBER_DOJO_HOME}
RUN  chown -R cyber-dojo ${CYBER_DOJO_HOME}

WORKDIR ${CYBER_DOJO_HOME}
USER    cyber-dojo
EXPOSE  3000


