FROM cyberdojo/web-base
LABEL maintainer=jon@jaggersoft.com

WORKDIR /cyber-dojo
COPY . .
RUN chown -R nobody:nogroup .

ARG SHA
ENV SHA=${SHA}

EXPOSE  3000
USER nobody
CMD [ "./up.sh" ]
