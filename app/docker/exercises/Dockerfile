FROM cyberdojofoundation/user-base
MAINTAINER Jon Jagger <jon@jaggersoft.com>

ARG CYBER_DOJO_PATH
USER root
RUN  mkdir -p ${CYBER_DOJO_PATH}
COPY . ${CYBER_DOJO_PATH}
RUN  chown -R cyber-dojo ${CYBER_DOJO_PATH}
VOLUME [ "${CYBER_DOJO_PATH}" ]
