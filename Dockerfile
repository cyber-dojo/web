FROM cyberdojo/web-base:fd4385f
LABEL maintainer=jon@jaggersoft.com

COPY . /cyber-dojo
RUN chown -R nobody:nogroup /cyber-dojo
# COPY --chown=nobody:nogroup . /cyber-dojo
# causes a run (docker exec cyber-dojo-web) failure...
# /usr/lib/ruby/2.5.0/fileutils.rb:232:in `mkdir': Permission denied @ dir_s_mkdir - /cyber-dojo/tmp (Errno::EACCES)

WORKDIR /cyber-dojo

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

EXPOSE  3000
USER nobody
CMD [ "./up.sh" ]
