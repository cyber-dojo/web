FROM  cyberdojo/web-base
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - -
# copy source & set ownership
# - - - - - - - - - - - - - - - - -

ARG                            WEB_HOME=/cyber-dojo
COPY .                       ${WEB_HOME}
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
ENV RAILS_LOG_TO_STDOUT=TRUE
CMD [ "./up.sh" ]
