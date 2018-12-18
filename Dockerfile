FROM cyberdojo/web-base
LABEL maintainer=jon@jaggersoft.com

COPY . /cyber-dojo
RUN  chown -R nobody:nogroup /cyber-dojo

ARG SHA
ENV SHA=${SHA}

EXPOSE  3000
USER nobody
CMD [ "./up.sh" ]
