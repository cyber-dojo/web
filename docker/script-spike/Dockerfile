FROM cyberdojo/web-base:DOCKER_VERSION
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# Copy the app source

USER root
ARG  CYBER_DOJO_HOME
RUN  mkdir -p ${CYBER_DOJO_HOME}
COPY . ${CYBER_DOJO_HOME}
RUN  chown -R cyber-dojo ${CYBER_DOJO_HOME}

# - - - - - - - - - - - - - - - - - - - - - -
WORKDIR ${CYBER_DOJO_HOME}
USER    cyber-dojo
EXPOSE  3000
