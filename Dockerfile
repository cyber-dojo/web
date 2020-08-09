FROM cyberdojo/web-base:fd4385f
LABEL maintainer=jon@jaggersoft.com

WORKDIR /cyber-dojo
COPY . .
RUN chown -R nobody:nogroup /cyber-dojo

# COPY --chown=nobody:nogroup . /cyber-dojo
# causes a failure when you run
# ./build_test_tag_publish.sh
# /usr/lib/ruby/2.6.0/fileutils.rb:239:in `mkdir': Permission denied @ dir_s_mkdir - /cyber-dojo/tmp (Errno::EACCES)

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

EXPOSE  3000
USER nobody
CMD [ "./up.sh" ]
