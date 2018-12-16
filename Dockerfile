FROM  cyberdojo/web-base
LABEL maintainer=jon@jaggersoft.com

ARG                            WEB_HOME=/cyber-dojo
COPY .                       ${WEB_HOME}
RUN  chown -R nobody:nogroup ${WEB_HOME}

ARG SHA
RUN echo ${SHA} > ${WEB_HOME}/sha.txt

EXPOSE  3000
USER nobody
CMD [ "./up.sh" ]
