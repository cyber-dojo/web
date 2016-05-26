FROM cyberdojofoundation/user-base
MAINTAINER Jon Jagger <jon@jaggersoft.com>

ARG CYBER_DOJO_HOME
ARG PATH=${CYBER_DOJO_HOME}/app/data/exercises

USER root
RUN  mkdir -p ${PATH}
RUN git clone --depth 1 https://github.com/JonJagger/cyber-dojo-exercises.git ${PATH}
RUN  chown -R cyber-dojo ${PATH}
VOLUME [ "${PATH}" ]
