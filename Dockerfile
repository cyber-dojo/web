ARG TRUE_BASE=cyberdojo/web-base:e8c4aba
ARG BUILD_ENV
# copy|no_copy

FROM ${TRUE_BASE} as build_copy
ONBUILD COPY . /cyber-dojo
ONBUILD RUN chown -R nobody:nogroup /cyber-dojo
# NB: combining the above 2 lines into
# ONBUILD COPY --chown=nobody:nogroup . /cyber-dojo
# causes a run (docker exec cyber-dojo-web) failure...
# /usr/lib/ruby/2.5.0/fileutils.rb:232:in `mkdir': Permission denied @ dir_s_mkdir - /cyber-dojo/tmp (Errno::EACCES)

FROM ${TRUE_BASE} as build_no_copy
ONBUILD RUN echo "I need a volume-mount"

# - - - - - - - - - - - - - - - - - - - -
FROM build_${BUILD_ENV}
LABEL maintainer=jon@jaggersoft.com

WORKDIR /cyber-dojo

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

EXPOSE  3000
USER nobody
CMD [ "./up.sh" ]
